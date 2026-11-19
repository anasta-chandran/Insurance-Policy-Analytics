CREATE DATABASE insurance_analytics_project;
USE insurance_analytics_project;

RENAME TABLE `policy_data` TO Customer_Information;
 RENAME TABLE `policy_data2` TO Policy_Details;
 RENAME TABLE  `policy_data3` TO Claims;
 RENAME TABLE `policy_data4` TO Payment_History;
RENAME TABLE  `policy_data5` TO Additional_Information;
			
# KPI 2
# What is the total number of customers available in the policy database?
SELECT COUNT(DISTINCT `Customer ID`) AS TOTAL_CUSTOMERS
FROM Customer_information;

# KPI 3
# What is the total number of policies issued?
SELECT count(`Policy ID`) AS TOTAL_POLICIES 
FROM policy_details;

# KPI 4
#What is the total claim amount generated from all policies?
SELECT SUM(`Claim Amount`) AS TOTAL_CLAIM_AMOUNT
FROM Claims;

# KPI 5
# What is the average coverage amount per policy?
SELECT ROUND(AVG(`Coverage Amount`),2) AS AVG_COVERAGE_AMT
 FROM policy_details;
 
 # KPI 6
# What is the average premium amount collected per policy?
SELECT ROUND(AVG(`Premium Amount`), 2) AS AVG_PREMIUM_AMT
FROM policy_details;

# KPI 7
# What percentage of policies are currently active?
SELECT ROUND(COUNT( CASE WHEN status ='Active' THEN 1
		END)*100.0/ COUNT(*),2) AS ACTIVE_PERCENTAGE
		FROM policy_details;
  
# # KPI 8
# How many policies are in active, lapsed, and terminated status?
SELECT status,
       COUNT(*) AS POLICY_COUNT
       FROM policy_details
       GROUP BY status;

# KPI 9
# Which policy status has the highest number of policies?
SELECT status,
       COUNT(*) AS POLICY_COUNT
       FROM policy_details
       GROUP BY status
       ORDER BY POLICY_COUNT DESC
       Limit 1;
      
# KPI 10
# What is the ratio between active policies and inactive policies?
SELECT CONCAT(COUNT(CASE WHEN status ='Active' THEN 1 END),
       ' : ',
       COUNT(CASE WHEN status IN ('Lapsed','Terminated') THEN 1 END))
       AS ACTIVE_INACTIVE_RATIO
       FROM policy_details;
      
# KPI 11
# Which age group has the highest number of policies?
SELECT 
    CASE 
        WHEN C.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN C.Age BETWEEN 31 AND 40 THEN '31-40'
        WHEN C.Age BETWEEN 41 AND 50 THEN '41-50'
        WHEN C.Age BETWEEN 51 AND 60 THEN '51-60'
        ELSE '60+'
    END AS AGE_GROUP,
    COUNT(P.`Policy ID`) AS POLICY_COUNT
FROM Customer_information C
JOIN Policy_Details P ON C.`Customer ID` = P.`Customer ID`
GROUP BY AGE_GROUP
ORDER BY POLICY_COUNT DESC
LIMIT 1;
  
# KPI 12
#Identify the top three age groups by policy count
SELECT 
    CASE 
        WHEN C.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN C.Age BETWEEN 31 AND 40 THEN '31-40'
        WHEN C.Age BETWEEN 41 AND 50 THEN '41-50'
        WHEN C.Age BETWEEN 51 AND 60 THEN '51-60'
        ELSE '60+'
    END AS AGE_GROUP,
    COUNT(P.`Policy ID`) AS POLICY_COUNT
FROM Customer_information C
JOIN Policy_Details P ON C.`Customer ID` = P.`Customer ID`
GROUP BY AGE_GROUP
ORDER BY POLICY_COUNT DESC
LIMIT 3;
    
# KPI 13
# Which gender has the highest policy participation?
  SELECT GENDER,
    COUNT(P.`Policy ID`) AS GENDER_PARTICIPATION
FROM Customer_information C
JOIN Policy_Details P ON C.`Customer ID` = P.`Customer ID`
GROUP BY GENDER
ORDER BY GENDER_PARTICIPATION DESC
LIMIT 1;
   
# KPI 14
# What is the difference between male and female policy counts?
SELECT ABS(
    COUNT(CASE WHEN C.GENDER = 'Male' THEN P.`Policy ID` END)
    -
    COUNT(CASE WHEN C.GENDER = 'Female' THEN P.`Policy ID` END)
) AS MALE_FEMALE_DIFFERENCE
FROM Customer_information C
JOIN Policy_Details P 
ON C.`Customer ID` = P.`Customer ID`;
   
# KPI 15
# Which policy type has the maximum number of policies?
SELECT `Policy Type`,
    COUNT(*) AS POLICY_COUNT
FROM Policy_Details
GROUP BY `Policy Type`
ORDER BY POLICY_COUNT DESC
LIMIT 1;

# KPI 16
# Which policy type has the minimum number of policies?
SELECT `Policy Type`,
    COUNT(*) AS POLICY_COUNT
FROM Policy_Details
GROUP BY `Policy Type`
ORDER BY POLICY_COUNT ASC
LIMIT 1; 
   
# KPI 17
# Compare Auto and Health policy counts
SELECT
    COUNT(CASE WHEN `Policy Type` = 'Auto' THEN 1 END) AS Auto_Policies,
    COUNT(CASE WHEN `Policy Type` = 'Health' THEN 1 END) AS Health_Policies
FROM policy_details;

# KPI 18
#What is the total number of policies across all policy types?
SELECT COUNT(*) AS Total_Policies
FROM policy_details;

# KPI 19
#What is the average premium growth rate over all years?
WITH YEARLY_PREMIUM AS (
    SELECT
        YEAR(`Policy Start Date`) AS POLICY_YEAR,
        AVG(`Premium Amount`) AS AVG_PREMIUM
    FROM Policy_Details
    GROUP BY YEAR(`Policy Start Date`)
),
PremiumGrowth AS (SELECT
        POLICY_YEAR,
        AVG_PREMIUM,
        LAG(AVG_PREMIUM) OVER (
            ORDER BY POLICY_YEAR
        ) AS PY_PREMIUM
    FROM YEARLY_PREMIUM
)
SELECT
    ROUND(AVG((AVG_PREMIUM - PY_PREMIUM) / PY_PREMIUM) * 100,2) AS AVG_PRE_GROWTHRATE
FROM PremiumGrowth
WHERE PY_PREMIUM IS NOT NULL;

# KPI 20
# Is the premium growth trend increasing or decreasing over time?

WITH YEARLY_PREMIUM AS (
    SELECT
        YEAR(`Policy Start Date`) AS POLICY_YEAR,
        AVG(`Premium Amount`) AS AVG_PREMIUM
    FROM Policy_Details
    GROUP BY YEAR(`Policy Start Date`)
),
PremiumGrowth AS (
    SELECT
        POLICY_YEAR,
        AVG_PREMIUM,
        LAG(AVG_PREMIUM) OVER (
            ORDER BY POLICY_YEAR
        ) AS PY_PREMIUM
    FROM YEARLY_PREMIUM
)
SELECT
    POLICY_YEAR,
    ROUND(
        ((AVG_PREMIUM - PY_PREMIUM) / PY_PREMIUM) * 100,
        2
    ) AS GROWTH_RATE
FROM PremiumGrowth
WHERE PY_PREMIUM IS NOT NULL
ORDER BY POLICY_YEAR;

# KPI 21
#Calculate the difference between the highest and lowest premium growth rates.
SELECT 
    ROUND(MAX(Growth_Rate) - MIN(Growth_Rate), 2)
    AS DIFFERENCE_HIGH_LOW_GROWTH
FROM ( SELECT
        Year,
        ROUND((Total_Premium - Previous_Premium) / Previous_Premium * 100,2) AS Growth_Rate
    FROM (
        SELECT YEAR(`Policy Start Date`) AS Year,
            SUM(`Premium Amount`) AS Total_Premium,
            LAG(SUM(`Premium Amount`))
            OVER (ORDER BY YEAR(`Policy Start Date`)) AS Previous_Premium
        FROM Policy_Details
        GROUP BY YEAR(`Policy Start Date`)
    ) AS yearly_premium
    WHERE Previous_Premium IS NOT NULL
) AS growth_data;

# KPI 22
#What is the yearly trend of policies ending from 2016 to 2034?
SELECT YEAR(`Policy End Date`) AS End_Year,
    COUNT(*) AS Policy_Count
FROM policy_details
WHERE YEAR(`Policy End Date`) BETWEEN 2016 AND 2034
GROUP BY YEAR(`Policy End Date`)
ORDER BY END_YEAR;
  