
    # Save PDF

  		pdf("figures/figure1_right.pdf", width = 5.5, height = 5)

    # Plot ROC curves

      plot(roc_escalation_6mo_inc_civil_ns,
		    ylab = "True positive rate",
		    xlab = "False positive rate",
		    #col = c("brown"),
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

      dev.off()


