#
#   Get the tuned parameter values
#

all_tune <- read_rds("output/all-tune-results.rds") %>%
  # impute sampsize0 for older runs
  mutate(sampsize0 = ifelse(is.na(sampsize0), 5930, sampsize0),
         horizon = ifelse(is.na(horizon), "1 month", horizon))

tune_res <- all_tune %>%
  group_by(horizon, spec, tune_id, ntree, mtry, nodesize, sampsize0) %>%
  dplyr::summarize(mean_auc = mean(AUC),
                   sd_auc   = sd(AUC),
                   n = n())
tune_res %>%
  group_by(horizon, spec) %>%
  arrange(horizon, spec, desc(mean_auc)) %>%
  top_n(1, mean_auc) %>%
  select(-tune_id, -mean_auc, -sd_auc, -n) -> tuned_values

tuned_values %>%
  nest(data = c(ntree:sampsize0)) %>%
  nest(data = c(spec, data)) %>%
  nest(data = c(horizon, data)) %>%
  as.list() -> foo

tuned_values %>%
  nest(data = c(ntree:sampsize0)) %>%
  mutate(data = map(data, as.list)) %>%
  nest(data = c(spec, data)) %>%
  mutate(data = map(data, as.list)) -> foo
foo


