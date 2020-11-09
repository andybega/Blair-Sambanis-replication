#
#   Create Figure 2: Gain from using smoothed ROC to calculate AUC
#

library(ggplot2)
library(readr)
library(tibble)
library(dplyr)
library(tidyr)
library(here)

setwd(here::here("rep_nosmooth"))


table1_benefit <- read_csv("output/tables/table1-smooth-benefit.csv")
table2_benefit <- read_csv("output/tables/table2-smooth-benefit.csv")

cols <- c(
  Escalation = "#e41a1c",
  Goldstein = "#ff7f00",
  Quad = "#984ea3",
  CAMEO = "#377eb8",
  Average = "#4daf4a",
  `With PITF Predictors` = "gray50",
  `Weighted by PITF` = "gray50",
  `PITF Split Population` = "gray50",
  `PITF Only` = "gray50"
)

benefit <- bind_rows(
  table1_benefit %>%
    rename(setting = Model) %>%
    pivot_longer(-c(horizon, setting), names_to = "model", values_to = "diff"),
  table2_benefit %>%
    rename(setting = Model, Escalation = `Escalation Only`) %>%
    pivot_longer(-c(horizon, setting), names_to = "model", values_to = "diff")
)

# mean benefit by model
means <- benefit %>%
  group_by(model) %>%
  summarize(avg_benefit = mean(diff))

ann_text <- tibble(horizon = "1 month", diff = 0.07, model = 8.6, label = "Mean")

model_levels <- c("Escalation", "Quad", "Goldstein", "CAMEO", "Average",
                  "With PITF Predictors", "Weighted by PITF", "PITF Split Population",
                  "PITF Only")
p <- benefit %>%
  mutate(model = factor(model, levels = rev(model_levels))) %>%
  ggplot(aes(y = model)) +
  #facet_wrap(~ horizon, scales = "free_x") +
  geom_point(aes(x = diff, color = model), alpha = 0.5, size = 2) +
  scale_color_manual(guide = FALSE, values = cols) +
  geom_point(data = means, aes(x = avg_benefit), shape = "|", color = "black", size = 6) +
  labs(x = "AUC(smoothed ROC) - AUC(empirical ROC)",
       y = "") +
  theme_bw() +
  geom_text(data = ann_text, aes(x = diff, label = label), col = "black") +
  geom_vline(xintercept = 0, linetype = 3) +
  theme(axis.text.y = element_text(size = 12))

ggsave(plot = p, filename = "output/figures/fig-2-benefit-plot.png", height = 3.5, width = 5.5)
