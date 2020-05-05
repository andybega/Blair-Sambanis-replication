
        	# Run random forests model for high-risk split

        			train_model_highriskPITF <- randomForest(escalation_6mo_highriskPITF_train_formula_civil_ns,
    												  type = regression, importance = TRUE,
    												  na.action = na.omit, ntree = 10000, maxnodes = 5,
    												  sampsize = 100,
    												  replace = FALSE, do.trace = FALSE ,
    												  data = escalation_6mo_highriskPITF_train_frame_civil_ns, forest = TRUE
    												  )

      		# Run random forests model for low-risk split

        			train_model_lowriskPITF <- randomForest(escalation_6mo_lowriskPITF_train_formula_civil_ns,
    												  type = regression, importance = TRUE,
    												  na.action = na.omit, ntree = 10000, maxnodes = 5,
    												  sampsize = 100,
    												  replace = FALSE, do.trace = FALSE ,
    												  data = escalation_6mo_lowriskPITF_train_frame_civil_ns, forest = TRUE
    												  )

      		# Combine random forests models for high-risk and low-risk splits

           		 	train_model <- combine(train_model_highriskPITF, train_model_lowriskPITF)


		    	# Generate out-of-sample predictions

    				    prediction <- as.numeric(predict(train_model, newdata = data.matrix(escalation_6mo_splitPITF_test_frame_civil_ns), type="response"))
       			    	prediction[is.na(escalation_6mo_splitPITF_test_frame_civil_ns$test_DV_civil_ns)] <- NA



			# Calculate AUC

    				performance <- prediction(prediction, test_DV_civil_ns)
              			roc <- roc(test_DV_civil_ns, prediction, smooth=TRUE, auc = TRUE)
    				    	AUC_obs <- data.frame(as.numeric(roc$auc))


			# Compile AUCs

             		AUCs_escalation_6mo_split_PITF <- AUC_obs

AUCs <- data.frame(specification = "escalation with Split PITF", horizon = "6 months",
                smoothed = as.numeric(AUC_obs), original = as.numeric(AUC_obs_noSmooth))
write.csv(AUCs, "tables/PITF/AUCs-6mo-escalation-split-PITF.csv")

