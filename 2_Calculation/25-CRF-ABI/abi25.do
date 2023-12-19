*------------------------------------------------------------------------------*

*	                        WFP RAM Standardized Scripts
*                     Calculating Asset Benefit Indicator - ABI

*-----------------------------------------------------------------------------

** Load data
* ---------
	import delim using "/Users/nicolewu/Documents/GitHub/wfp-indicators/0_Static/ABI_Sample_Survey.csv", clear 	///
		   case(preserve) bindquotes(strict) varn(1)

** Label ABI relevant variables
	label var HHFFAPart			"Have you or any of your household member participated in the asset creation activities and received a food assistance transfer?"
	label var HHAssetProtect	"Do you think that the assets that were built or rehabilitated in your community are better protecting your household, its belongings and its production capacities (fields, equipment, etc.) from floods / drought / landslides / mudslides?"
	label var HHAssetProduct	"Do you think that the assets that were built or rehabilitated in your community have allowed your household to increase or diversify its production (agriculture / livestock / other)?"
	label var HHAssetDecHardship "Do you think that the assets that were built or rehabilitated in your community have decreased the day-to-day hardship and released time for any of your family members (including women and children)?"
	label var HHAssetAccess		"Do you think that the assets that were built or rehabilitated in your community have improved the ability of any of your household member to access markets and/or basic services (water, sanitation, health, education, etc)?"
	label var HHTrainingAsset	"Do you think that the trainings and other support provided in your community have improved your household's ability to manage and maintain assets?"
	label var HHAssetEnv		"Do you think that the assets that were built or rehabilitated in your community have improved your natural environment (for example more vegetal cover, water table increased, less erosion, etc.)?"
	label var HHWorkAsset		"Do you think that the works undertaken in your community have restored your ability to access and/or use basic asset functionalities?"

	label def yesnona		1 "Yes" 0 "No" 9999 "Not applicable", replace 
	label def yesno			1 "Yes" 0 "No"						, replace 
	label val HHAssetProtect HHAssetProduct HHAssetDecHardship HHAssetAccess 	///
			  HHTrainingAsset HHAssetEnv HHWorkAsset yesnona
	label val HHFFAPart	yesno
	
* recode 999 to 0 (?)	
	recode HHAssetProtect HHAssetProduct HHAssetDecHardship HHAssetAccess 		///
		   HHTrainingAsset HHAssetEnv HHWorkAsset (0 = 0) (1 = 1) (9999 = 0)

* sum ABI score
	egen ABIScore = rowtotal(HHAssetProtect HHAssetProduct HHAssetDecHardship	///
							 HHAssetAccess HHTrainingAsset HHAssetEnv 			///
							 HHWorkAsset)

* create denominator of questions asked 
	gen ABIdenom = .
	replace ABIdenom = 5 if ADMIN5Name == "Community A"
	replace ABIdenom = 6 if ADMIN5Name == "Community B"

* create % ABI for each respondent
	gen ABIperc = round((ABIScore / ABIdenom) * 100)

* create table comparing ABI % of participants and non-participants by village 
	egen HHFFAPart_lab = group(HHFFAPart)
	collapse (mean) ABIperc, by(ADMIN5Name HHFFAPart_lab) into ABIperc_particp_ADMIN5Name

* create table presenting ABI % participants vs non-participants (average across villages)
	collapse (mean) ABIperc, by(HHFFAPart_lab) into ABIperc_particp

* calculate the ABI across using weight value of 2 for non-participants
	egen ABIperc_wtd = total(cond(HHFFAPart_lab == "No", ABIperc * 2, ABIperc))
	gen ABIperc_total = ABIperc_wtd / 3

	
