clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Table 2 - HH Consumption and CHE rates
* File Name: t02_hhconsumption_CHErates
* RA: Benjamin Sas
* PI: Karen Grepin
* Version: 3
* Date: 29/08/18				
*******************************************************************************
/* This program will calculate catastrophic health expenditures for households
in different ways
*/
*******************************************************************************
* Directory
cdoutput
* Load Data
use e15_dataframe_with_emploi
* Set survey unit and weights
svyset menage_id [pweight=hhweight], strata(strate)
* Only Relevant Obs
keep if present_all==1
*******************************************************************************


******************************************************************************
**********************--------------------------------*************************
						** I. CHE Rates  **
************************--------------------------------***********************
*******************************************************************************
/*

CHEs: 	1. Total Expenditure
		2. Total Expenditure Excluding Health
		3. Total Expenditures - Food consumption of HH (Non-Food)
		4. Non Food Excl Health
		5. A la Ke Xu, Total - substenance consumption.

For each CHE we need:
		a. Incidence Rates
		b. Concentration Index
		c. Overshoot
		d. Mean positive overshoot
		e. Separate on rural, urban and total. Also on wealth quintiles.

*/

*----------------------------------------------------------*
*1.0 Set the parallel loop
*----------------------------------------------------------*
/* We will loop over pairs of CHE type and Thresholds specified by us
*/

* Start the Parallel Loop
local che_types  "1		3	5"
local thresholds "10	40	40"
local n : word count `che_types'

 forvalues i = 1/`n' {
  local j : word `i' of `che_types' // j is our type of CHE
  local num : word `i' of `thresholds' // num is the threshold
  di " New Loop - CHE TYPE `j' With Threshold `num'"




*--------------------------------------------------------------*
*1.1 CHEs, Overshoot,MPO Rates and CI for Population/Urban/Rural
*--------------------------------------------------------------*

foreach name in "che" "over" "mpover"{

	* On each Passage

	forvalues i = 1/4{
		
		* Population
		svy, subpop(if passage == `i'): mean q_`name'`j'_`num'
			mat aux = e(b)
				scalar q_`name'`j'_`num'_p`i'_pop = aux[1,1]

		* Rural
		svy, subpop(if passage == `i' & milieu==2): mean q_`name'`j'_`num'
				mat aux = e(b)
					scalar q_`name'`j'_`num'_p`i'_rur = aux[1,1]
				
				
		* Urban
		svy, subpop(if passage == `i' & milieu ==1): mean q_`name'`j'_`num'
			mat aux = e(b)
				scalar q_`name'`j'_`num'_p`i'_urb = aux[1,1]
		
				
	}

	* Year Data

		* Population
		svy, subpop(if present_all==1): mean y_`name'`j'_`num'
			mat aux = e(b)
				scalar q_`name'`j'_`num'_p5_pop = aux[1,1]

		* Rural
		svy, subpop(if present_all==1 & milieu==2): mean y_`name'`j'_`num'
			mat aux = e(b)
				scalar q_`name'`j'_`num'_p5_rur = aux[1,1]
				
		* Urban
		svy, subpop(if present_all==1 & milieu==1): mean y_`name'`j'_`num'
			mat aux = e(b)
				scalar q_`name'`j'_`num'_p5_urb = aux[1,1]

	}


*------------------------------------------------------------------------------------*
*1.3 Concentration Index Population/Urban/Rural by Passage
*------------------------------------------------------------------------------------*	

* Quaterly Data

forvalues i = 1/4{
	
	* Concentration Index - Population
		conindex q_che`j'_`num' if passage==`i', svy rankvar(wealth_score) bounded limits(0 1)
			scalar q_CIche`j'_`num'_p`i'_pop		= r(CI)
			scalar q_CISEche`j'_`num'_p`i'_pop 		= r(CIse)			

	* Concentration Index - Rural
		conindex q_che`j'_`num' if passage==`i' & milieu==2, svy rankvar(wealth_score) bounded limits(0 1)
			scalar q_CIche`j'_`num'_p`i'_rur		= r(CI)
			scalar q_CISEche`j'_`num'_p`i'_rur 		= r(CIse)		
		
	* Concentration Index - Urban
		conindex q_che`j'_`num' if passage==`i' & milieu==1, svy rankvar(wealth_score) bounded limits(0 1)
			scalar q_CIche`j'_`num'_p`i'_urb		= r(CI)
			scalar q_CISEche`j'_`num'_p`i'_urb 		= r(CIse)
}

* Year Data

* Concentration Index - Population
		conindex y_che`j'_`num' if present_all==1, svy rankvar(wealth_score) bounded limits(0 1)
			scalar q_CIche`j'_`num'_p5_pop			= r(CI)
			scalar q_CISEche`j'_`num'_p5_pop 		= r(CIse)

* Concentration Index - Rural
		conindex y_che`j'_`num' if present_all==1 & milieu==2, svy rankvar(wealth_score) bounded limits(0 1)
			scalar q_CIche`j'_`num'_p5_rur		= r(CI)
			scalar q_CISEche`j'_`num'_p5_rur 		= r(CIse)		
			
* Concentration Index - Urban
		conindex y_che`j'_`num' if present_all==1 & milieu==1, svy rankvar(wealth_score) bounded limits(0 1)
			scalar q_CIche`j'_`num'_p5_urb			= r(CI)
			scalar q_CISEche`j'_`num'_p5_urb 		= r(CIse)		

			

*------------------------------------------------------------------------------------*
*1.3 CHEs, Overshoot, and MPO Rates for Population/Urban/Rural given wealth quintile
*------------------------------------------------------------------------------------*		

	*------------------------------------------------------------------------------------*
	*1.31 Quaterly Info
	*------------------------------------------------------------------------------------*

foreach name in "che" "over" "mpover"{

	* On each Passage
	forvalues i = 1/4{
		
		* For each Wealth Quintile
		forvalues q = 1/5{
		
	    * Check that value is greater than zero 
		*(at least one household has CHE for category)
			
			* Population
				sum q_`name'`j'_`num' if passage==`i' & wealth_quintiles==`q'
					
					if r(sum)==0{
						scalar q_`name'`j'_`num'_p`i'_pop_q`q' = 0
					}
					else{
						svy, subpop(if passage==`i' & wealth_quintiles==`q'): mean q_`name'`j'_`num'
							mat aux = e(b)
								scalar q_`name'`j'_`num'_p`i'_pop_q`q' = aux[1,1]
					}
				
			* Rural
				sum q_`name'`j'_`num' if passage==`i' & wealth_quintiles==`q' & milieu==2
			
			
				if r(sum)==0{
						scalar q_`name'`j'_`num'_p`i'_rur_q`q' = 0
					}
					else{
						svy, subpop(if passage==`i' & wealth_quintiles==`q' & milieu==2): mean q_`name'`j'_`num'
							mat aux = e(b)
								scalar q_`name'`j'_`num'_p`i'_rur_q`q' = aux[1,1]
					}
					
			* Urban
				sum q_`name'`j'_`num' if passage==`i' & wealth_quintiles==`q' & milieu==1
			
			
				if r(sum)==0{
						scalar q_`name'`j'_`num'_p`i'_urb_q`q' = 0
					}
					else{
						svy, subpop(if passage==`i' & wealth_quintiles==`q' & milieu==1): mean q_`name'`j'_`num'
							mat aux = e(b)
								scalar q_`name'`j'_`num'_p`i'_urb_q`q' = aux[1,1]
					}		
			
				
		
		}

	}
	
	
*------------------------------------------------------------------------------------*
*1.32 Year Info - we keep names loop
*------------------------------------------------------------------------------------*

	* For each Wealth Quintile
		forvalues q = 1/5{
		
	    * Check that value is greater than zero 
		*(at least one household has CHE for category)
			
			* Population
				sum y_`name'`j'_`num' if present_all==1 & wealth_quintiles==`q'
					
					if r(sum)==0{
						scalar q_`name'`j'_`num'_p5_pop_q`q' = 0
					}
					else{
						svy, subpop(if present_all==1 & wealth_quintiles==`q'): mean y_`name'`j'_`num'
							mat aux = e(b)
								scalar q_`name'`j'_`num'_p5_pop_q`q' = aux[1,1]
					}
				
			* Rural
				sum y_`name'`j'_`num' if present_all==1 & wealth_quintiles==`q' & milieu==2
			
			
				if r(sum)==0{
						scalar q_`name'`j'_`num'_p5_rur_q`q' = 0
					}
					else{
						svy, subpop(if present_all==1 & wealth_quintiles==`q' & milieu==2): mean y_`name'`j'_`num'
							mat aux = e(b)
								scalar q_`name'`j'_`num'_p5_rur_q`q' = aux[1,1]
					}
					
			* Urban
				sum y_`name'`j'_`num' if present_all==1 & wealth_quintiles==`q' & milieu==1
			
			
				if r(sum)==0{
						scalar q_`name'`j'_`num'_p5_urb_q`q' = 0
					}
					else{
						svy, subpop(if present_all==1 & wealth_quintiles==`q' & milieu==1): mean y_`name'`j'_`num'
							mat aux = e(b)
								scalar q_`name'`j'_`num'_p5_urb_q`q' = aux[1,1]
					}		
			
	
	
	
	
	}


}


******************************************************************************
**********************--------------------------------*************************
					   ** II. Store results in Matrix  **
************************--------------------------------***********************
*******************************************************************************

/* For ease of use we will create a matrix for each Type/Threshold CHE that we are interested
in and export it into excel */



matrix Table2 = J(70,5,.)


matrix rownames Table2 = ///
G`num'AllCHE`j' G`num'AllCHE`j'Q1 G`num'AllCHE`j'Q2 G`num'AllCHE`j'Q3 G`num'AllCHE`j'Q4 G`num'AllCHE`j'Q5 ///
G`num'RurCHE`j' G`num'RurCHE`j'Q1 G`num'RurCHEQ2 G`num'RurCHEQ3 G`num'RurCHEQ4 G`num'RurCHEQ5 ///
G`num'UrbCHE`j' G`num'UrbCHE`j'Q1 G`num'UrbCHE`j'Q2 G`num'UrbCHE`j'Q3 G`num'UrbCHE`j'Q4 G`num'UrbCHE`j'Q5 ///
G`num'AllOVER`j' G`num'AllOVER`j'Q1 G`num'AllOVER`j'Q2 G`num'AllOVER`j'Q3 G`num'AllOVER`j'Q4 G`num'AllOVER`j'Q5 ///
G`num'RurOVER`j' G`num'RurOVER`j'Q1 G`num'RurOVERQ2 G`num'RurOVERQ3 G`num'RurOVERQ4 G`num'RurOVERQ5 ///
G`num'UrbOVER`j' G`num'UrbOVER`j'Q1 G`num'UrbOVER`j'Q2 G`num'UrbOVER`j'Q3 G`num'UrbOVER`j'Q4 G`num'UrbOVER`j'Q5 ///
G`num'AllMPO`j' G`num'AllMPO`j'Q1 G`num'AllMPO`j'Q2 G`num'AllMPO`j'Q3 G`num'AllMPO`j'Q4 G`num'AllMPO`j'Q5 ///
G`num'RurMPO`j' G`num'RurMPO`j'Q1 G`num'RurMPOQ2 G`num'RurMPOQ3 G`num'RurMPOQ4 G`num'RurMPOQ5 ///
G`num'UrbMPO`j' G`num'UrbMPO`j'Q1 G`num'UrbMPO`j'Q2 G`num'UrbMPO`j'Q3 G`num'UrbMPO`j'Q4 G`num'UrbMPO`j'Q5 ///
G`num'AllCI G`num'AllCISE ///
G`num'RurCI G`num'RurCISE ///
G`num'UrbCI G`num'UrbCISE





matrix colnames Table2 = P1 P2 P3 P4 Year
matrix list Table2


* Row Indicator
local z = 1

* Auxliliar Row indicators
	local z2 = `z' + 1
	local z3 = `z' + 2
	local z4 = `z' + 3
	local z5 = `z' + 4
	local z6 = `z' + 5
	local z7 = `z' + 6


*****----------------------------------------------------------*****
	*2.1 Input Into Matrix
*****----------------------------------------------------------*****


	*----------------------------------------------------------*
	*2.11 CHEs, Overshoot and Mean Positive Overshoot
	*----------------------------------------------------------*
	
	* For the main variables: CHE, Overshoot, and MPO
	foreach name in "che" "over" "mpover"{
		* For Population, Rural and Urban
		foreach milieu in "pop" "rur" "urb"{
		
			* Passage and Year Info on each Column
			forvalues i = 1/5{
			
					* All Quintiles
					mat Table2[`z',`i'] = q_`name'`j'_`num'_p`i'_`milieu'
				
					*Q1-Q10
					mat Table2[`z2',`i'] = q_`name'`j'_`num'_p`i'_`milieu'_q1
					mat Table2[`z3',`i'] = q_`name'`j'_`num'_p`i'_`milieu'_q2
					mat Table2[`z4',`i'] = q_`name'`j'_`num'_p`i'_`milieu'_q3
					mat Table2[`z5',`i'] = q_`name'`j'_`num'_p`i'_`milieu'_q4
					mat Table2[`z6',`i'] = q_`name'`j'_`num'_p`i'_`milieu'_q5
				}
				
				local z = `z' + 6
					local z2 = `z' + 1
					local z3 = `z' + 2
					local z4 = `z' + 3
					local z5 = `z' + 4
					local z6 = `z' + 5
					local z7 = `z' + 6
				
			}
						
			
		}

		
	
	*----------------------------------------------------------*
	*2.12 Concentration Index
	*----------------------------------------------------------*
		
		* For Population, Rural and Urban
		foreach milieu in "pop" "rur" "urb"{
		
			* Passage and Year Info on each Column
			forvalues i = 1/5{
	
			
		* All quintiles Info on CI
		mat Table2[`z', `i'] = 	q_CIche`j'_`num'_p`i'_`milieu'
		mat Table2[`z2', `i'] = q_CISEche`j'_`num'_p`i'_`milieu'	
	}
				local z = `z' + 2
					local z2 = `z' + 1
					local z3 = `z' + 2
					local z4 = `z' + 3
					local z5 = `z' + 4
					local z6 = `z' + 5
					local z7 = `z' + 6
	
	
}
		

******************************************************************************
**********************--------------------------------*************************
							** Save Table  **
************************--------------------------------***********************
*******************************************************************************

* Directory
cdtables

* Save Table
putexcel set Table3CHE`j'_`num', replace
putexcel A1 = mat(Table2), rownames		
				
		
		
	}
	

	
	
	
	
******************************************************************************
**********************--------------------------------*************************
						** II. IHEs Rates  **
************************--------------------------------***********************
*******************************************************************************

* I can use this for any other variables too.


*----------------------------------------------------------*
*1.0 Set the parallel loop
*----------------------------------------------------------*
/* We will loop over pairs of CHE type and Thresholds specified by us
*/

rename quarter_impoverishing3 impov
gen y_impov = impov*3

local var_table impov

* Start loop over variables we want distributional stats
foreach var in `var_table'{


*--------------------------------------------------------------*
*1.1 CHEs, Overshoot,MPO Rates and CI for Population/Urban/Rural
*--------------------------------------------------------------*


	* On each Passage

	forvalues i = 1/4{
		
		* Population
		svy, subpop(if passage == `i'): mean `var'
			mat aux = e(b)
				scalar `var'_p`i'_pop = aux[1,1]

		* Rural
		svy, subpop(if passage == `i' & milieu==2): mean `var'
				mat aux = e(b)
					scalar `var'_p`i'_rur = aux[1,1]
				
				
		* Urban
		svy, subpop(if passage == `i' & milieu ==1): mean `var'
			mat aux = e(b)
				scalar `var'_p`i'_urb = aux[1,1]
		
				
	}

	* Year Data

		* Population
		svy, subpop(if present_all==1): mean y_`var'
			mat aux = e(b)
				scalar `var'_p5_pop = aux[1,1]

		* Rural
		svy, subpop(if present_all==1 & milieu==2): mean y_`var'
			mat aux = e(b)
				scalar `var'_p5_rur = aux[1,1]
				
		* Urban
		svy, subpop(if present_all==1 & milieu==1): mean y_`var'
			mat aux = e(b)
				scalar `var'_p5_urb = aux[1,1]




*------------------------------------------------------------------------------------*
*1.3 Concentration Index Population/Urban/Rural by Passage
*------------------------------------------------------------------------------------*	

* Quaterly Data

forvalues i = 1/4{
	
	* Concentration Index - Population
		conindex `var' if passage==`i', svy rankvar(wealth_score) bounded limits(0 1)
			scalar q_CI`var'_p`i'_pop		= r(CI)
			scalar q_CISE`var'_p`i'_pop 		= r(CIse)			

	* Concentration Index - Rural
		conindex `var' if passage==`i' & milieu==2, svy rankvar(wealth_score) bounded limits(0 1)
			scalar q_CI`var'_p`i'_rur		= r(CI)
			scalar q_CISE`var'_p`i'_rur 		= r(CIse)		
		
	* Concentration Index - Urban
		conindex `var' if passage==`i' & milieu==1, svy rankvar(wealth_score) bounded limits(0 1)
			scalar q_CI`var'_p`i'_urb		= r(CI)
			scalar q_CISE`var'_p`i'_urb 		= r(CIse)
}

* Year Data

* Concentration Index - Population
		conindex `var' if present_all==1, svy rankvar(wealth_score) bounded limits(0 1)
			scalar q_CI`var'_p5_pop			= r(CI)
			scalar q_CISE`var'_p5_pop 		= r(CIse)

* Concentration Index - Rural
		conindex `var' if present_all==1 & milieu==2, svy rankvar(wealth_score) bounded limits(0 1)
			scalar q_CI`var'_p5_rur		= r(CI)
			scalar q_CISE`var'_p5_rur 		= r(CIse)		
			
* Concentration Index - Urban
		conindex `var' if present_all==1 & milieu==1, svy rankvar(wealth_score) bounded limits(0 1)
			scalar q_CI`var'_p5_urb			= r(CI)
			scalar q_CISE`var'_p5_urb 		= r(CIse)		

			

*------------------------------------------------------------------------------------*
*1.3 CHEs, Overshoot, and MPO Rates for Population/Urban/Rural given wealth quintile
*------------------------------------------------------------------------------------*		

	*------------------------------------------------------------------------------------*
	*1.31 Quaterly Info
	*------------------------------------------------------------------------------------*


	* On each Passage
	forvalues i = 1/4{
		
		* For each Wealth Quintile
		forvalues q = 1/5{
		
	    * Check that value is greater than zero 
		*(at least one household has CHE for category)
			
			* Population
				sum `var' if passage==`i' & wealth_quintiles==`q'
					
					if r(sum)==0{
						scalar `var'_p`i'_pop_q`q' = 0
					}
					else{
						svy, subpop(if passage==`i' & wealth_quintiles==`q'): mean `var'
							mat aux = e(b)
								scalar `var'_p`i'_pop_q`q' = aux[1,1]
					}
				
			* Rural
				sum `var' if passage==`i' & wealth_quintiles==`q' & milieu==2
			
			
				if r(sum)==0{
						scalar `var'_p`i'_rur_q`q' = 0
					}
					else{
						svy, subpop(if passage==`i' & wealth_quintiles==`q' & milieu==2): mean `var'
							mat aux = e(b)
								scalar `var'_p`i'_rur_q`q' = aux[1,1]
					}
					
			* Urban
				sum `var' if passage==`i' & wealth_quintiles==`q' & milieu==1
			
			
				if r(sum)==0{
						scalar `var'_p`i'_urb_q`q' = 0
					}
					else{
						svy, subpop(if passage==`i' & wealth_quintiles==`q' & milieu==1): mean `var'
							mat aux = e(b)
								scalar `var'_p`i'_urb_q`q' = aux[1,1]
					}		
			
				
		
		}


	
	
*------------------------------------------------------------------------------------*
*1.32 Year Info - we keep names loop
*------------------------------------------------------------------------------------*

	* For each Wealth Quintile
		forvalues q = 1/5{
		
	    * Check that value is greater than zero 
		*(at least one household has CHE for category)
			
			* Population
				sum y_`var' if present_all==1 & wealth_quintiles==`q'
					
					if r(sum)==0{
						scalar `var'_p5_pop_q`q' = 0
					}
					else{
						svy, subpop(if present_all==1 & wealth_quintiles==`q'): mean y_`var'
							mat aux = e(b)
								scalar `var'_p5_pop_q`q' = aux[1,1]
					}
				
			* Rural
				sum y_`var' if present_all==1 & wealth_quintiles==`q' & milieu==2
			
			
				if r(sum)==0{
						scalar `var'_p5_rur_q`q' = 0
					}
					else{
						svy, subpop(if present_all==1 & wealth_quintiles==`q' & milieu==2): mean y_`var'
							mat aux = e(b)
								scalar `var'_p5_rur_q`q' = aux[1,1]
					}
					
			* Urban
				sum y_`var' if present_all==1 & wealth_quintiles==`q' & milieu==1
			
			
				if r(sum)==0{
						scalar `var'_p5_urb_q`q' = 0
					}
					else{
						svy, subpop(if present_all==1 & wealth_quintiles==`q' & milieu==1): mean y_`var'
							mat aux = e(b)
								scalar `var'_p5_urb_q`q' = aux[1,1]
					}		
			
	
	
	
	
	}


}


******************************************************************************
**********************--------------------------------*************************
					   ** II. Store results in Matrix  **
************************--------------------------------***********************
*******************************************************************************

/* For ease of use we will create a matrix for each Type/Threshold CHE that we are interested
in and export it into excel */



matrix Table2 = J(70,5,.)


matrix rownames Table2 = ///
All`var' All`var'Q1 All`var'Q2 All`var'Q3 All`var'Q4 All`var'Q5 ///
Rur`var' Rur`var'Q1 RurCHEQ2 RurCHEQ3 RurCHEQ4 RurCHEQ5 ///
Urb`var' Urb`var'Q1 Urb`var'Q2 Urb`var'Q3 Urb`var'Q4 Urb`var'Q5 ///
AllCI AllCISE ///
RurCI RurCISE ///
UrbCI UrbCISE





matrix colnames Table2 = P1 P2 P3 P4 Year
matrix list Table2


* Row Indicator
local z = 1

* Auxliliar Row indicators
	local z2 = `z' + 1
	local z3 = `z' + 2
	local z4 = `z' + 3
	local z5 = `z' + 4
	local z6 = `z' + 5
	local z7 = `z' + 6


*****----------------------------------------------------------*****
	*2.1 Input Into Matrix
*****----------------------------------------------------------*****


	*----------------------------------------------------------*
	*2.11 CHEs, Overshoot and Mean Positive Overshoot
	*----------------------------------------------------------*
	
	* For the main variables: CHE, Overshoot, and MPO
		* For Population, Rural and Urban
		foreach milieu in "pop" "rur" "urb"{
		
			* Passage and Year Info on each Column
			forvalues i = 1/5{
			
					* All Quintiles
					mat Table2[`z',`i'] = `var'_p`i'_`milieu'
				
					*Q1-Q10
					mat Table2[`z2',`i'] = `var'_p`i'_`milieu'_q1
					mat Table2[`z3',`i'] = `var'_p`i'_`milieu'_q2
					mat Table2[`z4',`i'] = `var'_p`i'_`milieu'_q3
					mat Table2[`z5',`i'] = `var'_p`i'_`milieu'_q4
					mat Table2[`z6',`i'] = `var'_p`i'_`milieu'_q5
				}
				
				local z = `z' + 6
					local z2 = `z' + 1
					local z3 = `z' + 2
					local z4 = `z' + 3
					local z5 = `z' + 4
					local z6 = `z' + 5
					local z7 = `z' + 6
				
			}
						
			

		
	
	*----------------------------------------------------------*
	*2.12 Concentration Index
	*----------------------------------------------------------*
		
		* For Population, Rural and Urban
		foreach milieu in "pop" "rur" "urb"{
		
			* Passage and Year Info on each Column
			forvalues i = 1/5{
	
			
		* All quintiles Info on CI
		mat Table2[`z', `i'] = 	q_CI`var'_p`i'_`milieu'
		mat Table2[`z2', `i'] = q_CISE`var'_p`i'_`milieu'	
	}
				local z = `z' + 2
					local z2 = `z' + 1
					local z3 = `z' + 2
					local z4 = `z' + 3
					local z5 = `z' + 4
					local z6 = `z' + 5
					local z7 = `z' + 6
	
	
}
		

******************************************************************************
**********************--------------------------------*************************
							** Save Table  **
************************--------------------------------***********************
*******************************************************************************

* Directory
cdtables

* Save Table
putexcel set Table3`var', replace
putexcel A1 = mat(Table2), rownames		
				
		
		
	}
	
	
	
	

******************************************************************************
**********************--------------------------------*************************
							** OOPs  **
************************--------------------------------***********************
*******************************************************************************

use e15_dataframe_with_emploi, clear
keep if present_all==1
replace quarter_sante = quarter_sante / 526

* For all
collapse quarter_sante [aweight=hhweight] , by(passage wealth_quintiles)	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

