
			
			clear
			
			
			
			use "predictions/6mo_predictions_escalation_OOS.dta", clear

			
								
		* Recode variables as numeric
		
			foreach x of varlist year period incidence_civil_ns incidence_civil_ns_plus1 prediction  {
				replace `x'="" if `x'=="NA"
			}
			
			foreach x of varlist year period incidence_civil_ns incidence_civil_ns_plus1 prediction  {
				destring `x', replace
			}
		
		* Drop predictions before first half of 2016
		
			keep if period==30
		
		* Rank predicted probabilities for 2015
		
			foreach x of varlist prediction  {
				egen `x'_rank=rank(`x'), field
					foreach n of local periods {
					egen `x'_rank_`n'=rank(`x') if period==`n', field
					replace `x'_rank=`x'_rank_`n' if period==`n'
					}
				}
			
		* Reverse code country ISO3 codes

			ren country country_iso3
			
			encode country_iso3, gen(country_num)
			
			xtset country_num period
			
			do "code/define_country_codes.do"
				country_codes_reverse

		* Sort
		
			sort prediction_rank

		* Keep top 30 highest ranked countries
		
			keep if prediction_rank<=30
			

			
