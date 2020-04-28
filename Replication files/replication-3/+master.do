
	
			clear

			gl WD "YOUR DIRECTORY"
			
			cd "$WD"

		
		* Run ranking for out-of-sample test
			
			do "code/6mo_make_ranking.do"
		
		* Create Table 3
		
			outsheet prediction_rank country_name prediction using "tables/table3.csv", comma replace

		* Run confusion matrix for out-of-sample test
		
			do "code/6mo_make_confusion_matrix.do"
			
		* Create top panel of Table 4
		
			tab2xl incidence_civil_ns prediction_bin using "tables/table4_top", col(1) row(1) replace

		* Create bottom panel of Table 4

			tab2xl incidence_civil_ns_alt prediction_bin using "tables/table4_bottom", col(1) row(1) replace
			
		* Create Tables A1 - A3
			
			do "code/1mo_make_summstats.do"
			
		* Create Figures A1 - A10
		
			do "code/1mo_make_time_series.do"
			
		
