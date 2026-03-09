CREATE DATABASE insurance_analytics;

USE insurance_analytics;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    country VARCHAR(50),
    signup_date DATE
);

CREATE TABLE policies (
    policy_id INT PRIMARY KEY,
    customer_id INT,
    policy_type VARCHAR(50),
    start_date DATE,
    premium DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE claims (
    claim_id INT PRIMARY KEY,
    policy_id INT,
    claim_amount DECIMAL(10,2),
    claim_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
);

INSERT INTO customers VALUES
(1,'Alice Martin','France','2023-01-10'),
(2,'Bob Schmidt','Germany','2023-03-12'),
(3,'Carlos Lopez','Spain','2023-05-01'),
(4,'Diana Petit','France','2023-06-21'),
(5,'Eva Rossi','Italy','2023-07-15');

INSERT INTO policies VALUES
(101,1,'Trade Credit','2024-01-01',1200),
(102,1,'Trade Credit','2025-01-01',1400),
(103,2,'Trade Credit','2024-03-01',900),
(104,3,'Trade Credit','2024-05-10',1000),
(105,4,'Trade Credit','2024-07-01',1100);

INSERT INTO claims VALUES
(201,101,5000,'2024-05-10','Approved'),
(202,101,2000,'2024-07-01','Approved'),
(203,103,7000,'2024-10-10','Rejected'),
(204,104,1500,'2024-09-12','Approved'),
(205,104,3000,'2024-10-15','Pending');

#Queries 
#customers, policies, claims
#Level 1 — Basic filtering
#1 List all customers.
select customer_name from customers;
#correction: All customers means all the columns
select * from customers;
#2 Show customers located in France.
select customer_name 
from customers
where country = 'France';
#3 Show all policies with premium greater than 1000.
select * 
from policies
where premium > 1000;
#4 List claims with status Approved.
select * 
from claims
where status = 'Approved';

#Level 2 — Basic joins
#5 Show all policies with the customer name.
select pol.policy_id, cus.customer_name
from policies pol
left join customers cus on pol.customer_id = cus.customer_id;
#correction: every policy must have a customer
SELECT 
    pol.policy_id,
    cus.customer_name
FROM policies pol
JOIN customers cus
    ON pol.customer_id = cus.customer_id;
#6 List all claims with their policy type.
select cla.claim_id, pol.policy_type
from claims cla
left join policies pol on cla.policy_id = cla.policy_id;
#correction: joined the same col, wrong on
select cla.claim_id, pol.policy_type
from claims cla
left join policies pol on cla.policy_id = pol.policy_id;
#7 Show all customers and their policies (even if none exist).
select * from policies;
select cus.customer_name, pol.policy_id 
from customers cus
left join policies pol on cus.customer_id = pol.customer_id;
#8 Find customers without policies.
select * 
from customers cus
left join policies pol on pol.customer_id = cus.customer_id 
where pol.customer_id is null;

#Level 3 — Aggregations
#9 Calculate the total premium per customer.
select cus.customer_name, sum(pol.premium) as total_premiun
from customers cus
join policies pol on cus.customer_id = pol.customer_id
group by cus.customer_name;
#correction: group by id, safer
SELECT 
    cus.customer_id,
    cus.customer_name,
    SUM(pol.premium) AS total_premium
FROM customers cus
JOIN policies pol
    ON cus.customer_id = pol.customer_id
GROUP BY cus.customer_id, cus.customer_name;
#10 Count the number of policies per customer.
select cus.customer_name, count(pol.policy_id) as total_policies
from customers cus
join policies pol on cus.customer_id = pol.customer_id
group by cus.customer_name;
#11 Calculate the total claim amount per policy.
select pol.policy_id,sum(cla.claim_amount) as total_claim
from policies pol 
join claims cla on pol.policy_id = cla.policy_id
group by pol.policy_id;
#12 Calculate the number of claims per policy.
select pol.policy_id,count(cla.claim_id) as total_claims
from policies pol 
join claims cla on pol.policy_id = cla.policy_id
group by pol.policy_id;
#Level 4 — Business analysis
#13 Find the total claim amount per customer.
#(Hint: requires 3 tables)
select pol.policy_id, cus.customer_name,sum(cla.claim_amount) as total_claims_amount
from policies pol 
join claims cla on pol.policy_id = cla.policy_id
join customers cus on cus.customer_id = pol.customer_id
group by pol.policy_id, cus.customer_name;
#correction: remove the policy_id, it is just per customer
SELECT 
    cus.customer_name,
    SUM(cla.claim_amount) AS total_claim_amount
FROM customers cus
JOIN policies pol 
    ON cus.customer_id = pol.customer_id
JOIN claims cla 
    ON pol.policy_id = cla.policy_id
GROUP BY cus.customer_name;
#14 Find the average claim amount.
select avg(claim_amount) as avg_client_amount
from claims;
#15 Show total claims by country.
select * from policies;
select * from claims;
select cus.country, sum(claim_amount) as total_claim_amount
from customers cus
join policies pol on cus.customer_id = pol.customer_id
join claims cla on cla.policy_id = pol.policy_id
group by cus.country ;
#16 Find the policy with the highest claim amount.
select policy_id, claim_amount, rn
from(
select pol.policy_id, cla.claim_amount, 
row_number() over(order by cla.claim_amount desc) as rn
from claims cla
join policies pol on pol.policy_id = cla.policy_id) as high_query
where rn = 1;
#correction: correct, but there is a simpler solution
select policy_id, claim_amount
from claims
ORDER BY claim_amount DESC
LIMIT 1;
#Level 5 — Typical interview questions
#17 Find customers with more than one policy.
select cus.customer_name, count(pol.customer_id) as total_policies_number
from customers cus
join policies pol on cus.customer_id = pol.customer_id
group by cus.customer_name
having count(pol.customer_id) >1;
#18 Find policies with no claims.
SELECT pol.policy_id
FROM policies pol
LEFT JOIN claims cla
    ON pol.policy_id = cla.policy_id
WHERE cla.policy_id IS NULL;
#correction: wrong impossible condition. It says no claims = without claims, left join
SELECT pol.policy_id
FROM policies pol
LEFT JOIN claims cla
ON pol.policy_id = cla.policy_id
WHERE cla.policy_id IS NULL;
#19 Find the country with the highest total claim amount.
select country,claim_amount
from(
select cus.country, cla.claim_amount,
row_number() over(order by cla.claim_amount desc) as rn
from customers cus
join policies pol on cus.customer_id = pol.customer_id
join claims cla on cla.policy_id = pol.policy_id
) as query_highest
where rn = 1;
#simple version 
SELECT 
    cus.country,
    SUM(cla.claim_amount) AS total_claim_amount
FROM customers cus
JOIN policies pol
    ON cus.customer_id = pol.customer_id
JOIN claims cla
    ON pol.policy_id = cla.policy_id
GROUP BY cus.country
ORDER BY total_claim_amount DESC
LIMIT 1;
#20 Find the top 3 customers by total claim amount.
select customer_name, claim_amount
from(
select cus.customer_name, cla.claim_amount,
row_number()over(order by cla.claim_amount desc) as rn
from customers cus
join policies pol on cus.customer_id = pol.customer_id 
join claims cla on cla.policy_id = pol.policy_id) as query_rn
where rn <= 3;
#simple version:
SELECT 
    cus.customer_name,
    SUM(cla.claim_amount) AS total_claim_amount
FROM customers cus
JOIN policies pol
    ON cus.customer_id = pol.customer_id
JOIN claims cla
    ON pol.policy_id = cla.policy_id
GROUP BY cus.customer_name
ORDER BY total_claim_amount DESC
LIMIT 3;

/* ==============================
SQL MOCK TEST (60 MINUTES)
Dataset: customers, policies, claims
============================== */
USE insurance_analytics;
/* Q1 */
-- List all customers who signed up after '2023-04-01'.

select * 
from customers
where signup_date > '2023-04-01';

/* Q2 */
-- Show all policies with their customer name and country.

select pol.policy_id, cus.customer_name, cus.country
from policies pol
left join customers cus on pol.customer_id = cus.customer_id
;
#correction: every policy has a customer, use join
select pol.policy_id, cus.customer_name, cus.country
from policies pol
join customers cus on pol.customer_id = cus.customer_id
;

/* Q3 */
-- Find the total number of policies per country.

select cus.country, count(pol.policy_id) as total_number_of_policies
from policies pol
join customers cus on pol.customer_id = cus.customer_id
group by cus.country;

/* Q4 */
-- Find the total claim amount per policy.

select pol.policy_id, sum(cla.claim_amount) as total_claim_amount
from policies pol 
join claims cla on pol.policy_id = cla.policy_id
group by pol.policy_id;

/* Q5 */
-- Find policies that have no claims.

select pol.policy_id, cla.claim_id
from policies pol 
left join claims cla on pol.policy_id = cla.policy_id
where cla.claim_id is null;

/* Q6 */
-- Find the customer with the highest total claim amount.

select cus.customer_name, max(cla.claim_amount) as highest_total_claim_amount
from customers cus 
join policies pol on pol.customer_id = cus.customer_id
join claims cla on pol.policy_id = cla.policy_id
group by cus.customer_name
order by max(cla.claim_amount) desc
limit 1;
#correction: highest claim amount is sum
select cus.customer_name, sum(cla.claim_amount) as highest_total_claim_amount
from customers cus 
join policies pol on pol.customer_id = cus.customer_id
join claims cla on pol.policy_id = cla.policy_id
group by cus.customer_name
order by sum(cla.claim_amount) desc
limit 1;

/* Q7 */
-- Find the average claim amount per country.

select cus.country, avg(cla.claim_amount) as avg_claim_amount
from customers cus
join policies pol on pol.customer_id = cus.customer_id
join claims cla on pol.policy_id= cla.policy_id
group by cus.country;

/* Q8 */
-- Find customers who have more than 1 claim.

select cus.customer_name, count(cla.claim_id) total_claim
from customers cus
join policies pol on pol.customer_id = pol.customer_id
join claims cla on pol.policy_id = cla.policy_id
group by cus.customer_name
having count(cla.claim_id) > 1;
#correction: wrong prefix in the first join
select cus.customer_name, count(cla.claim_id) total_claim
from customers cus
join policies pol on cus.customer_id = pol.customer_id
join claims cla on pol.policy_id = cla.policy_id
group by cus.customer_name
having count(cla.claim_id) > 1;

/* ==============================
INSURANCE ANALYTICS QUESTIONS
============================== */

/* Q9 */
-- Calculate the loss ratio per policy.
-- loss_ratio = total_claim_amount / premium

select policy_id, (total_claim_amount / premium) as loss_ratio 
from (
select pol.policy_id, pol.premium,sum(cla.claim_amount) as total_claim_amount
from policies pol 
join claims cla on pol.policy_id = cla.policy_id 
group by pol.policy_id) as calcu_claim;
#correction:use left join in case there are policies with no claims
select policy_id, coalesce((total_claim_amount / premium),0) as loss_ratio 
from (
select pol.policy_id, pol.premium,sum(cla.claim_amount) as total_claim_amount
from policies pol 
left join claims cla on pol.policy_id = cla.policy_id 
group by pol.policy_id) as calcu_claim;

/* Q10 */
-- Find customers whose total claim amount is greater than 5000.

select cus.customer_name, sum(cla.claim_amount) as total_claim_amount
from customers cus
join policies pol on cus.customer_id = pol.customer_id
join claims cla on pol.policy_id = cla.policy_id
group by cus.customer_name 
having sum(cla.claim_amount) > 5000;

/* Q11 */
-- Calculate the total claim amount per month.

select date_format(claim_date, '%Y-%m') as months, claim_id, sum(claim_amount) as total_claim_amount
from claims 
group by date_format(claim_date, '%Y-%m') , claim_id
order by date_format(claim_date, '%Y-%m') asc;
#correction: dont add the id, not necessary
select date_format(claim_date, '%Y-%m') as months, sum(claim_amount) as total_claim_amount
from claims 
group by date_format(claim_date, '%Y-%m') 
order by date_format(claim_date, '%Y-%m') asc;
/* Q12 */
-- Calculate the claim approval rate per country.
-- approval_rate = approved_claims / total_claims

select country, (approved_claims/total_claims) as approval_rate
from(
select cus.country, sum(cla.claim_amount) as total_claims,
sum(case when cla.status = 'Approved' then 1 else 0 end) as approved_claims
from customers cus
join policies pol on cus.customer_id = pol.customer_id
join claims cla on cla.policy_id = pol.policy_id
group by cus.country) as sub_app; 
#correction: it should have count of the claims, not sum
select country, (approved_claims/total_claims) as approval_rate
from(
select cus.country, count(cla.claim_amount) as total_claims,
sum(case when cla.status = 'Approved' then 1 else 0 end) as approved_claims
from customers cus
join policies pol on cus.customer_id = pol.customer_id
join claims cla on cla.policy_id = pol.policy_id
group by cus.country) as sub_app; 

#other simpler solution
SELECT
cus.country,
SUM(CASE WHEN cla.status='Approved' THEN 1 ELSE 0 END) /
COUNT(*) AS approval_rate
FROM customers cus
JOIN policies pol
ON cus.customer_id = pol.customer_id
JOIN claims cla
ON pol.policy_id = cla.policy_id
GROUP BY cus.country;

/* Q13 */
-- Find the top 3 policies with the highest total claim amount.

select pol.policy_id, sum(cla.claim_amount) as total_claim_amount
from policies pol 
join claims cla on pol.policy_id = cla.policy_id
group by pol.policy_id 
order by sum(cla.claim_amount) desc
limit 3;

/* ==============================
ADVANCED DATA ANALYST QUESTIONS
============================== */

/* Q14 */
-- Find customers who have multiple policies.

select cus.customer_name, count(pol.customer_id) as total_policies
from customers cus
join policies pol on cus.customer_id = pol.customer_id
group by cus.customer_name
having count(pol.customer_id) >1;

/* Q15 */
-- Find policies where the total claim amount exceeds the premium.

select policy_id, total_claim_amount, premium
from(
select pol.policy_id, pol.premium,sum(cla.claim_amount) as total_claim_amount
from policies pol
join claims cla on pol.policy_id = cla.policy_id
group by pol.policy_id
having sum(cla.claim_amount) >  pol.premium) as query;

/* Q16 */
-- Find the average claim amount per policy type.

select pol.policy_type, avg(cla.claim_amount) as avg_claim_amount
from policies pol 
join claims cla on pol.policy_id = cla.policy_id
group by pol.policy_type; 

/* Q17 */
-- Find the country with the highest total premium.

select* from policies;
select cus.country, sum(pol.premium) as highest_total_premium
from customers cus
join policies pol on cus.customer_id = pol.customer_id
group by cus.country
order by sum(pol.premium) desc
limit 1;

/* Q18 */
-- Find the percentage of rejected claims.

select sum(case when status = 'Rejected' then 1 else 0 end)/count(status) as percentage_of_rejected_claims
from claims;
#correction: use count(*) 
select sum(case when status = 'Rejected' then 1 else 0 end)/count(*) as percentage_of_rejected_claims
from claims;

/* Q19 */
-- Find customers who have policies but no claims.

select cus.customer_name
from customers cus
left join policies pol on cus.customer_id = pol.customer_id
left join claims cla on pol.policy_id = cla.policy_id
where cla.policy_id is null; 
#correction: wrong logic , first is join and second is left
SELECT cus.customer_name
FROM customers cus
JOIN policies pol
ON cus.customer_id = pol.customer_id
LEFT JOIN claims cla
ON pol.policy_id = cla.policy_id
WHERE cla.claim_id IS NULL;

/* Q20 */
-- Rank customers by their total claim amount (highest first).

select customer_name, total_claim_amount, 
rank()over(order by total_claim_amount desc) as rkn
from(
select cus.customer_name, sum(cla.claim_amount) as total_claim_amount
from customers cus
join policies pol on cus.customer_id = pol.customer_id
join claims cla on pol.policy_id = cla.policy_id
group by cus.customer_name) as total;

/* Q21 */
-- Find the cumulative claim amount ordered by claim date.

select claim_id, claim_date,
sum(claim_amount) over( order by claim_date asc) as cumulative_claim_amount
from claims;