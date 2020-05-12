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

ggplot(with_time, aes(x = sampsize0, y = time, color = factor(ncol))) +
  geom_point() +
  scale_y_log10()

with_time %>%
  filter(sampsize0 < 4000, ncol < 20) %>%
  ggplot(aes(x = sampsize0, y = time, color = factor(ncol))) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

with_time %>%
  filter(sampsize0 < 4000, ncol < 20) %>%
  ggplot(aes(x = sampsize0, y = time, color = ntree)) +
  facet_wrap(~ ncol) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

ggplot(with_time, aes(x = ntree, y = time, color = factor(ncol))) +
  geom_point() +
  scale_y_log10()

with_time %>%
  filter(sampsize0 < 4000, ncol < 20) %>%
  ggplot(aes(x = ntree, y = time, color = factor(ncol))) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

with_time %>%
  filter(sampsize0 < 4000, ncol < 20) %>%
  ggplot(aes(x = ntree, y = time, color = sampsize0)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

ggplot(with_time, aes(x = ncol, y = time, color = ntree)) +
  geom_point() +
  scale_y_log10()

fitted_mdl <- lm(log(time) ~ log(ntree)*log(sampsize0)*ncol + machine, data = with_time)

yhat <- exp(predict(fitted_mdl, newdata = with_time, type = "response"))
y    <- with_time$time
cor(yhat, y)^2

fitted_mdl <- glm(time ~ ntree*sampsize0*ncol + machine, data = with_time, family = Gamma)

yhat <- predict(fitted_mdl, newdata = with_time, type = "response")
y    <- with_time$time
cor(yhat, y)^2

summary(fitted_mdl)

write_rds(fitted_mdl, "output/runtime-model.rds")

yhat <- predict(fitted_mdl, newdata = with_time, type = "response")
y    <- with_time$time

plot(yhat, y,
     xaxt = "n", xlim = c())
abline(a = 0, b = 1, col = "red")

plot(yhat, y,
     xaxt = "n", xlim = log(c(2, 30000)),
     yaxt = "n", ylim = log(c(2, 30000)))
abline(a = 0, b = 1, col = "red")
bks  <- c(2, 10, 60, 300, 600, 1800, 3600, 3600*5)
lbls <- c("2s", "10s", "1m", "5m", "10m", "30m", "1h", "5h")
axis(side = 1, at = log(bks), labels = lbls)
axis(side = 2, at = log(bks), labels = lbls)




