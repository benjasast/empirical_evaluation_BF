clear all
set more off
*set trace on
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Chef Menage Variables
* File Name: e10_adds_chef_menage
* RA: Benjamin Sas
* PI: Karen Grepin	
* Date: 16/08/18 
* Version: 1			
*******************************************************************************
/* We will merge into our DataFrame all variables related to the HHs chief
*/
*******************************************************************************
* Directory
cddata
* Load Data
use emc2014_p1_individu
*******************************************************************************


*******************************************************************************
***************--------------------------------------------********************
					** I. Identify Chef de Menage **
***************--------------------------------------------********************
*******************************************************************************


*--------------------------------------------------*
*1.1 Characteristics chef menage
*--------------------------------------------------*

* Order houses
sort zd menage B5

* Keep if it is chef de menage
keep if B5==1

* Id of Chef menage
gen chef_id = numind

* Chef menage is female
gen chef_female = (B2==2) & !mi(B2)

* Chef's age
clonevar chef_age = B4

* Etat Matrimonial de chef menage
clonevar chef_etat_matrimonial = B6

* Chef menage is married - monogame
gen chef_menage_marrie_monogamy = (B6==1) & !mi(B6)

* Chef menage is married - polygame
gen chef_menage_marrie_poligamy = (B6==2) & !mi(B6)

* chef menage educational level
clonevar chef_education = B14

* Chef menage has been sick or injured last 15 days
clonevar chef_maladie_blesse = B17

* Chef menage Maladie ou blesse 1
clonevar chef_maladie_blesse_1 = B18A

* Chef menage Maladie ou blesse 2
clonevar chef_maladie_blesse_2 = B18B

* Chef menage Maladie ou blesse 3
clonevar chef_maladie_blesse_3 = B18C

* Chef menage went to health service or healer
clonevar chef_menage_went_treatment = B19

* Chef menage went to health service or healer
clonevar chef_menage_type_treatment = B20




*--------------------------------------------------*
*1.2 Save
*--------------------------------------------------*

* Keep relevant vars
keep chef* passage zd menage numind
* Save
cdoutput
save e10_chef_menage, replace


*******************************************************************************
***************--------------------------------------------********************
				  ** II. Work of Chef Menage **
***************--------------------------------------------********************
*******************************************************************************
clear all
* Directory
cddata
* Load Data
use emc2014_p1_emploi
*******************************************************************************

* Merge with chef menage data
cdoutput
merge 1:1 zd menage numind using e10_chef_menage

* Drop the non-matched (not chef-menage)
drop if _merge==1 | _merge==2

*--------------------------------------------------*
*2.1 Characteristics chef menage
*--------------------------------------------------*

* Chef menage has not worked for a week
gen chef_pas_travaille = (W01==1 & W02==7) & !mi(W01, W02)
label var chef_pas_travaille "HH chef has not worked in last week, either in remunarated or non remunerated job"

* Chef menage has not worked for a week and has a job
gen chef_pas_traveilleavecjob = (chef_pas_travaille==1 & W03==1) & !mi(chef_pas_travaille, W03)
label var chef_pas_traveilleavecjob "HH chef has not worked last week but he/she has a job"
* Chef menage has not worked for a week and did not do so because of disiease
gen chef_pas_traveillemaladie = (chef_pas_travaille==1 & W04==2) & !mi(chef_pas_travaille, W03)

* Chef menage has not worked and did not so because fo reason..
clonevar chef_pas_travailleraisons = W04
label var chef_pas_travailleraisons "Several reasons why chef menage did not go to work last week"

* How long will chef menage be absent if he was sick
clonevar chef_pas_travaille_duration = W05
label var chef_pas_travaille_duration "HH chef not work last week, estimated duration of absense"

* Chef is invalid or long time sick and has not worked because of that
gen chef_pastravaille_lmalade_inval = (W10==1) & !mi(W10) 
label var chef_pastravaille_lmalade_inval "HH has no job because is long time sick or invalid"

* Chef nature of employment
clonevar chef_travaille_type = W22

* Socioprofessional category
clonevar chef_travaille_position = W23

* Industry where he works
clonevar chef_travaille_profession = W24

	*--------------------------------------------------*
	*2.1.1 Simplify Profession of Chef Menage
	*--------------------------------------------------*
	
	* Aggregation of profession to a low level
	
	egen new = cut(W24), at(0 8 34 44 85 111 120 127 134 139 158 181 183 189 192 207 226 238 246 247 ///
							249 253 257 259 277 279 283 292 301 308 318 326 330 337 338 339 345 375 383 391 398 399 ///
							444 462 513 524 544 549 997) icodes
		label var new "Aggregation of Profession to a low level"
		
	* Creates labels for the new groups						
	forvalue  i = 1(1)1 {
	
	label define new ///
	0 "MEMBRES DE L'EXECUTIF ET DU CORPS LEGISLATIF" ///
	1 "CADRES SUPERIEURS DE L'ADMINISTRATION PUBLIQUE"  ///
	///
	2 "DIRIGEANTS ET CADRES SUPERIOR D'ENTERPRISE"	///
	///
	3 "SPECILISTES DES SCIENCES PHYSIQUES, MATH, ET TECHNIQUES" ///
	4 "SPECILISTES SCIENCES DE LA VIE ET SANTE" ///
	5 "SPECILISTES DE L'ENSEIGNMENT" ///
	///
	6 "SPECILISTES DE FUNCTIONS COMMERCIEL ET ADMINISTRATIF D'ENTERPRISE" ///
	7 "JURISTES" ///
	8 "ARCHIVISTES, BIBLIOTECAIRES, documentalistes et assimilés" ///
	9 "SPECILISTES DE SCIENCES SOCIALES ET HUMAINES" ///
	10 "ECRIVAINS, ARTISTES CREATEURS ET EXECUTANTS" ///
	11 "MEMBRES DU CLERGE" ///
	///
	12 "Cadres de l'administration territoriale, du travail et de la sécurité Sociale" ///
	13 "Cadres de l'Enseignement et de la recherche" ///
	14 "Cadres de la santé et des affaires sociales" ///
	15 "Cadres du secteur des télécommunications, Transports, Equipement et Bâtiment, construction" ///
	16 "Cadres Supérieurs des Ressources Financière, Budget, Planification, Commerce, Banque et Assurances" ///
	17 "Cadres Supérieurs de l'Agriculture, Elevage et Forêt" ///
	18 "Cadres Supérieurs de l'Energie, de la Géologie et Mines" ///
	19 "Cadres Supérieurs de la Justice, de l'Information et des Relations Extérieures" ///
	20 "Cadres Supérieurs de l'Information, écrivains, artistes créateurs et exécutants" ///
	21 "Cadres Supérieurs de sports" ///
	22 "Autres Cadres Supérieurs non classés ailleurs" ///
	23 "Techniciens des sciences physiques et techniques" ///
	24 "Technicien spécialiste des sciences de la vie (biologiste, botanique, etc,)" ///
	///
	25 "Cadres Moyens de l'Administration, du Travail et de la Sécurité Sociale" ///
	26 "Cadres Moyens de l'Enseignement et de la bibliothéconomie" ///
	27 "Cadres Moyens de la Santé et de l'Action Sociale" ///
	28 "Cadres Moyens des Télécommunications Transports Equipement - Bâtiments" ///
	29 "Cadres Moyens des Ressources financières, Budget, Planification, commerce, banques et assurances" ///
	30 "Cadres Moyens de l'Agriculture, Elevage, Forêt, Géologie et Mines" ///
	31 "Cadres Moyens de la Justice - de l'Information et des Affaires Etrangères" ///
	32 "Cadres Moyens de la création artistique, du spectacle et des sports" ///
	33 "Professions intermédiaires - cadre moyen NCA" ///
	///
	34 "Cadres subalternes administration territoriale" ///
	35 "Cadres subalternes de l'Agriculture - Elevage Forêt - Géologie et Mines" ///
	36 "Cadres Subalternes des Administrations, Finances, Trésor, Planification, commerce, banque et assurances" ///
	37 "Cadres Subalternes de l'Equipement - des Transports des Télécommunications - du Bâtiment" ///
	38 "Cadres Subalternes de la Santé" ///
	39 "Autre personnel subalterne" ///
	40 "Personnel du type administratif et cadre subalterne de l'administration NCA" ///
	///
	41 "GRAND GROUPE 5 : PERSONNEL DES SERVICES ET VENDEURS DE MAGASIN ET DE MARCHE" ///
	///
	42 "GRAND GROUPE 6 : AGRICULTEURS ET OUVRIERS QUALIFIES DE L'AGRICULTURE ET LA PECHE" ///
	///
	43 "GRAND GROUPE 7 : ARTISANS ET OUVRIERS DES METIERS DE TYPE ARTISANAL" ///
	///
	44 "GRAND GROUPE 8 : CONDUCTEUR D'INSTALLATIONS ET DE MACHINES ET OUVRIERS DE L'ASSEMBLAGE" ///
	///
	45 "GRAND GROUPE 9 : OUVRIERS ET EMPLOYES NON QUALIFIES" ///
	///
	46 "GRAND GROUPE 0 : ARMEE ET SECURITE" ///
	///
	47 "AUTRES METIERS ET PROFESSIONS"
	
	label values new new
	tab new
}	

	* Aggregations to the super groups done in the survey
	egen new2 = cut(W24), at(0 44 183 338 399 444 462 513 524 544 549) icodes
		label var new2 "Aggregation of Professions to Super Groups"
	
	forvalues i = 1(1)1{

		label define new2 ///
		0 "GRAND GROUPE 1 : MEMBRES DE L'EXECUTIF ET DU CORPS LEGISLATIF,CADRES SUPERIEURS DE L'ADMINISTRATION PUBLIQUE,DIRIGEANTS ET CADRES SUPERIEUR D'ENTREPRISE" ///
		1 "GRAND GROUPE 2 : PROFESSIONS INTELLECTUELLES ET SCIENTIFIQUE" ///
		2 "GRAND GROUPE 3 : PROFESSIONS INTERMEDIAIRES" ///
		3 "GRAND GROUPE 4 : EMPLOYE DE TYPE ADMINISTRATIF - CADRES SUBALTERNES DE L'ADMINISTRATION" ///
		4 "GRAND GROUPE 5 : PERSONNEL DES SERVICES ET VENDEURS DE MAGASIN ET DE MARCHE" ///
		5 "GRAND GROUPE 6 : AGRICULTEURS ET OUVRIERS QUALIFIES DE L'AGRICULTURE ET LA PECHE" ///
		6 "GRAND GROUPE 7 : ARTISANS ET OUVRIERS DES METIERS DE TYPE ARTISANAL" ///
		7 "GRAND GROUPE 8 : CONDUCTEUR D'INSTALLATIONS ET DE MACHINES ET OUVRIERS DE L'ASSEMBLAGE" ///
		8 "GRAND GROUPE 9 : OUVRIERS ET EMPLOYES NON QUALIFIES" ///
		9 "GRAND GROUPE 0 : ARMEE ET SECURITE"
		
		label values new2 new2
		tab new2
}

	* Rename new variables
	rename new chef_travaille_professionv2
	rename new2 chef_travaille_professionv3

*--------------------------------------------------*
*2.2 Save
*--------------------------------------------------*

* Relevant vars
keep chef* zd menage

* Save
cdoutput
save e10_chef_menage, replace


*******************************************************************************
***************--------------------------------------------********************
				 ** III. Merge with DataFrame **
***************--------------------------------------------********************
*******************************************************************************
* Load data
cdoutput
use e08_dataframe_with_foodsecurity

* Merge
capture drop _merge
merge m:1 zd menage using e10_chef_menage
capture drop _merge

* Save DataFrame
save e10_chef_menage, replace








