******************************
* Example summary statistics *
******************************

* set up *
version 14.2
cd ~/Stats506/Stata/

* load data *
use esophg.dta, clear

* 

generate total = ncases + ncontrols
egen age_group = group(agegp), label

poisson ncases i.age_group exposure(total)