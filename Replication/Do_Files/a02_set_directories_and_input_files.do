clear all
*******************************************************************************
					*** Burkina Phaso Project ****
*******************************************************************************
* Program: Set Directories
* File Name: a00_set_directories_and_input_files
* RA: Benjamin Sas
* PI: Karen Grepin				
*******************************************************************************
***************--------------------------------------------********************
						** 	I. Directories **
***************--------------------------------------------********************
*******************************************************************************
* Install Workingdir package
net from http://www.indiana.edu/~jslsoc/stata
	net install workingdir , replace

* Data Directory
cd "$user/Input_Data"

savecd data, replace //  Creates permanent directory cddata

* Output Directory
 cd "$user/Output_Data"

savecd output,replace // Creates permanent directory cdoutput

* Tables Directory
 cd "$user/Tables_Figures"

savecd tables, replace // Creates permanent directory cdtables

* Do-Files Directory
cd "$user/Do_Files"

savecd dofile, replace // Creates permanent directory cddofile

*******************************************************************************
***************--------------------------------------------********************
						** 	II. Packages to Install **
***************--------------------------------------------********************
*******************************************************************************

capture ssc install elasticregress // LASSO and RIDGE regressions.
capture ssc install blindschemes // Sceme for graphs

