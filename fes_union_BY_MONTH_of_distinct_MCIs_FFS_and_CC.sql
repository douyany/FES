/* MONTH-BY-MONTH */
/* just looking at a few particular months of time window and of 2014 */
select FacilCounty, MonthofInitial,  count(FacilMCI) as CountFacil
 from 
(SELECT CountyCode as FacilCounty, [Childs_MCI] as FacilMCI, month([Mtg_Dt]) as MonthofInitial
  FROM [FGDM].[dbo].[Facilitator]
  WHERE 
  cast([Mtg_Dt] as datetime)<='2014/10/31'	
  AND  cast([Mtg_Dt] as datetime)>'2013/06/30 23:59:59.999'
  and year(cast([Mtg_Dt] as datetime))=2014 
    and month(cast([Mtg_Dt] as datetime))>7
union
SELECT County_Code as OutcomeCounty, [Childs_MCI] as OutcomeMCI, month([FollowUp_Date]) as MonthofFollow
  FROM [FGDM].[dbo].[Outcome]
  where 
  ((CHARINDEX('XX', [Family_ID] COLLATE Latin1_General_CI_AS)>0 OR Case_closed=1) 
  and 
  cast([FollowUp_Date] as datetime)<='2014/10/31' 
  and cast([FollowUp_Date] as datetime)>'2013/06/30 23:59:59.999' 
  and 
  year(cast([FollowUp_Date] as datetime))=2014
  and
  month(cast([FollowUp_Date] as datetime))>7
  ) 
  ) as TableLayer1
  group by FacilCounty, MonthofInitial
  order by FacilCounty, MonthofInitial  
  
/* not grouping by county */
/* listing out the MCI's (as a quality check) */  
select FacilCounty, MonthofInitial,  FacilMCI
 from 
(SELECT CountyCode as FacilCounty, [Childs_MCI] as FacilMCI, month(cast([Mtg_Dt] as datetime)) as MonthofInitial
  FROM [FGDM].[dbo].[Facilitator]
  WHERE 
  cast([Mtg_Dt] as datetime)<='2014/10/31'	
  AND  cast([Mtg_Dt] as datetime)>'2013/06/30 23:59:59.999'
  and year(cast([Mtg_Dt] as datetime))=2014 
union
SELECT County_Code as OutcomeCounty, [Childs_MCI] as OutcomeMCI, month(cast([FollowUp_Date] as datetime)) as MonthofFollow
  FROM [FGDM].[dbo].[Outcome]
  where 
  ((CHARINDEX('XX', [Family_ID] COLLATE Latin1_General_CI_AS)>0 OR Case_closed=1) 
  and 
  cast([FollowUp_Date] as datetime)<='2014/10/31' 
  and cast([FollowUp_Date] as datetime)>'2013/06/30 23:59:59.999' 
  and 
  year(cast([FollowUp_Date] as datetime))=2014
  ) 
  ) as TableLayer1
  order by FacilCounty, MonthofInitial  
  
/* listing out which data (FFS vs. CC FollowUp_Date) provided the record */
/* because of the "uniqueness" definition */
/* may contain repeats of the MCI's */  

/* not grouping by county */
/* listing out the MCI's (as a quality check) */  
select FacilCounty, MonthofInitial,  FacilMCI, WhenMet, inFFS
 from 
(SELECT CountyCode as FacilCounty, [Childs_MCI] as FacilMCI, month(cast([Mtg_Dt] as datetime)) as MonthofInitial, Mtg_Dt as WhenMet, 1 as inFFS
  FROM [FGDM].[dbo].[Facilitator]
  WHERE 
  cast([Mtg_Dt] as datetime)<='2014/10/31'	
  AND  cast([Mtg_Dt] as datetime)>'2013/06/30 23:59:59.999'
  and year(cast([Mtg_Dt] as datetime))=2014 
union
SELECT County_Code as OutcomeCounty, [Childs_MCI] as OutcomeMCI, month(cast([FollowUp_Date] as datetime)) as MonthofFollow, FollowUp_Date, 0 as inCC
  FROM [FGDM].[dbo].[Outcome]
  where 
  ((CHARINDEX('XX', [Family_ID] COLLATE Latin1_General_CI_AS)>0 OR Case_closed=1) 
  and 
  cast([FollowUp_Date] as datetime)<='2014/10/31' 
  and cast([FollowUp_Date] as datetime)>'2013/06/30 23:59:59.999' 
  and 
  year(cast([FollowUp_Date] as datetime))=2014
  ) 
  ) as TableLayer1
  where MonthofInitial>7
  order by FacilCounty, MonthofInitial  