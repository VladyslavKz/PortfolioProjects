/* 
Dataset Overview: Gym Membership Information
--------------------------------------------
- Database: Portfolio_Projects
- Table: gym_membership
- Description: This dataset contains information about gym members, including demographics, attendance, and preferences.
- Number of records: 1000 records

Purpose of Analysis:
---------------------
This analysis will focus on:
- Demographic statistics and trends
- Membership engagement patterns by age and gender
- Membership type preferences and visit frequency
*/

--Import dataset to the MS SQL Server 
-- Check if data imported correctly

SELECT *
FROM Portfolio_Projects..gym_membership


SELECT *
FROM Portfolio_Projects..gym_membership
WHERE Age > 16 AND Age < 30
ORDER BY 1

--Check the entire table for any missing values
SELECT * 
FROM Portfolio_Projects..gym_membership 
WHERE id IS NULL
	OR gender IS NULL
	OR birthday Is NULL
	OR Age IS NULL
	OR abonoment_type IS NULL
	OR visit_per_week IS NULL
	OR days_per_week IS NULL
	OR attend_group_lesson IS NULL
	--OR fav_group_lesson IS NULL
	OR avg_time_check_in IS NULL
	OR avg_time_check_out IS NULL
	OR avg_time_in_gym IS NULL
	OR drink_abo IS NULL
	--OR fav_drink IS NULL
	OR personal_training IS NULL
	--OR name_personal_trainer IS NULL
	OR uses_sauna IS NULL

--We evaluated that there are 3 column with missing values(They are commented). 
--Analyzing those columns we can see that there is approximately 50% of missing values, so we decided not to use them in further analysis

--remove columns 

ALTER TABLE Portfolio_Projects..gym_membership
DROP COLUMN fav_group_lesson 

ALTER TABLE Portfolio_Projects..gym_membership
DROP COLUMN fav_drink

ALTER TABLE Portfolio_Projects..gym_membership
DROP COLUMN name_personal_trainer

--Check for duplicates

WITH Unque_id AS (
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY id
		ORDER BY id) AS row_num
	FROM Portfolio_Projects..gym_membership
)
SELECT *
FROM Unque_id
WHERE row_num > 1

--So, there are no duplicates
--Lets deep into our analysis

--TASK 1 
--to Perform Summary Statistics

SELECT
COUNT (*) AS Total_members,
AVG(Age) AS avg_age,
AVG(visit_per_week) as avg_visits,
AVG(avg_time_in_gym) as avg_duration_min
FROM Portfolio_Projects..gym_membership

--For visits and age lets check the mode

SELECT Top 1 Age,
	COUNT(Age) As freq
FROM Portfolio_Projects..gym_membership
GROUP BY Age
ORDER BY freq DESC

SELECT Top 1 visit_per_week,
	COUNT(visit_per_week) As freq
FROM Portfolio_Projects..gym_membership
GROUP BY visit_per_week
ORDER BY freq DESC
--there most frequently values is 36 for Age(37 times) and 3 visits per week (312 times)
/*The summary statistics show that the typical gym member is around the age of 36, and the average member attends the gym approximately 
three times per week. The mode values reinforce this, with 36 being the most common age and three visits per week being the most 
frequent attendance rate. This indicates that the gym’s primary demographic is mid-30s individuals who are moderately active, which 
could inform targeted engagement and program development for this core group.*/

--Task 2 Analyze Age Distribution and Segment Memberships by Age Group

--Calculate Age distribution of Gym members
SELECT Age,
       COUNT(Age) As age_distr
FROM Portfolio_Projects..gym_membership
GROUP BY Age
ORDER BY Age

--create age segments
SELECT 
    CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_range,
    COUNT(*) AS member_count
FROM Portfolio_Projects..gym_membership
GROUP BY CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END
ORDER BY age_range;

--Ñalculate the percentage for each age group
SELECT 
    CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_range,
    COUNT(*) AS age_distrib,
    CONCAT(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Portfolio_Projects..gym_membership), 1), '%') AS age_percentage
FROM Portfolio_Projects..gym_membership
GROUP BY CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END
ORDER BY age_percentage DESC;

/*The largest gym membership segments are ages 36–45 (27%) and 26–35 (26.8%), 
indicating strong interest from mid-career adults, while 18–25 (21.5%) also shows significant engagement. 
Older age groups (46+) represent a smaller but notable portion, suggesting opportunities for tailored offerings.
--Determine what percentage each age group represents within the total membership.*/

SELECT 
    CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_range,
	abonoment_type,
    COUNT(*) AS age_distrib,
    CONCAT(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Portfolio_Projects..gym_membership), 1), '%') AS age_percentage
FROM Portfolio_Projects..gym_membership
GROUP BY CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END, abonoment_type
ORDER BY age_distrib DESC;

/*The 26–35 and 36–45 age groups dominate both Standard and Premium memberships, collectively comprising around 53.8% of total memberships,
indicating strong engagement among mid-career adults. Younger members (18–25) and older members (56+) prefer Standard memberships slightly 
more than Premium, suggesting potential to encourage upgrades among these groups.*/

SELECT 
    CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_range,
	visit_per_week,
    COUNT(*) AS age_distrib,
    CONCAT(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Portfolio_Projects..gym_membership), 1), '%') AS age_percentage
FROM Portfolio_Projects..gym_membership
GROUP BY CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END, visit_per_week
ORDER BY age_distrib DESC;

/*The 26–35 and 36–45 age groups show the highest gym attendance, particularly with 2-3 visits per week, making up about 30% of total visits. 
Young adults (18–25) and older members (56+) show moderate attendance, mostly with 1-3 visits per week. The lower attendance frequency 
among the 46–55 group may suggest lower engagement, indicating potential for targeted initiatives to boost activity in this segment.*/


--Task 3 Identify and Categorize Membership Types

--Identify Membership Type Categories
SELECT DISTINCT(abonoment_type)
FROM Portfolio_Projects..gym_membership

SELECT abonoment_type,
COUNT(*) AS quantity
FROM Portfolio_Projects..gym_membership
GROUP BY abonoment_type

/*With 507 Standard members and 493 Premium members, there’s almost an equal preference, 
this balance may indicate that both membership offerings are well-aligned 
with customer needs and budget, attracting nearly equal interest.*/


--Analyze Membership Engagement Patterns of High-Frequency Users

SELECT 
    gender,
    abonoment_type,
    COUNT(abonoment_type) AS membership_count
FROM 
    Portfolio_Projects..gym_membership
--WHERE 
--	Age = 36
GROUP BY 
    gender, abonoment_type
ORDER BY 
    gender, membership_count DESC

/*This analysis suggests that both membership tiers are well-received across genders, 
with only slight differences in preference. The results support the idea of a well-balanced 
offering but also hint at subtle opportunities for targeted engagement and marketing based on gender. */

--CONCLUSION
/*The analysis of gym membership data reveals that the majority of members are aged 26–45, with a balanced preference between
Standard and Premium memberships. Both genders show similar engagement across membership types, with the highest gym attendance
occurring 2-3 times per week, particularly among mid-career adults. These findings suggest that the gym's offerings align well with 
member needs, especially for the 26–45 age group, while providing opportunities for targeted initiatives to engage younger and older
demographics more effectively.*/

