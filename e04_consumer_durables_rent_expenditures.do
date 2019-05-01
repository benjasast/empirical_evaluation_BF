clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Consumer Durables and Rent
* File Name: e04_consumer_durables_rent_expenditures
* RA: Benjamin Sas
* PI: Karen Grepin				
*******************************************************************************
/* 
The modules for consumer durables and the characteristics of the house were 
only collected during passage one. A consequence of this is that we will be
under-estimating the real value of use of the consumer durables in case the 
household purchased more consumer durables during the rest of the period.

*/
*******************************************************************************
 * Directory
 cddata
 
 * Load Data
 use emc2014_p1_biensdurables
 *******************************************************************************
 * House-Keeping
 *******************************************************************************
rename (a1 a2 a3 a6) (region province milieu passage)

* Keep only observations that have item
keep if pm1==1 & !mi(pm1) // Has item dummy
keep if pm2>=1 & !mi(pm2) // Number of items
keep if pm4>0 & !mi(pm4) // Payed money for the item when bought.
keep if !mi(pm5) 		// Non-missing valuation of item today

* Herve did this I do not agree, eliminate for those that have had the item zero years,
* or not known
*keep if pm3!=0 & pm3!=.


* Important observation if I have had object zero years, should I still imply utilization cost?
* My opinion we should add one to both pm3 and pm4 and calculate according to that.
 
* Some values are plain wrong or imply missing values
replace pm2 =1 		if pm2>=95 & !mi(pm2) 	// Number of articles over 95, we switch to only one.
replace pm3 =.		if pm3==99				// Also age of some aribles over 60 y/o?
replace pm3 =.		if pm3>=50				// (option take items out if over 50 y/o.
replace pm4 =.		if pm4==9999000 | pm4==9999999

* Observations lots of values do not make sense in data, some items seem to expensive
* to be true.


 
******************************************************************************
**********************--------------------------------*************************
				**I. Calculate Consumer Use of Durables per year**
************************--------------------------------***********************
*******************************************************************************
 /* All the information refered to these steps can be found on page 35-36 of
 Guidelines for Construction Consumption Aggregates for Welfare Analysis, Deaton
 and Zaidi.
 */
 
*******************************************************************************
* 1. Calculate real depreciation rate
*******************************************************************************

* Formula (3.2) : delta-pi = 1 - (p_t/p_t-T) ^(1/T)

* Value of products per household: quantity*value
gen n = pm2
gen T = pm3
*gen p0 = pm4*n
*gen p1 = pm5*n

// Values for products are only for last one consumed, we will have to do
* more calculations to estimatie depretiation for the rest, we only know they
* have more, not for how long they have had it.

gen p0 = pm4 if pm4!=0 & !mi(pm4)
gen p1 = pm5 if pm5!=0 & !mi(pm5)


* Estimated real depreciation rate
gen delta_pi = 1 - (p1/p0)^(1/T) if p1<p0 & !mi(p1, p0)

*******************************************************************************
* 2. Calculate median depreciation rate for each consumer durable
*******************************************************************************
* This is done to attenuate the effect of outliers in the data. We use a sample
* average of the depreciation rate of the data instead of the one implicit in
* the data for each household.

* Median Depreciation rate by product:
cddata
gen hhid=1000*zd+menage

* Get Strata and hhweight to calculate population median (we want this!)
merge m:1 hhid using emc2014_welfare , keepusing(hhweight strate)
drop if _merge==2
* We get the median real dep for each product (weighted)

gen median_delta_pi =. 
 
 forvalues i = 201(1)226{ 
	sum delta_pi [w=hhweight] if code_article==`i' , detail
	replace median_delta_pi = r(p50) if code_article==`i'
}  




*******************************************************************************
* 3. Calculate the user cost of durable goods:
*******************************************************************************
* This is formula (3.1): s_t*p_t (r_t + delta_pi)

* As recommended on page 35, we average the real interest rate over a long
* period of time and use it for all products.

* From information from the WB WDI the average real interest rate in Burkina
* Faso from 2005 to 2014 when the survey was done was 2.4%.

* Real Interest Rate
gen r = 0.024

* User Cost
gen durables_cout_utilisation = p1*n * (r + median_delta_pi)


******************************************************************************
**********************--------------------------------*************************
					** Collapse to household level and Save**
************************--------------------------------***********************
*******************************************************************************


*******************************************************************************
* 1. Create Household level user costs, and percapita user costs
*******************************************************************************

* Household level user costs
bysort zd menage : 	egen durables_menage_cout_utilisation = total(durables_cout_utilisation)
label var durables_menage_cout_utilisation "Total User costs for consumer durables in hh for one year"

* Household level percapita user cosst
gen durables_percap_cout_utilisation = durables_menage_cout_utilisation/a8

*******************************************************************************
* 2. Collapse to household and save
*******************************************************************************
* Collapse to household
duplicates drop zd menage , force


* Keep relevant variables for household level
keep region province milieu zd menage passage ///
a8 durables_menage_cout_utilisation durables_percap_cout_utilisation

* Save File
cdoutput
save e04_p1_special_consumer_durables_agg, replace


 
******************************************************************************
**********************--------------------------------*************************
				**II. Calculate Cost of Rent per household**
************************--------------------------------***********************
*******************************************************************************
 /* All the information refered to these steps can be found on page 37-39 of
 Guidelines for Construction Consumption Aggregates for Welfare Analysis, Deaton
 and Zaidi.
 */
 *******************************************************************************
 clear all
 * Directory
 cddata
 
 * Load Data
 use emc2014_p1_logement
 *******************************************************************************
 

******************************************************************************
**********************--------------------------------*************************
					** I. Calculate Rent Cost**
************************--------------------------------***********************
*******************************************************************************
set matsize 11000
gen passage = 1

*******************************************************************************
* 0. Some little outlier control
*******************************************************************************
replace L01=. if L01==4 // Unkown value
replace L03=2 if !(inrange(L03, 1,49)) // More than 50 rooms in HH

* Some corrections from Herve, about lotie and number of rooms, consistency from
* other surveys is my guess.

replace  L01=1 if zd==629
replace  L01=2 if zd==70
replace  L01=1 if zd==71
replace  L01=1 if zd==689

replace  L01=2 if zd==16
replace  L01=1 if zd==19
replace  L01=1 if zd==356
replace  L01=2 if zd==657
replace  L01=2 if zd==727
replace  L01=1 if zd==761

replace L03=1 if zd==416 & menage==9
replace L03=2 if zd==64 & menage==4
replace L03=2 if zd==532 & menage==2
replace L03=2 if zd==550 & menage==13
replace L03=2 if zd==863 & menage==8
replace L03=2 if zd==689 & menage==5
replace L03=7 if zd==689 & menage==1
replace L03=7 if zd==821 & menage==9
replace L03=. if zd==871 & menage==6




*******************************************************************************
* 1. First approach just use declared data
*******************************************************************************
* Just Copy variable
*gen logement_menage_loyer = L16

*Option input for people who do not rent and probably overestiamte
gen logement_menage_loyer = L16 if L15==3

label var logement_menage_loyer "Household spending on rent monthly"
*twoway (kdensity logement_menage_loyer if L15==1 ) (kdensity logement_menage_loyer if L15==3) if L16<50000

* Compare densities between tenants and owners, there are no visible differences
* between owners with title and renters, differences when including all owners
* come from people without the title, which would obviously pay rent for rent in those
* properties in irregular situation.



*******************************************************************************
* 2. Inputting for poeple that do not declare value
*******************************************************************************

/* A regression will be done to input values for those households that did not
declare how much they pay/or estimate would pay on rent monthly.

The regression uses all variables that characterize the households plus controls
on the region and province of the house.
*/



*gen logement_input_loyer = 1 if mi(L16)==1 // Have missing observation on estimated rent
* Option inputting for people not renting

gen logement_input_loyer =1 if mi(L15)==1 | L15!=3 | mi(L16)==1
label var logement_input_loyer "Takes value 1 if household needed inputting on their house rent"
count if logement_input_loyer==1 

* Percentiles of rent for locataire
pctile loyer_percentiles_rent = logement_menage_loyer , nq(10)
scalar firstdecile = loyer_percentiles_rent[1]


* Install neccesary package for ridge,lasso-regression
capture ssc install elasticregress

* Some values are very very low, we do not want them for estimation, let's only
* use those in the 90% higher.

* Make it logarithmic
gen llogement_menage_loyer = log(logement_menage_loyer)

* Lasso Regression - We want to improve prediction power no need for causality. 

ridgeregress llogement_menage_loyer i.region i.province i.milieu i.zd i.L01 i.L02 L03 ///
i.L04 i.L05 i.L06 i.L07 i.L08 i.L09 i.L10 i.L11 i.L12 i.L13 i.L14 i.L15 ///
i.L17 i.L18 SSB* if logement_menage_loyer > scalar(firstdecile)

* Predict Values in log
predict yhat , xb

* Predicted values in levels
gen yhat2 = exp(yhat)

*Replace for households that need inputting
replace logement_menage_loyer = yhat2 if logement_input_loyer==1 | logement_menage_loyer<=scalar(firstdecile)

* Check error at inputting
gen error_input = L16 - yhat2 if logement_input_loyer!=1 

twoway (kdensity error_input if milieu==2) (kdensity error_input if milieu==1)

* Drop predicted value
drop yhat


*******************************************************************************
* 3. Save File
*******************************************************************************
* Directory
cdoutput
* Save File
save e04_p1_special_logement_agg, replace


 
 
 
 






