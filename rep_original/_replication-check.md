Replication verification
================

How much do the replication results differ from the values reported in
the B\&S paper?

The values in `table1-original.csv` and `table2-original.csv` are
hand-copied values from the paper tables. The paper tables include two
decimal digits. In this note, we compare the original Table 1 and 2
AUC-ROC values to the values we obtained from re-running the replication
code.

## Table 1

The table below shows the difference between B\&S Table 1 and our
re-creation. All values are 0, meaning that we match the paper results.

| row                  | horizon  | Escalation | Quad | Goldstein | CAMEO | Average |
| :------------------- | :------- | ---------: | ---: | --------: | ----: | ------: |
| Base specification   | 1 month  |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Terminal nodes       | 1 month  |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Sample size          | 1 month  |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Trees per forest     | 1 month  |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Training/test sets 1 | 1 month  |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Training/test sets 2 | 1 month  |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Training/test sets 3 | 1 month  |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Coding of DV 1       | 1 month  |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Coding of DV 2       | 1 month  |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Base specification   | 6 months |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Terminal nodes       | 6 months |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Sample size          | 6 months |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Trees per forest     | 6 months |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Training/test sets 1 | 6 months |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Training/test sets 2 | 6 months |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Training/test sets 3 | 6 months |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Coding of DV 1       | 6 months |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |
| Coding of DV 2       | 6 months |       0.00 | 0.00 |      0.00 |  0.00 |    0.00 |

## Table 2

Our reproduction values also match the B\&S paper values for Table 2.

| horizon  | Escalation Only | With PITF Predictors | Weighted by PITF | PITF Split Population | PITF Only |
| :------- | --------------: | -------------------: | ---------------: | --------------------: | --------: |
| 1 month  |            0.00 |                 0.00 |             0.00 |                  0.00 |      0.00 |
| 6 months |            0.00 |                 0.00 |             0.00 |                  0.00 |      0.00 |
