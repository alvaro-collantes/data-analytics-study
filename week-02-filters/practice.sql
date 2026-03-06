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
