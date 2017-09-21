*------------------------------------------------------------------------*
* Stats 506, F17 Stata Examples
* RECS (RECS_Consump_Analysis.do)
*
* This script is based in part on an example from
* Prof. Shedden's F16 course notes:
* http://dept.stat.lsa.umich.edu/~kshedden/Courses/Stat506/stata_intro/
* 
* The example analyzes energy department data from the 2009
* Residential Energy Consumption Survey. 
* 
* The data loaded by this script was prepared using "RECS_prep_subset1.do".
*------------------------------------------------------------------------*

*------------------------------------------------------------------------*
*---------------*  
* Script Setup  *
*---------------*
version 14.2				// Stata version used
cd \\afs\umich.edu\user\j\b\jbhender\Stats506\Stata\RECS // Working Directory
log using RECS_Consump_Analysis.log, /// line break comment
 text replace				// Generates a log
set more off				// Don't page results

// Load existing stata dataset
use RECS_subset1.dta, clear
*------------------------------------------------------------------------*

*------------------------------------------------------------------------*
*------------------*
* Data Exploration *
*------------------*

// Label Census Region
label define region_codes 1 "NE" 2 "MW" 3 "S" 4 "W", replace
label values regionc region_codes

// Summarize yearmade by census region
*by regionc: summarize yearmade		// Produces an error if not sorted

sort regionc	      			// Sort and then summarize
by regionc: summarize yearmade

*bysort regionc: summarize yearmade	// Other options for sorting
*by regionc, sort: summarize yearmade

// Access computed results afer running commands
summarize yearmade
display r(mean)

*------------*
* Regression * 
*------------*
// simple linear regression
regress kwh yearmade
display e(r2_a)				// adjusted R-squared

// make year & constant more interpretable
generate year_since1920 = yearmade - 1920
label variable year_since1920 "Year Constructed"

// multiple regression
regress kwh year_since1920 totsqft
display %3.1f 100*e(r2_a)

regress kwh year_since1920 c.totsqft i.regionc // use prefix to specify
	    	          		// continuous(c.) / categorical(i.)

// log transform
generate lkwh = log(kwh)
label variable lkwh "Log KWH"

regress lkwh year_since1920 totsqft i.regionc

// Ask for exponentiated coefficients
regress lkwh year_since1920 totsqft i.regionc, eform("%Change")

// interactions
regress lkwh c.totsqft##c.year_since1920 i.regionc, eform("%Change")

regress lkwh c.totsqft c.year_since1920 i.regionc /// split across lines
  c.year_since1920#i.regionc, eform("%Change") cformat("%5.3f")

 regress lkwh c.totsqft c.year_since1920 i.regionc /// split across lines
  c.year_since1920#i.regionc, eform("%Change") cformat("%5.3f")

/* Good practice to center variables before interacting them */

// Check correlations with interaction term 
generate year_sqft = yearmade*totsqft
correlate yearmade totsqft year_sqft

generate year1920_sqft = year_since1920*totsqftt
correlate year_since1920 totsqft year1920_sqft

// Center year and scale by 10
quietly summarize yearmade
generate c_year = (yearmade - r(mean))/10  // Make unit decades
label variable c_year "10 Years (centered)"

// Center sq footage and scale by 100
quietly summarize totsqft
generate c_totsqft = (totsqft - r(mean))/100 // Per 100 sq ft
label variable c_totsqft "Total Sq Ft (100s, centered)"

generate cyear_csqft = c_totsqft*c_year
correlate c_year c_totsqft cyear_csqft

// regression with centered variables
regress lkwh c.c_totsqft##c.c_year i.regionc, eform("%Change")

*------------------------------------------------------------------------*

*-----------------*
* Script Cleanup  *
*-----------------*
log close
exit
