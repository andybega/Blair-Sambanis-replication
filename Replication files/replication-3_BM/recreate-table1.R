#
#   Recreate table 1 with non-smoothed ROC
#

library(readr)
library(dplyr)
library(here)

setwd(here::here("Replication files/replication-3_BM"))

auc <- lapply(dir("tables", pattern = "auc-", full.names = TRUE), read_csv,
              col_types = cols(
                model = col_character(),
                specification = col_character(),
                horizon = col_character(),
                smoothed = col_double(),
                original = col_double()
              )) %>%
  bind_rows() %>%
  select(model, horizon, specification, smoothed, original)
