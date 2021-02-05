set memory 500000
set matsize 800


use "/Users/Noel Johnson Notebook/Desktop/TrustMAData_3-4-2011.dta", clear

log using "/Users/Noel Johnson Notebook/Desktop/TrustMA_JOEP_R&R_3-4-2011.log", replace

/* Outline

1.  Create Variables and Clean-up Data
2.  Summary Stats
3.  Predicting Trust with Experimental Variables
4.  Predicting Trustworthiness with Experimental Variables

*/

/* Fix coding mistakes in Lount and in Kesner (2 studies) */

replace n = 40 if obs== 13
replace n = 32 if obs== 15


/* Fix Coding Mistake in Study 70 (Obs 90) */

replace sendend = 50 if obs== 85

/*  Fix Coding mistake in Obs 123 */

replace proportion=.01 if obs==123

/*  Fix coding mistake in obs 96 */

replace n=76 if obs==96

replace avsent=. if obs==124

/* Adjust Migheli study that pays only 2% of subjects anything at all */

replace proportion=.02 if obs==134

/*  1.  Create Variables and Clean-up Data */

/*  CONVERT EXPERIMENTAL CURRENCY INTO NOMINAL CURRENCY  */

gen nsendend=proportion*sendend
gen nrecend=proportion*recend
gen navsent=proportion*avsent
gen navret=proportion*avret

/*  CONVERT NOMINAL CURRENCY VALUES INTO PPP VALUES  */

gen psendend=nsendend/pppconversion
gen precend=nrecend/pppconversion
gen pavsent=navsent/pppconversion
gen pavret=navret/pppconversion

/*  APPLY THE LOGIT TRANSFORMATION TO THE DEPENDENT VARIABLES  */

gen psentfraction=pavsent/psendend
gen trust=log(psentfraction/(1-psentfraction))

gen pretavail=(pavret/(rateret*pavsent))
gen trustworthy=log(pretavail/(1-pretavail))


/*  "Fix" rateret variable */

replace rateret=0 if rateret==2
replace rateret=1 if rateret>=3


/*  Generate a dummy for receiver endowment */

gen precenddummy=0 if precend==0
replace precenddummy=1 if precend>0

sum psentfraction pretavail trust trustworthy rateret precenddummy

/*  Redefine the Country Group Definitions */

replace countrygroup=2 if countrygroup==5
replace countrygroup=1 if countrygroup==7
replace countrygroup=2 if countrygroup==3
replace countrygroup=3 if countrygroup==1
replace countrygroup=1 if countrygroup==6
replace countrygroup=5 if countrygroup==8

/*

1 = N. America
2 = Europe
3 = Asia
4 = S. America
5 = Africa

*/

/*  CLEAN UP THE SAMPLE (REPEATS ETCÉ) */

/* Drop Obs 92 because theyplay different form of trust game */

drop if obs==92

/* Drop Cochard Repeat */

drop if obs == 18

/* Drop Hauser Schunk Winter Repeat */

drop if obs==68

/*  Drop the Keser repeat */

drop if obs==74

/* Drop the Venezuela (Cardenas) Study with the Endowment too high */

drop if obs==101

/*  Drop Migheli repeat */

drop if obs==136

replace countrycode=924 if obs==153
replace country="China" if obs==70
replace n=208 if obs==107
replace n=328 if obs==59
replace n=135 if obs==38
replace n=320 if obs==59
replace n=350 if obs==33
replace n=154 if obs==64
replace n=141 if obs==10

/* Generate Common Sample Dummies */

gen trustsample=0
replace trustsample=1 if trust~=. & psendend~=. & precenddummy~=. & anon~=. & rateret~=. & dbleblind~=. & student~=. & bothroles~=. & randompayment~=. & stratmeth~=. & realperson~=.

gen trustworthysample=0
replace trustworthysample=1 if trustworthy~=. & trust~=. & psendend~=. & precenddummy~=. & anon~=. & rateret~=. & dbleblind~=. & student~=. & bothroles~=. & randompayment~=. & stratmeth~=.



/* 2.  Summary Statistics  */

drop if trustsample==0

/*  Study Descriptions */

sort countrygroup studyyear

by countrygroup: egen sumn=sum(n)

sort countrygroup

by countrygroup:  egen countcountrygroup=count(countrygroup),

sort countrygroup

collapse countcountry sumn psentfraction pretavail trust trustworthy [aw=n], by(countrygroup)

sort countrygroup

list countrygroup countcountry sumn psentfraction pretavail trust trustworthy, clean compress


use "/Users/Noel Johnson Notebook/Desktop/TrustMAData_3-4-2011.dta", clear


/* Fix coding mistakes in Lount and in Kesner (2 studies) */

replace n = 40 if obs== 13
replace n = 32 if obs== 15


/* Fix Coding Mistake in Study 70 (Obs 90) */

replace sendend = 50 if obs== 85

/*  Fix Coding mistake in Obs 123 */

replace proportion=.01 if obs==123

/*  Fix coding mistake in obs 96 */

replace n=76 if obs==96

replace avsent=. if obs==124

/* Adjust Migheli study that pays only 2% of subjects anything at all */

replace proportion=.02 if obs==134


/*  1.  Create Variables and Clean-up Data */

/*  CONVERT EXPERIMENTAL CURRENCY INTO NOMINAL CURRENCY  */

gen nsendend=proportion*sendend
gen nrecend=proportion*recend
gen navsent=proportion*avsent
gen navret=proportion*avret

/*  CONVERT NOMINAL CURRENCY VALUES INTO PPP VALUES  */

gen psendend=nsendend/pppconversion
gen precend=nrecend/pppconversion
gen pavsent=navsent/pppconversion
gen pavret=navret/pppconversion

/*  APPLY THE LOGIT TRANSFORMATION TO THE DEPENDENT VARIABLES  */

gen psentfraction=pavsent/psendend
gen trust=log(psentfraction/(1-psentfraction))

gen pretavail=(pavret/(rateret*pavsent))
gen trustworthy=log(pretavail/(1-pretavail))

/*  "Fix" rateret variable */

replace rateret=0 if rateret==2
replace rateret=1 if rateret>=3


/*  Generate a dummy for receiver endowment */

gen precenddummy=0 if precend==0
replace precenddummy=1 if precend>0

/*  Redefine the Country Group Definitions */

replace countrygroup=2 if countrygroup==5
replace countrygroup=1 if countrygroup==7
replace countrygroup=2 if countrygroup==3
replace countrygroup=3 if countrygroup==1
replace countrygroup=1 if countrygroup==6
replace countrygroup=5 if countrygroup==8

/*

1 = N. America
2 = Europe
3 = Asia
4 = S. America
5 = Africa

*/

/*  CLEAN UP THE SAMPLE (REPEATS ETCÉ) */

/* Drop Obs 92 because theyplay different form of trust game */

drop if obs==92

/* Drop Cochard Repeat */

drop if obs == 18

/* Drop Hauser Schunk Winter Repeat */

drop if obs==68

/*  Drop the Keser repeat */

drop if obs==74

/* Drop the Venezuela (Cardenas) Study with the Endowment too high */

drop if obs==101

/*  Drop Migheli repeat */

drop if obs==136

replace countrycode=924 if obs==153
replace country="China" if obs==70
replace n=208 if obs==107
replace n=328 if obs==59
replace n=135 if obs==38
replace n=320 if obs==59
replace n=350 if obs==33
replace n=154 if obs==64
replace n=141 if obs==10
replace n=94 if obs==35

/* Generate Common Sample Dummies */

gen trustsample=0
replace trustsample=1 if trust~=. & psendend~=. & precenddummy~=. & anon~=. & rateret~=. & dbleblind~=. & student~=. & bothroles~=. & randompayment~=. & stratmeth~=. & realperson~=.

gen trustworthysample=0
replace trustworthysample=1 if trustworthy~=. & trust~=. & psendend~=. & precenddummy~=. & anon~=. & rateret~=. & dbleblind~=. & student~=. & bothroles~=. & randompayment~=. & stratmeth~=.



/* Summary Stats and Correlations for Experimental Variables */

sum psentfraction trust psendend precend precenddummy anon rateret dbleblind student stratmeth bothroles randompayment realperson if trustsample==1 [aw=n], separator(0)

sum psentfraction pretavail trust trustworthy psendend precend precenddummy anon rateret dbleblind student stratmeth bothroles randompayment if trustworthysample==1 [aw=n], separator(0)


/* 3.  Predicting Trusting Behavior with Methodological Variables  */

/* Using a dummy for receiver endowment */ 

regress trust psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson [aw=n] if trustsample==1, robust
estimates store aone

xi: regress trust psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson i.countrygroup [aw=n] if trustsample==1, robust
estimates store bone

xi: rreg trust psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson i.countrygroup if trustsample==1,
estimates store cone

/* 4.  Predicting Trustworthy Behavior with Experimental Variables   */

/* Using a dummy for receiver endowment */ 

regress trustworthy trust psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth [aw=n] if trustworthysample==1, robust
estimates store done

xi: regress trustworthy trust psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth i.countrygroup [aw=n] if trustworthysample==1, robust
estimates store eone

xi: rreg trustworthy trust psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth i.countrygroup if trustworthysample==1,
estimates store fone

outreg2 psendend precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson trust _Icountrygr_2 _Icountrygr_3 _Icountrygr_4 _Icountrygr_5  [aone bone cone done eone fone] using TableA, replace bdec(4) nocons


/*  Run Regressions To Identify Effect of Stakes on trust and trustworthy */

gen psendendsq=psendend^2

xi: regress trust psendend psendendsq precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson [aw=n] if trustsample==1, robust
estimates store atwo

xi: regress trust psendend psendendsq precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson i.countrygroup [aw=n] if trustsample==1, robust
estimates store btwo

xi: rreg trust psendend psendendsq precenddummy anon rateret dbleblind student bothroles randompayment stratmeth realperson i.countrygroup if trustsample==1,
estimates store ctwo

xi: regress trustworthy trust psendend psendendsq precenddummy anon rateret dbleblind student bothroles randompayment stratmeth [aw=n] if trustworthysample==1, robust
estimates store dtwo

xi: regress trustworthy trust psendend psendendsq precenddummy anon rateret dbleblind student bothroles randompayment stratmeth i.countrygroup [aw=n] if trustworthysample==1, robust
estimates store etwo

xi: rreg trustworthy trust psendend psendendsq precenddummy anon rateret dbleblind student bothroles randompayment stratmeth i.countrygroup if trustworthysample==1,
estimates store ftwo

outreg2 psendend psendendsq [atwo btwo ctwo dtwo etwo ftwo] using TableB, replace bdec(4,5) nocons


/*NOTE:  realperson is dropped in reciprocity regressions because not enough observations */

/*  Generate the Properly Weighted Standard Deviations for Table 2 */


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


/* 2.  Summary Statistics on Trust and Trustworthy by Country for Appendix  */



replace country="Colombia" if country=="Columbia"

/*  Study Descriptions */

sort country studyyear

by country: egen sumn=sum(n)

sort countrycode

by countrycode:  egen countcountry=count(countrycode),

sort countrygroup

collapse countcountry sumn psentfraction pretavail trust trustworthy [aw=n], by(country)

sort country

list country countcountry sumn psentfraction pretavail trust trustworthy, clean compress



use "/Users/Noel Johnson Notebook/Desktop/TrustMAData_3-4-2011.dta", clear


/* Fix coding mistakes in Lount and in Kesner (2 studies) */

replace n = 40 if obs== 13
replace n = 32 if obs== 15


/* Fix Coding Mistake in Study 70 (Obs 90) */

replace sendend = 50 if obs== 85

/*  Fix Coding mistake in Obs 123 */

replace proportion=.01 if obs==123

/*  Fix coding mistake in obs 96 */

replace n=76 if obs==96

replace avsent=. if obs==124

/* Adjust Migheli study that pays only 2% of subjects anything at all */

replace proportion=.02 if obs==134


/*  1.  Create Variables and Clean-up Data */

/*  CONVERT EXPERIMENTAL CURRENCY INTO NOMINAL CURRENCY  */

gen nsendend=proportion*sendend
gen nrecend=proportion*recend
gen navsent=proportion*avsent
gen navret=proportion*avret

/*  CONVERT NOMINAL CURRENCY VALUES INTO PPP VALUES  */

gen psendend=nsendend/pppconversion
gen precend=nrecend/pppconversion
gen pavsent=navsent/pppconversion
gen pavret=navret/pppconversion

/*  APPLY THE LOGIT TRANSFORMATION TO THE DEPENDENT VARIABLES  */

gen psentfraction=pavsent/psendend
gen trust=log(psentfraction/(1-psentfraction))

gen pretavail=(pavret/(rateret*pavsent))
gen trustworthy=log(pretavail/(1-pretavail))

/*  "Fix" rateret variable */

replace rateret=0 if rateret==2
replace rateret=1 if rateret>=3


/*  Generate a dummy for receiver endowment */

gen precenddummy=0 if precend==0
replace precenddummy=1 if precend>0

/*  Redefine the Country Group Definitions */

replace countrygroup=2 if countrygroup==5
replace countrygroup=1 if countrygroup==7
replace countrygroup=2 if countrygroup==3
replace countrygroup=3 if countrygroup==1
replace countrygroup=1 if countrygroup==6
replace countrygroup=5 if countrygroup==8

/*

1 = N. America
2 = Europe
3 = Asia
4 = S. America
5 = Africa

*/

/*  CLEAN UP THE SAMPLE (REPEATS ETCÉ) */

replace country="Colombia" if country=="Columbia"

/* Drop Obs 92 because theyplay different form of trust game */

drop if obs==92

/* Drop Cochard Repeat */

drop if obs == 18

/* Drop Hauser Schunk Winter Repeat */

drop if obs==68

/*  Drop the Keser repeat */

drop if obs==74

/* Drop the Venezuela (Cardenas) Study with the Endowment too high */

drop if obs==101

/*  Drop Migheli repeat */

drop if obs==136

replace countrycode=924 if obs==153
replace country="China" if obs==70
replace n=208 if obs==107
replace n=328 if obs==59
replace n=135 if obs==38
replace n=320 if obs==59
replace n=350 if obs==33
replace n=154 if obs==64
replace n=141 if obs==10
replace n=94 if obs==35


/* Generate Common Sample Dummies */

gen trustsample=0
replace trustsample=1 if trust~=. & psendend~=. & precenddummy~=. & anon~=. & rateret~=. & dbleblind~=. & student~=. & bothroles~=. & randompayment~=. & stratmeth~=. & realperson~=.

gen trustworthysample=0
replace trustworthysample=1 if trustworthy~=. & trust~=. & psendend~=. & precenddummy~=. & anon~=. & rateret~=. & dbleblind~=. & student~=. & bothroles~=. & randompayment~=. & stratmeth~=.

/*  Generate the Properly Weighted Standard Deviations for Table 2 (using Proportion Sent and Proportion Returned) */


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
