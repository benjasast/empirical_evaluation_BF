clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Shock Module
* File Name: e17_shock_module
* RA: Benjamin Sas
* PI: Karen Grepin	
* Date: 07/09/18 
* Version: 1			
*******************************************************************************
/* We will import and process all relevant information of the Shock Module and
Merge it into our Dataframe.
*/
*******************************************************************************
* Vars
set maxvar 10000

* Directory
cddata
* Load Data
use emc2014_p3_chocs
*******************************************************************************



*******************************************************************************
***************--------------------------------------------********************
					** 	I. Rescale Data **
***************--------------------------------------------********************
*******************************************************************************
/* Data from the module is Episode-Household, we want it to be simply household */

*-------------------------------------------------*
*1.1 Declares Coping - In general
*-------------------------------------------------*
gen aux = (CS1==1)
bysort zd menage: egen choc_coping = max(aux) 
drop aux

* Coping Strategies declared for all households that declare disease
levelsof CS4A, local(coping)
 
foreach l of local coping {
	gen choc_coping_`l' = ( (CS4A==`l' | CS4B==`l' | CS4C==`l') & choc_coping==1 ) if CS1==1
 }

* Assign labels
forvalues i = 1(1)1{
label var choc_coping_1 "1 Use of savings"
label var choc_coping_2 "2 Aid of parents or friends"
label var choc_coping_3 "3 Aid of the government"
label var choc_coping_4 "4 Aid of religious organizations or NGOs"
label var choc_coping_5 "5 Marry the children"
label var choc_coping_6 "6 Change consumption habits"
label var choc_coping_7 "7 Work active hh members took additional employment"
label var choc_coping_8 "8 Work inactive hh members took additional employment"
label var choc_coping_9 "9 Children under 15 y/o started working"
label var choc_coping_10 "10 Children were withdrawn from school"
label var choc_coping_11 "11 Migration of one or more hh members"
label var choc_coping_12 "12 Reduction of education and health expenses"
label var choc_coping_13 "13 Took out a loan"
label var choc_coping_14 "14 Sell of agricultural equipment"
label var choc_coping_15 "15 Sell of household durables"
label var choc_coping_16 "16 Sell of land or real estate property"
label var choc_coping_17 "17 Sell of livestock"
label var choc_coping_18 "18 Vente de b�tail"
label var choc_coping_19 "19 Practice more fishing"
label var choc_coping_20 "20 Send children to other households"
label var choc_coping_21 "21 Engage in spiritual activities"
label var choc_coping_22 "22 Off-Season farming"
label var choc_coping_23 "23 Other strategy (identify)"
label var choc_coping_24 "24 No strategy at all"
}

*-------------------------------------------------*
*1.1 Declares Grave Disease or Injury
*-------------------------------------------------*
gen aux = (CS0==113 & CS1==1)
bysort zd menage: egen choc_maladiegrave = max(aux) 

* Declares Grave Diases or Injury as their most important problem
drop aux
gen aux = (CS0==113 & CS1==1 & CS2==1)
bysort zd menage: egen choc_maladiegrave_plusimportant = max(aux) 
drop aux

* Coping Strategies declared for all households that declare disease
levelsof CS4A, local(coping)
 
foreach l of local coping {
	gen choc_copingmaladie_`l' = ( (CS4A==`l' | CS4B==`l' | CS4C==`l') & choc_maladiegrave==1 ) if (CS1==1 & choc_maladiegrave==1)
 }

* Assign labels
forvalues i = 1(1)1{
label var choc_copingmaladie_1 "1 Use of savings"
label var choc_copingmaladie_2 "2 Aid of parents or friends"
label var choc_copingmaladie_3 "3 Aid of the government"
label var choc_copingmaladie_4 "4 Aid of religious organizations or NGOs"
label var choc_copingmaladie_5 "5 Marry the children"
label var choc_copingmaladie_6 "6 Change consumption habits"
label var choc_copingmaladie_7 "7 Work active hh members took additional employment"
label var choc_copingmaladie_8 "8 Work inactive hh members took additional employment"
label var choc_copingmaladie_9 "9 Children under 15 y/o started working"
label var choc_copingmaladie_10 "10 Children were withdrawn from school"
label var choc_copingmaladie_11 "11 Migration of one or more hh members"
label var choc_copingmaladie_12 "12 Reduction of education and health expenses"
label var choc_copingmaladie_13 "13 Took out a loan"
label var choc_copingmaladie_14 "14 Sell of agricultural equipment"
label var choc_copingmaladie_15 "15 Sell of household durables"
label var choc_copingmaladie_16 "16 Sell of land or real estate property"
label var choc_copingmaladie_17 "17 Sell of livestock"
label var choc_copingmaladie_18 "18 Vente de b�tail"
label var choc_copingmaladie_19 "19 Practice more fishing"
label var choc_copingmaladie_20 "20 Send children to other households"
label var choc_copingmaladie_21 "21 Engage in spiritual activities"
label var choc_copingmaladie_22 "22 Off-Season farming"
label var choc_copingmaladie_23 "23 Other strategy (identify)"
label var choc_copingmaladie_24 "24 No strategy at all"
}

*-------------------------------------------------*
*1.2 Declares Agriculture Related Shock
*-------------------------------------------------*
gen aux = ( (CS0==101 | CS0==103 | CS0==104 | CS0==105 | CS0==106) & CS1==1)
bysort zd menage: egen choc_agriculture = max(aux) 
drop aux


* Coping Strategies declared for all households that declare Agriculture Shock
foreach l of local coping {
	gen choc_copingagriculture_`l' = ( (CS4A==`l' | CS4B==`l' | CS4C==`l') & choc_agriculture==1 ) if (CS1==1 & choc_agriculture==1)
 }

 * Assign labels
forvalues i = 1(1)1{
label var choc_copingagriculture_1 "1 Use of savings"
label var choc_copingagriculture_2 "2 Aid of parents or friends"
label var choc_copingagriculture_3 "3 Aid of the government"
label var choc_copingagriculture_4 "4 Aid of religious organizations or NGOs"
label var choc_copingagriculture_5 "5 Marry the children"
label var choc_copingagriculture_6 "6 Change consumption habits"
label var choc_copingagriculture_7 "7 Work active hh members took additional employment"
label var choc_copingagriculture_8 "8 Work inactive hh members took additional employment"
label var choc_copingagriculture_9 "9 Children under 15 y/o started working"
label var choc_copingagriculture_10 "10 Children were withdrawn from school"
label var choc_copingagriculture_11 "11 Migration of one or more hh members"
label var choc_copingagriculture_12 "12 Reduction of education and health expenses"
label var choc_copingagriculture_13 "13 Took out a loan"
label var choc_copingagriculture_14 "14 Sell of agricultural equipment"
label var choc_copingagriculture_15 "15 Sell of household durables"
label var choc_copingagriculture_16 "16 Sell of land or real estate property"
label var choc_copingagriculture_17 "17 Sell of livestock"
label var choc_copingagriculture_18 "18 Vente de b�tail"
label var choc_copingagriculture_19 "19 Practice more fishing"
label var choc_copingagriculture_20 "20 Send children to other households"
label var choc_copingagriculture_21 "21 Engage in spiritual activities"
label var choc_copingagriculture_22 "22 Off-Season farming"
label var choc_copingagriculture_23 "23 Other strategy (identify)"
label var choc_copingagriculture_24 "24 No strategy at all"
}

*-------------------------------------------------*
*1.3 Declares Income Shock - Not related to Agriculture
*-------------------------------------------------*
gen aux = (	(CS0==108 | CS0==109 | CS0==110 | CS0==111 | CS0==112) & CS1==1)
bysort zd menage: egen choc_revenu = max(aux) 
drop aux


* Coping Strategies declared for all households that declare Agriculture Shock
foreach l of local coping {
	gen choc_copingrevenu_`l' = ( (CS4A==`l' | CS4B==`l' | CS4C==`l') & choc_revenu==1 ) if (CS1==1 & choc_revenu==1)
 }

* Assign labels
forvalues i = 1(1)1{
label var choc_copingrevenu_1 "1 Use of savings"
label var choc_copingrevenu_2 "2 Aid of parents or friends"
label var choc_copingrevenu_3 "3 Aid of the government"
label var choc_copingrevenu_4 "4 Aid of religious organizations or NGOs"
label var choc_copingrevenu_5 "5 Marry the children"
label var choc_copingrevenu_6 "6 Change consumption habits"
label var choc_copingrevenu_7 "7 Work active hh members took additional employment"
label var choc_copingrevenu_8 "8 Work inactive hh members took additional employment"
label var choc_copingrevenu_9 "9 Children under 15 y/o started working"
label var choc_copingrevenu_10 "10 Children were withdrawn from school"
label var choc_copingrevenu_11 "11 Migration of one or more hh members"
label var choc_copingrevenu_12 "12 Reduction of education and health expenses"
label var choc_copingrevenu_13 "13 Took out a loan"
label var choc_copingrevenu_14 "14 Sell of agricultural equipment"
label var choc_copingrevenu_15 "15 Sell of household durables"
label var choc_copingrevenu_16 "16 Sell of land or real estate property"
label var choc_copingrevenu_17 "17 Sell of livestock"
label var choc_copingrevenu_18 "18 Vente de b�tail"
label var choc_copingrevenu_19 "19 Practice more fishing"
label var choc_copingrevenu_20 "20 Send children to other households"
label var choc_copingrevenu_21 "21 Engage in spiritual activities"
label var choc_copingrevenu_22 "22 Off-Season farming"
label var choc_copingrevenu_23 "23 Other strategy (identify)"
label var choc_copingrevenu_24 "24 No strategy at all"
}


*-------------------------------------------------*
*1.4 Declares someone died in household
*-------------------------------------------------*
gen aux = (	(CS0==114 | CS0==115) & CS1==1)
bysort zd menage: egen choc_decede = max(aux) 
drop aux


*-------------------------------------------------*
*1.5 Declares other shock
*-------------------------------------------------*
gen aux = (	(CS0==102 | CS0==116 | CS0==117 | CS0==118 | CS0==119) & CS1==1	)
bysort zd menage: egen choc_autre = max(aux) 
drop aux



*******************************************************************************
***************--------------------------------------------********************
					** 	II. Merge to DataFrame **
***************--------------------------------------------********************
*******************************************************************************

* Relevant varibles and HH as unit of analysis
keep zd menage choc*
duplicates drop zd menage, force

* Directory
cdoutput

* Merge
merge 1:m zd menage using e13_dataframe_impov_households
drop if _merge==1
drop _merge

* Save
order choc*, last
save e14_dataframe_with_shocks, replace






