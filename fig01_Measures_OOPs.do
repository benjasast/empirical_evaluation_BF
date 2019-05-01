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
* Vars
set maxvar 10000

* Directory
cdoutput
* Load Data
use e15_dataframe_with_emploi

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
		
		
		
/*		
		
*------------------------------------------------------------------------------*
*1.1 Collapse Info to Averages - For Passage, Wealth Quintile, Urbanicity
*------------------------------------------------------------------------------*

local graph_vars ///
				quarter_sante 	quarter_impoverishing3 	q_che1_10 		q_che3_40 		q_che5_40

local scales `" "0(20)100"  		"0(0.02).18"			"0(0.02).18"	"0(0.02).18"	"0(0.02).18"				"'
local ytitles `"	"USD 2014"		"Proportion of households" "Proportion of households" "Proportion of households" "Proportion of households"			"'


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
			,by(passage wealth_quintiles milieu)


	generate hi`v' =  `v' + invttail(n-1,0.025)*(sd`v' / sqrt(n`v'))
	generate low`v' = `v' - invttail(n-1,0.025)*(sd`v' / sqrt(n`v'))

			
* Aux variable with order of display
sort milieu passage wealth_quintiles
	gen aux = _n
	
* Add a scalar every five columns
	recode aux ///
	(6/10=1) (11/15=2) (16/20=3) (21/25=4) (26/30=5) (31/35=6) (36/40=7) ///
	, gen(group)

	replace group =. if aux<=5
	
	replace aux = aux + group*3 if group>=1 & aux>5 // space between rounds
	replace aux = aux + 3 if group>=4 & !mi(group) // extra space between rural urban	

	

* Graph
cdtables

	twoway 	(bar `v' aux if wealth_quintiles==1) ///
			(bar `v' aux if wealth_quintiles==2) ///
			(bar `v' aux if wealth_quintiles==3) ///
			(bar `v' aux if wealth_quintiles==4) ///
			(bar `v' aux if wealth_quintiles==5) ///
			(rcap hi`v' low`v' aux) ///
			,xlabel( 3 "Round 1" 11 "Round 2" 19 "Round 3" 27 "Round 4" 38 "Round 1" 46 "Round 2" 54 "Round 3" 62 "Round 4"   , noticks) ///
			xtitle("Urban									Rural") ///
			ylabel(`s') ///
			ytitle(`yt') ///
			legend(off)
			
			graph export fig01b_`v'.png , replace

restore
local z = `z' + 1			
}


			
		
			
			
			
	
		* Stack of Quarter Sante
		local money_var quarter_sante_drugmoder quarter_sante_drugtrad quarter_sante_medecin quarter_sante_servhosp quarter_sante_autre

		graph bar (mean) `money_var', ///
			stack over(wealth_quintiles, gap(250)) over(passage, gap(700) label(labsize(vsmall)) ) ///
			title(Decomposed OOPs, size(medsmall)) ///
				ytitle(USD 2014, size(medsmall)) ///
				ylabel(,labsize(vsmall) angle(0)) ///
				yscale(titlegap(5)) ///
				graphregion(color(white)) ///
				scheme(s1mono) ///
				bargap(60) ///
				legend( lab(1 "Modern Drugs") lab(2 "Traditional Medicine") labe(3 "Medical Consultations") labe(4 "Hospital Services") labe(5 "Other Health") ) ///
				saving(graph_quarter_sante_decomposed_nourb, replace)
				
				graph export fig04decomposed_OOPs.png , replace












