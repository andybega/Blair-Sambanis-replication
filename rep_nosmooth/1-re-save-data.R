#
#   Re-save the replication data as RDS; the .dta versions take very long to
#   read.
#

library(readstata13)
library(readr)
library(here)

dir.create(here("rep_nosmooth/trafo-data"), showWarnings = FALSE)

data_1mo <- read.dta13(here("rep_nosmooth/data/1mo_data.dta"))
write_rds(data_1mo, here("rep_nosmooth/trafo-data/1mo_data.rds"))

data_6mo <- read.dta13(here("rep_nosmooth/data/6mo_data.dta"))
write_rds(data_6mo, here("rep_nosmooth/trafo-data/6mo_data.rds"))
