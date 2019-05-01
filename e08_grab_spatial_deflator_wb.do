clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Grab Spatial Deflator from WB data
* File Name: e08_grab_spatial_deflator_wb
* RA: Benjamin Sas
* PI: Karen Grepin				
*******************************************************************************
/* This program will grab the spatial deflator from WB welfare file and save it
for a future merge. The importance of this deflator is for adjustment of cost of living
between different provinces and rural/urban differences.
*/
*******************************************************************************
* Directory
cddata
* Load Data
use emc2014_welfare
*******************************************************************************


******************************************************************************
**********************--------------------------------*************************
					** I. Grab Spatial Deflator **
************************--------------------------------***********************
*******************************************************************************
* Housekeeping
rename grappe zd

* The spatial deflator is based in a combination of zd-region-province-milieu
duplicates drop zd region province milieu menage, force

* Keep only relevant variables to objective
keep zd menage region province milieu deflateur


******************************************************************************
**********************--------------------------------*************************
						** II. Save and Merge with DataFrame **
************************--------------------------------***********************
*******************************************************************************
* Directory
cdoutput

* Save
save e08_spatial_deflator_wb, replace


*******************************************************************************
* Merge with DataFrame
*******************************************************************************
* Load Data
use e06_dataframe_total_household_expenditures

* Merge
drop _merge
merge m:1 zd menage using e08_spatial_deflator_wb

*******************************************************************************
* Input from households in same zd for households not present in WB data.
*******************************************************************************

* Order Data
sort zd menage passage region province milieu

* Check if it should grab information for deflateur from up or down

gen grabup =0
replace grabup=1 if (_merge==1) & (passage==1) & (zd[_n]==zd[_n-1])
bysort menage_id:		egen do_grabup = max(grabup)

gen grabdown =0
replace grabdown=1 if (_merge==1) & (passage==4) & (zd[_n]==zd[_n+1]) & do_grabup==0
bysort menage_id:		egen do_grabdown = max(grabdown)

* Input from their neighbors -- Grab Up
gen deflateur_input =.
replace deflateur_input = deflateur[_n-1] if do_grabup==1

* Input from neighbors -- Grab down
replace deflateur_input = deflateur[_n+1] if do_grabdown==1

* Strange cases where a unit without deflateur came after one the same
replace deflateur_input = deflateur_input[_n-1] if zd[_n]==zd[_n-1] & do_grabup==1 & deflateur_input==.
replace deflateur_input = deflateur_input[_n+1] if zd[_n]==zd[_n+1] & do_grabdown==1 & deflateur_input==.

* Fill for all years
bysort menage_id:		egen deflateur_menage_input = max(deflateur_input)

* Do the actual inputting
replace deflateur = deflateur_menage_input if mi(deflateur_menage_input)==0


* Do a special grabdown
replace do_grabdown=1 if deflateur==. & do_grabup==1
replace deflateur_input = deflateur[_n+1] if deflateur==. & do_grabdown==1
drop deflateur_menage_input
bysort menage_id:		egen deflateur_menage_input = max(deflateur_input)

* Do inputting again
replace deflateur = deflateur_menage_input if deflateur==.


* Do a special grabdown -v2
replace do_grabdown=1 if deflateur==. & do_grabup==1
replace deflateur_input = deflateur[_n+1] if deflateur==. & do_grabdown==1
drop deflateur_menage_input
bysort menage_id:		egen deflateur_menage_input = max(deflateur_input)

* Do inputting again
replace deflateur = deflateur_menage_input if deflateur==.



* Drop redundant variables
drop grabup do_grabup grabdown do_grabdown deflateur_input deflateur_menage_input _merge

*******************************************************************************
* Save
*******************************************************************************

save e08_dataframe_with_deflator, replace




