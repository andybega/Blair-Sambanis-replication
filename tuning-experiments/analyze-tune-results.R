#
#   Analyze the tuning results
#

library(dplyr)
library(readr)
library(tidyr)

all_tune <- read_rds("output/tune-results-cumulative.rds")


tune_res <- all_tune %>%
  group_by(spec, tune_batch_id, tune_id, ntree, mtry, nodesize) %>%
  summarize(mean_auc = mean(AUC),
            sd_auc   = sd(AUC),
            n = n())


# Escalation specification ------------------------------------------------

escalation_tune <- tune_res %>%
  filter(spec=="escalation")

escalation_tune %>%
  pivot_longer(ntree:nodesize) %>%
  ggplot(aes(x = value, y = mean_auc, group = name)) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  geom_smooth(se = FALSE) +
  theme_minimal() +
  labs(title = sprintf("Specification: %s", "Escalation"))

escalation_tune %>%
  filter(mtry < 10, mtry > 1, nodesize < 20, ntree > 2000) %>%
  pivot_longer(ntree:nodesize) %>%
  ggplot(aes(x = value, y = mean_auc, group = name)) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  geom_smooth(se = FALSE) +
  theme_minimal() +
  labs(title = sprintf("Specification: %s", "Escalation"))

# TODO add some pair matrices here

escalation_tune %>%
  arrange(desc(mean_auc))


# Quad specification ------------------------------------------------------

quad_tune <- tune_res %>%
  filter(spec=="quad")

quad_tune %>%
  pivot_longer(ntree:nodesize) %>%
  ggplot(aes(x = value, y = mean_auc, group = name)) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  geom_smooth(se = FALSE) +
  theme_minimal() +
  labs(title = sprintf("Specification: %s", "Quad"))

quad_tune %>%
  filter(mtry < 6, nodesize < 20) %>%
  pivot_longer(ntree:nodesize) %>%
  ggplot(aes(x = value, y = mean_auc, group = name)) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  geom_smooth(se = FALSE) +
  theme_minimal() +
  labs(title = sprintf("Specification: %s", "Quad"))

quad_tune %>%
  arrange(desc(mean_auc))
