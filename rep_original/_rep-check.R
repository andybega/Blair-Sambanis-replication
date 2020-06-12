#
#   How much do the replication results differ from the values reported in the
#   B&S paper?
#

library(readr)
library(dplyr)
library(tidyr)

setwd(here::here("rep_original"))

table1_orig <- read_csv("extra/table1-original.csv")
table2_orig <- read_csv("extra/table2-original.csv")

table1_orig <- table1_orig %>%
  rename(row = model) %>%
  pivot_longer(-c(horizon, row), names_to = "column", values_to = "auc_roc_paper")

table2_orig <- table2_orig %>%
  pivot_longer(-horizon, names_to = "column", values_to = "auc_roc_paper")


t1_top <- read_csv("tables/table1_top.csv") %>%
  rename(row = X1) %>%
  mutate(horizon = "1 month")
t1_bottom <- read_csv("tables/table1_bottom.csv") %>%
  rename(row = X1) %>%
  mutate(horizon = "6 months")
t1 <- bind_rows(t1_top, t1_bottom) %>%
  pivot_longer(-c(row, horizon), names_to = "column", values_to = "auc_roc_rep") %>%
  mutate(
    row = case_when(
      row=="base" ~ "Base specification",
      row=="robust_maxnodes" ~ "Terminal nodes",
      row=="robust_sampsize" ~ "Sample size",
      row=="robust_ntree"    ~ "Trees per forest",
      row=="robust_traintest1" ~ "Training/test sets 1",
      row=="robust_traintest2" ~ "Training/test sets 2",
      row=="robust_traintest3" ~ "Training/test sets 3",
      row=="robust_DV1"        ~ "Coding of DV 1",
      row=="robust_DV2"        ~ "Coding of DV 2",
      TRUE ~ row
    ),
    column = case_when(
      column=="escalation" ~ "Escalation",
      column=="quad"       ~ "Quad",
      column=="avg"        ~ "Average",
      TRUE ~ column
    )
  )

table1 <- full_join(t1, table1_orig) %>%
  mutate(diff = auc_roc_rep - auc_roc_paper)

table1 <- table1 %>%
  select(-auc_roc_rep, -auc_roc_paper) %>%
  pivot_wider(names_from = column, values_from = diff)

write_csv(table1, "extra/rep-check-table1.csv")
table1 %>%
  knitr::kable("markdown", digits = 2)


t2_top <- read_csv("tables/table2_top.csv") %>%
  rename(row = X1) %>%
  mutate(horizon = "1 month")
t2_bottom <- read_csv("tables/table2_bottom.csv") %>%
  rename(row = X1) %>%
  mutate(horizon = "6 months")

t2 <- bind_rows(t2_top, t2_bottom) %>%
  pivot_longer(-c(row, horizon), names_to = "column", values_to = "auc_roc_rep") %>%
  mutate(
    row = NULL,
    column = case_when(
      column=="escalation"    ~ "Escalation Only",
      column=="with_PITF"     ~ "With PITF Predictors",
      column=="weighted_PITF" ~ "Weighted by PITF",
      column=="split_PITF"    ~ "PITF Split Population",
      column=="PITF"          ~ "PITF Only",
      TRUE ~ column
    )
  )

table2 <- full_join(t2, table2_orig) %>%
  mutate(diff = auc_roc_rep - auc_roc_paper)

table2 <- table2 %>%
  select(-auc_roc_rep, -auc_roc_paper) %>%
  pivot_wider(names_from = column, values_from = diff)

write_csv(table2, "extra/rep-check-table2.csv")
table2 %>%
  knitr::kable("markdown", digits = 2)
