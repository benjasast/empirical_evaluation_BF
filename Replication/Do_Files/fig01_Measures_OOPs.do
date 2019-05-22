clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Catastrophic Health Expenditures
* File Name: fig07_CHEs_alltogether
* RA: Benjamin Sas
* PI: Karen Grepin	
* Date: 11/10/18
* Version: 1			
*******************************************************************************
/* A Graph encompassing all CHE types
*/
*******************************************************************************
* Directory
cdoutput
* Load Data
use a00_dataset_empirical_eval

* Relevant
keep if present_all==1
*******************************************************************************
* Passages
label define milieu 1 "Urban", modify
label define milieu 2 "Rural", modify

* Rounds
label define rounds 1 "Round 1" 2 "Round 2" 3 "Round 3" 4 "Round 4"
label values passage rounds

* Autre Health
egen quarter_sante_autre = rsum( quarter_sante_proddivers quarter_sante_appareils  quarter_sante_labradio quarter_sante_servaux quarter_sante_assurance)
local money_var quarter_sante quarter_total_consumation quarter_nonfood_consumation quarter_consumation_subsistance quarter_sante_drugmoder quarter_sante_drugtrad quarter_sante_proddivers quarter_sante_appareils quarter_sante_medecin quarter_sante_labradio quarter_sante_servaux quarter_sante_servhosp quarter_sante_assurance quarter_sante_autre

* TO USD
foreach var in `money_var'{
replace `var' = `var' / 526

}


* Scheme
set scheme plotplain

gen zero = (quarter_sante==0) if !mi(quarter_sante)
gen oops2 = (quarter_sante) if (quarter_sante>0 & !mi(quarter_sante))

*------------------------------------------------------------------------------*
*1.0 Collapse Info to Averages - For Passage, Wealth Quintile
*------------------------------------------------------------------------------*
* List of variables to graph

local graph_vars ///
				quarter_sante 	oops2 quarter_impoverishing3 	q_che1_10 		q_che3_40 		q_che5_40 zero quarter_share_health1

local scales `" 	"0(10)70" "0(10)70"  		"0(0.02).1"			"0(0.02).1"	"0(0.02).1"	"0(0.02).1" "0(.1).5" "0(0.02).1"				"'
local ytitles `"	"USD 2014" "USD 2014"		"Proportion of households" "Proportion of households" "Proportion of households" "Proportion of households" "Proportion of households" "Share of OOPs"			"'
	
local z = 1

foreach v in `graph_vars'{
preserve

local s: word `z' of `scales'
local yt: word `z' of `ytitles'

			collapse (mean) ///
				 `v' ///
				 (sd) sd`v' = `v' ///
				 (count) n`v' = `v' ///
				[aweight=hhweight] ///
				,by(passage wealth_quintiles)

	generate hi`v' =  `v' + invttail(n-1,0.025)*(sd`v' / sqrt(n`v'))
	generate low`v' = `v' - invttail(n-1,0.025)*(sd`v' / sqrt(n`v'))

* Aux variable with order of kind to be displayed in graph
gen aux=.
local i = 1

	forval p = 1/4{
		forval w = 1/5{

				replace aux = `i' if passage==`p' & wealth_quintiles==`w'
			
			local i = `i' + 1
		}
		
		local i = `i' + 2 // for space between columns
	}

	
	
* Graph				

	twoway 	(bar `v' aux if wealth_quintiles==1) ///
			(bar `v' aux if wealth_quintiles==2) ///
			(bar `v' aux if wealth_quintiles==3) ///
			(bar `v' aux if wealth_quintiles==4) ///
			(bar `v' aux if wealth_quintiles==5) ///
			(rcap hi`v' low`v' aux) ///
			,xlabel( 3 "Round 1" 10 "Round 2" 17 "Round 3" 24 "Round 4" , noticks) ///
			ylabel(`s') ///
			ytitle(`yt') ///
			xtitle("") ///
			legend(order(1 "Poorest" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Richest") pos(6) rows(2)) ///
			legend(off)
				
			* Dir and Save
			cdtables
			graph export fig01a`v'.png, replace


			
restore
local z = `z' + 1			
}		
		
		
		
	









