import sas using "C:\Users\VANCOLNE\Desktop\NSCH\data\1718\sheet3.sas7bdat",clear
global treatment Insurance_1718
global ylist ACE
global xlist race4_1718 PrntNativity_1718 HHLanguage_1718 famstruct5_1718 AdultEduc_1718 InsType_1718 FamResilience_1718 CSHCN_1718 Diff2more_1718 povlev4_1718 fwc_1718

pbalchk Insurance_1718 $xlist, strata(FIPSST)

pbalchk MedHome_1718 $xlist, strata(FIPSST)





/*
global xlist2 SC_AGE_YEARS sex_1718 race4_1718 famstruct5_1718 group FamResilience_1718 fwc_1718

dr $ylist $treatment $xlist2  HHLanguage_1718 PrntNativity_1718 povlev4_1718, genvars

gen newweight=iptwt*fwc_1718

pbalchk $treatment $xlist2 HHLanguage_1718 PrntNativity_1718 povlev4_1718, wt(newweight)

logit $ylist $treatment $xlist2 HHLanguage_1718 PrntNativity_1718 povlev4_1718 [pweight=newweight]

help svyset


svyset _n [pweight = (newweight)], strata(FIPSST)
svy:  glm $ylist $treatment $xlist2 HHLanguage_1718 PrntNativity_1718 povlev4_1718, family(binomial) link(log) eform difficult





local file = "C:\Users\VANCOLNE\Desktop\sheet3.dta"
use "C:\Users\VANCOLNE\Desktop\sheet3.dta", clear
egen statacross=group(FIPSST stratum) /* create single cluster variable for svy */
gen FPL_I0=. /* create missing variable for original fpl, m=0 */
save "C:\Users\VANCOLNE\Desktop\sheet3.dta", replace /* must be saved prior to declaring imputation */

mi import wide, imputed(FPL_I0=FPL_I1-FPL_I6) drop /* declare imputed data */
mi passive: generate povcat_i=0 /* generate new variable based on imputed fpl */
mi passive: replace povcat_i=2 if FPL_I0>=100&FPL_I0<200
mi passive: replace povcat_i=3 if FPL_I0>=200&FPL_I0<400
mi passive: replace povcat_i=4 if FPL_I0>=400
mi svyset HHID [pweight=fwc_1718], strata(statacross) /* declare survey data */
mi est: svy: proportion povcat_i, over(SC_CSHCN) /* request crosstab of povcat_i by sc_cshcn */

mi register imputed Insurance_1718
mi imput chained (logit) Insurance_1718 = SC_AGE_YEARS sex_1718 race4_1718 famstruct5_1718 FamResilience_1718 group fwc_1718, replace force

mi register imputed MedHome_1718
mi imput chained (logit) MedHome_1718 = SC_AGE_YEARS sex_1718 race4_1718 famstruct5_1718 FamResilience_1718 group fwc_1718, replace force

mi register imputed DevScrnng_1718
mi imput chained (logit) DevScrnng_1718 = SC_AGE_YEARS sex_1718 race4_1718 famstruct5_1718 FamResilience_1718 group fwc_1718, replace force

help mi imput chained

*/