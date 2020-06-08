library(here)
library(readr)
library(dplyr)
library(tidyr)
library(kableExtra)
library(purrr)

setwd(here::here("rep_nosmooth"))
dir.create("output/tables")

results <- read_rds("output/model-table-w-results.rds")

# Table 1 -----------------------------------------------------------------

# Note that all rows in Table 1 operate, correctly, on the same test
# set N
table1_N <- results %>%
  filter(table=="Table 1") %>%
  select(table, horizon, row, column, N_test) %>%
  arrange(table, horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "N_test") %>%
  select(table, horizon, row, Escalation, Quad, Goldstein, CAMEO, Average) %>%
  rename(Model = row)
table1_N
table1_N %>%
  knitr::kable("markdown") %>%
  writeLines("output/table1-N.md")

table1_smooth <- results %>%
  filter(table=="Table 1") %>%
  dplyr::select(horizon, row, column, auc_roc_smoothed) %>%
  arrange(horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "auc_roc_smoothed") %>%
  dplyr::select(horizon, row, Escalation, Quad, Goldstein, CAMEO, Average) %>%
  rename(Model = row)

write_csv(table1_smooth, "output/tables/table1-smooth.csv")
table1_smooth %>%
  knitr::kable("markdown", digits = 2) %>%
  writeLines("output/table1-smooth.md")

table1_nosmooth <- results %>%
  filter(table=="Table 1") %>%
  dplyr::select(horizon, row, column, auc_roc) %>%
  arrange(horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "auc_roc") %>%
  dplyr::select(horizon, row, Escalation, Quad, Goldstein, CAMEO, Average) %>%
  rename(Model = row)

write_csv(table1_nosmooth, "output/tables/table1-nosmooth.csv")
table1_nosmooth %>%
  knitr::kable("markdown", digits = 2) %>%
  writeLines("output/table1-nosmooth.md")

table1_smooth_benefit <- results %>%
  filter(table=="Table 1") %>%
  mutate(diff = auc_roc_smoothed - auc_roc) %>%
  dplyr::select(horizon, row, column, diff) %>%
  arrange(horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "diff") %>%
  dplyr::select(horizon, row, Escalation, Quad, Goldstein, CAMEO, Average) %>%
  rename(Model = row)

write_csv(table1_smooth_benefit, "output/tables/table1-smooth-benefit.csv")
table1_smooth_benefit %>%
  knitr::kable("markdown", digits = 2) %>%
  writeLines("output/table1-smooth-benefit.md")




# Table 2 -----------------------------------------------------------------
#
#   The test set predictions for the various models in Table 2 do not cover the
#   same set of cases, so the AUC-ROC values need to be recreated from the
#   common subset of cases. (See below for a comparison of test set N.)
#

# Function to wrap the AUC-ROC calculation
auc_roc_vec <- function(pred, truth, smooth) {
  roc_obj <- pROC::roc(truth, pred, auc = TRUE, quiet = TRUE, smooth = smooth)
  as.numeric(roc_obj$auc)
}

# all-predictions is a tibble of all predictions, ID's by cell_id.
# For the common sub-setting below, it's easier to treat each set of predictions
# as a seperate list/object, so use tidyr to nest them
all_predictions <- read_rds("output/all-predictions.rds") %>%
  group_by(cell_id) %>%
  tidyr::nest(preds = year:value)

# Identify the cell IDs for the predictions we need and get the predictions
cell_ids <- results %>%
  filter(table=="Table 2") %>%
  select(cell_id, horizon, row, column)
preds <- cell_ids %>%
  left_join(all_predictions, by = "cell_id")

# Filter out cases with both non-missing prediction and non-missing outcome
# Either one missing will cause it to drop out of AUC-ROC calculation.
# Only keep the country-[time period] row identifier variables so that ID'ing
# the common subset is easier.
common_subset <- preds %>%
  mutate(preds = purrr::map(preds, function(x) {
    out <- x %>%
      filter(complete.cases(.)) %>%
      select(year, period, country_iso3)
    out
  }))
common_subset %>%
  group_by(horizon, column, preds) %>%
  summarize(n = map_int(preds, nrow)) %>%
  select(-preds)


# Since we need to calculate common subsets by horizon, split the data frame
# by horizon, then use inner_join on the row ID tibbles in each preds column
# to get the case subsets
common_subset <- common_subset %>%
  base::split(., f = as.factor(.$horizon)) %>%
  # extract only the tibbles with row info; then reduce through inner joins
  # into common subsets
  map(., "preds") %>%
  lapply(., purrr::reduce, .f = inner_join, by = c("year", "period", "country_iso3")) %>%
  map(., as_tibble)
sapply(common_subset, nrow)
# Combine them; this is now a list of cases we can check against using semi_join
common_subset <- common_subset %>%
  bind_rows(., .id = "horizon")

# Note that the number of positive cases also differs!
sapply(preds$preds, function(x) {x <- x[complete.cases(x), ]; sum(x$value==1, na.rm=T)})
preds %>%
  # reduce each prediction set down to the common case set; after this step
  # the predictions in each horizon group will have same N.
  mutate(preds = map(preds, semi_join, y = common_subset,
                     by = c("year", "period", "country_iso3"))) %>%
  pull(preds) %>%
  sapply(., function(x) {x <- x[complete.cases(x), ]; sum(x$value==1, na.rm=T)})

results_table2 <- preds %>%
  # reduce each prediction set down to the common case set; after this step
  # the predictions in each horizon group will have same N.
  mutate(preds = map(preds, semi_join, y = common_subset,
                     by = c("year", "period", "country_iso3"))) %>%
  mutate(
    N_test  = map_dbl(preds, nrow),
    auc_roc = map_dbl(
      preds, ~auc_roc_vec(.x$pred, .x$value, smooth = FALSE)
    ),
    auc_roc_smoothed = map_dbl(
      preds, ~auc_roc_vec(.x$pred, .x$value, smooth = TRUE)
    ),
    table = "Table 2"
  ) %>%
  select(-preds)

table2_smooth <- results_table2 %>%
  filter(table=="Table 2") %>%
  dplyr::select(horizon, row, column, auc_roc_smoothed) %>%
  arrange(horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "auc_roc_smoothed") %>%
  rename(Model = row)

write_csv(table2_smooth, "output/tables/table2-smooth.csv")
table2_smooth %>%
  knitr::kable("markdown", digits = 2) %>%
  writeLines("output/table2-smooth.md")

table2_nosmooth <- results_table2 %>%
  filter(table=="Table 2") %>%
  dplyr::select(horizon, row, column, auc_roc) %>%
  arrange(horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "auc_roc") %>%
  rename(Model = row)
write_csv(table2_nosmooth, "output/tables/table2-nosmooth.csv")
table2_nosmooth %>%
  knitr::kable("markdown", digits = 2) %>%
  writeLines("output/table2-nosmooth.md")

table2_smooth_benefit <- results_table2 %>%
  filter(table=="Table 2") %>%
  mutate(diff = auc_roc_smoothed - auc_roc) %>%
  dplyr::select(horizon, row, column, diff) %>%
  arrange(horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "diff") %>%
  rename(Model = row)

write_csv(table2_smooth_benefit, "output/tables/table2-smooth-benefit.csv")
table2_smooth_benefit %>%
  knitr::kable("markdown", digits = 2) %>%
  writeLines("output/table2-smooth-benefit.md")


# Appendix Table 2 --------------------------------------------------------
#
#   Construct a comprehensive version of Table 2 showing values both across
#   smooth/nosmooth and case adjustment/original N.
#

orig <- results %>%
  filter(table=="Table 2") %>%
  mutate(cases = "Original model-specific cases")

adj <- results_table2 %>%
  mutate(cases = "Cases adjusted to common subset")

full_table2 <- bind_rows(orig, adj) %>%
  select(-cell_id, -table, -non_RF, -N_train, -time)

write_csv(full_table2, "output/tables/table2-for-appendix.csv")

# keep track of N for git; easier to spot differences
table2_N <- full_table2 %>%
  select(cases, horizon, column, N_test) %>%
  arrange(desc(cases), horizon) %>%
  pivot_wider(names_from = "column", values_from = "N_test")
table2_N
table2_N %>%
  knitr::kable("markdown") %>%
  writeLines("output/table2-N.md")



# Average smooth benefit --------------------------------------------------
#
#   This is mentioned in the text
#

tbl1 <- table1_smooth_benefit %>%
  pivot_longer(Escalation:Average) %>%
  group_by(name) %>%
  summarize(Avg_benefit = mean(value)) %>%
  mutate(table = "Table 1")

tbl2 <- table2_smooth_benefit %>%
  pivot_longer(-c(horizon, Model)) %>%
  group_by(name) %>%
  summarize(Avg_benefit = mean(value)) %>%
  mutate(table = "Table 2")

bind_rows(tbl1, tbl2)

