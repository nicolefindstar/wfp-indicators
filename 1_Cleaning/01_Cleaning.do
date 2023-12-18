*------------------------------------------------------------------------------*

*	                        WFP RAM Standardized Scripts
*                     			General Data Cleaning  

*-----------------------------------------------------------------------------

** Demographics 
	tab HHSize
	replace HHSize = 1 if HHSize == 0 
	// Fix miscount when HHSize cannot be 0
	
** FCS
foreach v in		FCSStap /// Food Consumption Score module
					FCSPulse ///
					FCSDairy ///
					FCSPr ///
					FCSVeg ///
					FCSFruit ///
					FCSFat ///
					FCSSugar ///
					FCSCond ///
					FCSNPrMeatF /// FCS Nutrition module
					FCSNPrMeatO ///
					FCSNPrMeatFish ///
					FCSNPrEggs ///
					FCSNVegOrg ///
					FCSNVegGre ///
					FCSNFruiOrg  {
		di "`v'" 					
	cap confirm variable `v' 
		if !_rc {
				di in red "`v' exists"
				}
		else 	{
				di in yellow "`v' does not exists"
				qui gen `v'=. 
				di in green "`v' generated"
				}
}
	
	
** rCSI
