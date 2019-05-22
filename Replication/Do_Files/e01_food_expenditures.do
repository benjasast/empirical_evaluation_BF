clear all
set more off
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Food Consumption Expenditures
* File Name: e01_food_expenditures
* RA: Benjamin Sas
* PI: Karen Grepin				
*******************************************************************************
* Start Loop over passages
forvalues i=1(1)4 {
*******************************************************************************
* Directory
cddata
*******************************************************************************
* Load Data
use emc2014_p`i'_conso7jours.dta , replace
*******************************************************************************
* Create Household IDs
* Combination of ZD: counting area + household number
* there is one already created hhid
gen menage_id = hhid

* Create Household - Product ID
gen menage_id_product = strofreal(menage_id) + "p" + strofreal(product)

*******************************************************************************
**********************--------------------------------*************************
					  ** I. Food Expenditures per Household **
************************--------------------------------***********************
*******************************************************************************

* ALL QUANTITIES ARE COMMENTED AS SINCE PASSAGE 2 THE QUANTITIES ARE NOT
* REPORTED ANYMORE **

*replace qachat =. 								
*replace qcadeau =. 							
*replace qautocons =. 							


***** Create Extra Categories *******************
egen cereal = rsum(achat autocons cadeau) ///
				if product<=13

egen viande = rsum(achat autocons cadeau) ///
				if product>13 & product<=22

egen lait_fromage = rsum(achat autocons cadeau) ///
				if product>22 & product<=25
				
egen huile_graisse = rsum(achat autocons cadeau) ///
				if product>25 & product<=29

egen legume = rsum(achat autocons cadeau) ///
				if product>29 & product<=45

egen sucre = rsum(achat autocons cadeau) ///
				if product>45 & product<=47
				
egen autre_alim = rsum(achat autocons cadeau) ///
				if product>47 & product<=51

egen boisson_salcohol = rsum(achat autocons cadeau) ///
				if product>51 & product<=56

egen alcohol_drugs = rsum(achat autocons cadeau) ///
				if (product>=57 & (product!=61 & product!=62) )

egen tobacco = rsum(achat  autocons  cadeau) 		if (product==61 | product==62)
			
*******************************************************************************
* Calculate expenditures per household - For that Week for each category

* We need to exclude alcohol_drugs and tobacco!
egen food_consumation = rsum(achat autocons cadeau)
		replace food_consumation = food_consumation - alcohol_drugs if !mi(alcohol_drugs)
		replace food_consumation = food_consumation - tobacco		if !mi(tobacco)

local conso_var food_consumation achat autocons cadeau cereal viande ///
				lait_fromage huile_graisse legume sucre autre_alim boisson_salcohol ///
				alcohol_drugs tobacco

foreach var in `conso_var' {
	bysort menage_id: egen week_`var' = total(`var')
	label var week_`var' "Total value `var' by HH 7 days recall"
}

*******************************************************************************
					** Relevant Scalars **
*******************************************************************************

* Number of households in this passage
by menage_id, sort: gen n_menage = _n ==1
count if n_menage
replace n_menage = r(N)

* Number of observations in this passage
gen n_obs = _N


*******************************************************************************
		** Some Variable Name to consolidate datasets of each passage **
*******************************************************************************
rename hhsize`i' hhsize
rename merge`i' merge
rename res_entr`i' res_entr
rename hhweight`i' hhweight


*******************************************************************************
					** Save Aggregate Data **
*******************************************************************************
keep zd menage hhsize hhid hhweight region milieu strate ///
week* menage_id n_menage

duplicates drop menage_id, force
gen passage = `i'
gen menage_id_passage = strofreal(menage_id) + "passage" + strofreal(`i')
cdoutput
save e01_p`i'_food_agg, replace

*******************************************************************************
					** End Loop **
*******************************************************************************
clear all
}

*******************************************************************************
**********************--------------------------------*************************
				** DataFrame -> Merging and Rectangularization of Data **
************************--------------------------------***********************
*******************************************************************************
/* We will basically need 2 datasets to make computation easier.

1. An aggregated panel at the household-passage level where we focus in total
expenditures.

2. An (optional) disaggrated panel at the household-product-passage level, found in
e01_food_dataframe.dta

*/

*******************************************************************************
	********* 1. Aggregated Dataset: ID-Menage - Passage level **********
*******************************************************************************
clear all
cdoutput

* First we need all ID-Menage available. They were all on passage 1
use e01_p1_food_agg
keep menage_id

* Create DataFrame for Aggregate Data
forvalues i=1(1)4{
	gen passage`i' = `i'
}

reshape long passage, i(menage_id) j(p)
drop p

* Create Merge identifier
gen menage_id_passage = strofreal(menage_id) + "passage" + strofreal(passage)


* Data is Ready for merge
forvalues i=1(1)4 {
	merge 1:1 menage_id_passage using e01_p`i'_food_agg, replace update
	drop _merge
}

save e01_food_agg_dataframe, replace



