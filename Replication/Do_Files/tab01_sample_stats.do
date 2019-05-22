clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Table 1 - Descriptive Statistics for Population
* File Name: t01_descriptive_stats_sample
* RA: Benjamin Sas
* PI: Karen Grepin				
*******************************************************************************
/* This program will calculate catastrophic health expenditures for households
in different ways
*/
*******************************************************************************
* Directory
cdoutput
* Load Data
use a00_dataset_empirical_eval
*******************************************************************************

******************************************************************************
**********************--------------------------------*************************
						** I. Survey Information  **
************************--------------------------------***********************
*******************************************************************************

keep if present_all==1 // keep only households present every round.


*******************************************************************************
***************--------------------------------------------********************
				** 	I. Descriptive Statistics  **
***************--------------------------------------------********************
*******************************************************************************
gen urban = (milieu==1)

*-------------------------------------------------*
*Part 1 - Number of Households and HH characteristics
*-------------------------------------------------*
preserve

collapse 	(count) nhouseholds=hhid ///
			(sum) npeople=hhsize ///
			(mean) avgsize=hhsize perurban=urban chef_female , by(passage)

xpose, clear varname // put it the way we want

* Save
cdtables
export excel tab01_sample_part1.xlsx , replace

restore

*-------------------------------------------------*
*Part 2 - Wealth Quintiles
*-------------------------------------------------*

preserve
keep if passage==1

forval q = 1/5{
	gen wq`q' = (wealth_quintiles==`q')
}

collapse wq*, by(passage)
xpose,clear varname
export excel tab01_sample_part2a.xlsx , replace

restore


preserve
keep if passage==1

forval q = 1/5{
	gen wq`q' = (wealth_quintiles==`q')
}

collapse wq*, by(passage milieu)
xpose, clear varname
export excel tab01_sample_part2b.xlsx , replace

restore

*-------------------------------------------------*
*Part 3 - Consumption and Poverty
*-------------------------------------------------*
egen other = rsum(quarter_sante_proddivers quarter_sante_appareils quarter_sante_labradio ///
quarter_sante_servaux)

rename quarter_preoop_poor3 poorhousehold

* Money in USD
unab money_list: quarter*
	foreach v in `money_list'{
		replace `v' = `v' / 526
	}

preserve
	
collapse (mean) quarter_total_consumation quarter_food_consumation ///
				quarter_nonfood_consumation quarter_sante ///
				quarter_sante_drugmoder quarter_sante_drugtrad ///
				quarter_sante_medecin quarter_sante_servhosp ///
				quarter_sante_assurance other ///
				poorhousehold ///
				, by(passage)

xpose, clear varname				
export excel tab01_sample_part3a.xlsx , replace

restore

preserve
	
collapse (mean) quarter_total_consumation quarter_food_consumation ///
				quarter_nonfood_consumation quarter_sante ///
				quarter_sante_drugmoder quarter_sante_drugtrad ///
				quarter_sante_medecin quarter_sante_servhosp ///
				quarter_sante_assurance other ///
				poorhousehold ///
				, by(passage wealth_quintiles)

xpose, clear varname				
export excel tab01_sample_part3b.xlsx , replace

restore






























