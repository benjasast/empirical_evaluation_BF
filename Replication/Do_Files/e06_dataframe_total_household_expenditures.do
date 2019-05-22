clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Calculate Total Nominal Expenditures and Real Expenditures
* File Name: e_06_dataframe_total_household_expenditures
* RA: Benjamin Sas
* PI: Karen Grepin				
*******************************************************************************
/* This program will compute the total nominal expenditures and also adjust the
expenditures to real terms, in order to do this we will:

1. Consolidate the expenditures to annual data for each item
2. Add up the different items to get to the shares of each component (food, health)

*/
*******************************************************************************
* Directory
cdoutput
* Load data
use e05_dataframe_household_agg
*******************************************************************************


*******************************************************************************
***************--------------------------------------------********************
			** I. Quarter - Create Data to Evaluate each Passage **
***************--------------------------------------------********************
*******************************************************************************
/* In essence each passage acts like a representative consumption bundle of
the consumption of each season, therefore we will only use information recollected
on each passage for food and non-food items, with the exception of consumer durables
and rent which will be inputted according to their annual values
*/

*******************************************************************************
* 1. Creating Quarter Consumption Data for all Elements - Nominal
*******************************************************************************

* It is important to know that in this module consumation refers to the total 
* food consumption is the addition of achat, autocons, cadeau and tobacco. these come
* from conso7jours files. Non-Food comes from conso3mois, while rent and consumer
* durables come from their respective module.

*-----------------------------------------------*
* 1.1. Quarter Food Consumption - 7 Day Recall
*-----------------------------------------------*

* Relevant Variables
local week_variables week_food_consumation week_achat week_autocons ///
week_cadeau week_cereal week_viande week_lait_fromage week_huile_graisse ///
week_legume week_sucre week_autre_alim week_boisson_salcohol week_alcohol_drugs ///
week_tobacco

/* Create Quarter - Spending - We will wegiht each passage as the INSD did.
	- Passage 1: 90 days
	- Passage 2: 91 days
	- Passage 3: 92 days
	- Passage 4: 92 days
*/

foreach var in `week_variables'{
	bysort menage_id: gen quarter_`var' =.
		replace quarter_`var' = `var'/7 * 90 if passage==1
		replace quarter_`var' = `var'/7 * 91 if passage==2
		replace quarter_`var' = `var'/7 * 92 if passage==3
		replace quarter_`var' = `var'/7 * 92 if passage==4
}

rename (quarter_week_food_consumation quarter_week_achat quarter_week_autocons ///
quarter_week_cadeau quarter_week_cereal quarter_week_viande quarter_week_lait_fromage ///
quarter_week_huile_graisse quarter_week_legume quarter_week_sucre quarter_week_autre_alim ///
quarter_week_boisson_salcohol quarter_week_alcohol_drugs quarter_week_tobacco) ///
	(quarter_food_consumation quarter_achat quarter_autocons quarter_cadeau quarter_cereal ///
	quarter_viande quarter_lait_fromage quarter_huile_graisse quarter_legume ///
	quarter_sucre quarter_autre_alim quarter_boisson_salcohol quarter_alcohol_drugs ///
	quarter_tobacco)


*-----------------------------------------------*
* 1.2. Quarter Non-Food Consumption - 3 Month Recall
*-----------------------------------------------*
* This variables were asked in a 3 month recall period, we will take them as lump
* sums. for the passage analysis we won't average them over year as they consist
* of perhaps seasonal spending and the objective consists on evaluating CHE under
* the assumption that we only have info for each passage.

* Relevant Variables - No Modification is needed =)
local quarter_nonfood_variables quarter_nonfood_consumation quarter_sante quarter_education ///
quarter_habillement quarter_factures_maison quarter_meubles_appareils ///
quarter_transport quarter_communication quarter_loisir quarter_restaurant ///
quarter_diverse ///
quarter_sante_drugmoder quarter_sante_drugtrad quarter_sante_proddivers ///
quarter_sante_appareils quarter_sante_medecin quarter_sante_labradio ///
quarter_sante_servaux quarter_sante_servhosp quarter_sante_assurance


*-----------------------------------------------*
* 1.3. Quarter Rent and Consumer Durables - Mix
*-----------------------------------------------*
/* These modules were only asked once in P3, we will input them over the year
in order to represent their cost of use or rent. 
*/

* We need to copy the data for loyer and durables for all periods - they are only on their
* respective passages

* Rent is asked for the monthly amount
bysort menage_id:	egen quarter_logement_menage_loyer = max(logement_menage_loyer)
replace quarter_logement_menage_loyer = quarter_logement_menage_loyer*3 // A quarter is composed of 3 months

* Consumer Durables were calculated for the yearly cost of use
bysort menage_id:	egen quarter_durables_coututilis = max(durables_menage_cout_utilisation)
replace quarter_durables_coututilis = quarter_durables_coututilis/4


*******************************************************************************
* 2. Create Quarter Total Consumption - Nominal
*******************************************************************************


*-----------------------------------------------*
* 2.1 Quarter - Food
*-----------------------------------------------*
* Is all good in quarter_food_consumation	

*-----------------------------------------------*
* 2.2 Quarter - Non-Food
*-----------------------------------------------*
* Let's put all non-food expenditure in one place! - we need to add the loyer and cout utilisation
* We also need to include alcohol_drugs and tobacco.

egen aux = rsum(quarter_logement_menage_loyer  quarter_durables_coututilis quarter_alcohol_drugs quarter_tobacco)
replace quarter_nonfood_consumation = quarter_nonfood_consumation + aux if aux>0 & !mi(aux)

*-----------------------------------------------*
* 2.3 Quarter - Total Consumption
*-----------------------------------------------*

egen quarter_total_consumation = ///
	rsum(quarter_food_consumation quarter_nonfood_consumation)


*-----------------------------------------------*
* 2.4 Quarter - Equivalent HH consumption
*-----------------------------------------------*
local quarter_total quarter_nonfood_consumation quarter_total_consumation quarter_food_consumation

foreach var in `quarter_local'{
	gen pc`var'eq = `var' / hhsize^(0.56)
	label var pc`var'eq "Percapita `var' adjusted for household size (economies of scale)"
}


	

*******************************************************************************
***************--------------------------------------------********************
			** II. Year - Create Data to Evaluate whole Year **
***************--------------------------------------------********************
*******************************************************************************
/* This module will consist on the evaluation of consumption over the whole year
again. The food consumption of each passage will be weighted equally to determine
total amount of food consumption, as each is a representative sample of the food
bundle for each season. Non-Food will again be taken as lump sum, and those
expenditures will simply be added as they are not recurrent as food.
*/


*******************************************************************************
* 1. Creating Yearly Consumption Data for all Elements - Nominal
*******************************************************************************

*-----------------------------------------------*
* 1.1. Year Food Consumption - 7 Day Recall
*-----------------------------------------------*
* We will simply construct from our earlier quarter results

local quarter_list_food quarter_food_consumation quarter_achat quarter_autocons quarter_cadeau quarter_cereal ///
quarter_viande quarter_lait_fromage quarter_huile_graisse quarter_legume ///
quarter_sucre quarter_autre_alim quarter_boisson_salcohol quarter_alcohol_drugs ///
quarter_tobacco

* We average the results for each quarter and then multiply by four to represent yearly
* food expenditure. This way we avoid inputting low values for HHs previously not present.

foreach var in `quarter_list_food'{
	bysort menage_id:	egen year_`var' 	= mean(`var')
						replace year_`var' 	= year_`var'*4
}


rename (year_quarter_food_consumation year_quarter_achat year_quarter_autocons ///
year_quarter_cadeau year_quarter_cereal year_quarter_viande year_quarter_lait_fromage ///
year_quarter_huile_graisse year_quarter_legume year_quarter_sucre year_quarter_autre_alim ///
year_quarter_boisson_salcohol year_quarter_alcohol_drugs year_quarter_tobacco) ///
	(year_food_consumation year_achat year_autocons year_cadeau year_cereal ///
	year_viande year_lait_fromage year_huile_graisse year_legume year_sucre ///
	year_autre_alim year_boisson_salcohol year_alcohol_drugs year_tobacco )


*-----------------------------------------------*
* 1.2. Year Non-Food Consumption - 3 Month Recall
*-----------------------------------------------*
* We will also add up from our earlier results, remmeber these were simply the
* declared 3 month non food consumption from conso3mois.

* These are all inside the local `quarter_nonfood_variables'

foreach var in `quarter_nonfood_variables' {
	bysort menage_id:	egen year_`var' = total(`var')		  // Lump-Sum Approach
	*bysort menage_id:	egen year_`var' 		= mean(`var') // Average Approach
	*					replace year_`var' 		= year_`var'*4 // Average Approach
						
}


rename (year_quarter_nonfood_consumation year_quarter_sante ///
year_quarter_education year_quarter_habillement year_quarter_factures_maison ///
year_quarter_meubles_appareils year_quarter_transport year_quarter_communication ///
year_quarter_loisir year_quarter_restaurant year_quarter_diverse ///
year_quarter_sante_drugmoder year_quarter_sante_drugtrad ///
year_quarter_sante_proddivers year_quarter_sante_appareils ///
year_quarter_sante_medecin year_quarter_sante_labradio ///
year_quarter_sante_servaux year_quarter_sante_servhosp year_quarter_sante_assurance) ///
	(year_nonfood_consumation year_sante year_education year_habillement ///
	year_factures_maison year_meubles_appareils year_transport ///
	year_communication year_loisir year_restaurant year_diverse ///
	year_sante_drugmoder year_sante_drugtrad ///
	year_sante_proddivers year_sante_appareils ///
	year_sante_medecin year_sante_labradio ///
	year_sante_servaux year_sante_servhosp year_sante_assurance)



*-----------------------------------------------*
* 1.3. Year Rent and Consumer Durables - Mixed Recall
*-----------------------------------------------*
* We will also build from previous quarter variables for consistency.

* Year Rent
gen year_logement_menage = quarter_logement_menage_loyer*4

* Year Cost of Use of consumer durables
gen year_durables_coututilis = quarter_durables_coututilis*4



*******************************************************************************
* 2. Create Yearly Total Consumption - Nominal
*******************************************************************************


*-----------------------------------------------*
* 2.1 Yearly - Food
*-----------------------------------------------*
* Restaurants were already included in quarter var.


*-----------------------------------------------*
* 2.2 Yearly - Non-Food
*-----------------------------------------------*
* Done in year_nonfood_consumation


*-----------------------------------------------*
* 2.3 Year - Total Consumption
*-----------------------------------------------*

egen year_total_consumation = ///
	rsum(year_food_consumation year_nonfood_consumation)

	
*-----------------------------------------------*
* 2.4 Year - Total Household adjusted
*-----------------------------------------------*
local year_total year_total_consumation year_food_consumation year_nonfood_consumation

foreach var in `year_total'{
	gen pc`var'eq = `var'/hhsize^(0.56)
	label var pc`var'eq "Percapita `var' adjusted for household size (economies of scale)"
}


******************************************************************************
**********************--------------------------------*************************
							** IV. Save Data **
************************--------------------------------***********************
*******************************************************************************

* Directory
cdoutput

* Save
save e06_dataframe_total_household_expenditures, replace

