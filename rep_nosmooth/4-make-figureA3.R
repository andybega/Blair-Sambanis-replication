#
#   Create Figure A.3: Extended smooth AUC-ROC benefit plot
#


library(tidyverse)
library(yardstick)
library(pROC)
library(forcats)
library(here)

dir.create(here("rep_nosmooth/output/figures"), showWarnings = FALSE)

preds <- read_rds(here("rep_nosmooth/output/all-predictions.rds"))

auc_roc_vec <- function(pred, truth, smooth, sm = "binormal") {
  roc_obj <- pROC::roc(truth, pred, auc = TRUE, quiet = TRUE, smooth = smooth, smooth.method = sm)
  as.numeric(roc_obj$auc)
}

rocs <- preds %>%
  filter(!is.na(value)) %>%
  group_by(cell_id) %>%
  summarize(
    no = auc_roc_vec(pred = pred, truth = value, smooth = FALSE),
    binormal = auc_roc_vec(pred = pred, truth = value, smooth = TRUE, sm = "binormal"),
    density = auc_roc_vec(pred = pred, truth = value, smooth = TRUE, sm = "density"),
    fitdistr = auc_roc_vec(pred = pred, truth = value, smooth = TRUE, sm = "fitdistr")
  )

# these two take a long time and error out for some reason
#logcondens = auc_roc_vec(pred = pred, truth = value, smooth = TRUE, sm = "logcondens"),
#logcondens.smooth = auc_roc_vec(pred = pred, truth = value, smooth = TRUE, sm = "logcondens.smooth")

mt <- read_rds(here("rep_nosmooth/output/model-table-w-results.rds"))
mt <- mt %>% left_join(rocs, by = "cell_id")

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

model_levels <- c("Escalation", "Quad", "Goldstein", "CAMEO", "Average",
                  "With PITF Predictors", "Weighted by PITF", "PITF Split Population",
                  "PITF Only")

benefit <- mt %>%
  mutate(column = fct_recode(column, Escalation = "Escalation Only"),
         column = factor(column, levels = rev(model_levels))) %>%
  mutate(binormal = binormal - no,
         density  = density - no,
         fitdistr = fitdistr - no) %>%
  select(cell_id:non_RF, binormal:fitdistr) %>%
  pivot_longer(binormal:fitdistr, names_to = "method")

means <- benefit %>%
  group_by(column, method) %>%
  summarize(avg_benefit = mean(value))

p <- ggplot(benefit, aes(x = value, y = column, color = column)) +
  facet_wrap(~method) +
  geom_point() +
  scale_color_manual(guide = FALSE, values = cols) +
  theme(axis.text.y = element_text(size = 12)) +
  geom_point(data = means, aes(x = avg_benefit), shape = "|", color = "black", size = 6) +
  labs(x = "AUC(smoothed ROC) - AUC(empirical ROC)",
       y = "") +
  theme_bw() +
  geom_vline(xintercept = 0, linetype = 3) +
  theme(axis.text.y = element_text(size = 12))

ggsave(plot = p,
       filename = here("rep_nosmooth/output/figures/fig-A3-benefit-plot-extended.png"),
       height = 3.5, width = 7.5)


