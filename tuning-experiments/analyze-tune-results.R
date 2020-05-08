#
#   Analyze the tuning results
#

library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)

setwd(here::here("tuning-experiments"))

all_tune <- read_rds("output/tune-results-cumulative.rds") %>%
  # impute sampsize0 for older runs
  mutate(sampsize0 = ifelse(is.na(sampsize0), 5930, sampsize0))


tune_res <- all_tune %>%
  group_by(spec, tune_batch_id, tune_id, ntree, mtry, nodesize, sampsize0) %>%
  dplyr::summarize(mean_auc = mean(AUC),
            sd_auc   = sd(AUC),
            n = n())

# How many new-style samples do i have for each spec? (with reduced sampsize0)
tune_res %>%
  filter(sampsize0 < 5000) %>%
  ungroup() %>%
  count(spec)


# Escalation specification ------------------------------------------------
#
#   Escalation has 10 features.
#

escalation_tune <- tune_res %>%
  filter(spec=="escalation")

escalation_tune %>%
  arrange(desc(mean_auc))

escalation_tune %>%
  pivot_longer(ntree:sampsize0) %>%
  ggplot(aes(x = value, y = mean_auc, group = name)) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  geom_smooth(se = FALSE) +
  theme_minimal() +
  labs(title = sprintf("Specification: %s", "Escalation"))

escalation_tune %>%
  filter(sampsize0 < 4000) %>%
  pivot_longer(ntree:sampsize0) %>%
  ggplot(aes(x = value, y = mean_auc, group = name)) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  geom_smooth(se = FALSE) +
  theme_minimal() +
  labs(title = sprintf("Specification: %s", "Escalation"))

# TODO add some pair matrices here




# Quad specification ------------------------------------------------------
#
#   Quad has 16 features.
#

quad_tune <- tune_res %>%
  filter(spec=="quad")

quad_tune %>%
  arrange(desc(mean_auc))

quad_tune %>%
  pivot_longer(ntree:sampsize0) %>%
  ggplot(aes(x = value, y = mean_auc, group = name)) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  geom_smooth(se = FALSE) +
  theme_minimal() +
  labs(title = sprintf("Specification: %s", "Quad"))

quad_tune %>%
  filter(sampsize0 < 5000) %>%
  pivot_longer(ntree:sampsize0) %>%
  ggplot(aes(x = value, y = mean_auc, group = name)) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  geom_smooth(se = FALSE) +
  theme_minimal() +
  labs(title = sprintf("Specification: %s", "Quad"))





# Goldstein specification -------------------------------------------------
#
#   Goldstein has only 4 features.
#

goldstein_tune <- tune_res %>%
  filter(spec=="goldstein")

goldstein_tune %>%
  arrange(desc(mean_auc))

goldstein_tune %>%
  pivot_longer(ntree:sampsize0) %>%
  ggplot(aes(x = value, y = mean_auc, group = name)) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  geom_smooth(se = FALSE) +
  theme_minimal() +
  labs(title = sprintf("Specification: %s", "goldstein"))

goldstein_tune %>%
  filter(sampsize0 < 5000) %>%
  pivot_longer(ntree:sampsize0) %>%
  ggplot(aes(x = value, y = mean_auc, group = name)) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  geom_smooth(se = FALSE) +
  theme_minimal() +
  labs(title = sprintf("Specification: %s", "goldstein"))


# Cameo specification -------------------------------------------------
#
#   Cameo has 1,159 features (sqrt = 34)
#

cameo_tune <- tune_res %>%
  filter(spec=="cameo")

cameo_tune %>%
  arrange(desc(mean_auc))

cameo_tune %>%
  pivot_longer(ntree:sampsize0) %>%
  ggplot(aes(x = value, y = mean_auc, group = name)) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  geom_smooth(se = FALSE) +
  theme_minimal() +
  labs(title = sprintf("Specification: %s", "cameo"))

cameo_tune %>%
  filter(sampsize0 < 5000) %>%
  pivot_longer(ntree:sampsize0) %>%
  ggplot(aes(x = value, y = mean_auc, group = name)) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  geom_smooth(se = FALSE) +
  theme_minimal() +
  labs(title = sprintf("Specification: %s", "cameo"))



