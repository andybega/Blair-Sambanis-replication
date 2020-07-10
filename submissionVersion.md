---
title: "Comments on Blair and Sambanis, 2020, \"Forecasting Civil Wars: Theory and Structure in an Age of 'Big Data' and Machine Learning\", *JCR*"
author: 
# - Andreas Beger^[Predictive Heuristics, adbeger@gmail.com.]
# - Richard K. Morgan^[Varieties of Democracy Institute, University of Gothenburg, rick.morgan2@gmail.com.]
# - Michael D. Ward^[Predictive Heuristics, Duke University, University of Washington, michael.don.ward@gmail.com. Corresponding author.]
 - Anne Author
date: "10 July 2020"
# thanks: John Ahlquist, Cassy L. Dorff, and Shahryar Minhas both provided helpful feedback on this project. All the code and several additional analyses can be found at our replication archive at https://github.com/andybega/Blair-Sambanis-replication.
abstract: We examine the research protocols in Blair and Sambanis (2020).  We find that there are several important mistakes and research decisions that determine their results. Fixing these mistakes results in a reversal of their claim that theory based models of escalation are better at predicting onsets of civil war than other kinds of models.  While their model is not very theoretical, it is outperformed by several of the ad hoc, putatively non-theoretical models they devise and examine.  
output: 
  bookdown::pdf_document2:
    keep_tex: true
    keep_md: true
    toc: false
header-includes:
  - \usepackage{setspace}\doublespacing
bibliography: "./references.bib"
nocite: |
  @cederman:weidmann:2017
---


# Introduction

Blair and Sambanis [-@blair:sambanis:2020, hereafter B\&S] argue that theory is essential for creating models that have high accuracy in forecasting civil war onset. Indeed they assert that with such theory forecasting is more accurate than has previously been possible. Setting aside the validity of this argument, we re-examine the empirical basis for the claims made in their article. We find that these claims are false. Their theory-based escalation model does not do better than the alternatives that they examine. Actually, it does worse. The reason for this reversal of their conclusion is that they have made several mistakes in their research procedure. The performance results they report are based on smoothed performance curves, not the original unsmoothed curves. Further, two of the structural alternatives to their basic escalation model were incorrectly implemented. We also found that the scoring of their forecasts for the first half of 2016 were incorrectly performed using civil war incidence, not onset. In what follows, we show the impact of these mistakes on the conclusions. 

B\&S claim (page 3) to show that a model informed by procedural theories of escalation and de-escalation can predict the onset of civil wars "remarkably accurately". Indeed, B&S argue that this so-called theoretical model outperforms four other "more mechanical" alternatives. Second, they claim that the integration of structure with process is better over short forecasting windows. Third, they preregistered the list of thirty countries that have the highest risk of civil war onset. They claim that such prospective predictions are rare in the literature when, in fact, they have been routine for many years with several prominent projects. B\&S claim to be unique in assessing these forecasts. A qualitative analysis of their predictions allows them to conclude that their model is robust. We will return to their analysis later, after correcting the procedural mistakes we found in their research process.

Before proceeding, we quote B&S (page 24):

> Our theoretically driven model generates accurate forecasts, with base specification AUCs of 0.82 and 0.85 over one- and six-month windows, respectively, and AUCs as high as 0.92 in other specifications. Our model also consistently and sometimes dramatically outperforms the alternatives we test. [...]  Cederman and Weidmann (2017, 476) argue that "the hope that big data will somehow yield valid forecasts through theory-free 'brute force' is misplaced in the area of political violence." Our results lend some credence to this claim.

# Summary of Blair and Sambanis (2020)

B&S' analysis is based on the use of non-linear, non-deterministic machine learning models, and specifically random forests, one of which has a specification they argues is theory-based, and several others with more generic sets of covariates. Notably, the analysis is at the country-month or country-(6 month) levels and relies in large part on indicators derived from the ICEWS event data. For the moment, we set aside a) the logic of this hypothesis and b) whether their model has more theory than is typically found in empirical conflict models. In short, they uphold their assumption that theory-guided empirical research produces better conflict predictions than machine learning inspired efforts that are necessarily ad hoc combinations of available variables. They arrive at this conclusion by examining the problem of predicting civil war onset. They report that a parsimonious model using a small number of covariates derived from escalation theories of conflict can forecast civil war onset better than alternative specifications based on generic covariates not specifically informed by theory, including a \textit{kitchen sink} model with more than 1,000 covariates.

B&S specifically examine three questions: 

1. How does the theoretically-driven escalation model compare in forecast performance to alternative models not informed specifically by civil war onset theories?
2. Does annual, structural information from the PITF instability forecasting model add to the escalation model's monthly and 6-month predictions?
3. How accurate were predictions using the escalation model for the first half of 2016?

To assess the first two questions, B&S use ICEWS data covering all major countries from 2001 to 2015. Two versions of the dataset are used, one at the country-month level, the other aggregated to 6-month half-years. The main outcome variable is civil war onset, measured using Sambanis' civil war dataset. 

Both the first and second questions above rely on comparing their escalation model to various alternative models. The same procedure is used in both cases:

1. Split the training data into training (2001 - 2007) and test (2008 - 2015) sets.
2. Estimate the escalation and other competing models. 
3. Create out-of-sample (OOS) predictions from each model using the test set. 
4. Calculate AUC-ROC measures for each set of OOS predictions.

To examine the first question, B&S compare the test set of the escalation model to four alternative models. The independent variables for the first set of analysis reported in Table 1 in the paper are all derived from the ICEWS event data, using domestic events between actors within a country. The models are:

- Escalation: a set of ten indicators, putatively drawn from a theoretical escalation model, for interactions between the government on one side and opposition or rebel actors on the other. 
- Quad: ICEWS quad counts, i.e. material conflict, material cooperation, verbal conflict, verbal cooperation, for interactions between the government and opposition or rebels. These are directed, thus making for four directed dyads, which with four quad categories make sixteen covariates. 
- Goldstein: -10 (conflictual) to 10 (cooperative) scores derived from the ICEWS data for the same four directed dyads, for a total of four covariates. 
- CAMEO: counts for all CAMEO event codes over the four actor dyads, totaling $1,160$ covariates, which are mostly zero for any country in any month. 
- Average: unweighted average of the predictions from the four models briefly described above.

The corresponding results for each question are shown in B&S Tables 1 and 2, which we examine further below. We accurately replicate their Tables 1 and 2, with very tiny differences. The results in Table 1, aside from the core base specification results, include eight additional robustness tests for both the 1-month and 6-month versions. These robustness checks vary either (1) random forecast hyperparameter values or (2) the year used to split the train/test data, or (3) alternative codings of the civil war onset dependent variable. 

The second question, whether structural variables add to the escalation model, is assessed by comparing the original escalation model to four alternatives that incorporate annual, structural variables that are used in the PITF instability forecasting model:

- Escalation Only: the original basic escalation model with only ICEWS predictors.
- With PITF Predictors: a random forest that also adds the PITF annual, structural variables.
- Weighted by PITF: escalation model predictions weighted using the PITF instability model predictions.
- PITF Split Population: the training data are split into high and low risk portions based on the PITF instability model predictions, two separate escalation random forests are trained on the splits, then re-combined into a single random forest that is used to create the test set predictions.
- PITF Only: a random forest model based only on the annual, structural PITF model predictors.

The corresponding results are shown in B&S Table 2. 

Finally, B&S used their escalation model to create forecasts for the first half of 2016, and in their third and final analysis, they score the forecasts accuracy using civil war onset data later observed. This is summarized in B&S Table 3. 

# Implementation Issues in B&S

While replicating and analyzing B&S's results, we found several issues worthy of further discussion and investigation. These are a) the use of smoothed ROC curves to draw conclusions about which model is best, b) incorrect implementations of the weighted by PITF and PITF analog split-population models, c) inconsistent test sets for the models examined, and d) incorrect scoring of the 2016 forecasts.^[We also note there are additional concerns arising from the question of how the random forest models were tuned by B&S, especially given the way they are used is unorthodox. We did not further investigate the latter issue as it is rendered somewhat moot by the changes in results after addressing the preceding issues.]

We believe that these research decisions and issues lead B\&S to incorrect conclusions. The escalation model is not the best, and it actually performs worse than the atheoretical, garbage can model with over \(1000\) variables. We discuss these five issues below. We defer a complete analysis that corrects all these issues until later, as there are many possible permutations of a seriatim unfolding.

## Smoothed ROC Curves

The most consequential issue that we found is that all AUC-ROC values reported in B&S Tables 1 and 2 are calculated using smoothed ROC curves, not the original, empirical ROC curves. The data in rare events problems like this one restrict the number of true positive rate values and lead to non-continuous ROC curves; B&S refer to smoothing in the context of their Figure 1 with ROC curves as easing interpretation. But in fact smoothing is used to produce all AUC-ROC values they report. Standard practice in conflict research and forecasting has been to use empirical, not smoothed ROC curves, both for visualization and when calculating AUCs. 

The next three issues we encountered all concern information in B&S Table 2. 

## Incorrect "Weighted by PITF" Implementation

The "Weighted by PITF" model is described as follows in B&S, page 19:

> The [Weighted by PITF model] uses PITF predicted probabilities to weight the results of the escalation model, ensuring that high-risk and low-risk countries that happen to take similar values on ICEWS-based predictors are nonetheless assigned different predicted probabilities in most months.

B&S intend that the escalation model's predictions for the test set are weighted by the PITF model predictions for the test set. However, they actually weight the \textbf{test} set predictions using the PITF model predictions for the \textbf{training} set.^[See `1mo_run_escalation_weighted_PITF.R` line 4, where the PITF predictions are taken from the training data set (`train$pred_prob_plus1`). The next line is a hack extending the shorter `weight` vector with missing values to avoid a R warning when it is multiplied with the longer vector of escalation model test set predictions. Similarly, in the 6-month version of this file.] This appears to be an easily corrected coding error on the part of B&S.


## Incorrect "PITF Split Population" Implementation

The "PITF Split Population" model also appears to be incorrectly implemented, owing to a coding error. B&S describe it on page 20:

> The final approach is a random forest analog to split-population modeling. We first compute the average PITF predicted probability for each country across all years in our training set. We define those that fall in the bottom quartile as "low risk" and the rest as "high risk." We then run our escalation model on the high-risk and low-risk subsets separately, combining the results into a single random forest [...].

This description suggests that B&S intended to run two separate random forest models, one each on the low- and high-risk training data splits. The replication code does indeed run two separate random forecasts, but they both utilize the *exact same training data*, which consists of the full training data from all other models. In short, rather than using only data for high-risk countries to train their split-sample model for high-risk cases, the data they use captures both high- and low-risk countries, similarly for the training set for their low-risk split. 

The model specifications are also identical; i.e., they use the same *x* variables and the same random forest hyper-parameter settings. The *only* difference in the models as they are implemented in the B&S replication code is due to the non-deterministic nature of the random forest model itself. If we ran both with the same random seed, they would be identical in every respect, producing to forests of identical decision trees and, thus, identical predictions.^[Disentangling this coding error is not straightforward as it occurs over several R scripts and requires (or at least is easier to verify by) running partway through the actual replication until the objects holding the training data for the models are instantiated and can be examined. We have documented details at https://github.com/andybega/Blair-Sambanis-replication/issues/5.] 

The implementation error aside, this split-population analog model is quite odd and does not replicate the idea behind split-population modeling [@chiba:etal:2015;@beger:etal:2017]. Although the two RFs are trained on separate data (in our updated, fixed replication), the process of combining them actually just creates a new, larger RF using both component model's underlying decision trees. Thus, while all RF models throughout (except for one of the robustness checks) are trained with 100,000 decision trees (`ntree`), the new RF model after combination does have 200,000 decision trees. Furthermore, the PITF model predictions do not impact how the combined RF model predicts at all, not even through a binary low-/high-risk split. The split-population PITF RF model is practically speaking just another escalation model trained with N=200,000 instead of N=100,000 trees and an extra odd randomization step added to the already existing RF randomization facilities (row and column sampling for each decision tree). This does not adequately implement their split-sample modeling strategy.

## Inconsistent test set N for the models in Table 2

Further, the AUC-ROC values reported in the original B&S Table 2 are calculated based on slightly different numbers of underlying test set cases (see Table \ref{tab:table2-N}). ROC calculations for a set of predictions can only be done on the set of cases for which both non-missing predictions and non-missing outcomes are available. Those sets differ across models (columns) for each row in B&S Table 2. 

Thus a difference in AUC-ROC values for two models could be because they were calculated on different sets of underlying cases, not because the models are systemically performing at a different level. In other words, the results for different models in B&S Table 2 are not comparable to one another, and any conclusions drawn from such comparison are potentially incorrect. 

## Incorrect scoring of the 2016 forecasts

B&S present a confusion matrix to score their 2016-H1 forecasts in Table 4. Although the forecasts are for the probability of civil war onset, in the replication code, they are actually scored using incidence of civil war.

The relevant variables in the data are "incidence_civil_ns" and "incidence_civil_ns_plus1", which appears to be a 1-period lead (ie., $t_+1$) version of the dependent variable that is used in the actual prediction models. The incidence dependent variable  contains both 0/1 and missing values. By examining the pattern of missing values, it seems clear that this was originally an incidence variable indicating whether a country was at civil war in a given year or not, and which was converted to an onset version so that onsets retain the value of 1 but continuing civil war years are coded as missing. This reflects common practice. 

However, by examining the code used to generated Table 4, we were able to confirm that the onset forecasts are assessed using incidence, not onset. In the file `6mo_make_confusion_matrix.do` on line 52, missing values in "incidence_civil_ns" are recoded to 1, thus reverting the onset coding of this variable to incidence. 

# Results of the updated analysis

We now turn to an examination of our analysis that addresses and fixes the issues discussed above.^[The code for all of our analysis undertaken for this effort may be found at https://github.com/andybega/Blair-Sambanis-replication.] The main results of the original analysis consist of the comparison of the Escalation to other ICEWS models (our Table \ref{tab:table1-nosmooth}, B&S Table 1), and a comparison of the Escalation model to models that add structural variables/information (our Table \ref{tab:table2-fixed}, B&S Table 2). We will review the substantive implications of our updated analysis below, but the bottom line is that these changes turn B&S's conclusions on their heads.

## Smoothed ROC curves and AUC calculations

A reference to smoothing is made in a single sentence in B&S (p. 12):

> Figure 1 displays the corresponding ROC curves, smoothed for ease of interpretation.

This implies that the ROC curves were only smoothed in the referenced Figure 1. However, this is not the case. All AUC-ROC calculations throughout the replication code use an option to smooth the ROC curves prior to AUC calculation. ROC curves are constructed from the false positive and true positive rates as one moves through a set of ranked predictions, and as a result they appear step-like. Figure \ref{fig:rocs} shows our replication of both the estimated smoothed ROC curves from the B&S report (left-hand side) and the actual empirical ROC curves (right-hand side). The standard method is to compute the area under the curve (AUC) statistic on the original, empirical ROC curves that are shown on the right. 

\begin{figure}
\caption{Replication of B\&S Figure 1 with both smooth and non-smoothed ROC curves\label{fig:rocs}}
\centering
\includegraphics[width=.95\linewidth]{figures/figure1-replicated.png}
\end{figure}

The specific predictions also include groups of cases with identical predicted probabilities, which accounts for the unusual diagonal lines seen in the panels on the right. In any case, with a sparse outcome like civil war onsets, the true positive rate on the *y*-axis only changes when the prediction for an observed positive case is reached. For these ROC curves, and for that matter in the fundamental train/test split used for 12 of the 18 rows/models in B&S Table 1, there are only 11 civil war onset cases in the test set. Thus, the ROC curves here are very step-like, with only 12 (11 positive cases plus 1 for TPR = 0) distinct *y* coordinates. Notice also that the smoothing averages the left-most almost straight line with the right-most almost straight line in a monotonic way.

## The Effect of Using Smoothed ROC Curves

What impact did the ROC smoothing have overall on the performance of the Escalation model relative to other ICEWS models (our Table \ref{tab:table1-nosmooth}, B&S Table 1) and structural extensions (our Table \ref{tab:table2-fixed}, B&S Table 2)?  Figure \ref{fig:benefit-plot} shows the changes in AUC-ROC values had we used smoothed ROC curves to calculate the AUC-ROC values. Each point corresponds to the change in AUC-ROC values for one of the models in the cells in Tables \ref{tab:table1-nosmooth} and \ref{tab:table2-fixed} (the colors match those in Figure \ref{fig:rocs}). The vertical bar in each plot marks the average effect of smoothing on AUC-ROC. For all alternative models, from Quad to "PITF Only", smoothing sometimes hurts and sometimes benefits, but the overall impact is negligible in average. The Escalation model _always_ benefits from smoothing, with an average improvement on the order of 0.05. This is sufficient to push the Escalation model ahead of the alternative models, and accounts for the result B&S find, namely that the escalation model is generally superior. 

\begin{figure}

{\centering \includegraphics[width=.8\linewidth]{submissionVersion_files/figure-latex/benefit-plot-1} 

}

\caption{Gain from using smoothed ROC to calculate AUC, for each model reported in Tables 3 and 4 (B\&S Tables 1 and 2)}(\#fig:benefit-plot)
\end{figure}

In sum, it is not only the case that using smoothed ROC curves alters the results, but also that the use of smoothed ROC curves to calculate AUC-ROC values benefits \textbf{only} the escalation model. It does so consistently and by a considerable margin. All eight alternative models reported in B&S Tables 1 and 2, on average, do not gain when using smoothed ROC curves to calculate AUC. Four of the eight show a small positive bias from smoothing, while the other four display a small negative bias. The magnitudes of these are not close to the level of positive bias found in the escalation model.

## Is the Escalation model superior to the alternative ICEWS models?

Table \ref{tab:table1-nosmooth} (B&S Table 1) shows the comparison of the Escalation model to other alternative models based on ICEWS event data indicators. The AUC-ROC values are based on original, non-smoothed ROC curves. 
Both the Average and CAMEO models outperform the Escalation model in almost all instances (see also Figure \ref{fig:table1-plot}). The Goldstein model generally outperforms the Escalation model in the 6-month version. The Quad model appears to be roughly on par with the Escalation model. Thus, the original B&S conclusion that the Escalation model is superior to the alternative models is entirely conditional on the non-standard use of smoothed ROC curves and overturns when using conventional AUC-ROC calculations. 

\begin{table}[t]

\caption{(\#tab:table1-nosmooth)Comparison of the escalation model to alternative ICEWS model using test set AUC-ROC, \textit{without} smoothed ROC curves (Replication of B\&S Table 1)}
\centering
\begin{tabular}{lrrrrr}
\toprule
Model & Escalation & Quad & Goldstein & CAMEO & Average\\
\midrule
\addlinespace[0.3em]
\multicolumn{6}{l}{\textbf{One-month forecasts}}\\
\hspace{1em}Base specification & 0.78 & 0.78 & 0.80 & 0.81 & 0.82\\
\hspace{1em}Terminal nodes & 0.79 & 0.78 & 0.79 & 0.81 & 0.82\\
\hspace{1em}Sample size & 0.79 & 0.80 & 0.74 & 0.82 & 0.84\\
\hspace{1em}Trees per forest & 0.78 & 0.78 & 0.79 & 0.81 & 0.82\\
\hspace{1em}Training/test sets 1 & 0.77 & 0.76 & 0.77 & 0.79 & 0.80\\
\hspace{1em}Training/test sets 2 & 0.75 & 0.77 & 0.74 & 0.76 & 0.78\\
\hspace{1em}Training/test sets 3 & 0.71 & 0.79 & 0.69 & 0.72 & 0.74\\
\hspace{1em}Coding of DV 1 & 0.80 & 0.80 & 0.80 & 0.82 & 0.83\\
\hspace{1em}Coding of DV 2 & 0.80 & 0.82 & 0.77 & 0.83 & 0.81\\
\addlinespace[0.3em]
\multicolumn{6}{l}{\textbf{Six-month forecasts}}\\
\hspace{1em}Base specification & 0.77 & 0.79 & 0.83 & 0.78 & 0.81\\
\hspace{1em}Terminal nodes & 0.77 & 0.78 & 0.82 & 0.78 & 0.79\\
\hspace{1em}Sample size & 0.77 & 0.77 & 0.80 & 0.80 & 0.82\\
\hspace{1em}Trees per forest & 0.77 & 0.79 & 0.83 & 0.79 & 0.81\\
\hspace{1em}Training/test sets 1 & 0.75 & 0.79 & 0.82 & 0.77 & 0.80\\
\hspace{1em}Training/test sets 2 & 0.70 & 0.75 & 0.78 & 0.75 & 0.77\\
\hspace{1em}Training/test sets 3 & 0.85 & 0.72 & 0.84 & 0.72 & 0.81\\
\hspace{1em}Coding of DV 1 & 0.78 & 0.80 & 0.83 & 0.79 & 0.82\\
\hspace{1em}Coding of DV 2 & 0.80 & 0.78 & 0.84 & 0.80 & 0.81\\
\bottomrule
\end{tabular}
\end{table}

The key difference between Table \ref{tab:table1-nosmooth} and B&S Table 1 is whether the underlying ROC curves were original or smoothed; the test set N and coding issues did not affect this set of results.^[We should note that in our replication we consciously decided to not set RNG seeds, even though the random forest models are non-deterministic and vary slightly from run to run. As we changed the replication code to allow running in parallel, we cannot exactly reproduce the B&S results even with the same RNG seed. More importantly, the substantive interpretation of results should not depend on a specific RNG seed. We found that the escalation model's AUC-ROC values generally fluctuate no more than 0.01 (see https://github.com/andybega/Blair-Sambanis-replication/blob/master/rep_nosmooth/variance.md), and thus are confident that the patterns we see are robust to the initial RNG state.] B&S's original results and interpretation regarding the superiority of the B&S model over alternative ICEWS models, including the 1,000+ covariate CAMEO model, are thus entirely conditional on the use of smoothed AUC-ROC. Even the Quad model is generally as good as the escalation model in all implementations and is frequently quite a bit better.

Aside from the visual impact of ROC smoothing, the underlying motivation and methods involved in smoothing are broader and involve parametric estimation of population ROC curves [@henley:1988; @henley:2014]. The main application is in the evaluation of medical tests (e.g. diagnostic imaging) with early methods dating back several decades and ongoing development of both parametric and non-parametric smoothing methods [e.g. @zou:etal:1997; @pulit:2016].  It is not established which methods are preferable in a given application [@henley:2014]. Notably, the context in which ROC smoothing is used differs in important aspects from typical conflict research applications. Conflict data are closer to a census of the population and with well-known dependencies like spatial and temporal correlation, rather than a random sample that is approximately independently and identically distributed. It is thus neither clear that smoothing is justified nor valid. We also note that smoothed ROC plots are not widely used outside of the narrow context mentioned above.

## Using Inconsistent Ns

The top portion of Table \ref{tab:table2-N} shows the number of valid test set predictions that can be scored for each model in the original B&S Table 2. For the 1-month data version, the number of predictions differs by up to 500 cases, and in the 6-month data version by around 100 cases. These numbers appear small enough to be not important. However, the already small number of positive cases also is affected substantially:  "With PITF Predictors" and "PITF Only" models lose two or one (respectively) of 11 positive cases in the 1- and 6-month data versions. 

\begin{table}[t]

\caption{(\#tab:table2-N)Number of valid test predictions for the escalation and structural alterantives models (B\&S Table 2)}
\centering
\begin{tabular}{ll>{\raggedleft\arraybackslash}p{2cm}>{\raggedleft\arraybackslash}p{2cm}>{\raggedleft\arraybackslash}p{2cm}>{\raggedleft\arraybackslash}p{2cm}>{\raggedleft\arraybackslash}p{2cm}}
\toprule
 & Horizon & Escalation Only & With PITF Predictors & Weighted by PITF & PITF Split Population & PITF Only\\
\midrule
\addlinespace[0.3em]
\multicolumn{7}{l}{\textbf{Original model-specific cases}}\\
\hspace{1em} & 1 month & 13748 & 13155 & 13461 & 13748 & 13510\\
\cmidrule{2-7}
\hspace{1em} & 6 months & 2366 & 2264 & 2317 & 2366 & 2265\\
\cmidrule{1-7}
\addlinespace[0.3em]
\multicolumn{7}{l}{\textbf{Cases adjusted to common subset}}\\
\hspace{1em} & 1 month & 13062 & 13062 & 13062 & 13062 & 13062\\
\cmidrule{2-7}
\hspace{1em} & 6 months & 2250 & 2250 & 2250 & 2250 & 2250\\
\bottomrule
\end{tabular}
\end{table}

Generally, these comparisons require the same cases.  Therefore, we use predictions for a common joint subset of non-missing predictions. The resulting numbers of cases for each model are shown in the bottom portion of the table. Since the sets of incomplete cases in the original version above do not entirely overlap themselves, the common subset for all models is slightly smaller than the smallest N in the top portion of the table.

## Do Structural Variables Add to the Escalation Model's Predictive Power?

Table \ref{tab:table2-fixed} shows our replication of B&S Table 2 with (1) regular, not smoothed, AUC-ROC, (2) fixed "Weighted by PITF" and "PITF Split-Population" models, and (3) AUC-ROC values computed on the common, joint subset of tests cases for which all models have non-missing predictions. Table \ref{tab:table2-full} in the appendix shows AUC-ROC values for both smoothed and non-smoothed versions, and both the original, model-varying test cases sets and our common joint subset. 

\begin{table}[t]

\caption{(\#tab:table2-fixed)Comparison of escalation model to structural extensions, using test set AUC-ROC (Replication of B\&S Table 2)}
\centering
\begin{threeparttable}
\begin{tabular}{r>{\raggedleft\arraybackslash}p{2cm}>{\raggedleft\arraybackslash}p{2cm}>{\raggedleft\arraybackslash}p{2cm}>{\raggedleft\arraybackslash}p{2cm}>{}p{2cm}}
\toprule
Escalation Only & With PITF Predictors & Weighted by PITF & PITF Split Population & PITF Only\\
\midrule
\addlinespace[0.3em]
\multicolumn{5}{l}{\textbf{One-month forecasts}}\\
\hspace{1em}0.75 & 0.78 & 0.78 & 0.85 & 0.75\\
\addlinespace[0.3em]
\multicolumn{5}{l}{\textbf{Six-month forecasts}}\\
\hspace{1em}0.76 & 0.86 & 0.80 & 0.77 & 0.74\\
\bottomrule
\end{tabular}
\begin{tablenotes}[para]
\item \textit{Note: } 
\item Differences from the original B\&S Table 2: (1) AUC-ROC values are computed on the common subset of cases, meaning that N is equal in each row; (2) AUC-ROC values are computed using original, non-smoothed ROC curves.
\end{tablenotes}
\end{threeparttable}
\end{table}

B&S interpret their results as follows, on page 20 and we comment on the conclusions seratim:^[We list the "Overall, ..." interpretation out of order, last, for clarity.]

1. B&S: "Of the approaches we test, the split-population analog is most promising ..."

The PITF split-population analog still performs well, but the simple Escalation + PITF predictors model arguable performs better still. 

2. B&S: "Adding PITF predictors improves the performance of the escalation model over six-month windows but diminishes it over one-month windows \ldots "

Adding PITF predictors actually improves performance in both cases; the "With PITF Predictions" model strictly dominates the "Escalation Only" model, and by quite a margin in the 6-month data version.  

3. B&S: "The weighted model performs very poorly regardless \ldots "

The weighted model performs roughly on par with the Escalation Only model. One finding that remains is that the "PITF Only" model is outperformed by the "Escalation Only" model. As the former only uses annual inputs, but the data at hand are the 1-month or 6-months level, this is neither surprising, nor noteworthy.

4. B&S: "Overall, our results suggest that while measures of structural risk may improve predictive performance, the value they add is marginal and inconsistent. [...] Incorporating PITF thus significantly reduces or only slightly improves the performance of the escalation model, regardless of the approach we take. [...] "

The most straightforward method of incorporating the annual structural PITF variables---adding them to the predictors of the Escalation RF model---strictly outperforms the Escalation Only model. Note that the two other combination models considered are both non-standard and that the "PITF Split Population" model does not incorporate structural information at all, yet they also both do well. We thus conclude that adding structural variables improves predictive performance.

## How Accurate Were the 2016 Forecasts?


B&S report (Table 4)confusion matrices for their forecasts for the first half of 2016 (2016-H1). To create the confusion matrices, B&S treat the 30 highest ranked predictions as positive predictions ("1s") and the rest as negative predictions ("0s"). We replicate their Table 4 in the top portion of \ref{tab:table4}. There are two confusion matrices for slightly different codings of outcomes in 2016-H1, under the corresponding "Assuming Persistence" and "Assuming Change" headings. We should note that the "Assuming Persistence" corresponds to the values in the replication data; the small variations for the "Assuming Change" version are hand-coded in the replication code file that generates the confusion matrices and appear to be subjective assessments of B&S. 

We can see that the original table presents 15 or 16 positive cases for 2016-H1, depending on the dependent variable coding variation. This corresponds to a positive rate of around 9.5% for the first half of 2016 data. In contrast, the corresponding 6-month version of the data from 2001 to 2015, with 30 half-years, has in total 20 civil war onset events, for a much lower positive rate of around 0.5%. The positive event rate in the confusion matrices far exceeds the rate of observed civil war onsets in both the training and test data. This suggests that the forecasts were erroneously assessed using civil war incidence, not onset. By examining the replication code we were able to verify that the forecasts were scored using civil war incidence, i.e., including ongoing civil wars, rather than civil war onset years only. 

\begin{table}[t]

\caption{(\#tab:table4)Replication of B\&S Table 4: 2016 Confusion Matrices for Six-month Escalation Model.}
\centering
\begin{tabular}{llrrr}
\toprule
 & header & Observed & Predicted0 & Predicted1\\
\midrule
\addlinespace[0.3em]
\multicolumn{5}{l}{\textbf{Original, scored with civil war incidence}}\\
\hspace{1em} & Assuming Persistence & 0 & 132 & 17\\
\cmidrule{3-5}
\hspace{1em} &  & 1 & 2 & 13\\
\cmidrule{2-5}
\hspace{1em} & Assuming Change & 0 & 132 & 16\\
\cmidrule{3-5}
\hspace{1em} &  & 1 & 2 & 14\\
\cmidrule{1-5}
\addlinespace[0.3em]
\multicolumn{5}{l}{\textbf{Fixed, scored with civil war onset}}\\
\hspace{1em} & Assuming Persistence & 0 & 134 & 30\\
\cmidrule{3-5}
\hspace{1em} &  & 1 & 0 & 0\\
\cmidrule{2-5}
\hspace{1em} & Assuming Change & 0 & 134 & 28\\
\cmidrule{3-5}
\hspace{1em} &  & 1 & 0 & 2\\
\bottomrule
\end{tabular}
\end{table}

The correct confusion matrices when using observed onset (or the lack of it) are shown in the second part of Table \ref{tab:table4}. In the default "Assuming Persistence" coding, there are no civil war onsets in the data for 2016-H1. Thus, the recall values is undefined, while the precision is 0/30 = 0, compared to reported recall and precision values of 13/15 = 0.87 and 13/30 = 0.43. The alternative coding ("Assuming Change") produces two civil war onsets. Recall is 1.0 compared to 14/16 = 0.88 before, and precision is 2/30 = 0.07 instead of 14/30 = 0.47. 

Another, minor issue or rather coding error, is related to using a lead version of the DV. With the lead version of the DV, "incidence_civil_ns_plus1", which is what the models are predicting, the predicted value for 2016-H1 indicates the risk of civil war onset in 2016-H2. In the Table 4 script referenced above, the 2016-H1 predictions (for 2016-H2) are assessed using the raw DV, "incidence_civil_ns", not the lead version. Essentially, the forecasts for 2016-H2 are assessed using observed outcomes for 2016-H1. In this case, it doesn't make a difference since both the raw DV and lead version for 2016-H1 do not have any positive values. 

# Conclusion

B&S advocate the use of theory to guide prediction. But "theory" as used by B&S is an ambiguous and undefined concept.  It is not a procedure.  They actually create a model with ten right-hand side variables that are supposed to capture a complicated repression-dissent dynamic. There is wide-ranging literature on this dynamic that could justify many specifications.  As such, their baseline comparison is an unfortunate standard bearer for strong theory.

Another important consideration when developing a predictive model is to do so without contaminating the out-of-sample test set. This occurs if test set performance is used to inform specification---predictive modeling's analogue to p-hacking---and special care is needed [e.g. see the approach by @colaresi:mahmood:2017]. B&S did pre-register their 2016-H1 forecasts, which verifies the integrity of the forecasts, but this does not assure the model development process. To be clear: there is no reason to suspect test set contamination in the escalation or other models. Rather, it is challenging to provide verifiable assurance thereof in a single analysis iteration that both develops and tests a model on data that was available contemporaneously. 

Moreover, they misunderstand the use of ICEWS event data in current research. They claim that most applications to date have focused on the quad categories, but this ignores a wide swath of literature [@steinert-threlkeld:2017; and @metternich:etal:2013] that uses a specific action---such as protest---defined in the CAMEO ontology. In their article on conflict in Thailand, Metternich et alia hand-coded, for example, every actor in Thailand and focused on an analysis of how those interact.

We encountered several issues in the code underlying the B&S analysis. The problems we encountered are not subjective modeling choices. When we fix these issues and perform an updated analysis, the B&S conclusions are all essentially overturned. In other words, B&S findings are based on a faulty analysis, and invalid. 

In contradistinction to the conclusions offered by B&S, we find that when correctly specified and implemented:

- The theory-driven escalation model is outperformed both by the low-effort 1,160 predictor all-CAMEO model.
- The Average ensemble model and the CAMEO models outperform the escalation model in all instances.
- Adding structural variables substantially improves the escalation model's performance.

Blair & Sambanis have focused attention on comparing forecasting models and forecasts in the civil war domain.  As social science becomes more adept at predictive analysis, this will doubtless be of increasing importance.  However, these comparisons must be made carefully to ensure those correct inferences are drawn.  We continue to think that theory is overrated [@ward:2016], and that machine learning and big data will allow us to learn new things. It will be interesting to see how the evidence for these claims is adjudicated with additional usage and careful evaluation.

\newpage

# References

<div id="refs"></div>

\newpage

# (APPENDIX) Appendix {-}

# Appendix

\renewcommand{\thefigure}{A\arabic{figure}}
\setcounter{figure}{0}

\renewcommand{\thetable}{A\arabic{table}} 
\setcounter{table}{0}

## Additional replication tables

Table \ref{tab:table1-smooth} is our replication of B&S Table 1 with smoothed AUC-ROC. The results differ slightly from the original B&S Table 1, typically by no more than 0.01, due to the non-deterministic nature of the RF models. It is the case that B&S set the RNG seed in their replication code, which should theoretically allow exact reproduction, but (1) there was a change in more recent versions of R that affected the RNG seeding process, and (2) we refactored the replication script to allow one to run the models in parallel. In any case, the interpretation of results should not be sensitive to random variation, i.e. it should not depend on using a specific RNG seed. On the basis of these results, B&S conclude that the escalation model is generally superior to the alternatives, and we can replicate that interpretation when using smoothed ROC curves. 

\begin{table}[t]

\caption{(\#tab:table1-smooth)Replication of B\&S Table 1 with smoothed ROC curves; test set AUC-ROC for various models}
\centering
\begin{tabular}{lrrrrr}
\toprule
Model & Escalation & Quad & Goldstein & CAMEO & Average\\
\midrule
\addlinespace[0.3em]
\multicolumn{6}{l}{\textbf{One-month forecasts}}\\
\hspace{1em}Base specification & 0.85 & 0.80 & 0.79 & 0.84 & 0.83\\
\hspace{1em}Terminal nodes & 0.86 & 0.79 & 0.77 & 0.83 & 0.82\\
\hspace{1em}Sample size & 0.85 & 0.81 & 0.71 & 0.86 & 0.84\\
\hspace{1em}Trees per forest & 0.85 & 0.80 & 0.78 & 0.83 & 0.82\\
\hspace{1em}Training/test sets 1 & 0.86 & 0.78 & 0.76 & 0.81 & 0.80\\
\hspace{1em}Training/test sets 2 & 0.82 & 0.79 & 0.72 & 0.77 & 0.78\\
\hspace{1em}Training/test sets 3 & 0.80 & 0.80 & 0.69 & 0.74 & 0.75\\
\hspace{1em}Coding of DV 1 & 0.86 & 0.81 & 0.80 & 0.84 & 0.83\\
\hspace{1em}Coding of DV 2 & 0.92 & 0.80 & 0.81 & 0.81 & 0.81\\
\addlinespace[0.3em]
\multicolumn{6}{l}{\textbf{Six-month forecasts}}\\
\hspace{1em}Base specification & 0.82 & 0.78 & 0.82 & 0.77 & 0.79\\
\hspace{1em}Terminal nodes & 0.79 & 0.76 & 0.81 & 0.77 & 0.77\\
\hspace{1em}Sample size & 0.83 & 0.78 & 0.78 & 0.79 & 0.79\\
\hspace{1em}Trees per forest & 0.82 & 0.77 & 0.82 & 0.77 & 0.79\\
\hspace{1em}Training/test sets 1 & 0.80 & 0.78 & 0.81 & 0.76 & 0.78\\
\hspace{1em}Training/test sets 2 & 0.72 & 0.74 & 0.77 & 0.73 & 0.75\\
\hspace{1em}Training/test sets 3 & 0.88 & 0.71 & 0.81 & 0.68 & 0.79\\
\hspace{1em}Coding of DV 1 & 0.83 & 0.77 & 0.82 & 0.79 & 0.80\\
\hspace{1em}Coding of DV 2 & 0.83 & 0.77 & 0.83 & 0.78 & 0.79\\
\bottomrule
\end{tabular}
\end{table}

\begin{table}[t]

\caption{(\#tab:table2-full)Replication of B\&S Table 2 with smoothed/original ROC and with original varying N cases or adjusting for common case set with constant N}
\centering
\begin{tabular}{ll>{\raggedright\arraybackslash}p{1.5cm}>{\raggedleft\arraybackslash}p{2cm}>{\raggedleft\arraybackslash}p{2cm}>{\raggedleft\arraybackslash}p{2cm}>{\raggedleft\arraybackslash}p{2cm}>{\raggedleft\arraybackslash}p{2cm}}
\toprule
 &  & Smoothed ROC & Escalation Only & With PITF Predictors & Weighted by PITF & PITF Split Population & PITF Only\\
\midrule
\addlinespace[0.3em]
\multicolumn{8}{l}{\textbf{Original model-specific cases}}\\
\addlinespace[0.3em]
\multicolumn{8}{l}{\textit{1 month}}\\
\hspace{1em}\hspace{1em} &  & Yes & 0.85 & 0.77 & 0.80 & 0.81 & 0.76\\
\cmidrule{3-8}
\hspace{1em}\hspace{1em} &  & No & 0.79 & 0.78 & 0.80 & 0.79 & 0.75\\
\cmidrule{2-8}
\addlinespace[0.3em]
\multicolumn{8}{l}{\textit{6 months}}\\
\hspace{1em}\hspace{1em} &  & Yes & 0.82 & 0.85 & 0.81 & 0.78 & 0.74\\
\cmidrule{3-8}
\hspace{1em}\hspace{1em} &  & No & 0.77 & 0.86 & 0.81 & 0.78 & 0.74\\
\cmidrule{1-8}
\addlinespace[0.3em]
\multicolumn{8}{l}{\textbf{Cases adjusted to common subset}}\\
\addlinespace[0.3em]
\multicolumn{8}{l}{\textit{1 month}}\\
\hspace{1em}\hspace{1em} &  & Yes & 0.81 & 0.77 & 0.79 & 0.86 & 0.76\\
\cmidrule{3-8}
\hspace{1em}\hspace{1em} &  & No & 0.75 & 0.78 & 0.78 & 0.85 & 0.75\\
\cmidrule{2-8}
\addlinespace[0.3em]
\multicolumn{8}{l}{\textit{6 months}}\\
\hspace{1em}\hspace{1em} &  & Yes & 0.82 & 0.85 & 0.80 & 0.77 & 0.74\\
\cmidrule{3-8}
\hspace{1em}\hspace{1em} &  & No & 0.76 & 0.86 & 0.80 & 0.77 & 0.74\\
\bottomrule
\end{tabular}
\end{table}

\begin{table}[t]

\caption{(\#tab:table1-benefit)Smoothing advantage for B\&S Table 1: the gain in AUC-ROC when calculated using smoothed ROC curves}
\centering
\begin{tabular}{lrrrrr}
\toprule
Model & Escalation & Quad & Goldstein & CAMEO & Average\\
\midrule
\addlinespace[0.3em]
\multicolumn{6}{l}{\textbf{One-month forecasts}}\\
\hspace{1em}Base specification & 0.06 & 0.02 & -0.01 & 0.03 & 0.00\\
\hspace{1em}Terminal nodes & 0.07 & 0.01 & -0.01 & 0.02 & 0.00\\
\hspace{1em}Sample size & 0.06 & 0.01 & -0.04 & 0.04 & 0.00\\
\hspace{1em}Trees per forest & 0.06 & 0.02 & -0.01 & 0.02 & 0.00\\
\hspace{1em}Training/test sets 1 & 0.09 & 0.02 & -0.01 & 0.02 & 0.00\\
\hspace{1em}Training/test sets 2 & 0.07 & 0.02 & -0.01 & 0.02 & 0.00\\
\hspace{1em}Training/test sets 3 & 0.09 & 0.01 & 0.00 & 0.02 & 0.01\\
\hspace{1em}Coding of DV 1 & 0.07 & 0.02 & 0.00 & 0.02 & 0.00\\
\hspace{1em}Coding of DV 2 & 0.12 & -0.02 & 0.04 & -0.01 & 0.01\\
\addlinespace[0.3em]
\multicolumn{6}{l}{\textbf{Six-month forecasts}}\\
\hspace{1em}Base specification & 0.05 & -0.01 & -0.01 & -0.01 & -0.02\\
\hspace{1em}Terminal nodes & 0.02 & -0.02 & -0.01 & -0.01 & -0.02\\
\hspace{1em}Sample size & 0.05 & 0.00 & -0.02 & -0.01 & -0.03\\
\hspace{1em}Trees per forest & 0.05 & -0.01 & -0.01 & -0.02 & -0.02\\
\hspace{1em}Training/test sets 1 & 0.04 & -0.01 & -0.01 & -0.02 & -0.02\\
\hspace{1em}Training/test sets 2 & 0.02 & -0.01 & -0.02 & -0.01 & -0.02\\
\hspace{1em}Training/test sets 3 & 0.03 & -0.02 & -0.03 & -0.04 & -0.02\\
\hspace{1em}Coding of DV 1 & 0.05 & -0.03 & -0.01 & 0.00 & -0.02\\
\hspace{1em}Coding of DV 2 & 0.03 & -0.01 & -0.01 & -0.02 & -0.02\\
\bottomrule
\end{tabular}
\end{table}

\begin{table}[t]

\caption{(\#tab:table2-benefit)Smoothing advantage for B\&S Table 2: the gain in AUC-ROC when calculated using smoothed ROC curves}
\centering
\begin{tabular}{l>{\raggedleft\arraybackslash}p{2cm}>{\raggedleft\arraybackslash}p{2cm}>{\raggedleft\arraybackslash}p{2cm}>{\raggedleft\arraybackslash}p{2cm}>{\raggedleft\arraybackslash}p{2cm}}
\toprule
Model & Escalation Only & With PITF Predictors & Weighted by PITF & PITF Split Population & PITF Only\\
\midrule
\addlinespace[0.3em]
\multicolumn{6}{l}{\textbf{One-month forecasts}}\\
\hspace{1em}Base specification & 0.06 & -0.01 & 0.01 & 0.01 & 0.01\\
\addlinespace[0.3em]
\multicolumn{6}{l}{\textbf{Six-month forecasts}}\\
\hspace{1em}Base specification & 0.06 & -0.01 & 0.00 & 0.00 & 0.00\\
\bottomrule
\end{tabular}
\end{table}

## Model to model comparison plots

Figures \ref{fig:table1-plot} and \ref{fig:table2-plot} replicate the information in Tables \ref{tab:table1-nosmooth} and \ref{tab:table2-fixed} in a way makes the comparison of the escalation model to the alternative models easier. Each facet shows the escalation AUC-ROC for all model settings (the rows in Table \ref{fig:table1-plot} and base specification for all models in Table \ref{tab:table2-fixed}) on the left, and the AUC-ROC for an alternative model on the right, with a connecting line. If the lines slope up to the right, the alternative model is better. 

\begin{figure}

{\centering \includegraphics[width=.9\linewidth]{submissionVersion_files/figure-latex/table1-plot-1} 

}

\caption{Escalation to alternative comparisons for the ICEWS models (B\&S Table 1)}(\#fig:table1-plot)
\end{figure}

\begin{figure}

{\centering \includegraphics[width=.9\linewidth]{submissionVersion_files/figure-latex/table2-plot-1} 

}

\caption{Escalation to alternative comparisons for the structural models (B\&S Table 2)}(\#fig:table2-plot)
\end{figure}


## Random forest hyper-parameter selection

What initially sparked our interest in the paper was the unusual choice of hyperparameter settings for the random forest models estimated. Table \ref{tab:hp} shows the default values used by the implementation of random forest that B&S use (from the **randomForest** R package), in contrast to the basic settings used by B&S for most the models reported in the paper. 

As the outcome is a binary indicator of civil war onset, one would typically use a classification random forest that predicts 0 or 1 labels directly. The implementation of random forests that B&S use ([@liaw:wiener:2002]) is based on the original @breiman:2001 implementation and calculates predictive probabilities by averaging over the "0" or "1" votes from all constituent decision trees. The conventional wisdom regarding the number of trees in a random forest is that it needs to be large enough to stabilize performance, but without any additional gain or harm in accuracy beyond a certain number. From the other default settings, which are generally not uninformed choices, one can see that the basic logic is to grow a forest with a relatively small number of trees, but where each tree is fairly extensive, and operates on a large bootstrapped sample of the original training data. These are of course only heuristics and it is usual to attempt to find better hyper-parameter methods through some form of tuning. 

\begin{table}
\caption{\label{tab:hp} Random forest (\texttt{randomForest()}) default versus B\&S hyperparameters}
\begin{tabular}{l>{\raggedright\arraybackslash}p{2in}ll}
\toprule
Hyperparameter & Default heuristic & Default values (Escalation) & B\&S value \\
\midrule
type & & classification & regression \\
ntree & & 500 & 100,000 or 1e6 \\
mtry & \texttt{floor(sqrt(ncol(x)))} & 3 & 3 \\
replace & & true & false \\
sampsize & \texttt{nrow(x)} if replace, else \texttt{ceiling(.632*nrow(x))} & 11,869 & 100 or
500 \\
nodesize & 1 for classification & 1 & 1 \\
maxnodes & & null & 5 or 10 \\
\bottomrule
\end{tabular}
\end{table}

B&S in contrast fit very large forests with 100,000 trees in the basic model form, but where each tree only operates on a very small sub-sample (N=100 or 500), drawn without replacement, of the available training data. This approach only works due to the choice to use regression, not classification, trees. Trying to use classification trees with the other parameter settings does not work at all because it is almost guaranteed that a sample of 100 from the ~11,000 training data rows with 9 positive cases will only include 0 (negative) outcomes in the sample. As it is, using regression with a 0 or 1 outcome produces warnings when estimating the models: 

```
Warning message:
In randomForest.default(y = as.integer(train_df$incidence_civil_ns_plus1 ==  :
  The response has five or fewer unique values.  Are you sure you want to do regression?
```

As it turns out, using regression random forests for this kind of binary classification problem in order to obtain probability estimates matches the probability random forest approach suggested and positively evaluated in @malley:etal:2012, and which is used in another prominent R implementation of random forests.^[The **ranger** package.] It is not clear whether this is intentional, as the Malley paper is not cited in B&S. 

In any case, B&S's random forest approach appears to work really well. We tried to construct classification random forests tuned via cross-validation on the training data set partition, i.e. without touching the test data, but were unable to develop models that consistently match the B&S random forest method in both cross-validated out-of-sample training predictions and test set predictions. 

Given that they are relatively unorthodox, yet appear to work very well, we wonder how the hyper-parameter values were determined. Two specific concerns are that this was not done with an eye towards test set accuracy, which would invalidate the independence of the out-of-sample test set, and whether the specific hyper-parameter values are optimized for only one model, or were optimized and found to work well for all models. There is no discussion of the random forest tuning strategy or how the specific hyper-parameter methods were determined in the paper. 

Given the dramatic changes in results as a result of the preceding issues, we did not further investigate these potential concerns.

