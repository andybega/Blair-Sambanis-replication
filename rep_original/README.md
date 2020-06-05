Original B&S replication code
=============

## Changes

Due to a bug with RStudio's job runner (`https://github.com/rstudio/rstudio/issues/4586`), we replaces all `source(...)` commands with `source(..., local = TRUE)`. 

We added code to save additional objects generated during the replication run to the `extra/` folder. These are to validate the re-factored replication code in `rep_nosmooth/`. 

**ROCR** version 1.0-9 (2020-03-26) added a check in `ROCR::prediction()` for NA's in the input predictions. This breaks the existing replication code. I added a wrapper that handles the NAs before calling ROCR, `port$prediction()`. It' can't be just `prediction()` because vectors of predictions get assigned to the same name, and thus conflict. 


