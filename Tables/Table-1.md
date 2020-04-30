Replication of Figure 1 and Table 1
================

### Introduction\[1\]

One issue that stood out as we read through Blair and Sambanis’ (2020)
article was how smooth their Receiver Operating Characteristic curves
where in Figure 1 on page 14. A Receiver Operating Characteristic curve
displays the balance between the true positive rate and the false
positive rate, across a range of acceptance thresholds – the value in
which a zero to one probability is assumed to be an “onset” (here: civil
conflict). Given that the DV is civil conflict onset (1/0) and that this
is a rare event, these curves should resemble a step-like function.
Looking through the Blair/Sambanis replication code, we noticed that
they we using a rarely used in practice smoothing function when
producing their Receiver Operating Characteristic curves.

This is important because Blair and Sambanis use a common performance
metric – Area Under the Receiver Operating Characteristic Curves
(AUC-ROC) – as evidence that their escalation model out preforms all
others. However, by smoothing the Receiver Operating Characteristic
Curves, they are misrepresenting the true AUC-ROC scores of their
various models. Not only does this make model-to-model comparison
difficult, it also makes it impossible to assess whether any of their
models are performing better than random chance (a AUC-ROC score greater
than 0.5) or whether their AUC-ROC scores surpass the (soft) industry
standard that suggests that a model is performing well (an AUC-ROC score
greater than 0.8).

To assess whether their decision to implement a smoothing function on
the Receiver Operating Characteristic Curves for their various models
impacts their results (namely, that the escalation model is superior to
all others), we replicate Figure 1. However, rather than a two panel
figure (one ROC plot their one-month-ahead forecasts and one for their
six-months-ahead forecasts), we now include for panels (one panel for
the two forecast windows with the smoothed curve (as they produce) and
one panel for the two forecast windows that are not smoothed – the
industry standard).

Using these smoothed and non-smoothed curves, we then replicate Table 1
(page 13), which reports the AUC-ROC scores for these four different
Receiver Operating Characteristic Curves. If the non-smoothed AUC-ROC
scores are drastically different from those of the smoothed AUC-ROC
score (a difference of ≥ 0.05) or if the non-smoothed AUC-ROC scores are
\< 0.8, would suggest that their decision to smooth-out the curves was
improper. Further, if the the non-smoothed AUC-ROC score of the
Escalation model is smaller or the same as of the non-smoothed AUC-ROC
scores other models (Quad, Goldstein, and CAMEO) would suggests that the
evidence presented in the paper is not robust to standard AUC-ROC
calculation procedures.

Note: we are only reproducing the “Base specification” scores found in
Table 1, as these are the what Blair and Sambanis use to support their
calims. In order to ensure that this replication is a close as possible
to the authors’ original work, I will be using the replication code they
provided at
<https://journals.sagepub.com/doi/suppl/10.1177/0022002720918923>. There
is a lot going on in their code, so I will be commenting out all
elements that are not necessary for this replication process. Futher, I
will note any changes that I make this parsed code (i.e., removing the
smoothing function). The raw replication files can be found at
`GitHub/Blair-Sambanis-replication/Replication files/replication-3`,
while all my edited code can be found at
`GitHub/Blair-Sambanis-replication/Replication files/replication-3_BM`

1.  RM: As a way to maintain transparency and as a poor-mans version of
    preregistration, I’m pushing each stepto GitHub, where it will have
    a time-stamp and track all changes.