
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


