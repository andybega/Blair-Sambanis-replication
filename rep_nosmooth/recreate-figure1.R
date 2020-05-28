## Recreating figure 1 in B&S with and without smoothing
## Inputs: all calculated ROCs from the various model run scripts
## Output: a pdf and png file showing the ROCs for 1-mon and 6-mon target variables with and without smoothing

library(here)
library(stringr)
setwd(here("MB-replication-checks"))

names_1mon <- str_replace(dir("figures", pattern = "1mo-", full.names = FALSE), "\\.rds", "")
names_6mon <- str_replace(dir("figures", pattern = "6mo-", full.names = FALSE), "\\.rds", "")

ROCs_1mon <- lapply(dir("figures", pattern = "1mo-", full.names = TRUE), readRDS)
names(ROCs_1mon) <- names_1mon

ROCs_6mon <- lapply(dir("figures", pattern = "6mo-", full.names = TRUE), readRDS)
names(ROCs_6mon) <- names_6mon

png("../figures/figure1-replicated.png", width = 11, height = 10, units = "in", res = 1050)
# pdf("../figures/figure1-replicated.pdf", width = 11, height = 10)
par(mfrow = c(2, 2))

# Plot ROC curves

plot(ROCs_1mon[["roc-1mo-escalation"]],
  ylab = "True positive rate",
  xlab = "False positive rate",
  main = "ROC - Smoothed (1-mon)", lty = 1)
pROC::lines.roc(ROCs_1mon[["roc-1mo-quad"]], lty = 1)
pROC::lines.roc(ROCs_1mon[["roc-1mo-goldstein"]], lty = 3)
pROC::lines.roc(ROCs_1mon[["roc-1mo-cameo"]], lty = 4)
pROC::lines.roc(ROCs_1mon[["roc-1mo-avg"]], lty = 5)
legend("bottomright", c("Escalation", "Quad", "Goldstein", "CAMEO", "Average"), lty = c(1, 2, 3, 4, 5))

plot(ROCs_1mon[["non-smooth-roc-1mo-escalation"]],
     ylab = "True positive rate",
     xlab = "False positive rate",
     main = "ROC - Not Smoothed (1-mon)", lty = 1)
pROC::lines.roc(ROCs_1mon[["non-smooth-roc-1mo-quad"]], lty = 1)
pROC::lines.roc(ROCs_1mon[["non-smooth-roc-1mo-goldstein"]], lty = 3)
pROC::lines.roc(ROCs_1mon[["non-smooth-roc-1mo-cameo"]], lty = 4)
pROC::lines.roc(ROCs_1mon[["non-smooth-roc-1mo-avg"]], lty = 5)
# legend("bottomright", c("Escalation", "Quad", "Goldstein", "CAMEO", "Average"), lty = c(1, 2, 3, 4, 5))

plot(ROCs_6mon[["roc-6mo-escalation"]],
     ylab = "True positive rate",
     xlab = "False positive rate",
     main = "ROC - Smoothed (6-mon)", lty = 1)
pROC::lines.roc(ROCs_6mon[["roc-6mo-quad"]], lty = 1)
pROC::lines.roc(ROCs_6mon[["roc-6mo-goldstein"]], lty = 3)
pROC::lines.roc(ROCs_6mon[["roc-6mo-cameo"]], lty = 4)
pROC::lines.roc(ROCs_6mon[["roc-6mo-avg"]], lty = 5)
legend("bottomright", c("Escalation", "Quad", "Goldstein", "CAMEO", "Average"), lty = c(1, 2, 3, 4, 5))

plot(ROCs_6mon[["non-smooth-roc-6mo-escalation"]],
     ylab = "True positive rate",
     xlab = "False positive rate",
     main = "ROC - Not Smoothed (6-mon)", lty = 1)
pROC::lines.roc(ROCs_6mon[["non-smooth-roc-6mo-quad"]], lty = 1)
pROC::lines.roc(ROCs_6mon[["non-smooth-roc-6mo-goldstein"]], lty = 3)
pROC::lines.roc(ROCs_6mon[["non-smooth-roc-6mo-cameo"]], lty = 4)
pROC::lines.roc(ROCs_6mon[["non-smooth-roc-6mo-avg"]], lty = 5)
# legend("bottomright", c("Escalation", "Quad", "Goldstein", "CAMEO", "Average"), lty = c(1, 2, 3, 4, 5))

dev.off()


