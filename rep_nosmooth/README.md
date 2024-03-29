Re-analysis of B&S with both smoothed and empirical AUC-ROC
================

The easiest way to reproduce our re-analysis is to run `master.R`, which
will run the other scripts in correct order.

-   Adjust the number of parallel workers in `2-model-runner.R`
-   Go through `master.R`.

If you want to run without `master.R`, the numbers in the other R
scripts indicate dependence. For example, the script starting with “3-”
for requires all “1-” and “2-” scripts to have been run.

Our re-analysis is based on the original B&S replication materials. The
main substantive changes are:

-   We evaluate AUC values from both the original smoothed ROC curves
    but also standard empirical ROC curves.
-   Two of the structural model implementations have been changed.

While the substantive changes are minor, we have changed the structure
of the code substantially so that the random forest models can be run in
parallel.

We intentionally do not set a RNG seed, since the substantive
conclusions of our re-analysis should not depend on particular RNG seed
values. There is some slight variation between re-runs of the models as
a result. There is a provision in the model runner for setting RNG
seeds, but the downstream scripts won’t work with the resulting file
names without some manual adjustment.

*Note (July 2022): The latest version of randomForest on CRAN leads to a
memory issue when trying to the part of the replication code that trains
all of the models. Memory usage increases until the process errors out
or system crashes. Thus the old randomForest 4.6-14 is required for
replication (this is also the version we used when originally conducting
the replication). The package setup script will check for this, and
issue guidance as needed. Thanks to Christian Oswald for raising this
issue.*

------------------------------------------------------------------------

## Overview

The code in this folder replicates the results in Tables 1 and 2 of B&S,
but does so with both the smoothed ROC curve AUC values B&S report, and
regular, non-smoothed ROC curve AUC.

In order to be able to run the models needed to create tables 1 and 2
more quickly than with the original replication code, the code here has
been re-factored to enable running in parallel. The structure of the
code has completely changed. Instead of a master script that handles
file IO and sources other scripts to setup model definition objects
(features, training/test data frames, etc.) and run models, the new
logic is to:

1.  Create a central model table that encodes all cells in B&S Tables 1
    and 2 and the information needed to define the underlying models, as
    well as associated model definitions like features, hyper-parameter
    settings, etc. (`output/model-definitions/`).
2.  Run through the model table (mostly in parallel) to estimate all
    models; save the resulting predictions.
3.  Re-create output tables and figures.

## Reproducing our replication

Below are instructions for how to manually run the scripts in order to
replicate the updated analysis. To do a clean replication, delete the
`output/` folder; this is not required though.

The file numbering indicates the order in which files should be run, and
roughly correspond to the steps above. Files with the same number can be
run in any order, as long as lower number files have already been run.

Setup:

-   `0-packages.R` makes sure all required R packages are installed.

Preparing data for model estimation:

-   `1-re-save-data.R` changes the format of the saved 1-month and
    6-month data versions from Stata 13 .dta files to R .rds format.
    This can be read much quicker than the Stata format.
-   `1-make-original-tables.R` is a by-hand coding of the values
    reported for Tables 1, 2, and 4 in B&S 2020.
-   `1-setup-model-table.R` encodes all the various pieces of
    information needed to actually run the models reflected in tables 1
    and 2. In the original replication files this is done in bits and
    pieces in `+master.R`, `code/[1|6]mo_define_models.R`, and each
    model runner file, e.g. `code/1mo_run_escalation.R`. The primary
    output are several files written to the `output/model-definitions`
    folder. More details on this below.

Estimate all models (this is where the heavy lifting takes places):

-   `2-model-runner.R` runs the models. Adjust the number of WORKERS at
    the top of the script as needed based on the number of cores on your
    computer. The primary output of this script is
    `output/model-table-w-results.csv` and `output/all-predictions.R`.

Recreate AUC-ROC tables:

-   `3-recreate-tables.R` produces various tables summarizing the
    performance of the core event data models (B&S Table 1) and the
    structural models (B&S Table 2); some of these are used as inputs to
    generate figures below.

Generate figures:

-   `4-...`: the various scripts starting with “4-” recreate the various
    figures that end up in the paper.

The processed results created in the above two sets of scripts (“3-…”
and “4-…”) are written to the `rep_nosmooth/output` folder here. The
`paper/` folder includes a `update-inputs.R` script that will copy
needed pieces over to that folder.

In addition, there are some ancillary materials that are not required
for replicating the results in the paper, but add additional
information. These are easiest to read in GitHub.

-   [replication-check.md](replication-check.md) compares the AUC-ROC
    results we obtain when using smoothed ROC curves to the original B&S
    results (hand-copied from the paper). When taking into account the
    implementation fixes we made for two models, and RNG seed variation,
    we are able to replicate the original results/patterns.
-   [variance.md](variance.md) examines how much the AUC-ROC results
    vary when you don’t set an RNG seed. For the base specification
    escalation model, the variance is significantly below 0.01, and
    small changes in the Table 1 and 2 replications mainly occur when
    the distribution straddles a threshold used for rounding,
    e.g. 0.825.
-   `rep-check.R` compares the results of our modified replication to
    the original values reported in Tables 1 and 2 of the B&S paper.

## Variation due to random number generator seed

We consciously chose not do set a random number generator (RNG) seed in
the model estimation script (`2-model-runner.R`), because the
substantive results should not change as a result of the small amount of
variation related to RNG state. The [variance.md](variance.md) note
explores this to some extent and leads us to believe that this is the
case, with variation for the Table 1 models generally less than 0.01
AUC-ROC.

Anyways, the model runner script does include a provision for setting a
RNG seed, in which case the key output files will be suffixed with the
RNG seed value. Note that the results processing scripts are not setup
to work this these output files. Instead of adjusting file names in the
downstream scripts, the easiest way to get this working again is to copy
the output + RNG seed files and rename them by dropping the RNG seed
suffix.

## Model definitions

The original replication code has a large number of scripts that define
the various models/methods to run. In order to allow running the RF
models in parallel, this refactored code sets up a table and other lists
that define all the information needed to run the various models, and
then runs through the table (in parallel) to run each model.

The various models going into tables 1 and 2 vary over several
dimensions. We started untangling this by first encoding every AUC-ROC
value/cell in Tables 1 and 2. These can be uniquely identified by the
forecast horizon (1 or 6-months), and then the table row and columns.
There are a total of 100 AUC-ROC values reported, 90 in Table 1, and 10
in Table 2.

*(The “Escalation only” values in Table 2 actuall correspond to the
models that produce the

!["Base specification", "Escalation"](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;%22Base%20specification%22%2C%20%22Escalation%22 ""Base specification", "Escalation"")

values in Table 1, but it is easier to duplicate them since the
underlying models in any case estimate pretty quickly.)*

One of the principal outputs of `1-setup-model-definitions.R` is this
encoding, in `output/model-definitions/model-table.rds`:

``` r
model_table <- read_rds("output/model-definitions/model-table.rds")
head(model_table)
```

    ## # A tibble: 6 × 6
    ##   cell_id table   horizon row                column     non_RF
    ##     <int> <chr>   <fct>   <fct>              <fct>      <lgl> 
    ## 1       1 Table 1 1 month Base specification Escalation FALSE 
    ## 2       2 Table 1 1 month Base specification Quad       FALSE 
    ## 3       3 Table 1 1 month Base specification Goldstein  FALSE 
    ## 4       4 Table 1 1 month Base specification CAMEO      FALSE 
    ## 5       5 Table 1 1 month Base specification Average    TRUE  
    ## 6       6 Table 1 1 month Terminal nodes     Escalation FALSE

The majority of cells correspond to underlying random forest (RF)
models–78 of 100 entries. For these RF cells, the table columns
correspond to the feature specification going into the model as
predictors. This mapping is encoded in
`output/model-definitions/feature-specs.json`.

Forecasting horizon aside, the rows encode three dimensions of info:

-   the DV to use (`dv-specs.yaml`), specifically either the regular one
    or one of the two alternate codings
-   the train/test split to use (`train-end-year.yaml`), one of 4
    possible values
-   the RF hyperparameter settings to use (`hp-settings.yaml`).

Together these bits define all that we need to run the correct random
forest models for these 78 cells.

The other 22 cells mostly involve averaging predictions produced by the
other models. For example, the “Average” column in Table 1 is for a
model that averages the predictions from the other four
models(/specifications). This doesn’t require running any model per se;
just averaging existing predictions. These are handled via special
treatment in `model-runner.R`, outside the main parallel loop.
