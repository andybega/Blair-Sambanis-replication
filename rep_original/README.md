Original B&S replication code
=============


## Changes

Due to a bug with RStudio's job runner (`https://github.com/rstudio/rstudio/issues/4586`), we replaces all `source(...)` commands with `source(..., local = TRUE)`. 
