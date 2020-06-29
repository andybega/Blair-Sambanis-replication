Replication verification
================

How much do our replication results differ from the values reported in
the B\&S paper? This note compares the B\&S Table 1 and 2 AUC-ROC values
we obtain from our modified replication, when using smoothed ROC curves
(not the standard empirical ROC curves) to calculate AUC, as B\&S do.

Our replication relies on completely rewritten code that differs
substantially from B\&S’ original replication code, and thus we want to
verify that the results are not spuriously different because our
replication code is different. (The reason for rewriting the code was to
allow for running the replication in parallel, which reduces the time
needed to run it.)

There are a couple of known deviations:

  - RNG seed variation: the original B\&S code sets a RNG seed value and
    then proceeds sequentially through the dozens of random forest
    models reflected in the paper. Even if we were to set the same RNG
    seed value, our code runs models in parallel and thus the RNG state
    for any given model will be different than it is for a given model
    in the sequence of models B\&S’ code runs. In experiments (see
    [variance.md](variance.md)) we find that this generally produces on
    the order of 0.01 differences in AUC-ROC values, but sometimes more.
  - We fixed the implementations of the “Weighted by PITF” and “PITF
    Split Population” models in Table 2, which probably accounts for the
    more dramatic AUC-ROC differences there.

Overall, it doesn’t look to us like there are any glaring deviations
from the original B\&S results.

## B\&S Table 1

| horizon  | row                  | Escalation |   Quad | Goldstein |  CAMEO | Average |
| :------- | :------------------- | ---------: | -----: | --------: | -----: | ------: |
| 1 month  | Base specification   |       0.00 |   0.00 |      0.00 |   0.02 |    0.01 |
| 1 month  | Terminal nodes       |       0.01 | \-0.01 |    \-0.01 |   0.00 |    0.00 |
| 1 month  | Sample size          |       0.00 |   0.00 |      0.00 |   0.00 |    0.00 |
| 1 month  | Trees per forest     |       0.00 |   0.00 |      0.00 |   0.00 |    0.00 |
| 1 month  | Training/test sets 1 |       0.00 |   0.00 |      0.00 |   0.00 |    0.00 |
| 1 month  | Training/test sets 2 |       0.01 |   0.00 |    \-0.01 |   0.00 |    0.00 |
| 1 month  | Training/test sets 3 |       0.01 | \-0.01 |      0.00 | \-0.01 |  \-0.01 |
| 1 month  | Coding of DV 1       |       0.00 |   0.00 |      0.01 |   0.00 |    0.00 |
| 1 month  | Coding of DV 2       |       0.00 |   0.00 |      0.00 |   0.00 |    0.00 |
| 6 months | Base specification   |       0.00 |   0.00 |      0.00 |   0.01 |    0.00 |
| 6 months | Terminal nodes       |     \-0.01 |   0.00 |      0.00 |   0.01 |  \-0.01 |
| 6 months | Sample size          |       0.00 |   0.00 |      0.00 |   0.00 |    0.00 |
| 6 months | Trees per forest     |       0.00 | \-0.01 |      0.00 |   0.00 |    0.00 |
| 6 months | Training/test sets 1 |       0.01 |   0.00 |      0.00 |   0.00 |    0.00 |
| 6 months | Training/test sets 2 |     \-0.01 |   0.01 |      0.01 |   0.00 |    0.00 |
| 6 months | Training/test sets 3 |       0.00 |   0.00 |      0.00 |   0.00 |    0.00 |
| 6 months | Coding of DV 1       |       0.00 | \-0.01 |      0.00 |   0.01 |    0.00 |
| 6 months | Coding of DV 2       |       0.00 |   0.00 |      0.00 |   0.00 |    0.00 |

## B\&S Table 2

| horizon  | row                | Escalation Only | With PITF Predictors | Weighted by PITF | PITF Split Population | PITF Only |
| :------- | :----------------- | --------------: | -------------------: | ---------------: | --------------------: | --------: |
| 1 month  | Base specification |               0 |               \-0.01 |             0.27 |                \-0.03 |         0 |
| 6 months | Base specification |               0 |               \-0.01 |             0.29 |                \-0.05 |         0 |
