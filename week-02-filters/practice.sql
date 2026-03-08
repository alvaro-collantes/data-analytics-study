#Practice
USE sql_practice;

# Clients table
CREATE TABLE clients (
    client_id   INT PRIMARY KEY,
    client_name VARCHAR(100),
    country     VARCHAR(50),
    segment     VARCHAR(50)
);

INSERT INTO clients VALUES
(1, 'Renault', 'France', 'Large'),
(2, 'Fiat', 'Italy', 'Medium'),
(3, 'Siemens', 'Germany', 'Large');

#Credit Assessments table
CREATE TABLE credit_assessments (
    assessment_id   INT PRIMARY KEY,
    client_id       INT,
    assessment_date DATE,
    credit_limit    INT,
    status          VARCHAR(50),
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

INSERT INTO credit_assessments VALUES
(101, 1, '2024-01-15', 500000, 'Approved'),
(102, 2, '2024-02-10', 150000, 'Rejected'),
(103, 3, '2024-02-20', 800000, 'Approved');

#Claims table
CREATE TABLE claims (
    claim_id     INT PRIMARY KEY,
    client_id    INT,
    claim_date   DATE,
    claim_amount INT,
    claim_status VARCHAR(50),
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

INSERT INTO claims VALUES
(201, 1, '2024-03-01', 20000, 'Paid'),
(202, 2, '2024-04-15', 35000, 'Pending'),
(203, 3, '2024-03-22', 60000, 'Paid');

#Additional
#New client with no assessment
INSERT INTO clients VALUES (4, 'Peugeot', 'France', 'Small');

#Explore data
#clients
select *
from clients;
#credit_assessments
select *
from credit_assessments;
#claims
select *
from claims;

# Exercise 1 — Basic aggregation
#Find the total claim amount per client name. Only show clients who have at least one claim.

select client_name, sum(claim_amount) as total_claim_amount
from claims cla
join clients cli
	on cla.client_id = cli.client_id
where cla.client_id >= 1
group by client_name; 

#Join: merge both tables, all columns in the same table where they match
#indicate each table with a prefix
#where: goes after join
#If you use an agg function, you need to group by

#Better solution 
SELECT cli.client_name, SUM(cla.claim_amount) AS total_claim_amount
FROM claims cla
JOIN clients cli ON cla.client_id = cli.client_id
GROUP BY cli.client_name;
#improvements:
#name the prefix of each table for each column
#when you make the join, it is not necessary the where 
    

#Exercise 2 — LEFT JOIN + COALESCE
#List all clients with their total credit limit. If a client has no credit assessment, show 0 instead of NULL.

select client_name, sum(credit_limit) as total_credit_limit 
from clients cli
left join credit_assessments cre
on cli.client_id = cre.client_id
where status != 'Rejected'
group by client_name;

#Better solution

#use of coalsece, verification
SELECT cli.client_name,
       SUM(cre.credit_limit) AS total_credit_limit
FROM clients cli
LEFT JOIN credit_assessments cre ON cli.client_id = cre.client_id
GROUP BY cli.client_name;

#see the change
SELECT cli.client_name,
       COALESCE(SUM(cre.credit_limit), 0) AS total_credit_limit
FROM clients cli
LEFT JOIN credit_assessments cre ON cli.client_id = cre.client_id
GROUP BY cli.client_name;

#Improvements: 
#where filter after the join, and eliminates the effect of the left join 
#use of coalesce for replace a null value 


#Exercise 3 — CASE WHEN
#For each claim, add a column called urgency that says 'High' if claim_amount > 30000, and 'Normal' otherwise.

select *, 
case
when claim_amount > 30000 then 'High' else 'Normal' 
end as urgency
from claims;

#Exercise 4 — WHERE vs HAVING
#Count the number of Approved assessments per country. Only show countries where that count is at least 1.

select country, 
sum(case
when status = 'Approved' then 1 else 0 end) as approved_assessments
from credit_assessments cre
join clients cli
on cre.client_id = cli.client_id
group by country
having approved_assessments >=1 ;

#better solution 
SELECT cli.country, COUNT(cre.assessment_id) AS approved_assessments
FROM credit_assessments cre
JOIN clients cli ON cre.client_id = cli.client_id
WHERE cre.status = 'Approved'
GROUP BY cli.country
HAVING approved_assessments >= 1;

#use where for the count of the assessment_id, more simple than use of when

#Practice

#LEFT JOIN + COALESCE
#Exercise A
#List all clients with the total number of claims they have made. If a client has no claims, show 0 instead of NULL.
#clients
select* 
from clients;
#claims
select* 
from claims;
#query (count)
select cli.client_name, count(cla.client_id) as total_claims
from clients cli
left join claims cla
on cli.client_id = cla.client_id
group by cli.client_name;

#query (coalesce)
select cli.client_name, coalesce(count(cla.client_id),0) as total_claims
from clients cli
left join claims cla
on cli.client_id = cla.client_id
group by cli.client_name;

#same result, is it necessary the coalesce in this case?

#Exercise B
#Show all clients with their highest claim amount (MAX). If a client has no claims, show 0.
#left join + coalesce
select cli.client_name, coalesce(max(cla.claim_amount),0) as total_claim_amount
from clients cli
left join claims cla
on cli.client_id = cla.client_id
group by cli.client_name;
#shows all clients

#join 
select cli.client_name,max(cla.claim_amount) as total_claim_amount
from clients cli
join claims cla
on cli.client_id = cla.client_id
group by cli.client_name;
#shows just the clients with values 

#Why is necessary the left join, when use it and when use join? 
#It is because it says: Show all clients with their highest claim amount (MAX)

#WHERE vs HAVING
#Exercise A
#Find the total claim_amount per client, but only counting claims with status 'Paid'. Only show clients whose total is greater than 10000.
select * from clients;
select * from claims;

select client_name, sum(cla.claim_amount) as total_claim_amount
from clients cli
join claims cla
on cli.client_id = cla.client_id
where cla.claim_status = 'Paid'
group by client_name
having total_claim_amount > 10000;
#Because it says Only show clients whose total is greater than 10000, i have to use just Join instead of left join?
#It is missing the > 10000

#Exercise B
#Count how many assessments each country has. Exclude assessments with status 'Rejected' and only show countries with more than 0 assessments. 
select * from clients;
select * from credit_assessments;

#query
select country, count(*) as total_assessments
from clients cli 
left join credit_assessments cre
on cli.client_id = cre.client_id
where cre.status = 'Approved'
group by country
having total_assessments > 0 ;

#With where, removes the left join, so it is better just a join
#remember: "It says show ALL clients" → LEFT JOIN. "Only clients with values" → INNER JOIN.
#Fix version
SELECT cli.country, COUNT(*) AS total_assessments
FROM clients cli
JOIN credit_assessments cre ON cli.client_id = cre.client_id
WHERE cre.status = 'Approved'
GROUP BY cli.country
HAVING total_assessments > 0;

# CASE WHEN combined
#Exercise A
#For each client, show their name, their credit_limit, and a column called risk_level that says:
#'High Risk' if credit_limit < 200000
#'Medium Risk' if credit_limit is between 200000 and 600000
#'Low Risk' if credit_limit > 600000

select * from clients;
select * from credit_assessments;

select cli.client_name, cre.credit_limit,
case 
when cre.credit_limit < 200000 then 'High Risk'
when cre.credit_limit between 200000 and 600000 then 'Medium Risk'
when cre.credit_limit > 600000 then 'Low Risk'
end as risk_level
from clients cli
 join credit_assessments cre
on cli.client_id = cre.client_id
group by cli.client_name, cre.credit_limit;

#there is one client (peugeot) that doesnt have info in the credit assessment table. It is better doesnt add it. So use Join
#dont use group by, there is no agg funct

#Exercise B
#For each claim, show the claim_id, claim_amount, claim_status, and a column called action that says:
#'Follow Up' if status is 'Pending'
#'Closed' if status is 'Paid'
#'Review' for any other case

select* from claims;

select claim_id, claim_amount,claim_status,
case
when claim_status = 'Pending' then 'Follow Up' 
when claim_status = 'Paid' then 'Closed' else 'Review' end as action
from claims;

#Exercise A — This query has 1 bug, find and fix it:
SELECT cli.client_name, SUM(cla.claim_amount) AS total_claims
FROM clients cli
JOIN claims cla ON cli.client_id = cla.client_id
WHERE SUM(cla.claim_amount) > 30000
GROUP BY cli.client_name;

#WHERE SUM(cla.claim_amount) > 30000. An agg function should be used with a group by, not in the where clause. It should be in a having
#Fix version
SELECT cli.client_name, SUM(cla.claim_amount) AS total_claims
FROM clients cli
JOIN claims cla ON cli.client_id = cla.client_id
GROUP BY cli.client_name
having SUM(cla.claim_amount) > 30000;

#Exercise B — This query has 2 bugs, find and fix them:
SELECT cli.country, COUNT(cre.assessment_id) AS total_assessments
FROM credit_assessments cre
JOIN clients cli ON cre.client_id = cli.client_id
GROUP BY cli.country
WHERE cre.status = 'Approved'
HAVING total_assessments > 0;

#where should be before the group by, not after.
#The join should be in the other way, first the clients table join to the credit table 
#Fixed version
SELECT cli.country, COUNT(cre.assessment_id) AS total_assessments
FROM clients cli
JOIN credit_assessments cre ON cre.client_id = cli.client_id
WHERE cre.status = 'Approved'
GROUP BY cli.country
HAVING total_assessments > 0;
#second bug, is the alias in having, it has to be the expression
#group by goes when there are AGG FUNC in the select, if there are no agg func or if there is a case when, it is not necessary

#Practice 2

#Exercise 1
#Show each country with the total number of claims made by clients from that country. Only show countries with more than 1 claim total.
select * from clients;
select * from claims;

select cli.country, count(cla.claim_id) as total_claims
from clients cli
join claims cla
on cli.client_id = cla.client_id
group by cli.country
having count(cla.claim_id) > 1;

#Justification
#Columns to show: country and total number of claims (agg funct)
#Tables:clients and claims (relation by client_id)
#Conditions to show: countries with more than 1 claim total (more than x = greater than x = > x), condition on agg function, use having

#Exercise 2
#For each segment, show the average credit limit. Only include approved assessments. Round the result to 2 decimals. (Hint: MySQL uses ROUND(value, 2))
select * from clients;
select* from credit_assessments;

select cli.segment, round(avg(credit_limit),2) as avg_credit_limit
from clients cli
join credit_assessments cre
on cli.client_id = cre.client_id
where cre.status = 'Approved'
group by cli.segment;

#Justification
#columns:segment, avg credit limit (agg func)
#tables: clients, credit_assessments (relation by client_id)
#Conditions to show: for each segment(need all, so left join), only approved (filter on status) and round(val,2). Where breaks the left join

#Exercise 3
#Show all clients with the total amount of their PAID claims only. If a client has no paid claims, show 0. Order the results from highest to lowest. (Hint: WHERE will break your LEFT JOIN — think about where to filter)

select * from claims;

select cli.client_name, coalesce(sum(cla.claim_amount),0) as total_claim_amount
from clients cli
join claims cla
on cli.client_id = cla.client_id
where cla.claim_status = 'Paid'
group by cli.client_name
order by sum(cla.claim_amount) desc;

#Justification
#Columns:client_name, total clame_amount (sum, agg funct)
#Tables: clients, claims (client_id)
#Conditions: all clients (left join) , on paid (filter on claim_status), if has no paid, show 0 (coalesce) and order
#says all and filter on one column, making this will break the left join, so use join and filter, it was missing the coalesce

#Exercise 4
#List all clients with the number of assessments they have. Include clients with no assessments and show 0 for them. Only show clients from France or Germany.

select * from credit_assessments;
select * from clients;

select cli.client_name, coalesce(count(cre.client_id),0) as total_assessments
from clients cli
left join credit_assessments cre
on cli.client_id = cre.client_id
where cli.country IN('Germany','France')
group by cli.client_name
;
#justification
#columns:client_name, count(client_id) (agg funct)
#tables:clients, credit_assessments
#conditions: all clients(left join) , show with no assessments and put 0 show from france or germany

#Exercise 5
#Find the total claim amount per country, but only for claims that are 'Paid'. Only show countries where the total is above 20000.
select* from claims;

select cli.country, sum(cla.claim_amount) as total_claim_amount
from clients cli
join claims cla
on cli.client_id = cla.client_id
where cla.claim_status = 'Paid'
group by cli.country
having sum(cla.claim_amount) > 20000;

#justification
#columns: country, total claim amount(agg)
#tables:clients, claims
#cond: status(filter paid), total claim amount > 20000, join

#Exercise 6
#Count the number of claims per client. Exclude 'Pending' claims. Only show clients who have more than 0 paid claims. Show the result ordered by count descending.

select * from claims;

select cli.client_name, count(cla.client_id) as total_number_claims
from clients cli
join claims cla
on cli.client_id = cla.client_id
where cla.claim_status != 'Pending'
group by cli.client_name
having count(cla.client_id) > 0
order by count(cla.client_id) desc; 

#justificacion
#columns: client_name, total number of claims
#table: clients, claims
#conditions: status (excluding pending), only show(join) > 0paid claims, order by count desc

#Exercise 7
#Show all assessments with client name, credit limit, status, and a column called review_needed that says:
#'Yes' if status is 'Rejected'
#'No' for anything else

select cli.client_name, cre.credit_limit, cre.status,
case
when cre.status = 'Rejected' then 'Yes' else 'No' end as review_needed
from credit_assessments cre
join clients cli
on cli.client_id = cre.client_id
;

#justification
#columns: client name, credit limit, status, review_needed
#table: client, credit_assessments
#cond: the case statements, all assessments so left , it is ok just join

#Exercise 8
#Show each client name, their total claim amount, and a column called client_health that says:
#'Critical' if total claims > 50000
#'Watch' if total claims is between 20000 and 50000
#'Good' if total claims < 20000
#'No Claims' if the client has no claims at all

select cli.client_name, sum(cla.claim_amount) as total_claim_amount, 
case 
when sum(cla.claim_amount) > 50000 then 'Critical'
when sum(cla.claim_amount)  between 20000 and 50000 then 'Watch'
when sum(cla.claim_amount)  < 20000 then 'Good' else 'No Claims'
end as client_health
from clients cli
left join claims cla
on cli.client_id = cla.client_id
group by cli.client_name;

#justification
#col:client name, total claim amount, client health with case when cond
#tab: client, claims
#Cond: case when, each client, left join

#Exercise 9 — Fix the bug
#This query works in MySQL but would fail in Snowflake. Find why and fix it:
`SELECT cli.client_name, SUM(cla.claim_amount) AS total_claims
FROM clients cli
JOIN claims cla ON cli.client_id = cla.client_id
GROUP BY cli.client_name
HAVING total_claims > 30000;`

#because in the having is the alias, it must be the expression

#Exercise 10 — Fix the 2 bugs
#This query has 2 bugs. Find and fix both:

`SELECT cli.client_name, AVG(cre.credit_limit) AS avg_limit
FROM clients cli
LEFT JOIN credit_assessments cre ON cli.client_id = cre.client_id
WHERE cre.status = 'Approved'
GROUP BY cli.client_name
HAVING avg_limit > 100000;`

# you cant use the left join and the where because it wont return the correct values by the filter
# in the having is the alias instead the expression

#LEFT JOIN VS JOIN Which one do i have to use?
#Do I want to keep rows from the left table even if there's NO match in the right table?
#Yes, keep ALL rows from left table, use LEFT JOIN (it says expressions as all clients or include clients with no...)
#No, only rows that match in both tables, use INNER JOIN (it says expressions as only clients who have or find clients with)

#Common mistake LEFT JOIN + WHERE
#Do I want to keep rows from the left table even if there's NO match in the right table?
#Yes, use the left Join and the where goes the filter? 
#On left table? the filter with where referencing to the left table. It keeps all the rows of the left table
#On right table? the filter goes in the ON , using And condition, otherwise it will remove all the rows of the left table, and breaks the 
#left join, and acts as a Join

#LEFT JOIN vs INNER JOIN
#Keep ALL rows from left table (even no match)? UseLEFT JOIN
#Keywords: "all clients", "include clients with no..."
#Only matching rows in both tables? Use INNER JOIN
#Keywords: "only clients who have...", "find clients with..."

#LEFT JOIN + Filter rule
#Filter on LEFT table?. WHERE is safe 
#Filter on RIGHT table?. Move to ON with AND 
#Filter on RIGHT table with WHERE?. Breaks LEFT JOIN 
#(acts as INNER JOIN, NULLs are eliminated)

#One rule to remember: WHERE kills NULLs. ON keeps them.

#Window Functions
#Regular aggregate functions (SUM, COUNT) collapse rows into one result per group. Window functions keep all rows but add a calculation alongside each row.
#FUNCTION() OVER (
    #PARTITION BY column    -- "group by" for window functions
    #ORDER BY column        -- order within each partition
#)
#Make calculations in the same group, without transforming the table in one single category, gives each line of the same group a calculation adding the previous 
#it is like a acumulated group by
USE sql_practice;
select * from claims;
-- GROUP BY collapses rows
SELECT client_id, SUM(claim_amount)
FROM claims
GROUP BY client_id;
-- Result: 2 rows (one per client)

-- Window function keeps all rows
SELECT client_id, claim_amount,
SUM(claim_amount) OVER (PARTITION BY client_id) AS total_per_client
FROM claims;
-- Result: 3 rows (all claims, with total alongside)

#Uses
#partition makes a reset to each new category line
#Example 1 — ROW_NUMBER
#Assigns a unique number to each row within a partition:
-- Number each claim per client, ordered by date
SELECT cli.client_name, cla.claim_id, cla.claim_date, cla.claim_amount,
ROW_NUMBER() OVER (PARTITION BY cli.client_name ORDER BY cla.claim_date) AS claim_number
FROM claims cla
JOIN clients cli ON cla.client_id = cli.client_id;

#Example 2 — RANK
#Like ROW_NUMBER but ties get the same rank:
-- Rank clients by their credit limit
SELECT cli.client_name, cre.credit_limit,
RANK() OVER (ORDER BY cre.credit_limit DESC) AS credit_rank
FROM credit_assessments cre
JOIN clients cli ON cre.client_id = cli.client_id;

#DENSE_RANK — ties share a rank, next rank doesn't skip (1,2,2,3)
SELECT cli.client_name, cre.credit_limit,
DENSE_RANK() OVER (ORDER BY cre.credit_limit DESC) AS credit_rank
FROM credit_assessments cre
JOIN clients cli ON cre.client_id = cli.client_id;

#Example 3 — SUM OVER (Running Total)
#Adds up values progressively row by row:
-- Running total of claims ordered by date (Cumulative sum)
SELECT cli.client_name, cla.claim_date, cla.claim_amount,
SUM(cla.claim_amount) OVER (ORDER BY cla.claim_date) AS running_total
FROM claims cla
JOIN clients cli ON cla.client_id = cli.client_id;

#Example 4 — SUM OVER with PARTITION BY
#Running total reset per client:

SELECT cli.client_name, cla.claim_date, cla.claim_amount,
SUM(cla.claim_amount) OVER (
    PARTITION BY cli.client_name
    ORDER BY cla.claim_date
) AS running_total_per_client
FROM claims cla
JOIN clients cli ON cla.client_id = cli.client_id;

#Exercises
#Exercise 1 — ROW_NUMBER
#Number each claim per country, ordered by claim_amount descending. Show client_name, country, claim_amount and the row number.
select * from clients;
#query
select cli.client_name, cli.country,  cla.claim_amount ,
row_number() over(partition by cli.client_name order by cla.claim_amount desc) as claim_number
from clients cli
left join claims cla
on cli.client_id = cla.client_id
;
#fix: the partition should be by COUNTRY not name client name. Also, use just join, to avoid show the null
#why use just join? because the exercise says Number each claim per country, the claims are from the right table, 
# if it says Show all clients with their claims, will be the left join
select cli.client_name, cli.country,  cla.claim_amount ,
row_number() over(partition by cli.country order by cla.claim_amount desc) as claim_number
from clients cli
join claims cla
on cli.client_id = cla.client_id
;
#Exercise 2 — RANK
#Rank all clients by their total claim amount (highest first). Show client_name, total claim amount and their rank. Clients with no claims should not appear.
use sql_practice;
select * from claims;

select cli.client_name, cla.claim_amount, 
rank()over(order by cla.claim_amount desc) as rank_claim
from clients cli
left join claims cla 
on cli.client_id = cla.client_id and cla.client_id > 0
;
#It needs subqueries

#Exercise 3 — Running Total
#Show a running total of claim amounts ordered by claim_date. Show claim_id, claim_date, claim_amount and the running total.
use sql_practice;
select claim_id, claim_date, claim_amount,
sum(claim_amount) over (order by claim_date) as run_total
from claims; 
#Ok
select * from claims;

#Exercise 4 — PARTITION BY
#For each claim, show the client_name, claim_amount, and the total claim amount for that client alongside each row 
#(not a running total — the full total for that client on every row).

select cli.client_name, cla.claim_amount,
sum(cla.claim_amount) over(partition by cli.client_name order by cla.claim_date) as run_total_client
from clients cli
left join claims cla
on cli.client_id = cla.client_id;
#It says: not a running total — the full total for that client on every row, means that it is not necessary the order by inside the over. I need the full sum
#by each row, so it is not needed the order. Use join, because the subject is claims that is in the right table, not clients
#Fixed
SELECT cli.client_name, cla.claim_amount,
SUM(cla.claim_amount) OVER(PARTITION BY cli.client_name) AS total_per_client
FROM clients cli
JOIN claims cla ON cli.client_id = cla.client_id;

#subqueries

SELECT client_name, total_claims,
  CASE
    WHEN total_claims > 50000 THEN 'Critical'
    WHEN total_claims BETWEEN 20000 AND 50000 THEN 'Watch'
    ELSE 'Good'
  END AS health
FROM (
  SELECT cli.client_name, SUM(cla.claim_amount) AS total_claims
  FROM clients cli
  JOIN claims cla ON cli.client_id = cla.client_id
  GROUP BY cli.client_name
) AS totals;

SELECT country,
  SUM(CASE WHEN status = 'Approved' THEN 1 ELSE 0 END) AS approved_count
FROM credit_assessments cre
JOIN clients cli ON cre.client_id = cli.client_id
GROUP BY country;

SELECT country,
  SUM(CASE WHEN status = 'Approved' THEN 1 ELSE 0 END) AS approved_count
FROM clients cli
JOIN credit_assessments cre ON cre.client_id = cli.client_id
GROUP BY country;

SELECT country,
  SUM(CASE WHEN status = 'Approved' THEN 1 ELSE 0 END) AS approved_count,
  SUM(CASE WHEN status = 'Rejected' THEN 1 ELSE 0 END) AS rejected_count,
  COUNT(*) AS total_assessments
FROM clients cli
JOIN credit_assessments cre ON cli.client_id = cre.client_id
GROUP BY country;

-- Use CASE WHEN on a SUM result (needs subquery or window function)
SELECT client_name, total_claims,
  CASE
    WHEN total_claims > 50000 THEN 'Critical'
    WHEN total_claims BETWEEN 20000 AND 50000 THEN 'Watch'
    WHEN total_claims < 20000 THEN 'Good'
    ELSE 'No Claims'
  END AS health
FROM (
  SELECT cli.client_name, COALESCE(SUM(cla.claim_amount), 0) AS total_claims
  FROM clients cli
  LEFT JOIN claims cla ON cli.client_id = cla.client_id
  GROUP BY cli.client_name
) AS totals;

 -- Find all claims above the average claim amount
SELECT claim_id, client_id, claim_amount
FROM claims
WHERE claim_amount > (
  SELECT AVG(claim_amount)   -- runs first, returns one number (38333)
  FROM claims
);

SELECT AVG(claim_amount)   -- runs first, returns one number (38333)
  FROM claims;
  
  SELECT cli.client_name, cla.claim_amount
FROM claims cla
JOIN clients cli ON cla.client_id = cli.client_id
WHERE cla.claim_amount > (
    SELECT AVG(cla2.claim_amount)
    FROM claims cla2
    JOIN clients cli2 ON cla2.client_id = cli2.client_id
    WHERE cli2.country = 'France'
);

SELECT cli.client_name, cre.credit_limit,
  RANK()       OVER(ORDER BY cre.credit_limit DESC) AS rnk,
  DENSE_RANK() OVER(ORDER BY cre.credit_limit DESC) AS dense_rnk
FROM credit_assessments cre
JOIN clients cli ON cre.client_id = cli.client_id;

#Practice with more data

USE sql_practice;

-- Clear existing data first
DELETE FROM claims;
DELETE FROM credit_assessments;
DELETE FROM clients;

-- CLIENTS — 8 rows
INSERT INTO clients VALUES
(1, 'Renault',        'France',      'Large'),
(2, 'Fiat',          'Italy',       'Medium'),
(3, 'Siemens',       'Germany',     'Large'),
(4, 'Peugeot',       'France',      'Small'),
(5, 'Volkswagen',    'Germany',     'Large'),
(6, 'Airbus',        'France',      'Large'),
(7, 'Ferrero',       'Italy',       'Medium'),
(8, 'BASF',          'Germany',     'Small');

-- CREDIT ASSESSMENTS — 8 rows
INSERT INTO credit_assessments VALUES
(101, 1, '2024-01-15', 500000,  'Approved'),
(102, 2, '2024-02-10', 150000,  'Rejected'),
(103, 3, '2024-02-20', 800000,  'Approved'),
(104, 4, '2024-03-05', 90000,   'Approved'),
(105, 5, '2024-03-18', 950000,  'Approved'),
(106, 6, '2024-04-02', 600000,  'Approved'),
(107, 7, '2024-04-15', 200000,  'Rejected'),
(108, 8, '2024-05-01', 120000,  'Approved');

-- CLAIMS — 12 rows (spread across clients and dates)
INSERT INTO claims VALUES
(201, 1, '2024-03-01', 20000,  'Paid'),
(202, 1, '2024-04-15', 35000,  'Pending'),
(203, 3, '2024-03-22', 60000,  'Paid'),
(204, 5, '2024-04-10', 45000,  'Paid'),
(205, 5, '2024-05-20', 80000,  'Paid'),
(206, 6, '2024-04-28', 15000,  'Pending'),
(207, 6, '2024-06-10', 55000,  'Paid'),
(208, 3, '2024-05-14', 30000,  'Pending'),
(209, 1, '2024-06-01', 25000,  'Paid'),
(210, 7, '2024-06-15', 10000,  'Paid'),
(211, 4, '2024-07-03', 42000,  'Pending'),
(212, 5, '2024-07-18', 70000,  'Paid');

 #Window Functions Exercises

#Exercise 1
#Show each claim with its claim_id, client_name, claim_amount, and a row number ordered by claim_amount descending across all claims

select cla.claim_id,cli.client_name,cla.claim_amount,
row_number() over(order by cla.claim_amount desc) as row_n
from clients cli
join claims cla on cli.client_id = cla.client_id;
#It says across all the claims (just order by) and each claim (use join)
#Exercise 2
#For each client show their claim_id, claim_date, claim_amount, and a running total of their claims ordered by claim_date. Reset the total per client.

select cla.claim_id,cli.client_name,cla.claim_date,cla.claim_amount,
sum(cla.claim_amount) over(partition by cli.client_name order by cla.claim_date) as running_total
from clients cli
join claims cla on cli.client_id = cla.client_id; 

#it says for each client show. Should be left?  but with claim id there are null. But i have all the names, it looks better without those nulls
#Also, it says running total of their claims, means the sum or the count? I think it make more sense the sum than the count

#Exercise 3
#Rank all clients by their total credit limit from highest to lowest. Show client_name, credit_limit and the rank. (Hint: you need a subquery)

select client_name, total_credit_limit,
rank() over(order by total_credit_limit desc) as rnk
from( 
select cli.client_name, sum(cre.credit_limit) as total_credit_limit
from clients cli
join credit_assessments cre on cli.client_id = cre.client_id
group by cli.client_name) as sub_aggfunc;
#In the outquery it must be the columns names without the prefix
#rank all clients by their total credit limit: implies only clients who have a credit assessment. Clients with no assessment have no credit limit to rank. So INNER JOIN is correct.

#Exercise 4
#For each claim show client_name, country, claim_amount, and rank the claims within each country by claim_amount descending.

select cli.client_name, cli.country, cla.claim_amount, 
rank() over(partition by cli.country order by cla.claim_amount desc) as rnk
from clients cli
join claims cla on cli.client_id = cla.client_id;

#it says for each claim , so it is join, keep second table
#it says rank within country so, partitio by and the order by the claim amount
#Exercise 5
#Show each client's name, claim_amount, and alongside each row show both the client's total claims AND the running total across all claims ordered by claim_date.

select cli.client_name, cla.claim_amount,
sum(cla.claim_amount) over(order by cla.claim_date) as running_total_claims,
sum(cla.claim_amount) over(partition by cli.client_name) as full_total_claims
from clients cli
join claims cla on cli.client_id = cla.client_id;
#cumulative total per client, no reset
#Exercise 6
#Show the top 1 claim per client — the highest claim amount per client. Show client_name, claim_id and claim_amount. 

SELECT client_name, claim_id, claim_amount
FROM (
    SELECT cli.client_name, cla.claim_id, cla.claim_amount,
        ROW_NUMBER() OVER(
            PARTITION BY cli.client_name
            ORDER BY cla.claim_amount DESC  
        ) AS rnk
    FROM clients cli
    JOIN claims cla ON cli.client_id = cla.client_id
) AS ranked
WHERE rnk = 1;

#get the row number part as subquery, after that put it inside a outer query with condition on the row number
#innter query inside and outer query outside

#Exercise 7
#For each country show the monthly total claim amount, the previous month's total using LAG(), and the difference between the two.

SELECT year_month, country, monthly_total,
    LAG(monthly_total) OVER(
        PARTITION BY country
        ORDER BY year_month
    ) AS prev_month_total,
    monthly_total - LAG(monthly_total) OVER(
        PARTITION BY country
        ORDER BY year_month
    ) AS difference
FROM (
    SELECT DATE_FORMAT(cla.claim_date, '%Y-%m') AS year_month,
        cli.country,
        SUM(cla.claim_amount) AS monthly_total
    FROM claims cla
    JOIN clients cli ON cla.client_id = cli.client_id
    GROUP BY DATE_FORMAT(cla.claim_date, '%Y-%m'), cli.country
) AS monthly
ORDER BY country, year_month;

#Exercise 8
#Show each client's name, their total claim amount, their rank among all clients, and a column called vs_average that says 'Above' if their total is above the average total claim amount, and 'Below' otherwise. (Hint: subquery + window function + CASE WHEN)

SELECT client_name, total_claims,
    RANK() OVER(ORDER BY total_claims DESC) AS rnk,
    CASE
        WHEN total_claims > AVG(total_claims) OVER() THEN 'Above'
        ELSE 'Below'
    END AS vs_average
FROM (
    SELECT cli.client_name,
        SUM(cla.claim_amount) AS total_claims
    FROM clients cli
    JOIN claims cla ON cli.client_id = cla.client_id
    GROUP BY cli.client_name
) AS totals;

#Exercise 9
#For each client show their name, each claim_amount, the running total per client, and a column called threshold_status that says 'Under 40k' if the running total is below 40000, 'Over 40k' if above. Order by client_name and claim_date

SELECT cli.client_name, cla.claim_amount,
    SUM(cla.claim_amount) OVER(
        PARTITION BY cli.client_name
        ORDER BY cla.claim_date
    ) AS running_total,
    CASE
        WHEN SUM(cla.claim_amount) OVER(
            PARTITION BY cli.client_name
            ORDER BY cla.claim_date
        ) < 40000 THEN 'Under 40k'
        ELSE 'Over 40k'
    END AS threshold_status
FROM clients cli
JOIN claims cla ON cli.client_id = cla.client_id
ORDER BY cli.client_name, cla.claim_date;

SELECT DISTINCT cli.country
FROM clients cli
JOIN credit_assessments cre ON cli.client_id = cre.client_id;

SELECT DATE_FORMAT(claim_date, '%Y-%m') AS years_months
FROM claims;

SELECT YEAR(claim_date) AS claim_year,
  SUM(claim_amount) AS total_amount
FROM claims
GROUP BY YEAR(claim_date)
ORDER BY claim_year;

SELECT year_months, monthly_total,
  LAG(monthly_total) OVER(ORDER BY year_months) AS prev_month_total,
  monthly_total - LAG(monthly_total) OVER(ORDER BY year_months) AS difference
FROM (
  SELECT DATE_FORMAT(claim_date, '%Y-%m') AS year_months,
    SUM(claim_amount) AS monthly_total
  FROM claims
  GROUP BY DATE_FORMAT(claim_date, '%Y-%m')
) AS monthly_totals
ORDER BY year_months;

#Easy
#DISTINCT — E1
#List all unique countries that have at least one client with an Approved assessment.

select distinct cli.country 
from clients cli
join credit_assessments cre on cli.client_id = cre.client_id
where cre.status = 'Approved';

#Date Aggregations — E2
#Show the total claim amount per month. Display year_month and total_amount, ordered by month.

select date_format(claim_date,'%Y-%m') as year_months, sum(claim_amount) as total_claim
from claims 
group by date_format(claim_date,'%Y-%m')
order by date_format(claim_date,'%Y-%m');

#Pivoting — E3
#For each country show the number of Approved and Rejected assessments as separate columns.

select cli.country,
sum(case when cre.status = 'Approved' then 1 else 0 end) as approved_assessments,
sum(case when cre.status = 'Rejected' then 1 else 0 end) as rejected_assessments
from clients cli
join credit_assessments cre on cli.client_id = cre.client_id
group by cli.country;

#CTE — E4
#Using a CTE, find all clients whose total claim amount is above 50000. Show client_name and total_claims.
with clients_claim as (
select cli.client_name, sum(cla.claim_amount) as total_claims
from clients cli
join claims cla on cli.client_id = cla.client_id
group by cli.client_name
)
select client_name, total_claims
from clients_claim
where total_claims > 50000;

#in the the last select, dont add the prefix
#use where in the outside query instead of having inside, is better, you can call the column by the alias

#medium
#DISTINCT — M1
#Count how many unique countries have clients who have filed at least one Paid claim.

select cli.client_name,count(distinct cli.country) as unique_countries,
sum(case when cla.claim_status = 'Paid' then 1 else 0 end) as paid_claim
from clients cli
join claims cla on cli.client_id = cla.client_id
group by cli.client_name
having paid_claim > 1;
#always return 1, there is a best approach and correct too

SELECT COUNT(DISTINCT cli.country) AS unique_countries
FROM clients cli
JOIN claims cla ON cli.client_id = cla.client_id
WHERE cla.claim_status = 'Paid';

#Date Aggregations — M2
#Show for each client the total claims per month. Only show months where the client's total is above 20000.

select cli.client_name, month(cla.claim_date) as months, sum(cla.claim_amount) as total_amount
from clients cli
join claims cla on cli.client_id = cla.client_id
group by cli.client_name, month(cla.claim_date)
having sum(cla.claim_amount) > 20000;
#it is better to use date_format to keep the years in case, there are more years and then using month, it will be merged
#and add order by , because there are dates

SELECT cli.client_name,
    DATE_FORMAT(cla.claim_date, '%Y-%m') AS year_months,
    SUM(cla.claim_amount) AS total_amount
FROM clients cli
JOIN claims cla ON cli.client_id = cla.client_id
GROUP BY cli.client_name, DATE_FORMAT(cla.claim_date, '%Y-%m')
HAVING SUM(cla.claim_amount) > 20000
ORDER BY cli.client_name, year_months;

#Pivoting — M3
#For each client show their total Paid amount and total Pending amount as separate columns. Include all clients even with no claims.

select cli.client_name, 
sum(case when cla.claim_status = 'Paid' then cla.claim_amount else 0 end) as paid_status,
sum(case when cla.claim_status = 'Pending' then cla.claim_amount else 0 end) as pending_status
from clients cli
left join claims cla on cli.client_id = cla.client_id
group by cli.client_name;

#CTE — M4
#Using a CTE, rank all clients by their total claim amount. Show client_name, total_claims and their rank. Only show clients who have made at least one claim.

with rank_table as (
select cli.client_name, sum(cla.claim_amount) as total_claim
from clients cli
join claims cla on cli.client_id = cla.client_id
group by cli.client_name)
select client_name, total_claim, 
rank() over(order by total_claim desc) as rnk
from rank_table;

#it was missing the order, desc

#DISTINCT — H1
#Show all clients who have filed claims in more than one distinct month. Show client_name and the count of distinct months.

select cli.client_name, count(distinct(date_format(cla.claim_date,'%Y-%m'))) as distinc_months
from clients cli
join claims cla on cli.client_id = cla.client_id
where cla.claim_status = 'Paid'
group by cli.client_name;

#fix version
SELECT cli.client_name,
    COUNT(DISTINCT DATE_FORMAT(cla.claim_date, '%Y-%m')) AS distinct_months
FROM clients cli
JOIN claims cla ON cli.client_id = cla.client_id
GROUP BY cli.client_name
HAVING COUNT(DISTINCT DATE_FORMAT(cla.claim_date, '%Y-%m')) > 1;

#Date Aggregations — H2
#Show the month-over-month difference in total claim amounts across all clients. Show year_month, monthly_total, previous month total using LAG(), and the difference. Order by month.

select year_months, monthly_total,
lag(monthly_total) over(order by year_months) as previous_month,
monthly_total - lag(monthly_total) over( order by year_months) as differences
from(
select date_format(claim_date, '%Y-%m') as year_months, sum(claim_amount) as monthly_total
from claims
group by date_format(claim_date, '%Y-%m')
) as monthly_totals
order by year_months;

#Pivoting — H3
#For each country show the total claim amount per month as separate columns — one column for each month that appears in the data. Include country, and one column per month.
SELECT cli.country,
    SUM(CASE WHEN DATE_FORMAT(cla.claim_date, '%Y-%m') = '2024-03'
        THEN cla.claim_amount ELSE 0 END) AS '2024-03',
    SUM(CASE WHEN DATE_FORMAT(cla.claim_date, '%Y-%m') = '2024-04'
        THEN cla.claim_amount ELSE 0 END) AS '2024-04',
    SUM(CASE WHEN DATE_FORMAT(cla.claim_date, '%Y-%m') = '2024-05'
        THEN cla.claim_amount ELSE 0 END) AS '2024-05',
    SUM(CASE WHEN DATE_FORMAT(cla.claim_date, '%Y-%m') = '2024-06'
        THEN cla.claim_amount ELSE 0 END) AS '2024-06',
    SUM(CASE WHEN DATE_FORMAT(cla.claim_date, '%Y-%m') = '2024-07'
        THEN cla.claim_amount ELSE 0 END) AS '2024-07'
FROM clients cli
LEFT JOIN claims cla ON cli.client_id = cla.client_id
GROUP BY cli.country
ORDER BY cli.country;

#CTE — H4
#Using two CTEs — one for total claims per client, one for average credit limit per client — join them together and show client_name, total_claims, avg_credit_limit, and a column called profile that says:
#'High Value' if total_claims > 50000 AND avg_credit_limit > 500000
#'Risk' if total_claims > 50000 AND avg_credit_limit < 500000
#'Standard' for everything else

WITH total_claims AS (
    SELECT cli.client_name,
        SUM(cla.claim_amount) AS total_claims
    FROM clients cli
    LEFT JOIN claims cla ON cli.client_id = cla.client_id
    GROUP BY cli.client_name
),
avg_credit AS (
    SELECT cli.client_name,
        AVG(cre.credit_limit) AS avg_credit_limit
    FROM clients cli
    LEFT JOIN credit_assessments cre ON cli.client_id = cre.client_id
    GROUP BY cli.client_name
)
SELECT
    tc.client_name,
    COALESCE(tc.total_claims, 0) AS total_claims,
    ROUND(COALESCE(ac.avg_credit_limit, 0), 2) AS avg_credit_limit,
    CASE
        WHEN tc.total_claims > 50000 AND ac.avg_credit_limit > 500000 THEN 'High Value'
        WHEN tc.total_claims > 50000 AND ac.avg_credit_limit < 500000 THEN 'Risk'
        ELSE 'Standard'
    END AS profile
FROM total_claims tc
JOIN avg_credit ac ON tc.client_name = ac.client_name
ORDER BY tc.client_name;

#Test Exercises
use sql_practice;
#Q1 — Basic aggregation with JOIN
#E1: Show the total claim amount per segment. Order from highest to lowest. 
#col:total claim amount (sum), segment
#table: claims,clients (id
#cond:order desc
select cli.segment, sum(cla.claim_amount) as total_claim_amount
from clients cli
join claims cla on cli.client_id = cla.client_id
group by cli.segment
order by sum(cla.claim_amount) desc;

#E2: Count how many clients each country has. Show country and client_count.
select country, count(*) as client_count
from clients
group by country;
#col: country, client count(count)
#table:clients
#cond: no

#Q2 — WHERE + HAVING together
#E1: Show total claim amount per client, only counting Paid claims. Only show clients whose total is above 20000. 
#col: client name, total claim amount(sum)
#table:client, claim
#Cond: only paid claims (join+where), total claim amount > 20000 (having)

select cli.client_name, sum(cla.claim_amount) as total_claim_amount
from clients cli
join claims cla on cli.client_id = cla.client_id
where cla.claim_status = 'Paid'
group by cli.client_name
having sum(cla.claim_amount) > 20000;

#E2: Count assessments per country, only Approved. Only show countries with more than 1 approved assessment.
#col: assessments count(count) , country
#table: clients, credit assessments
#cond: assessments approved (join+where: countries with approved status), countries with > 1 approved assessments (having)

select cli.country, count(cre.client_id) as count_assessments
from clients cli
join credit_assessments cre on cli.client_id = cre.client_id
where cre.status = 'Approved'
group by cli.country
having count(cre.client_id) > 1;

#Q3 — LEFT JOIN + COALESCE
#E1: Show all clients with their total claim amount. If a client has no claims show 0. 
#columns: all clients, claim_amount (sum)
#table:clients, claims
#cond:all clients (left join) and for no claims put 0 instead of null

select cli.client_name, coalesce(sum(cla.claim_amount),0) as total_claim_amount
from clients cli
left join claims cla on cli.client_id = cla.client_id
group by cli.client_name;

#E2: Show all clients with their credit limit. If a client has no assessment show 0.
#column: all clients, credit limit 
#table: clients, credit_assessments
#cond:all clients(left) if one has null, put 0 instead

select cli.client_name, coalesce(max(cre.credit_limit), 0) as credit_limit
from clients cli 
left join credit_assessments cre on cli.client_id = cre.client_id
group by cli.client_name;

#it is asked to show all clients with their credit limit , so it must be with max in credit limit 

#Q4 — CASE WHEN classification
#E1: For each assessment show client_name, credit_limit and a column called size — 'Large' if credit_limit > 500000, 'Medium' if between 100000 and 500000, 'Small' otherwise. 
#column: client name, credit limit, classificaction with case when
#table:client, credit assessments
#condition: each assessment (rigth table, join)

select cli.client_name, cre.credit_limit, 
case 
when cre.credit_limit > 500000 then 'Large' 
when cre.credit_limit between 100000 and 500000 then 'Medium' else 'Small' 
end as size
from clients cli
join credit_assessments cre on cli.client_id = cre.client_id ;
#extra when can be removed, just use else in the second when 
#E2: For each claim show claim_id, claim_amount and a column called urgency — 'Critical' if above 50000, 'Normal' otherwise.
#column: claim id, claim amount , urgency
#table: client, claims
#cond: case when , (join, each claim is right table)

select claim_id, claim_amount,
case when claim_amount > 50000 then 'Critical' else 'Normal' end as urgency 
from claims;

#MEDIUM
#Q5 — Ranking with window function
#M1: Rank all claims by claim_amount from highest to lowest. Show client_name, claim_amount and rank. 
#column:client name, claim amonunt, rank
#table: clients, claims
#cond:rank desc

select cli.client_name,cla.claim_amount,
rank() over(order by cla.claim_amount desc) as rnk
from clients cli
join claims cla on cli.client_id = cla.client_id;

#M2: For each country rank clients by their total claim amount. Show country, client_name, total_claims and rank within country.
#colum: country, client_name, total_claims and rank
#table: clients, claim
#cond: rank with agg func and desc

select country, client_name, total_claims,
rank()over( partition by country order by total_claims desc) as rnk
from(
select cli.country, cli.client_name, sum(cla.claim_amount) as total_claims
from clients cli
join claims cla on cli.client_id = cla.client_id
group by cli.country, cli.client_name) as sub_claim;
#ALWAYS PUT DESC, it is important to see from highest to lowest

#Q6 — Running total
#M1: Show a running total of claim amounts ordered by claim_date across all claims. Show claim_id, claim_date, claim_amount and running_total. 
#col:claim_id, claim_date, claim_amount and running_total.
#tab: clients, claims
#con:running total  across all claims (cummulative: running total,go with order by ordered by claim_date)

select claim_id, claim_date, claim_amount, 
sum(claim_amount) over ( order by claim_date) as running_total
from claims
;
#Remvove group by when there is a WINDOW FUNCTION, it is unnecesary

#M2: Show a running total of claim amounts per client ordered by claim_date. Show client_name, claim_date, claim_amount and running_total_per_client.
#col:claim_id, claim_date, claim_amount and running_total.
#tab: clients, claims
#con:running total   per client ordered by claim_date (cummulative: running total,go with order by and it is partition by , bc it is per client, resets)
select cli.client_name, cla.claim_date, cla.claim_amount, 
sum(cla.claim_amount) over ( partition by cli.client_name order by cla.claim_date) as running_total_per_client
from clients cli
join claims cla on cli.client_id = cla.client_id
;

#Remvove group by when there is a WINDOW FUNCTION, it is unnecesary
#Partition by, should be by the same name that is showing change client_id by client_name

#Q7 — Pivot
#M1: For each segment show the count of Approved and Rejected assessments as separate columns. 
#col:segment
#tab: client, credit asses
#con: new col of appro and reject ass
select * from credit_assessments;

select cli.segment, 
Sum(case when cre.status = 'Approved' then 1 else 0 end) as Approved_count,
Sum(case when cre.status = 'Rejected' then 1 else 0 end) as Rejected_count,
count(*) as assessments
from clients cli
join credit_assessments cre on cli.client_id = cre.client_id
group by cli.segment;

#M2: For each country show the total Paid and total Pending claim amounts as separate columns. Include all countries.
#col: country all countries
#tab: clients, claims
#cond: total paid and pending as col, all(so it is left)

select cli.country, 
sum(case when cla.claim_status = 'Paid' then cla.claim_amount else 0 end) as paid_claims,
sum(case when cla.claim_status = 'Pending' then cla.claim_amount else 0 end) as pending_claims
from clients cli
left join claims cla on cli.client_id = cla.client_id
group by cli.country;
#FORGOT THE LEFT JOIN
#Q8 — Date aggregation
#M1: Show total claim amount per month. Display year_month and monthly_total ordered chronologically. 
#col: year_month and monthly_total
#tab: claim
#cond: asc

select date_format(claim_date, '%Y-%m') as yearmonths, sum(claim_amount) as monthly_total
from claims
group by date_format(claim_date, '%Y-%m')
order by yearmonths asc ;
#order chronologically is just by the date, not the totals
#M2: Show total claim amount per client per month. Only show rows where the monthly total is above 15000.

select cli.client_name, month(cla.claim_date) as months, sum(cla.claim_amount) as monthly_total
from clients cli
join claims cla on cli.client_id = cla.client_id
group by cli.client_name, month(cla.claim_date)
having sum(cla.claim_amount)
;
