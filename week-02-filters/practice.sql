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

#Exercise 2 — LEFT JOIN + COALESCE
#List all clients with their total credit limit. If a client has no credit assessment, show 0 instead of NULL.

select client_name, sum(credit_limit) as total_credit_limit 
from clients cli
left join credit_assessments cre
on cli.client_id = cre.client_id
where status != 'Rejected'
group by client_name;


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