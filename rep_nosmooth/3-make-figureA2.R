#
#   Generate Figure A.2., Comparing Escalation to alternative models in B&S
#   Table 2.
#

library(ggplot2)
library(readr)
library(dplyr)
library(tidyr)
library(here)

setwd(here::here("rep_nosmooth"))

table2_nosmooth <- read_csv("output/tables/table2-nosmooth.csv")

model_lvls <- colnames(table2_nosmooth)[-c(1:2)]

df <- table2_nosmooth %>%
  rename(Spec = Model) %>%
  pivot_longer(`Escalation Only`:`PITF Only`, names_to = "Model", values_to = "auc_roc") %>%
  mutate(Model = factor(Model, levels = model_lvls)) %>%
  nest(data = c(Spec, auc_roc))

pairs <- full_join(
  df %>% filter(Model!="Escalation Only"),
  df %>% filter(Model=="Escalation Only") %>% rename(data2 = data) %>% select(horizon, data2),
  by = c("horizon")
) %>%
  pivot_longer(data:data2, names_to = "xname", values_to = "data") %>%
  mutate(xname = ifelse(xname=="data", as.character(Model), "Escalation Only"),
         xname = factor(xname, levels = model_lvls))

p <- pairs %>%
  unnest(data) %>%
  ggplot(aes(x = xname, y = auc_roc)) +
  facet_grid(horizon ~ Model, scales = "free_x") +
  geom_point() +
  geom_line(aes(group = Spec)) +
  theme_bw() +
  theme(panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 30, hjust = 1)) +
  labs(x = "", y = "AUC-ROC (empirical)")

ggsave(plot=p, filename = "output/figures/fig-A2-table2-pairs.png",
       height = 5, width = 8)

