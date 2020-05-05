
# loadfonts()

# Open plot window

# quartz()

## RM: ADDED 4/29/2020       
# plot.new()

# Save PDF
## RM: ADDED 4/29/2020   
      png("figures/figure1_bottom.png", family = "times", width = 11, height = 5, units = "in", res = 1050)
      
      par(mfrow = c(1, 2))
      # pdf("figures/figure1_left.pdf", family = "CM Roman", width = 5.5, height = 5)
      
      # Plot ROC curves   
      
      plot(roc_escalation_6mo_inc_civil_ns,
           ylab = "True positive rate",
           xlab = "False positive rate",
           #col = c("brown"),
           main = "ROC - Smoothed (6-mons)",
           lty = 1
      )
      
      lines.roc(roc_quad_6mo_inc_civil_ns,
                lty = 2
      )
      
      lines.roc(roc_goldstein_6mo_inc_civil_ns,
                lty = 3
      )
      
      lines.roc(roc_all_CAMEO_6mo_inc_civil_ns,
                lty = 4
      )
      
      lines.roc(roc_avg_6mo_inc_civil_ns,
                lty = 5
      )
      
      # Add legend
      
      legend("bottomright",
             c("Escalation", "Quad", "Goldstein", "CAMEO", "Average"),
             lty = c(1, 2, 3, 4, 5) 
      )
      
      plot(roc_noSmooth_escalation_6mo_inc_civil_ns,
           ylab = "True positive rate",
           xlab = "False positive rate",
           #col = c("brown"),
           main = "ROC - Not Smoothed (6-mons)",
           lty = 1
      )
      
      lines.roc(roc_noSmooth_quad_6mo_inc_civil_ns,
                lty = 2
      )
      
      lines.roc(roc_noSmooth_goldstein_6mo_inc_civil_ns,
                lty = 3
      )
      
      lines.roc(roc_noSmooth_all_CAMEO_6mo_inc_civil_ns,
                lty = 4
      )
      
      lines.roc(roc_noSmooth_avg_6mo_inc_civil_ns,
                lty = 5
      )
      
      
      dev.off()
      
