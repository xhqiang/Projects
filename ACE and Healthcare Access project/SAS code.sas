/*sheet 1*/
/*create new dataset*/
data nsch1718;
set nsch.nsch1718combined_drc;
run;

proc sort data=nsch1718;
by age3_1718;
run;

/*percentage*/
proc surveyfreq data=nsch1718;
table age3_1718;
weight fwc_1718;
run;

proc surveyfreq data=nsch1718 missing;
table sex_1718 race4_1718 PrntNativity_1718 HHLanguage_1718 famstruct5_1718 AdultEduc_1718
InsType_1718 FamResilience_1718 CSHCN_1718 Diff2more_1718 povlev4_1718;
by age3_1718;
weight fwc_1718;
run;

proc surveyfreq data=nsch1718 missing;
table sex_1718 race4_1718 PrntNativity_1718 HHLanguage_1718 famstruct5_1718 AdultEduc_1718
InsType_1718 FamResilience_1718 CSHCN_1718 Diff2more_1718 povlev4_1718;
weight fwc_1718;
run;

/*chisq --> p-value*/
%macro chisq();
ods output ChiSq=data0;
proc surveyfreq data=nsch1718;
table sex_1718*age3_1718/chisq;
weight fwc_1718;
run;

data data0;
set data0;
if _n_ ne 11 then delete;
run;
%local I;
%let I=1;
%let a=%str(sex_1718 race4_1718 PrntNativity_1718 HHLanguage_1718 famstruct5_1718 AdultEduc_1718 InsType_1718 FamResilience_1718 CSHCN_1718 Diff2more_1718 povlev4_1718);
%do %while(%scan(&a.,&I.,%str( )) ne %str()); 
	%let curname1=%scan(&a.,&I.,%str( ));
		ods output ChiSq=data1;
		proc surveyfreq data=nsch1718;
			table &curname1.*age3_1718/chisq;
			weight fwc_1718;
		run;

		data data1;
			set data1;
			if _n_ ne 11 then delete;
		run;

		data data0;
			set data0 data1;
		run;
	%let I=%eval(&I.+1);
%end;
data data0;
set data0;
if _n_=1 then delete;
keep cValue1 Table;
run;
%mend;
%chisq()



/*sheet 2*/
/*health care access*/
/*percentage*/
proc surveyfreq data=nsch1718;
table Insurance_1718 MedHome_1718;
by age3_1718;
weight fwc_1718;
run;

/*relative risk*/
data g2g1;
set nsch1718;
if age3_1718=3 then delete;
if age3_1718=2 then group=1;
if age3_1718=1 then group=2;
run;

data g3g1;
set nsch1718;
if age3_1718= 1 then group=2;
if age3_1718= 2 then delete;
if age3_1718= 3 then group=1;
run;

proc surveyfreq data=g2g1;
table group*Insurance_1718/OR;
run;

proc surveyfreq data=g3g1;
table group*Insurance_1718/OR;
run;

proc surveyfreq data=g2g1;
table group*MedHome_1718/OR;
run;

proc surveyfreq data=g3g1;
table group*MedHome_1718/OR;
run;


/*adjusted relative risk*/
proc genmod data=nsch1718;
class age3_1718(param=ref ref=FIRST) race4_1718 FamResilience_1718 AdultEduc_1718 InsType_1718 Diff2more_1718 
CSHCN_1718 famstruct5_1718 PrntNativity_1718;
model Insurance_1718=age3_1718 race4_1718 FamResilience_1718 AdultEduc_1718 InsType_1718 Diff2more_1718 
CSHCN_1718 famstruct5_1718 PrntNativity_1718/link=log dist=binomial;
run;

proc genmod data=nsch1718;
class age3_1718(param=ref ref=FIRST) race4_1718 FamResilience_1718 AdultEduc_1718 InsType_1718 Diff2more_1718 
CSHCN_1718 famstruct5_1718 PrntNativity_1718;
model MedHome_1718=age3_1718 race4_1718 FamResilience_1718 AdultEduc_1718 InsType_1718 Diff2more_1718 
CSHCN_1718 famstruct5_1718 PrntNativity_1718/link=log dist=binomial;
run;


/*ACE*/
/*ACE2more_1718 ACEct_1718*/
/*percentage*/
data ace;
set nsch1718;
if ACE2more_1718 =1 then ACE=2;
if ACE2more_1718 =3 or ACE2more_1718 =2 then ACE=1;
if ACE2more_1718 =.M then ACE=.M;
run;

proc sort data=ace;
by age3_1718;
run;

proc surveyfreq data=ace;
table ACE;
by age3_1718;
weight fwc_1718;
run;

/*relative risk*/
data g2g1;
set ace;
if age3_1718=3 then delete;
if age3_1718=2 then group=1;
if age3_1718=1 then group=2;
run;

data g3g1;
set ace;
if age3_1718= 1 then group=2;
if age3_1718= 2 then delete;
if age3_1718= 3 then group=1;
run;

proc surveyfreq data=g2g1;
table group*ACE/OR;
run;

proc surveyfreq data=g3g1;
table group*ACE/OR;
run;

/*adjusted relative risk*/
proc genmod data=ace;
class age3_1718(param=ref ref=FIRST) race4_1718 FamResilience_1718 AdultEduc_1718 InsType_1718 Diff2more_1718 
CSHCN_1718 famstruct5_1718 PrntNativity_1718;
model ACE=age3_1718 race4_1718 FamResilience_1718 AdultEduc_1718 InsType_1718 Diff2more_1718 
CSHCN_1718 famstruct5_1718 PrntNativity_1718/link=log dist=binomial;
run;



/*sheet 3*/
data sheet3;
set nsch1718;
if ACE2more_1718 =1 then ACE=0;
if ACE2more_1718 =3 or ACE2more_1718 =2 then ACE=1;
if ACE2more_1718 =.M then ACE=.M;
if Insurance_1718=1 then Insurance_1718=0;
if Insurance_1718=2 then Insurance_1718=1;
if MedHome_1718=1 then MedHome_1718=0;
if MedHome_1718=2 then MedHome_1718=1;
run;

data nsch.sheet3;
set sheet3;
run;

proc logistic data=sheet3;
model ACE= sex_1718 race4_1718 PrntNativity_1718 HHLanguage_1718 famstruct5_1718 AdultEduc_1718
InsType_1718 FamResilience_1718 CSHCN_1718 Diff2more_1718 povlev4_1718/selection=stepwise;
run;

PROC IMPORT OUT= WORK.ins 
            DATAFILE= "C:\Users\VANCOLNE\Desktop\NSCH\data\1718\sheet3modi.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

data ins1;
set ins;
sub+1;
run;

data ins2;
set ins1;
if ACE=1;
ACE=0;
run;

data ins3;
set ins1 ins2;
run;

proc genmod data=ins3;
class Insurance_1718(param=ref ref="0");
model ACE=Insurance_1718/link=log dist=binomial;
weight fwc_1718;
by age3_1718;
run;

proc sort data=ins3;
by age3_1718;
run;

proc genmod data=ins3;
class sub Insurance_1718(param=ref ref="0") PrntNativity_1718 HHLanguage_1718 famstruct5_1718 AdultEduc_1718 
povlev4_1718;
model ACE=Insurance_1718 PrntNativity_1718 HHLanguage_1718 famstruct5_1718 AdultEduc_1718 
povlev4_1718/link=log dist=binomial;
repeated subject=sub;
weight comb_ate;
by age3_1718;
run;

PROC IMPORT OUT= WORK.med 
            DATAFILE= "C:\Users\VANCOLNE\Desktop\NSCH\data\1718\sheet3modi2.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

data med1;
set med;
sub+1;
run;

data med2;
set med1;
if ACE=1;
ACE=0;
run;

data med3;
set med1 med2;
run;

proc genmod data=med3;
class MedHome_1718(param=ref ref="0");
model ACE=MedHome_1718/link=log dist=binomial;
weight fwc_1718;
by age3_1718;
run;

proc sort data=med3;
by age3_1718;
run;

proc genmod data=med3;
class sub MedHome_1718(param=ref ref="0") race4_1718 InsType_1718;
model ACE=MedHome_1718 race4_1718 InsType_1718/link=log dist=binomial;
repeated subject=sub;
weight comb_ate2;
by age3_1718;
run;


/*sheet 4*/
/*2 true 1 false*/
data sheet4;
set nsch1718;
if ACE2more_1718 =1 then ACE=0;
if ACE2more_1718 =3 or ACE2more_1718 =2 then ACE=1;
if ACE2more_1718 =.M then ACE=.M;
if ACE=0 then ACE=2;
if benefits_1718=2 then benefits_1718=3;
if benefits_1718=1 then benefits_1718=2;
if benefits_1718=3 then benefits_1718=1;
if (allows_1718=3 or allows_1718=4) then allows_1718=2;
if allows_1718=1 then allows_1718=3;
if allows_1718=2 then allows_1718=1;
if allows_1718=3 then allows_1718=2;
if (expense_1718=3 or expense_1718=4) then expense_1718=2;
if expense_1718=1 then expense_1718=3;
if expense_1718=2 then expense_1718=1;
if expense_1718=3 then expense_1718=2;
if CareCoor_1718=1 then CareCoor_1718=0;
if CareCoor_1718=2 then CareCoor_1718=1;
if CareCoor_1718=0 then CareCoor_1718=2;
if FamCent_1718=2 then FamCent_1718=0;
if FamCent_1718=1 then FamCent_1718=2;
if FamCent_1718=0 then FamCent_1718=1;
if PerDrNs_1718=2 then PerDrNs_1718=0;
if PerDrNs_1718=1 then PerDrNs_1718=2;
if PerDrNs_1718=0 then PerDrNs_1718=1;
if UsualSck_1718=2 then UsualSck_1718=0;
if UsualSck_1718=1 then UsualSck_1718=2;
if UsualSck_1718=0 then UsualSck_1718=1;
run;

/*1 true 2 false*/
data sheet4rr;
set sheet4;
if UsualSck_1718=2 then UsualSck_1718=0;
if PerDrNs_1718=2 then PerDrNs_1718=0;
if FamCent_1718=2 then FamCent_1718=0;
if CareCoor_1718=2 then CareCoor_1718=0;
if expense_1718=2 then expense_1718=0;
if UsualSck_1718=2 then UsualSck_1718=0;
if allows_1718=2 then allows_1718=0;
if benefits_1718=2 then benefits_1718=0;
run;

%macro crtdataset();
%let n=3;
%do I= 1 %to 3; 
data sheet4g&I.;
set sheet4;
if age3_1718 ne &I. then delete;
run;

data sheet4rrg&I.;
set sheet4rr;
if age3_1718 ne &I. then delete;
run;
%end;
%mend;
%crtdataset();


%macro logbinomial(y=,n=);
proc datasets nolist nowarn;
delete data0;
run;
quit;

ods output ParameterEstimates=data0;
proc genmod data=sheet4g&n. DESC;
class ACEdiscrim_1718(param=ref ref="2"); 
model CareCoor_1718 = ACEdiscrim_1718 race4_1718 PrntNativity_1718 AdultEduc_1718 famstruct5_1718 
InsType_1718 Diff2more_1718 CSHCN_1718 FamResilience_1718/link=log dist=binomial;
run;

data data0;
set data0;
if _n_ ne 2 then delete;
run;
%local I;
%let I=1;
%let a=%str(ACE ACEdivorce_1718 ACEdeath_1718 ACEjail_1718 ACEdomviol_1718 ACEneighviol_1718 ACEmhealth_1718 ACEdrug_1718 ACEdiscrim_1718);
%do %while(%scan(&a.,&I.,%str( )) ne %str()); 
	%let curname1=%scan(&a.,&I.,%str( ));
		ods output ParameterEstimates=data1;

		proc genmod data=sheet4g&n. DESC;
			class &curname1.(param=ref ref="2");
			model &y. = &curname1. race4_1718 PrntNativity_1718 AdultEduc_1718 famstruct5_1718 InsType_1718 Diff2more_1718 CSHCN_1718 FamResilience_1718/dist=binomial link=log;
		run;

		data data1;
			set data1;
			if _n_ ne 2 then delete;
		run;

		data data0;
			set data0 data1;
		run;
	%let I=%eval(&I.+1);
%end;
data log&y.;
set data0;
if _n_=1 then delete;
run;

proc datasets nowarn nolist;
delete data:;
run;
quit;
%mend;

%macro RR(y=,n=);
proc datasets nolist nowarn;
delete RR0;
run;
quit;

ods output OddsRatio=RR0;
proc surveyfreq data=sheet4rrg&n.;
table benefits_1718*ACEdiscrim_1718/OR;
run;

data RR0;
set RR0;
if _n_ ne 2 then delete;
run;
%local I;
%let I=1;
%let a=%str(ACE ACEdivorce_1718 ACEdeath_1718 ACEjail_1718 ACEdomviol_1718 ACEneighviol_1718 ACEmhealth_1718 ACEdrug_1718 ACEdiscrim_1718);
%do %while(%scan(&a.,&I.,%str( )) ne %str()); 
	%let curname=%scan(&a.,&I.,%str( ));
		ods output OddsRatio=RR1;
		proc surveyfreq data=sheet4rrg&n.;
		table &y.*&curname./OR;
		run;

		data RR1;
		set RR1;
		if _n_ ne 2 then delete;
		run;

		data RR0;
		set RR0 RR1;
		run;
	%let I=%eval(&I.+1);
%end;
data RR&y.;
set RR0;
if _n_=1 then delete;
run;

proc datasets nowarn nolist;
delete RR0 RR1;
run;
quit;
%mend;

%macro per(y=,n=);
proc datasets nolist nowarn;
delete table0;
run;
quit;

ods output CrossTabs=table0;
proc surveyfreq data=sheet4g&n. missing;
table benefits_1718*ACE;
weight fwc_1718;
run;

data table0;
set table0;
if F_benefits_1718=2 and ACE=1;
keep Table Percent;
run;
%local I;
%let I=1;
%let a=%str(ACE ACEdivorce_1718 ACEdeath_1718 ACEjail_1718 ACEdomviol_1718 ACEneighviol_1718 ACEmhealth_1718 ACEdrug_1718 ACEdiscrim_1718);
%do %while(%scan(&a.,&I.,%str( )) ne %str()); 
	%let curname=%scan(&a.,&I.,%str( ));
	ods output CrossTabs=table1;
	proc surveyfreq data=sheet4g&n. missing;
	table &y.*&curname.;
	weight fwc_1718;
	run;

	data table1;
	set table1;
	if F_&y.=2 and F_&curname.=1;
	keep Table Percent;
	run;

	data table0;
	set table0 table1;
	run;
%let I=%eval(&I.+1);
%end;

data per&y.;
set table0;
if _n_=1 then delete;
run;

proc datasets nowarn nolist;
delete table:;
run;
quit;
%mend;

%macro sheet4(m=);
%local J;
%let J=1;
%let b=%str(benefits_1718 allows_1718 expense_1718 PerDrNs_1718 UsualSck_1718 FamCent_1718 CareCoor_1718);
%do %while(%scan(&b.,&J.,%str( )) ne %str()); 
	%let name=%scan(&b.,&J.,%str( ));
	%per(y=&name.,n=&m.);
	%logbinomial(y=&name.,n=&m.);
	%RR(y=&name.,n=&m.);
	%let J=%eval(&J.+1);
%end;
%mend;
%sheet4(m=1);
%sheet4(m=2);
%sheet4(m=3);
