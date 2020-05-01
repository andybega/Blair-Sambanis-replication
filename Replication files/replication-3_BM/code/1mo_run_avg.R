
# Average predicted probabilities across models

# AB:
# load the dependencies
prediction_escalation_inc_civil_ns <- as.numeric(read.dta13("predictions/1mo_predictions_escalation.dta")$prediction)
prediction_quad_inc_civil_ns       <- as.numeric(read.dta13("predictions/1mo_predictions_quad.dta")$prediction)
prediction_goldstein_inc_civil_ns  <- as.numeric(read.dta13("predictions/1mo_predictions_goldstein.dta")$prediction)
prediction_all_CAMEO_inc_civil_ns  <- as.numeric(read.dta13("predictions/1mo_predictions_all_CAMEO.dta")$prediction)

prediction <- as.numeric((prediction_escalation_inc_civil_ns +
                            prediction_quad_inc_civil_ns +
                            prediction_goldstein_inc_civil_ns +
                            prediction_all_CAMEO_inc_civil_ns)
                         /4)

# prediction_robust_maxnodes <- as.numeric((prediction_robust_maxnodes_escalation_inc_civil_ns +
#                                 prediction_robust_maxnodes_quad_inc_civil_ns +
#                                 prediction_robust_maxnodes_goldstein_inc_civil_ns +
#                                 prediction_robust_maxnodes_all_CAMEO_inc_civil_ns)
#                              /4)
#
# prediction_robust_sampsize <- as.numeric((prediction_robust_sampsize_escalation_inc_civil_ns +
#                                 prediction_robust_sampsize_quad_inc_civil_ns +
#                                 prediction_robust_sampsize_goldstein_inc_civil_ns +
#                                 prediction_robust_sampsize_all_CAMEO_inc_civil_ns)
#                              /4)
#
# prediction_robust_ntree <- as.numeric((prediction_robust_ntree_escalation_inc_civil_ns +
#                              prediction_robust_ntree_quad_inc_civil_ns +
#                              prediction_robust_ntree_goldstein_inc_civil_ns +
#                              prediction_robust_ntree_all_CAMEO_inc_civil_ns)
#                           /4)
#
# prediction_robust_traintest1 <- as.numeric((prediction_robust_traintest1_escalation_inc_civil_ns +
#                                   prediction_robust_traintest1_quad_inc_civil_ns +
#                                   prediction_robust_traintest1_goldstein_inc_civil_ns +
#                                   prediction_robust_traintest1_all_CAMEO_inc_civil_ns)
#                                /4)
#
# prediction_robust_traintest2 <- as.numeric((prediction_robust_traintest2_escalation_inc_civil_ns +
#                                   prediction_robust_traintest2_quad_inc_civil_ns +
#                                   prediction_robust_traintest2_goldstein_inc_civil_ns +
#                                   prediction_robust_traintest2_all_CAMEO_inc_civil_ns)
#                                /4)
#
# prediction_robust_traintest3 <- as.numeric((prediction_robust_traintest3_escalation_inc_civil_ns +
#                                   prediction_robust_traintest3_quad_inc_civil_ns +
#                                   prediction_robust_traintest3_goldstein_inc_civil_ns +
#                                   prediction_robust_traintest3_all_CAMEO_inc_civil_ns)
#                                /4)
#
#
# prediction_robust_civil_ns_alt1 <- as.numeric((prediction_robust_civil_ns_alt1_escalation_inc_civil_ns +
#                                      prediction_robust_civil_ns_alt1_quad_inc_civil_ns +
#                                      prediction_robust_civil_ns_alt1_goldstein_inc_civil_ns +
#                                      prediction_robust_civil_ns_alt1_all_CAMEO_inc_civil_ns)
#                                   /4)
#
# prediction_robust_civil_ns_alt2 <- as.numeric((prediction_robust_civil_ns_alt2_escalation_inc_civil_ns +
#                                      prediction_robust_civil_ns_alt2_quad_inc_civil_ns +
#                                      prediction_robust_civil_ns_alt2_goldstein_inc_civil_ns +
#                                      prediction_robust_civil_ns_alt2_all_CAMEO_inc_civil_ns)
#                                   /4)


# Calculate AUC
performance <- prediction(prediction, test_DV_civil_ns)
roc <- roc(test_DV_civil_ns, prediction, smooth=TRUE, auc = TRUE)
saveRDS(roc, "figures/roc-1mo-avg.rds")
AUC_obs <- data.frame(as.numeric(roc$auc))

## RM: ADDED 4/29/2020
roc_noSmooth <- roc(test_DV_civil_ns, prediction, smooth=FALSE, auc = TRUE)
saveRDS(roc, "figures/non-smooth-roc-1mo-avg.rds")
AUC_obs_noSmooth <- data.frame(as.numeric(roc_noSmooth$auc))
#   			performance_robust_maxnodes <- prediction(prediction_robust_maxnodes, test_DV_civil_ns)
#           roc_robust_maxnodes <- roc(test_DV_civil_ns, prediction_robust_maxnodes, smooth=TRUE, auc = TRUE)
# 				    AUC_obs_robust_maxnodes <- data.frame(as.numeric(roc_robust_maxnodes$auc))
#
#       	performance_robust_sampsize <- prediction(prediction_robust_sampsize, test_DV_civil_ns)
#           roc_robust_sampsize <- roc(test_DV_civil_ns, prediction_robust_sampsize, smooth=TRUE, auc = TRUE)
# 				    AUC_obs_robust_sampsize <- data.frame(as.numeric(roc_robust_sampsize$auc))
#
#       	performance_robust_ntree <- prediction(prediction_robust_ntree, test_DV_civil_ns)
#           roc_robust_ntree <- roc(test_DV_civil_ns, prediction_robust_ntree, smooth=TRUE, auc = TRUE)
# 				    AUC_obs_robust_ntree <- data.frame(as.numeric(roc_robust_ntree$auc))
#
#         performance_robust_traintest1 <- prediction(prediction_robust_traintest1, test_DV_civil_ns_robust_traintest1)
#           roc_robust_traintest1 <- roc(test_DV_civil_ns_robust_traintest1, prediction_robust_traintest1, smooth=TRUE, auc = TRUE)
#   			    AUC_obs_robust_traintest1 <- data.frame(as.numeric(roc_robust_traintest1$auc))
#
#         performance_robust_traintest2 <- prediction(prediction_robust_traintest2, test_DV_civil_ns_robust_traintest2)
#            roc_robust_traintest2 <- roc(test_DV_civil_ns_robust_traintest2, prediction_robust_traintest2, smooth=TRUE, auc = TRUE)
#              AUC_obs_robust_traintest2 <- data.frame(as.numeric(roc_robust_traintest2$auc))
#
#         performance_robust_traintest3 <- prediction(prediction_robust_traintest3, test_DV_civil_ns_robust_traintest3)
#             roc_robust_traintest3 <- roc(test_DV_civil_ns_robust_traintest3, prediction_robust_traintest3, smooth=TRUE, auc = TRUE)
#              AUC_obs_robust_traintest3 <- data.frame(as.numeric(roc_robust_traintest3$auc))
#
#         performance_robust_civil_ns_alt1 <- prediction(prediction_robust_civil_ns_alt1, test_DV_civil_ns_alt1)
#           roc_robust_civil_ns_alt1 <- roc(test_DV_civil_ns_alt1, prediction_robust_civil_ns_alt1, smooth=TRUE, auc = TRUE)
#             AUC_obs_robust_civil_ns_alt1 <- data.frame(as.numeric(roc_robust_civil_ns_alt1$auc))
#
#         performance_robust_civil_ns_alt2 <- prediction(prediction_robust_civil_ns_alt2, test_DV_civil_ns_alt2)
#           roc_robust_civil_ns_alt2 <- roc(test_DV_civil_ns_alt2, prediction_robust_civil_ns_alt2, smooth=TRUE, auc = TRUE)
#             AUC_obs_robust_civil_ns_alt2 <- data.frame(as.numeric(roc_robust_civil_ns_alt2$auc))
#

# Compile AUCs

# AUCs <- as.matrix(c(AUC_obs, AUC_obs_robust_maxnodes, AUC_obs_robust_sampsize,
#                     AUC_obs_robust_ntree, AUC_obs_robust_traintest1, AUC_obs_robust_traintest2,
#                        AUC_obs_robust_traintest3, AUC_obs_robust_civil_ns_alt1, AUC_obs_robust_civil_ns_alt2))

## RM: ADDED 4/29/2020
# keep track of both smoothed and original AUC ROC; write a table with these
# intermediate results so that Table 1 can be reconstructed later without having
# to re-run all of the model scripts.
AUCs <- as.matrix(c(AUC_obs, AUC_obs_noSmooth))

tbl <- data.frame(
  model = "base specification",
  specification = "avg",
  horizon = "1 month",
  smoothed = unname(AUC_obs),
  original = unname(AUC_obs_noSmooth)
)
write.csv(tbl, "tables/auc-1mo-avg.csv", row.names = FALSE)

# # Calculate PR
#
#         precision_recall <- performance(performance, "prec", "rec")
#
# # Calculate Brier score
#
#         brier <- brier(test_DV_civil_ns, prediction)
#
#         brier_obs <- data.frame(brier$bs)
#
#
# # Calculate maximum F1 score
#
#         f1 <- performance(performance,"f")
#         f1_vals <- na.omit(as.numeric(unlist(f1@y.values)))
#         f1_max <- max(f1_vals)
#
#
# Export predicted probabilities

country <- as.vector(test$country_iso3)
year <- as.vector(test$year)
month <- as.vector(test$month)
period <- as.vector(test$period)
incidence_civil_ns <- as.vector(test$incidence_civil_ns)
incidence_civil_ns_plus1 <- as.vector(test$incidence_civil_ns_plus1)

pred_avg_inc_civil_ns <- data.frame(cbind(country, year, month, period,
                                          incidence_civil_ns, incidence_civil_ns_plus1,
                                          prediction))

colnames(pred_avg_inc_civil_ns) <- c("country", "year", "month", "period",
                                     "incidence_civil_ns", "incidence_civil_ns_plus1",
                                     "prediction")

# Store predictions and ROC curves

AUCs_avg <- AUCs
prediction_avg_inc_civil_ns <- prediction
# prediction_robust_maxnodes_avg_inc_civil_ns <- prediction_robust_maxnodes
# prediction_robust_sampsize_avg_inc_civil_ns <- prediction_robust_sampsize
# prediction_robust_ntree_avg_inc_civil_ns <- prediction_robust_ntree
# prediction_robust_traintest1_avg_inc_civil_ns <- prediction_robust_traintest1
# prediction_robust_traintest2_avg_inc_civil_ns <- prediction_robust_traintest2
# prediction_robust_traintest3_avg_inc_civil_ns <- prediction_robust_traintest3
# prediction_robust_civil_ns_alt1_avg_inc_civil_ns <- prediction_robust_civil_ns_alt1
# prediction_robust_civil_ns_alt2_avg_inc_civil_ns <- prediction_robust_civil_ns_alt2
roc_avg_inc_civil_ns <- roc
roc_noSmooth_avg_inc_civil_ns <- roc
# precision_recall_avg_inc_civil_ns <- precision_recall
# brier_obs_avg_inc_civil_ns <- brier_obs
# RF_ranking_avg_inc_civil_ns <- RF_ranking
# f1_max_avg_inc_civil_ns <- f1_max
#
