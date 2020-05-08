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
  names(df)[str_detect(names(df), "cameo_[0-9]+$")]
)

#
#   1-month indices
#

# Make sure we are operating on same df for all specs
data_1mo <- data_1mo[complete.cases(df[, unique(c(dv, escalation, cameo))]), ]

# Need to sort the df by year and month (implicitly period, which is a unique
# ID for year-month), otherwise the train/test indices will be wrong
df <- df %>% arrange(year, month, country_iso3)

# Define training and testing sets for base specification
train_period = mean(df$period[which(df$month==12 & df$year==2007)])
end_period = mean(df$period[which(df$month==12 & df$year==2015)])

train_df <- df[df$period<=train_period,]
test_df  <- df[df$period>train_period & df$period<=end_period,]


#
#   6-month indices
#



# Set up model grid -------------------------------------------------------
#





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


