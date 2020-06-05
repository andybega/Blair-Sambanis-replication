
      # Weight predicted probabilities from escalation model

            weight <- as.numeric(train$pred_prob_plus1)
            length(weight) <- length(prediction_escalation_inc_civil_ns)
            
            prediction = prediction_escalation_inc_civil_ns*weight
            prediction[is.na(escalation_test_frame_civil_ns$test_DV_civil_ns)] <- NA


			# Calculate AUC
			
    				performance <- port$prediction(prediction, test_DV_civil_ns)
              roc <- roc(test_DV_civil_ns, prediction, smooth=TRUE, auc = TRUE)
    				    AUC_obs <- data.frame(as.numeric(roc$auc))


			# Compile AUCs
              
              AUCs_escalation_weighted_PITF <- AUC_obs


