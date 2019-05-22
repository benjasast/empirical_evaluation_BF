clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Run Everything
* File Name: a_01_run_everything
* RA: Benjamin Sas
* PI: Karen Grepin				
*******************************************************************************
/* This program has the simple objective of running all the do-files in the project
to instantaneously replicate all of our results. */
*******************************************************************************


************************************************************************************
**** REPLACE HERE FOR THE ADRESS WHERE THE FOLDERS ARE LOCATED IN YOUR COMPUTER ***
	global user /Users/bsastrakinsky/Desktop/Replication // <------< HERE
*****													**********
*******************************************************************************

*******************************************************************************
***************--------------------------------------------********************
					** I. Household Dataset **
***************--------------------------------------------********************
*******************************************************************************


*******************************************************************************
* 1. Directories
*******************************************************************************
cd $user/Do_Files
do a02_set_directories_and_input_files

*******************************************************************************
* 2. Food Expenditures
*******************************************************************************
cddofile
do e01_food_expenditures

*******************************************************************************
* 3. Non-Food Expenditures
*******************************************************************************
cddofile
do e02_nonfood_expenditures

*******************************************************************************
* 4. Special Education, Health and Anthropology Modules
*******************************************************************************
cddofile
do e03_special_education_health_antrhopometrie_modules

*******************************************************************************
* 5. Consumer Durables and Rent Cost Expenditures
*******************************************************************************
cddofile
do e04_consumer_durables_rent_expenditures

*******************************************************************************
* 6. Create Dataframe Aggregated at Household Level
*******************************************************************************
cddofile
do e05_dataframe_household_agg

*******************************************************************************
* 7. Compute Total consumption per household - Nominal
*******************************************************************************
cddofile
do e06_dataframe_total_household_expenditures

*******************************************************************************
* 8. Include spatial deflators from WB welfare file
*******************************************************************************
cddofile
do e08_grab_spatial_deflator_wb

*******************************************************************************
* 9. Add Chef Menage info
*******************************************************************************
cddofile
do e10_adds_chef_menage

*******************************************************************************
* 10. Wealth Index
*******************************************************************************
cddofile
do e11_wealth_index

*******************************************************************************
* 11. Find out CHE for passages (quarters) and Year
*******************************************************************************
cddofile
do e12_CHE

*******************************************************************************
* 12. Impoverishment and Cata meets Impov
*******************************************************************************
cddofile
do e13_impoverishing

*******************************************************************************
* 13. Shocks module
*******************************************************************************
cddofile
do e14_shock_module

*******************************************************************************
***************--------------------------------------------********************
					** II. Tables and Figures **
***************--------------------------------------------********************
*******************************************************************************

* Keep only final dataset
cdoutput
use e14_dataframe_with_shocks, clear
save a00_dataset_empirical_eval , replace

#delimit;
local erase_list
e01_food_agg_dataframe
e01_p1_food_agg
e01_p2_food_agg
e01_p3_food_agg
e01_p4_food_agg
e02_nonfood_agg_dataframe
e02_p1_nonfood_agg
e02_p2_nonfood_agg
e02_p3_nonfood_agg
e02_p4_nonfood_agg
e03_p3_special_health_agg
e03_p4_special_anthropometrie_agg
e03_p4_special_education_agg
e03_p4_special_pregnancy
e04_p1_special_consumer_durables_agg
e04_p1_special_logement_agg
e05_dataframe_household_agg
e06_dataframe_total_household_expenditures
e08_dataframe_with_deflator
e08_spatial_deflator_wb
e10_chef_menage
e11_dataframe_withwealthindex
e11_wealth_index
e12_dataframe_CHEs_households
e13_dataframe_impov_households
e14_wealth_index
e14_dataframe_with_shocks
;
# delimit cr

foreach file in `erase_list'{
	erase `file'.dta
}

*-------------------------------------------------*
*2.2. Tables
*-------------------------------------------------*
cddofile
do tab01_sample_stats

cddofile
do z_appendix_tab01_CHEs

cddofile
do z_appendix_tab02_Shocks

*-------------------------------------------------*
*2.3. Figures
*-------------------------------------------------*
cddofile
do fig01_Measures_OOPs

cddofile
do fig02_shocks_CHEs





























