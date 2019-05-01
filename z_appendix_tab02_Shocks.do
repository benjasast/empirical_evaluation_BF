clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Catastrophic Health Expenditures
* File Name: t07_shocks_&_CHEs
* RA: Benjamin Sas
* PI: Karen Grepin	
* Date: 13/10/18
* Version: 1			
*******************************************************************************
/* Correlogram
*/
*******************************************************************************


*******************************************************************************
* Vars
set maxvar 10000

* Directory
cdoutput
* Load Data
use e15_dataframe_with_emploi

* Relevant
keep if present_all==1
*******************************************************************************

* Passages
label define milieu 1 "Urban", modify
label define milieu 2 "Rural", modify

* Rounds
label define rounds 1 "Round 1" 2 "Round 2" 3 "Round 3" 4 "Round 4"
label values passage rounds

* Food Secure
label define foodinsecure 1 "Food Insecure" 0 "Food Secure"
label values quarter_foodinsecure_hunger foodinsecure

* Quintiles
label define quintiles 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5"
label values wealth_quintiles quintiles
label var wealth_quintiles "Quintiles of Household Wealth Score"  

* CHEs
label define che 0 "No CHEs" 1 "CHEs"
label values q_che1_10 che
label values q_che3_40 che
label values q_che5_40 che



* TO USD
replace quarter_sante = quarter_sante/ 526
replace quarter_total_consumation = quarter_total_consumation / 526
replace quarter_nonfood_consumation = quarter_nonfood_consumation / 526
replace quarter_consumation_subsistance = quarter_consumation_subsistance / 526

* Convenient Variables
egen choc_coping_sellassets = rsum(choc_coping_14 choc_coping_15 choc_coping_16 choc_coping_17)

* All shocks in one variable
gen choc_type =.
replace choc_type = 1 if choc_maladiegrave==1
replace choc_type = 2 if choc_agriculture==1
replace choc_type = 3 if choc_revenu==1
replace choc_type = 4 if choc_decede==1
replace choc_type = 5 if choc_autre==1



label define choc 1 "Health Shock" 2 "Agriculture Shock" 3 "Income Shock" 4 "Dead HH member" 5 "Other Shock"
label values choc_type choc

* All wagstaff in one variable

* For Povline 2 - National Extreme Poverty Line
gen wagstaff_type2 = 1 if quarter_immiserizing2==1
replace wagstaff_type2 = 2 if quarter_impoverishing2==1
replace wagstaff_type2 = 3 if quarter_catastrohic2==1
replace wagstaff_type2 = 4 if quarter_noncatastrophic2==1
replace wagstaff_type2 = 5 if quarter_zero2==1

label define wagstaff 1 "Immiserizing" 2 "Impoverishing" 3 "Catastrophic" 4 "Non-Catastrophic" 5 "No Health-Care Expenditures" 
label values wagstaff_type2 wagstaff

* For Povline 3 - USD 1.90
gen wagstaff_type3 = 1 if quarter_immiserizing3==1
replace wagstaff_type3 = 2 if quarter_impoverishing3==1
replace wagstaff_type3 = 3 if quarter_catastrohic3==1
replace wagstaff_type3 = 4 if quarter_noncatastrophic3==1
replace wagstaff_type3 = 5 if quarter_zero3==1

label values wagstaff_type3 wagstaff

*******************************************************************************
keep if passage==3 // That is when the shock module was recollected



******************************************************************************
*******************-----------------------------------*************************
				** 0. Calculate Percentage of Shocks  **
******************-------------------------------------***********************
*******************************************************************************

local coping_var choc_coping choc_maladiegrave choc_agriculture choc_revenu choc_decede choc_autre

local sub_coping choc_maladiegrave choc_agriculture choc_revenu choc_decede choc_autre

* Population, no wealth quintiles - for those with and without shocks
preserve

		* Pop collapse only one row
			collapse (mean) ///
				`coping_var' ///
				[pweight=hhweight]
				

			* Rate of the population with any shock
			scalar YES_percent_choc_coping_0 = choc_coping[1]
			* Rate of population reporting no shock at all
			scalar NO_percent_choc_coping_0 = 1 - choc_coping[1]
			
			
		* Looop over other variables
		foreach var in `sub_coping'{
			* Rate in the population for specific shock
			scalar percent_`var'_0 = `var'[1]
		}
		
restore

* Population by wealth quintile

preserve

		* Pop by wealth quintile
			collapse (mean) ///
				`coping_var' ///
				[pweight=hhweight] ///
				,by(wealth_quintiles)
				
		
	* Loop wealth quintile
	forvalues q = 1/5{
		* Rate of population with any shock by quintile
			scalar YES_percent_choc_coping_`q' = choc_coping[`q']
		* Rate of population with no shock by quintile		
			scalar NO_percent_choc_coping_`q' = 1- choc_coping[`q']
			
		
		* Rate of population with any shock by quintile, all other vars
		foreach var in `sub_coping'{
			scalar percent_`var'_`q' = `var'[`q']
		
		
		
		}
			
			
	}	
			
			
				
restore






******************************************************************************
*******************-----------------------------------*************************
				** I. Calculate Rates of CHEs for Reporting Shocks  **
******************-------------------------------------***********************
*******************************************************************************
preserve

		* Pop collapse only one row
			collapse (mean) ///
				q* ///
				[pweight=hhweight] ///
				, by(choc_coping)


		
		
*-------------------------------------------------------------------------------------*
*1.1 Rates for Any kind of shock - or no shock reported at all
*-------------------------------------------------------------------------------------*				
				
	* Loop over all relevant che_variables
		local che_type "1_10 3_40 5_40"
			
			foreach type in `che_type'{
					
			* Rate of CHEs for those without any shock
				scalar NOchoc_coping_che`type'_0 = q_che`type'[1]
					
			* Rate of CHEs for those with the shock
				scalar YESchoc_coping_che`type'_0 = q_che`type'[2]
			}
			
			* Impoverishing
				scalar NOchoc_coping_impov_0 = 	quarter_impoverishing3[1]
				scalar YESchoc_coping_impov_0 = 	quarter_impoverishing3[2]


restore		
		
*-------------------------------------------------------------------------------------*
*1.2 Rates for all other shocks - Only if has shock
*-------------------------------------------------------------------------------------*			

* CHE TYPES
local che_type "1_10 3_40 5_40"

* Variables to loop
local coping_var choc_maladiegrave choc_agriculture choc_revenu choc_decede choc_autre


	foreach var in `coping_var'{
		preserve
		* Pop collapse only one row
			collapse (mean) ///
				q* ///
				[pweight=hhweight] ///
				, by(`var')
		
		* Only positives
		keep if `var'==1

		foreach type in `che_type'{
			
			scalar choc_`var'_che`type'_0 = q_che`type'[1]
		
		
		
		}
		
		* Impoverishing
			scalar choc_`var'_impov_0 = quarter_impoverishing3[1]
		
		
		restore
	}



		
		
		
		



	
*-------------------------------------------------------------------------------------*
*1.3 Rates for Any kind of shock - or no shock by wealth Quintile
*-------------------------------------------------------------------------------------*			


			* Pop collapse only one row
			collapse (mean) ///
			q* ///
			[pweight=hhweight] ///
			, by(choc_coping wealth_quintiles)


	* Loop over all relevant che_variables
		local che_type "1_10 3_40 5_40"

* Those not Coping		
preserve
keep if choc_coping==0
	
	foreach type in `che_type'{
	
		forvalues q = 1/5{
		* Rate of CHEs for those without any shock
				scalar NOchoc_coping_che`type'_`q' = q_che`type'[`q']
		
		}
		
	}
	
	* Impoverishing
		forvalues q = 1/5{
				scalar NOchoc_coping_impov_`q' = quarter_impoverishing3[`q']
					}					
restore



* Those Coping	
preserve
keep if choc_coping==1
	
	foreach type in `che_type'{
	
		forvalues q = 1/5{
		* Rate of CHEs for those without any shock
				scalar YESchoc_coping_che`type'_`q' = q_che`type'[`q']
		
		}
	}
	
	* Impoverishing
		forvalues q = 1/5{
				scalar YESchoc_coping_impov_`q' = quarter_impoverishing3[`q']
					}		
	
					
restore


		
*-------------------------------------------------------------------------------------*
*1.4 Rates for all shocks by wealth quintile
*-------------------------------------------------------------------------------------*
	
* Have to reload dataset unfortunately
clear
* Load Data
use e15_dataframe_with_emploi
* Relevant
keep if present==1
* Round
keep if passage==3

* Variables to loop 
local coping_var choc_maladiegrave choc_agriculture choc_revenu choc_decede choc_autre
local che_type "1_10 3_40 5_40"

foreach var in `coping_var'{
	preserve
	
		* Pop collapse only one row
			collapse (mean) ///
			q* ///
			[pweight=hhweight] ///
			, by(`var' wealth_quintiles)

	
	foreach type in `che_type'{
	keep if `var'==1

		* CHE rates for households with the shock
			* Loop over quintiles
			forvalues q = 1/5{
				scalar choc_`var'_che`type'_`q' = q_che`type'[`q']
			}
	}
	
	* Impoverishing
		forvalues q = 1/5{
			scalar choc_`var'_impov_`q' = quarter_impoverishing3[`q']
		
		}
	
	
	restore
}



******************************************************************************
*******************-----------------------------------*************************
				** II. FPIs for Different Shocks  **
******************-------------------------------------***********************
*******************************************************************************

	
*-------------------------------------------------------------------------------------*
*2.1 FPI for Any kind of shock - or no shock reported at all
*-------------------------------------------------------------------------------------*				
preserve

			* Pop collapse only one row
			collapse (mean) ///
				q* ///
				[pweight=hhweight] ///
				, by(choc_coping)

* Create FPI for poverty lines
local povlines "2 3"

foreach num in `povlines'{
	gen fpi`num' = quarter_immiserizing`num' + 2*quarter_impoverishing`num' + 3*quarter_noncatastrophic`num' + 4*quarter_zero`num'
		replace fpi`num' = fpi`num'*10


		* FPI for those with and without any shock
		scalar NOchoc_coping_fpi_povline`num'_0 	= 	quarter_vulnerable`num'[1]
		scalar YESchoc_coping_fpi_povline`num'_0 	= 	quarter_vulnerable`num'[2]

}


restore
		
*-------------------------------------------------------------------------------------*
*2.2 FPI for all other shocks - Only if has shock
*-------------------------------------------------------------------------------------*			

local coping_var choc_maladiegrave choc_agriculture choc_revenu choc_decede choc_autre
local povlines "2 3"


foreach var in `coping_var'{
	preserve

				* Pop collapse only for one shock
				collapse (mean) ///
					q* ///
					[pweight=hhweight] ///
					, by(`var')

			keep if `var'==1
			
			
	foreach num in `povlines'{
		gen fpi`num' = quarter_immiserizing`num' + 2*quarter_impoverishing`num' + 3*quarter_noncatastrophic`num' + 4*quarter_zero`num'
			replace fpi`num' = fpi`num'*10


			* FPI Rate for those with the shock
			scalar `var'_fpi_povline`num'_0 = 	quarter_vulnerable`num'[1]

	}
	restore	
}


*-------------------------------------------------------------------------------------*
*2.3 FPI for Any kind of shock - or no shock reported at all - for wealth quintile
*-------------------------------------------------------------------------------------*	

preserve

			* Pop collapse only one row
			collapse (mean) ///
				q* ///
				[pweight=hhweight] ///
				, by(choc_coping wealth_quintile)
				
				
* Create FPI for poverty lines
local povlines "2 3"

foreach num in `povlines'{
	gen fpi`num' = quarter_immiserizing`num' + 2*quarter_impoverishing`num' + 3*quarter_noncatastrophic`num' + 4*quarter_zero`num'
		replace fpi`num' = fpi`num'*10


		* FPI for those with and without any shock
		
		* Loop over quintiles
			forvalues q = 1/5{
				scalar NOchoc_coping_fpi_povline`num'_`q' 	= 	quarter_vulnerable`num'[`q']
				local q2 = `q' + 5
				scalar YESchoc_coping_fpi_povline`num'_`q' 	= 	quarter_vulnerable`num'[`q2']
		}
}
			

restore



*-------------------------------------------------------------------------------------*
*2.4 FPI for any shock (only positive)- for wealth quintile
*-------------------------------------------------------------------------------------*	

local coping_var choc_maladiegrave choc_agriculture choc_revenu choc_decede choc_autre
local povlines "2 3"

foreach var in `coping_var'{
	preserve

				* Pop collapse only one row
				collapse (mean) ///
					q* ///
					[pweight=hhweight] ///
					, by(`var' wealth_quintile)
					

	* Keep positive
	keep if `var'==1				
					
	* Create FPI for poverty lines
	local povlines "2 3"

	foreach num in `povlines'{
		gen fpi`num' = quarter_immiserizing`num' + 2*quarter_impoverishing`num' + 3*quarter_noncatastrophic`num' + 4*quarter_zero`num'
			replace fpi`num' = fpi`num'*10

		
		forvalues q = 1/5{
			scalar `var'_fpi_povline`num'_`q' = quarter_vulnerable`num'[`q']
		
		}
			
			
			
			
	}
	restore
}


******************************************************************************
*******************-----------------------------------*************************
						** III. Store in Matrix **
******************-------------------------------------***********************
*******************************************************************************


matrix Table2 = J(49,6,.)


matrix rownames Table2 = ///
	CHE1_10NOSHOCK CHE1_10ANYSHOCK HealthShock AgShock IncomeShock DeathShock OtherShock ///
	CHE3_40NOSHOCK CHE3_40ANYSHOCK HealthShock AgShock IncomeShock DeathShock OtherShock ///
	CHE5_40NOSHOCK CHE5_40ANYSHOCK HealthShock AgShock IncomeShock DeathShock OtherShock ///
	POVLINE2_NOSHOCK POVLINE2_SHOCK HealthShock AgShock IncomeShock DeathShock OtherShock ///
	POVLINE3_NOSHOCK POVLINE3_SHOCK HealthShock AgShock IncomeShock DeathShock OtherShock ///
	PERNOSHOCK PERANYSHOCK HealthShock AgShock IncomeShock DeathShock OtherShock ///
	IMPOV_NOSHOCK IMPOV_ANYSHOCK HealthShock AgShock IncomeShock DeathShock OtherShock



matrix colnames Table2 = Pop Q1 Q2 Q3 Q4 Q5



mat list Table2





*-------------------------------------------------------------------------------------*
*3.1 Put Scalars in Matrix
*-------------------------------------------------------------------------------------*

* Row indicator
local z = 1

local coping_var choc_maladiegrave choc_agriculture choc_revenu choc_decede choc_autre
local che_type "1_10 3_40 5_40"
local povlines "2 3"


* NORMAL CHES
foreach type in `che_type'{

	* Input Shock or no shock
		forvalues q = 0/5{
			local q2 = `q' + 1
			
			* No shock at all
			mat Table2[`z',`q2'] = NOchoc_coping_che`type'_`q'
			* Shock
			local z2 = `z' + 1
			mat Table2[`z2',`q2'] = YESchoc_coping_che`type'_`q'
		}
		local z = `z' + 2

	* Input all other shocks
	local coping_var choc_maladiegrave choc_agriculture choc_revenu choc_decede choc_autre

	foreach var in `coping_var'{

		forvalues q = 0/5{
			local q2 = `q' + 1
			mat Table2[`z',`q2'] = choc_`var'_che`type'_`q'
		}
		* Go next row
		local z = `z'+1
	}
}


* WAGSTAFF
foreach num in `povlines'{

	* Input Shock or no shock
		forvalues q = 0/5{
			local q2 = `q' + 1
			
			* No shock at all
			mat Table2[`z',`q2'] = NOchoc_coping_fpi_povline`num'_`q'
			
			* Shock
			local z2 = `z' + 1
			mat Table2[`z2',`q2'] = YESchoc_coping_fpi_povline`num'_`q'
		}
		local z = `z' + 2

	* Input all other shocks
	local coping_var choc_maladiegrave choc_agriculture choc_revenu choc_decede choc_autre

	foreach var in `coping_var'{

		forvalues q = 0/5{
			local q2 = `q' + 1
			mat Table2[`z',`q2'] = `var'_fpi_povline`num'_`q'
		}
		* Go next row
		local z = `z'+1
	}
}


* Percentage of shocks for those with any or no shock
forvalues q = 0/5{
	local q2 = `q' + 1
	local z2 = `z' + 1
		
		mat Table2[`z' , `q2'] = NO_percent_choc_coping_`q'
		mat Table2[`z2' , `q2'] = YES_percent_choc_coping_`q'
		
}
local z = `z' + 2

* Percentage of shock for all categories

	local coping_var choc_maladiegrave choc_agriculture choc_revenu choc_decede choc_autre

	foreach var in `coping_var'{

		forvalues q = 0/5{
			local q2 = `q' + 1
			mat Table2[`z',`q2'] = percent_`var'_`q'
		}
		* Go next row
		local z = `z'+1
	}



* IMPOV


	* Input Shock or no shock
		forvalues q = 0/5{
			local q2 = `q' + 1
			
			* No shock at all
			mat Table2[`z',`q2'] = NOchoc_coping_impov_`q'
			* Shock
			local z2 = `z' + 1
			mat Table2[`z2',`q2'] = YESchoc_coping_impov_`q'
		}
		local z = `z' + 2

	* Input all other shocks
	local coping_var choc_maladiegrave choc_agriculture choc_revenu choc_decede choc_autre

	foreach var in `coping_var'{

		forvalues q = 0/5{
			local q2 = `q' + 1
			mat Table2[`z',`q2'] = scalar(choc_`var'_impov_`q')
		}
		* Go next row
		local z = `z'+1
	}	
	

mat list Table2






*-------------------------------------------------------------------------------------*
*3.2 Export table
*-------------------------------------------------------------------------------------*


* Directory
cdtables

* Excel
putexcel set Table7_shocks_CHEs.xlsx, replace
putexcel A1 = mat(Table2), rownames		


	





