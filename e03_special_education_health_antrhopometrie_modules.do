clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Special Modules for Education and Health
* File Name: e03_special_education_health_antrhopometrie_modules_expenditures
* RA: Benjamin Sas
* PI: Karen Grepin				
*******************************************************************************
/* 
The recall period for this modules was annual for Education.
The Health Module was episodic based, and had 15 day recall period for the episode itself,
and 30 day recall period for the treatment of the period itself.


We have to be careful about not double inputting the same thing, specially in education
there are 
conflicts in the data between the following variables:
*******************************************************************************
	I. Education Conflicts
*******************************************************************************
Education Special Module - only passage 4/ 3months recall period - every passage:
(yearly/3months):

1. Frais de Scolarite 

Variable ET17 : Frais de scolarite annual
(product>=196) & (product<=199) In 3mois data for each passage: this are
all the frais de scolarite payed for all educational levels in the household.
*/
*******************************************************************************
******************************************************************************
**********************--------------------------------*************************
							** Education Module **
************************--------------------------------***********************
*******************************************************************************

*Directory
cddata

* Load data
use emc2014_p4_education

******************************************************************************
* Some useful Variables household variables
*******************************************************************************
* Number of individuals in the household who are more than four
bysort zd menage ,sort: 	gen edu_n_more_than_four = _N
label var edu_n "N in household more than 4 years old"
*******************************************************************************
* Number of members in the household that do not attend formal school

gen edu_nonformal_school =0
replace edu_nonformal_school=1 			if ET04>1

bysort zd menage : 		egen edu_n_nonformal = total(edu_nonformal_school) 
label var edu_n_nonformal "N in the household that studies/ed in non formal setting"
*******************************************************************************
* Number of people in the household currently in school year 2013/2014
gen edu_in_school=0
replace edu_in_school = 1 if ET10==1

bysort zd menage : 		egen edu_n_inschool = total(edu_in_school)
label var edu_n_inschool "N in the household currently studying"
*******************************************************************************
* Highest Educational level in the household
bysort zd menage : 		egen edu_highest_level = max(ET23)

label var edu_highest_level "Highest Educational level of any person living in the household"

label define edu_highest_level 1 "Prescolaire" 2 "Primaire" 3 "Post Primaire" ///
4 "Post Primaire Techniq et Profess" 5 "Secondaire" 6 "Secondaire techniq et Profess" ///
7 "Superieur"

*******************************************************************************
* Total declared Educational Spending by household, does only include items directly
* related to education, frais scolaires, fournitures, livres, hebergement, et bourses.
* It does not include transportation to school, or frais de cantine scolaire.

egen edu_total_individual = 			rsum(ET17 ET18 ET19 ET22)
bysort zd menage : 		egen edu_total_spending = total(edu_total_individual)

label var edu_highest_level "Educational expenses declared by household, yearly basis"



 *******************************************************************************
**********************--------------------------------*************************
							** Data Checks **
************************--------------------------------***********************
*******************************************************************************


*******************************************************************************
* 1. Collapse Information to household level
*******************************************************************************

keep zd menage region milieu A6 edu_n_more_than_four ///
edu_n_nonformal edu_n_inschool edu_highest_level ///
edu_total_spending

* Keep one observation per household with aggregate data - 10,796 households with data.
duplicates drop zd menage , force

* Create a passage variable
rename A6 passage


 *******************************************************************************
**********************--------------------------------*************************
							** Save Educational Data **
************************--------------------------------***********************
*******************************************************************************

* Directory
cdoutput

* Save
save e03_p4_special_education_agg , replace




*******************************************************************************

******************************************************************************
**********************--------------------------------*************************
							** Health Module **
************************--------------------------------***********************
*******************************************************************************



/* In this module we will try to identify which households had health episodes for
one or more of its members, how much were these episodes in total, and what kind of
episodes they were.

*/

********************************************************************************
* Blank page
clear all

* Directory
cddata

* Load data
use emc2014_p3_sante 

******************************************************************************
******************************************************************************
		**** Some useful Variables household variables****
*******************************************************************************
******************************************************************************


*******************************************************************************
* Number of members of household with health episodes in the last 2 or 4 weeks
*******************************************************************************

gen health_episode =0
replace health_episode=1 	if S01A==1 // 2 weeks recall
replace health_episode=1 	if S01B==1 // 4 weeks recall

bysort zd menage : 	egen health_n_episodes = total(health_episode)

label var health_n_episodes "N. of members of household with health episodes in last 4 weeks"

*******************************************************************************
* A member of the family was affected by the episode for more than 2 weeks
*******************************************************************************

gen health_longer_twoweeks=0
replace health_longer_twoweeks=1 	if S04==3

bysort zd menage : 	egen health_long_episode = max(health_longer_twoweeks)

label var health_long_episode "At least one member of household had health episodelonger than 2 weeks altering routine"

*******************************************************************************
* Number of members of the household that went to modern health services, traditional services
* or did not look for health services, given that they had an episode.
*******************************************************************************
gen health_moderne=0
replace health_moderne =1 		if S05==1

gen health_traditionel=0
replace health_traditionel =1 	if S05==2

gen health_nonservice=0
replace health_nonservice =1 	if S05==3
*******************************************************************************
* Number in household that seek modern medicine attention
*******************************************************************************
bysort zd menage : 	egen health_n_moderne = total(health_moderne)

label var health_n_modern "N. in hh that seek modern health attention given episode"
*******************************************************************************
* Number in household that seek traditional medicine attention
*******************************************************************************
bysort zd menage : 	egen health_n_traditionel = total(health_traditionel)

label var health_n_traditionel "N. in hh that seek traditional health attention given episode"
*******************************************************************************
* Number in household that do not seek attention
*******************************************************************************
gen health_n_nonservice = health_n_episodes - health_n_modern - health_n_traditionel

*******************************************************************************
* Higher complexity health facilities - Establishment they visited first time.
*******************************************************************************
gen health_complexite_hopital = S07 // The lower the number the higher the complexity.

* Complexity of hospital attended when they first checked their episode.
bysort zd menage : 	egen health_menage_complexite_hopital = min(S07)

label define health_complexite_hopital 1 "Centre Hospitalier Universitaire" ///
2 "Centre Hospitalier Regional" 3 "Centre Medical avec Antenne Chirurgical"


******************************************************************************
******************************************************************************
						**** Health Spending ****
*******************************************************************************
******************************************************************************

******************************************************************************
* Expenditure variables
******************************************************************************

* Household spending in consultation medical last 4 weeks for that episode
bysort zd menage : 	egen health_total_consultation 				= total(S12)
label var health_total_consultation "Total expenses for hh in consultations last 4 weeks"

* Household spending in examens last 4 weeks for episodes
bysort zd menage :		egen health_total_examens 					= total(S15)
label var health_total_examens "Total expenses for hh in consultation last 4 weeks"

* Household spending in medicaments last 4 weeks
bysort zd menage :		egen health_total_medicaments 				= total(S18)
label var health_total_medicaments "Total expenses for hh in medicaments last 4 weeks"

* Household spending in hospitalisation, last 12 months
bysort zd menage :		egen health_total_annual_hosp				= total(S22)
label var health_total_annual_hosp "Total expenses for hh in hospitalization last 12 months"

* Aide recieved from friends and family for medical treatment during last 12 months
bysort zd menage :		egen health_total_annual_aide 				= total(S26) 
label var health_total_annual_aide "Total aide recieve by hh from family/friends for health last 12 months"

* Household other kind of health spending (pregnancy,automedication, circumsition, illegal etc.)
bysort zd menage :		egen aux1 									= total(S27) // autres
bysort zd menage :		egen aux2 									= total(S30) // illegal

									gen health_total_annual_autres 				= aux1 + aux2
drop aux*
label var health_total_annual_autres "Total expenses for hh in other medical last 12 months"


******************************************************************************
* Health characteristics
******************************************************************************


******************************************************************************
* At least one member of household has insurance
gen health_insurance =0
replace health_insurance = 1 		if (S13==1 | S16==1 | S19==1 | S23==1)

bysort zd menage : 	egen health_menage_insurance = max(health_insurance)
label var health_menage_insurance "One member of household declared has some kind of health insurance"

******************************************************************************
* There is a moustiquaire in the household

gen health_moustiquaire =0
replace health_moustiquaire=1 		if S31 ==1

bysort zd menage :		egen health_menage_moustiquaire = max(health_moustiquaire)
label var health_moustiquaire "One member of household declared to have a mosquito net"

******************************************************************************


******************************************************************************
* Tobacco
******************************************************************************
* Only for 15+ years old

******************************************************************************
* Number of smokers in the household
gen health_fumeur 					= 0
replace health_fumeur = 1 			if (S36==1 | S36==2 | S36==3) // tabac en poudre, cigarretes ou pipe, autre tabac

bysort zd menage : 	egen health_n_fumeurs = total(health_fumeur)
label var health_n_fumeurs "N. of smokers in household"
******************************************************************************
* Daily smokers in household, and number of daily smokers
gen health_fumeur_quotidien =0
replace health_fumeur_quotidien = 1 if (S37==1 | S37==2)

* Dummy variable if daily smoker inside house
bysort zd menage :		egen health_menage_fumeur_quotidien = max(health_fumeur_quotidien)
label var health_menage_fumeur_quotidien "At least one daily smoker in house"

* Number of Daily smokers in the household
bysort zd menage :		egen health_n_fumeur_quotidien = total(health_fumeur_quotidien)
label var health_n_fumeur_quotidien "N. of daily smokers in household" 
******************************************************************************


******************************************************************************
* Reproductive Health
******************************************************************************
* Number of pregnancies in household last 12 months
gen health_pregnancy =0 
replace health_pregnancy =1 if S41==1

bysort zd menage :		egen health_n_pregnancies = total(health_pregnancy)
label var health_n_pregnancies "N. of pregnant women in hh last 12 months"

* Number of succesful pregnancies in the household
gen health_pregnancy_succes =0 if health_pregnancy==1
replace health_pregnancy_succes = 1 if S46==1

bysort zd menage :		egen health_n_pregnancies_succes = total(health_pregnancy_succes)
label var health_n_pregnancies_succes "N. of succesful pregnancies in hh last 12 months"


 *******************************************************************************
**********************--------------------------------*************************
							** Data Checks **
************************--------------------------------***********************
*******************************************************************************

******************************************************************************
* Individual Variables
******************************************************************************
* Health Episodes
tab health_episode // 20% of individuals report an episode in the past 4 weeks

* Episode affecting them in daily activities more than 2 weeks
tab health_longer_twoweeks // around 1% of individuals were affected for more than 2 weeks.

* Percentage of people using modern medicine given an episode
tab S05 health_episode, column // 97.5% used modern medicine if they looked for medical attention.

* Percentage of people not using any service
tab S05 health_episode, column // 41% of people with an episode did not look for attention

* Percentage of people that went to complex health facilities given an episode
tab health_complexite_hopital health_episode, column // High Complexity are 1-3
													 * only 10% went to high complexity.
*******************************************************************************													 
* Naive Average yearly health spending, we just multiply by 12 the monthly things

******************************************************************************
* Household Variables
******************************************************************************
capture ssc install glcurve
preserve

local monthly_spending health_total_consultation health_total_examens health_total_medicaments
local yearly_spending health_total_annual_hosp health_total_annual_aide health_total_annual_autres

foreach var in `monthly_spending'{
replace `var' = `var'*12
}

egen health_year_spending 		= rsum(`monthly_spending' `yearly_spending')

sum health_year_spending, detail // Average is 127477 CFA , median 26420 CFA
glcurve health_year_spending
*kdensity health_year_spending if health_year_spending>5000
*******************************************************************************
* Naive Average household yearly health spending

bysort zd menage:		egen health_menage_year_spending = total(health_year_spending) 

* Get only household level
duplicates drop zd menage region milieu, force

sum health_menage_year_spending, detail // Average HH health spending is 961560 CFA, median 90024.5
*kdensity health_menage_year_spending if health_menage_year_spending>10000
glcurve health_menage_year_spending // Distribution is incredible right-skewed by hh with high spending
restore


******************************************************************************
* Collapse to household level
******************************************************************************
duplicates drop zd menage, force


******************************************************************************
* Keep relevant variables for household
******************************************************************************
keep zd menage region milieu A6 res_entr3 B1A health_n_episodes ///
 health_long_episode health_n_moderne health_n_traditionel health_n_nonservice ///
 health_menage_complexite_hopital health_total_consultation health_total_examens ///
 health_total_medicaments health_total_annual_hosp health_total_annual_aide ///
 health_total_annual_autres health_menage_insurance health_menage_moustiquaire ///
 health_n_fumeurs health_menage_fumeur_quotidien health_n_fumeur_quotidien ///
 health_n_pregnancies health_n_pregnancies_succes

rename A6 passage
 
******************************************************************************
* Save Dataset
******************************************************************************
* Directory
cdoutput 

* Save
save e03_p3_special_health_agg, replace






******************************************************************************
**********************--------------------------------*************************
							** Antrhopometrie **
************************--------------------------------***********************
*******************************************************************************

/* Main objective is to get how many newborn kids have been in the household
the information is only for kids under 5 years old present in the household, there
are also empty rows marking households that did not have kids under 5 years old. */
clear all
* Directory
cddata

* Load special module
use emc2014_p4_anthropometrie


******************************************************************************
* 1. Relevant Variables
******************************************************************************

* Number of kids under 5 in each household.
gen an_enfant=0
replace an_enfant=1 		if (ANT01!=. & ANT10A==.) // making sure kid did not die.

bysort zd menage :		egen an_n_enfants = total(an_enfant)
label var an_n_enfants "N. of kids under 5 in household"

* Number of kids under 1 year old in the household
gen an_enfant_moins_un_an = 0
replace an_enfant_moins_un_an =1 if ANT04<=12

bysort zd menage :		egen an_n_enfants_moins_un_an = total(an_enfant_moins_un_an)
label var an_n_enfants_moins_un_an "N. of kids under 1 in household"

* Number of kids under 3 years old in the household
gen an_enfant_moins_trois_ans= 0
replace an_enfant_moins_trois_ans =1 if ANT04<=36

bysort zd menage :		egen an_n_enfants_moins_trois_ans = total(an_enfant_moins_trois_ans)
label var an_n_enfants_moins_un_an "N. of kids under 3 in household"

* Number of deceased children in the household, died in the last 5 years.
gen an_enfant_mort =0
replace an_enfant_mort = 1 if (ANT10A!=.)

* A kids has died in the household, (only counted if he would be under 5 at moments of interview)
bysort zd menage :		egen an_menage_enfant_mort = max(an_enfant_mort)
label var an_menage_enfant_mort "A kid under has died in household in last 5 years (kid would be under 5 at moment of interview))"

* Number of kids that have died in the household in the last 5 years.
bysort zd menage :		egen an_n_enfant_mort = total(an_enfant_mort)
label var an_n_enfant_mort "N. of kids that have died in household in last 5 years"

* Household has had a child born outside hospital
gen an_nee_dehors_hopital = 0
replace an_nee_dehors_hopital = 1 	if (ANT05==2 | ANT05==3)

bysort zd menage :		egen an_menage_nee_dehors_hopital = max(an_nee_dehors_hopital)
label var an_menage_nee_dehors_hopita "At least one kid in the hh was born outside hospital in last 5 years"

* Number of kids born outside hospital
bysort zd menage :		egen an_n_nee_dehors_hopital = total(an_nee_dehors_hopital)
label var an_menage_nee_dehors_hopita "N. of kids born outside hospital last 5 years"

* Average number of prenatal consultations in each household
bysort zd menage :	egen an_menage_consul_prenatales = mean(ANT07)
label var an_menage_consul_prenatales "Average number of prenatal consultations for each household, last 5 years"

* At least one kid in household participates in program
gen an_nutritionnel = 0
replace an_nutritionnel = 1 if ANT08A==1
gen an_croissance = 0
replace an_croissance =1 if ANT08B==1

* 1. Nutritional Program:
bysort zd menage :		egen an_menage_nutritionnel = max(an_nutritionnel)
label var an_menage_nutritionnel "At least one kid under 5 participated of Programme Nutritionnel"
*2. Croissance program:
bysort zd menage :		egen an_menage_croissance = max(an_croissance)
label var an_menage_croissance "At least one kid under 5 participated of Programme Croissance"




 *******************************************************************************
**********************--------------------------------*************************
							** Data Checks **
************************--------------------------------***********************
*******************************************************************************
* All naive and sample estimates as we are not using the appropiate weights for
* population estimates, and also we are not using the proper frame to account for
* possible input mistakes, or the non presence of some household in this data.

******************************************************************************
* Individual Variables
******************************************************************************

* Percentage of kids born outside hospital
tab an_nee_dehors_hopital if ANT01!=. // 12.6% of kids born outside hospital

* Who assited the labour of the kids, given that they lived or not.
tab ANT06 an_enfant_mort, column
/*

For those living:
Doctor: 1.73%, Nurse: 32.13%, Magneuticien/Sage-femme 31.99%,
Accouch. Auxiliaire: 21.52%, Accouch. Villageoise: 8.08%, Autre: 4.55%

For those that died:
Doctor: 1.22%, Nurse: 28.66%, Magneuticien/Sage-femme 25%,
Accouch. Auxiliaire: 25.61%, Accouch. Villageoise: 10.98%, Autre: 8.54%
*/

* Average number of consultations prenatales for each kid
sum ANT07 , detail // average of 3.821 , median of 4.
histogram ANT07
glcurve ANT07 // Very egalitarian distribution


* Percentage of kids in programme nutritionnel
tab an_nutritionnel if ANT10A!=. // 10% of kids in the sample

* Percentage of kids in programme croissance
tab an_croissance if ANT10A!=. // 18.86% of kids in the sample.


******************************************************************************
* Household Variables
******************************************************************************


* Get household level dataset
duplicates drop zd menage , force


* Average number of consultations prenatales for each household
sum an_menage_consul_prenatales, detail // Average of 3.85 almost identical median at 4
histogram an_menage_consul_prenatales

* Number of kids under 5 in each household
sum an_n_enfants, detail // Average 1.11 kid under 5 per household
histogram an_n_enfants // left skewed

* Percentage of households that have had a deceased children in last 5 years.
tab an_menage_enfant_mort // 1.98% of households have had a kid die.



 *******************************************************************************
**********************--------------------------------*************************
							** Save Data for HH databse **
************************--------------------------------***********************
*******************************************************************************


******************************************************************************
* Keep relevant variables for household
******************************************************************************

keep zd menage region milieu A6 B1A an_n_enfants an_n_enfants_moins_un_an ///
an_n_enfants_moins_trois_ans an_menage_enfant_mort an_n_enfant_mort ///
an_menage_nee_dehors_hopital an_menage_consul_prenatales an_menage_nutritionnel ///
an_menage_croissance

rename A6 passage


******************************************************************************
* Save dataset
******************************************************************************

* New directory
cdoutput

* Save hh level dataset
save e03_p4_special_anthropometrie_agg, replace







******************************************************************************
**********************--------------------------------*************************
					** Antrhopometrie - Pregnancy in months **
************************--------------------------------***********************
*******************************************************************************

* We want to check the age of the youngest child here, in order to estimate pregnancy
* in months for mothers in previous passages.

clear all
* Directory
cddata

* Load special module
use emc2014_p4_anthropometrie



*--------------------------------------------------*
*1.0 Relevant observations
*--------------------------------------------------*


* We only want children under 4 months old, to only cover period of pregnancy.
keep if ANT04<15

* Keep only the youngest in this category per household
egen preg_youngest = min(ANT04), by(zd menage)
	drop if ANT04!= preg_youngest

* Drop households that have more than one child with same age in months
duplicates drop zd menage, force	

*--------------------------------------------------*
*1.1 Relevant characteristics of this pregnancy
*--------------------------------------------------*

clonevar preg_lieunaissance 		= ANT05
clonevar preg_profnaissance 		= ANT06
clonevar preg_nprenatal 			= ANT07
clonevar preg_prognutritionnel 		= ANT08A
clonevar preg_progsuivecroissance 	= ANT08B
clonevar preg_poids					= ANT11A
clonevar preg_taille 				= ANT11B




*--------------------------------------------------*
*2. Save Data into dataframe
*--------------------------------------------------*

keep zd menage A6 preg*
	rename A6 passage

* Save
cdoutput
save e03_p4_special_pregnancy, replace	
