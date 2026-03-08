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
#6 List all claims with their policy type.
select cla.claim_id, pol.policy_type
from claims cla
left join policies pol on cla.policy_id = cla.policy_id;
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
#Level 5 — Typical interview questions
#17 Find customers with more than one policy.
select cus.customer_name, count(pol.customer_id) as total_policies_number
from customers cus
join policies pol on cus.customer_id = pol.customer_id
group by cus.customer_name
having count(pol.customer_id) >1;
#18 Find policies with no claims.
select * from policies;
select * from claims;
select pol.policy_id, cla.claim_id
from policies pol
join claims cla on pol.policy_id = cla.policy_id
where pol.policy_id is null;
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
#20 Find the top 3 customers by total claim amount.
select customer_name, claim_amount
from(
select cus.customer_name, cla.claim_amount,
row_number()over(order by cla.claim_amount desc) as rn
from customers cus
join policies pol on cus.customer_id = pol.customer_id 
join claims cla on cla.policy_id = pol.policy_id) as query_rn
where rn <= 3;

