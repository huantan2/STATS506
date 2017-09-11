*------------------------------------------------------------------------*
* Stats 506, F17 Stata Examples
* RECS (RECS_merge.do)
*
* This script demonstrates how to merge data in Stata using subset of the RECS_2009 data.
* recs_a1.csv and recs_a2.csv contain the first 20 variables split by cases.
* recs_b1.csv and recs_b2.csv contain variables 1:10, and 1,11:20, respectively for all cases.
* See also RECS_Consump_Analysis.do for an analysis.
*
* Author: James Henderson (jbhender@umich.edu)
* Date:   Sep 10, 2017
*------------------------------------------------------------------------*

*---------------*  
* Script Setup  *
*---------------*
version 14.2				// Stata version used
log using RECS_merge.log, text replace 	// Generate a log
cd ~/Stats506/Stata/RECS   	    	// Working directory
clear					// Start clean

*------------------*
* Appending data   *
*------------------*

// import recs data and save as dta

// First set
import delimited ./merge_data/recs_a1.csv, clear
*describe
drop v1
save ./merge_data/recs_a1.dta, replace

// Second Set
import delimited ./merge_data/recs_a2.csv, clear
append using "./merge_data/recs_a1"	

*--------------*
* Joining data *
*--------------*
// Data should be sorted by matching vars before joining

import delimited ./merge_data/recs_b1.csv, clear
*describe
drop v1
gsort +doeid
save ./merge_data/recs_b1.dta, replace

import delimited ./merge_data/recs_b2.csv, clear
gsort +doeid

merge 1:1 doeid using "./merge_data/recs_b1.dta"
gsort +doeid

// Notice how non-shared variables are treated
*summarize v1

save ./merge_data/recs_b_merged.dta, replace

/* See also:
   help merge
   merge m:1	// many to one
   merge 1:m	// one to many
   merge m:m	// many to many
*/

*--------------------*
* Looping over files *
*--------------------*

// Create local file list
local files : dir "./merge_data/" file "*_c_*.csv"

// Display file names for pedagogy
foreach file in `files' {
  display "`file'"  
}

// To understand the loop below use these:
*/
describe
preserve

clear
describe

restore
describe
*/

// Import and append in a loop
foreach file in `files' {
  preserve
  import delimited ./merge_data/`file', clear
  save temp, replace
  restore
  append using temp
}
rm temp
save recs_merge_c.dta, replace

*-----------------*
* Script Cleanup  *
*-----------------*
log close
exit