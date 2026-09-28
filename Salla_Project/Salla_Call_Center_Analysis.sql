 --Combine monthly data
Select *
Into Call_center_data
From Feb_Call_Center
Union all
Select * From Mar_Call_Center
Union all
Select * From Apr_Call_Center;


-- Calculate call difference, missed calls, and handling rate
Select  *, Forecasted_Calls - Calls_Offered As Call_Difference,
			(Calls_Offered - Calls_Handled) As Missed_calls,
			 (Calls_Handled * 100 / NULLIF(Calls_Offered,0)) As Handling_Rate
From Call_center_data;


-- Add calculated columns
Alter Table Call_center_data
Add
	Call_Difference  INT,
	Missed_Calls  INT,
	Handling_Rate DECIMAL(10,2)


-- Update calculated columns
Update Call_center_data
SET
	Call_Difference = Forecasted_Calls - Calls_Offered,
	Missed_calls = Calls_Offered - Calls_Handled,
	Handling_Rate = Calls_Handled * 100.0 / NULLIF(Calls_Offered, 0);


--Calulated Total Forecasted calls, Calls offered, Calls handled, Call Abandon and Handling ratio.
Select 
	Sum(Forecasted_Calls) As Total_Forecasted_Calls,
	Sum(Calls_Offered)    As Total_Calls_Offered,
	Sum(Calls_Handled)    As Total_Calls_Handled,
	Sum(Calls_Abandon)    As Total_Calls_Abandon,
	CONCAT(
	CAST(
	Sum(Calls_Handled) * 100.0/ NULLIF(Sum(Calls_offered),0)
	As DECIMAL(10,2)),'%') As Handling_Ratio
From Call_center_data


-- Calls offered by month
Select Month,
	Sum(Calls_Offered) As Calls_Offered
From Call_center_data
Group By Month 
Order By Calls_Offered Desc;


-- Averege ASA by month
Select Month,
	Round(Avg(ASA),2) As Avg_ASA_by_month
From Call_center_data
Group By Month
Order By Month Desc;


-- Forecast vs actual calls by month
Select Month,
	SUM(Forecasted_Calls) As Total_Forecasted_Calls,
	SUM(Calls_Offered)    As Total_Calls_Offered,
	SUM(Call_Difference)  As Total_Call_Difference
	From Call_center_data
Group By Month

-- Calculate average Call Abandon by month
Select Month,
	Avg(Calls_Abandon) As Calls_Abandon
From Call_center_data
Group By Month 
Order By Month Desc;


-- Calculate Total Agent and Service levels

Select
	Count(Distinct Agent_Name) As Total_Agent,
	CONCAT(
	Cast(
	Sum(Calls_Handled_With_in_Thrshold)* 100.0 / NULLIF(Sum(Calls_offered),0)
	As DECIMAL(10,2) ),'%')
	As Service_levels
From Call_center_data;


-- Calls offered by Agent
Select Agent_Name,
	Sum(Calls_Offered) As Calls_Offered
From Call_center_data
Group By Agent_Name
Order by Calls_Offered Desc;


-- Agent perfermance
Select Agent_Name,
	Sum(Forecasted_Calls) As Forecasted_Calls,
	Sum(Calls_Offered)    As Calls_Offered,
	Sum(Calls_Handled)    As Answered_Call
From Call_center_data
Group By Agent_Name


-- Average ASA by Agent
Select Agent_Name,
	Round(Avg(ASA), 2) As Avg_ASA_by_Agent
From Call_center_data
Group By Agent_Name;


-- Calls Abandon by Agent
Select Agent_Name,
	Sum(Calls_Abandon) As Calls_Abandon_by_Agent
From Call_center_data
Group By Agent_Name
Order By Calls_Abandon_by_Agent Desc;


-- Top 10 call volume
Select Top 10
	Project,
	Date,
	Calls_Offered
From Call_center_data
Order By Calls_Offered Desc;


-- Largest forecast differences
Select Top 10
	Project,
	Call_Difference
From Call_center_data
Order By ABS(Call_Difference) Desc;


Select * From Call_center_data