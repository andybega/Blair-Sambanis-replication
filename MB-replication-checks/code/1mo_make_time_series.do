

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
	
	
			gl plots ///
				gov_opp_low_level opp_gov_low_level gov_reb_low_level reb_gov_low_level ///
				gov_opp_nonviol_repression gov_reb_nonviol_repression ///
				gov_opp_accommodations gov_reb_accommodations ///
				reb_gov_demands opp_gov_demands
		
	
	
	
	* Generate time series plots for countries with civil war onsets after 2001
		
				la define periods 1 "2001" 13 "2002" 25 "2003" 37 "2004" 49 "2005" 61 "2006" 73 "2007" 85 "2008" 97 "2009" 109 "2010" 121 "2011" 133 "2012" 145 "2013" 157 "2014" 169 "2015" 181 "2016"
				la values period periods
				
				graph set window fontface "Times"
			
				bys country_num: egen incidence_civil_ns_max=max(incidence_civil_ns)
					tab country_iso3 if incidence_civil_ns_max==1
			
					
			* Make Figure A1 (Georgia)

				foreach x of varlist $escalation1 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 50 `=92' 50 `=93', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="GEO", lc(black) lpattern(solid)), ///
							yscale(range(0(10)50)) ylab(0(10)50, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

				foreach x of varlist $escalation2 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 10 `=92' 10 `=93', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="GEO", lc(black) lpattern(solid)), ///
							yscale(range(0(2)10)) ylab(0(2)10, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			
							
					graph combine $plots, col(2) graphr(color(white)) imargin(small) name(GEO, replace)
					graph export "figures/figureA1.pdf", as(pdf) replace
		
		
		

			* Make Figure A2 (Nigeria)

				foreach x of varlist $escalation1 $escalation2 {
					summ `x' if country_iso3=="NGA"
					}
				
				foreach x of varlist $escalation1 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 75 `=103' 75 `=180', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="NGA", lc(black) lpattern(solid)), ///
							yscale(range(0(25)75)) ylab(0(25)75, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

				foreach x of varlist $escalation2 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 10 `= 103' 10 `=180', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="NGA", lc(black) lpattern(solid)), ///
							yscale(range(0(2)10)) ylab(0(2)10, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

					graph combine $plots, col(2) graphr(color(white)) imargin(small) name(NGA, replace)
					graph export "figures/figureA2.pdf", as(pdf) replace

					
					

			* Make Figure A3 (Yemen)

				foreach x of varlist $escalation1 $escalation2 {
					summ `x' if country_iso3=="YEM"
					}
				
				foreach x of varlist $escalation1 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 100 `=42' 100 `=110', bcolor(gs15) recast(area)) ///
						(scatteri 100 `=114' 100 `=180', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="YEM", lc(black) lpattern(solid)), ///
							yscale(range(0(50) 100)) ylab(0(50) 100, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

				foreach x of varlist $escalation2 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 10 `=42' 10 `=110', bcolor(gs15) recast(area)) ///
						(scatteri 10 `=114' 10 `=180', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="YEM", lc(black) lpattern(solid)), ///
							yscale(range(0(2)10)) ylab(0(2)10, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

					graph combine $plots, col(2) graphr(color(white)) imargin(small) name(YEM, replace)
					graph export "figures/figureA3.pdf", as(pdf) replace


					

			* Make Figure A4 (Libya)

				foreach x of varlist $escalation1 $escalation2 {
					summ `x' if country_iso3=="LBY"
					}
				
				foreach x of varlist $escalation1 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 150 `=122' 150 `=130', bcolor(gs15) recast(area)) ///
						(scatteri 150 `=138' 150 `=180', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="LBY", lc(black) lpattern(solid)), ///
							yscale(range(0(50)150)) ylab(0(50)150, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

				foreach x of varlist $escalation2 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 10 `=122' 10 `=130', bcolor(gs15) recast(area)) ///
						(scatteri 10 `=138' 10 `=180', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="LBY", lc(black) lpattern(solid)), ///
							yscale(range(0(2)10)) ylab(0(2)10, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

					graph combine $plots, col(2) graphr(color(white)) imargin(small) name(LBY, replace)
					graph export "figures/figureA4.pdf", as(pdf) replace
					
					
					
					
			* Make Figure A5 (Cote d'Ivoire)
				
				foreach x of varlist $escalation1 {
					local predictors1 "`predictors' `x'"
					gr tw ///
						(scatteri 50 `=21' 50 `=43', bcolor(gs15) recast(area)) ///
						(scatteri 50 `=122' 50 `=125', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="CIV", lc(black) lpattern(solid)), ///
							yscale(range(0(10)50)) ylab(0(10)50, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}		
	
				foreach x of varlist $escalation2 {
					local predictors2 "`predictors' `x'"
					gr tw ///
						(scatteri 10 `=21' 10 `=43', bcolor(gs15) recast(area)) ///
						(scatteri 10 `=122' 10 `=125', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="CIV", lc(black) lpattern(solid)), ///
							yscale(range(0(2)10)) ylab(0(2)10, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			
							
					graph combine $plots, col(2) graphr(color(white)) imargin(small) name(CIV, replace)
					graph export "figures/figureA5.pdf", as(pdf) replace



			* Make Figure A6 (Syria)

				foreach x of varlist $escalation1 $escalation2 {
					summ `x' if country_iso3=="SYR"
					}
				
				foreach x of varlist $escalation1 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 175 `=123' 175 `=180', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="SYR", lc(black) lpattern(solid)), ///
							yscale(range(0(50)175)) ylab(0(50)175, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

				foreach x of varlist $escalation2 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 10 `= 123' 10 `=180', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="SYR", lc(black) lpattern(solid)), ///
							yscale(range(0(2)10)) ylab(0(2)10, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

					graph combine $plots, col(2) graphr(color(white)) imargin(small) name(SYR, replace)
					graph export "figures/figureA6.pdf", as(pdf) replace



			* Figure A7 (Sudan)

				foreach x of varlist $escalation1 $escalation2 {
					summ `x' if country_iso3=="SDN"
					}
				
				foreach x of varlist $escalation1 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 50 `=1' 50 `=61', bcolor(gs15) recast(area)) ///
						(scatteri 50 `=127' 50 `=180', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="SDN", lc(black) lpattern(solid)), ///
							yscale(range(0(10)50)) ylab(0(10)50, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

				foreach x of varlist $escalation2 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 10 `=1' 10 `=61', bcolor(gs15) recast(area)) ///
						(scatteri 10 `=127' 10 `=180', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="SDN", lc(black) lpattern(solid)), ///
							yscale(range(0(2)10)) ylab(0(2)10, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

					graph combine $plots, col(2) graphr(color(white)) imargin(small) name(SDN, replace)
					graph export "figures/figureA7.pdf", as(pdf) replace
					
	

			* Make Figure A8 (Mali)

				foreach x of varlist $escalation1 $escalation2 {
					summ `x' if country_iso3=="MLI"
					}
				
				foreach x of varlist $escalation1 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 75 `=133' 75 `=180', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="MLI", lc(black) lpattern(solid)), ///
							yscale(range(0(25)75)) ylab(0(25)75, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

				foreach x of varlist $escalation2 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 10 `= 133' 10 `=180', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="MLI", lc(black) lpattern(solid)), ///
							yscale(range(0(2)10)) ylab(0(2)10, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

					graph combine $plots, col(2) graphr(color(white)) imargin(small) name(MLI, replace)
					graph export "figures/figureA8.pdf", as(pdf) replace


	
	
			* Make Figure A9 (DRC)
			
				foreach x of varlist $escalation1 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 50 `=1' 50 `=99', bcolor(gs15) recast(area)) ///
						(scatteri 50 `=137' 50 `=180', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="COD", lc(black) lpattern(solid)), ///
							yscale(range(0(10)50)) ylab(0(10)50, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

				foreach x of varlist $escalation2 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 10 `=1' 10 `=99', bcolor(gs15) recast(area)) ///
						(scatteri 10 `=137' 10 `=180', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="COD", lc(black) lpattern(solid)), ///
							yscale(range(0(2)10)) ylab(0(2)10, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

					graph combine $plots, col(2) graphr(color(white)) imargin(small) name(COD, replace)
					graph export "figures/figureA9.pdf", as(pdf) replace
					
					


			* Make Figure A10 (Ukraine)

				foreach x of varlist $escalation1 $escalation2 {
					summ `x' if country_iso3=="UKR"
					}
				
				foreach x of varlist $escalation1 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 350 `=160' 350 `=180', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="UKR", lc(black) lpattern(solid)), ///
							yscale(range(0(100)350)) ylab(0(100)350, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

				foreach x of varlist $escalation2 {
					local predictors "`predictors' `x'"
					gr tw ///
						(scatteri 10 `=160' 10 `= 174', bcolor(gs15) recast(area)) ///
						(tsline `x' if country_iso3=="UKR", lc(black) lpattern(solid)), ///
							yscale(range(0(2)10)) ylab(0(2)10, nogrid) ytitle("Frequency", margin(small)) ///
							xlab(1 "2001" 25 "2003" 49 "2005" 73 "2007" 97 "2009" 121 "2011" 145 "2013" 169 "2015") xtitle("`:var la `x''", margin(small)) ///
							name(`x', replace) legend(off) graphr(color(white))
							}			

					graph combine $plots, col(2) graphr(color(white)) imargin(small) name(UKR, replace)
					graph export "figures/figureA10.pdf", as(pdf) replace


	

	
					
