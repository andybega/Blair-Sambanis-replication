
library(readr)
library(here)
library(dplyr)

setwd(here::here("tuning-experiments"))

res <- read_rds("output/tune-results-Rick.rds")

# Append to cumulative tuning results
all_tune <- read_rds("output/tune-results-cumulative.rds")
res$tune_batch_id <- max(all_tune$tune_batch_id, na.rm = TRUE) + 1L
all_tune <- bind_rows(all_tune, res)
write_rds(all_tune, "output/tune-results-cumulative.rds")

