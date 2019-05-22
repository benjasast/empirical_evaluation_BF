clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Compare Nominal Expenditures Results with those from WB in welfare file
* File Name: e07_dataframe_compare_expenditures_wb
* RA: Benjamin Sas
* PI: Karen Grepin				
*******************************************************************************
/* This program will merge our previous dataframe with yearly household expenditures
with that created by the WB to evaluate welfare of households in Burkina, we will
try to grasp if there are any significant differences in our calculations
*/
*******************************************************************************
* Directory
cdoutput
* Load Data
use e06_dataframe_total_household_expenditures
*******************************************************************************


******************************************************************************
**********************--------------------------------*************************
								** I. Merging **
************************--------------------------------***********************
*******************************************************************************

* Directory of using file
cddata

* Merge Variable
drop _merge

* Merge on hhid - using data only has 10,411 hh on their records
merge m:1 hhid using emc2014_welfare

****** Option use welfare file from hervé. *****
*merge m:1 hhid using emc2014_welfare_herve

*rename dnali dnalim
*rename dtot deptotnd

************************************************


duplicates drop menage_id, force

******************************************************************************
**********************--------------------------------*************************
						** II. Comparing Expenditures **
************************--------------------------------***********************
*******************************************************************************
* We will only do it for the matched observations! - not compare apples and pears
drop if _merge==1

* Only for HHs we consider present
keep if present==1

*******************************************************************************
* Option Winsorize outliers before start.
*******************************************************************************

capture ssc install winsor2

*winsor2 year_nonfood_consumation, replace cuts(0 95)
*winsor2 year_food_consumation, replace cuts(0 95)
*winsor2 year_total_consumation, replace cuts(0 95)




*******************************************************************************
* 1. Create Comparison Variables - In percentages in terms of WB data
*******************************************************************************

* Total Consumption
gen diff_total_expenses = (year_total_consumation-deptotnd)/deptotnd if mi(deptotnd)==0
gen diff_total = year_total_consumation-deptotnd

* Food Consumption
gen diff_food_expenses = (year_food_consumation - dalim)/dalim
gen diff_food = year_food_consumation - dalim

* Non Food Consumption
gen diff_nonfood_expenses = (year_nonfood_consumation-dnalim) / dnalim
gen diff_nonfood = year_nonfood_consumation-dnalim


/*
* Welfare
	*1. Replicate Wb indicator with their data for HHs
		gen welfare_wb = (deptotnd/hhsize)/deflateur // exactly the same
	*2. Out welfare indicator
		gen welfare = (year_total_consumation/hhsize) / deflateur

gen diff_welfare = (welfare - welfare_wb)/welfare_wb

*/

*******************************************************************************
* 2. Create Table to Examine Differences
*******************************************************************************

*---------------------------------------------*
*2.1 Create Table to examine differences
*---------------------------------------------*

matrix Comparison = J(3,4,.)
matrix rownames Comparison = Diff Diff-Food Diff-NonFood
matrix colnames Comparison = All-mean All-median All-max All-min
							

*---------------------------------------------*
*2.2 Differences
*---------------------------------------------*
* All differences are in percentage and for the sample

local diff_var diff_total_expenses diff_food_expenses diff_nonfood_expenses
local j = 1 // Counter variable

foreach var in `diff_var' {

* Total
	qui:sum `var' , detail // Get only one obs per HH
		scalar mean_`var' 		= r(mean) 
		scalar median_`var' 	= r(p50)
		scalar max_`var'		= r(max)
		scalar min_`var'		= r(min)

* Put results into matrix


		mat Comparison[`j',1] = mean_`var'
		mat Comparison[`j',2] = median_`var'
		mat Comparison[`j',3] = max_`var'
		mat Comparison[`j',4] = min_`var'

		local ++j

}

matrix list Comparison

* Directory
cdtables

* Save Table
outtable using WBcomparison-preliminary, mat(Comparison) replace

*******************************************************************************
* 2. Check Distribution of Differences
*******************************************************************************
* Install Nick Cox's extremes package
capture ssc install extremes

*---------------------------------------------*
*2.1 Differences in Food Expenditure
*---------------------------------------------*
* Food Differences

kdensity diff_food_expenses , ///
lcolor(navy) clwidth(thick) ///
title(Distribution differences food consumption , size(large) color(black)) ///
graphregion(color(white)) ///
legend(off)

graph export diff_food_expenses_wb.png, replace



gen inspect_food =1 if abs(diff_food_expenses)>1
kdensity diff_food_expenses if inspect_food==.


kdensity diff_food_expenses if inspect_food==. , ///
lcolor(navy) clwidth(thick) ///
title(Distribution differences food consumption , size(large) color(black)) ///
subtitle(Without outliers) ///
graphregion(color(white)) ///
legend(off)

graph export diff_food_expenses_wb_nooutliers.png, replace



sum diff_food_expenses, detail
* Observations are concentrated around zero, but there is still a -8% median value
* Large outliers to both left and right.

*---------------------------------------------*
*2.2 Differences in NonFood Expenditure
*---------------------------------------------*

kdensity diff_nonfood_expenses , ///
lcolor(navy) clwidth(thick) ///
title(Distribution differences non-food consumption , size(large) color(black)) ///
graphregion(color(white)) ///
legend(off)

graph export diff_nonfood_expenses_wb.png, replace


sum diff_nonfood_expenses,detail
* Crazy outliers up to 150% difference with WB data. Lets check those HHs
gen inspect_nonfood = 1 if abs(diff_nonfood_expenses)>1
sort inspect_nonfood menage passage

* It is obvious that the WB recognized outliers from data and performed some
* kind of inputting for them. The nature of this inputting is unkown to me.


kdensity diff_nonfood_expenses if inspect_nonfood==. , ///
lcolor(navy) clwidth(thick) ///
title(Distribution differences non-food consumption , size(large) color(black)) ///
subtitle(Without outliers) ///
graphregion(color(white)) ///
legend(off)

graph export diff_nonfood_expenses_wb_nooutliers.png, replace

*---------------------------------------------*
*2.3 Differences in Total Expenditure
*---------------------------------------------*

kdensity diff_total_expenses , ///
lcolor(navy) clwidth(thick) ///
title(Distribution differences total consumption , size(large) color(black)) ///
graphregion(color(white)) ///
legend(off) ///

graph export diff_total_expenses_wb.png, replace



sum diff_total_expenses, detail
* Outliers are very present. Lets see what happens once we exclude them

gen inspect= 1 if abs(diff_total_expenses)>1


kdensity diff_total_expenses if inspect==. , ///
lcolor(navy) clwidth(thick) ///
title(Distribution differences total consumption , size(large) color(black)) ///
subtitle(Without outliers) ///
graphregion(color(white)) ///
legend(off)

graph export diff_total_expenses_wb_nooutliers.png, replace


*******************************************************************************
* 3. Useful graphs
*******************************************************************************

scatter diff_food_expenses diff_nonfood_expenses if diff_nonfood_expenses<1000, ///
title(% Diff Food and % Diff Non-Food , size(large) color(black)) ///
graphregion(color(white))

graph export scatter_food_nonfood_wb.png, replace


*******************************************************************************
* 4. Detect Categories with trouble
*******************************************************************************


*---------------------------------------------*
*4.1 Food Categories Trouble
*---------------------------------------------*

local food_categories year_cereal year_viande year_lait_fromage /// 
year_huile_graisse year_legume year_sucre year_autre_alim ///
year_boisson_salcohol year_alcohol_drugs year_tobacco 


foreach var in `food_categories'{
gen trouble_`var' = 0
replace trouble_`var' = 1 if inspect_food==1 & `var'>dalim/2
	qui: sum trouble_`var', detail
	scalar ntrouble`var' = r(sum)
}




* Category Alcohol and Drugs is trouble - but only two households show up when dalim/2


*---------------------------------------------*
*4.2 Non-Food Categories Trouble
*---------------------------------------------*

local nonfood_categories year_sante year_education year_habillement ///
year_factures_maison year_meubles_appareils year_transport year_communication ///
year_loisir year_restaurant year_diverse year_logement_menage year_durables_coututilis


foreach var in `nonfood_categories'{
gen trouble_`var' = 0
replace trouble_`var' = 1 if inspect_nonfood==1 & `var'>dnalim
	qui: sum trouble_`var', detail
	scalar ntrouble`var' = r(sum)
}


*---------------------------------------------*
*4.3 Table for Count of cases
*---------------------------------------------*

matrix Trouble = J(22,1,.)
matrix rownames Trouble =  cereal viande lait_fromage /// 
huile_graisse legume sucre autre_alim ///
boisson_salcohol alcohol_drugs tobacco ///
sante education habillement ///
factures_maison meubles_appareils transport communication ///
loisir restaurant diverse logement_menage durables_coututilis

matrix colnames Trouble = N-Households
matrix list Trouble
							

*---------------------------------------------*
*4.4 Fill Table
*---------------------------------------------*

local j=1

foreach var in `food_categories' `nonfood_categories'{
	mat Trouble[`j',1] = scalar(ntrouble`var')
			local ++j
}

matrix list Trouble


* Directory
cdtables

* Save Table
outtable using WBcomparison-categories-trouble, mat(Trouble) replace




* Experiment, check means from wb data
svyset menage_id [pweight=hhweight], strata(strate)
gen depenses = (dalim + dnalim) / 526
replace dalim = dalim/526
replace dnalim = dnalim/526
replace year_total_consumation = year_total_consumation / 526
replace year_food_consumation = year_food_consumation/526
replace year_nonfood_consumation = year_nonfood_consumation/526

gen pc_depenses = depenses/hhsize
gen pc_alim = dalim/hhsize
gen pc_dnalim = dnalim/hhsize

svy: mean depenses
svy: mean year_total_consumation

svy: mean dalim
svy: mean year_food_consumation


svy: mean dnalim
svy: mean year_nonfood_consumation

svy: mean pc_depenses
svy: mean pc_alim
svy: mean pc_dnalim 



