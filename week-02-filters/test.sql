use practice_test;
-- TABLE 1: clients
CREATE TABLE clients (
  client_id   INT PRIMARY KEY,
  client_name VARCHAR(50),
  country     VARCHAR(50),
  segment     VARCHAR(50)
);

INSERT INTO clients VALUES
(1,  'Renault',       'France',      'Large'),
(2,  'Fiat',          'Italy',       'Medium'),
(3,  'Siemens',       'Germany',     'Large'),
(4,  'Peugeot',       'France',      'Small'),
(5,  'Volkswagen',    'Germany',     'Large'),
(6,  'Airbus',        'France',      'Large'),
(7,  'Ferrero',       'Italy',       'Medium'),
(8,  'BASF',          'Germany',     'Small'),
(9,  'TotalEnergies', 'France',      'Large'),
(10, 'Pirelli',       'Italy',       'Small');

-- TABLE 2: credit_assessments
CREATE TABLE credit_assessments (
  assessment_id INT PRIMARY KEY,
  client_id     INT,
  assessment_date DATE,
  credit_limit  INT,
  status        VARCHAR(20)
);

INSERT INTO credit_assessments VALUES
(101, 1,  '2024-01-10', 500000,  'Approved'),
(102, 2,  '2024-01-22', 200000,  'Rejected'),
(103, 3,  '2024-02-05', 750000,  'Approved'),
(104, 4,  '2024-02-18', 80000,   'Approved'),
(105, 5,  '2024-03-03', 900000,  'Approved'),
(106, 6,  '2024-03-25', 650000,  'Rejected'),
(107, 7,  '2024-04-11', 150000,  'Approved'),
(108, 8,  '2024-04-30', 60000,   'Rejected'),
(109, 9,  '2024-05-14', 720000,  'Approved'),
(110, 10, '2024-05-28', 95000,   'Rejected');

-- TABLE 3: claims
CREATE TABLE claims (
  claim_id     INT PRIMARY KEY,
  client_id    INT,
  claim_date   DATE,
  claim_amount INT,
  claim_status VARCHAR(20)
);

INSERT INTO claims VALUES
(201, 1,  '2024-03-05', 45000,  'Paid'),
(202, 1,  '2024-05-12', 32000,  'Pending'),
(203, 1,  '2024-07-01', 61000,  'Paid'),
(204, 3,  '2024-03-18', 28000,  'Paid'),
(205, 3,  '2024-06-22', 54000,  'Pending'),
(206, 5,  '2024-04-09', 77000,  'Paid'),
(207, 5,  '2024-06-15', 43000,  'Paid'),
(208, 5,  '2024-07-20', 19000,  'Pending'),
(209, 6,  '2024-05-03', 88000,  'Paid'),
(210, 6,  '2024-07-11', 35000,  'Pending'),
(211, 7,  '2024-04-27', 22000,  'Paid'),
(212, 9,  '2024-06-08', 67000,  'Paid'),
(213, 9,  '2024-07-25', 41000,  'Pending'),
(214, 10, '2024-05-19', 15000,  'Paid');

-- ============================================================
-- SQL MOCK EXAM 
-- Time: 45 minutes | No notes | Apply 5-question method
-- Step 1 — Read twice
-- Step 2 — Write these 5 lines as comments:
          -- WHAT:    (columns to show)
          -- FROM:    (tables needed)
          -- JOIN:    (INNER or LEFT — and why)
          -- FILTER:  (WHERE conditions + HAVING conditions)
          -- GROUP:   (GROUP BY + ORDER BY)
-- Step 3 — Only then start writing SQL
-- Step 4 — Read your SQL once before submitting
          -- and check: DESC in RANK? DATE_FORMAT not MONTH()?
          -- HAVING has full expression? Filter on right table in ON?
-- USE practice_test before starting
-- ============================================================
USE practice_test;

-- ============================================================
-- TOPIC 1 — JOINs
-- ============================================================

-- Q1.1 [EASY]
-- Show each claim with the client name and country.
-- Display claim_id, client_name, country, claim_amount.

select cla.claim_id, cli.client_name, cli.country, cla.claim_amount
from clients cli
join claims cla on cli.client_id = cla.client_id;

-- Q1.2 [MEDIUM]
-- Show all clients with their total claim amount.
-- Include clients who have no claims and show 0 for them.
-- Display client_name, country and total_claims.

select cli.client_name, cli.country ,coalesce(sum(cla.claim_amount),0) as total_claim_amount
from clients cli
left join claims cla on cli.client_id = cla.client_id
group by cli.client_name, cli.country;

-- Q1.3 [HARD]
-- Show all clients(left) with their total Paid claim amount only(On... and).
-- Include clients with no Paid claims and show 0(coalesce).
-- Only show clients from France or Germany (where+between).
-- Display client_name, country, total_paid.

select cli.client_name, cli.country, coalesce(sum(cla.claim_amount),0) as total_paid
from clients cli
left join claims cla on cli.client_id = cla.client_id and cla.claim_status != 'Paid'
where cli.country IN ('France','Germany') 
group by cli.client_name, cli.country;

-- ============================================================
-- TOPIC 2 — Aggregates & GROUP BY
-- ============================================================

-- Q2.1 [EASY]
-- Show the total claim amount and number of claims per country.
-- Display country, total_claim_amount, number_of_claims.

select cli.country, sum(cla.claim_amount) as total_claim_amount, count(*) as number_of_claims
from clients cli 
join claims cla on cli.client_id = cla.client_id
group by cli.country;

-- Q2.2 [MEDIUM]
-- Show the average credit limit per segment, only for Approved assessments.
-- Only show segments where the average is above 400000.
-- Display segment and avg_credit_limit.
select * from credit_assessments;

select cli.segment, avg(cre.credit_limit) as avg_credit_limit 
from clients cli
join credit_assessments cre on cli.client_id = cre.client_id
where cre.status = 'Approved'
group by cli.segment
having avg(cre.credit_limit) > 400000
;

-- Q2.3 [HARD]
-- Show each country with its total claim amount, number of claims,
-- and average claim amount rounded to 0 decimals.
-- Only show countries with more than 2 claims
-- and a total claim amount above 100000.
-- Display country, total_claims, number_of_claims, avg_claim.

SELECT cli.country,
    SUM(cla.claim_amount) AS total_claims,
    COUNT(*) AS number_of_claims,
    ROUND(AVG(cla.claim_amount), 0) AS avg_claim
FROM clients cli
left JOIN claims cla ON cli.client_id = cla.client_id
GROUP BY cli.country
HAVING COUNT(*) > 2
    AND SUM(cla.claim_amount) > 100000;
-- ============================================================
-- TOPIC 3 — WHERE vs HAVING
-- ============================================================

-- Q3.1 [EASY]
-- Show the total claim amount per client, only counting Paid claims.
-- Display client_name and total_paid.

select cli.client_name, sum(cla.claim_amount) as total_paid 
from clients cli
join claims cla on cli.client_id = cla.client_id
where cla.claim_status = 'Paid'
group by cli.client_name
;

-- Q3.2 [MEDIUM]
-- Show the number of Approved assessments per country.
-- Only show countries with more than 1 Approved assessment.
-- Display country and approved_count.

-- Q3.3 [HARD]
-- Show total claim amount per client per claim status.
-- Only include claims from 2024-05-01 onwards.
-- Only show rows where the total is above 30000.
-- Display client_name, claim_status, total_amount.

-- ============================================================
-- TOPIC 4 — CASE WHEN
-- ============================================================

-- Q4.1 [EASY]
-- For each assessment show client_name, credit_limit,
-- and a column called risk_level:
-- 'High Risk' if credit_limit > 600000
-- 'Medium Risk' if between 200000 and 600000
-- 'Low Risk' otherwise.

-- Q4.2 [MEDIUM]
-- For each country show the count of Approved
-- and Rejected assessments as separate columns,
-- plus the total number of assessments.
-- Display country, approved, rejected, total.

-- Q4.3 [HARD]
-- For each client show client_name, total cla