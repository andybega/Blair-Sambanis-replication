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

# Should existing models be re-run or overwritten?
RERUN   <- TRUE
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

setwd(here::here("tuning-experiments"))

registerDoFuture()
plan("multisession", workers = WORKERS)

# Prepare data ------------------------------------------------------------

df <- read_rds("trafo-data/1mo_data.rds") %>%
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
  names(df)[str_detect(names(df), "cameo_[0-9]+$")]
)

# Map the Table 1 columns names to specifications
spec_list <- list(Escalation = escalation,
                  Quad = quad,
                  Goldstein = goldstein,
                  CAMEO = cameo)

# Make sure we are operating on same df for both specs
df <- df[complete.cases(df[, unique(c(dv, escalation, cameo))]), ]

# Need to sort the df by year and month (implicitly period, which is a unique
# ID for year-month), otherwise the train/test indices will be wrong
df <- df %>% arrange(year, month, country_iso3)

# Define training and testing sets for base specification
train_period = mean(df$period[which(df$month==12 & df$year==2007)])
end_period = mean(df$period[which(df$month==12 & df$year==2015)])

train_df <- df[df$period<=train_period,]
test_df  <- df[df$period>train_period & df$period<=end_period,]



# Set up model grid -------------------------------------------------------
#

table1_row <- c("Base specification", "Terminal nodes", "Sample size",
                 "Trees per forest", "Training/test sets 1",
                 "Training/test sets 2", "Training/test sets 3",
                 "Coding of DV 1", "Coding of DV 2")
table1_row <- factor(table1_row, levels = table1_row)
horizon <- c("1 month", "6 months")
horizon <- factor(horizon, levels = horizon)
table1_columns <- c("Escalation", "Quad", "Goldstein", "CAMEO", "Average")
table1_columns <- factor(table1_columns, levels = table1_columns)

# This defines all cells in Table 1
table1 <- crossing(table1_row, table1_columns, horizon)

# For each cell in table 1, I want to run three versions of RF
hp_set <- c("B&S", "Default", "Tuned")
hp_set <- factor(hp_set, levels = hp_set)

# Setup up training CV train/test data indices
set.seed(1234)
folds <- vfold_cv(train_df, v = 2, repeats = 7*3) %>%
  # keep only the row indices for the CV train/validation splits
  mutate(train_idx = map(splits, function(x) x$in_id),
         test_idx  = map(splits, function(x) (1:nrow(x$data))[-x$in_id]),
         splits = NULL)
# Make sure all splits have at least one positive case, otherwise ROC doesn't
# work
pos <- map_dbl(1:nrow(folds), df = train_df, function(i, df) {
  test_idx <- folds[i, ][["test_idx"]][[1]]
  sum(train_df[test_idx, ][["incidence_civil_ns_plus1"]]=="1")
})
stopifnot(all(pos > 0))

# Add a row to folds for the full models that will use all train_df data and
# will predict over the test_df data
test_row <- tibble(
  prediction_on = "test",
  id = NA_character_,
  id2 = NA_character_,
  train_idx = list(1:nrow(train_df)),
  test_idx  = list((nrow(train_df) + 1):nrow(df))
)
folds <- folds %>%
  mutate(prediction_on = "train-cv") %>%
  select(prediction_on, everything()) %>%
  bind_rows(test_row) %>%
  # convert prediction to factor otherwise test will show up before train-cv
  mutate(prediction_on = factor(prediction_on, levels = c("train-cv", "test")))

# Create the full model grid:
# [all cells in Table 1] x [the 3 RF HP sets] x [the train CV and test data indices]
full_model_grid <- crossing(table1, hp_set, folds) %>%
  # create a unique ID for each model
  mutate(model_id = 1:n()) %>%
  select(model_id, everything())

# Write a copy of the full grid, sans the actual indices, to a CSV file. This
# is so that any permutations that alter what rows are associated with what
# model_id will show up in git. They shouldn't, since a permutation of model IDs
# would be a fatal mistake that breaks the link between model and correct chunk
# file.
full_model_grid %>%
  select(model_id:id2) %>%
  write_csv("output/table1-model-id-mapping.csv")

# And the first and second train/test indices just to make sure they don't change
# THESE SHOULD NOT CHANGE
full_model_grid %>%
  pull(train_idx) %>%
  `[[`(1) %>%
  as.character() %>%
  writeLines("output/table1-full-model-grid-train-idx-1.txt")
full_model_grid %>%
  pull(train_idx) %>%
  `[[`(2) %>%
  as.character() %>%
  writeLines("output/table1-full-model-grid-train-idx-2.txt")

# Save the full model grid as well, just in case.
write_rds(full_model_grid, "output/table1-full-model-grid.rds")


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
# example
#
# mdl    <- rf_tuned(train_df, escalation, spec = "Escalation")
# phat   <- predict.rf_tuned(mdl, train_df)
rf_tuned <- function(data, features, spec, ...) {
  stopifnot(is.factor(data$incidence_civil_ns_plus1),
            spec %in% c("Escalation", "Quad", "Goldstein", "CAMEO"))
  tune_values <- list(
    Escalation = list(ntree = 20000, mtry = 4,  nodesize = 2, sampsize0 = 1000),
    Quad       = list(ntree = 20000, mtry = 4,  nodesize = 2, sampsize0 = 500),
    Goldstein  = list(ntree = 20000, mtry = 2,  nodesize = 4, sampsize0 = 500),
    CAMEO      = list(ntree = 20000, mtry = 34, nodesize = 5, sampsize0 = 500)
  )
  tune_values <- tune_values[[spec]]

  randomForest(y = data$incidence_civil_ns_plus1,
               x = data[, features],
               type = "classification",
               ntree = tune_values[["ntree"]],
               mtry  = tune_values[["mtry"]],
               nodesize = tune_values[["nodesize"]],
               sampsize = c(1, tune_values[["sampsize0"]]),
               strata   = train_i$incidence_civil_ns_plus1,
               replace  = FALSE,
               do.trace = FALSE)
}

predict.rf_tuned <- function(object, new_data, ...) {
  new_data <- new_data[, rownames(object$importance)]
  as.vector(predict(object, newdata = new_data, type = "prob")[, "1"])
}


# Excecute the model runs -------------------------------------------------

# For now I'm only interested in running the base specification row, so filter
# on that. The average model also requires special treatment, so take it out.
model_grid <- full_model_grid %>%
  filter(table1_row=="Base specification",
         horizon=="1 month",  # I haven't set this nor the tune stuff up to work with the 6month data yet.
         table1_columns!="Average",
         (hp_set!= "Tuned" | (hp_set=="Tuned" & table1_columns %in% c("Escalation", "Quad", "Goldstein")))
  )

dir.create("output/table1-chunks/prediction", showWarnings = FALSE, recursive = TRUE)
dir.create("output/table1-chunks/roc", showWarnings = FALSE)

# Keep track of how many models we aim to run
writeLines(as.character(nrow(model_grid)), "output/table1-chunks/n-chunks.txt")

# Take out models that have already been run
if (!RERUN & dir.exists("output/table1-chunks/prediction")) {
  # Check both prediction and roc files in case somehow one got written but
  # no the other
  pred_ids <- dir("output/table1-chunks/prediction") %>%
    str_extract("[0-9]+") %>%
    as.integer()
  roc_ids <- dir("output/table1-chunks/roc") %>%
    str_extract("[0-9]+") %>%
    as.integer()
  done_ids <- intersect(pred_ids, roc_ids)
  model_grid <- model_grid %>%
    filter(!model_id %in% done_ids)
}

set.seed(5235)

res <- foreach(
  i = 1:nrow(model_grid),
  .export = c("model_grid", "df", "spec_list", "dv"),
  .packages = c("randomForest", "tibble", "yardstick", "dplyr"),
  .inorder = FALSE) %dopar% {

    # keep track of run time
    t0 <- proc.time()

    chunk_id <- model_grid$model_id[[i]]

    train_i <- df[model_grid$train_idx[[i]], ]
    test_i  <- df[model_grid$test_idx[[i]], ]

    dv      <- dv
    spec    <- model_grid$table1_columns[[i]]
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
      fitted_model <- rf_tuned(train_i, x_names, spec)
      test_preds   <- tibble(
        preds = predict.rf_tuned(fitted_model, test_i),
        truth = test_i[, dv]
      )
    }

    # Write output
    # 1. Predictions
    pred_path <- file.path(sprintf("output/table1-chunks/prediction/chunk-%04d.rds", chunk_id))
    write_rds(test_preds, path =pred_path)

    # 2. Summary stats
    res <- tibble(
      model_id = chunk_id,
      AUC = roc_auc(test_preds, truth, preds)[[".estimate"]]
    )
    roc_path <- file.path(sprintf("output/table1-chunks/roc/chunk-%04d.csv", chunk_id))
    write_csv(res, roc_path)

    NULL
  }



# Collect chunks ----------------------------------------------------------

roc <- chunk_files <- dir("output/table1-chunks/roc", full.names = TRUE) %>%
  map(read_csv, col_types = cols(
    model_id = col_double(),
    AUC = col_double()
  )) %>%
  bind_rows()

model_mapping <- read_csv("output/table1-model-id-mapping.csv")

roc <- roc %>%
  left_join(model_mapping, by = "model_id")

write_rds(roc, "table1-auc-roc-samples.rds")

boot_ci <- function(x) {
  bb <- boot(x, function(x, indices) mean(x[indices]), R = 2000)
  ci <- boot.ci(bb, type = "basic")
  out <- as.list(ci$basic[4:5])
  names(out) <- c("ci_lower", "ci_upper")
  as_tibble(out)
}

test_fit <- roc %>%
  filter(prediction_on=="test") %>%
  select(table1_row, table1_columns, horizon, hp_set, AUC) %>%
  rename(Test_AUC_ROC = AUC)

traincv_roc <- roc %>%
  filter(prediction_on=="train-cv")

cv_fit <- traincv_roc %>%
  group_by(table1_row, table1_columns, horizon, hp_set) %>%
  summarize(mean_AUC = mean(AUC),
            sd_AUC   = sd(AUC),
            ci = list(boot_ci(AUC))) %>%
  unnest(ci) %>%
  ungroup()

fit_table <- cv_fit %>%
  left_join(test_fit) %>%
  select(-sd_AUC, -ci_lower, -ci_upper)

fit_table %>%
  arrange(horizon, table1_columns, hp_set) %>%
  select(-table1_row) %>%
  select(horizon, table1_columns, hp_set, everything()) %>%
  knitr::kable(digits = 2) %>%
  writeLines("output/tbl-traincv-test-fit.md")


by_model <- traincv_roc %>%
  filter(horizon=="1 month") %>%
  tidyr::unite(col = "model", c(table1_columns, hp_set), remove = TRUE) %>%
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
  filter(horizon=="6 months") %>%
  tidyr::unite(col = "model", c(table1_columns, hp_set), remove = TRUE) %>%
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


