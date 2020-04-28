

			clear

			
			use "data/1mo_data.dta", clear

			

			gl escalation1 ///
				gov_opp_low_level opp_gov_low_level gov_reb_low_level reb_gov_low_level

			gl escalation2 ///
				gov_opp_nonviol_repression gov_reb_nonviol_repression ///
				gov_opp_accommodations gov_reb_accommodations ///
				reb_gov_demands opp_gov_demands

			gl quad ///
      			gov_opp_vercf gov_reb_vercf ///
				gov_opp_matcf gov_reb_matcf ///
				opp_gov_vercf reb_gov_vercf ///
				opp_gov_matcf reb_gov_matcf ///
				gov_opp_vercp gov_reb_vercp ///
				gov_opp_matcp gov_reb_matcp ///
				opp_gov_vercp reb_gov_vercp ///
				opp_gov_matcp reb_gov_matcp
				
			gl goldstein ///
				gov_opp_gold gov_reb_gold ///
    			opp_gov_gold reb_gov_gold
	
	
	
	
	* Generate descriptive statistics
	
			cap matrix drop escalation
	
			foreach x of varlist $escalation1 $escalation2 {
					qui sum `x', d
						scalar mean_`x' = r(mean)
						scalar medi_`x' = r(p50)
						scalar min_`x' = r(min)
						scalar max_`x' = r(max)
						scalar sd_`x' = r(sd)
						scalar skew_`x' = r(skewness)
						mat m`x' = (mean_`x' , medi_`x' , min_`x' , max_`x' , sd_`x' , skew_`x')
						mat list m`x'
					}
				
			foreach x of varlist $escalation1 $escalation2 {	
 				matrix escalation = nullmat(escalation) \ m`x'
				}

			mat list escalation
			
			local cnames `" "Mean" "Median" "Min" "Max" "SD" "Skewness" "'
				display `cnames'
			
			foreach x of varlist $escalation1 $escalation2 {
				local label: var la `x'
				local rnames_escalation  `" `rnames_escalation' "`label'" "'
				}
				display `rnames_escalation'
				
			xml_tab escalation, save("tables/tableA1.xml") replace noisily cnames(`cnames') rnames(`rnames_escalation')								
				
	

	
			cap matrix drop quad
	
			foreach x of varlist $quad {
					qui sum `x', d
						scalar mean_`x' = r(mean)
						scalar medi_`x' = r(p50)
						scalar min_`x' = r(min)
						scalar max_`x' = r(max)
						scalar sd_`x' = r(sd)
						scalar skew_`x' = r(skewness)
						mat m`x' = (mean_`x' , medi_`x' , min_`x' , max_`x' , sd_`x' , skew_`x')
						mat list m`x'
					}
				
			foreach x of varlist $quad {	
 				matrix quad = nullmat(quad) \ m`x'
				}

			mat list quad
			
			local cnames `" "Mean" "Median" "Min" "Max" "SD" "Skewness" "'
				display `cnames'
			
			foreach x of varlist $quad {
				local label: var la `x'
				local rnames_quad  `" `rnames_quad' "`label'" "'
				}
				display `rnames_quad'
				
			xml_tab quad, save("tables/tableA2.xml") replace noisily cnames(`cnames') rnames(`rnames_quad')								
	
	
	
			cap matrix drop goldstein
	
			foreach x of varlist $goldstein {
					qui sum `x', d
						scalar mean_`x' = r(mean)
						scalar medi_`x' = r(p50)
						scalar min_`x' = r(min)
						scalar max_`x' = r(max)
						scalar sd_`x' = r(sd)
						scalar skew_`x' = r(skewness)
						mat m`x' = (mean_`x' , medi_`x' , min_`x' , max_`x' , sd_`x' , skew_`x')
						mat list m`x'
					}
				
			foreach x of varlist $goldstein {	
 				matrix goldstein = nullmat(goldstein) \ m`x'
				}

			mat list goldstein
			
			local cnames `" "Mean" "Median" "Min" "Max" "SD" "Skewness" "'
				display `cnames'
			
			foreach x of varlist $goldstein {
				local label: var la `x'
				local rnames_goldstein  `" `rnames_goldstein' "`label'" "'
				}
				display `rnames'
				
			xml_tab goldstein, save("tables/tableA3.xml") replace noisily cnames(`cnames') rnames(`rnames_goldstein')								
	
	
