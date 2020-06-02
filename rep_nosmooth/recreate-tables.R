
library(readr)
library(dplyr)
library(tidyr)
library(kableExtra)

results <- read_rds("output/model-table-w-results-1234.rds")


# Table 1 -----------------------------------------------------------------

table1_smooth <- results %>%
  filter(table=="Table 1") %>%
  dplyr::select(horizon, row, column, auc_roc_smoothed) %>%
  arrange(horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "auc_roc_smoothed") %>%
  dplyr::select(horizon, row, Escalation, Quad, Goldstein, CAMEO, Average) %>%
  rename(Model = row)

write_csv(table1_smooth, "output/table1-smooth.csv")
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

write_csv(table1_nosmooth, "output/table1-nosmooth.csv")
table1_nosmooth %>%
  knitr::kable("markdown", digits = 2) %>%
  writeLines("output/table1-nosmooth.md")

smooth_benefit <- results %>%
  filter(table=="Table 1") %>%
  mutate(diff = auc_roc_smoothed - auc_roc) %>%
  dplyr::select(horizon, row, column, diff) %>%
  arrange(horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "diff") %>%
  dplyr::select(horizon, row, Escalation, Quad, Goldstein, CAMEO, Average) %>%
  rename(Model = row)

write_csv(smooth_benefit, "output/table1-smooth-benefit.csv")
smooth_benefit %>%
  knitr::kable("markdown", digits = 2) %>%
  writeLines("output/table1-smooth-benefit.md")

# N_train

results %>%
  filter(table=="Table 1") %>%
  dplyr::select(table, horizon, row, column, N_train) %>%
  arrange(table, horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "N_train") %>%
  dplyr::select(table, horizon, row, Escalation, Quad, Goldstein, CAMEO, Average) %>%
  rename(Model = row)

results %>%
  filter(table=="Table 2") %>%
  select(table, horizon, row, column, N_train) %>%
  arrange(table, horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "N_train") %>%
  select(table, horizon, row, everything()) %>%
  rename(Model = row)

# N_test

results %>%
  filter(table=="Table 1") %>%
  select(table, horizon, row, column, N_test) %>%
  arrange(table, horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "N_test") %>%
  select(table, horizon, row, Escalation, Quad, Goldstein, CAMEO, Average) %>%
  rename(Model = row)

results %>%
  filter(table=="Table 2") %>%
  select(table, horizon, row, column, N_test) %>%
  arrange(table, horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "N_test") %>%
  select(table, horizon, row, everything()) %>%
  rename(Model = row)



# Table 2 -----------------------------------------------------------------

table2_smooth <- results %>%
  filter(table=="Table 2") %>%
  dplyr::select(horizon, row, column, auc_roc_smoothed) %>%
  arrange(horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "auc_roc_smoothed") %>%
  rename(Model = row)

write_csv(table2_smooth, "output/table2-smooth.csv")
table2_smooth %>%
  knitr::kable("markdown", digits = 2) %>%
  writeLines("output/table2-smooth.md")

table2_nosmooth <- results %>%
  filter(table=="Table 2") %>%
  dplyr::select(horizon, row, column, auc_roc) %>%
  arrange(horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "auc_roc") %>%
  rename(Model = row)

write_csv(table2_nosmooth, "output/table2-nosmooth.csv")
table2_nosmooth %>%
  knitr::kable("markdown", digits = 2) %>%
  writeLines("output/table2-nosmooth.md")

table2_smooth_benefit <- results %>%
  filter(table=="Table 2") %>%
  mutate(diff = auc_roc_smoothed - auc_roc) %>%
  dplyr::select(horizon, row, column, diff) %>%
  arrange(horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "diff") %>%
  rename(Model = row)

write_csv(smooth_benefit, "output/table2-smooth-benefit.csv")
table2_smooth_benefit %>%
  knitr::kable("markdown", digits = 2) %>%
  writeLines("output/table2-smooth-benefit.md")
