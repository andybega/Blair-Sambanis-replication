Tuning experiments
==================

The goal here basically was to come up with classification trees that could match the B&S regression tree + very aggressive sub-sampling approach. The experiments were done using the training set + repeated cross-validation to get OOS estimates that can be used for the HP tuning.

See `table1-redo` for a more condensed version of the results, which generally were that the B&S RF approach works very well (on the test set). There are tuned models that do better in training CV, but generally B&S does the best in test set AUC-ROC. Not sure if that reflects overfitting to the test set in the original B&S tuning.
