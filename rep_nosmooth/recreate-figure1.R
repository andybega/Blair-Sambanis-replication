## Recreating figure 1 in B&S with and without smoothing
## Inputs: all calculated ROCs from the various model run scripts
## Output: a pdf and png file showing the ROCs for 1-mon and 6-mon target variables with and without smoothing

library(here)
library(stringr)
library(pROC)
library(tidyr)
library(dplyr)
library(readr)
library(tibble)

setwd(here("rep_nosmooth"))
dir.create("output/figures")

all_predictions <- read_rds("output/all-predictions.rds") %>%
  group_by(cell_id) %>%
  nest()
model_table <- read_rds("output/model-table-w-results.rds")

# We need predictions for Table 1, base specification
cell_ids <- model_table %>%
  filter(table=="Table 1", row == "Base specification") %>%
  select(cell_id, horizon, column)

preds <- cell_ids %>%
  left_join(all_predictions, by = "cell_id")

rocs <- preds %>%
  mutate(
    smooth_roc = purrr::map(data, ~pROC::roc(.x$value, .x$pred, smooth = TRUE)),
    orig_roc   = purrr::map(data, ~pROC::roc(.x$value, .x$pred, smooth = FALSE))) %>%
  select(horizon, column, smooth_roc, orig_roc) %>%
  pivot_longer(smooth_roc:orig_roc, names_to = "roc", values_to = "object")

# paste together the identifying info and make this thing into two lists, by
# horizon
roc <- rocs %>%
  mutate(horizon = ifelse(horizon=="1 month", "1mo", "6mo"),
         column  = tolower(column),
         roc     = ifelse(roc=="smooth_roc", "smooth", "orig"),
         list_name = paste(horizon, roc, column, sep = "-")) %>%
  select(list_name, object) %>%
  deframe()

png("output/figures/figure1-replicated.png", width = 1100, height = 1000,
    units = "px", pointsize = 20)
par(mfrow = c(2, 2))

# Plot ROC curves

plot(roc[["1mo-smooth-escalation"]],
  ylab = "True positive rate",
  xlab = "False positive rate",
  main = "ROC - Smoothed (1-mon)", lty = 1)
pROC::lines.roc(roc[["1mo-smooth-quad"]],      lty = 2)
pROC::lines.roc(roc[["1mo-smooth-goldstein"]], lty = 3)
pROC::lines.roc(roc[["1mo-smooth-cameo"]],     lty = 4)
pROC::lines.roc(roc[["1mo-smooth-average"]],   lty = 5)
legend("bottomright", c("Escalation", "Quad", "Goldstein", "CAMEO", "Average"), lty = c(1, 2, 3, 4, 5))

plot(roc[["1mo-orig-escalation"]],
     ylab = "True positive rate",
     xlab = "False positive rate",
     main = "ROC - Not Smoothed (1-mon)",    lty = 1)
pROC::lines.roc(roc[["1mo-orig-quad"]],      lty = 2)
pROC::lines.roc(roc[["1mo-orig-goldstein"]], lty = 3)
pROC::lines.roc(roc[["1mo-orig-cameo"]],     lty = 4)
pROC::lines.roc(roc[["1mo-orig-average"]],   lty = 5)
# legend("bottomright", c("Escalation", "Quad", "Goldstein", "CAMEO", "Average"), lty = c(1, 2, 3, 4, 5))

plot(roc[["6mo-smooth-escalation"]],
     ylab = "True positive rate",
     xlab = "False positive rate",
     main = "ROC - Smoothed (6-mon)", lty = 1)
pROC::lines.roc(roc[["6mo-smooth-quad"]],      lty = 2)
pROC::lines.roc(roc[["6mo-smooth-goldstein"]], lty = 3)
pROC::lines.roc(roc[["6mo-smooth-cameo"]],     lty = 4)
pROC::lines.roc(roc[["6mo-smooth-average"]],   lty = 5)
legend("bottomright", c("Escalation", "Quad", "Goldstein", "CAMEO", "Average"), lty = c(1, 2, 3, 4, 5))

plot(roc[["6mo-orig-escalation"]],
     ylab = "True positive rate",
     xlab = "False positive rate",
     main = "ROC - Not Smoothed (6-mon)", lty = 1)
pROC::lines.roc(roc[["6mo-orig-quad"]],      lty = 2)
pROC::lines.roc(roc[["6mo-orig-goldstein"]], lty = 3)
pROC::lines.roc(roc[["6mo-orig-cameo"]],     lty = 4)
pROC::lines.roc(roc[["6mo-orig-average"]],   lty = 5)
# legend("bottomright", c("Escalation", "Quad", "Goldstein", "CAMEO", "Average"), lty = c(1, 2, 3, 4, 5))

dev.off()


