*------------------------------------------------------------------------*
* Stats 506, F17 Stata Examples
* RECS (RECS_ES.do)
*
* This script uses logistic regression to learn about the important predictors of 
* whether the primary fridge is Energy Star compliant.
*
*
* Author: James Henderson (jbhender@umich.edu)
* Date:   Sep 10, 2017
*------------------------------------------------------------------------*

*---------------*  
* Script Setup  *
*---------------*
version 14.2				// Stata version used
log using RECS_ES.log, text replace 	// Generate a log
cd ~/Stats506/Stata/RECS   	    	// Working directory
*cd \\afs\umich.edu\users\j\b\jbhender\Stats506\Stata\Recs // Windows path for MiDesktop
clear					// Start clean

*-----------*
* Data Prep *
*-----------*

use recs2009_public.dta, clear

// Label regions 
label define region_codes 1 "NE" 2 "MW" 3 "S" 4 "W", replace  
label values regionc region_codes 

// Decode missing values
mvdecode esfrig, mv(-2=.\-8=.\-9=.)
*mvdecode _, mv(-2=.\-8=.\-9=.) 

// Label outcome
label define estar 0 "Not Certified" 1 "Energy Star Certified"
label values esfrig estar
tabulate esfrig

//Exercise: write a foreach loop to apply estar to all applicable values.

// Logistic regression
logit esfrig totsqft i.regionc

// Use "logistic" to get estimates as odds ratios
logistic esfrig totsqft i.regionc, nolog

// Rescale house size
replace totsqft = totsqft/100
label variable totsqft "Total Square Feet (100s)"

// Repeat model
logistic esfrig totsqft i.regionc, nolog 

// In interaction, c. is necessary
logistic esfrig c.totsqft##i.regionc, nolog

*---------*
* Margins *
*---------*


/* Adjusted predictions at the means */

// Regional probabilities at mean of totsqft
margins regionc, atmeans cformat("%4.3f")

// Specific values of totsqft for "average region
margins, at(totsqft=(10 20 30)) atmeans 

/* Marginal Effects */

// marginal effect of region at mean of totsqft
margins, dydx(regionc) atmeans

// average marginal effect of region
margins, dydx(regionc)

// adjusted predictions at representative values
margins regionc, at(totsqft=(10 20 30)) cformat("%4.3f")

// marginal effects at rep. values
margins, dydx(regionc) at(totsqft=(10 20 30)) cformat("%4.3f")


*-----------------*
* Script Cleanup  *
*-----------------*
log close
exit