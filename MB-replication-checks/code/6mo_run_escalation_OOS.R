##############################
# RHS = escalation_6mo 
# DV = incidence_civil_ns_plus1
# model = randomForest
##############################

			# Run random forests models			
				         
      				train_model <- randomForest(escalation_6mo_train_formula_civil_ns,
      												  type = regression, importance = TRUE, 
      												  na.action = na.omit, ntree = 100000, maxnodes = 5, 
      												  sampsize = 100, 
      												  replace = FALSE, do.trace = FALSE , 
      												  data = escalation_6mo_train_frame_civil_ns, forest = TRUE   
      												  )			         
    				
			# Generate out-of-sample predictions
				
      				prediction <- as.numeric(predict(train_model, newdata = data.matrix(escalation_6mo_test_frame_civil_ns), type="response"))      								

      # Export predicted probabilities

              country <- as.vector(test$country_iso3)
              year <- as.vector(test$year)
              period <- as.vector(test$period)
              incidence_civil_ns <- as.vector(test$incidence_civil_ns)
              incidence_civil_ns_plus1 <- as.vector(test$incidence_civil_ns_plus1)
      
              pred_escalation_6mo_inc_civil_ns <- data.frame(cbind(country, year, period,
                                                      incidence_civil_ns, incidence_civil_ns_plus1,
                                                      prediction))
    
              colnames(pred_escalation_6mo_inc_civil_ns) <- c("country", "year", "period",
                                                         "incidence_civil_ns", "incidence_civil_ns_plus1",
                                                        "prediction")
    
              
