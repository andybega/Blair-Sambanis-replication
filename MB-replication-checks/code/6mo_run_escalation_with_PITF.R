
			# Run random forests models			
				         
    				train_model <- randomForest(escalation_6mo_with_PITF_train_formula_civil_ns,
    												  type = regression, importance = TRUE, 
    												  na.action = na.omit, ntree = 100000, maxnodes = 5, 
    												  sampsize = 100, 
    												  replace = FALSE, do.trace = FALSE , 
    												  data = escalation_6mo_with_PITF_train_frame_civil_ns, forest = TRUE   
    												  )			         
    

			# Generate out-of-sample predictions
				
    				prediction <- as.numeric(predict(train_model, newdata = data.matrix(escalation_6mo_with_PITF_test_frame_civil_ns), type="response"))      								
       				prediction[is.na(escalation_6mo_with_PITF_test_frame_civil_ns$test_DV_civil_ns)] <- NA

 

			# Calculate AUC
			
    				performance <- prediction(prediction, test_DV_civil_ns)
              roc <- roc(test_DV_civil_ns, prediction, smooth=TRUE, auc = TRUE)
    				    AUC_obs <- data.frame(as.numeric(roc$auc))


			# Compile AUCs
              
              AUCs_escalation_6mo_with_PITF <- AUC_obs

