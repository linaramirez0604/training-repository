/* -----------------------------------------------------------------------------
PROJECT: KINDERPREP AND TWO REPLICATIONS
PI's: ELI LIST, JOHN LIST, LINA RAMIREZ, ANYA SAMEK, HARUKA UCHIDA
TOPIC: MERGING SHEETS OF SPREADSHEET
AUTHOR: LINA RAMIREZ 
DATE CREATED: 21/05/2021
LAST MODIFIED: 21/05/2021 

NOTES: 
	- Run 0.master before running this file
	-Merging different sheets of excel spreadsheet to same sheet. 
	- Required files: 
	
		For 2018: 
		- "$pre_sd161_2018/Pre-assessment_2018_entry1"
		- "$pre_sd161_2018/Pre-assessment_2018_entry2"
		- "$post_sd161_2018/Post-assessment_2018_entry1"
		- "$post_sd161_2018/Post-assessment_2018_entry2"
		
		For 2019
		- "$pre_sd161_2019/Pre-assessment_2019_entry1"
		- "$pre_sd161_2019/Pre-assessment_2019_entry2"
		- "$post_sd161_2019/Post-assessment_2019_entry1"
		- "$post_sd161_2019/Post-assessment_2019_entry2"

		-install package 
							ssc install cfout
		
	

------------------------------------------------------------------------------*/

	


*-------------------------------------------------------------------------------
*						DIRECTORY
*
*------------------------------------------------------------------------------- 



clear 

gl Pre_sd161_2018 "$raw/2018_flossmoor_sd161/pre_assessment_May_2018"
gl Post_sd161_2018 "$raw/2018_flossmoor_sd161/post_assessment_August_2018"

gl Pre_sd161_2019 "$raw/2019_flossmoor_sd161/pre_assessment"
gl Post_sd161_2019 "$raw/2019_flossmoor_sd161/post_assessment"



*-------------------------------------------------------------------------------
*						MERGING SHEETS 
*
*------------------------------------------------------------------------------- 



local survey "Pre Post"
local years "2018 2019"

foreach var of local survey{
	foreach year of local years{

		forvalues i=1/2 {
	

	
	cd "${`var'_sd161_`year'}"
	
	
*General information
import excel "`var'-assessment_`year'_entry`i'.xlsx",  sheet("info") firstrow clear 
capture rename RAInitials ra_initials
drop if missing(checc_ID)
keep checc_ID form language first_name last_name school grade teacher birthday age assessor start_time end_time survey_date
rename checc_ID child
duplicates tag child, gen(duplicates) 
egen group=group(child duplicates)
egen indicator=rank(duplicates), unique by(group)
duplicates drop 
save info.dta, replace 


*PPVT 
import excel "`var'-assessment_`year'_entry`i'.xlsx",  sheet("ppvt") firstrow clear 
capture rename RAInitials ra_initials
drop if missing(child)
keep child ppvt_set01 ppvt_set02 ppvt_set03 ppvt_set04 ppvt_set05 ppvt_set06 ppvt_set07 ppvt_set08 ppvt_set09 ppvt_set10 ppvt_set11 ppvt_set12 ppvt_set13 ppvt_set14 comments
duplicates tag child, gen(duplicates) 
egen group=group(child duplicates)
egen indicator=rank(duplicates), unique by(group)
duplicates drop 

save ppvt.dta, replace 

*Spacial conflict 1 
import excel "`var'-assessment_`year'_entry`i'.xlsx",  sheet("spatial conflict 1") firstrow clear 
capture rename RAInitials ra_initials
drop if missing(child)
drop ra_initials 
duplicates tag child, gen(duplicates) 
egen group=group(child duplicates)
egen indicator=rank(duplicates), unique by(group)
duplicates drop 

save spatial_conflict.dta, replace 

*WJ 
import excel "`var'-assessment_`year'_entry`i'.xlsx",  sheet("wj") firstrow clear 
capture rename RAInitials ra_initials
drop if missing(child)
keep child wj_letter_word wj_let_word_ext wj_spelling wj_spelling_ext wj_applied wj_applied_ext wj_quant_a wj_quant_b comments
duplicates tag child, gen(duplicates) 
egen group=group(child duplicates)
egen indicator=rank(duplicates), unique by(group)
duplicates drop 

save wj.dta, replace 

*Ospan

import excel "`var'-assessment_`year'_entry`i'.xlsx",  sheet("ospan") firstrow clear 
capture rename RAInitials ra_initials
drop if missing(child)
drop ra_initials
duplicates tag child, gen(duplicates) 
egen group=group(child duplicates)
egen indicator=rank(duplicates), unique by(group)
duplicates drop 

save ospan.dta, replace 



*Same Game 

import excel "`var'-assessment_`year'_entry`i'.xlsx",  sheet("same_game") firstrow clear 
capture rename RAInitials ra_initials
drop if missing(child)
drop ra_initials 
sort child 
duplicates tag child, gen(duplicates) 
egen group=group(child duplicates)
egen indicator=rank(duplicates), unique by(group)
duplicates drop 

save samegame.dta, replace 

* PSRA 

import excel "`var'-assessment_`year'_entry`i'.xlsx",  sheet("psra") firstrow clear 
capture rename RAInitials ra_initials
drop if missing(child)
drop ra_initials 
duplicates tag child, gen(duplicates) 
egen group=group(child duplicates)
egen indicator=rank(duplicates), unique by(group)
duplicates drop 

save psra.dta, replace 


/* 
The variable "indicator" is made to merge arbitrarily the duplicated observations so we can have one unique dataset.
However, the data of these children has to be rechecked. 
*/


use info.dta, clear 
merge 1:1 child indicator using wj.dta, nogen
merge 1:1 child indicator using ppvt.dta, nogen 
merge 1:1 child indicator using spatial_conflict.dta, nogen 
merge 1:1 child indicator using ospan.dta, nogen 
merge 1:1 child indicator using samegame.dta, nogen 
merge 1:1 child indicator using psra.dta, nogen 

gen status="`var'" 
gen year=`year'
order status year, first
missings dropvars, force
drop duplicates 

duplicates tag child, gen(duplicates) 
duplicates drop child, force 


save `var'`year'_entry`i'.dta, replace

foreach variable in info ppvt spatial_conflict wj ospan samegame psra {
	erase `variable'.dta 
}

}

}
}

*Additonal cleaning

 cd ${Pre_sd161_2018}
 
 use Pre2018_entry2.dta, clear 
 drop if child=="FL1-21" // already exists 
 replace duplicates=1 if child=="FL1021" 
 drop if child=="Fl1013" // already exists 
 replace duplicates=1 if child=="FL1013" 
 
 save Pre2018_entry2.dta, replace 



*-------------------------------------------------------------------------------
*						ENTRY DISPARITIES 
*
*------------------------------------------------------------------------------- 


* Generating spreadsheets for RAs to check the disparities between entries

	local survey "Pre Post"
	local years "2018 2019"

	foreach var of local survey{
	foreach year of local years{

	
	
	cd ${`var'_sd161_`year'}
 
 
		use "`var'`year'_entry1.dta", clear
 
		capture drop comments 
 
		capture destring same1, force replace 
 
		cfout _all using "`var'`year'_entry2.dta", id(child) lower nopunct saving("$raw/mismatchs_fl/mismatch_`var'`year'", csv keepmaster(child) keepusing(child) replace)   
 
	}
	}
	
	
	local survey "Pre Post"
	local years "2018 2019"

	foreach var of local survey{
	foreach year of local years{
 

 
		import delimited "$raw/mismatchs_fl/mismatch_`var'`year'", varnames(1)  clear 
		rename master entry1 
		rename v4 entry2 
		gen correct_entry=. // column generated for RAs to check the true values. 
		export delimited "$raw/mismatchs_fl/mismatch_`var'`year'", replace 
		
		
	}
	}
 



 *END 
