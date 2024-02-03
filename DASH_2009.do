**********************************************************************************
* BY: 					JANE MADDOCK
* DATASETS: 			NSHD 2009
* DATE CREATED:			27/01/2023 
* LAST MODIFIED:
* PURPOSE: 				CREATE DASH DIET SCORE 
* NOTES:				RESTRICT TO AT LEAST 3 DAYS
*						BASED ON PAPER 	Maddock et al 2018 Br J Nur:119(5):581-589
* FILES CREATED:		DASH_2009.dta
*************************************************************************************


*--------------------------------------------------------------------
* PROGRAM SETUP

version 17 			 //Set version for backward compatiblity
set more off  		//Disable partitioned output
clear all 			//clear previous memory 
set more off 		//Disabile partitoned output
macro drop _all 
capture log close
*---------------------------------------------------------------------

*------------------------------------------------------------------------------------------------
* FILE SETUP

global datain "<INSERT PATH TO LONG FORM DIETARY DATA>"
global dataout "<INSERT PATH TO WHERE THE DATA IS TO BE SAVED>"
import delimited  "$datain\<NAME OF LONG FORM DIET DATA>.csv",  bindquote(strict) 
*-------------------------------------------------------------------------------------------------

*-----------------------------------------------------------------------------------------------------------------------------------------------------
* QUICK CHECK OF THE DATASET

desc
tab studytitle 								//ensure you are keeping the diary data only, there may also be recall data in other years (see dietary resource document for more info)
keep if studytitle=="NSHD 2009 - Diary" 
by ntag1, sort: gen first_ntag1= _n==1		//tag unique ids
tab first_ntag1 							//281,720 observations; 1,870 participants 
*-----------------------------------------------------------------------------------------------------------------------------------------------------


*------------------------------------------------------------------------------------------------------------------------------------------------
* RESTRICT TO AT LEAST 3 DAYS OF DATA 

by ntag1 day_of_week, sort: gen ndays =_n==1 	//tags the first day the participant responds (all repeated occasions within each day as zero)
br ntag1 day_of_week ndays 						//check
by ntag1: replace ndays = sum(ndays)			//replaces zeros with appropriate number representing the day
br ntag1 day_of_week ndays 						//check
by ntag1: replace ndays = ndays[_N] 			//assigns total number of days to each participant 
br ntag1 day_of_week ndays 						//check
tab ndays if first_ntag1
keep if ndays >=3 
count if first_ntag1  							//N=1869

*---------------------------------------------------------------------------------------------------------------------------------------------------------* 

*---------------------------------------------------------------------------------------------------------------------------------------------------------* 
*PREPARE FOODGROUPS FOR DASH DIET

/* Required:
fruitg, driedfruig, fruitJnosugar(create), purejuice(create)
tomatoesg, tomatopureeg, brassicaceaeg, yellowredgreeng, othervegg (not including potatoes)
beansg, nutsg
lfdairyg (create)
wholegraing
sodiummg
softdrink_g, fruitjsugar_g, fruitsqsugar_g  
beeg, lambg, porkg, processedredmeatg, otherredmeatg, burgersg, sausagesg, processedpoultryg
*/			

# delimit ; 
su fruit_g driedfruit_g 
   tomatoes_g tomatopuree_g brassicaceae_g yellowredgreen_g otherveg_g 
   beans_g nuts_g 
   wholegrain_g  sodium_mg 
   beef_g lamb_g pork_g processedredmeat_g otherredmeat_g burgers_g sausages_g processedpoultry_g ;
   

*Create lowfat dairy group ;
gen lgdairy_g =  total_grams if
							foodgroupdesc=="Dairy products - Yoghurt & drinking yoghurts, incl. buttermilk and probiotics - reduced or low fat products" | 
							foodgroupdesc=="Milk - 1% milk" | 
							foodgroupdesc=="Milk - Semi-skimmed milk" | 
							foodgroupdesc=="Milk - Skimmed milk" ;
# delimit cr								
 
*Generate SSB groups
gen softdrink_g = total_grams  if foodgroupdesc=="Beverages - Carbonated soft drinks" 
replace softdrink_g=0 if softdrink_g==. 

gen fruitjsugar_g = total_grams  if (foodgroupdesc=="Beverages - Fruit based drinks - Fruit juice drinks" & total_grams  != fruitjuice_g) 
replace fruitjsugar_g=0 if fruitjsugar_g==. 

gen fruitsqsugar_g = total_grams  if foodgroupdesc=="Beverages - Fruit based drinks - Squashes & fruit concentrates" 
replace fruitsqsugar_g=0 if fruitsqsugar_g==. 

*Fruit juice group for fruit category
gen fruitjnosugar_g = total_grams  if (foodgroupdesc=="Beverages - Fruit based drinks - Fruit juice drinks" & total_grams  == fruitjuice_g) 
replace fruitjnosugar_g=0 if fruitjnosugar_g==. 

gen purejuice_g = total_grams  if (foodgroupdesc=="Beverages - Fruit based drinks - Pure fruit juice & smoothies" & total_grams  == fruitjuice_g)
replace purejuice_g=0 if purejuice_g==.
*---------------------------------------------------------------------------------------------------------------------------------------------------------* 

 
 
*---------------------------------------------------------------------------------------------------------------------------------------------------------* 
*AGGREGATE FOOD GROUPS

*Collapse into wide format			
order ntag1 studytitle diarydate day_of_week foodgroupdesc 

# delimit ; 
collapse (sum) 
	energy_kcals 
	fruit_g 
	driedfruit_g 
	tomatoes_g 
    tomatopuree_g 
    brassicaceae_g 
    yellowredgreen_g 
    otherveg_g 
    beans_g nuts_g 
    wholegrain_g  
    sodium_mg 
    beef_g 
    lamb_g 
    pork_g 
    processedredmeat_g 
    otherredmeat_g 
    burgers_g 
    sausages_g 
    processedpoultry_g
	lgdairy_g
	softdrink_g
	fruitjsugar_g
	fruitsqsugar_g
	fruitjnosugar_g
	purejuice_g, by (ntag1 day_of_week) ;
# delimit cr
	
collapse (mean) energy_kcals-purejuice_g, by (ntag1) 
count 		//1869
*---------------------------------------------------------------------------------------------------------------------------------------------------------* 



*---------------------------------------------------------------------------------------------------------------------------------------------------------* 
*CREATE DASH CORE

sort ntag1
merge 1:1 ntag1 using "<PATH FILE FOR SEX VARIABLE>", keepusing(sex) 
keep if _merge==3

** Sum variables into the eight DASH groups (as in PMID: 18413553)
* Produce blank variables
g fruit          = 0
g vegetables     = 0
g nuts_legumes   = 0
g lf_dairy       = 0
g wholegrains    = 0
g grains		 = 0
g sodium         = 0
g ssb 	         = 0
g red_proc_meats = 0

* Sum grams of each included variable
replace fruit          = fruit_g + driedfruit_g + fruitjnosugar_g + purejuice_g                  		   // excludes beverages where fruitjg != Totalgram
replace vegetables     = tomatoes_g + tomatopuree_g + brassicaceae_g + yellowredgreen_g + otherveg_g 	  //Note: not including potatoes
replace nuts_legumes   = beans_g + nuts_g
replace lf_dairy       = lgdairy_g
replace wholegrains    = wholegrain_g
replace sodium         = sodium_mg
replace ssb	    	   = softdrink_g +  fruitjsugar_g + fruitsqsugar_g
replace red_proc_meats = beef_g + lamb_g + pork_g + processedredmeat_g + otherredmeat_g + burgers_g + sausages_g + processedpoultry_g

su fruit vegetables nuts_legumes lf_dairy wholegrains sodium  ssb  red_proc_meats
su fruit vegetables nuts_legumes lf_dairy wholegrains sodium  ssb  red_proc_meats, d


// account for energy using energy densities g/1000kcal 
*(******IMPORTANT: THIS IS THE CODE USED IN THE PAPER, HOWEVER RECENT WORK HAS HIGHLIGHTED THAT DENSITIES MAY NOT BE THE BEST APPROACH******)

* Energy adjust densities
foreach group in fruit vegetables nuts_legumes lf_dairy wholegrains sodium ssb red_proc_meats {
gen `group'_d = ((`group'/energy_kcals)*1000)
}

* Sort into quintiles
foreach group in fruit vegetables nuts_legumes lf_dairy wholegrains sodium ssb red_proc_meats {
	xtile `group'_dq = `group'_d , nquantiles(5)
	}
	
* For unhealthy foods make the quintiles negative
foreach variable in sodium_dq ssb_dq red_proc_meats_dq {
	replace `variable' = 6 - `variable'
	}

	
** Calculate DASH points and assign to quintiles
* Sum DASH points
g dash_c09 = fruit_dq + vegetables_dq + nuts_legumes_dq + lf_dairy_dq + wholegrains_dq + sodium_dq + ssb_dq + red_proc_meats_dq

* Sort into quintiles separately for men and women
xtile dash_q_men_d = dash_c09 if sex==1, nquantiles(5)
xtile dash_q_wom_d = dash_c09 if sex==2, nquantiles(5)
assert dash_q_wom_d ==. if dash_q_men_d!=.
assert dash_q_men_d ==. if dash_q_wom_d!=.
replace dash_q_men_d = 0 if dash_q_men_d==.
replace dash_q_wom_d = 0 if dash_q_wom_d==.

* Produce one variable for both men and women
g dash_q09 = dash_q_wom_d + dash_q_men_d

keep nshdid_ntag1 sex dash_c09 dash_q09
	
label var dash_c09 "DASH score continuous"
label var dash_q09 "DASH score quintiles"
*---------------------------------------------------------------------------------------------------------------------------------------------------------* 


sort ntag1
save "$dataout/dash_2009.dta", replace














