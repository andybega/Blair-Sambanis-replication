#
#   Run all the models behind Tables 1 and 2
#

WORKERS <- 7

setwd(here::here("rep_nosmooth"))

library(dplyr)
library(readr)
library(randomForest)
library(yaml)
library(jsonlite)
library(pROC)
library(foreach)
library(doFuture)

dir.create("output/predictions", recursive = TRUE, showWarnings = FALSE)

registerDoFuture()
plan("multisession", workers = WORKERS)

# Function to wrap the AUC-ROC calculation
auc_roc_vec <- function(pred, truth, smooth) {
  roc_obj <- pROC::roc(truth, pred, auc = TRUE, quiet = TRUE, smooth = smooth)
  as.numeric(roc_obj$auc)
}

# Load the model definition data

model_table    <- read_rds("output/model-definitions/model-table.rds")
feature_specs  <- read_json("output/model-definitions/feature-specs.json",
                            simplifyVector = TRUE)
dv_specs       <- read_yaml("output/model-definitions/dv-specs.yaml")
hp_settings    <- read_yaml("output/model-definitions/hp-settings.yaml")
train_end_year <- read_yaml("output/model-definitions/train-end-year.yaml")

# Load the data
data_1mo <- read_rds("trafo-data/1mo_data.rds")
data_6mo <- read_rds("trafo-data/6mo_data.rds")

# Split out the non-RF models that need special treatment
non_rf_models <- model_table %>%
  filter(non_RF==TRUE)
rf_model_table <- model_table %>%
  filter(!non_RF)

# Shuffle the model table so the workload per worker is on average more evenly
# distributed. Otherwise the script will take longer to run because it's waiting
# on the last worker that ended up with the hardest workload to finish.
rf_model_table <- rf_model_table[sample(1:nrow(rf_model_table)), ]

rf_model_table <- foreach(
  i = 1:nrow(rf_model_table),
  .inorder = FALSE
) %dopar% {

  # keep track of run time
  t0 <- proc.time()

  horizon_i <- rf_model_table[i, ][["horizon"]]
  row_i     <- rf_model_table[i, ][["row"]]
  col_i     <- rf_model_table[i, ][["column"]]

  if (horizon_i=="1 month") {
    data_i <- data_1mo
  } else {
    data_i <- data_6mo
  }

  train_data <- data_i %>% filter(year <= train_end_year[[row_i]])
  test_data  <- data_i %>% filter(year >  train_end_year[[row_i]])

  # randomForest with the x, y instead of formulate interface will not drop
  # missing values, so we need to make sure the training data drops those
  # manually
  dv_i_name    <- dv_specs[[row_i]]
  spec_i_names <- feature_specs[[col_i]]
  train_data   <- train_data %>%
    dplyr::select(one_of(c(dv_i_name, spec_i_names))) %>%
    filter(complete.cases(.))

  fitted_model <- suppressWarnings(randomForest(
    x = train_data[, spec_i_names],
    y = train_data[, dv_i_name],
    ntree    = hp_settings[[row_i]]$ntree,
    maxnodes = hp_settings[[row_i]]$maxnodes,
    sampsize = hp_settings[[row_i]]$sampsize,
    replace = FALSE, do.trace = FALSE, importance = FALSE
  ))

  # Because the original rep code uses the formula interface, the predictions
  # it puts out cover all of the test data, with NA values where needed for
  # incomplete rows. Replicate that here.
  non_missing_test_data <- test_data %>%
    dplyr::select(one_of(c("year", "period", "country_iso3", spec_i_names))) %>%
    filter(complete.cases(.))
  preds <- non_missing_test_data %>%
    dplyr::select(year, period, country_iso3) %>%
    mutate(pred = predict(fitted_model, newdata = non_missing_test_data,
                          type = "response")) %>%
    # add the non-complete rows back in
    right_join(test_data %>%
                 dplyr::select(year, period, country_iso3, one_of(dv_i_name)),
               by = c("year", "period", "country_iso3")) %>%
    # the original rep scripts do this; doesn't make a difference for ROC
    # calculations
    mutate(pred = ifelse(is.na(test_data[, dv_i_name]), NA_real_, pred))

  # 2020-05-29, AB: I checked this manually against train_model and prediction
  # in `1mo_run_escalation.R` and both seem to match what is done here in terms
  # of N and N_missing

  write_rds(preds, sprintf("output/predictions/model-%02s.rds", rf_model_table$cell_id[i]))

  res_i <- rf_model_table[i, ] %>%
    mutate(
      auc_roc          = auc_roc_vec(pred = preds$pred, truth = preds[, dv_i_name],
                                     smooth = FALSE),
      auc_roc_smoothed = auc_roc_vec(pred = preds$pred, truth = preds[, dv_i_name],
                                     smooth = TRUE),
      # The number of non-missing rows in the training data used to fit the mdl
      N_train = nrow(train_data),
      # The number of non-missing predictions
      N_test  = sum(!is.na(preds$pred)),
      time    = as.numeric((proc.time() - t0)["elapsed"])
    )
  res_i
}

rf_model_table <- bind_rows(rf_model_table)

# TODO: add handling of the special models here


# Combine and save results ------------------------------------------------

model_table_w_results <- bind_rows(rf_model_table, non_rf_models)

write_rds(model_table_w_results, "output/model-table-w-results.rds")

# Write a summary of just the AUC-ROC for git
write_csv(model_table_w_results, "output/model-table-w-results.csv")

