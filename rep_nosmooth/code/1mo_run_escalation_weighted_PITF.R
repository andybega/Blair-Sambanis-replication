
# Weight predicted probabilities from escalation model

weight <- as.numeric(train$pred_prob_plus1)
length(weight) <- length(prediction_escalation_inc_civil_ns)

prediction = prediction_escalation_inc_civil_ns*weight
prediction[is.na(escalation_test_frame_civil_ns$test_DV_civil_ns)] <- NA


# Calculate AUC

performance <- prediction(prediction, test_DV_civil_ns)
roc <- roc(test_DV_civil_ns, prediction, smooth=TRUE, auc = TRUE)
AUC_obs <- data.frame(as.numeric(roc$auc))

## RM ADDED 5/4/2020
roc_noSmooth <- roc(test_DV_civil_ns, prediction, smooth = FALSE, auc = TRUE)
AUC_obs_noSmooth <- data.frame(as.numeric(roc_noSmooth$auc))

AUCs <- data.frame(specification = "escalation with PITF weights", horizon = "1 month",
smoothed = as.numeric(AUC_obs), original = as.numeric(AUC_obs_noSmooth))
write.csv(AUCs, "tables/PITF/AUCs-1mo-escalation-PITF-weights.csv")

# Compile AUCs

AUCs_escalation_weighted_PITF <- AUC_obs
