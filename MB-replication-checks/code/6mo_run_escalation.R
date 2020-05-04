
# Run random forests models


train_model <- randomForest(escalation_6mo_train_formula_civil_ns,
                            type = regression, importance = TRUE,
                            na.action = na.omit, ntree = 100000, maxnodes = 5,
                            sampsize = 100,
                            replace = FALSE, do.trace = FALSE ,
                            data = escalation_6mo_train_frame_civil_ns, forest = TRUE
)

#   			train_model_robust_maxnodes <- randomForest(escalation_6mo_train_formula_civil_ns,
# 												  type = regression, importance = TRUE,
# 												  na.action = na.omit, ntree = 100000, maxnodes = 10,
# 												  sampsize = 100,
# 												  replace = FALSE, do.trace = FALSE ,
# 												  data = escalation_6mo_train_frame_civil_ns, forest = TRUE
# 												  )
#
#     		train_model_robust_sampsize <- randomForest(escalation_6mo_train_formula_civil_ns,
# 												  type = regression, importance = TRUE,
# 												  na.action = na.omit, ntree = 100000, maxnodes = 5,
# 												  sampsize = 500,
# 												  replace = FALSE, do.trace = FALSE ,
# 												  data = escalation_6mo_train_frame_civil_ns, forest = TRUE
# 												  )
#
#   			train_model_robust_ntree <- randomForest(escalation_6mo_train_formula_civil_ns,
# 												  type = regression, importance = TRUE,
# 												  na.action = na.omit, ntree = 1000000, maxnodes = 5,
# 												  sampsize = 100,
# 												  replace = FALSE, do.trace = FALSE ,
# 												  data = escalation_6mo_train_frame_civil_ns, forest = TRUE
# 												  )
#
#     		train_model_robust_traintest1 <- randomForest(escalation_6mo_train_formula_civil_ns_robust_traintest1,
# 												  type = regression, importance = TRUE,
# 												  na.action = na.omit, ntree = 100000, maxnodes = 5,
# 												  sampsize = 100,
# 												  replace = FALSE, do.trace = FALSE ,
# 												  data = escalation_6mo_train_frame_civil_ns_robust_traintest1, forest = TRUE
# 												  )
#
#     		train_model_robust_traintest2 <- randomForest(escalation_6mo_train_formula_civil_ns_robust_traintest2,
#     		                  type = regression, importance = TRUE,
#     		                  na.action = na.omit, ntree = 100000, maxnodes = 5,
#     		                  sampsize = 100,
#     		                  replace = FALSE, do.trace = FALSE ,
#     		                  data = escalation_6mo_train_frame_civil_ns_robust_traintest2, forest = TRUE
#     		                  )
#
#     		train_model_robust_traintest3 <- randomForest(escalation_6mo_train_formula_civil_ns_robust_traintest3,
#     		                  type = regression, importance = TRUE,
#     		                  na.action = na.omit, ntree = 100000, maxnodes = 5,
#     		                  sampsize = 100,
#     		                  replace = FALSE, do.trace = FALSE ,
#     		                  data = escalation_6mo_train_frame_civil_ns_robust_traintest3, forest = TRUE
#     		                  )
#
#       	train_model_robust_civil_ns_alt1 <- randomForest(escalation_6mo_train_formula_civil_ns_alt1,
#       	                  type = regression, importance = TRUE,
#       	                  na.action = na.omit, ntree = 100000, maxnodes = 5,
#       	                  sampsize = 100,
#       	                  replace = FALSE, do.trace = FALSE ,
#       	                  data = escalation_6mo_train_frame_civil_ns_alt1, forest = TRUE
#       	                  )
#
#       	train_model_robust_civil_ns_alt2 <- randomForest(escalation_6mo_train_formula_civil_ns_alt2,
#       	                  type = regression, importance = TRUE,
#       	                  na.action = na.omit, ntree = 100000, maxnodes = 5,
#       	                  sampsize = 100,
#       	                  replace = FALSE, do.trace = FALSE ,
#       	                  data = escalation_6mo_train_frame_civil_ns_alt2, forest = TRUE
#       	                  )

# Extract importance scores

importance_scores <- data.frame(train_model["importance"][[1]][,1])

# Sort importance scores

RF_ranking = matrix(NA,nrow=length(escalation_6mo_train_RHS), ncol=1)
RF_ranking[order(matrix(importance_scores[,1], ncol=1),
                 decreasing=TRUE)]<- seq(1,length(order(matrix(importance_scores[,1], ncol=1),
                                                        decreasing=TRUE)),1)
RF_ranking <- data.frame(RF_ranking,importance_scores)
colnames(RF_ranking) <- c("Rank","Importance score")
rownames(RF_ranking) <- escalation_6mo
RF_ranking <- data.frame(RF_ranking)


# Generate out-of-sample predictions

prediction <- as.numeric(predict(train_model, newdata = data.matrix(escalation_6mo_test_frame_civil_ns), type="response"))
prediction[is.na(escalation_6mo_test_frame_civil_ns$test_DV_civil_ns)] <- NA

#   			prediction_robust_maxnodes <- as.numeric(predict(train_model_robust_maxnodes, newdata = data.matrix(escalation_6mo_test_frame_civil_ns), type="response"))
# 				  prediction_robust_maxnodes[is.na(escalation_6mo_test_frame_civil_ns$test_DV_civil_ns)] <- NA
#
#       	prediction_robust_sampsize <- as.numeric(predict(train_model_robust_sampsize, newdata = data.matrix(escalation_6mo_test_frame_civil_ns), type="response"))
# 				  prediction_robust_sampsize[is.na(escalation_6mo_test_frame_civil_ns$test_DV_civil_ns)] <- NA
#
#       	prediction_robust_ntree <- as.numeric(predict(train_model_robust_ntree, newdata = data.matrix(escalation_6mo_test_frame_civil_ns), type="response"))
# 				  prediction_robust_ntree[is.na(escalation_6mo_test_frame_civil_ns$test_DV_civil_ns)] <- NA
#
#         prediction_robust_traintest1 <- as.numeric(predict(train_model_robust_traintest1, newdata = data.matrix(escalation_6mo_test_frame_civil_ns_robust_traintest1), type="response"))
# 				  prediction_robust_traintest1[is.na(escalation_6mo_test_frame_civil_ns_robust_traintest1$test_DV_civil_ns_robust_traintest1)] <- NA
#
# 				prediction_robust_traintest2 <- as.numeric(predict(train_model_robust_traintest2, newdata = data.matrix(escalation_6mo_test_frame_civil_ns_robust_traintest2), type="response"))
# 				  prediction_robust_traintest2[is.na(escalation_6mo_test_frame_civil_ns_robust_traintest2$test_DV_civil_ns_robust_traintest2)] <- NA
#
# 				prediction_robust_traintest3 <- as.numeric(predict(train_model_robust_traintest3, newdata = data.matrix(escalation_6mo_test_frame_civil_ns_robust_traintest3), type="response"))
# 				  prediction_robust_traintest3[is.na(escalation_6mo_test_frame_civil_ns_robust_traintest3$test_DV_civil_ns_robust_traintest3)] <- NA
#
# 				prediction_robust_civil_ns_alt1 <- as.numeric(predict(train_model_robust_civil_ns_alt1, newdata = data.matrix(escalation_6mo_test_frame_civil_ns_alt1), type="response"))
# 				  prediction_robust_civil_ns_alt1[is.na(escalation_6mo_test_frame_civil_ns_alt1$test_DV_civil_ns_alt1)] <- NA
#
# 				prediction_robust_civil_ns_alt2 <- as.numeric(predict(train_model_robust_civil_ns_alt2, newdata = data.matrix(escalation_6mo_test_frame_civil_ns_alt2), type="response"))
# 				  prediction_robust_civil_ns_alt2[is.na(escalation_6mo_test_frame_civil_ns_alt2$test_DV_civil_ns_alt2)] <- NA

# Calculate AUC

performance <- prediction(prediction, test_DV_civil_ns)
roc <- roc(test_DV_civil_ns, prediction, smooth=TRUE, auc = TRUE)
saveRDS(roc, "figures/roc-6mo-escalation.rds")
AUC_obs <- data.frame(as.numeric(roc$auc))

## RM: ADDED 4/29/2020
roc_noSmooth <- roc(test_DV_civil_ns, prediction, smooth=FALSE, auc = TRUE)
saveRDS(roc_noSmooth, "figures/non-smooth-roc-6mo-escalation.rds")
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

# 			# Compile AUCs
#
#               AUCs <- as.matrix(c(AUC_obs, AUC_obs_robust_maxnodes, AUC_obs_robust_sampsize,
#                                   AUC_obs_robust_ntree, AUC_obs_robust_traintest1, AUC_obs_robust_traintest2,
#                                      AUC_obs_robust_traintest3, AUC_obs_robust_civil_ns_alt1, AUC_obs_robust_civil_ns_alt2))

## RM: ADDED 4/29/2020
# keep track of both smoothed and original AUC ROC; write a table with these
# intermediate results so that Table 1 can be reconstructed later without having
# to re-run all of the model scripts.
AUCs <- as.matrix(c(AUC_obs, AUC_obs_noSmooth))

tbl <- data.frame(
  model = "base specification",
  specification = "escalation",
  horizon = "6 month",
  smoothed = unname(AUC_obs),
  original = unname(AUC_obs_noSmooth)
)
write.csv(tbl, "tables/auc-6mo-escalation.csv", row.names = FALSE)

# Calculate PR

precision_recall <- performance(performance, "prec", "rec")

# Calculate Brier score

brier <- brier(test_DV_civil_ns, prediction)

brier_obs <- data.frame(brier$bs)


# Calculate maximum F1 score

f1 <- performance(performance,"f")
f1_vals <- na.omit(as.numeric(unlist(f1@y.values)))
f1_max <- max(f1_vals)


# Export predicted probabilities

country <- as.vector(test$country_iso3)
year <- as.vector(test$year)
period <- as.vector(test$period)
incidence_civil_ns <- as.vector(test$incidence_civil_ns)
incidence_civil_ns_plus1 <- as.vector(test$incidence_civil_ns_plus1)

pred_escalation_6mo_inc_civil_ns <- data.frame(cbind(country, year, period,
                                                     incidence_civil_ns, incidence_civil_ns_plus1,
                                                     prediction))

colnames(pred_escalation_6mo_inc_civil_ns) <- c("country", "year",  "period",
                                                "incidence_civil_ns", "incidence_civil_ns_plus1",
                                                "prediction")

# Rename and store performance and predictions

AUCs_escalation_6mo <- AUCs
prediction_escalation_6mo_inc_civil_ns <- prediction
# prediction_robust_maxnodes_escalation_6mo_inc_civil_ns <- prediction_robust_maxnodes
# prediction_robust_sampsize_escalation_6mo_inc_civil_ns <- prediction_robust_sampsize
# prediction_robust_ntree_escalation_6mo_inc_civil_ns <- prediction_robust_ntree
# prediction_robust_traintest1_escalation_6mo_inc_civil_ns <- prediction_robust_traintest1
# prediction_robust_traintest2_escalation_6mo_inc_civil_ns <- prediction_robust_traintest2
# prediction_robust_traintest3_escalation_6mo_inc_civil_ns <- prediction_robust_traintest3
# prediction_robust_civil_ns_alt1_escalation_6mo_inc_civil_ns <- prediction_robust_civil_ns_alt1
# prediction_robust_civil_ns_alt2_escalation_6mo_inc_civil_ns <- prediction_robust_civil_ns_alt2
roc_escalation_6mo_inc_civil_ns <- roc
roc_noSmooth_escalation_6mo_inc_civil_ns <- roc_noSmooth
# precision_recall_escalation_6mo_inc_civil_ns <- precision_recall
# brier_obs_escalation_6mo_inc_civil_ns <- brier_obs
# RF_ranking_escalation_6mo_inc_civil_ns <- RF_ranking
# f1_max_escalation_6mo_inc_civil_ns <- f1_max
