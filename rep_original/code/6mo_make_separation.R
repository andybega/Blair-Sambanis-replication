
    # Load modified separation plot function from "separationplot" package

      separationplot_alt <-
        function(pred, actual, type="line", line=T, lwd1=0.5, lwd2=1, heading="", xlab="", shuffle=T, width=8, height=2, col0="#FEF0D9", col1="#E34A33", flag=NULL, flagcol=1, file=NULL, newplot=T, locate=NULL, rectborder=NA, show.expected=F, zerosfirst=T, BW=F){

          if (is.vector(pred)==F) stop("The pred argument needs to be a vector")
          if (is.vector(actual)==F) stop("The actual argument needs to be a vector")
          if (length(pred)!=length(actual)) stop("The pred and actual vectors are of different lengths.")
          if (any(is.na(pred))) stop("Missing values in the pred vector.")
          if (any(is.na(actual))) stop("Missing values in the actual vector.")

          resultsmatrix<-data.frame(pred, actual, flags=0)
          rows<-nrow(resultsmatrix)

          if (!is.null(flag)) resultsmatrix$flags[flag]<-1

          if (shuffle==T){
            set.seed(1)
            resultsmatrix<-resultsmatrix[sample(1:rows,rows),]
          }

          resultsmatrix<-resultsmatrix[order(resultsmatrix$pred,resultsmatrix$actual),]
          resultsmatrix<-cbind(resultsmatrix, position=1:rows)

          if (type=="bands"){width<-6; height<-2}

          if (BW==T){col0="#FFFFFF"; col1="#636363"}

          if (newplot==T){
            if (is.null(file)) dev.new(width=width, height=height)
            if (!is.null(file)) pdf(file=file, width=width, height=height)
            par(mgp=c(3,0,0), lend=2, mar=c(3,2,2,2))
          }

          if (type!="bands"){
            plot(1:nrow(resultsmatrix),1:nrow(resultsmatrix), xlim=c(0.5, nrow(resultsmatrix)+0.5), ylim=c(0,0.15),  type="n", bty="n", yaxt="n", xaxt="n", xlab=xlab, ylab="") #RB: Change ylim to alter y-axis
            title(main=heading)
          }

          resultsmatrix$color<-NA
          resultsmatrix$color[resultsmatrix$actual==1]<-col1
          resultsmatrix$color[resultsmatrix$actual==0]<-col0

          events<-resultsmatrix[resultsmatrix$actual==1,]
          nonevents<-resultsmatrix[resultsmatrix$actual==0,]

          if (type=="line" & zerosfirst==T){
            if (nrow(nonevents)>0) segments(x0=nonevents$position, x1=nonevents$position, y0=0, y1=1, col=col0, lwd=lwd1)
            if (nrow(events)>0) segments(x0=events$position, x1=events$position, y0=0, y1=1, col=col1, lwd=lwd1)
            if (!is.null(flag)) segments(x0=resultsmatrix$position[resultsmatrix$flags==1], x1=resultsmatrix$position[resultsmatrix$flags==1], y0=0, y1=1, col=flagcol, lwd=lwd1)
          }

          if (type=="line" & zerosfirst==F){
            if (nrow(events)>0) segments(x0=events$position, x1=events$position, y0=0, y1=1, col=col1, lwd=lwd1)
            if (nrow(nonevents)>0) segments(x0=nonevents$position, x1=nonevents$position, y0=0, y1=1, col=col0, lwd=lwd1)

            if (!is.null(flag)) segments(x0=resultsmatrix$position[resultsmatrix$flags==1], x1=resultsmatrix$position[resultsmatrix$flags==1], y0=0, y1=1, col=flagcol, lwd=lwd1)
          }

          if (type=="rect") {

            rect(xleft=resultsmatrix$position-0.5, ybottom=0, xright=resultsmatrix$position+0.5, ytop=1, col=resultsmatrix$color, border=rectborder)
            if (!is.null(flag)) rect(xleft=resultsmatrix$position[resultsmatrix$flags==1]-0.5, xright=resultsmatrix$position[resultsmatrix$flags==1]+0.5, ybottom=0, ytop=1, col=flagcol,  border=rectborder)

          }

            expectedevents<-round(sum(resultsmatrix$pred))

          if (show.expected) points(nrow(resultsmatrix)-expectedevents+0.5, -0.1, pch=24, bg=1, cex=0.7)

          newcutpoint<-sort(resultsmatrix$pred, decreasing=T)[expectedevents]

          tp<-length(resultsmatrix$actual[resultsmatrix$pred>=newcutpoint & resultsmatrix$actual==1])
          fp<-length(resultsmatrix$actual[resultsmatrix$pred>=newcutpoint & resultsmatrix$actual==0])
          tn<-length(resultsmatrix$actual[resultsmatrix$pred<newcutpoint & resultsmatrix$actual==0])
          fn<-length(resultsmatrix$actual[resultsmatrix$pred<newcutpoint & resultsmatrix$actual==1])

          pcp<-(tp+tn)/length(resultsmatrix$actual)

          if (type=="localaverage"){

            if (nrow(resultsmatrix)>5000) cat("\nCalculating the moving averages.  This may take a few moments due to the large number of observations.\n")

            windowsize<-round(nrow(resultsmatrix)*0.01)
            resultsmatrix$localaverage<-NA
            for (i in 1:nrow(resultsmatrix)){
              lower<-max(c(1, i-windowsize))
              upper<-min(c(nrow(resultsmatrix), i+windowsize))
              resultsmatrix$localaverage[i]<-mean(resultsmatrix$actual[lower:upper])

            }

            lines(1:rows, resultsmatrix$localaverage, lwd=lwd1, col=col1)

          }

            if (line==T & type!="bands")
            lines(1:rows, resultsmatrix$pred, lwd=lwd2)

            if (type=="bands"){

            breaks<-seq(0,0.9,0.1)
            cols<-RColorBrewer::brewer.pal(9,"Reds")
            a<-colorRampPalette(cols)
            cols<-a(10)

            phat.events<-events[,1]
            phat.nonevents<-nonevents[,1]

            par(mgp=c(3,0,0), lend=2, mar=c(2.5,2,2.5,2))

            layout(matrix(c(1,2,1,2,1,2,1,2,3,3), nrow=2, ncol=5))

            plot(1:length(phat.events),1:length(phat.events), xlim=c(0.5, length(phat.events)+0.5), ylim=c(0,1),  type="n", bty="n", yaxt="n", xaxt="n", xlab=xlab, ylab="")

            title(main=paste("y=1 (n=", length(phat.events), ")", sep=""))
            segments(x0=1:length(phat.events), x1=1:length(phat.events), y0=0, y1=1, col=cols[findInterval(phat.events,breaks)])

            plot(1:length(phat.nonevents),1:length(phat.nonevents), xlim=c(0.5, length(phat.nonevents)+0.5), ylim=c(0,1),  type="n", bty="n", yaxt="n", xaxt="n", xlab=xlab, ylab="")
            title(main=paste("y=0 (n=", length(phat.nonevents), ")", sep=""))
            segments(x0=1:length(phat.nonevents), x1=1:length(phat.nonevents), y0=0, y1=1, col=cols[findInterval(phat.nonevents,breaks)])

            plot.new()
            par(mar=c(1,1,1,1))
            legend("center", legend=c("over 0.9", "0.8 - 0.9", "0.7 - 0.8", "0.6 - 0.7", "0.5 - 0.6", "0.4 - 0.5", "0.3 - 0.4", "0.2 - 0.3", "0.1 - 0.2", "under 0.1"), fill=rev(cols), title="Probabilities:", cex=1.25, bty="n")

          }

          if (!is.null(file)) dev.off()

          if (!is.null(locate)) {
            a<-locator(n=locate)
            resultsmatrix[round(a$x),]

          invisible(resultsmatrix)
          }
        }


  # Drop missing values

    test_DV_civil_ns_escalation_6mo <-test_DV_civil_ns
      test_DV_civil_ns_escalation_6mo[is.na(prediction_escalation_6mo_inc_civil_ns)] <- NA
      test_DV_civil_ns_escalation_6mo <- as.vector(na.omit(test_DV_civil_ns_escalation_6mo))

    test_DV_civil_ns_quad_6mo <-test_DV_civil_ns
      test_DV_civil_ns_quad_6mo[is.na(prediction_quad_6mo_inc_civil_ns)] <- NA
      test_DV_civil_ns_quad_6mo <- as.vector(na.omit(test_DV_civil_ns_quad_6mo))

    test_DV_civil_ns_goldstein_6mo <-test_DV_civil_ns
      test_DV_civil_ns_goldstein_6mo[is.na(prediction_goldstein_6mo_inc_civil_ns)] <- NA
      test_DV_civil_ns_goldstein_6mo <- as.vector(na.omit(test_DV_civil_ns_goldstein_6mo))

    test_DV_civil_ns_all_CAMEO_6mo <-test_DV_civil_ns
      test_DV_civil_ns_all_CAMEO_6mo[is.na(prediction_all_CAMEO_6mo_inc_civil_ns)] <- NA
      test_DV_civil_ns_all_CAMEO_6mo <- as.vector(na.omit(test_DV_civil_ns_all_CAMEO_6mo))

    test_DV_civil_ns_avg_6mo <-test_DV_civil_ns
      test_DV_civil_ns_avg_6mo[is.na(prediction_avg_6mo_inc_civil_ns)] <- NA
      test_DV_civil_ns_avg_6mo <- as.vector(na.omit(test_DV_civil_ns_avg_6mo))

    prediction_escalation_6mo_inc_civil_ns <- as.vector(na.omit(prediction_escalation_6mo_inc_civil_ns))

    prediction_quad_6mo_inc_civil_ns <- as.vector(na.omit(prediction_quad_6mo_inc_civil_ns))

    prediction_goldstein_6mo_inc_civil_ns <- as.vector(na.omit(prediction_goldstein_6mo_inc_civil_ns))

    prediction_all_CAMEO_6mo_inc_civil_ns <- as.vector(na.omit(prediction_all_CAMEO_6mo_inc_civil_ns))

    prediction_avg_6mo_inc_civil_ns <- as.vector(na.omit(prediction_avg_6mo_inc_civil_ns))



  # Generate separation plots

      separationplot_alt(pred=prediction_escalation_6mo_inc_civil_ns, actual=test_DV_civil_ns_escalation_6mo, type="line",
                         line=TRUE, show.expected=FALSE, xlab = "", heading="Escalation", shuffle = F, BW=T, file="figures/figure4_a.pdf")

      separationplot_alt(pred=prediction_quad_6mo_inc_civil_ns, actual=test_DV_civil_ns_quad_6mo, type="line",
                         line=TRUE, show.expected=FALSE, xlab = "", heading="Quad", shuffle = F, BW=T, file="figures/figure4_b.pdf")

      separationplot_alt(pred=prediction_goldstein_6mo_inc_civil_ns, actual=test_DV_civil_ns_goldstein_6mo, type="line",
                         line=TRUE, show.expected=FALSE, xlab = "", heading="Goldstein", shuffle = F, BW=T, file="figures/figure4_c.pdf")

      separationplot_alt(pred=prediction_all_CAMEO_6mo_inc_civil_ns, actual=test_DV_civil_ns_all_CAMEO_6mo, type="line",
                         line=TRUE, show.expected=FALSE, xlab = "", heading="CAMEO", shuffle = F, BW=T, file="figures/figure4_d.pdf")

      separationplot_alt(pred=prediction_avg_6mo_inc_civil_ns, actual=test_DV_civil_ns_avg_6mo, type="line",
                         line=TRUE, show.expected=FALSE, xlab = "", heading="Average", shuffle = F, BW=T, file="figures/figure4_e.pdf")



