Replication of Blair and Sambanis 2020
===============

This repo contains a reproduction/replication of the code and data for Blair and Sambanis, 2020, 'Forecasting Civil Wars: Theory and Structure in an Age of "Big Data" and Machine Learning', Journal of Conflict Resolution ([journal link](https://journals.sagepub.com/doi/abs/10.1177/0022002720918923)).

The original replication materials are in `rep_original`; the paper and SI as well as other relevant documents are in `original_materials`. We conduct a modified replication in `rep_nosmooth` where we:

- calculate AUC-ROC values using empirical ROC curves, not smoothed ROC curves, which B&S do for all results mentioned in the paper
- fix coding/implementation mistakes for the "Weighted by PITF" and "PITF Split Population" models reported in B&S Table 2

In `table4` we verify that the 2016-H1 forecasts created by B&S are in their Table 4 incorrectly scored using civil war incidence, not civil war onset, which is what they forecast.

## Folders

- `original_materials`: the paper, SI, and other documents
- `rep_original/`: the original replication code, with some trivial changes to be able to run it 
- `rep_nosmooth/`: our version of the replication; code restructured to allow running in parallel; corrects for the issues we bring up in the paper
- `table4/`: investigating how B&S Table 4 was created; and a fixed assessment
- `tuning/`: abortive tuning experiments that we did not include in the paper

The other folders and files at the repo top level pertain to the replication writeup in `paper.pdf`. 

## Replication

To re-run the replication, see the instructions in [rep_nosmooth/README.md].

## Misc

For the paper word count:

```bash
ps2ascii paper.pdf | wc -w
```
