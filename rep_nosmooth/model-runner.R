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
library(lgr)

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

# Handle the special models that are not simple RFs
results <- list()
for (i in 1:nrow(non_rf_models)) {
  # keep track of run time
  t0 <- proc.time()

  model_type <- non_rf_models[i, ][["column"]]
  row_i      <- non_rf_models[i, ][["row"]]
  col_i      <- rf_model_table[i, ][["column"]]
  dv_i_name  <- dv_specs[[row_i]]
  horizon_i  <- non_rf_models[i, ][["horizon"]]

  if (model_type=="Average") {

    # Identify the relevant prediction models: non-Average columns with same
    # row (specification/model) and same horizon, from same table
    cell_ids <- filter(rf_model_table,
                       table   == non_rf_models[i, ][["table"]],
                       horizon == non_rf_models[i, ][["horizon"]],
                       row     == non_rf_models[i, ][["row"]]) %>%
      pull(cell_id)
    pred_file_names <- sprintf("output/predictions/model-%02s.rds", cell_ids)
    # this will have 4 predictions for each [year, period, country_iso3] row
    # before fixing this by averaging, we need to ID the DV column name, which
    # can be different for the alternative DV codings
    all_preds <- pred_file_names %>% purrr::map_dfr(., read_rds)
    vars <- setdiff(names(all_preds), "pred")
    preds <- all_preds %>%
      group_by_at(vars) %>%
      dplyr::summarize(pred = mean(pred)) %>%
      ungroup()

    # create a dummy train_data object so that the code below doesn't error out
    train_data <- data.frame(list())

  } else if (model_type=="Weighted by PITF") {
    # this model type consists of the basic escalation predictions multiplied
    # with the PITF model predictions that are in the training data frame

    # First, find the file containing the base escalation predictions for table
    # 2
    cell_id <- filter(rf_model_table,
                      table   == non_rf_models[i, ][["table"]],
                      horizon == non_rf_models[i, ][["horizon"]],
                      row     == non_rf_models[i, ][["row"]],
                      column  == "Escalation Only") %>%
      pull(cell_id)
    preds <- read_rds(sprintf("output/predictions/model-%02s.rds", cell_id))
    if (non_rf_models[i, ][["horizon"]]=="1 month") {
      df <- read_rds("trafo-data/1mo_data.rds")
    } else {
      df <- read_rds("trafo-data/6mo_data.rds")
    }
    df <- df %>% dplyr::select(year, period, country_iso3, pred_prob_plus1)
    preds <- preds %>%
      as_tibble() %>%
      left_join(df) %>%
      mutate(pred = pred*pred_prob_plus1) %>%
      dplyr::select(-pred_prob_plus1)

    # create a dummy train_data object so that the code below doesn't error out
    train_data <- data.frame(list())
  } else if (model_type=="PITF Split Population") {
    # How this "model" works:
    # train two random forests on a split version of the training data
    # combine them into a single RF using randomForest::combine
    # predict on the test set.
    # Aside from the train data split, the PITF model predictions don't enter
    # the model at all, so it's kind of just like a weird additional form of
    # randomization in the model training. See issue #5.
    if (horizon_i=="1 month") {
      data_i <- data_1mo
    } else {
      data_i <- data_6mo
    }

    train_data <- data_i %>% filter(year <= train_end_year[[row_i]])
    test_data  <- data_i %>% filter(year >  train_end_year[[row_i]])

    # Calculate the country averages before subsetting complete data, so it
    # maches what B&S do
    country_mean_pitf <- train_data %>%
      dplyr::group_by(country_iso3) %>%
      dplyr::summarize(pred_prob = mean(pred_prob, na.rm = TRUE)) %>%
      filter(complete.cases(.))
    # cor(country_mean_pitf$pred_prob, country_mean_pred_prob$pred_prob)
    # checked on 2020-06-01 that cor is 1
    cutoff <- quantile(country_mean_pitf$pred_prob, c(.25))
    # 0.00305, for both 1mo and 6mo
    # there are probably better ways to do the splitting, but this matches
    # what B&S did
    highrisk_countries <- country_mean_pitf %>%
      filter(pred_prob > cutoff) %>%
      pull(country_iso3)
    lowrisk_countries  <- country_mean_pitf %>%
      filter(pred_prob < cutoff) %>%
      pull(country_iso3)

    # Subset the data and filter to complete cases for randomForest()
    dv_i_name    <- dv_specs[[row_i]]
    spec_i_names <- feature_specs[[col_i]]

    train_data_highrisk <- train_data %>%
      filter(country_iso3 %in% highrisk_countries)
    # all(train_data_highrisk$country_iso3 %in% train_highrisk$country_iso3)
    train_data_highrisk <- train_data_highrisk %>%
      dplyr::select(one_of(c(dv_i_name, spec_i_names))) %>%
      filter(complete.cases(.))

    train_data_lowrisk <- train_data %>%
      filter(country_iso3 %in% lowrisk_countries)
    # all(train_data_lowrisk$country_iso3 %in% train_lowrisk$country_iso3)
    train_data_lowrisk <- train_data_lowrisk %>%
      dplyr::select(one_of(c(dv_i_name, spec_i_names))) %>%
      filter(complete.cases(.))

    highrisk_model <- suppressWarnings(randomForest(
      x = train_data_highrisk[, spec_i_names],
      y = train_data_highrisk[, dv_i_name],
      ntree    = hp_settings[[row_i]]$ntree,
      maxnodes = hp_settings[[row_i]]$maxnodes,
      sampsize = hp_settings[[row_i]]$sampsize,
      replace = FALSE, do.trace = FALSE, importance = FALSE
    ))

    lowrisk_model <- suppressWarnings(randomForest(
      x = train_data_lowrisk[, spec_i_names],
      y = train_data_lowrisk[, dv_i_name],
      ntree    = hp_settings[[row_i]]$ntree,
      maxnodes = hp_settings[[row_i]]$maxnodes,
      sampsize = hp_settings[[row_i]]$sampsize,
      replace = FALSE, do.trace = FALSE, importance = FALSE
    ))

    # see #5
    fitted_model <- suppressWarnings(randomForest::combine(highrisk_model, lowrisk_model))

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
  }

  write_rds(preds, sprintf("output/predictions/model-%02s.rds", non_rf_models$cell_id[i]))

  res_i <- non_rf_models[i, ] %>%
    mutate(
      auc_roc          = auc_roc_vec(pred = preds$pred, truth = preds[[dv_i_name]],
                                     smooth = FALSE),
      auc_roc_smoothed = auc_roc_vec(pred = preds$pred, truth = preds[[dv_i_name]],
                                     smooth = TRUE),
      # The number of non-missing rows in the training data used to fit the mdl
      N_train = nrow(train_data),
      # The number of non-missing predictions
      N_test  = sum(!is.na(preds$pred)),
      time    = as.numeric((proc.time() - t0)["elapsed"])
    )
  results[[i]] <- res_i
}

results <- bind_rows(results)
non_rf_models <- results


# Combine and save results ------------------------------------------------

model_table_w_results <- bind_rows(rf_model_table, non_rf_models) %>%
  arrange(cell_id)

write_rds(model_table_w_results, "output/model-table-w-results.rds")

# Write a summary of just the AUC-ROC for git
model_table_w_results %>%
  dplyr::select(cell_id, table, horizon, row, column, auc_roc, auc_roc_smoothed) %>%
  knitr::kable("markdown", digits = 2) %>%
  writeLines("output/model-table-w-results.md")

