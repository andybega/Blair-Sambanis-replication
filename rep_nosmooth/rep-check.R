#
#   How much do our replication results differ from the values reported in the
#   B&S paper?
#

library(readr)
library(dplyr)
library(tidyr)

setwd(here::here("rep_nosmooth"))
dir.create("output/tables")

stopifnot(
  "run model-runner.R first" = file.exists("output/model-table-w-results.rds"),
  "run make-original-tables.R first" = file.exists(c("output/tables/table1-original.csv", "output/tables/table2-original.csv"))
)

results <- read_rds("output/model-table-w-results.rds")

table1_orig <- read_csv("output/tables/table1-original.csv")
table2_orig <- read_csv("output/tables/table2-original.csv")

table1_orig <- table1_orig %>%
  rename(row = model) %>%
  pivot_longer(-c(horizon, row), names_to = "column", values_to = "auc_roc_paper")

table2_orig <- table2_orig %>%
  pivot_longer(-horizon, names_to = "column", values_to = "auc_roc_paper")

table1_smooth <- results %>%
  filter(table=="Table 1") %>%
  dplyr::select(horizon, row, column, auc_roc_smoothed) %>%
  arrange(horizon, row) %>%
  rename(auc_roc_ourrep = auc_roc_smoothed)

table1 <- full_join(table1_smooth, table1_orig) %>%
  mutate(diff = auc_roc_ourrep - auc_roc_paper)

table1 <- table1 %>%
  select(-auc_roc_ourrep, -auc_roc_paper) %>%
  pivot_wider(names_from = column, values_from = diff)

write_csv(table1, "output/tables/ourrep-check-table1.csv")
table1 %>%
  knitr::kable("markdown", digits = 2)



table2_smooth <- results %>%
  filter(table=="Table 2") %>%
  dplyr::select(horizon, row, column, auc_roc_smoothed) %>%
  arrange(horizon, row) %>%
  rename(auc_roc_ourrep = auc_roc_smoothed)

table2 <- full_join(table2_smooth, table2_orig) %>%
  mutate(diff = auc_roc_ourrep - auc_roc_paper)

table2 <- table2 %>%
  select(-auc_roc_ourrep, -auc_roc_paper) %>%
  pivot_wider(names_from = column, values_from = diff)

write_csv(table2, "output/tables/ourrep-check-table2.csv")
table2 %>%
  knitr::kable("markdown", digits = 2)
