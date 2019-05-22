clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Table 2 - HH Consumption and CHE rates
* File Name: t02_hhconsumption_CHErates
* RA: Benjamin Sas
* PI: Karen Grepin
* Version: 3
* Date: 29/08/18				
*******************************************************************************
/* This program will calculate catastrophic health expenditures for households
in different ways
*/
*******************************************************************************
* Directory
cdoutput
* Load Data
use a00_dataset_empirical_eval
* Only Relevant Obs
keep if present_all==1
*******************************************************************************

* To usd
unab money_list: quarter_sante
	foreach var in `money_list'{
		replace `var' = `var' / 526
	}


gen oops = quarter_sante if (quarter_sante>0 & !mi(quarter_sante))
gen zero = (quarter_sante==0) if !mi(quarter_sante)


* Dir
cdtables

******************************************************************************
**********************--------------------------------*************************
						** I. OOPs  **
************************--------------------------------***********************
*******************************************************************************

local oops_var quarter_sante oops quarter_share_health1 zero
	
*----------------------------------------------------------*
*1.1 Average for all households
*----------------------------------------------------------*
preserve 

collapse `oops_var' [aweight=hhweight] , by(passage)
	gen one = 1
	reshape wide `oops_var', i(one) j(passage)
	
order quarter_sante* oops* quarter_share* zero*

	
export excel z_appendix_tab01_A , replace firstrow(var)

restore	
*----------------------------------------------------------*
*1.2 By wealth quintile
*----------------------------------------------------------*
preserve

local oops_var quarter_sante oops quarter_share_health1 zero


collapse `oops_var' [aweight=hhweight] , by(passage wealth_quintiles)
	reshape wide `oops_var', i(wealth_quintiles) j(passage)

order quarter_sante* oops* quarter_share* zero*
	
export excel z_appendix_tab01_A , cell(A3) sheetmodify

restore

******************************************************************************
**********************--------------------------------*************************
						** II. Indicators of High OOPs  **
************************--------------------------------***********************
*******************************************************************************


local indic_var q_che1_10 q_che3_40 q_che5_40 quarter_impoverishing3

*----------------------------------------------------------*
*2.1 Average for all households
*----------------------------------------------------------*
preserve 

collapse `indic_var' [aweight=hhweight] , by(passage)
	gen one = 1
	reshape wide `indic_var', i(one) j(passage)
	
order q_che1_10* q_che3_40* q_che5_40* quarter_impo*

export excel z_appendix_tab01a , replace firstrow(var)

restore	
*----------------------------------------------------------*
*2.2 By wealth quintile
*----------------------------------------------------------*
preserve

collapse `indic_var' [aweight=hhweight] , by(passage wealth_quintiles)
	reshape wide `indic_var', i(wealth_quintiles) j(passage)

order q_che1_10* q_che3_40* q_che5_40* quarter_impo*
	
export excel z_appendix_tab01b , cell(A3) sheetmodify

restore

























	
	
	
	
	
	

