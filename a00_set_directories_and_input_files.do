clear all
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Set Directories
* File Name: a00_set_directories_and_input_files
* RA: Benjamin Sas
* PI: Karen Grepin				
*******************************************************************************
* Create Directories - Only needed to be done once
*******************************************************************************
** NECCESARY TO INSTALL WORKINGDIR PACKAGE ** -->> findit workingdir

* Benjamin
local user /Users/bsastrakinsky/Dropbox/Nouna_Health_Expenditures/Analysis

* Bridget
*local user /Users/birwin/Dropbox/NOUNA HEALTH EXPENDITURES/Analysis

* Data Directory
cd "`user'/Input_Data"

savecd data, replace //  Creates permanent directory cddata

* Output Directory
 cd "`user'/Output_Data"

savecd output,replace // Creates permanent directory cdoutput

* Tables Directory
 cd "`user'/Tables_Figures"

savecd tables, replace // Creates permanent directory cdtables

* Do-Files Directory
cd "`user'/Do_Files"

savecd dofile, replace // Creates permanent directory cddofile

* Do-Files Persistence
cd "`user'/Do_Files_Persistence"

savecd dofiles_persistence, replace

* Do-Files_Panel
cd "`user'/Do_Files_Panel"
savecd dofiles_panel , replace

* Do Files_Bounds
cd "`user'/Do_Files_Bounds"

savecd dofiles_bounds, replace

* Original Data Directory // We all need an individual one for this one
cd "/Users/bsastrakinsky/Dropbox/Nouna_Health_Expenditures/Data/Burkina Faso - Enquête Multisectorielle Continue 2014/Burkina Faso - Enquéte Multisectorielle Continue 2014/BKA_2013_EMC_v01_M_STATA8"

*Bridget*
*cd "/Users/birwin/Dropbox/NOUNA HEALTH EXPENDITURES/Data/Burkina Faso - Enquête Multisectorielle Continue 2014/Burkina Faso - Enquéte Multisectorielle Continue 2014/BKA_2013_EMC_v01_M_STATA8"

savecd originaldata, replace // Creates permanent directory cdoriginaldata

* Temp-Files
cd "`user'/Temporal_Files"

savecd tempfiles, replace

*******************************************************************************
* Put neccesary data into Input data
*******************************************************************************
** Food consumption ** Recall period 7 days
*******************************************************************************
forvalues i=1(1)4 {
* Directory
cdoriginaldata
* Use original Data
use emc2014_p`i'_conso7jours_16032015.dta
* Change to new directory
cddata
* save with new name
save emc2014_p`i'_conso7jours, replace
}
*******************************************************************************
** Nonfood consumption ** Recall period 3 months
*******************************************************************************
forvalues i=1(1)4{
* Directory
cdoriginaldata
* Use Original Data
use emc2014_p`i'_conso3mois_16032015.dta
* Change to new directory
cddata
* Save with new name
save emc2014_p`i'_conso3mois.dta, replace
}
*******************************************************************************
** Nonfood consumption ** Recall period 7 days only some items on P2, P3, P4
*******************************************************************************

*-------
* P2
*-------
* Directory
cdoriginaldata
* Original Data
use emc2014_p2_conso7nonalimjours_17032015
* New dir
cddata
* Save
save emc2014_p2_conso7nonalimjours, replace

*-------
* P3
*-------
* Directory
cdoriginaldata
* Original Data
use emc2014_p3_conso7nonalimjours_16032015
* New dir
cddata
* Save
save emc2014_p3_conso7nonalimjours, replace

*-------
* P4
*-------
* Directory
cdoriginaldata
* Original Data
use emc2014_p4_conso7nonalimjours_16032015
* New dir
cddata
* Save
save emc2014_p4_conso7nonalimjours, replace

*******************************************************************************
** Consumer Durables
*******************************************************************************

* Directory
cdoriginaldata
*Use original data
use emc2014_p1_biensdurables_27022015
* Change to new directory
cddata
*Save with new name
save emc2014_p1_biensdurables, replace


*******************************************************************************
** House characteristics and rent
*******************************************************************************

* Directory
cdoriginaldata
*Use original data
use emc2014_p1_logement_27022015
* Change to new directory
cddata
* Save with new name
save emc2014_p1_logement, replace


*******************************************************************************
** Special modules ** Recall period 1 year
*******************************************************************************

** 1. Education ** - Passage 4

* Directory
cdoriginaldata
* Use Original Data
use emc2014_p4_education_27022015
* Change to new directory
cddata
* Save with new name
save emc2014_p4_education, replace

** 2. Health ** - Passage 3

* Directory
cdoriginaldata
*Use Original Data
use emc2014_p3_sante_27022015
* Change to new directory
cddata
* Save with new name
save emc2014_p3_sante, replace

** 2. Anthropometric ** - Passage 4

* Directory
cdoriginaldata
* Use Original Data
use emc2014_p4_anthropometrie_27022015
* Change to new directory
cddata
* Save with new name
save emc2014_p4_anthropometrie, replace

*******************************************************************************
** Individual Data
*******************************************************************************
* Directory
cdoriginaldata
* Use Original Data
use emc2014_p1_individu_27022015
* Change to new directory
cddata
* Save with new name
save emc2014_p1_individu, replace

*******************************************************************************
** Welfare Indicators
*******************************************************************************

* Directory
cdoriginaldata
* Use Original Data
use emc2014_welfare
* Change to new directory
cddata
* Save with new name
save emc2014_welfare, replace


*******************************************************************************
** Individual Characteristics all passages
*******************************************************************************

forvalues i = 1(1)4{
* Directory
cdoriginaldata
* Use Original Data
use emc2014_p`i'_individu_27022015, replace
* Change to new directory
cddata
* Save with new name
save emc2014_p`i'_individu, replace
}


*******************************************************************************
** Employment - P1 to P4
*******************************************************************************

forvalues i = 1/4{

	* Directory
	cdoriginaldata
	* Use Original Data
	use emc2014_p`i'_emploi_27022015, replace
	* Change to new directory
	cddata
	* Save with new name
	save emc2014_p`i'_emploi, replace

}


*******************************************************************************
** Agricultural Equipment
*******************************************************************************

* Directory
cdoriginaldata
* Use Original Data
use emc2014_agri_equipements, replace
* Change to new directory
cddata
* Save with new name
save emc2014_agri_equipements, replace


*******************************************************************************
** Agricultural Land
*******************************************************************************
* Directory
cdoriginaldata
* Use Original Data
use emc2014_agri_caracteristiques_parcelles, replace
* Change to new directory
cddata
* Save with new name
save emc2014_agri_caracteristiques_parcelles, replace


*******************************************************************************
** Food Security
*******************************************************************************


* Round 3

* Directory
cdoriginaldata
* Use Original Data
use emc2014_p3_securitealimentaire_27022015.dta , replace
* Change to new directory
cddata
* Save with new name
save emc2014_p3_securitealimentaire, replace


* Round 4

* Directory
cdoriginaldata
* Use Original Data
use emc2014_p4_securitealimentaire_27022015.dta, replace
* Change to new directory
cddata
* Save with new name
save emc2014_p4_securitealimentaire, replace


*******************************************************************************
** Shock Module
*******************************************************************************
* Directory
cdoriginaldata
* Use Original Data
use emc2014_p3_chocs_27022015
* Change to new directory
cddata
* Save with new name
save emc2014_p3_chocs , replace




