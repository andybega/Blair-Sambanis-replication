#
#  Copy/update the files in data/ that are used in paper.Rmd
#

library(here)

setwd(here::here("paper"))

files_needed <- c("../rep_nosmooth/output/tables/table1-nosmooth.csv",
                  "../rep_nosmooth/output/tables/table1-smooth.csv",
                  "../rep_nosmooth/output/tables/table1-smooth-benefit.csv",
                  "../rep_nosmooth/output/tables/table2-for-appendix.csv",
                  "../rep_nosmooth/output/tables/table2-nosmooth.csv",
                  "../rep_nosmooth/output/tables/table2-smooth-benefit.csv",
                  "../rep_nosmooth/output/tables/table2-smooth.csv",
                  "../rep_nosmooth/output/tables/table4-original.csv",
                  "../table4/output/table4-fixed.csv")

success <- file.copy(files_needed, "data", overwrite = TRUE)

if (any(success==FALSE)) {
  warning(sprintf("Could not find and copy file(s):\n%s",
                  paste0(files_needed[!success], collapse = "\n")))
}

file.copy("../rep_nosmooth/output/figures/figure1-replicated.png",
          "figures/", overwrite = TRUE)


