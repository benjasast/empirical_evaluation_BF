clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Catastrophic Health Expenditures
* File Name: e16_impoverishing
* RA: Benjamin Sas
* PI: Karen Grepin	
* Date: 07/09/18 
* Version: 1			
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
use e12_dataframe_CHEs_households
*******************************************************************************

* Check
*gen random = runiform()
*drop if random < .90


*******************************************************************************
***************--------------------------------------------********************
			** 	I. Create Pre-OOP spending Consumption **
***************--------------------------------------------********************
*******************************************************************************
/* Three variables will be key here:
	- quarter/year_total_consumation
	- quarter/year_sante
	- extreme poverty line (to be created)
	
	
	The main assumption is that in the absence of OOP payments that money would
	have been used for consumption in other areas, which a lot of papers have
	disproven. (Flores, argues up to 75% comes from coping mechanisms)	
*/

*-------------------------------------------------*
*1.1 Pre-OOP and Post-OOP Payments
*-------------------------------------------------*

gen quarter_preoop_consumation = 	quarter_total_consumation if !mi(quarter_sante)
gen quarter_postoop_consumation = 	quarter_total_consumation - quarter_sante if !mi(quarter_sante)

gen year_preoop_consumation = 		year_total_consumation if !mi(year_sante)
gen year_postoop_consumation = 		year_total_consumation - year_sante if !mi(year_sante)


*-------------------------------------------------*
*1.2 Define Poverty Lines
*-------------------------------------------------*
* Another important point are the poverty lines to be used, we want to evaluate
* four of them:

/*
	1. The National Poverty line of 153530 CFA annual per person
	2. The National Seiul alimentaire of 102040 CFA annual per person
	3. The $1.90 per day of the WB adjusted for PPP and inflation
	4. The $3.20 per day of the WB adjusted for PPP and inflation- for lower middle income countries
*/


*  Poverty Lines - Year
		gen year_pline1 = 	153530 * hhsize
		gen year_pline2 = 	102040 * hhsize
		gen year_pline3 = 	1.90	* 526 * 365 * hhsize * (1/2.5) * 1.041		// PPP to US 2011 is 2.5, inflation from 2011 to 2014 was 4.1%
		gen year_pline4 = 	3.20	* 526 * 365 * hhsize * (1/2.5) * 1.041		// PPP to US 2011 is 2.5, inflation from 2011 to 2014 was 4.1%

* Poverty Lines - Quarter

	forvalues q = 1/4{
		gen quarter_pline`q' = 				year_pline`q' / 4 if present==1
}



*******************************************************************************
***************--------------------------------------------********************
				** 	II. Impoverishment Rates  **
***************--------------------------------------------********************
*******************************************************************************
/* A household suffers impoverishment pre-oops if its poor before oop payments,
same for post-oops. Variable of interest are HHs that pass from being non-poor
to poor after oops
*/


* We will need to loop over all possible poverty lines

forvalues q = 1/4{

	*-------------------------------------------------*
	*2.1 Imporverishment
	*-------------------------------------------------*

	* Quarter Data
	gen quarter_preoop_poor`q' 	= 		(quarter_preoop_consumation  < quarter_pline`q') if !mi(quarter_sante)
	gen quarter_postoop_poor`q' = 		(quarter_postoop_consumation < quarter_pline`q') if !mi(quarter_sante)

	* Impoverished HHs - Quarter
	gen quarter_postoop_impov`q' = 		(quarter_preoop_poor`q' < quarter_postoop_poor`q') if !mi(quarter_sante)

	* Year Data
	gen year_preoop_poor`q' 	= 		(year_preoop_consumation  < year_pline`q') if !mi(year_sante)
	gen year_postoop_poor`q' 	= 		(year_postoop_consumation < year_pline`q') if !mi(year_sante)

	* Impoverished HHs - Year
	gen year_postoop_impov`q' 	= 		(year_preoop_poor`q' < year_postoop_poor`q') if !mi(year_sante)



	*******************************************************************************
	***************--------------------------------------------********************
					** 	III. Impov Meets Cata Variables  **
	***************--------------------------------------------********************
	*******************************************************************************


	*-------------------------------------------------*
	*3.1 Tagging different kinds of poverty
	*-------------------------------------------------*

	* R1 - Ratio of Medical payments to discretionary consumption based in poverty line
	gen quarter_r1`q'			= quarter_sante / (quarter_total_consumation - quarter_pline`q') if !mi(quarter_sante)

	* R2 - Ratio of Medical payments to discretionary consumption based in poverty line vecinity
	gen quarter_r2`q' 			= quarter_sante / (quarter_total_consumation - 1.2 * quarter_pline`q') if !mi(quarter_sante)

	* R1 - Ratio of Medical payments to discretionary consumption based in poverty line
	gen year_r1`q'				= year_sante / (year_total_consumation - year_pline`q') if !mi(year_sante)

	* R2 - Ratio of Medical payments to discretionary consumption based in poverty line vecinity
	gen year_r2`q' 				= year_sante / (year_total_consumation - 1.2 * year_pline`q') if !mi(year_sante)

	* Poverty line R1
	gen quarter_r1plus`q' 		= quarter_postoop_consumation / (quarter_total_consumation - quarter_pline`q')  if !mi(quarter_sante)

	* Z-vecinity poverty line R2
	gen quarter_r2plus`q' 		= quarter_postoop_consumation / (quarter_total_consumation - 1.2 * quarter_pline`q')  if !mi(quarter_sante)

	* Poverty line R1 YEAR
	gen year_r1plus`q' 			= year_postoop_consumation / (year_total_consumation - year_pline`q')  if !mi(year_sante)

	* Z-vecinity poverty line R2 YEAR
	gen year_r2plus`q' 			= year_postoop_consumation / (year_total_consumation - 1.2 * year_pline`q')  if !mi(year_sante)


		*-------------------------------------------------*
		*3.1.2 Quarter Tagging
		*-------------------------------------------------*

		* Quarter Data
		gen quarter_immiserizing`q' 	= 	(quarter_r1`q' < 0) if !mi(quarter_sante)
									
		gen quarter_impoverishing`q' 	= 	(quarter_r1`q' > 1) if !mi(quarter_sante)

		* Catastrophic in terms of leaving the HH with less than (Z) - 20% the PL
		gen quarter_catastrohic`q' 		= 	((quarter_r1`q'>0 & quarter_r1`q'<1)      &   (quarter_r2`q'>1 | quarter_r2`q'<0))  if !mi(quarter_sante)		
		
		gen quarter_noncatastrophic`q' 	= 	((quarter_r1`q'>0 & quarter_r1`q'<1)      &   (quarter_r2`q'>0 & quarter_r2`q'<1))	if !mi(quarter_sante)
		
		* Zero OOPs
		gen quarter_zero`q' 			=  	(quarter_r1`q' == 0) if !mi(quarter_sante)	
		
		* Quarter Vulnerable - In categories 1,2,3
		gen quarter_vulnerable`q' = (quarter_immiserizing`q'==1 | quarter_impoverishing`q'==1 | quarter_catastrohic`q'==1)
		
		*-------------------------------------------------*
		*3.1.3 Year Tagging
		*-------------------------------------------------*

		* Year Data
		gen year_immiserizing`q' 	= 	(year_r1`q' < 0) if !mi(year_sante)
									
		gen year_impoverishing`q' 	= 	(year_r1`q' > 1) if !mi(year_sante)

		* Catastrophic in terms of leaving the HH with less than (Z) - 20% the PL
		gen year_catastrohic`q' 	= 	((year_r1`q'>0 & year_r1`q'<1)      &   (year_r2`q'>1 | year_r2`q'<0)) 	if !mi(year_sante)		
		
		gen year_noncatastrophic`q' = 	((year_r1`q'>0 & year_r1`q'<1)      &   (year_r2`q'>0 & year_r2`q'<1))	if !mi(year_sante)
		
		* Zero OOPs
		gen year_zero`q' 			=  	(year_r1`q' == 0) if !mi(year_sante)							
		
		* Year Vulnerable - In categories 1,2,3
		gen year_vulnerable`q' = (year_immiserizing`q'==1 | year_impoverishing`q'==1 | year_catastrohic`q'==1)
		

}

*******************************************************************************
***************--------------------------------------------********************
						** 	IV. Save  **
***************--------------------------------------------********************
*******************************************************************************

* Directory
cdoutput

* File
save e13_dataframe_impov_households, replace


