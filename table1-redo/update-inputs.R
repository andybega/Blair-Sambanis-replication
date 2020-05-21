#
#   Copy/update inputs from other folders
#

library(here)

setwd(here::here("table1-redo"))

file.copy("../tuning-experiments/output/hyperparameter-dictionary.rds",
          "input-data/",
          overwrite = TRUE)

