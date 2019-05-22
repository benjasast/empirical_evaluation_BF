clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Chef Menage Variables
* File Name: e14_wealth_index
* RA: Benjamin Sas
* PI: Karen Grepin	
* Date: 24/08/18 
* Version: 1			
*******************************************************************************
/* We will calculate a wealth index for each HH based on sevaral characteristics,
then we will divide the HHs in 5 quintiles based on their scores.
Finally we will merge this information to both DataFrame the individual and
household one.
*/
*******************************************************************************


*******************************************************************************
***************--------------------------------------------********************
					** I. Grab all HHs and basic Info  **
***************--------------------------------------------********************
*******************************************************************************

* Directory
cdoutput

* Household DataFrame
use e10_chef_menage

* Relevant Vars for us, Identification variables and house rent/ownership,
* household's head characteristics.
keep menage_id hhid menage zd hhsize hhweight region milieu strate L* PS* SS* ///
logement_menage_loyer chef*

* Make it HH level, copy all this variables across, use like this instead of collapse to keep labels

unab great_list : L* PS* SS* chef*
local var_list 	menage zd hhsize hhweight region milieu strate ///
				logement_menage_loyer `great_list'

foreach var in `var_list'{
	egen aux = max(`var') , by(hhid)
		qui: replace `var' = aux
			drop aux
}				
			
* hh level
duplicates drop hhid, force			

			
save e14_wealth_index, replace

*******************************************************************************
***************--------------------------------------------********************
				  ** II. Grab Consumer Durable Info  **
***************--------------------------------------------********************
*******************************************************************************
* Directory
cddata

* Open consumer Durables
use emc2014_p1_biensdurables

* Identifier of HH
egen id = group(zd menage)
bysort id: gen aux = _n

* Reshape Data
reshape wide code_article pm*, i(id) j(aux)

* Make pm1`code_article', the one declaring the object a dummy variable
forvalues i = 1(1)26 {
	capture replace pm1`i' = 0 if pm1`i' == 2 // Replace No-2 to zero
	capture label define pm`i' 0 "Non" 1 "Oui" , modify
	capture label var pm1`i' "Household has Article code number `i'"
}

* Save Again

* Directory
cdoutput
* Merge
capture drop aux*
merge m:1 zd menage using e14_wealth_index
drop _merge
save e14_wealth_index, replace


*******************************************************************************
***************--------------------------------------------********************
				  ** III. Grab Agricultural Data  **
***************--------------------------------------------********************
*******************************************************************************
clear
* Directory
cddata
* Agricultural Equipment
use emc2014_agri_equipements

* Identifier of HH
egen id = group(zd menage)
bysort id: gen aux = _n

* Rename Code
rename CODEX1 code_article


* Relevant Vars
drop A* L*

* Reshape Data
reshape wide code_article X* , i(id) j(aux)


* Make pm1`code_article', the one declaring the object a dummy variable
forvalues i = 1(1)44 {
	qui: replace X2`i' = 0 if X2`i' ==2 // Replace No-2 to zero
	label define X`i' 0 "Non" 1 "Oui", modify	
	label var X2`i' "Household has Article code number `i' "
}

* Save
cdoutput
merge m:1 menage zd using e14_wealth_index
drop if _merge==1 // No info about anything
drop _merge

save e14_wealth_index, replace

*******************************************************************************
***************--------------------------------------------********************
				** III. Grab Land Characteristics for Plots  **
***************--------------------------------------------********************
*******************************************************************************

* Directory
cddata
* Land characteristics
use emc2014_agri_caracteristiques_parcelles

* Land the HH workds in hectares
bysort zd menage: 	egen land_hectares = total(V06)

* Land Management
bysort zd menage:	egen land_gestion = min(V07)
	label values land_gestion V07

* Do they own the land?
bysort zd menage: 	egen land_propietaire = min(V14)
	label values land_propietaire V14

* Collapse to household and keep relevant vars
duplicates drop zd menage, force
keep land* zd menage

* Merge
cdoutput
merge m:1 menage zd using e14_wealth_index
drop if _merge==1
drop _merge

* Save
save e14_wealth_index,replace


*******************************************************************************
***************--------------------------------------------********************
					** IV. Set-Up Variables  **
***************--------------------------------------------********************
*******************************************************************************


*----------------------------------------------------------*
*4.1 Consumer Durables
*----------------------------------------------------------*

* Rename Durables
rename *X2* *product* 

* Not working all missing
drop product23-product44



*----------------------------------------------------------*
*4.2 Agricultural Data
*----------------------------------------------------------*

* Rename farm equipment
rename *pm1* *farm*

*----------------------------------------------------------*
*4.3. Plot Characteristics
*----------------------------------------------------------*

* Land gestion only has individuelle or collective
replace land_gestion = 0 if land_gestion ==2
	label define V07 0 "Collectif", add
	
* Separate land Gestion
levelsof land_gestion, local(levels)
 foreach l of local levels {
	gen land_gestion_`l' = (land_gestion==`l')
 
 }
	
* Separate propietaire	
recode land_propietaire  (3/5 = 6)

levelsof land_propietaire, local(levels)
 foreach l of local levels {
	gen land_propietaire_`l' = (land_gestion==`l')
 
 }


*----------------------------------------------------------*
*4.4. House Characteristics
*----------------------------------------------------------*
* Recode some variables
recode L02 (1/2 =3)
recode L05 (6=5)
recode L06 (4/5 = 6)
recode L07 (2=1) (4/5 = 3) 
recode L08 (2=1) (5/6=10) (9=10)
recode L09 (3/4=2) (8/9=7)
recode L10 (7=6)
recode L12 (1=.) (3=2) (5/6=4)
recode L13 (3/4=2)
recode L14 (2=1) (6=5)
recode L15 (4=5)


local var_fix_categorical L02 L05 L06 L07 L08 L09 L11 L12 L14 L15 L17

foreach var in `var_fix_categorical'{
	levelsof `var', local(levels)
		foreach l of local levels {
			gen dhouse`var'_`l' = (`var'==`l')
	}
}

*----------------------------------------------------------*
*4.5. Household head Characteristics
*----------------------------------------------------------*
recode chef_etat_matrimonial (3=1) (6=5)
recode chef_education (2=1) (5/6=4) 


local chef_list chef_etat_matrimonial chef_education

foreach var in `chef_list'{
	levelsof `var', local(levels)
		foreach l of local levels {
			gen dchef`var'_`l' = (`var'==`l')
	}
}

*----------------------------------------------------------*
*4.6. Mean Substitution
*----------------------------------------------------------*

unab product_list: product*
unab farm_list: farm*
unab land_list: land*
unab dummy_list: dhouse* dchef*

* Input mode of strata, they are all categorical variables or dummies.
local var_pca `product_list' `farm_list' `land_list' `dummy_list'

* Inputation, using mean of sample makes no sense, I use first mean of strata, then of region if still misssing.
* Inputation by mean of strata
foreach var in `var_pca'{
	bysort zd: egen aux = mean(`var')
		replace `var' = aux if mi(`var')==1
			drop aux
}

* Inputation mean of region if still missing
foreach var in `var_pca'{
	bysort region milieu: egen aux = mean(`var')
		replace `var' = aux if mi(`var')==1
			drop aux
}
* Inputation mean of sample if still missing
foreach var in `var_pca'{
	bysort milieu: egen aux = mean(`var')
		replace `var' = aux if mi(`var')==1
			drop aux
}


*----------------------------------------------------------*
*4.7. Varlists for PCA
*----------------------------------------------------------*

unab product_list: product*
unab farm_list: farm*
unab land_list: land*
unab dummy_list: dhouse* dchef*


local common `product_list' `dummy_list'
local rural `common' `farm_list' `land_list'
local urban `common'

display "`common'"



* PCA - Common to everyone
pca `common' , factors(1)

predict wealth_national
kdensity wealth_national


* PCA for urban
pca `urban' if milieu==1 , factors(1)

predict wealth_urban if milieu==1
kdensity wealth_urban

* PCA for rural
pca `rural' if milieu==2 , factors(1)

predict wealth_rural if milieu==2
kdensity wealth_rural

xtile wealth_qrural = wealth_rural [aweight=hhweight], nq(5) 
xtile wealth_drural = wealth_rural [aweight=hhweight], nq(10)

* Regression to normalize both
reg wealth_national wealth_urban 
	predict wealth_score if milieu==1
	
reg wealth_national wealth_rural
	predict wealth_score2 if milieu==2

replace wealth_score = wealth_score2 if milieu==2	
	drop wealth_score2

* Check normalizatyion was succesful - coefficient should be one.
reg wealth_national wealth_score

kdensity wealth_score

* Create quintiles and deciles
xtile wealth_quintiles = 	wealth_score [aweight = hhweight], nq(5)
xtile wealth_deciles = 		wealth_score [aweight = hhweight], nq(10)

* Create variable with centiles of wealth_score
xtile wealth_centiles = wealth_score [aweight=hhweight], nq(100)




**************************************clear*****************************************
***************--------------------------------------------********************
					** V. Save and merge  **
***************--------------------------------------------********************
*******************************************************************************

* Directory
cdoutput 
* Save
keep zd menage wealth*
save e11_wealth_index,replace


capture drop X*
capture drop code_*
capture drop pm*



* Merge with HH data
use e10_chef_menage
merge m:1 zd menage using e11_wealth_index
	drop _merge
save e11_dataframe_withwealthindex, replace





