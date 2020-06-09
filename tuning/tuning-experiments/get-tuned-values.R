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

# Turn the tuning results into a nested list dictionary to make it easier to
# extract tune values.
tuned_values %>%
  ungroup() %>%
  nest(data = c(ntree:sampsize0)) %>%
  mutate(data = map(data, as.list)) %>%
  pivot_wider(names_from = spec, values_from = data) %>%
  nest(data = c(cameo:quad)) %>%
  mutate(data = map(data, as.list),
         # right now each data sub-element is a list with length 1; take this
         # unneccessary level out
         data = map(data, function(x) {
           map(x, `[[`, 1)
         })) %>%
  pivot_wider(names_from = horizon, values_from = data) %>%
  as.list() %>%
  map(., function(x) x[[1]]) -> hp_dict

# Hyperparameter dictionary
# Level 1: horizon
#   Level 2: specification
#     Level 3: HP
hp_dict[["1 month"]][["escalation"]]

write_rds(hp_dict, "output/hyperparameter-dictionary.rds")


