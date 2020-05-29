Modified replication
================

The code in this folder replicates the results in Tables 1 and 2 of
B\&S, but does so with both the smoothed ROC curve AUC values B\&S
report, and regular, non-smoothed ROC curve AUC.

In order to be able to run the models needed to create tables 1 and 2
more quickly than with the original replication code, the code here has
been refactored to enable running in parallel. Here is a summary of the
major changes:

  - `re-save-data.R` changes the format of the saved 1-month and 6-month
    data versions from Stata 13 .dta files to R .rds format. This can be
    read much quicker than the Stata format.
  - `setup-model-table.R` encodes all the various pieces of information
    needed to actually run the models reflected in tables 1 and 2. In
    the original replication files this is done in bits and pieces in
    `+master.R`, `code/[1|6]mo_define_models.R`, and each model runner
    file, e.g. `code/1mo_run_escalation.R`. The primary output are
    several files written to the `output/model-definitions` folder. More
    details on this below.
  - `model-runner.R` runs the models. Adjust the number of WORKERS at
    the top of the script as needed based on the number of cores on your
    computer. The primary output of this script is
    `output/model-table-w-results.csv`
  - `recreate-tables.R` recreates the original and non-smooth ROC
    versions of Tables 1 and 2.

### Model definitions

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
models that produce the \["Base specification", "Escalation"\] values in
Table 1, but it is easier to duplicate them since the underlying models
in any case estimate pretty quickly.)*

One of the principal outputs of `setup-model-definitions.R` is this
encoding, in `output/model-definitions/model-table.rds`:

``` r
model_table <- read_rds("output/model-definitions/model-table.rds")
head(model_table)
```

    ## # A tibble: 6 x 6
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

  - the DV to use (`dv-specs.yaml`), specifically either the regular one
    or one of the two alternate codings
  - the train/test split to use (`train-end-year.yaml`), one of 4
    possible values
  - the RF hyperparameter settings to use (`hp-settings.yaml`).

Together these bits define all that we need to run the correct random
forest models for these 78 cells.

The other 22 cells mostly involve averaging predictions produced by the
other models. For example, the “Average” column in Table 1 is for a
model that averages the predictions from the other four
models(/specifications). This doesn’t require running any model per se;
just averaging existing predictions. These are handled via special
treatment in `model-runner.R`, outside the main parallel loop.

## Table 1

### Original, smoothed ROC curves

| horizon  | Model                | Escalation | Quad | Goldstein | CAMEO | Average |
| :------- | :------------------- | ---------: | ---: | --------: | ----: | :------ |
| 1 month  | Base specification   |       0.86 | 0.80 |      0.78 |  0.83 | NA      |
| 1 month  | Terminal nodes       |       0.86 | 0.79 |      0.77 |  0.83 | NA      |
| 1 month  | Sample size          |       0.84 | 0.81 |      0.70 |  0.86 | NA      |
| 1 month  | Trees per forest     |       0.85 | 0.80 |      0.78 |  0.83 | NA      |
| 1 month  | Training/test sets 1 |       0.86 | 0.79 |      0.75 |  0.81 | NA      |
| 1 month  | Training/test sets 2 |       0.81 | 0.80 |      0.72 |  0.78 | NA      |
| 1 month  | Training/test sets 3 |       0.80 | 0.81 |      0.68 |  0.75 | NA      |
| 1 month  | Coding of DV 1       |       0.85 | 0.81 |      0.80 |  0.84 | NA      |
| 1 month  | Coding of DV 2       |       0.92 | 0.80 |      0.82 |  0.81 | NA      |
| 6 months | Base specification   |       0.82 | 0.77 |      0.82 |  0.77 | NA      |
| 6 months | Terminal nodes       |       0.80 | 0.76 |      0.81 |  0.77 | NA      |
| 6 months | Sample size          |       0.83 | 0.78 |      0.78 |  0.79 | NA      |
| 6 months | Trees per forest     |       0.82 | 0.78 |      0.82 |  0.77 | NA      |
| 6 months | Training/test sets 1 |       0.80 | 0.78 |      0.81 |  0.75 | NA      |
| 6 months | Training/test sets 2 |       0.72 | 0.74 |      0.76 |  0.73 | NA      |
| 6 months | Training/test sets 3 |       0.88 | 0.70 |      0.81 |  0.68 | NA      |
| 6 months | Coding of DV 1       |       0.83 | 0.76 |      0.82 |  0.79 | NA      |
| 6 months | Coding of DV 2       |       0.83 | 0.77 |      0.82 |  0.79 | NA      |

Alternative Table 1 with non-smoothed AUC-ROC

### With conventional ROC curves

| horizon  | Model                | Escalation | Quad | Goldstein | CAMEO | Average |
| :------- | :------------------- | ---------: | ---: | --------: | ----: | :------ |
| 1 month  | Base specification   |       0.79 | 0.78 |      0.79 |  0.80 | NA      |
| 1 month  | Terminal nodes       |       0.80 | 0.78 |      0.75 |  0.81 | NA      |
| 1 month  | Sample size          |       0.79 | 0.80 |      0.74 |  0.82 | NA      |
| 1 month  | Trees per forest     |       0.78 | 0.78 |      0.79 |  0.81 | NA      |
| 1 month  | Training/test sets 1 |       0.77 | 0.77 |      0.76 |  0.79 | NA      |
| 1 month  | Training/test sets 2 |       0.74 | 0.77 |      0.73 |  0.76 | NA      |
| 1 month  | Training/test sets 3 |       0.71 | 0.80 |      0.69 |  0.73 | NA      |
| 1 month  | Coding of DV 1       |       0.79 | 0.80 |      0.80 |  0.82 | NA      |
| 1 month  | Coding of DV 2       |       0.80 | 0.82 |      0.77 |  0.83 | NA      |
| 6 months | Base specification   |       0.77 | 0.79 |      0.83 |  0.78 | NA      |
| 6 months | Terminal nodes       |       0.77 | 0.78 |      0.82 |  0.78 | NA      |
| 6 months | Sample size          |       0.78 | 0.78 |      0.80 |  0.80 | NA      |
| 6 months | Trees per forest     |       0.77 | 0.79 |      0.83 |  0.78 | NA      |
| 6 months | Training/test sets 1 |       0.75 | 0.79 |      0.82 |  0.76 | NA      |
| 6 months | Training/test sets 2 |       0.70 | 0.75 |      0.78 |  0.74 | NA      |
| 6 months | Training/test sets 3 |       0.85 | 0.72 |      0.84 |  0.71 | NA      |
| 6 months | Coding of DV 1       |       0.78 | 0.79 |      0.83 |  0.80 | NA      |
| 6 months | Coding of DV 2       |       0.80 | 0.78 |      0.84 |  0.80 | NA      |

Alternative Table 1 with non-smoothed AUC-ROC
