/* when pulling together fields, */
/* will use group by, because */
/* we only need one record per meeting */
/* and some forms appear more than once */
/* for the same meeting */
/* county 61, MCI 630155632 */
/* mtg date 10/15/2013 */



With
/* listing of facilitator facesheets */
/* will want conference date, county, MCI */
FFSinfo (COUNTY_ID, Mtg_Dt, MCI, hasFFS)
as (
SELECT [CountyCode],cast([Mtg_Dt] as datetime),[Childs_MCI], 1
FROM [FGDM].[dbo].[Facilitator]
group by [CountyCode],cast([Mtg_Dt] as datetime),[Childs_MCI]
),
/* listing of baseline forms */
/* will want conference date, county, MCI */

BLinfo (COUNTY_ID, Mtg_Dt, MCI, hasBL)
as (
SELECT [CountyCode],cast([Family_Conference_Date] as datetime),[MCI], 1
FROM [FGDM].[dbo].[Baseline]
group by [CountyCode],cast([Family_Conference_Date] as datetime),[MCI]
),

/* listing of follow-up forms */
/* will want conference date, county, MCI */

FLinfo (COUNTY_ID, Mtg_Dt, MCI, closure, hasFL)
as (
SELECT [County_Code],cast([FollowUp_Date] as datetime),[Childs_MCI],
	  		(case when 
			(CHARINDEX('XX', [Family_ID] COLLATE Latin1_General_CI_AS)>0 or Case_closed=1)
						then 1 else null end) as closure, 1
FROM [FGDM].[dbo].[Outcome]
group by [County_Code],cast([FollowUp_Date] as datetime),[Childs_MCI],
(case when 
			(CHARINDEX('XX', [Family_ID] COLLATE Latin1_General_CI_AS)>0 or Case_closed=1)
						then 1 else null end) 
),

Survinfo (COUNTY_ID, Mtg_Dt, MCI, numforms) 
as (
SELECT [CountyCode],cast([Conf_Date] as datetime),[MCI],
	count([Time_Stamp]) AS numforms
FROM [FGDM].[dbo].[FE_Survey] 
group by [CountyCode], cast([Conf_Date] as datetime),[MCI]
),
/* create the timeline of forms */
/* join the baseline forms and the FFS */
afteronejoin (COUNTY_ID, Mtg_Dt, MCI, hasFFS, hasBL)
as (
select ISNULL(FFSinfo.COUNTY_ID, BLinfo.COUNTY_ID), 
		ISNULL(FFSinfo.Mtg_Dt, BLinfo.Mtg_Dt), 
		ISNULL(FFSinfo.MCI, BLinfo.MCI), 
		hasFFS, hasBL
FROM FFSinfo full join BLinfo
	on FFSinfo.COUNTY_ID=BLinfo.COUNTY_ID
	and
	FFSinfo.Mtg_Dt=BLinfo.Mtg_Dt
	and
	FFSinfo.MCI=BLinfo.MCI
	),
/* join the follow-up forms to the BL and FFS */
aftertwojoins (COUNTY_ID, Mtg_Dt, MCI, hasFFS, hasBL, closure, hasFL)
as (
select ISNULL(afteronejoin.COUNTY_ID, FLinfo.COUNTY_ID), 
		ISNULL(afteronejoin.Mtg_Dt, FLinfo.Mtg_Dt), 
		ISNULL(afteronejoin.MCI, FLinfo.MCI), 
		hasFFS, hasBL,
		closure, hasFL
FROM afteronejoin full join FLinfo
	on afteronejoin.COUNTY_ID=FLinfo.COUNTY_ID
	and
	afteronejoin.Mtg_Dt=FLinfo.Mtg_Dt
	and
	afteronejoin.MCI=FLinfo.MCI
	),
/* add the survey information to the BL, FFS, and FL */ 
afterthreejoins (COUNTY_ID, Mtg_Dt, MCI, hasFFS, hasBL, closure, hasFL, numforms, completepacket)
as (
select ISNULL(aftertwojoins.COUNTY_ID, Survinfo.COUNTY_ID), 
		ISNULL(aftertwojoins.Mtg_Dt, Survinfo.Mtg_Dt), 
		ISNULL(aftertwojoins.MCI, Survinfo.MCI), 
		hasFFS, hasBL,
		closure, hasFL, ISNULL(numforms, 0),
		(case when (
		(hasFFS=1 and hasBL=1)
		or
		(hasFFS=1 and hasFL=1)
		or
		closure=1
		)		
		then 1 else 0 end) as completepacket
FROM aftertwojoins full join Survinfo
	on aftertwojoins.COUNTY_ID=Survinfo.COUNTY_ID
	and
	aftertwojoins.Mtg_Dt=Survinfo.Mtg_Dt
	and
	aftertwojoins.MCI=Survinfo.MCI
	)
/* what counts as a complete set */
/* FFS + BL */
/* FFS + FL */
/* FL that is case closure */
/* now create the summary statistic per month */
select COUNTY_ID, year(cast(Mtg_Dt as datetime)) as SubYear, 
	month(cast(Mtg_Dt as datetime)) as SubMonth, 
	count(case when (completepacket=1) then 1 else null end) as NumComplete, 
	count(case when (completepacket=0) then 1 else null end) as NumIncomplete,
	count(case when (completepacket=0) then hasFFS else null end) as FFSIncomplete,
	count(case when (completepacket=0) then hasBL else null end) as BLIncomplete,
	count(case when (completepacket=0) then hasFL else null end) as FLIncomplete,
	sum(case when (completepacket=0) then numforms else 0 end) as SurvIncomplete
		from afterthreejoins
	group by COUNTY_ID, year(cast(Mtg_Dt as datetime)),
	month(cast(Mtg_Dt as datetime))
	order by COUNTY_ID, year(cast(Mtg_Dt as datetime)),
	month(cast(Mtg_Dt as datetime))