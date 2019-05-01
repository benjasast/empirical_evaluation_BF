clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Catastrophic Health Expenditures
* File Name: fig09_shocks_CHEs
* RA: Benjamin Sas
* PI: Karen Grepin	
* Date: 19/10/18
* Version: 1			
*******************************************************************************
/* Graphs assesing the relationship between reported Shocks and CHEs
*/
*******************************************************************************
* Vars
set maxvar 10000

* Directory
cdoutput
* Load Data
use e15_dataframe_with_emploi

* Relevant
keep if present_all==1

* Scheme
set scheme plotplain

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

* All shocks create dummy - This variable does not work

* Create a Dummy for each shock to be in the graph
gen choc1 = (choc_coping==1)
	label var choc1 "Any Shock"

gen choc2 = (choc_maladiegrave==1)
	label var choc2 "Health Shock"

gen choc3 = (choc_agriculture==1)
		label var choc3 "Agriculture Shock"
		
gen choc4 = (choc_revenu==1)
			label var choc4 "Income Shock"

gen choc5 = (choc_decede==1)
			label var choc5 "Death in HH"

gen choc6 = (choc_autre==1)
			label var choc6 "Other Shock"
			
gen choc7 = (choc_coping==0)
			label var choc7 "No Shock"	


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


*******************************************************************************
*******************************************************************************
			* I. CHE rates by shock - Consolidated Graph
*******************************************************************************
*******************************************************************************

* Loop over variables
local graph_var  q_che1_10 q_che3_40 q_che5_40 quarter_impoverishing3
foreach var in `graph_var'{

	* Loop over shocks
		forval k = 1/7{
			qui: mean `var' if choc`k'==1 [aweight=hhweight]
				mat aux = r(table)
				scalar m`k'_`var' = aux[1,1]
				scalar l`k'_`var' = aux[5,1] // lower bound ci
				scalar u`k'_`var' = aux[6,1] // upper bound ci			
		}
}




* Put the information in the order of the graph: Shock -> CHE measure

gen mean =.
gen lower=.
gen upper=.
gen type =. // type of CHE
gen order=. // order of graph


local i = 1

forval k = 1/7{
	
	local t = 1
	foreach var in `graph_var'{
		replace mean = m`k'_`var' in `i'
		replace lower = l`k'_`var' in `i'
		replace upper = u`k'_`var' in `i'
		replace type = `t' in `i'
		replace order = `i' in `i'
	
	local t = `t' + 1
	local i = `i' + 1	
	}
		
}

* add three to the order for different shocks (to create distance)
recode order ///
(1/4=0) (5/8=1) (9/12=2) (13/16=3) (17/20=4) (21/24=5) (25/28=6) ///
, gen(group)

replace order = order + group*2 // space between shocks in graph



* GRAPH

	twoway 	(bar mean order if type==1 	, lcolor(gs6)) ///
			(bar mean order if type==2 	, lcolor(gs10)) ///
			(bar mean order if type==3	, lcolor(gs8)) ///
			(bar mean order if type==4	, lcolor(gs4)) ///
			(rcap upper lower order , lcolor(gs12)) ///
			,xlabel( 2.5 "Any"  8.5 "Health" 14.5 "Agriculture" 20.5 "Income" 26.5 "Death in HH" 32.5 "Other" 38.5 "No Shock"   , noticks) ///
			legend(lab(1 "10% total consumption") lab(2 "40% non-food consumption") lab(3 "40% non-subsistence consumption") lab(4 "Impoverished households") lab(5 "95% CI") pos(6) rows(2)) ///
			xtitle("") ///
			ytitle(Proportion of households)
			
			* Dir
			cdtables
			graph export fig03a_shocks_CHEs.png , replace



*******************************************************************************
*******************************************************************************
			* II. FPI rates by shock - Consolidated Graph
*******************************************************************************
*******************************************************************************


* Grab FPI score for each shock category

forval i = 1/7{
preserve

keep if choc`i'==1

	collapse (mean) ///
		quarter_immiserizing3 quarter_impoverishing3 quarter_catastrohic3 ///
		quarter_noncatastrophic3 quarter_zero3 ///
		(sd) sdquarter_immiserizing3 = quarter_immiserizing3  ///
		sdquarter_impoverishing3 = quarter_impoverishing3 ///
		sdquarter_catastrohic3 = quarter_catastrohic3 ///
		sdquarter_noncatastrophic3 = quarter_noncatastrophic3 ///
		sdquarter_zero3 = quarter_zero3 ///
		(count) n = quarter_immiserizing3 ///
		[aweight=hhweight] ///		
		
	gen fpi = quarter_immiserizing3 + 2*quarter_impoverishing3 + 3*quarter_noncatastrophic3 + 4*quarter_noncatastrophic3 + 5*quarter_zero3
		replace fpi = fpi*10
		
	sum fpi		
	
	* Get the sd of the linear combination
	gen sd = sqrt( 10^2 * sdquarter_immiserizing3^2 + 20^2 * sdquarter_impoverishing3^2 + 30^2*quarter_noncatastrophic3^2 + 40^2*quarter_noncatastrophic3^2 + 50^2*quarter_zero3^2 )  							

	generate upper =  fpi + invttail(n-1,0.025)*(sd / sqrt(n))
	generate lower = fpi - invttail(n-1,0.025)*(sd / sqrt(n))


	* Save the mean and upper and lower
	scalar fpi`i' = fpi[1]
	scalar upper`i' = upper[1]
	scalar lower`i' = lower[1]
	scalar n`i' = n[1]

restore	
}



* Put in order for graph
gen fpi =.
gen upper=.
gen lower=.
gen order =_n
	replace order = . if order>=8
	replace order = order*2
	
forval i = 1/7{
	replace fpi = scalar(fpi`i') in `i'
	replace upper = scalar(upper`i') in `i'
	replace lower = scalar(lower`i') in `i'
}

* Variable to use in Over() option	
	gen lab_choc =.
	forvalues k = 1/7{
		replace lab_choc = `k' in `k'
	}
label define shock 1 "Any Shock" 2 "Health Shock" 3 "Agriculture Shock" 4 "Income Shock" 5 "Death in HH" 6 "Other Shock" 7 "No Shock"
label values lab_choc shock
	




	twoway 	(bar fpi order if lab_choc==1) ///
			(bar fpi order if lab_choc==2) ///		
			(bar fpi order if lab_choc==3) ///		
			(bar fpi order if lab_choc==4) ///		
			(bar fpi order if lab_choc==5) ///		
			(bar fpi order if lab_choc==6) ///		
			(bar fpi order if lab_choc==7) ///		
			(rcap upper lower order) ///
			,ylabel(0(10)50) ///
			xlabel( 2 "Any"  4 "Health" 6 "Agriculture" 8 "Income" 10 "Death in HH" 12 "Other" 14 "No Shock"   , noticks) ///
			xtitle("") ///
			legend(off)

			cdtables
			graph export fig03b_FPIscore.png , replace



























	
	
	
