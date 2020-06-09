
library(readr)
library(here)
library(dplyr)
library(purrr)

setwd(here::here("tuning-experiments"))

all_tune <- dir("output/batches", full.names = TRUE) %>%
  map(., read_rds) %>%
  bind_rows()

write_rds(all_tune, "output/all-tune-results.rds")
