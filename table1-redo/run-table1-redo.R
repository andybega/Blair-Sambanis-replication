#
#   Redo the 1- and 6-month base specification cells in Table 1 with:
#
#     1. Varying RF models: the B&S hyperparameter set, default RF settings,
#        and tuned RF model.
#     2. Both test and cross-validated training data fit.
#
#   This script in essence generates AUC-ROC values to complement the
#   information in Table 1.
#
#   The models run in this script are based on a model grid that is created
#   in setup-model-grid.R.
#
#     - The reason for using a table to define models is to make it easier to
#       run this stuff in parallel.
#     - The reason to setup the model grid in a separate script is that it does
#       not (should not) change between different model runs. The set of models
#       we want to run is fixed, but also, crucially, the model grid is setup
#       so that each model is uniqued identified. This is so that this script
#       can be started and stopped without loosing progress. Models that have
#       already been run are saved and do not need to be re-run again.
#

# Should existing models be re-run or overwritten?
RERUN   <- FALSE
WORKERS <- 7

library(readr)
library(tibble)
library(tidyr)
library(dplyr)
library(purrr)
library(stringr)
library(ggplot2)
library(rsample)       # for vfold_cv
library(yardstick)
library(randomForest)
library(future)
library(doFuture)
library(here)
library(lgr)
library(boot)

setwd(here::here("table1-redo"))

registerDoFuture()
plan("multisession", workers = WORKERS)

# Prepare data ------------------------------------------------------------

data_1mo <- read_rds("trafo-data/1mo_data.rds") %>%
  mutate(incidence_civil_ns_plus1 = factor(incidence_civil_ns_plus1, levels = c("1", "0")))

data_6mo <- read_rds("trafo-data/6mo_data.rds") %>%
  mutate(incidence_civil_ns_plus1 = factor(incidence_civil_ns_plus1, levels = c("1", "0")))

dv <- "incidence_civil_ns_plus1"

escalation <- c(
  "gov_opp_low_level",
  "gov_reb_low_level",
  "opp_gov_low_level",
  "reb_gov_low_level",
  "gov_opp_nonviol_repression",
  "gov_reb_nonviol_repression",
  "gov_opp_accommodations",
  "gov_reb_accommodations",
  "reb_gov_demands",
  "opp_gov_demands"
)

quad <- c(
  "gov_opp_vercf","gov_reb_vercf",
  "gov_opp_matcf","gov_reb_matcf",
  "opp_gov_vercf","reb_gov_vercf",
  "opp_gov_matcf","reb_gov_matcf",
  "gov_opp_vercp","gov_reb_vercp",
  "gov_opp_matcp","gov_reb_matcp",
  "opp_gov_vercp","reb_gov_vercp",
  "opp_gov_matcp","reb_gov_matcp"
)

goldstein <- c(
  "gov_opp_gold","gov_reb_gold",
  "opp_gov_gold","reb_gov_gold"
)

cameo <- c(
  names(data_1mo)[str_detect(names(data_1mo), "cameo_[0-9]+$")]
)

# Map the Table 1 columns names to specifications
spec_list <- list(Escalation = escalation,
                  Quad = quad,
                  Goldstein = goldstein,
                  CAMEO = cameo)

#
#   1-month indices
#

# Make sure we are operating on same df for all specs
data_1mo <- data_1mo[complete.cases(data_1mo[, unique(c(dv, escalation, cameo))]), ]

# Need to sort the df by year and month (implicitly period, which is a unique
# ID for year-month), otherwise the train/test indices will be wrong
data_1mo <- data_1mo %>% arrange(year, month, country_iso3)

# Define training and testing sets for base specification
train_period <- mean(data_1mo$period[which(data_1mo$month==12 & data_1mo$year==2007)])
end_period   <- mean(data_1mo$period[which(data_1mo$month==12 & data_1mo$year==2015)])

train_data_1mo <- data_1mo[data_1mo$period<=train_period,]
test_data_1mo  <- data_1mo[data_1mo$period>train_period & data_1mo$period<=end_period,]


#
#   6-month data
#

data_6mo <- read_rds("trafo-data/6mo_data.rds") %>%
  mutate(incidence_civil_ns_plus1 = factor(incidence_civil_ns_plus1, levels = c("1", "0")))

# Make sure we are operating on same df for all specs
data_6mo <- data_6mo[complete.cases(data_6mo[, unique(c(dv, escalation, cameo))]), ]

# Need to sort the df by year and period (implicitly period, which is a unique
# ID for half-year), otherwise the train/test indices will be wrong
data_6mo <- data_6mo %>% arrange(year, period, country_iso3)

# Define training and testing sets for base specification
# periods are from +master.R
train_data_6mo <- data_6mo[data_6mo$period<=14, ]
test_data_6mo  <- data_6mo[data_6mo$period>14 & data_6mo$period<=30, ]


# Set up RF model functions -----------------------------------------------
#
#   I'm going to define a couple of model functions here. In Table 1 in the
#   paper, the results are identified by 3 dimensions:
#
#     - forecast horizon: 1 month or 6 month
#     - settings, what B&S call "specification": variations in RF
#       hyperparameters, train/test splits, and DV coding
#     - feature sets, what I will call specification: the columns used as
#       predictors, e.g. escalation, CAMEO
#
#   So a result cell in the table is identified by [horizon, setting, spec].
#
#   I am interested in two things:
#
#     - adding a RF model version that uses alternative hyperparameter settings
#     - obtaining cross-validated OOS fit for the training data split
#
#   Since the setting dimension includes both changes in the RF settings and
#   changes in the data, adding another RF setting choice kind of requires
#   splitting this dimension into RF settings vs. data changes. Maybe for now
#   it's just easier to ignore this and add "another row".
#
#   I'm also going to only do this for 1 month for now. What makes sense then
#   for the sake of flexibility is to encapsulate the model [setting] in a
#   function but allow the feature specification [spec] and training data to
#   vary
#
#     rf_[setting](data, features = [spec], horizon = 1mo)
#

# Base specification
#
# Corresponds to the settings in the first row in Table 1
#
# examples
#
# mdl    <- rf_base(train_df, escalation)
# phat   <- predict.rf_base(mdl, train_df)
# pcheck <- mdl$predicted
# cor(phat, pcheck)
# # the correlation is a bit less than 1. This also happens with the examples
# # in ?randomForest
#
rf_base <- function(data, features, ...) {
  suppressWarnings({
    randomForest(y = as.integer(data$incidence_civil_ns_plus1=="1"),
                 x = data[, features],
                 type = "regression",
                 ntree = 100000,
                 maxnodes = 5,
                 sampsize = 100,
                 replace = FALSE,
                 do.trace = FALSE)
  })
}

predict.rf_base <- function(object, new_data, ...) {
  # predict.randomForest checks for missing values in new_data before selecting
  # the columns that are actually needed. So if there are missing values in
  # unneeded columns, this will still cause an error.
  new_data <- new_data[, rownames(object$importance)]
  as.vector(predict(object, newdata = new_data, type = "response"))
}


# Default RF
#
# RF with out of the box hyperparameter settings
#
# example
#
# mdl    <- rf_default(train_df, escalation)
# phat   <- predict.rf_default(mdl, train_df)
rf_default <- function(data, features, ...) {
  stopifnot(is.factor(data$incidence_civil_ns_plus1))
  randomForest(y = data$incidence_civil_ns_plus1,
               x = data[, features],
               type = "classification",
               do.trace = FALSE)
}

predict.rf_default <- function(object, new_data, ...) {
  new_data <- new_data[, rownames(object$importance)]
  as.vector(predict(object, newdata = new_data, type = "prob")[, "1"])
}

# Tuned RF
#
# RF with tuned hyperparameters
#
# @param horizon forecast horizon, "1 month" or "6 months"
# @param hp_dict Hyperparameter dictionary from the tuning experiments
#
# example
#
# mdl    <- rf_tuned(train_df, escalation, spec = "Escalation")
# phat   <- predict.rf_tuned(mdl, train_df)
rf_tuned <- function(data, features, spec, horizon, hp_dict, ...) {
  stopifnot(is.factor(data$incidence_civil_ns_plus1),
            spec %in% c("Escalation", "Quad", "Goldstein", "CAMEO"))

  tune_values <- hp_dict[[horizon]][[tolower(spec)]]
  if (is.null(tune_values)) {
    stop("Hyperparameter values not available in hp_dict for this horizon and specification")
  }

  randomForest(y = data$incidence_civil_ns_plus1,
               x = data[, features],
               type = "classification",
               ntree = tune_values[["ntree"]],
               mtry  = tune_values[["mtry"]],
               nodesize = tune_values[["nodesize"]],
               sampsize = c(1, tune_values[["sampsize0"]]),
               strata   = data$incidence_civil_ns_plus1,
               replace  = FALSE,
               do.trace = FALSE)
}

predict.rf_tuned <- function(object, new_data, ...) {
  new_data <- new_data[, rownames(object$importance)]
  as.vector(predict(object, newdata = new_data, type = "prob")[, "1"])
}


# Excecute the model runs -------------------------------------------------

full_model_grid <- read_rds("output/full-model-grid.rds")
hp_dict <- read_rds("input-data/hyperparameter-dictionary.rds")

# For now I'm only interested in running the base specification row, so filter
# on that. The average model also requires special treatment, so take it out.
model_grid <- full_model_grid %>%
  filter(table1_row=="Base specification",
         horizon=="1 month",
         table1_column %in% c("Quad", "Escalation", "Goldstein"),
         hp_set %in% c("Tuned")
  )

dir.create("output/chunks/prediction", showWarnings = FALSE, recursive = TRUE)
dir.create("output/chunks/roc", showWarnings = FALSE)

# Keep track of how many models we aim to run
writeLines(as.character(nrow(model_grid)), "output/chunks/n-chunks.txt")

# Take out models that have already been run
if (!RERUN & dir.exists("output/chunks/prediction")) {
  # Check both prediction and roc files in case somehow one got written but
  # no the other
  pred_ids <- dir("output/chunks/prediction") %>%
    basename() %>%
    str_replace("\\.rds", "")
  roc_ids <- dir("output/chunks/roc") %>%
    basename() %>%
    str_replace("\\.csv", "")
  done_ids <- intersect(pred_ids, roc_ids)
  model_grid <- model_grid %>%
    filter(!model_id %in% done_ids)
}

# shuffle model grid for more event worker load
model_grid <- model_grid[sample(1:nrow(model_grid)), ]

set.seed(5235)

res <- foreach(
  i = 1:nrow(model_grid),
  .export = c("model_grid", "data_1mo", "data_6mo", "spec_list", "dv", "hp_dict"),
  .packages = c("randomForest", "tibble", "yardstick", "dplyr"),
  .inorder = FALSE) %dopar% {
    # keep track of run time
    t0 <- proc.time()

    chunk_id <- model_grid$model_id[[i]]

    # setup train and test data for this taks
    horizon_i <- model_grid$horizon[[i]]
    if (horizon_i=="1 month") {
      train_i <- data_1mo[model_grid$train_idx[[i]], ]
      test_i  <- data_1mo[model_grid$test_idx[[i]], ]
    } else {
      train_i <- data_6mo[model_grid$train_idx[[i]], ]
      test_i  <- data_6mo[model_grid$test_idx[[i]], ]
    }

    dv      <- dv
    spec    <- model_grid$table1_column[[i]]
    x_names <- spec_list[[spec]]

    hp_set <- model_grid$hp_set[[i]]

    # Run the correct RF model given the HP set
    if (hp_set=="B&S") {
      fitted_model <- rf_base(train_i, x_names)
      test_preds   <- tibble(
        preds = predict.rf_base(fitted_model, test_i),
        truth = test_i[, dv]
      )
    } else if (hp_set=="Default") {
      fitted_model <- rf_default(train_i, x_names)
      test_preds   <- tibble(
        preds = predict.rf_default(fitted_model, test_i),
        truth = test_i[, dv]
      )
    } else {
      fitted_model <- rf_tuned(train_i, x_names, spec, horizon = horizon_i,
                               hp_dict = hp_dict)
      test_preds   <- tibble(
        preds = predict.rf_tuned(fitted_model, test_i),
        truth = test_i[, dv]
      )
    }

    # Write output
    # 1. Predictions
    pred_path <- file.path(sprintf("output/chunks/prediction/%s.rds", chunk_id))
    write_rds(test_preds, path = pred_path)

    # 2. Summary stats
    res <- tibble(
      model_id = chunk_id,
      AUC = roc_auc(test_preds, truth, preds)[[".estimate"]],
      time = as.numeric((proc.time() - t0)["elapsed"])
    )
    roc_path <- file.path(sprintf("output/chunks/roc/%s.csv", chunk_id))
    write_csv(res, roc_path)

    NULL
  }


# Collect chunks ----------------------------------------------------------

roc <- chunk_files <- dir("output/chunks/roc", full.names = TRUE) %>%
  map(read_csv, col_types = cols(
    model_id = col_character(),
    AUC = col_double()
  )) %>%
  bind_rows()

model_mapping <- read_csv("output/model-id-mapping.csv")

roc <- model_mapping %>%
  left_join(roc, by = "model_id")

write_rds(roc, "output/auc-roc-samples.rds")

boot_ci <- function(x) {
  bb <- boot(x, function(x, indices) mean(x[indices]), R = 2000)
  ci <- boot.ci(bb, type = "basic")
  out <- as.list(ci$basic[4:5])
  names(out) <- c("ci_lower", "ci_upper")
  as_tibble(out)
}

test_fit <- roc %>%
  filter(!is.na(AUC)) %>%
  filter(prediction_on=="test") %>%
  select(table1_row, table1_column, horizon, hp_set, AUC) %>%
  rename(Test_AUC_ROC = AUC)

traincv_roc <- roc %>%
  filter(prediction_on=="train-cv")

cv_fit <- traincv_roc %>%
  filter(!is.na(AUC)) %>%
  group_by(table1_row, table1_column, horizon, hp_set) %>%
  summarize(mean_AUC = mean(AUC),
            sd_AUC   = sd(AUC),
            ci = list(boot_ci(AUC))) %>%
  unnest(ci) %>%
  ungroup()

fit_table <- cv_fit %>%
  left_join(test_fit) %>%
  select(-sd_AUC, -ci_lower, -ci_upper)

fit_table %>%
  arrange(horizon, table1_column, hp_set) %>%
  select(-table1_row) %>%
  select(horizon, table1_column, hp_set, everything()) %>%
  knitr::kable(digits = 2) %>%
  writeLines("output/tbl-traincv-test-fit.md")


by_model <- traincv_roc %>%
  filter(!is.na(AUC)) %>%
  filter(horizon=="1 month") %>%
  tidyr::unite(col = "model", c(table1_column, hp_set), remove = TRUE) %>%
  select(model, AUC)
temp <- by_model %>%
  rename(model2 = model, AUC2 = AUC) %>%
  nest(data2 = c(AUC2))
by_model <- crossing(
  by_model %>% nest(data = c(AUC)),
  temp
) %>%
  unnest(c(data, data2))
t_test_matrix <- by_model %>%
  group_by(model, model2) %>%
  summarize(p_value = t.test(AUC, AUC2, alternative = "greater")$p.value) %>%
  pivot_wider(names_from = model2, values_from = p_value)

t_test_matrix %>%
  knitr::kable(digits = 2) %>%
  writeLines("output/tbl-traincv-1month-t-tests.md")

by_model <- traincv_roc %>%
  filter(!is.na(AUC)) %>%
  filter(horizon=="6 months") %>%
  tidyr::unite(col = "model", c(table1_column, hp_set), remove = TRUE) %>%
  select(model, AUC)
temp <- by_model %>%
  rename(model2 = model, AUC2 = AUC) %>%
  nest(data2 = c(AUC2))
by_model <- crossing(
  by_model %>% nest(data = c(AUC)),
  temp
) %>%
  unnest(c(data, data2))
t_test_matrix <- by_model %>%
  group_by(model, model2) %>%
  summarize(p_value = t.test(AUC, AUC2, alternative = "greater")$p.value) %>%
  pivot_wider(names_from = model2, values_from = p_value)

t_test_matrix %>%
  knitr::kable(digits = 2) %>%
  writeLines("output/tbl-traincv-6month-t-tests.md")


