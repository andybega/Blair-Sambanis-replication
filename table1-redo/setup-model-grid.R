#
#   Setup model grid
#
#   This script creates a table of all the models we want to run for the Table
#   1 redo. Specifically, for the 1-month and 6-month base specification rows
#   in Table 1, we want to make the following two changes:
#
#     1. Varying RF models: the B&S hyperparameter set, default RF settings,
#        and tuned RF model.
#     2. Both test and cross-validated training data fit.
#
#   This way the actual model runner script (`run-table1-redo.R`) can run models
#   in parallel with maximum flexibility, since the various possible loops one
#   could instead do this with (e.g. 1-month/6-month > specification > RF model
#   > train-cv/test > if train-cv, the cv loop) are all unwound already.
#
#   The model grid is also setup so that each row has a unique ID that is tied
#   to the corresponding chunk file, e.g. instead of something like
#   "1-month-escalation-bandsRF-traincv-predictions.csv" it can be just
#
#   Note: right now this is only setup to work for the "Base specification"
#         rows.
#

library(tibble)
library(readr)
library(tidyr)
library(stringr)
library(dplyr)
library(rsample)
library(purrr)

setwd(here::here("table1-redo"))


# Table 1 cell definitions ------------------------------------------------
#
#   This defines the cells in Table 1
#

table1_row <- c("Base specification", "Terminal nodes", "Sample size",
                "Trees per forest", "Training/test sets 1",
                "Training/test sets 2", "Training/test sets 3",
                "Coding of DV 1", "Coding of DV 2")
table1_row <- factor(table1_row, levels = table1_row)

horizon <- c("1 month", "6 months")
horizon <- factor(horizon, levels = horizon)

# Aka the model specification (and average)
table1_column <- c("Escalation", "Quad", "Goldstein", "CAMEO", "Average")
table1_column <- factor(table1_column, levels = table1_column)

# This defines all cells in Table 1
table1 <- crossing(horizon, table1_row, table1_column)

# Only going to do this for Base specification row; otherwise some of the other
# pieces below, e.g. how the training-cv/test splits are setup below will
# change when using the train/test split variations in the table.
table1 <- table1 %>% filter(table1_row=="Base specification")



# Model variations --------------------------------------------------------
#
#   For each cell in table 1, I want to run three versions of RF
#
#   They differ in the hyperparameter values they use; hp_set = hyperparameter
#   set.
#

hp_set <- c("B&S", "Default", "Tuned")
hp_set <- factor(hp_set, levels = hp_set)



# Train-cv/test splits ----------------------------------------------------
#
#   To create the training/test and train-cv splits, i need to load the actual
#   data. Also, instead of using the actual data splits, I will just use
#   the indices, to save space.
#

data_1mo <- read_rds("trafo-data/1mo_data.rds") %>%
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

# Setup up training CV train/test data indices
set.seed(1234)
folds <- vfold_cv(train_data_1mo, v = 2, repeats = 7*3) %>%
  # keep only the row indices for the CV train/validation splits
  mutate(train_idx = map(splits, function(x) x$in_id),
         test_idx  = map(splits, function(x) (1:nrow(x$data))[-x$in_id]),
         splits = NULL)
# Make sure all splits have at least one positive case, otherwise ROC doesn't
# work
pos <- map_dbl(1:nrow(folds), df = train_data_1mo, function(i, df) {
  test_idx <- folds[i, ][["test_idx"]][[1]]
  sum(df[test_idx, ][["incidence_civil_ns_plus1"]]=="1")
})
stopifnot(all(pos > 0))

# Add a row to folds for the full models that will use all train_df data and
# will predict over the test_df data
test_row <- tibble(
  prediction_on = "test",
  id = NA_character_,
  id2 = NA_character_,
  train_idx = list(1:nrow(train_data_1mo)),
  test_idx  = list((nrow(train_data_1mo) + 1):nrow(data_1mo)),
  horizon = "1 month"
)
folds_1mo <- folds %>%
  mutate(prediction_on = "train-cv", horizon = "1 month") %>%
  select(prediction_on, everything()) %>%
  bind_rows(test_row) %>%
  # convert prediction to factor otherwise test will show up before train-cv
  mutate(prediction_on = factor(prediction_on, levels = c("train-cv", "test")))


#
#   6-month indices
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

# Setup up training CV train/test data indices
set.seed(1234)
folds <- vfold_cv(train_data_6mo, v = 2, repeats = 7*3) %>%
  # keep only the row indices for the CV train/validation splits
  mutate(train_idx = map(splits, function(x) x$in_id),
         test_idx  = map(splits, function(x) (1:nrow(x$data))[-x$in_id]),
         splits = NULL)
# Make sure all splits have at least one positive case, otherwise ROC doesn't
# work
pos <- map_dbl(1:nrow(folds), df = train_data_6mo, function(i, df) {
  test_idx <- folds[i, ][["test_idx"]][[1]]
  sum(df[test_idx, ][["incidence_civil_ns_plus1"]]=="1")
})
stopifnot(all(pos > 0))

# Add a row to folds for the full models that will use all train_df data and
# will predict over the test_df data
test_row <- tibble(
  prediction_on = "test",
  id = NA_character_,
  id2 = NA_character_,
  train_idx = list(1:nrow(train_data_6mo)),
  test_idx  = list((nrow(train_data_6mo) + 1):nrow(data_6mo)),
  horizon = "6 months"
)
folds_6mo <- folds %>%
  mutate(prediction_on = "train-cv", horizon = "6 months") %>%
  select(prediction_on, everything()) %>%
  bind_rows(test_row) %>%
  # convert prediction to factor otherwise test will show up before train-cv
  mutate(prediction_on = factor(prediction_on, levels = c("train-cv", "test")))

#
#   Combine folds
#

folds <- bind_rows(folds_1mo, folds_6mo) %>%
  rename(fold_horizon = horizon)


# Set up model grid -------------------------------------------------------
#
# [all cells in Table 1] x [the 3 RF HP sets] x [the train CV and test data indices]

full_model_grid <- crossing(table1, hp_set, folds) %>%
  # make sure 1-month/6-month folds are matched appropriately
  filter(horizon==fold_horizon) %>%
  select(-fold_horizon)

# create unique model ID string
full_model_grid <- full_model_grid %>%
  mutate(model_id = paste(horizon, table1_row, table1_column, hp_set, prediction_on, id, id2, sep = "_"),
         model_id = tolower(model_id),
         model_id = gsub("[- ]", "_", model_id)) %>%
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

# Save the full model grid
write_rds(full_model_grid, "output/table1-full-model-grid.rds")


