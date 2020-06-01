
library(readr)
library(dplyr)
library(tidyr)
library(kableExtra)

results <- read_rds("output/model-table-w-results.rds")

table1_smooth <- results %>%
  filter(table=="Table 1") %>%
  select(horizon, row, column, auc_roc_smoothed) %>%
  arrange(horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "auc_roc_smoothed") %>%
  select(horizon, row, Escalation, Quad, Goldstein, CAMEO, Average) %>%
  rename(Model = row)

write_csv(table1_smooth, "output/table1-smooth.csv")

table1_nosmooth <- results %>%
  filter(table=="Table 1") %>%
  select(horizon, row, column, auc_roc) %>%
  arrange(horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "auc_roc") %>%
  select(horizon, row, Escalation, Quad, Goldstein, CAMEO, Average) %>%
  rename(Model = row)

write_csv(table1_nosmooth, "output/table1-nosmooth.csv")

smooth_benefit <- results %>%
  filter(table=="Table 1") %>%
  mutate(diff = auc_roc_smoothed - auc_roc) %>%
  select(horizon, row, column, diff) %>%
  arrange(horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "diff") %>%
  select(horizon, row, Escalation, Quad, Goldstein, CAMEO, Average) %>%
  rename(Model = row)

write_csv(smooth_benefit, "output/table1-smooth-benefit.csv")

# N_train

results %>%
  filter(table=="Table 1") %>%
  select(table, horizon, row, column, N_train) %>%
  arrange(table, horizon, row) %>%
  pivot_wider(names_from = "column", values_from = "N_train") %>%
  select(table, horizon, row, Escalation, Quad, Goldstein, CAMEO, Average) %>%
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
