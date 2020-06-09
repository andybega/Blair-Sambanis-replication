#
#   Re-save the replication data as RDS; the .dta versions take very long to
#   read.
#

library(readstata13)
library(readr)
library(here)

setwd(here::here("table1-redo"))

dir.create("trafo-data", showWarnings = FALSE)

data_1mo <- read.dta13("input-data/1mo_data.dta")
write_rds(data_1mo, "trafo-data/1mo_data.rds")

data_6mo <- read.dta13("input-data/6mo_data.dta")
write_rds(data_6mo, "trafo-data/6mo_data.rds")
