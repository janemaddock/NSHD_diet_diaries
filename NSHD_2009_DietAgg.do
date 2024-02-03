*******************************************************************************************************
* BY: 					JANE MADDOCK
* DATASETS: 			NSHD 2009
* DATE CREATED:			25/01/2023 
* LAST MODIFIED:
* PURPOSE: 				AGGREGRATE DIETARY DATA 
* NOTES:				RESTRICT TO AT LEAST 3 DAYS
*						CAN ALSO BE APPLIED FOR 1982, 1989 AND 1999 BUT foodgroupdesc MAY DIFFER
* FILES CREATED:		foodgpagg_2009.dta (aggreated grams of food (based on food groups)
*						nutrientagg_2009.dta (aggregrated nutrient intakes)
*****************************************************************************************************


*--------------------------------------------------------------------
* PROGRAM SETUP

version 17 			 //Set version for backward compatiblity
set more off  		//Disable partitioned output
clear all 			//clear previous memory 
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
*AGGREGRATE NUTRIENT DATA FOR MEAN CONSUMPTION OVER NDAYS
/*At the moment all the data is long format for each eating occasion, so you need to 
1. Sum total grams/nutrients consumed per each day
2. Calcualte the mean consumed over all days

*/
preserve
collapse (sum) energy_kcals-total_grams , by (ntag1 day_of_week)
collapse (mean) energy_kcals-total_grams, by (ntag1) 
save "$dataout\nutrientagg_2009.dta", replace
restore

*---------------------------------------------------------------------------------------------------------------------------------------------------------* 


*---------------------------------------------------------------------------------------------------------------------------------------------------------* 
* AGGREGRATE FOODGROUP DATA

/*NOTE: 
	The following code assigns values (grams) to the foodgroupdesc variable in order to determine the average grams of this item comsumed over the 5 days.
	Please carefully check there are no errors in these assignments. 
    Could also use calories instead of grams (see https://doi.org/10.1093/ajcn/nqab266 for why you might want to do that).
	If you want to recode/regroup food grooups, do it in this step before collapsing data using foodgroupdesc and foodname.
*/

levelsof foodgroupdesc

gen wt09bbis=total_gram if foodgroupdesc=="Baby & infant foods/drinks - Biscuits"
label var  wt09bbis "Baby & infant foods/drinks - Biscuits"

gen wt09bcereal=total_gram if foodgroupdesc=="Baby & infant foods/drinks - Dried Cereals"
label var wt09bcereal "Baby & infant foods/drinks - Dried Cereals"

gen wt09bdrink=total_gram if foodgroupdesc=="Baby & infant foods/drinks - Drinks"
label var wt09bcereal "Baby & infant foods/drinks - Dried Cereals"

gen wt09brcereal=total_gram if foodgroupdesc=="Baby & infant foods/drinks - Ready meals - Cereal based"
label var wt09brcereal "Baby & infant foods/drinks - Ready meals - Cereal based"


gen wt09brdess=total_gram if foodgroupdesc=="Baby & infant foods/drinks - Ready meals - Desserts"
label var wt09brdess "Baby & infant foods/drinks - Ready meals - Desserts"

gen wt09alcalc=total_gram if foodgroupdesc=="Beverages - Alcohol - Alcopops"
label var wt09alcalc "Beverages - Alcohol - Alcopops"

gen wt09alcbe=total_gram if foodgroupdesc=="Beverages - Alcohol - Beer"
label var wt09alcbe "Beverages - Alcohol - Beer"

gen wt09alcfwin=total_gram if foodgroupdesc=="Beverages - Alcohol - Fortified wine"
label var wt09alcfwin "Beverages - Alcohol - Fortified wine"

gen wt09allow=total_gram if foodgroupdesc=="Beverages - Alcohol - Low alcohol beer"
label var wt09allow  "Beverages - Alcohol - Low alcohol beer"

gen wt09alcwin=total_gram if foodgroupdesc=="Beverages - Alcohol - Wine"
label var wt09alcwin "Beverages - Alcohol - Wine"

gen wt09sftdrink=total_gram if foodgroupdesc=="Beverages - Carbonated soft drinks"
label var wt09sftdrink "Beverages - Carbonated soft drinks"

gen wt09coffee=total_gram if foodgroupdesc=="Beverages - Coffee"
label var wt09coffee "Beverages - Coffee"

gen wt09fruitjd=total_gram if foodgroupdesc=="Beverages - Fruit based drinks - Fruit juice drinks"
label var wt09fruitjd "Beverages - Fruit based drinks - Fruit juice drinks"

gen wt09fruitsm=total_gram if foodgroupdesc=="Beverages - Fruit based drinks - Pure fruit juice & smoothies"
label var wt09fruitsm "Beverages - Fruit based drinks - Pure fruit juice & smoothies"

gen wt09sq=total_gram if foodgroupdesc=="Beverages - Fruit based drinks - Squashes & fruit concentrates"
label var wt09sq "Beverages - Fruit based drinks - Squashes & fruit concentrates"

gen wt09powb=total_gram if foodgroupdesc=="Beverages - Powdered Beverages (cocoa, Horlicks, Bonvita, Ovaltine, etc)"
label var wt09powb "Beverages - Powdered Beverages (cocoa, Horlicks, Bonvita, Ovaltine, etc)"

gen wt09tea=total_gram if foodgroupdesc=="Beverages - Tea"
label var wt09tea "Beverages - Tea"

gen wt09water=total_gram if foodgroupdesc=="Beverages - Water (still, tap, sparkling, flavoured)"
label var wt09water "Beverages - Water (still, tap, sparkling, flavoured)"

gen wt09brdb=total_gram if foodgroupdesc=="Breads - Brown/Granary/Wheatgerm"
label var wt09brdb "Breads - Brown/Granary/Wheatgerm"

gen wt09brdcr=total_gram if foodgroupdesc=="Breads - Crisp Breads, e.g. Rivetas, Grissini, Toast Melba"
label var wt09brdcr "Breads - Crisp Breads, e.g. Rivetas, Grissini, Toast Melba"

gen wt09brdo=total_gram if foodgroupdesc=="Breads - Other bread"
label var wt09brdo "Breads - Other bread"

gen wt09brdwhi=total_gram if foodgroupdesc=="Breads - White"
label var wt09brdwhi "Breads - White"

gen wt09brdwho=total_gram if foodgroupdesc=="Breads - Wholemeal"
label var wt09brdwho "Breads - Wholemeal"

gen wt09coat=total_gram if foodgroupdesc=="Breakfast cereals - Oat based cereals"
label var wt09coat "Breakfast cereals - Oat based cereals"

gen wt09chigh=total_gram if foodgroupdesc=="Breakfast cereals - Other breakfast cereals - high fibre (equal or >3g/40g portion)"
label var wt09chigh "Breakfast cereals - Other breakfast cereals - high fibre (equal or >3g/40g portion)"

gen wt09clow=total_gram if foodgroupdesc=="Breakfast cereals - Other breakfast cereals - low fibre"
label var wt09clow "Breakfast cereals - Other breakfast cereals - low fibre"

gen wt09cloth=total_gram if foodgroupdesc=="Cereals & cereal dishes - Other cereals & dishes"
label var wt09cloth "Cereals & cereal dishes - Other cereals & dishes"

gen wt09past=total_gram if foodgroupdesc=="Cereals & cereal dishes - Pasta & pasta dishes"
label var wt09past "Cereals & cereal dishes - Pasta & pasta dishes"

gen wt09pizz=total_gram if foodgroupdesc=="Cereals & cereal dishes - Pizza"
label var wt09pizz "Cereals & cereal dishes - Pizza"

gen wt09rice=total_gram if foodgroupdesc=="Cereals & cereal dishes - Rice & rice dishes"
label var wt09rice "Cereals & cereal dishes - Rice & rice dishes"

gen wt09choc=total_gram if foodgroupdesc=="Confectionary - Chocolate based products"
label var wt09choc "Confectionary - Chocolate based products"

gen wt09lolli=total_gram if foodgroupdesc=="Confectionary - Sorbets & lollies"
label var wt09lolli "Confectionary - Sorbets & lollies"

gen wt09suga=total_gram if foodgroupdesc=="Confectionary - Sugar based products"
label var wt09suga "Confectionary - Sugar based products"

gen wt09chee=total_gram if foodgroupdesc=="Dairy products - Cheese, incl. cottage cheese"
label var wt09chee "Dairy products - Cheese, incl. cottage cheese"

gen wt09crea=total_gram if foodgroupdesc=="Dairy products - Cream & fromage frais"
label var wt09crea "Dairy products - Cream & fromage frais"

gen wt09iceff=total_gram if foodgroupdesc=="Dairy products - Ice cream & dairy desserts - full fat products"
label var wt09iceff "Dairy products - Ice cream & dairy desserts - full fat products"

gen wt09icelw=total_gram if foodgroupdesc=="Dairy products - Ice cream & dairy desserts - reduced fat products"
label var wt09icelw "Dairy products - Ice cream & dairy desserts - reduced fat products"

gen wt09yogff=total_gram if foodgroupdesc=="Dairy products - Yoghurt & drinking yoghurts, incl. buttermilk and probiotics - full fat products"
label var wt09yogff "Dairy products - Yoghurt & drinking yoghurts, incl. buttermilk and probiotics - full fat products"

gen wt09yoglf=total_gram if foodgroupdesc=="Dairy products - Yoghurt & drinking yoghurts, incl. buttermilk and probiotics - reduced or low fat products"
label var wt09yoglf "Dairy products - Yoghurt & drinking yoghurts, incl. buttermilk and probiotics - reduced or low fat products"

gen wt09egg=total_gram if foodgroupdesc=="Egg & egg dishes"
label var wt09egg "Egg & egg dishes"

gen wt09fatan=total_gram if foodgroupdesc=="Fats - Animal based fats (solid)"
label var wt09fatan "Fats - Animal based fats (solid)"

gen wt09butt=total_gram if foodgroupdesc=="Fats - Butter"
label var wt09butt "Fats - Butter"

gen wt09oil=total_gram if foodgroupdesc=="Fats - Oils"
label var wt09oil "Fats - Oils"

gen wt09plfaff=total_gram if foodgroupdesc=="Fats - Plant based fats (solid) - Full fat"
label var wt09plfaff "Fats - Plant based fats (solid) - Full fat"

gen wt09plaflf=total_gram if foodgroupdesc=="Fats - Plant based fats (solid) - Low fat"
label var wt09plaflf "Fats - Plant based fats (solid) - Low fat"

gen wt09plafrf=total_gram if foodgroupdesc=="Fats - Plant based fats (solid) - Reduced fat"
label var wt09plafrf "Fats - Plant based fats (solid) - Reduced fat"


gen wt09fisho=total_gram if foodgroupdesc=="Fish & fish dishes - Oily fish"
label var wt09fisho "Fish & fish dishes - Oily fish"

gen wt09fishsh=total_gram if foodgroupdesc=="Fish & fish dishes - Shellfish"
label var wt09fishsh "Fish & fish dishes - Shellfish"

gen wt09fishw=total_gram if foodgroupdesc=="Fish & fish dishes - White fish, incl. tuna"
label var wt09fishw "Fish & fish dishes - White fish, incl. tuna"

gen wt09fruca=total_gram if foodgroupdesc=="Fruit - Canned & cooked"
label var wt09fruca  "Fruit - Canned & cooked"

gen wt09frudri=total_gram if foodgroupdesc=="Fruit - Dried"
label var wt09frudri "Fruit - Dried"

gen wt09frufrsh=total_gram if foodgroupdesc=="Fruit - Fresh"
label var wt09frufrsh "Fruit - Fresh"

gen wt09beef=total_gram if foodgroupdesc=="Meat - red - Beef & veal & dishes"
label var wt09beef "Meat - red - Beef & veal & dishes"

gen wt09lamb=total_gram if foodgroupdesc=="Meat - red - Lamb & dishes"
label var wt09lamb "Meat - red - Lamb & dishes"

gen wt09othme=total_gram if foodgroupdesc=="Meat - red - Other red meat, e.g. rabbit, venison"
label var wt09othme"Meat - red - Other red meat,  e.g. rabbit, venison"

gen wt09pork=total_gram if foodgroupdesc=="Meat - red - Pork & dishes"
label var wt09pork "Meat - red - Pork & dishes"

gen wt09chic=total_gram if foodgroupdesc=="Meat - white - Chicken & turkey & dishes"
label var wt09chic "Meat - white - Chicken & turkey & dishes"

gen wt09game=total_gram if foodgroupdesc=="Meat - white - Other game birds, (e.g. duck, goose, pheasant) & dishes"
label var wt09game "Meat - white - Other game birds, (e.g. duck, goose, pheasant) & dishes"

gen wt09mlk1=total_gram if foodgroupdesc=="Milk - 1% milk"
label var wt09mlk1 "Milk - 1% milk"

gen wt09mlkfl=total_gram if foodgroupdesc=="Milk - Milk based drinks, e.g. flavoured milks"
label var wt09mlkfl "Milk - Milk based drinks, e.g. flavoured milks"

gen wt09mlkoa=total_gram if foodgroupdesc=="Milk - Other - animal based, e.g. goat"
label var wt09mlkoa "Milk - Other - animal based, e.g. goat"

gen wt09mlkop=total_gram if foodgroupdesc=="Milk - Other - plant based, e.g. rice, soy"
label var wt09mlkop "Milk - Other - plant based, e.g. rice, soy"

gen wt09mlkss=total_gram if foodgroupdesc=="Milk - Semi-skimmed milk"
label var wt09mlkss "Milk - Semi-skimmed milk"

gen wt09mlks=total_gram if foodgroupdesc=="Milk - Skimmed milk"
label var wt09mlks "Milk - Skimmed milk"

gen wt09mlkwh=total_gram if foodgroupdesc=="Milk - Whole milk"
label var wt09mlkwh "Milk - Whole milk"

gen wt09swtna=total_gram if foodgroupdesc=="Miscellaneous - Artificial sweeteners"
label var wt09swtna "Miscellaneous - Artificial sweeteners"

gen wt09herb=total_gram if foodgroupdesc=="Miscellaneous - Dried herbs & spices & pastes"
label var wt09herb "Miscellaneous - Dried herbs & spices & pastes"

gen wt09salt=total_gram if foodgroupdesc=="Miscellaneous - Salt and salt substitutes"
label var wt09salt "Miscellaneous - Salt and salt substitutes"

gen wt09nudp=total_gram if foodgroupdesc=="Nutrition Powders & drinks"
label var wt09nudp "Nutrition Powders & drinks"

gen wt09nuse=total_gram if foodgroupdesc=="Nuts & Seeds (incl. peanut butter)"
label var wt09nuse "Nuts & Seeds (incl. peanut butter)"

gen wt09liver=total_gram if foodgroupdesc=="Offal - Liver & dishes"
label var wt09liver "Offal - Liver & dishes"

gen wt09offal=total_gram if foodgroupdesc=="Offal - Other offal & dishes, e.g. Haggis, faggots"
label var wt09offal "Offal - Other offal & dishes, e.g. Haggis, faggots"

gen wt09potop=total_gram if foodgroupdesc=="Potatoes - Potato products - other"
label var wt09potop "Potatoes - Potato products - othe"

gen wt09cutpic=total_gram if foodgroupdesc=="Preserves - Chutney & Pickles (incl. gherkins, pickled onions etc)"
label var wt09cutpic "Preserves - Chutney & Pickles (incl. gherkins, pickled onions etc)"

gen wt09jam=total_gram if foodgroupdesc=="Preserves - Jam & Marmalade"
label var wt09jam "Preserves - Jam & Marmalade"

gen wt09ham=total_gram if foodgroupdesc=="Processed meat - Bacon & ham"
label var wt09ham "Processed meat - Bacon & ham"

gen wt09meop=total_gram if foodgroupdesc=="Processed meat - Other processed meats"
label var wt09meop "Processed meat - Other processed meats"

gen wt09mepi=total_gram if foodgroupdesc=="Processed meat - Processed pies"
label var wt09meop "Processed meat - Processed pies"

gen wt09bean=total_gram if foodgroupdesc=="Pulses/Lentils - Baked beans"
label var wt09meop "Pulses/Lentils - Baked beans"

gen wt09lent=total_gram if foodgroupdesc=="Pulses/Lentils - Pulses/lentils"
label var wt09lent "Pulses/Lentils - Pulses/lentils"

gen wt09sauc=total_gram if foodgroupdesc=="Sauces & accompaniment - Cooking sauces, incl. gravies, pesto, cooking sauces for pasta and rice dishes"
label var wt09sauc "Sauces & accompaniment - Cooking sauces, incl. gravies, pesto, cooking sauces for pasta and rice dishes"

gen wt09may=total_gram if foodgroupdesc=="Sauces & accompaniment - Dressings & Mayonnaise"
label var wt09may "Sauces & accompaniment - Dressings & Mayonnaise"

gen wt09sauco=total_gram if foodgroupdesc=="Sauces & accompaniment - Other sauces, incl. brown sauce, soy sauce, ketchup, mint sauce, vinegar"
label var wt09sauco "Sauces & accompaniment - Other sauces, incl. brown sauce, soy sauce, ketchup, mint sauce, vinegar"

gen wt09saus=total_gram if foodgroupdesc=="Sausages & burgers & kebab"
label var wt09saus "Sausages & burgers & kebab"

gen wt09snkc=total_gram if foodgroupdesc=="Savoury Snacks - Cereal based snacks"
label var wt09snkc "Savoury Snacks - Cereal based snacks"

gen wt09snkp=total_gram if foodgroupdesc=="Savoury Snacks - Potato based snacks"
label var wt09snkp "Savoury Snacks - Potato based snacks"

gen wt09snks=total_gram if foodgroupdesc=="Savoury Snacks - Savoury biscuits & crackers"
label var wt09snks "Savoury Snacks - Savoury biscuits & crackers"

gen wt09snkv=total_gram if foodgroupdesc=="Savoury Snacks - Vegetable based snacks"
label var wt09snkv "Savoury Snacks - Vegetable based snacks"

gen wt09sopfr=total_gram if foodgroupdesc=="Soups - Canned & fresh & homemade"
label var wt09sopfr "Soups - Canned & fresh & homemade"

gen wt09sopdr=total_gram if foodgroupdesc=="Soups - Dried"
label var wt09sopdr "Soups - Dried"

gen wt09syr=total_gram if foodgroupdesc=="Sugars - Other, incl. syrups, honey"
label var wt09syr "Sugars - Other, incl. syrups, honey"

gen wt09psug=total_gram if foodgroupdesc=="Sugars - Pure sugars"
label var wt09syr "Sugars - Pure sugars"

gen wt09supd=total_gram if foodgroupdesc=="Supplements - Calcium Only or with Vitamin D"
label var wt09supd "Supplements - Calcium Only or with Vitamin D"

gen wt09supcod=total_gram if foodgroupdesc=="Supplements - Cod Liver Oil and other Fish Oils"
label var wt09supd "Supplements - Cod Liver Oil and other Fish Oils"

gen wt09supo=total_gram if foodgroupdesc=="Supplements - Evening Primrose Oil and Other Plant Oils"
label var wt09supo "Supplements - Evening Primrose Oil and Other Plant Oils"

gen wt09supfa=total_gram if foodgroupdesc=="Supplements - Folic Acid"
label var wt09supfa "Supplements - Folic Acid"

gen wt09supir=total_gram if foodgroupdesc=="Supplements - Iron Only or with Vitamin C"
label var wt09supir "Supplements - Iron Only or with Vitamin C"

gen wt09supmin=total_gram if foodgroupdesc=="Supplements - Minerals (Two or more including Multi Minerals) No Vitamins"
label var wt09supmin "Supplements - Minerals (Two or more including Multi Minerals) No Vitamins"

gen wt09supher=total_gram if foodgroupdesc=="Supplements - Non-Nutrient Supplements (Including Herbal)"
label var wt09supher "Supplements - Non-Nutrient Supplements (Including Herbal)"

gen wt09suponut=total_gram if foodgroupdesc=="Supplements - Other Nutrient Supplements"
label var wt09supher "Supplements - Other Nutrient Supplements"

gen wt09supsin=total_gram if foodgroupdesc=="Supplements - Single Vitamins/Minerals NOT Folic,  Fe, Ca, Vit D"
label var wt09supsin "Supplements - Single Vitamins/Minerals NOT Folic,  Fe, Ca, Vit D"

gen wt09vita=total_gram if foodgroupdesc=="Supplements - Vitamins (Two or more including Multi Vitamins) No Minerals"
label var wt09vita "Supplements - Vitamins (Two or more including Multi Vitamins) No Minerals"

gen wt09vitamins=total_gram if foodgroupdesc=="Supplements - Vitamins and Minerals (Including Multi Vitamins & Minerals)"
label var wt09vitamins "Supplements - Vitamins and Minerals (Including Multi Vitamins & Minerals)"

gen wt09biscu=total_gram if foodgroupdesc=="Sweet cereal products - Biscuits"
label var wt09biscu "Sweet cereal products - Biscuits"

gen wt09cbar=total_gram if foodgroupdesc=="Sweet cereal products - Cereal bars"
label var wt09cbar "Sweet cereal products - Cereal bars"

gen wt09cerpud=total_gram if foodgroupdesc=="Sweet cereal products - Cereal based puddings (not milk)"
label var wt09cerpud "Sweet cereal products - Cereal based puddings (not milk)"

gen wt09mlkpud=total_gram if foodgroupdesc=="Sweet cereal products - Milk based puddings"
label var wt09mlkpud "Sweet cereal products - Milk based puddings"

gen wt09buns=total_gram if foodgroupdesc=="Sweet cereal products - Pastries, Buns & Pies"
label var wt09buns "Sweet cereal products - Pastries, Buns & Pies"

gen wt09vegbr=total_gram if foodgroupdesc=="Vegetables - Brassicacea"
label var wt09vegbr "Vegetables - Brassicacea"

gen wt09vegoth=total_gram if foodgroupdesc=="Vegetables - Other"
label var wt09vegoth "Vegetables - Other"

gen wt09vegtomp=total_gram if foodgroupdesc=="Vegetables - Tomatoes - Puree & sun-dried"
label var wt09vegtomp "Vegetables - Tomatoes - Puree & sun-dried"

gen wt09vegtomr=total_gram if foodgroupdesc=="Vegetables - Tomatoes - Raw & canned"
label var wt09vegtomp "Vegetables - Tomatoes - Raw & canned"

gen wt09vegcol=total_gram if foodgroupdesc=="Vegetables - Yellow & red & dark green leafy vegetables"
label var wt09vegtomp "Vegetables - Yellow & red & dark green leafy vegetables"

***Aggregrate data for mean consumption of foodgroups in grames over ndays
*sum to get total grams of foodgroup intakes per day
collapse (sum) wt09bbis-wt09vegcol, by (ntag1 day_of_week)

*Aggregate data to get average for each person over ndays
collapse (mean) wt09bbis-wt09vegcol, by (ntag1) 
sort ntag1
save "$dataout\foodgpagg_2009.dta", replace
*---------------------------------------------------------------------------------------------------------------------------------------------------------* 




