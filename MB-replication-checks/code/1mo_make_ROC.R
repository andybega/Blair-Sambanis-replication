
      # loadfonts()

    # Open plot window

      # quartz()

library(here)
setwd(here::here("MB-replication-checks"))

roc_escalation_inc_civil_ns <- readRDS("figures/roc-1mo-escalation.rds")
roc_quad_inc_civil_ns <- readRDS("figures/roc-1mo-quad.rds")
roc_goldstein_inc_civil_ns <- readRDS("figures/roc-1mo-goldstein.rds")
roc_all_CAMEO_inc_civil_ns <- readRDS("figures/roc-1mo-CAMEO.rds")
roc_avg_inc_civil_ns <- readRDS("figures/roc-1mo-avg.rds")

roc_noSmooth_escalation_inc_civil_ns <- readRDS("figures/non-smooth-roc-1mo-escalation.rds")
roc_noSmooth_quad_inc_civil_ns <- readRDS("figures/non-smooth-roc-1mo-quad.rds")
roc_noSmooth_goldstein_inc_civil_ns <- readRDS("figures/non-smooth-roc-1mo-goldstein.rds")
roc_noSmooth_all_CAMEO_inc_civil_ns <- readRDS("figures/non-smooth-roc-1mo-CAMEO.rds")
roc_noSmooth_avg_inc_civil_ns <- readRDS("figures/non-smooth-roc-1mo-avg.rds")

png("../figures/figure1_top.png", family = "times", width = 11, height = 5, units = "in", res = 1050)
pdf("../figures/figure1_top.pdf", family = "times", width = 11, height = 5)
par(mfrow = c(1, 2))

# Plot ROC curves

plot(roc_escalation_inc_civil_ns,
  ylab = "True positive rate",
  xlab = "False positive rate",
  main = "ROC - Smoothed (1-mon)", lty = 1)

lines.roc(roc_quad_inc_civil_ns, lty = 1)

lines.roc(roc_goldstein_inc_civil_ns, lty = 3)

lines.roc(roc_all_CAMEO_inc_civil_ns,
lty = 4
)

lines.roc(roc_avg_inc_civil_ns,
lty = 5
)

# Add legend

legend("bottomright",
c("Escalation", "Quad", "Goldstein", "CAMEO", "Average"),
lty = c(1, 2, 3, 4, 5)
)

plot(roc_noSmooth_escalation_inc_civil_ns,
ylab = "True positive rate",
xlab = "False positive rate",
#col = c("brown"),
main = "ROC - Not Smoothed (1-mon)",
lty = 1
)

pROC::lines.roc(roc_noSmooth_quad_inc_civil_ns,
lty = 2
)

lines.roc(roc_noSmooth_goldstein_inc_civil_ns,
lty = 3
)

lines.roc(roc_noSmooth_all_CAMEO_inc_civil_ns,
lty = 4
)

lines.roc(roc_noSmooth_avg_inc_civil_ns,
lty = 5
)


dev.off()


