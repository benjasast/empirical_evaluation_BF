clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Catastrophic Health Expenditures
* File Name: e15_CHE
* RA: Benjamin Sas
* PI: Karen Grepin	
* Date: 09/10/18 
* Version: 5			
*******************************************************************************
/* This program will calculate catastrophic health expenditures for households
in different ways
*/
*******************************************************************************
* Vars
set maxvar 10000

* Directory
cdoutput
* Load Data
use e11_dataframe_withwealthindex
*******************************************************************************
* Required Package
*capture ssc install conindex
* Check
*gen random = runiform()
*drop if random < .90

* Include Survey Design
svyset menage_id [pweight=hhweight], strata(strate)


*******************************************************************************
***************--------------------------------------------********************
			** I. Quarter - CHE for each passage **
***************--------------------------------------------********************
*******************************************************************************
/* The exercise is to treat each passage as its own dataunit and see how many
households with CHE we would estimate only with this data

The main variables are che or: catastrophic health expenditures, this variable has
5 different definitions, with different thresholds:

che1: spending on health / total consumption
che2: spending on health / (total consumption- spending on health)
che3: spending on health / non-food consumption
che4: spending on health / (non-food consumption - spending on health)

che5: spending on health / (total consumption - basic subsistence needs)

From Lu- Social Science and Medicine 2017: " Basic subsistence needs were calculated
as the average annual food expenditures whose food shares were in the 45th and
55th percentile"

*/


*******************************************************************************
* 1. Generate Neccesary Variables
*******************************************************************************


*--------------------------------------------------*
*1.1 Quaterly Data
*--------------------------------------------------*


	*******************************************************************************
	* 1.11 Generate Quarter Share of Health
	*******************************************************************************

	* Share of Health out of Total Consumption
	gen quarter_share_health1 = quarter_sante / quarter_total_consumation

	* Share of Health out of Total Consumption exluding Health
	gen quarter_share_health2 = quarter_sante / (quarter_total_consumation - quarter_sante)

	* Share of Health out of Total of Non-Food Expenditures
	gen quarter_share_health3 = quarter_sante / quarter_nonfood_consumation

	* Share of Health out of Total of Non-Food Expenditures excluding Health
	gen quarter_share_health4 = quarter_sante / (quarter_nonfood_consumation - quarter_sante)


	*******************************************************************************
	* 1.12 Neccesary  share for CHE-5
	*******************************************************************************

	* Get Food share out of total consumption
	gen quarter_food_share = quarter_food_consumation / quarter_total_consumation

	* Get Food equivalent spending, theta: 0.56 from Xu (2005)
	gen quarter_foodeq = quarter_food_consumation / hhsize^(0.56)

	*gen quarter_sharefood = quarter_food_consumation / quarter_total_consumation^(0.56)

	* * Share of health out of total consumption minus basic substinance
	gen quarter_share_health5 =.

	* Create variable with substinance income for each hh
	gen quarter_consumation_subsistance=.

	* Tag Percentiles of share of food for households
	*capture ssc install xtile // Needed user-package


	*--------------------------------------------------*
	* 1.13 Detect 45th and 55th percentiles of food share
	*--------------------------------------------------*

	forvalues i = 1(1)4{

	xtile quarter_food_share`i' = quarter_food_share if passage==`i' [pweight=hhweight], nq(100) 

	* Tag Variables betwen the 45th and 55th percentile
	gen quarter_4555_foodshare`i' = 0

	replace quarter_4555_foodshare`i' = 1 if quarter_food_share`i' >=45 & quarter_food_share`i'<=55 & !mi(quarter_4555_foodshare`i')

	* Get pc substinance income

	sum quarter_foodeq if quarter_4555_foodshare`i' == 1 & present==1
		scalar pcquarter_basic_substenancep`i' = r(mean)

	*--------------------------------------------------*
	* 1.14 Create Variable CHE-5
	*--------------------------------------------------*	
	replace quarter_share_health5 = quarter_sante / (quarter_total_consumation - hhsize^(0.56) * scalar(pcquarter_basic_substenancep`i') ) if passage==`i'
	replace quarter_share_health5 = quarter_sante / (quarter_total_consumation - quarter_food_consumation) if quarter_share_health5<0 & passage==`i'

	* Replace Variable with substinance income for each HH
	replace quarter_consumation_subsistance = quarter_total_consumation - hhsize^(0.56) * scalar(pcquarter_basic_substenancep`i') if passage==`i'

	}


*--------------------------------------------------*
*1.2 Year Data
*--------------------------------------------------*

	*******************************************************************************
	* 1.11 Generate year Share of Health
	*******************************************************************************

	* Share of Health out of Total Consumption
	gen year_share_health1 = year_sante / year_total_consumation

	* Share of Health out of Total Consumption exluding Health
	gen year_share_health2 = year_sante / (year_total_consumation - year_sante)

	* Share of Health out of Total of Non-Food Expenditures
	gen year_share_health3 = year_sante / year_nonfood_consumation

	* Share of Health out of Total of Non-Food Expenditures excluding Health
	gen year_share_health4 = year_sante / (year_nonfood_consumation - year_sante)


	*******************************************************************************
	* 1.12 Neccesary  share for CHE-5
	*******************************************************************************

	* Get Food share out of total consumption
	gen year_food_share = year_food_consumation / year_total_consumation

	* Get Food equivalent spending, theta: 0.56 from Xu (2005)
	gen year_foodeq = year_food_consumation / hhsize^(0.56)

	*gen year_sharefood = year_food_consumation / year_total_consumation^(0.56)

	* * Share of health out of total consumption minus basic substinance
	gen year_share_health5 =.

	* Create variable with substinance income for each hh
	gen year_consumation_subsistance=.

	*--------------------------------------------------*
	* 1.13 Detect 45th and 55th percentiles of food share
	*--------------------------------------------------*


	xtile year_food_share1 = year_food_share [pweight=hhweight], nq(100) 

	* Tag Variables betwen the 45th and 55th percentile
	gen year_4555_foodshare = 0

	replace year_4555_foodshare = 1 if year_food_share1 >=45 & year_food_share1<=55 & !mi(year_4555_foodshare)

	* Get pc substinance income

	sum year_foodeq if year_4555_foodshare == 1 & present==1
		scalar pcyear_basic_substenancep = r(mean)

	*--------------------------------------------------*
	* 1.14 Create Variable CHE-5
	*--------------------------------------------------*	
	replace year_share_health5 = year_sante / (year_total_consumation - hhsize^(0.56) * scalar(pcyear_basic_substenancep) ) 
	replace year_share_health5 = year_sante / (year_total_consumation - year_food_consumation) if year_share_health5<0 

	* Replace Variable with substinance income for each HH
	replace year_consumation_subsistance = year_total_consumation - hhsize^(0.56) * scalar(pcyear_basic_substenancep)




	
	
*******************************************************************************
* 3. Generate CHE Dummies, and related variables
*******************************************************************************



* Start the Parallel Loop
local che_types  "1 	1 		1 		3 		3 		3		5		5		5"
local thresholds "5 	10		20		20 		30		40		20		30		40"
local n : word count `che_types'

 forvalues i = 1/`n' {
  local j : word `i' of `che_types' // j is our type of CHE
  local num : word `i' of `thresholds' // num is the threshold
  di " New Loop - CHE TYPE `j' With Threshold `num'"



*-------------------------------------------------*
*3.1 Quaterly Data
*-------------------------------------------------*


	*-------------------------------------------------*
	*3.11 CHEs
	*-------------------------------------------------*

	gen q_che`j'_`num' = ( quarter_share_health`j' > `num'/100 ) if !mi(quarter_sante) & present==1


	*-------------------------------------------------*
	*3.12 Overshoot
	*-------------------------------------------------*

	gen q_over`j'_`num' = quarter_share_health`j' - `num'/100 if !mi(quarter_sante) & present==1
		replace q_over`j'_`num' = 0 if q_over`j'_`num'<0 & !mi(quarter_sante)


	*-------------------------------------------------*
	*3.13 Mean Positive Overshoot
	*-------------------------------------------------*

	gen q_mpover`j'_`num' = quarter_share_health`j' - `num'/100 if q_che`j'_`num'==1


*-------------------------------------------------*
*3.2 Yearly Data
*-------------------------------------------------*


	*-------------------------------------------------*
	*3.21 CHEs
	*-------------------------------------------------*

	gen y_che`j'_`num' = ( year_share_health`j' > `num'/100 ) if !mi(year_sante) & present_all==1


	*-------------------------------------------------*
	*3.22 Overshoot
	*-------------------------------------------------*

	gen y_over`j'_`num' = year_share_health`j' - `num'/100 if !mi(year_sante) & present_all==1
		replace y_over`j'_`num' = 0 if y_over`j'_`num'<0 & !mi(quarter_sante)


	*-------------------------------------------------*
	*3.23 Mean Positive Overshoot
	*-------------------------------------------------*

	gen y_mpover`j'_`num' = year_share_health`j' - `num'/100 if y_che`j'_`num'==1


}
*******************************************************************************
***************--------------------------------------------********************
						** III. Save Data **
***************--------------------------------------------********************
*******************************************************************************
capture drop percentile*
capture drop pc*
capture drop aux*

* Directory
cdoutput

* Save
save e12_dataframe_CHEs_households, replace



