#
#   Analyze model run time
#

library(dplyr)
library(readr)
library(tidyr)

all_tune <- read_rds("output/tune-results-cumulative.rds")

with_time <- all_tune %>%
  filter(!is.na(time)) %>%
  mutate(ncol = case_when(
    spec=="escalation" ~ 10L,
    TRUE ~ NA_integer_))

with_time %>%
  pivot_longer(all_of(c("ntree", "mtry", "nodesize", "ncol"))) %>%
  ggplot(aes(x = value, y = time)) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  theme_minimal()

fitted_mdl <- lm(time ~ ntree , data = with_time)

summary(fitted_mdl)

plot(predict(fitted_mdl, newdata = with_time), with_time$time)




tune_res <- all_tune %>%
  group_by(tune_batch_id, tune_id, ntree, mtry, nodesize) %>%
  summarize(mean_auc = mean(AUC),
            sd_auc   = sd(AUC),
            n = n())

tune_res %>%
  pivot_longer(ntree:nodesize) %>%
  ggplot(aes(x = value, y = mean_auc, group = name)) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  geom_smooth(se = FALSE) +
  theme_minimal() +
  labs(title = sprintf("Specification: %s", spec))

tune_res %>%
  filter(mtry < 10, nodesize < 20) %>%
  pivot_longer(ntree:nodesize) %>%
  ggplot(aes(x = value, y = mean_auc, group = name)) +
  facet_wrap(~ name, scales = "free_x") +
  geom_point() +
  geom_smooth(se = FALSE) +
  theme_minimal() +
  labs(title = sprintf("Specification: %s", spec))

