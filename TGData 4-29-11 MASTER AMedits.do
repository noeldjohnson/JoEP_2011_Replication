set memory 500000
set matsize 800


use "/Users/noeljohnson_laptop/Desktop/TGData 4-29-11 MASTER AMedits copy.dta", clear

log using "/Users/Noel Johnson Notebook/Desktop/TGData 5-4-11 MASTER AMedits.log", replace

* Outline

1.  Create Variables and Clean-up Data
2.  Summary Stats
3.  Predicting Trust with Experimental Variables
4.  Predicting Trustworthiness with Experimental Variables

*/

* Fix the Country Codes */

replace countrycode=924 if obs==153
replace country="China" if obs==70

*  1.  Create Variables and Clean-up Data */


*  CONVERT EXPERIMENTAL CURRENCY INTO NOMINAL CURRENCY  */

gen nsendend=proportion*sendend
gen nrecend=proportion*recend
gen navsent=proportion*avsent
gen navret=proportion*avret

*  CONVERT NOMINAL CURRENCY VALUES INTO PPP VALUES  */

gen psendend=nsendend/pppconversion
gen precend=nrecend/pppconversion
gen pavsent=navsent/pppconversion
gen pavret=navret/pppconversion

*  APPLY THE LOGIT TRANSFORMATION TO THE DEPENDENT VARIABLES  */

gen psentfraction=pavsent/psendend
gen trust=log(psentfraction/(1-psentfraction))

gen pretavail=(pavret/(rateret*pavsent))
gen trustworthy=log(pretavail/(1-pretavail))


*  "Fix" rateret variable */

replace rateret=0 if rateret==2
replace rateret=1 if rateret>=3


*  Generate a dummy for receiver endowment */

gen precenddummy=0 if precend==0
replace precenddummy=1 if precend>0

* Drop the Simpson and Ericsson Trust Observation that is Exogenous */

replace psentfraction=. if obs==124
replace trust=. if obs==124

sum psentfraction pretavail trust trustworthy rateret precenddummy

*  Redefine the Country Group Definitions */

replace countrygroup=2 if countrygroup==5
replace countrygroup=1 if countrygroup==7
replace countrygroup=2 if countrygroup==3
replace countrygroup=3 if countrygroup==1
replace countrygroup=1 if countrygroup==6
replace countrygroup=5 if countrygroup==8

*

1 = N. America
2 = Europe
3 = Asia
4 = S. America
5 = Africa

*/




* Generate Common Sample Dummies */

gen trustsample=0
replace trustsample=1 if trust~=. & psendend~=. & precenddummy~=. & anon~=. & rateret~=. & dbleblind~=. & student~=. & bothroles~=. & randompayment~=. & stratmeth~=. & realperson~=.

gen trustworthysample=0
replace trustworthysample=1 if trustworthy~=. & trust~=. & psendend~=. & precenddummy~=. & anon~=. & rateret~=. & dbleblind~=. & student~=. & bothroles~=. & randompayment~=. & stratmeth~=.



* 2.  Summary Statistics  */

drop if trustsample==0

*  Study Descriptions */

sort countrygroup studyyear

by countrygroup: egen sumn=sum(n)

sort countrygroup

by countrygroup:  egen countcountrygroup=count(countrygroup),

sort countrygroup

collapse countcountry sumn psentfraction pretavail trust trustworthy [aw=n], by(countrygroup)

sort countrygroup

list countrygroup countcountry sumn psentfraction pretavail trust trustworthy, clean compress


use "/Users/noeljohnson_laptop/Desktop/TGData 4-29-11 MASTER AMedits copy.dta", clear

*  Messing with the endowments */

replace proportion=1 if studynr==136

replace randompayment=1 if studynr==136


* Fix the Country Codes */

replace countrycode=924 if obs==153
replace country="China" if obs==70

*  CONVERT EXPERIMENTAL CURRENCY INTO NOMINAL CURRENCY  */

gen nsendend=proportion*sendend
gen nrecend=proportion*recend
gen navsent=proportion*avsent
gen navret=proportion*avret

*  CONVERT NOMINAL CURRENCY VALUES INTO PPP VALUES  */

gen psendend=nsendend/pppconversion
gen precend=nrecend/pppconversion
gen pavsent=navsent/pppconversion
gen pavret=navret/pppconversion

*  APPLY THE LOGIT TRANSFORMATION TO THE DEPENDENT VARIABLES  */

gen psentfraction=pavsent/psendend
gen trust=log(psentfraction/(1-psentfraction))

gen pretavail=(pavret/(rateret*pavsent))
gen trustworthy=log(pretavail/(1-pretavail))

*  "Fix" rateret variable */

replace rateret=0 if rateret==2
replace rateret=1 if rateret>=3


*  Generate a dummy for receiver endowment */

gen precenddummy=0 if precend==0
replace precenddummy=1 if precend>0


*  Redefine the Country Group Definitions */

replace countrygroup=2 if countrygroup==5
replace countrygroup=1 if countrygroup==7
replace countrygroup=2 if countrygroup==3
replace countrygroup=3 if countrygroup==1
replace countrygroup=1 if countrygroup==6
replace countrygroup=5 if countrygroup==8

*

1 = N. America
2 = Europe
3 = Asia
4 = S. America
5 = Africa

*/


* Generate Common Sample Dummies */

gen trustsample=0
replace trustsample=1 if trust~=. & psendend~=. & precenddummy~=. & anon~=. & rateret~=. & dbleblind~=. & student~=. & bothroles~=. & randompayment~=. & stratmeth~=. & realperson~=.

gen trustworthysample=0
replace trustworthysample=1 if trustworthy~=. & trust~=. & psendend~=. & precenddummy~=. & anon~=. & rateret~=. & dbleblind~=. & student~=. & bothroles~=. & randompayment~=. & stratmeth~=.



* Summary Stats and Correlations for Experimental Variables */

sum psentfraction trust psendend precend precenddummy anon rateret dbleblind student stratmeth bothroles randompayment realperson if trustsample==1 [aw=n], separator(0)

sum psentfraction pretavail trust trustworthy psendend precend precenddummy anon rateret dbleblind student stratmeth bothroles randompayment if trustworthysample==1 [aw=n], separator(0)


* 3.  Predicting Trusting Behavior with Methodological Variables  */

* Using a dummy for receiver endowment */ 

regress trust  psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson [aw=n] if trustsample==1, robust
estimates store aone

xi: regress trust  psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson i.countrygroup [aw=n] if trustsample==1, robust
estimates store bone

xi: rreg trust  psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson i.countrygroup if trustsample==1,tune(8)
estimates store cone

* 4.  Predicting Trustworthy Behavior with Experimental Variables   */

* Using a dummy for receiver endowment */ 

regress trustworthy  trust psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth [aw=n] if trustworthysample==1, robust
estimates store done

xi: regress trustworthy  trust psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth i.countrygroup [aw=n] if trustworthysample==1, robust
estimates store eone

xi: rreg trustworthy  trust psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth i.countrygroup if trustworthysample==1,tune(8)
estimates store fone

outreg2 psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson trust _Icountrygr_2 _Icountrygr_3 _Icountrygr_4 _Icountrygr_5  [aone bone cone done eone fone] using TableA, replace bdec(4) nocons


gen interact=psendend*randompayment

* Using a dummy for receiver endowment */ 

regress trust interact psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson [aw=n] if trustsample==1, robust

xi: regress trust interact psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson i.countrygroup [aw=n] if trustsample==1, robust

xi: rreg trust interact psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson i.countrygroup if trustsample==1, tune(8)

* 4.  Predicting Trustworthy Behavior with Experimental Variables   */

* Using a dummy for receiver endowment */ 

regress trustworthy interact trust psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth [aw=n] if trustworthysample==1, robust

xi: regress trustworthy interact trust psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth i.countrygroup [aw=n] if trustworthysample==1, robust

xi: rreg trustworthy interact trust psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth i.countrygroup if trustworthysample==1, tune(8)


*  Run Regressions To Identify Effect of Stakes on trust and trustworthy */

gen psendendsq=psendend^2

xi: regress trust psendend psendendsq precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson [aw=n] if trustsample==1, robust
estimates store atwo

xi: regress trust psendend psendendsq precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson i.countrygroup [aw=n] if trustsample==1, robust
estimates store btwo

xi: rreg trust psendend psendendsq precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson i.countrygroup if trustsample==1, tune(8)
estimates store ctwo

xi: regress trustworthy trust psendend psendendsq precenddummy anon rateret dbleblind student bothroles randompayment stratmeth [aw=n] if trustworthysample==1, robust
estimates store dtwo

xi: regress trustworthy trust psendend psendendsq precenddummy anon rateret dbleblind student bothroles randompayment stratmeth i.countrygroup [aw=n] if trustworthysample==1, robust
estimates store etwo

xi: rreg trustworthy trust psendend psendendsq precenddummy anon rateret dbleblind student bothroles randompayment stratmeth i.countrygroup if trustworthysample==1, tune(8)
estimates store ftwo

outreg2 psendend psendendsq [atwo btwo ctwo dtwo etwo ftwo] using TableB, replace bdec(4,5) nocons


*NOTE:  realperson is dropped in reciprocity regressions because not enough observations */

*  Generate the Properly Weighted Standard Deviations for Table 2 */


sum trust [aw=n] if trustsample==1

sum trust if countrygroup==1 & trustsample==1 [aw=n]
sum trust if countrygroup==2 & trustsample==1 [aw=n]
sum trust if countrygroup==3 & trustsample==1 [aw=n]
sum trust if countrygroup==4 & trustsample==1 [aw=n]
sum trust if countrygroup==5 & trustsample==1 [aw=n]


sum trustworthy [aw=n] if trustworthysample==1

sum trustworthy if countrygroup==1 & trustworthysample==1 [aw=n] 
sum trustworthy if countrygroup==2 & trustworthysample==1 [aw=n]
sum trustworthy if countrygroup==3 & trustworthysample==1 [aw=n]
sum trustworthy if countrygroup==4 & trustworthysample==1 [aw=n]
sum trustworthy if countrygroup==5 & trustworthysample==1 [aw=n]


* 2.  Summary Statistics on Trust and Trustworthy by Country for Appendix  */



replace country="Colombia" if country=="Columbia"

*  Study Descriptions */

sort country studyyear

by country: egen sumn=sum(n)

sort countrycode

by countrycode:  egen countcountry=count(countrycode),

sort countrygroup

collapse countcountry sumn psentfraction pretavail trust trustworthy [aw=n], by(country)

sort country

list country countcountry sumn psentfraction pretavail trust trustworthy, clean compress



use "/Users/Noel Johnson Notebook/Desktop/TGData 5-4-11 MASTER AMedits.dta", clear


* Fix the Country Codes */

replace countrycode=924 if obs==153
replace country="China" if obs==70

*  CONVERT EXPERIMENTAL CURRENCY INTO NOMINAL CURRENCY  */

gen nsendend=proportion*sendend
gen nrecend=proportion*recend
gen navsent=proportion*avsent
gen navret=proportion*avret

*  CONVERT NOMINAL CURRENCY VALUES INTO PPP VALUES  */

gen psendend=nsendend/pppconversion
gen precend=nrecend/pppconversion
gen pavsent=navsent/pppconversion
gen pavret=navret/pppconversion

*  APPLY THE LOGIT TRANSFORMATION TO THE DEPENDENT VARIABLES  */

gen psentfraction=pavsent/psendend
gen trust=log(psentfraction/(1-psentfraction))

gen pretavail=(pavret/(rateret*pavsent))
gen trustworthy=log(pretavail/(1-pretavail))

*  "Fix" rateret variable */

replace rateret=0 if rateret==2
replace rateret=1 if rateret>=3


*  Generate a dummy for receiver endowment */

gen precenddummy=0 if precend==0
replace precenddummy=1 if precend>0

* Drop the Simpson and Ericsson Trust Observation that is Exogenous */

replace psentfraction=. if obs==124
replace trust=. if obs==124


*  Redefine the Country Group Definitions */

replace countrygroup=2 if countrygroup==5
replace countrygroup=1 if countrygroup==7
replace countrygroup=2 if countrygroup==3
replace countrygroup=3 if countrygroup==1
replace countrygroup=1 if countrygroup==6
replace countrygroup=5 if countrygroup==8

*

1 = N. America
2 = Europe
3 = Asia
4 = S. America
5 = Africa

*/



* Generate Common Sample Dummies */

gen trustsample=0
replace trustsample=1 if trust~=. & psendend~=. & precenddummy~=. & anon~=. & rateret~=. & dbleblind~=. & student~=. & bothroles~=. & randompayment~=. & stratmeth~=. & realperson~=.

gen trustworthysample=0
replace trustworthysample=1 if trustworthy~=. & trust~=. & psendend~=. & precenddummy~=. & anon~=. & rateret~=. & dbleblind~=. & student~=. & bothroles~=. & randompayment~=. & stratmeth~=.

*  Generate the Properly Weighted Standard Deviations for Table 2 (using Proportion Sent and Proportion Returned) */


sum psentfraction [aw=n] if trustsample==1

sum psentfraction if countrygroup==1 & trustsample==1 [aw=n]
sum psentfraction if countrygroup==2 & trustsample==1 [aw=n]
sum psentfraction if countrygroup==3 & trustsample==1 [aw=n]
sum psentfraction if countrygroup==4 & trustsample==1 [aw=n]
sum psentfraction if countrygroup==5 & trustsample==1 [aw=n]


sum pretavail [aw=n] if trustworthysample==1

sum pretavail if countrygroup==1 & trustworthysample==1 [aw=n] 
sum pretavail if countrygroup==2 & trustworthysample==1 [aw=n]
sum pretavail if countrygroup==3 & trustworthysample==1 [aw=n]
sum pretavail if countrygroup==4 & trustworthysample==1 [aw=n]
sum pretavail if countrygroup==5 & trustworthysample==1 [aw=n]


log close
