#
#   Analyze model run time
#

library(dplyr)
library(readr)
library(tidyr)
library(here)
library(ggplot2)

setwd(here::here("tuning-experiments"))

all_tune <- read_rds("output/tune-results-cumulative.rds")

with_time <- all_tune %>%
  filter(!is.na(time)) %>%
  mutate(ncol = case_when(
    spec=="escalation" ~ 10L,
    spec=="quad" ~ 16L,
    spec=="goldstein" ~ 4L,
    spec=="cameo" ~ 1159L,
    TRUE ~ NA_integer_)) %>%
  # impute sampsize0 for older runs
  mutate(sampsize0 = ifelse(is.na(sampsize0), 5930, sampsize0)) %>%
  # impute machine for older runs
  mutate(machine = ifelse(is.na(machine), "other", machine))

with_time %>%
  pivot_longer(all_of(c("ntree", "mtry", "nodesize", "sampsize0", "ncol"))) %>%
  ggplot(aes(x = value, y = time, color = factor(machine))) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  theme_minimal() +
  scale_y_log10()

with_time %>%
  ggplot(aes(x = ntree, y = time, color = factor(ncol))) +
  geom_point() +
  theme_minimal() +
  scale_y_log10()

fitted_mdl <- lm(log(time) ~ log(ntree)*log(sampsize0)*ncol + machine, data = with_time)

summary(fitted_mdl)

write_rds(fitted_mdl, "output/runtime-model.rds")

plot(predict(fitted_mdl, newdata = with_time), log(with_time$time))




