#
#   Re-save the replication data as RDS, the .dta versions take very long to
#   read.
#

library(readstata13)
library(readr)
library(here)

setwd(here::here("tuning-experiments"))

data_1mo <- read.dta13("input-data/1mo_data.dta")

write_rds(data_1mo, "trafo-data/1mo_data.rds")
