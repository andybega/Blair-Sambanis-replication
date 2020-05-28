
      loadfonts()

    # Open plot window

      quartz()

      plot.new()
      
    # Save PDF
      
      pdf("figures/figure2_left.pdf", family = "Times", width = 5.5, height = 5)

    # Plot PR curves

      plot(precision_recall_escalation_inc_civil_ns,lty = 1)
      plot(precision_recall_quad_inc_civil_ns,lty = 2,add=T)
      plot(precision_recall_goldstein_inc_civil_ns,lty = 3,add=T)
      plot(precision_recall_all_CAMEO_inc_civil_ns,lty = 4,add=T)
      plot(precision_recall_avg_inc_civil_ns,lty = 5,add=T)

    # Add legend
      
      legend("topright",
             c("Escalation", "Quad", "Goldstein", "CAMEO", "Average"),
             lty = c(1, 2, 3, 4, 5) 
              )

      dev.off()

