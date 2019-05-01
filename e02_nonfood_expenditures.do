clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Non-Food Expenditures Excluding Health
* File Name: e02_nonfood_expenditures
* RA: Benjamin Sas
* PI: Karen Grepin				
*******************************************************************************
* Start Loop
forvalues i=1(1)4{
*******************************************************************************
* Set Directory
cddata
*******************************************************************************
* Load Data
use emc2014_p`i'_conso3mois
************************************************************ 2 1*******************
* Create Household IDs
gen menage_id = hhid

* Create Household - Product ID
gen menage_id_product = strofreal(menage_id) + "p" + strofreal(product)

*******************************************************************************
**********************--------------------------------*************************
							** Data Checks **
************************--------------------------------***********************
*******************************************************************************

* Data Check - Is any observation marked as gift, purchase, or self production at the same time?
gen is_achat=0 
replace is_achat=1 		if achat!=.

gen is_cadeau = 0
replace is_cadeau =1 	if cadeau!=.

* 2909 observations they look fine upon closer inspection
count if (is_achat==1 & is_cadeau==1)
*br if (is_achat==1 & is_cadeau==1)

*******************************************************************************
* Data Check - Observations per household
*******************************************************************************
gen ones = 1
by menage_id, sort: egen obs_menage = total(ones)

*histogram obs_menage
* Some outliers on the right with over 50obs - lots of different consumed items, which make sense.

*histogram hhsize1
* some households have over 50 members, strange!


*******************************************************************************
* Datacheck - Duplicates Check
*******************************************************************************

* Data Check - No more than one observation per product per household
duplicates tag menage_id_product, gen(tag)
* Lots of duplicates in many categories, but they seem to be unique observations and not typos.

* We need to consolidate observations on the household level

* Create totals for menage_id product
bysort menage_id_product: 	egen aux_achat = 	total(achat)
bysort menage_id_product: 	egen aux_cadeau = 	total(cadeau)

* Replace for duplicates
replace achat = 	aux_achat 		if tag>0
replace cadeau = 	aux_cadeau 		if tag>0

* Drop auxiliar variables
drop aux*

* Keep only first observation for duplicates
duplicates drop menage_id_product , force


*******************************************************************************
**********************--------------------------------*************************
					  ** NonFood Expenditures per Household **
************************--------------------------------***********************
*******************************************************************************
/* Three categories will be essential here: Health, Education and the rest

*/

*******************************************************************************
* 1. Total Non-Food Expenditures
*******************************************************************************
egen nonfood_consumation = rsum (achat cadeau) if (product!=213) // No funerals

*******************************************************************************
* 2. Health Expenditures
*******************************************************************************
* Health Expenditures
egen sante = rsum(achat cadeau) if (product>=149) & (product<=156) | (product==208)

* More detail for health
egen sante_drugmoder 		= rsum(achat cadeau) if product==149
egen sante_drugtrad 		= rsum(achat cadeau) if product==150
egen sante_proddivers		= rsum(achat cadeau) if product==151
egen sante_appareils		= rsum(achat cadeau) if product==152
egen sante_medecin			= rsum(achat cadeau) if product==153
egen sante_labradio			= rsum(achat cadeau) if product==154
egen sante_servaux 			= rsum(achat cadeau) if product==155
egen sante_servhosp			= rsum(achat cadeau) if product==156
egen sante_assurance		= rsum(achat cadeau) if product==208

*******************************************************************************
* 3. Educational Expenditures
*******************************************************************************
* Education Expenditures
egen education = rsum(achat cadeau) if (product>=196) & (product<=199)
*******************************************************************************
* 4. Other Expenditures
*******************************************************************************
* These products start at 66 but the first ones are in complete disorder, we will
* add those in the end.

egen habillement = rsum(achat cadeau) ///
if (product>=84) & (product<=99)

egen factures_maison = rsum(achat cadeau) ///
if ( (product>=100) & (product<=113) ) | ( (product>=66) & (product<=68) )

egen meubles_appareils = rsum(achat cadeau) ///
if (product>=114) & (product<=148) // We will substract the consumer durables from here
		egen aux5 = rsum(achat cadeau) if (product>=133 & product<=135)
			replace meubles_appareils = meubles_appareils - aux5 if !mi(aux5) 
		
egen transport = rsum(achat cadeau) ///
if ( (product>=167) & (product<=171) ) | ( (product>=72) & (product<=76) ) // We want to exclude cars. moto, pruchase

egen communication = rsum(achat cadeau) ///
if ( (product>=172) & (product<=173)) | product==77 // We will have to add more in here a lot lost

egen loisir = rsum(achat cadeau) ///
if ( ((product>=174) & (product<=183)) | ( product>=193 & product<=195)	) | product==79 // Exclude consumer durables

egen restaurant = rsum(achat cadeau) ///
if (product==200) | product==80 // We will have to add a lot lost in data up there

egen diverse = rsum(achat cadeau) ///
if  (product>=202 & product<=207)  | (product>=209 & product<=212) | ( (product>=81) & (product<=82) ) | (product==201)

*******************************************************************************
* 6. Calculate Expenditures per HH
*******************************************************************************


local list nonfood_consumation sante education habillement factures_maison ///
meubles_appareils transport communication loisir restaurant diverse ///
sante_drugmoder sante_drugtrad sante_proddivers sante_appareils sante_medecin ///
sante_labradio sante_servaux sante_servhosp sante_assurance

foreach var in `list' {
	bysort menage_id: egen quarter_`var' = total(`var')
	label var quarter_`var' "Total value `var' by HH 3 month recall"
}



*******************************************************************************
* 2. Other Expenditures - Additions, begging of list is not in order so we add them up
* to their corresponding category. From 66 to 83 we need to add
*******************************************************************************
/* We will name code names of products that need to be added up there in code

Category: Factures Maison: 66, 67, 68

Category: Transport: 72, 74, 75, 76, 

Category Communication: 77, 

Category Loisir: 79

Category Restanrant-Hotel: 80, 

Category Divers: 81,82

We do not want to include: Funerals(213), 

A careful reader will note that there are some items missing in the 66-83 range, 
this is because we code only items that appeared in the survey, and not all asked,
to do so we appended all answers and checked which items actually appeared.

*/
*******************************************************************************
**********************--------------------------------*************************
					  ** Some Housekeeping **
************************--------------------------------***********************
*******************************************************************************


*******************************************************************************
		** Some Variable Name to consolidate datasets of each passage **
*******************************************************************************
rename hhsize`i' hhsize
rename res_entr`i' res_entr
rename hhweight`i' hhweight


*******************************************************************************
**********************--------------------------------*************************
					  ** Saving Aggregated Data **
************************--------------------------------***********************
*******************************************************************************
* Keep only first observation of each household
duplicates drop menage_id, force
* Create Variable for passage
gen passage = `i'
* Create Matching ID
gen menage_id_passage = strofreal(menage_id) + "passage" + strofreal(`i')

* Aggregated Variables to keep
keep zd hhid region milieu strate menage hhsize res_entr ///
hhweight menage_id menage_id_passage quarter*

* Switch Directory
cdoutput
* Save
save e02_p`i'_nonfood_agg, replace
}



*******************************************************************************
**********************--------------------------------*************************
			** Special Recall for Non-Food Passage 2,3,4 **
************************--------------------------------***********************
*******************************************************************************
/* This list of items was asked with a 7day recall and excluded from the 3 month
questions only on this passage !!
We will scale them accordingly to represent 3 month figures
*/
clear all

forvalues i = 2(1)4{

* Load Data
cddata
use emc2014_p2_conso7nonalimjours
gen menage_id = hhid
gen special = 1
gen passage = `i'

* Categorize Expenditures and totals
egen nonfood_consumation = rsum (achat cadeau) if (product!=213) // No funerals

egen sante = rsum(achat cadeau) if (product>=149) & (product<=156) | (product==208)
egen sante_drugmoder 		= rsum(achat cadeau) if product==149
egen sante_drugtrad 		= rsum(achat cadeau) if product==150
egen sante_proddivers		= rsum(achat cadeau) if product==151
egen sante_appareils		= rsum(achat cadeau) if product==152
egen sante_medecin			= rsum(achat cadeau) if product==153
egen sante_labradio			= rsum(achat cadeau) if product==154
egen sante_servaux 			= rsum(achat cadeau) if product==155
egen sante_servhosp			= rsum(achat cadeau) if product==156
egen sante_assurance		= rsum(achat cadeau) if product==208


egen education = rsum(achat cadeau) if (product>=196) & (product<=199)

egen habillement = rsum(achat cadeau) ///
if (product>=84) & (product<=99)

egen factures_maison = rsum(achat cadeau) ///
if ( (product>=100) & (product<=113) ) | ( (product>=66) & (product<=68) )

egen meubles_appareils = rsum(achat cadeau) ///
if (product>=114) & (product<=148)

egen transport = rsum(achat cadeau) ///
if ( (product>=157) & (product<=171) ) | ( (product>=72) & (product<=76) )

egen communication = rsum(achat cadeau) ///
if ( (product>=172) & (product<=173)) | product==77 // We will have to add more in here a lot lost

egen loisir = rsum(achat cadeau) ///
if ( (product>=174) & (product<=195) ) | product==79

egen restaurant = rsum(achat cadeau) ///
if (product==200) | product==80 // We will have to add a lot lost in data up there

egen diverse = rsum(achat cadeau) ///
if  (product>=202 & product<=207)  | (product>=209 & product<=212) | ( (product>=81) & (product<=82) ) | (product==201)

* Totals for HH
local list_special nonfood_consumation sante sante_drugmoder sante_drugtrad  ///
sante_proddivers sante_appareils sante_medecin sante_labradio sante_servaux sante_servhosp education habillement factures_maison ///
sante_assurance ///
meubles_appareils transport communication loisir restaurant diverse

foreach var in `list_special' {
	bysort menage_id: egen quarter_`var' = total(`var')
	replace quarter_`var' = quarter_`var'/7 * 91 if passage==2
	replace quarter_`var' = quarter_`var'/7 * 92 if passage==3 | passage==4
	label var quarter_`var' "Total value `var' by HH 3 month recall"
}

duplicates drop menage_id, force


*** Append with passage 2 and get total for quarter passage 2
cdoutput
append using e02_p`i'_nonfood_agg.dta


*bysort menage_id: egen aux2 = total(quarter_diverse)
*drop quarter_diverse
*rename aux2 quarter_diverse

foreach var in `list_special' {
	bysort menage_id: egen aux = total(quarter_`var')
	drop quarter_`var'
	rename aux quarter_`var'
	label var quarter_`var' "Total value `var' by HH 3 month recall"
}



* Keep only first observation of each household
replace passage=`i' if mi(passage)==1
replace menage_id_passage = strofreal(menage_id) + "passage" + strofreal(passage) ///
							if mi(menage_id_passage)==1
							

duplicates drop menage_id_passage, force

* Aggregated Variables to keep
keep zd hhid region milieu strate menage hhsize res_entr ///
hhweight menage_id menage_id_passage passage quarter*

* Switch Directory
cdoutput
* Save
save e02_p`i'_nonfood_agg, replace

}

*******************************************************************************
**********************--------------------------------*************************
				** DataFrame -> Merging and Rectangularization of Data **
************************--------------------------------***********************
*******************************************************************************
/* We will create the neccesary DataFrame for our data in order to input the
aggregated results in there for every household.
*/


*******************************************************************************
* 1. Create the observational Units: Household-Passage
*******************************************************************************
clear all
* Directory
cdoutput

* Load passage 1 with all household IDs - 10,800
use e02_p1_nonfood_agg.dta

*Keep only Household IDs - There are only 10,799 one missing compared to 7jours dataset.
keep menage_id


*******************************************************************************
* 2. Create the DataFrame for the aggregated household data
*******************************************************************************
* Passage units
forvalues i=1(1)4{
	gen passage`i' = `i'
}

* Now observation will be household-passage
reshape long passage, i(menage_id) j(p)
drop p

* Create Merge identifier
gen menage_id_passage = strofreal(menage_id) + "passage" + strofreal(passage)


*******************************************************************************
* 3. Merge with other Datasets for non-food
*******************************************************************************
forvalues i=1(1)4 {
	merge 1:1 menage_id_passage using e02_p`i'_nonfood_agg, replace update
	drop _merge
}


*******************************************************************************
		** Strange typo from dataset No passage on 3 observations **
*******************************************************************************
replace passage = 2 in 8145
replace passage = 3 in 8146
replace passage = 4 in 43203

*******************************************************************************
		** Save Data **
*******************************************************************************

save e02_nonfood_agg_dataframe, replace









