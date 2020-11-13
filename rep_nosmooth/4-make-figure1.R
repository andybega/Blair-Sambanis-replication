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

dir.create(here("rep_nosmooth/output/figures"), showWarnings = FALSE)

all_predictions <- read_rds(here("rep_nosmooth/output/all-predictions.rds")) %>%
  group_by(cell_id) %>%
  nest()
model_table <- read_rds(here("rep_nosmooth/output/model-table-w-results.rds"))

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

cols <- c(
  esc = "#e41a1c",
  gold = "#ff7f00",
  quad = "#984ea3",
  cameo = "#377eb8",
  avg = "#4daf4a"
)

# linewidth
ll <- 4

png(here("rep_nosmooth/output/figures/fig-1-figure1-replicated.png"),
    width = 1100, height = 1000,
    units = "px", pointsize = 24)
par(mfrow = c(2, 2))

# Plot ROC curves

plot(roc[["1mo-smooth-escalation"]],
  ylab = "True positive rate",
  xlab = "True Negative Rate",
  main = "ROC - Smoothed (1-mon)",             lty = 1, col = cols["esc"], lwd = ll)
pROC::lines.roc(roc[["1mo-smooth-quad"]],      lty = 2, col = cols["quad"], lwd = ll)
pROC::lines.roc(roc[["1mo-smooth-goldstein"]], lty = 3, col = cols["gold"], lwd = ll)
pROC::lines.roc(roc[["1mo-smooth-cameo"]],     lty = 4, col = cols["cameo"], lwd = ll)
pROC::lines.roc(roc[["1mo-smooth-average"]],   lty = 5, col = cols["avg"], lwd = ll)
legend("bottomright",
       c("Escalation", "Quad", "Goldstein", "CAMEO", "Average"),
       lty = c(1, 2, 3, 4, 5),
       col = cols, lwd = ll)

plot(roc[["1mo-orig-escalation"]],
     ylab = "True positive rate",
     xlab = "True Negative Rate",
     main = "ROC - Not Smoothed (1-mon)",    lty = 1, col = cols["esc"], lwd = ll)
pROC::lines.roc(roc[["1mo-orig-quad"]],      lty = 2, col = cols["quad"], lwd = ll)
pROC::lines.roc(roc[["1mo-orig-goldstein"]], lty = 3, col = cols["gold"], lwd = ll)
pROC::lines.roc(roc[["1mo-orig-cameo"]],     lty = 4, col = cols["cameo"], lwd = ll)
pROC::lines.roc(roc[["1mo-orig-average"]],   lty = 5, col = cols["avg"], lwd = ll)

plot(roc[["6mo-smooth-escalation"]],
     ylab = "True positive rate",
     xlab = "True Negative Rate",
     main = "ROC - Smoothed (6-mon)",          lty = 1, col = cols["esc"], lwd = ll)
pROC::lines.roc(roc[["6mo-smooth-quad"]],      lty = 2, col = cols["quad"], lwd = ll)
pROC::lines.roc(roc[["6mo-smooth-goldstein"]], lty = 3, col = cols["gold"], lwd = ll)
pROC::lines.roc(roc[["6mo-smooth-cameo"]],     lty = 4, col = cols["cameo"], lwd = ll)
pROC::lines.roc(roc[["6mo-smooth-average"]],   lty = 5, col = cols["avg"], lwd = ll)
legend("bottomright",
       c("Escalation", "Quad", "Goldstein", "CAMEO", "Average"),
       lty = c(1, 2, 3, 4, 5),
       col = cols, lwd = ll)

plot(roc[["6mo-orig-escalation"]],
     ylab = "True positive rate",
     xlab = "True Negative Rate",
     main = "ROC - Not Smoothed (6-mon)",    lty = 1, col = cols["esc"], lwd = ll)
pROC::lines.roc(roc[["6mo-orig-quad"]],      lty = 2, col = cols["quad"], lwd = ll)
pROC::lines.roc(roc[["6mo-orig-goldstein"]], lty = 3, col = cols["gold"], lwd = ll)
pROC::lines.roc(roc[["6mo-orig-cameo"]],     lty = 4, col = cols["cameo"], lwd = ll)
pROC::lines.roc(roc[["6mo-orig-average"]],   lty = 5, col = cols["avg"], lwd = ll)

dev.off()


