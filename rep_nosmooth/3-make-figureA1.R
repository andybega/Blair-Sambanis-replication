#
#   Generate Figure A.1., Comparing Escalation to alternative models in B&S
#   Table 1.
#

library(ggplot2)
library(readr)
library(dplyr)
library(tidyr)
library(here)

setwd(here::here("rep_nosmooth"))

table1_nosmooth <- read_csv("output/tables/table1-nosmooth.csv")

icews_lvls <- c("Escalation", "Quad", "Goldstein", "CAMEO", "Average")

df <- table1_nosmooth %>%
  rename(Spec = Model) %>%
  pivot_longer(Escalation:Average, names_to = "Model", values_to = "auc_roc") %>%
  mutate(Model = factor(Model, levels = icews_lvls)) %>%
  nest(data = c(Spec, auc_roc))

pairs <- full_join(
  df %>% filter(Model!="Escalation"),
  df %>% filter(Model=="Escalation") %>% rename(data2 = data) %>% select(horizon, data2),
  by = c("horizon")
) %>%
  pivot_longer(data:data2, names_to = "xname", values_to = "data") %>%
  mutate(xname = ifelse(xname=="data", as.character(Model), "Escalation"),
         xname = factor(xname, levels = icews_lvls))

p <- pairs %>%
  unnest(data) %>%
  ggplot(aes(x = xname, y = auc_roc)) +
  facet_grid(horizon ~ Model, scales = "free_x") +
  geom_point() +
  geom_line(aes(group = Spec)) +
  theme_bw() +
  theme(panel.grid.minor = element_blank()) +
  labs(x = "", y = "AUC-ROC (empirical)")

ggsave(plot=p, filename = "output/figures/fig-A1-table1-pairs.png",
       height = 5, width = 8)

