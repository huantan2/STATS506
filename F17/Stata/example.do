**********************************************************
* Example data import script for Stat 506 intro to Stata *
* Date: Aug 28, 2017
* Author: James Henderson (jbhender@umich.edu)
**********************************************************

**********
* Basics *
**********

* stata version *
version 14.2

* Working directory *
cd "~/Stats506/Stata/"

*********************
* working with data *
*********************

* import data *
import delimited using "esoph.csv"

* learn about the data set 
describe

* use list to view a variable 
list agegp

* change more option
set more off
list agp

* provide variable and other labels 
label var agegp "Age group"
label data "Esophogal cancer data."

* remove unwanted variables *
drop v1

* save in native stata format 
save esophg.dta

* clear removes current file
clear
describe

* use loads a Stata dataset
use esophg.dta
describe

**********************
* creating variables *
**********************

* gen or generate creates a new variable *
gen pct_cancer = ncases / (ncases + ncontrols)
label pct "Percent of cancerous cases."

* conditionals
gen any_cases = 1 if ncases > 0
list any_cases
replace any_cases = 0 if ncases == 0
list any_cases

* indicator variables
gen no_cases = (ncases == 0)
tab no_cases

* indicators for each category
tab agegp, gen(agegp_)

* stata internal variables
gen id = _n

* creating a group from several variables
egen alc_tob_group = group(alcgp tobgp), label

* save genearated data
save, replace