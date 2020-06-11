Original materials
==================

Aside from the published paper and appendix, the documents starting with "20160308" are the materials that were pre-registered. Namely, a working paper, and a pre-analysis plan.

The pre-analysis plan contains a table with the 30 highest predictions for 2016-H1. It does not pre-register:

- the escalation model's specification
- the random forest tuning strategy

Ideally both the escalation model and RF hyperparameters were developed without an eye to the test set, as that would invalidate it as an independent, out-of-sample test set. For example, if the escalation model variable specification was informed by the model's test prediction performance, then it is possible that it overfits the test data.

Given that the data through 2016 were already available, even pre-registration would not have really assured that the model development and hyperparameter tuning were performed without information from a test set starting in 2007, in any case.

So we have assurance that the 2016-H1 forecasts were made prior to observation of outcomes. 
