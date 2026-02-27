# Week 0: Load Data & Select and From statements

# Raw Data

# Step 0: Configure SQL to load the data with code
# Verify if it is ON, if it is the case go to Step 1 directly
SHOW VARIABLES LIKE 'local_infile'; 
# In case it is OFF: 
# Close SQL, open again, before connecting right click and choose Edit Connection
# Choose Advanced tab and add: OPT_LOCAL_INFILE=1
# Connect to SQL and run SET GLOBAL local_infile = 1
# Verify again with SHOW VARIABLES LIKE 'local_infile', should say ON
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

# Step 1: Create Database and Table with headers
CREATE DATABASE IF NOT EXISTS superstore;
#Use IF NOT EXISTS to avoid the error if the database already exists
USE superstore;

# Check column names from CMD before creating the table. What is in "" is the path
# Check from CMD: more "C:\ARCHIVOS\DOCUMENTS\Alvaro Universidad\M2 FIT\Practice\Sample - Superstore.csv"
# First row: Row ID,Order ID,Order Date,Ship Date,Ship Mode,Customer ID,Customer Name,
#            Segment,Country,City,State,Postal Code,Region,Product ID,Category,
#            Sub-Category,Product Name,Sales,Quantity,Discount,Profit
# Naming convention: avoid capital letters and spaces, easier to manipulate
# All columns set as VARCHAR first, data types will be corrected after exploring the data

CREATE TABLE IF NOT EXISTS sales (
    row_id VARCHAR(50),
    order_id VARCHAR(50),
    order_date VARCHAR(20),
    ship_date VARCHAR(20),
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(200),
    sales VARCHAR(50),
    quantity VARCHAR(50),
    discount VARCHAR(50),
    profit VARCHAR(50)
);

# Step 2: Load data into the table
LOAD DATA LOCAL INFILE 'C:/ARCHIVOS/DOCUMENTS/Alvaro Universidad/M2 FIT/Practice/Sample - Superstore.csv'
INTO TABLE sales
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

# Step 3: Explore the data
SELECT COUNT(*) FROM sales;
# Expected: 9994 rows
SELECT * FROM sales LIMIT 10;

# Identify data types for each column:
# Date format: order_date, ship_date (format is M/D/YYYY)
# Integer format: row_id, quantity
# Decimal format: sales, discount, profit
# The rest: VARCHAR

# Step 4: Create new table with correct data types
DROP TABLE IF EXISTS sales_raw;
# Avoids error if the table already exists from a previous run

CREATE TABLE sales_raw AS
SELECT
    CAST(row_id AS SIGNED) AS row_id,
    order_id,
    STR_TO_DATE(order_date, '%m/%d/%Y') AS order_date,
	STR_TO_DATE(ship_date, '%m/%d/%Y') AS ship_date,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
	region,
    product_id,
    category,
    sub_category,
    product_name,
    CAST(sales AS DECIMAL(10,2)) AS sales,
    CAST(quantity AS SIGNED) AS quantity,
    CAST(discount AS DECIMAL(5,4)) AS discount,
    CAST(profit AS DECIMAL(10,2)) AS profit
FROM sales;
#cast: transform one column from one type to other
#signed: is like Integer (acept negative and positives)
#AS DECIMAL(10,2): 10 is the max digit allowed, 2 is the max digits after the decimal dot , so it will be 8 Integers and 2 decimals

# Verify
SELECT COUNT(*) FROM sales_raw;
# Expected: 9994 rows
DESCRIBE sales_raw;
# order_date and ship_date should show DATE type
# sales, discount, profit should show DECIMAL
# quantity, row_id should show INT
# Data ready to use: sales_raw

#Exercises 

# Exercise 1:  Show first rows
select *
from sales_raw
limit 10; 
#select shows the columns, use * to show all columns
#from indicate the table where the data is stored
#limit set the max number of rows to be shown
#output: first 10 rows of the table sales with all columns 

# Exercise 2: Count how many rows there are in total
select count(*) as total_rows
from sales_raw;
#count is the aggregate function that return the total of rows for all columns (use of *) in a column (with default name count(*))
#as give an alias to the new column
#output: 1 column (total_rows) with the total of the rows of the dataset

#Exercise 3: Show specific columns
select order_date, customer_name, Category , Sales, Profit
from sales_raw
limit 20; 
#use of backticks (``, use ALT + 96) to pick columns with names that have spaces between each word
#use single quotes ('', use ALT + 39) to give alias with spaces
#output: table with 20 rows of just the columns in the select in the same order

#Exercise 4: Show distinct values of 1 column
select distinct Category
from sales_raw; 
# distinct shows the unique values of a specific column

#Exercise 5: Show the date range of the dataset
SELECT 
    MIN(order_date) AS 'Oldest Date',
    MAX(order_date) AS 'Most Recent Date',
    COUNT(DISTINCT order_id) AS 'Total Orders'
FROM sales_raw;
#min and max return those functions 
#count(distinct) indicates the total between the range
#output: 3 columns, with the oldest date, recent date and total order
#Save the file as: week-01-exploration.sql
#Go to cmd and put: cd C:\ARCHIVOS\DOCUMENTS\Alvaro\data-analytics-study\week-01-exploration
					# git add .
					# git commit -m "week-01-day-1: SQL exploration — SELECT, COUNT, DISTINCT, date range"
                    # git push
#Now it is on Github
