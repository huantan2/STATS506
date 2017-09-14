*------------------------------------------------------------------------*
* Stats 506, F17 Stata Examples
* RECS (RECS_prep_subset1.do)
*
* This script imports RECS data from:
* http://www.eia.gov/consumption/residential/data/2009/csv/recs2009_public.csv
* and creates a subset for analysis. 
* 
* See also RECS_Consump_Analysis.do for an analysis.
*
* Author: James Henderson (jbhender@umich.edu)
* Date:   Sep 10, 2017
*------------------------------------------------------------------------*

*---------------*  
* Script Setup  *
*---------------*
version 14.2				// Stata version used
log using Ex_RECS.log, text replace 	// Generate a log
*cd ~/Stats506/Stata    	   		// Working directory
*display "$S_DATE"			// Print system dates
clear					// Start with a clean session

*------------------*
* Data preparation *
*------------------*

// import recs data
import delimited recs2009_public.csv

// various commands to undertand data
describe
*codebook				// Not run if commented
list doeid
summarize yearmade

// Change labels
label data "RECS 2009"
label variable doeid "DOE id"
label variable regionc "Census Region"
label variable ur "Urban or Rural"
label variable yearmade "Year Constructed"
label variable totsqft "Total Square Feet"
label variable kwh "Energy Consumption (kwh)"

// Generate new variables

** Urban Rural
generate urban = 1 if ur=="U"		// Stata prefers numeric types
replace urban = 0 if ur=="R"

** Next variable
/* Mix comment types for different purposes, not arbitrarily */ 

// Label values 
label define urban_rural 0 "Rural" 1 "Urban"
label values urban urban_rural
label variable urban "Urban / Rural"

// Compress will use smaller storage types where possible
compress

// To generate a specific type
generate byte city = urban

// Specify a location in the data set
generate byte rural = 1-0^urban, after(ur) // Also before(var)

// Using encode for the same thing
encode ur, generate(urban_rural)

// Remove one or more variables
drop city rural
drop hdd65-cdd30yr			// Drop a range of vars

// Keep only a subset of vars
keep doeid nweight urban regionc yearmade totsqft kwh

// Create standardized variables
foreach var of varlist yearmade-kwh {
  quietly summarize `var'
  generate `var'_z = (`var'- r(mean))/r(sd)
  label variable `var'_z "`var' (standardized)"
}

// Another apparoach using egen 
egen logkwh_z = std(log(kwh))

// Drop standardized variables
drop *_z			// Note the wildcard

// Save in Stata native dta format
save RECS_subset1.dta, replace

*-----------------*
* Script Cleanup  *
*-----------------*
log close
exit
