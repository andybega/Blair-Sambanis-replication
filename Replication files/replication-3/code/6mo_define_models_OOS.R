
    # Define model labels

    			escalation_6mo <- c(
    				"gov_opp_low_level",
    				"gov_reb_low_level",
    				"opp_gov_low_level",
    				"reb_gov_low_level",
    				"gov_opp_nonviol_repression",
    				"gov_reb_nonviol_repression",
    				"gov_opp_accommodations",
    				"gov_reb_accommodations",
    				"reb_gov_demands",
    				"opp_gov_demands"
    				)
    
    # Define predictors for base specification
    			
      			escalation_6mo_train_RHS <- train[escalation_6mo]
      			escalation_6mo_test_RHS <- test[escalation_6mo]

    # Append predictand for base specification
      				
      			escalation_6mo_train_frame_civil_ns = data.frame(train_DV_civil_ns, escalation_6mo_train_RHS)
      			escalation_6mo_test_frame_civil_ns = data.frame(test_DV_civil_ns, escalation_6mo_test_RHS)

    # Define model for base specification
      			
      			escalation_6mo_train_formula_civil_ns <- as.formula(paste("train_DV_civil_ns",paste(escalation_6mo, collapse=" + "), sep = "~", collapse=NULL))
      			escalation_6mo_test_formula_civil_ns <- as.formula(paste("test_DV_civil_ns",paste(escalation_6mo, collapse=" + "), sep = "~", collapse=NULL))



