/* *************************************************************************** *
*				Calculating Food Consumption Groups and Food Sources  		   * 
*																 			   *					
	
	** REQUIRES:	
					
	** NOTES:		Assumption & Data Flow & Variable Type

********************************************************************************
*							PART 0: Correct Variable Type
*******************************************************************************/
	
	
	
********************************************************************************
*					PART 1: Label Relevant Variables and Values
*******************************************************************************/

	label var FCSStap		"Consumption over the past 7 days: cereals, grains and tubers"
	label var FCSPulse		"Consumption over the past 7 days: pulses"
	label var FCSDairy		"Consumption over the past 7 days: dairy products"
	label var FCSPr			"Consumption over the past 7 days: protein-rich foods"
	label var FCSVeg		"Consumption over the past 7 days: vegetables"
	label var FCSFruit		"Consumption over the past 7 days: fruit"
	label var FCSFat		"Consumption over the past 7 days: oil"
	label var FCSSugar		"Consumption over the past 7 days: sugar"
	label var FCSCond		"Consumption over the past 7 days: condiments"
	
	label var FCSStap_SRf	"Main source of food group: cereals, grains and tubers"
	label var FCSPulse_SRf	"Main source of food group: pulses"
	label var FCSDairy_SRf	"Main source of food group: dairy products"
	label var FCSPr_SRf		"Main source of food group: protein-rich foods"
	label var FCSVeg_SRf	"Main source of food group: vegetables"
	label var FCSFruit_SRf	"Main source of food group: fruit"
	label var FCSFat_SRf	"Main source of food group: oil"
	label var FCSSugar_SRf	"Main source of food group: sugar"
	label var FCSCond_SRf	"Main source of food group: condiments"

	label def FCS_SRf_l		100 	"Own production"				///
							200 	"Fishing/ hunting"				///
							300 	"Gathering"						///
							400 	"Loaned/borrowed"				///
							500 	"Purchased"						///
							600 	"Credit"						///
							700 	"Begging"						///
							800 	"Exchange for labour or items"	///
							900 	"Gifts from family/friends"		///
							999 	"Other"							///
							1000 	"Food aid"
							
	label val FCSStap_SRf FCSPulse_SRf FCSDairy_SRf FCSPr_SRf FCSVeg_SRf 	///
			  FCSFruit_SRf FCSFat_SRf FCSSugar_SRf FCSCond_SRf FCS_SRf_l

***Staples***  
local SRf_var Stap Pulse Dairy Pr Veg Fruit Fat Sugar Cond

foreach var of local SRf_var {
	gen Ownprodfish_`var' = FCS`var' if FCS`var'_SRf == 100 | FCS`var'_SRf == 200
	gen GathGift_`var'    = FCS`var' if FCS`var'_SRf == 300 | FCS`var'_SRf == 900 | FCS`var'_SRf == 1000
	gen Credit_`var'	  = FCS`var' if FCS`var'_SRf == 400 | FCS`var'_SRf == 600
	gen Cash_`var'		  = FCS`var' if FCS`var'_SRf == 500
	gen Beg_`var'		  = FCS`var' if FCS`var'_SRf == 700
	gen Exchange_`var'	  = FCS`var' if FCS`var'_SRf == 800
	gen Other_`var'	  	  = FCS`var' if FCS`var'_SRf == 999
}

***Step 2 - Calculate unique variable for each source 

COMPUTE Ownprodfish = sum (Ownprodfish_cereal, Ownprodfish_pulses, Ownprodfish_prot, Ownprodfish_dairy, Ownprodfish_veg, Ownprodfish_fruit, Ownprodfish_fat, Ownprodfish_sugar, Ownprodfish_condiment). 
COMPUTE Gath_Gift= sum (GathGift_cereal, GathGift_pulses, GathGift_prot, GathGift_dairy, GathGift_veg, GathGift_fruit, GathGift_fat, GathGift_sugar, GathGift_condiment). 
COMPUTE Credit = sum (Credit_cereal, Credit_pulses, Credit_prot, Credit_dairy, Credit_veg, Credit_fruit, Credit_fat, Credit_sugar, Credit_condiment). 
COMPUTE Cash =  sum (Cash_cereal, Cash_pulses, Cash_prot, Cash_dairy, Cash_veg, Cash_fruit, Cash_fat, Cash_sugar, Cash_condiment). 
COMPUTE Beg =  sum (Beg_cereal, Beg_pulses, Beg_prot, Beg_dairy, Beg_veg, Beg_fruit, Beg_fat, Beg_sugar, Beg_condiment). 
COMPUTE Exchange = sum (Exchange_cereal, Exchange_pulses, Exchange_prot, Exchange_dairy, Exchange_veg, Exchange_fruit, Exchange_fat, Exchange_sugar, Exchange_condiment). 
COMPUTE Other = sum (Other_cereal, Other_pulses, Other_prot, Other_dairy, Other_veg, Other_fruit, Other_fat, Other_sugar, Other_condiment). 

***Step 3 - Compute the total sources of food 

COMPUTE totsource = sum (Ownprodfish, Gath_Gift, Credit, Cash, Beg, Exchange, Other). 
EXECUTE. 

***Step 4 - Calculate % of each food source 

COMPUTE pownprod = (Ownprodfish/ totsource)*100. 
COMPUTE pgathering_gift = (Gath_Gift/ totsource)*100. 
COMPUTE pcredit = (Credit/ totsource)*100. 
COMPUTE pcash = (Cash / totsource)*100. 
COMPUTE pbeg = (Beg / totsource)*100. 
COMPUTE pexchange = (Exchange / totsource)*100. 
COMPUTE pother = (Other / totsource)*100. 
EXECUTE. 

* Define Variable Properties. 
* Own production and fishing 

VARIABLE LEVEL pownprod(SCALE). 
VARIABLE LABELS pownprod '% of food from own production and fishing (food source)'. 
FORMATS pownprod(F8.0). 

*Gathering and gifts 

VARIABLE LEVEL pgathering_gift (SCALE). 
VARIABLE LABELS pgathering_gift '% of food from gathering, gifts and assistance (food source)'. 
FORMATS pgathering_gift (F8.0). 

*Credit purchases 

VARIABLE LEVEL pcredit (SCALE). 
VARIABLE LABELS pcredit '% of food from market credit purchases (food source)'. 
FORMATS pcredit (F8.0). 

*Cash purchases 

VARIABLE LEVEL pcash (SCALE). 
VARIABLE LABELS pcash '% of food from market cash purchases (food source)'. 
FORMATS pcash (F8.0). 

 *Begging 

VARIABLE LEVEL pbeg (SCALE). 
VARIABLE LABELS pbeg '% of food from begging (food source)'. 
FORMATS pbeg(F8.0). 

*Exchange for food 

VARIABLE LEVEL pexchange (SCALE). 
VARIABLE LABELS pexchange '% of food from exchanges (food source)'. 
FORMATS pexchange (F8.0). 

*Other

VARIABLE LEVEL pother (SCALE). 
VARIABLE LABELS pother '% of food from other (food source)'. 
FORMATS pother (F8.0). 
