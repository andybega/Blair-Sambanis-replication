Replicating Blair and Sambanis: Forecasting Civil Wars - JCR 2020
================

### Introduction

While reading Blair and Sambanis (2020), a few issues stuck out. We
downloaded the replication files authors provide from
<https://journals.sagepub.com/doi/suppl/10.1177/0022002720918923/suppl_file/sj-zip-1-jcr-10.1177_0022002720918923.zip>.
The original folder name of is
`sj-zip-1-jcr-10.1177_0022002720918923/replication-3`. For simplicity,
we extracted this `replication-3` and saved to the `Replication Files`
folder of this repo.

Before listing the primary issues we identified, we should note that we
are partial to their approach. Theory is important. It is helpful for
forecasting problems, especially with regards to identifying which
variables to include in a model. This is particularly true when the goal
is to assess how …

This document lists the primary issues we identified.

1.  Improperly tuning of models

<!-- end list -->

  - RM: In a twitter DM, I asked Blair to clarify – “\[I\] was wondering
    how you all came to your tuning procedure for the RF model
    hyper-parameters?” He responded “mostly trial and error, honestly. …
    Trial and error was on early data. Forecasts were for much later
    data”

<!-- end list -->

2.  Using a regression framework in a classification problem
3.  Their train/validate/test approach
4.  Rounding of AUC/ROC scores
5.  Lack of yearly test forecasts in favor of a single 5-year test
    forecast
6.  Table 4\!
      - There are only 20 onsets from 2001 to 2015 But there are 15
        “Persistence” cases (top of table 4) and 16 “Change” cases
        (bottom of table 4)
      - Why only top 30?
7.  Treating the output of a RF regression model as Pr() – (RM: I guess
    this is akin to a Linear Probability Model, but I’m not sure if this
    is possible in a RF framework
8.  The lack of procedures to account for rare events in an RF model
9.
