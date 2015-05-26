/* similar to check_dauphin_fes_counts.sps */
/* in making record sets */
/* now making a form timeline for all counties together */
/* will keep all fields and not just the timeline fields */


/* Baseline file */
GET DATA 
  /TYPE=XLS 
  /FILE='C:\Users\doy13\Downloads\fes_data_20140828.xls' 
  /SHEET=name 'Baseline' 
  /CELLRANGE=full 
  /READNAMES=on 
  /ASSUMEDSTRWIDTH=32767. 
EXECUTE. 
DATASET NAME DataSet1 WINDOW=FRONT. 


/* CREATE Date variable */

string m1 (a2).
string d1 (a2).
string y1 (a4).
exe.

/* what is length of string variable? */
/* mm-dd-yyyy means 10 */
/* mm-d-yyyy means 9 */
/* m-dd-yyyy means 9 */
/* m-d-yyyy means 8 */
/* some have time " 0:00" */
/* 13 means 8 */
/* 14 means 9 */
/* 15 means 10 */
/* 23 means yyyy-mm-dd 00:00:00.000 */
compute lendate=len(ltrim(rtrim(Family_Conference_Date))).
freq vars=lendate.

if (lendate=13) lendate=8.
if (lendate=14) lendate=9.
if (lendate=15) lendate=10.

/* Venango dates have a leading blank */
compute Family_Conference_Date=ltrim(rtrim(Family_Conference_Date)).

if (substring(Family_Conference_Date,3,1)="/") slashat3=1.
if (substring(Family_Conference_Date,3,1)~="/") slashat3=0.

freq vars=slashat3.

DEFINE fillindates (thelendate=!TOKENS(1) 
 / yesslash=!TOKENS(1) 
 / mplace=!TOKENS(1) 
 / mlength=!TOKENS(1) 
 / dplace=!TOKENS(1) 
 / dlength=!TOKENS(1)
 / yplace=!TOKENS(1))

if (lendate=!thelendate & slashat3=!yesslash) m1=substring(Family_Conference_Date, !mplace, !mlength).
if (lendate=!thelendate & slashat3=!yesslash) d1=substring(Family_Conference_Date, !dplace, !dlength).
if (lendate=!thelendate & slashat3=!yesslash) y1=substring(Family_Conference_Date, !yplace, 4).
!enddefine.


fillindates thelendate=10 yesslash=1 mplace=1 mlength=2 dplace=4 dlength=2 yplace=7.
fillindates thelendate=9 yesslash=1 mplace=1 mlength=2 dplace=4 dlength=1 yplace=6.
fillindates thelendate=9 yesslash=0 mplace=1 mlength=1 dplace=3 dlength=2 yplace=6.
fillindates thelendate=8 yesslash=0 mplace=1 mlength=1 dplace=3 dlength=1 yplace=5.
fillindates thelendate=23 yesslash=0 mplace=6 mlength=2 dplace=9 dlength=2 yplace=1.

freq vars=m1.
freq vars=d1.
freq vars=y1.


/* is month two digits? */
* compute m1 = substr(Family_Conference_Date, 1, 2).
* if (index(m1, "/")>0) onedigmo=1.
* if (index(m1, "/")=0) onedigmo=0.
* if (index(m1, "/")>0) m1=substr(Family_Conference_Date, 1, 1).

/* taking into account number of digits in month */
* if (onedigmo=0) compute d1 = substr(Family_Conference_Date, 4, 2).
/* that one has a slash in it? */
* if (onedigmo=0 & index(d1, "/")>0) onedigdy=1.
* if (onedigmo=0 & index(d1, "/")=0) onedigdy=0.
* if (onedigmo=0 & index(d1, "/")>0) compute d1 = substr(Family_Conference_Date, 4, 1).



* compute y1 = substr(Family_Conference_Date, 7, 4).

compute mn = numeric(m1, f4.0).
compute dn = numeric(d1, f4.0).
compute yn = numeric(y1, f4.0).

compute new_date = date.dmy(dn, mn, yn).

format new_date (adate).
execute.

delete variables Family_Conference_Date.
execute.
rename variables (new_date=Family_Conference_Date).

formats Family_Conference_Date (adate).

*formats family_id (f8.0) asmt_id (f8.0) inFTfile (f8.0) inCGfile (f8.0) inChildfile (f8.0) .
*sort cases by inallthree(A) COUNTY_ID inFTfile inCGfile inChildfile.
*list variables inallthree COUNTY_ID FAMILY_ID ASMT_ID Family_Conference_Date inFTfile inCGfile inChildfile.

/* extract only the date range needed */
/* July 01, 2013 to April 15, 2014 */


*if (yrmoda(yn, mn, dn)>=yrmoda(2013,7,1) AND yrmoda(yn, mn, dn)<=yrmoda(2014,4,15)) keepthisdate=1.
*crosstabs.
* /tables=Family_Conference_Date by keepthisdate.

/* select the records from that window */
*select if (keepthisdate=1).

FREQ VARS=MCI.
/* three MCI's appear twice */
/* one MCI is blank */

sort cases by CountyCode MCI Family_Conference_Date.

compute inbaseline=1.

compute isdiff=1.
if (CountyCode=LAG(CountyCode ) AND MCI=LAG(MCI) AND Family_Conference_Date=LAG(Family_Conference_Date))  isdiff=lag(isdiff)+1.

FREQ VARS=isdiff.
/* have three repeats */

/* which ones are the repeats? */
temporary.
SELECT IF (isdiff=2).
list  CountyCode MCI Family_Conference_Date.
/* were records that did appear twice in the dataset */

SELECT IF (isdiff=1).

/* no repeats */

string MCI10 (A10).
compute MCI10=MCI.

/* put the BL prefix in front of the entries */
/* can drop some fields */
execute.
delete variables Form_ID m1 d1 y1 lendate slashat3 mn dn yn isdiff.
execute.

/* from http://www.ats.ucla.edu/stat/spss/code/renaming_variables_dynamically.htm */
define !rename2 (vlist = !charend('/')
                        /prefix=!cmdend )

!do !vname !in (!vlist) 
!let !nname = !concat(!prefix, !vname)
rename variables (!vname = !nname).
!doend
!enddefine.

!rename2 vlist = Year Conference_ID Conference_ID_A
 Referral_Date
 Invitees
 ReturnHome
 Attendees
 PreventMove
 Pathway
 Ethnicity
 Race
 Age
 Gender
 Legal
 Hours
 Minutes
 Participants
 Part_Other
 a1
 a2
 a3
 a4
 a5
 a6
 a7
 a8
 a9
 a10
 a11
 a12
 a13
 a14
 a15
 a16
 a17
 a18
 a19
 a20
 a21
 a22
 a23
 a24
 a25
 a26
 a27
 a28
 a29
 Services
 c1
 c2
 c3
 c4
 c5
 c6
 c7
 c8
 c9
 c10
 c11
 c12
 c13
 c14
 c15
 c16
 c17
 c18
 c19
 c20
 c21
 c22
 c23
 c24
 c25
 c26
 c27
 c28
 c29
 c30
 c31
 c32
 c33
 CurrentLiving
 PostLiving
 SubstantiatedReports
 ServiceHistoryType
 Conference_Agencies
 Referal
 Purpose
 SharedCase
 Time_Stamp /prefix = BL_.



sort cases by CountyCode MCI10 Family_Conference_Date.


save outfile='H:\data_fes\20140702_baseline_sorted.sav'
 /keep=CountyCode MCI10 Family_Conference_Date inbaseline.


/* Outcome file */
GET DATA 
  /TYPE=XLS 
  /FILE='H:\data_fes\fes_data_20140702.xls' 
  /SHEET=name 'Outcome' 
  /CELLRANGE=full 
  /READNAMES=on 
  /ASSUMEDSTRWIDTH=32767. 
EXECUTE. 
DATASET NAME DataSet1 WINDOW=FRONT. 

/* CREATE Date variable */

string m1 (a2).
string d1 (a2).
string y1 (a4).
exe.

/* what is length of string variable? */
/* mm-dd-yyyy means 10 */
/* mm-d-yyyy means 9 */
/* m-dd-yyyy means 9 */
/* m-d-yyyy means 8 */
/* some have time " 0:00" */
/* 13 means 8 */
/* 14 means 9 */
/* 15 means 10 */
/* 23 means yyyy-mm-dd 00:00:00.000 */
compute lendate=len(ltrim(rtrim(FollowUp_Date))).
freq vars=lendate.

if (lendate=13) lendate=8.
if (lendate=14) lendate=9.
if (lendate=15) lendate=10.

/* Venango dates have a leading blank */
compute FollowUp_Date=ltrim(rtrim(FollowUp_Date)).

if (substring(FollowUp_Date,3,1)="/") slashat3=1.
if (substring(FollowUp_Date,3,1)~="/") slashat3=0.

freq vars=slashat3.

DEFINE fillindates (thelendate=!TOKENS(1) 
 / yesslash=!TOKENS(1) 
 / mplace=!TOKENS(1) 
 / mlength=!TOKENS(1) 
 / dplace=!TOKENS(1) 
 / dlength=!TOKENS(1)
 / yplace=!TOKENS(1))

if (lendate=!thelendate & slashat3=!yesslash) m1=substring(FollowUp_Date, !mplace, !mlength).
if (lendate=!thelendate & slashat3=!yesslash) d1=substring(FollowUp_Date, !dplace, !dlength).
if (lendate=!thelendate & slashat3=!yesslash) y1=substring(FollowUp_Date, !yplace, 4).
!enddefine.


fillindates thelendate=10 yesslash=1 mplace=1 mlength=2 dplace=4 dlength=2 yplace=7.
fillindates thelendate=9 yesslash=1 mplace=1 mlength=2 dplace=4 dlength=1 yplace=6.
fillindates thelendate=9 yesslash=0 mplace=1 mlength=1 dplace=3 dlength=2 yplace=6.
fillindates thelendate=8 yesslash=0 mplace=1 mlength=1 dplace=3 dlength=1 yplace=5.
fillindates thelendate=23 yesslash=0 mplace=6 mlength=2 dplace=9 dlength=2 yplace=1.

freq vars=m1.
freq vars=d1.
freq vars=y1.


/* is month two digits? */
* compute m1 = substr(FollowUp_Date, 1, 2).
* if (index(m1, "/")>0) onedigmo=1.
* if (index(m1, "/")=0) onedigmo=0.
* if (index(m1, "/")>0) m1=substr(FollowUp_Date, 1, 1).

/* taking into account number of digits in month */
* if (onedigmo=0) compute d1 = substr(FollowUp_Date, 4, 2).
/* that one has a slash in it? */
* if (onedigmo=0 & index(d1, "/")>0) onedigdy=1.
* if (onedigmo=0 & index(d1, "/")=0) onedigdy=0.
* if (onedigmo=0 & index(d1, "/")>0) compute d1 = substr(FollowUp_Date, 4, 1).



* compute y1 = substr(FollowUp_Date, 7, 4).

compute mn = numeric(m1, f4.0).
compute dn = numeric(d1, f4.0).
compute yn = numeric(y1, f4.0).

compute new_date = date.dmy(dn, mn, yn).

format new_date (adate).
execute.

delete variables FollowUp_Date.
execute.
rename variables (new_date=FollowUp_Date).

formats FollowUp_Date (adate).

*formats family_id (f8.0) asmt_id (f8.0) inFTfile (f8.0) inCGfile (f8.0) inChildfile (f8.0) .
*sort cases by inallthree(A) COUNTY_ID inFTfile inCGfile inChildfile.
*list variables inallthree COUNTY_ID FAMILY_ID ASMT_ID FollowUp_Date inFTfile inCGfile inChildfile.


/* extract only the date range needed */
/* July 01, 2013 to April 15, 2014 */


*if (yrmoda(yn, mn, dn)>=yrmoda(2013,7,1) AND yrmoda(yn, mn, dn)<=yrmoda(2014,4,15)) keepthisdate=1.
*crosstabs.
*/tables=FollowUp_Date by keepthisdate.

/* select the records from that window */
*select if (keepthisdate=1).

FREQ VARS=Childs_MCI.

rename variables (Childs_MCI=MCI).
/* 23 different MCI's no repeats */

sort cases by County_Code MCI FollowUp_Date.

compute inoutcome=1.

compute isdiff=1.
if (County_Code=LAG(County_Code ) AND MCI=LAG(MCI) AND FollowUp_Date=LAG(FollowUp_Date))  isdiff=lag(isdiff)+1.
FREQ VARS=isdiff.
select if (isdiff=1).

string MCI10 (A10).
compute MCI10=MCI.

sort cases by County_Code MCI10 FollowUp_Date.

recode Case_closed (''=SYSMIS) ('1'=1) ('2'=0) (convert) into caseclosureyes.

execute.
delete variables FormID m1 d1 y1 lendate slashat3 mn dn yn isdiff.
execute.

rename variables (County_Code=CountyCode) (Family_Conference_Date=Family_Conference_DateORIG) (FollowUp_Date=Family_Conference_Date). 

!rename2 vlist =
Closure_Reason
Family_Conference_DateORIG
Followup_Agencies_Open
Q1D
Q1Db
Q1Dc
Conference_ID
Year
Conference_Number
Q1Da
Case_closed
Family_ID
initial_agencies
Service_Supports
c1
c2
c3
c4
c5
c6
c7
c8
c9
c10
c11
c12
c13
c14
c15
c16
c17
c18
c19
c20
c21
c22
c23
c24
c25
c26
c27
c28
c29
c30
c31
c32
c33
c34
Post_Living
P_Environment
TimeStamp
/prefix = FL_.

save outfile='H:\data_fes\20140702_outcome_sorted.sav'
 /keep=CountyCode MCI10 Family_Conference_Date caseclosureyes inoutcome.



/* Facilitator file */
GET DATA 
  /TYPE=XLS 
  /FILE='H:\data_fes\fes_data_20140702.xls' 
  /SHEET=name 'Facilitator' 
  /CELLRANGE=full 
  /READNAMES=on 
  /ASSUMEDSTRWIDTH=32767. 
EXECUTE. 
DATASET NAME DataSet1 WINDOW=FRONT. 


/* CREATE Date variable */

string m1 (a2).
string d1 (a2).
string y1 (a4).
exe.

/* what is length of string variable? */
/* mm-dd-yyyy means 10 */
/* mm-d-yyyy means 9 */
/* m-dd-yyyy means 9 */
/* m-d-yyyy means 8 */
/* some have time " 0:00" */
/* 13 means 8 */
/* 14 means 9 */
/* 15 means 10 */
/* 23 means yyyy-mm-dd 00:00:00.000 */
compute lendate=len(ltrim(rtrim(Mtg_Dt))).
freq vars=lendate.

if (lendate=13) lendate=8.
if (lendate=14) lendate=9.
if (lendate=15) lendate=10.

/* Venango dates have a leading blank */
compute Mtg_Dt=ltrim(rtrim(Mtg_Dt)).

if (substring(Mtg_Dt,3,1)="/") slashat3=1.
if (substring(Mtg_Dt,3,1)~="/") slashat3=0.

freq vars=slashat3.

DEFINE fillindates (thelendate=!TOKENS(1) 
 / yesslash=!TOKENS(1) 
 / mplace=!TOKENS(1) 
 / mlength=!TOKENS(1) 
 / dplace=!TOKENS(1) 
 / dlength=!TOKENS(1)
 / yplace=!TOKENS(1))

if (lendate=!thelendate & slashat3=!yesslash) m1=substring(Mtg_Dt, !mplace, !mlength).
if (lendate=!thelendate & slashat3=!yesslash) d1=substring(Mtg_Dt, !dplace, !dlength).
if (lendate=!thelendate & slashat3=!yesslash) y1=substring(Mtg_Dt, !yplace, 4).
!enddefine.


fillindates thelendate=10 yesslash=1 mplace=1 mlength=2 dplace=4 dlength=2 yplace=7.
fillindates thelendate=9 yesslash=1 mplace=1 mlength=2 dplace=4 dlength=1 yplace=6.
fillindates thelendate=9 yesslash=0 mplace=1 mlength=1 dplace=3 dlength=2 yplace=6.
fillindates thelendate=8 yesslash=0 mplace=1 mlength=1 dplace=3 dlength=1 yplace=5.
fillindates thelendate=23 yesslash=0 mplace=6 mlength=2 dplace=9 dlength=2 yplace=1.

freq vars=m1.
freq vars=d1.
freq vars=y1.


/* is month two digits? */
* compute m1 = substr(Mtg_Dt, 1, 2).
* if (index(m1, "/")>0) onedigmo=1.
* if (index(m1, "/")=0) onedigmo=0.
* if (index(m1, "/")>0) m1=substr(Mtg_Dt, 1, 1).

/* taking into account number of digits in month */
* if (onedigmo=0) compute d1 = substr(Mtg_Dt, 4, 2).
/* that one has a slash in it? */
* if (onedigmo=0 & index(d1, "/")>0) onedigdy=1.
* if (onedigmo=0 & index(d1, "/")=0) onedigdy=0.
* if (onedigmo=0 & index(d1, "/")>0) compute d1 = substr(Mtg_Dt, 4, 1).



* compute y1 = substr(Mtg_Dt, 7, 4).

compute mn = numeric(m1, f4.0).
compute dn = numeric(d1, f4.0).
compute yn = numeric(y1, f4.0).

compute new_date = date.dmy(dn, mn, yn).

format new_date (adate).
execute.

delete variables Mtg_Dt.
execute.
rename variables (new_date=Mtg_Dt).

formats Mtg_Dt (adate).

*formats family_id (f8.0) asmt_id (f8.0) inFTfile (f8.0) inCGfile (f8.0) inChildfile (f8.0) .
*sort cases by inallthree(A) COUNTY_ID inFTfile inCGfile inChildfile.
*list variables inallthree COUNTY_ID FAMILY_ID ASMT_ID Mtg_Dt inFTfile inCGfile inChildfile.

/* extract only the date range needed */
/* July 01, 2013 to April 15, 2014 */


*if (yrmoda(yn, mn, dn)>=yrmoda(2013,7,1) AND yrmoda(yn, mn, dn)<=yrmoda(2014,4,15)) keepthisdate=1.
*crosstabs.
*/tables=Mtg_Dt by keepthisdate.

/* County Code is Numeric here */
/* select the records from that window */
*select if (keepthisdate=1 AND CountyCode=22).

/* County Code is Numeric here */
/* select the records from that window */
*select if (keepthisdate=1 AND CountyCode=22).

/* need to convert CountyCode to string format */
*string CountyasString (A2).
*compute CountyasString=string( CountyCode, F2.0).
*if CountyasString=' 2' CountyasString='02'.

*freq vars=CountyasString.
*execute.

*delete variables CountyCode.
*rename variables (CountyasString=CountyCode).


rename variables (Childs_MCI=MCI).
/* 84 different MCI's with 2 repeats */
/* 86 total */

sort cases by MCI.

compute infacilitator=1.
*save outfile='H:\data_fes\20140702_facilitator_sorted.sav'.

compute lenMCI=length(MCI).
FREQ VARS=lenMCI.

sort cases by CountyCode MCI Mtg_Dt.

compute isdiff=1.
if (CountyCode=LAG(CountyCode) AND MCI=LAG(MCI) AND Mtg_Dt=LAG(Mtg_Dt)) isdiff=lag(isdiff)+1.

FREQ VARS=isdiff.

/* which ones are the repeats? */
temporary.
SELECT IF (isdiff=2).
list  CountyCode MCI Mtg_Dt.
/* were records that did appear twice in the dataset */

!rename2 vlist = Mtg_type
Sched
Fac_Name
Fac_type
Fac_Other
Mtg_Loc
Family_ID
Parent
Num_Invite
Num_Attend
Trans_Offer
Transport
Care_Offer
Childcare
TimeStamp
/prefix = FA_.

select if (isdiff=1).
sort cases by CountyCode MCI Mtg_Dt.
rename variables (MCI=MCI10) (Mtg_Dt=Family_Conference_Date).
save outfile='H:\data_fes\20140702_facilitator_singles.sav'
 /keep=CountyCode MCI10 Family_Conference_Date  infacilitator.


/* Attendee Survey file */
GET DATA 
  /TYPE=XLS 
  /FILE='H:\data_fes\fes_data_20140702.xls' 
  /SHEET=name 'FE_Survey' 
  /CELLRANGE=full 
  /READNAMES=on 
  /ASSUMEDSTRWIDTH=32767. 
EXECUTE. 
DATASET NAME DataSet1 WINDOW=FRONT. 


/* CREATE Date variable */

string m1 (a2).
string d1 (a2).
string y1 (a4).
exe.

/* what is length of string variable? */
/* mm-dd-yyyy means 10 */
/* mm-d-yyyy means 9 */
/* m-dd-yyyy means 9 */
/* m-d-yyyy means 8 */
/* some have time " 0:00" */
/* 13 means 8 */
/* 14 means 9 */
/* 15 means 10 */
/* 23 means yyyy-mm-dd 00:00:00.000 */
compute lendate=len(ltrim(rtrim(Conf_Date))).
freq vars=lendate.

if (lendate=13) lendate=8.
if (lendate=14) lendate=9.
if (lendate=15) lendate=10.

/* Venango dates have a leading blank */
compute Conf_Date=ltrim(rtrim(Conf_Date)).

if (substring(Conf_Date,3,1)="/") slashat3=1.
if (substring(Conf_Date,3,1)~="/") slashat3=0.

freq vars=slashat3.

DEFINE fillindates (thelendate=!TOKENS(1) 
 / yesslash=!TOKENS(1) 
 / mplace=!TOKENS(1) 
 / mlength=!TOKENS(1) 
 / dplace=!TOKENS(1) 
 / dlength=!TOKENS(1)
 / yplace=!TOKENS(1))

if (lendate=!thelendate & slashat3=!yesslash) m1=substring(Conf_Date, !mplace, !mlength).
if (lendate=!thelendate & slashat3=!yesslash) d1=substring(Conf_Date, !dplace, !dlength).
if (lendate=!thelendate & slashat3=!yesslash) y1=substring(Conf_Date, !yplace, 4).
!enddefine.


fillindates thelendate=10 yesslash=1 mplace=1 mlength=2 dplace=4 dlength=2 yplace=7.
fillindates thelendate=9 yesslash=1 mplace=1 mlength=2 dplace=4 dlength=1 yplace=6.
fillindates thelendate=9 yesslash=0 mplace=1 mlength=1 dplace=3 dlength=2 yplace=6.
fillindates thelendate=8 yesslash=0 mplace=1 mlength=1 dplace=3 dlength=1 yplace=5.
fillindates thelendate=23 yesslash=0 mplace=6 mlength=2 dplace=9 dlength=2 yplace=1.

freq vars=m1.
freq vars=d1.
freq vars=y1.


/* is month two digits? */
* compute m1 = substr(Conf_Date, 1, 2).
* if (index(m1, "/")>0) onedigmo=1.
* if (index(m1, "/")=0) onedigmo=0.
* if (index(m1, "/")>0) m1=substr(Conf_Date, 1, 1).

/* taking into account number of digits in month */
* if (onedigmo=0) compute d1 = substr(Conf_Date, 4, 2).
/* that one has a slash in it? */
* if (onedigmo=0 & index(d1, "/")>0) onedigdy=1.
* if (onedigmo=0 & index(d1, "/")=0) onedigdy=0.
* if (onedigmo=0 & index(d1, "/")>0) compute d1 = substr(Conf_Date, 4, 1).



* compute y1 = substr(Conf_Date, 7, 4).

compute mn = numeric(m1, f4.0).
compute dn = numeric(d1, f4.0).
compute yn = numeric(y1, f4.0).

compute new_date = date.dmy(dn, mn, yn).

format new_date (adate).
execute.

delete variables Conf_Date.
execute.
rename variables (new_date=Conf_Date).

formats Conf_Date (adate).

*formats family_id (f8.0) asmt_id (f8.0) inFTfile (f8.0) inCGfile (f8.0) inChildfile (f8.0) .
*sort cases by inallthree(A) COUNTY_ID inFTfile inCGfile inChildfile.
*list variables inallthree COUNTY_ID FAMILY_ID ASMT_ID Conf_Date inFTfile inCGfile inChildfile.

/* extract only the date range needed */
/* July 01, 2013 to April 15, 2014 */


*if (yrmoda(yn, mn, dn)>=yrmoda(2013,7,1) AND yrmoda(yn, mn, dn)<=yrmoda(2014,4,15)) keepthisdate=1.
*crosstabs.
*/tables=Conf_Date by keepthisdate.

/* select the records from that window */
*select if (keepthisdate=1).

/* may have more than one survey per conference */
/* will want to tabulate the number of surveys at the conference */


sort cases by CountyCode MCI Conf_Date.

compute orderofobs=1.
if (CountyCode=lag(CountyCode) and MCI=lag(MCI) and Conf_Date=lag(Conf_Date)) orderofobs=lag(orderofobs)+1.

FREQ VARS=orderofobs.

/* some obs to check */
list variables CountyCode MCI Conf_Date orderofobs
 /cases=from 10 to 14.

/* reverse sort to get the maximum number first */
sort cases by CountyCode (A) MCI (A) Conf_Date (A) orderofobs (D).

compute inFESurvey=orderofobs.
if (CountyCode=lag(CountyCode) and MCI=lag(MCI) and Conf_Date=lag(Conf_Date)) inFESurvey=lag(inFESurvey).

FREQ VARS=orderofobs inFESurvey.


CROSSTABS
 /TABLES=orderofobs BY inFESurvey.

*save outfile='H:\data_fes\20140702_FESurvey_sorted.sav'.

/* also want to get rid of obs. without a survey date for the timeline */
/* will give these obs some orderofobs value not 1 */
if (sysmis(Conf_Date)=1) orderofobs=35.

/* ONLY NEED one obs per set of county code, MCI, conf date */
select if (orderofobs=1).

compute lenMCI=length(MCI).
FREQ VARS=lenMCI.

*compute isdiff=1.
*if (MCI=LAG(MCI)) isdiff=lag(isdiff)+1.

*FREQ VARS=isdiff.

/* for purposes of counting files */
/* remove dupes */

*select if (isdiff=1).
sort cases by CountyCode MCI  Conf_Date.

rename variables (MCI=MCI10) (Conf_Date=Family_Conference_Date).
save outfile='H:\data_fes\20140702_FESurvey_singles.sav'
 /keep=CountyCode MCI10 Family_Conference_Date inFESurvey.


/* TIME TO MERGE!! */
*get file='H:\data_fes\dauphin_20140508_FESurvey_singles.sav'.

/* the merge! */
match files file='H:\data_fes\20140702_baseline_sorted.sav' /in=fromBase
	/file='H:\data_fes\20140702_outcome_sorted.sav' /in=fromFollow
	/file='H:\data_fes\20140702_facilitator_singles.sav' /in=fromFacil
/file='H:\data_fes\20140702_FESurvey_singles.sav' /in=fromFESurvey
	/by CountyCode MCI10 Family_Conference_Date.

list variables MCI10 inbaseline inoutcome caseclosureyes infacilitator inFESurvey.

FREQ VARS=inbaseline inoutcome caseclosureyes infacilitator inFESurvey.

crosstabs
/tables=infacilitator  by caseclosureyes .

/* People with a Face Sheet and a Case Closure */
compute FSplusCC=sum(infacilitator, caseclosureyes ). 

crosstabs
/tables=infacilitator  by FSplusCC.

temporary.
select if (caseclosureyes=1).
list variables MCI10 inbaseline inoutcome caseclosureyes infacilitator inFESurvey.
/* four cases have case closure yes and no facilitator face sheet */

/* baseline meeting without face sheet */
temporary.
select if (inbaseline=1 AND sysmis(infacilitator)=1).
FREQ VARS=MCI10.

temporary.
select if (inbaseline=1 AND sysmis(infacilitator)=1).
list variables MCI10 inbaseline inoutcome caseclosureyes infacilitator inFESurvey.

/* 13 with baseline and no Face Sheet */
/* 3 of that 13 have Follow-Up and are Case Closure Yes */

/* follow-up meeting without face sheet */
temporary.
select if (inoutcome=1 AND sysmis(infacilitator)=1).
list variables MCI10 inbaseline inoutcome caseclosureyes infacilitator inFESurvey.
/* 5 with follow-up and no Face Sheet (four of them being case closures) */

/* has a face sheet and either a baseline or follow-up meeting OR case closure not previously counted */
compute countme=0.
if (infacilitator=1 AND inoutcome=1) countme=1.
if (infacilitator=1 AND inbaseline=1) countme=1.
if (caseclosureyes=1) countme=1.
FREQ VARS=countme.

/* reason for countme */
compute whycountme=0.
if (infacilitator=1 AND inoutcome=1) whycountme=1.
if (infacilitator=1 AND inbaseline=1) whycountme=2.
if (caseclosureyes=1) whycountme=3.
FREQ VARS=whycountme.

crosstabs
/table=countme by whycountme.
/* 3 follow-up & facilitator (not including case closures) */
/* 50 baseline & facilitator */
/* 17 case closure */

compute whynotcountme=0.
/* explain the countme=zeroes */
/* facilitator and no baseline or follow-up */
if (countme=0 & infacilitator=1 & sysmis(inbaseline)=1 & sysmis(inoutcome)=1) whynotcountme=1.


/* no facilitator and no baseline and yes follow-up */
if (countme=0 & sysmis(infacilitator)=1 & sysmis(inbaseline)=1 & inoutcome=1) whynotcountme=2.

/* no facilitator and yes baseline and no follow-up */
if (countme=0 & sysmis(infacilitator)=1 & inbaseline=1 & sysmis(inoutcome)=1) whynotcountme=3.



/* FE Survey only */
if (countme=0 & sysmis(infacilitator)=1 & sysmis(inbaseline)=1 & sysmis(inoutcome)=1 & inFESurvey>=1) 
 whynotcountme=4.

/* Baseline and Follow-Up Survey on Same Date */
/* Flagged Record! */
if (countme=0 & inbaseline=1 & inoutcome=1)  whynotcountme=5.


/* need it to be the other 51 out of the 121 total records */

FREQ VARS=whynotcountme.
crosstabs
/table=countme by whynotcountme.

/* hopefully zero for caseclosureyes=1 and whynotcountme~=0 */
/* meaning that case closure are not getting counted in the whynotcountme */
crosstabs
/table=caseclosureyes by whynotcountme.
/* yes, it's zero */

/* has a Baseline with FFS */

/* adding labels to variables for readability */
variable labels inbaseline 'MCI in Baseline Table'. 
variable labels infacilitator 'MCI in Facilitator Table'.
variable labels inoutcome 'MCI in Outcome Table'.
variable labels inFESurvey 'Number of Forms for MCI in FESurvey Table'.

variable labels fromBase 'MCI Appears in Baseline Table'. 
variable labels fromFacil 'MCI Appears in Facilitator Table'.
variable labels fromFollow 'MCI Appears in Outcome Table'.
variable labels fromFESurvey 'MCI Appears in FESurvey Table'.


value labels inbaseline infacilitator inoutcome 1 'Yes'.
*value labels inFESurvey 1 '1'.

value labels fromBase fromFacil fromFollow  fromFESurvey 1 'Yes' 0 'No'.
variable labels MCI10 'MCI'.
variable labels caseclosureyes 'Case Closure Box Checked'.
value labels caseclosureyes  1 'Yes' 0 'No'.
variable labels FSplusCC 'Has Both FFS and CC'.
value labels FSplusCC 2 'Has Both FFS and CC' 1 'Has Either FFS or CC' 0 'Has Neither FFS or CC'.
variable labels countme 'Included in Number of Children who Had at least One Meeting'.
value labels countme 1 'Yes' 0 'No'.
variable labels whycountme 'Reason Included in Number of Children who Had at least One Meeting'.
value labels whycountme 1 'Has FFS and Follow-Up' 2 'Has FFS and Base' 3 'Case Closure' 0 'Not Included'.
variable labels whynotcountme 'Reason NOT Included in Number of Children who Had at least One Meeting'.
value labels whynotcountme 1 'FFS with no Base and no Follow-Up' 
 2 'Follow-Up with No FFS and No Base' 
 3 'Base with No FFS and No Follow-Up' 
 4 'Conference Survey and No Other Forms' 
 5 'Base and Follow-Up on Same Date'
 0 'Yes Included'.

variable LABELS CountyCode 'County Code'.
variable LABELS MCI10 'MCI'.
variable LABELS Family_Conference_Date 'Date of Conference'.

FREQ VARS=countme whycountme whynotcountme .


save translate outfile='h:\mbg_db_reporting\20140702_timeline_of_FES_forms.xls'
 /type=xls
 /version=8
 /map
 /replace
 /fieldnames
 /cells=labels
 /unselected=delete
 /keep=CountyCode MCI10 Family_Conference_Date caseclosureyes 
 fromBase
 fromFollow
 fromFacil inFESurvey countme whycountme whynotcountme .
