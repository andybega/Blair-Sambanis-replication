Original B&S replication code
=============

`_rep-check.R` is a script that compares the replication output to the Table 1 and 2 values reported in the paper. It writes the results to `extra/rep-check-tableX.csv`.

The table values this is compared against are in `extra/tableX-original.csv`. These are coded in `rep_nosmooth/make-original-tables.R` and I manually copied them over here. 

## Changes

Due to a bug with RStudio's job runner (`https://github.com/rstudio/rstudio/issues/4586`), we replaces all `source(...)` commands with `source(..., local = TRUE)`. 

We added code to save additional objects generated during the replication run to the `extra/` folder. These are to validate the re-factored replication code in `rep_nosmooth/`. 

**ROCR** version 1.0-9 (2020-03-26) added a check in `ROCR::prediction()` for NA's in the input predictions. This breaks the existing replication code. I added a wrapper that handles the NAs before calling ROCR, `port$prediction()`. It' can't be just `prediction()` because vectors of predictions get assigned to the same name, and thus conflict. 

The original commands to save data objects have the form `saveRDS(..., convert.factor = "string")`. The "convert.factor" option does not exist in more recent versions of R and we have removed it. 

The scripts that produce plot output use `quartz()`, which is not available on Windows. Both `quartz()` and the `plot.new()` commands are not needed to produce the PDF figures and we removed them. Also, the original plots use CM Romand and Times family fonts via the **extrafonts** package. Getting this to work requires additional installation steps. Since it does not otherwise affect the results, we remove the associated code as well.  



