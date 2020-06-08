#
#   Copy over/update the inputs needed for things here
#

setwd(here::here("table4"))

file.copy("../rep_original/predictions/6mo_predictions_escalation_OOS.dta",
          "data", overwrite = TRUE)

file.copy("../rep_original/data/6mo_data_OOS.dta",
          "data", overwrite = TRUE)
