clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Add Food Security Module
* File Name: e09_food_security
* RA: Benjamin Sas
* PI: Karen Grepin	
* Date: 10/10/18
* Version: 1			
*******************************************************************************
/* We will grab food the food security module, add it to our dataframe, and then
calculate a food security score for each household.
*/
*******************************************************************************





******************************************************************************
**********************--------------------------------*************************
								** ROUNDs **
************************--------------------------------***********************
*******************************************************************************

forvalues i = 3/4{

	******************************************************************************
	**********************--------------------------------*************************
							** I. Grab Data from Module **
	************************--------------------------------***********************
	*******************************************************************************

	* Directory
	cddata

	* Load Data
	use emc2014_p4_securitealimentaire


	******************************************************************************
	**********************--------------------------------*************************
							** II. Create Score for each HH **
	************************--------------------------------***********************
	*******************************************************************************


	*-----------------------------------------------------------------*
	* 2.1 Rename and recode variables according to USDA classification
	*-----------------------------------------------------------------*


	* SA01
		rename SA01 q2

	* SA02
		rename SA02 q4
		
	* SA03
		rename SA03 q5

	* SA04 (Yes/NO for scores)
		rename SA04 q8

	* SA05 (Yes/NO for scores)
		rename SA05 q9

	* SA06
		rename SA06 q3
		
	* SA07 (Yes/NO for scores)
		rename SA07 q10

	* SA08 (Yes/NO for scores)
		rename SA08 q12

	* SA09
		rename SA09 qchildren

	* SA10
		rename SA10 q6

	* SA11
		rename SA11 q7
		



	*-----------------------------------------------------------------*
	* 2.2 Modify variables to be compatible with scores
	*-----------------------------------------------------------------*
	* Drop those with tons of missings (always the same), the rest are so little observations
	* that doing the inputting is a waste of time.

	drop if mi(q2) & mi(q4) & mi(q5)
	drop if mi(q2)
	drop if mi(q12)
	drop if mi(q10)


	* In original Paper have three options: Often True, Sometimes True, and Never. 
	* In EMC2014 were asked as Yes/NO
	local list1 q2 q4 q5 q3 q6 q7

	* These are Yes/NO questions always.
	local list2 q8 q10 q12

	* Funny enough nothing is neccesary as to compute scores only Affirmative or negative
	* is neccesary.

	* So we will create dummies to count
	foreach var in `list1' `list2'{

	gen Q`var' = (`var'==1) & !mi(`var')
	}

	local dummy_affirmative Qq2 Qq4 Qq5 Qq3 Qq6 Qq7 Qq8 Qq10 Qq12

	*-----------------------------------------------------------------*
	* 2.3 Count Affirmative Answers Per household
	*-----------------------------------------------------------------*

	egen q_affirmative = rsum(`dummy_affirmative')

	*-----------------------------------------------------------------*
	* 2.4 Classification of Household Given responses
	*-----------------------------------------------------------------*

	/* We will use a simple classification, a household with more than three affirmatives
	will be classified as insecure as it is in: Bickel, G., Nord, M., Price, C., Hamilton, W., & Cook, J. (2000).
	*/

	gen q_foodinsecure = (q_affirmative >=3)

	gen quarter_foodinsecure_hunger = (q_affirmative >= 6)


	******************************************************************************
	**********************--------------------------------*************************
							** III. Save and Merge with DataFrame **
	************************--------------------------------***********************
	*******************************************************************************

	* Directory
	cdoutput

	* Passage
	gen passage=`i'

	* Keep only relevant vars
	keep q_foodinsecure q_affirmative quarter_foodinsecure_hunger zd menage passage

	* Rename them
	rename q_foodinsecure quarter_foodinsecure
	rename q_affirmative quarter_nfoodinsecure

	* Drop
	capture drop _merge

	* Save
	save e09_food_security_p`i', replace
}



	*-----------------------------------------------------------------*
	* 2.1 Merge with dataframe
	*-----------------------------------------------------------------*

	* Load Data
	use e08_dataframe_with_deflator


	* Merge
	capture drop _merge
	merge m:1 zd menage passage using e09_food_security_p3

	* Drop households not on original sample?
	drop if _merge==2
	drop _merge
	
	merge m:1 zd menage passage using e09_food_security_p4


	*-----------------------------------------------------------------*
	* 2.2 Save
	*-----------------------------------------------------------------*

	save e08_dataframe_with_foodsecurity, replace







