clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: DataFrame for Household Data
* File Name: e05_dataframe_household_agg
* RA: Benjamin Sas
* PI: Karen Grepin				
*******************************************************************************
/* 
This program will merge all the different expenditure aggregated expenditure modules
and create a panel dataset where the unit of observation is household-passage.

The idea is that after creating this DataFrame we will be able to compute total
consumption and its different components.
*/
*******************************************************************************
 * Directory
 cddata
*******************************************************************************
 
 
******************************************************************************
**********************--------------------------------*************************
				** I. Create the DataFrame (Rectangularization)**
************************--------------------------------***********************
*******************************************************************************

* We will take all the household IDs from the Individu database
use  emc2014_p1_conso7jours

* First we need all ID-Menage available. They were all on passage 1
gen menage_id = hhid
keep zd menage hhid menage_id 

duplicates drop menage_id, force

* Create DataFrame for Aggregate Data
forvalues i=1(1)4{
	gen passage`i' = `i'
}

reshape long passage, i(menage_id) j(p)
drop p

* Create Merge identifier
gen menage_id_passage = strofreal(menage_id) + "passage" + strofreal(passage)


******************************************************************************
**********************--------------------------------*************************
						** II. Perform the Matching  **
************************--------------------------------***********************
*******************************************************************************
* Directory
cdoutput

*******************************************************************************
* 1. Match Food expenditures
*******************************************************************************

merge 1:1 menage_id passage using e01_food_agg_dataframe.dta


*******************************************************************************
* 2. Non Food Expenditures
*******************************************************************************
drop _merge

merge 1:1 menage_id passage using e02_nonfood_agg_dataframe

* Empty observations - coming from this data
drop if menage==.
* One observation didn't have the menage id and was included
duplicates drop zd menage passage, force

*******************************************************************************
* 3. Special Health Module - Yearly performed in P3
*******************************************************************************
drop _merge

merge 1:1 zd menage passage using e03_p3_special_health_agg

* One strange observation was also added
drop if menage_id==.

*******************************************************************************
* 4. Special Anthropometric Module - Yearly performed in P4
*******************************************************************************
drop _merge

merge 1:1 zd menage passage using e03_p4_special_anthropometrie_agg

* Redundant Added observations with no information
drop if _merge==2

*******************************************************************************
* 5. Special Education Module - Yearly performed in P3
*******************************************************************************
drop _merge

merge 1:1 zd menage passage using e03_p4_special_education_agg

* Redundant Added observations with no information
drop if _merge==2


*******************************************************************************
* 6. Consumer Durables - Yearly performed in P1
*******************************************************************************
drop _merge

merge 1:1 zd menage passage using e04_p1_special_consumer_durables_agg

drop if _merge==2


*******************************************************************************
* 7. Housing Cost - Yearly performed in P1
*******************************************************************************
drop _merge

merge 1:1 zd menage passage using e04_p1_special_logement_agg

drop if _merge==2


*******************************************************************************
* 8. Special Pregnancy - Yearly performed in P4
*******************************************************************************
capture drop _merge

merge 1:1 zd menage passage using e03_p4_special_pregnancy

drop if _merge==2


******************************************************************************
**********************--------------------------------*************************
						** III. Save DataSet  **
************************--------------------------------***********************
*******************************************************************************


*******************************************************************************
* 1. HH present on each passage - Useful to have
*******************************************************************************
// We only want observations that have valid values for both non-food consumption
// and food consumption.

gen present = .

forvalues i = 1(1)4 {
replace present = 0 if passage==`i'
replace present = 1 if passage==`i' ///
					& !mi(week_food_consumation,quarter_nonfood_consumation) ///
					& week_food_consumation!=0 & quarter_nonfood_consumation!=0
}


*******************************************************************************
* 2. HH present in all passages
*******************************************************************************

* Useful variables present in all periods
bysort menage_id:	egen present_n = total(present)
label var present_n "Number of rounds the HH is present and valid"
gen present_all =0
replace present_all = 1 if present_n==4
label var present_all "HH is present and valid in all passages" 

*******************************************************************************
* 3. HH in some passages
*******************************************************************************

* Present only until passage `i'

forvalues i = 1(1)3{
bysort menage_id: egen aux = total(present)
gen present_until_p`i' =0
replace present_until_p`i' = 1 if aux==`i' & present_all==0
label var present_until_p`i' "HH is present and valid until passage `i'"
drop aux

}



*******************************************************************************
* 4. Saving Dataset
*******************************************************************************

save e05_dataframe_household_agg, replace












