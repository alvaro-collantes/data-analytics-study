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

#Aditional Practice
USE superstore;

select *
from sales_raw
limit 10;

SELECT 
    MIN(ship_date) AS 'Oldest Date',
    MAX(ship_date) AS 'Most Recent Date',
    COUNT(DISTINCT order_id) AS 'Total Orders'
FROM sales_raw;

#Filter
#How many orders were in year 2019?
SELECT count('order_date') as Orders_2019
from sales_raw
Where order_date between '2014-01-01' and '2014-12-31';

#How many orders were in year 2018?
SELECT count('order_date') as Orders_2015
from sales_raw
Where order_date between '2015-01-01' and '2015-12-31';

#Know the number of orders for each year 
select Year(order_date) as Years, count(*) as 'Total Orders'
from sales_raw
group by Years
order by Years;

#What is the total profit by years
select Year(order_date) as Years, count(*) as 'Total Orders', sum(profit) as 'Total Profit'
from sales_raw
group by Years
order by Years;

#Always the columns in the SELECT MUST be a column in the GROUP BY or a AGGREGATE FUNCTION

#unique values of sub category
select distinct sub_category as sub
from sales_raw;

#Show the count in the subcategory when it starts with e
select count('sub_category') as sub_cat
from sales_raw
where sub_category like 'e%';

#Show dates and id when postal code is greater than 40000
select order_date, ship_date, customer_id
from sales_raw
where postal_code >40000;

#Aditional Practice
USE superstore;

select *
from sales_raw;

#Use of IN
select row_id, order_date,customer_name,city, sales * quantity as Income
from sales_raw
where region IN('South','West')
order by Income Asc
limit 10;

#What is the total sales amount and number of transactions by region, category and sub-category, only considering orders with a profit greater than or equal to $100? Order the results by category.
select region, category, sub_category,sum(sales) as 'Total Sales', count(*) as 'Total Count'
from sales_raw
where profit >= 100
group by region, category, sub_category
order by category asc;
# GROUP BY must include ALL non-aggregated columns from SELECT
# Aggregate functions (SUM, COUNT, AVG, MIN, MAX) in SELECT 
# are what make GROUP BY useful — they calculate one value per group
# Without aggregate functions, GROUP BY behaves like DISTINCT

#Practice queries
Use superstore;
select *
from sales_raw;
# 1. What is the average discount and total profit by segment and region,
#    only for orders shipped via Second Class? Order by total profit descending.

select segment,region, avg(discount) as 'Discount (Avg)',sum(profit) as 'Total Profit'
from sales_raw
where ship_mode = 'Second Class'
group by segment, region
order by `Total Profit` Desc;
#You can put in the select ex columns 1,2,3,aggfunction col4, and in the where, you can put the condition on column 8. It will work
#Aggregate Functions were in select, and in group, it is the other columns of the select

# 2. How many unique customers placed orders in each region per year?
#    Only include years with more than 100 unique customers.

select year(order_date) as Years ,region, count(distinct customer_id) as Unique_Customers
from sales_raw
group by Years, region
Having Unique_Customers > 100
order by Years Asc ;
#Why when i filter unique customers >100, i have an empty table and without it, i have a table with the count of the unique customers (all >100)
#Fixed: moved filter from WHERE to HAVING — aggregate functions need HAVING
# Dont use where to filter on aggregate functions, use having always 

# 3. What is the total sales and total quantity sold by category,
#    only for orders where the discount is greater than 0?
#    Include the average sales per order.

select category ,sum(sales) as 'Total Sales', sum(quantity) as 'Total Quantity', avg(sales) as 'Avg Sales Per Order'
from sales_raw
where discount > 0
group by category
order by category
;
#I just need categories, not row id

# 4. Which ship modes have an average delivery time greater than 4 days?
#    Show the ship mode and the average days to ship.

select ship_mode, avg(DATEDIFF(ship_date, order_date)) as Avg_Delivery_Time
from sales_raw
group by ship_mode
having Avg_Delivery_Time >4
order by 1;

#Why when i filter Avg Delivery Time >4, i have an empty table and without it, i have a table with the count of the Avg Delivery Time (all >4)
#Fixed: moved filter from WHERE to HAVING — aggregate functions need HAVING
#use dateiff and the columns to get the difference betweem two dates, always put the end date,start date 


# 5. What is the total profit by sub-category, only for the West and East regions?
#    Exclude sub-categories with a total loss (negative profit).

select sub_category,region, sum(profit) as Total_Profit
from sales_raw
where region IN('West','East')
group by sub_category,region
HAVING Total_Profit > 0
order by 1;
#Is not say to have the region as a column, but for better presentation, is better to include it 
#Use having as other condition(has the agg funct)
#Why is not working the condition on the total profit col? 

#Rules
# WHERE: filter before group by, dont use alias or aggregate functions
# HAVING: filter groups after group by, it does accept alias or aggregate functions
# DATEDIFF: difference between 2 dates (end, start)
# ORDER BY alias: dont use "" or '', use `` if the name has spaces 
#You can define the alias with '' in select, but you can use it in other statement always with ``, otherwise it wont work

#additional practice

# 6. What is the total sales and total profit by category and year?
#    Only include combinations where total sales exceed $50,000.
#    Order by year ascending and total sales descending.

select year(order_date) as Years, category, sum(sales) as 'Total Sales', sum(profit) as 'Total Profit'
from sales_raw
group by Years, category
having `Total Sales` > 50000
order by Years ASC, `Total Sales` Desc
;
#use having for agg func
#you can order by 2 columns 
#use the backstrings for the name with spaces

# 7. Which regions have an average order value (sales) greater than $230?
#    Show the region, average order value and total number of orders.

select region, avg(sales) as 'Avg Sales', count(sales) as 'Total Orders'
from sales_raw
group by region 
having `Avg Sales` > 230
order by 1 asc;

#same as before use of having and backstrings

# 8. What is the total quantity sold and average discount by ship mode and segment?
#    Only for orders placed in 2016 and 2017.
#    Exclude combinations with an average discount of 0.

select year(order_date) as Years, ship_mode, segment, sum(quantity) as 'Total Quantity', avg(discount) as 'Avg Discount'
from sales_raw
Where year(order_date) IN('2016','2017')
group by Years, ship_mode, segment
having `Avg Discount` != 0 
order by Years asc
;
#exclude combinations, so show everything that it is not 0, use != or <>
#Years is an date funct, so it has to be used inside where NOT WITH THE ALIAS (where doesnt allow it, it must be with the date funct)

# 9. How many orders were placed each month of 2017?
#    Only include months with more than 250 orders.
#    Order by month ascending.

select month(order_date) as Months, count(order_date) as 'Total Orders'
from sales_raw
where year(order_date) = 2017
group by Months
having `Total Orders` > 250
order by Months Asc
;
#Month is date func, use with where, and add where

# 10. What is the total profit and number of orders by region and segment?
#     Only include orders where sales are greater than $100.
#     Exclude groups where total profit is negative.
#     Order by total profit descending.

select region, segment, sum(profit) as 'Total Profit', count(profit) as 'Total Orders'
from sales_raw
where sales > 100
group by region, segment
having `Total Profit` > 0
order by `Total Orders` Desc
;
#same as before, practice, add where filter of sales 

# 11. Which sub-categories have an average sales per order greater than $200?
#     Show sub-category, average sales and total number of orders.
#     Only consider orders with no discount applied.

select sub_category, avg(sales) as 'Avg Sales', count(sales) as 'Total Orders'
from sales_raw
where discount = 0
group by sub_category
having `Avg Sales` > 200
order by `Avg Sales` desc
;
#careful with the name of the columns

# 12. What is the total sales by customer segment for each year?
#     Only include years where total sales across all segments exceed $100,000.
#     Order by year and total sales descending.

select year(order_date) as Years ,segment, sum(sales) as 'Total Sales'
from sales_raw
group by Years, segment
having `Total Sales` > 100000
order by Years Desc, `Total Sales` desc
;

# 13. Which cities have more than 20 unique customers?
#     Show city, state, region and number of unique customers.
#     Order by unique customers descending.

select city,state,region, count(distinct(customer_id)) as 'Unique Customer'
from sales_raw
group by city, state, region
having `Unique Customer` > 20
order by `Unique Customer` desc
;

# 14. What is the average profit per order by category and ship mode?
#     Only include ship modes where the average profit is greater than $20.
#     Exclude orders with a discount greater than 0.3.

select category, ship_mode, avg(profit) as 'Avg Profit'
from sales_raw
where discount <= 0.3
group by category, ship_mode
having `Avg Profit` > 20
order by `Avg Profit` Desc
;
#include the 0.3

# 15. How many orders contain more than one product (more than one row
#     with the same order_id)? Show order_id, customer_name, region
#     and number of products per order.
#     Only include orders with more than 3 products.
#     Order by number of products descending.

select order_id, customer_name, region, count(distinct(product_id)) as 'Products per Order' 
from sales_raw
group by order_id, customer_name,region 
having `Products per Order` > 3
order by `Products per Order` Desc
;

#practice

# 1. What is the total sales and average profit by state?
#    Only include states where total sales exceed $30,000.
#    Exclude states with negative average profit.
#    Order by total sales descending.

select state, sum(sales) as total_sales, avg(profit) as avg_profit
from sales_raw
group by state
having total_sales > 30000 and avg_profit > 0
order by total_sales desc
;
#create 2 agg funct & use them as filter with and operator

# 2. How many unique products were sold by category and region?
#    Only include orders placed in 2015 and 2016.
#    Only show combinations with more than 100 unique products.
#    Order by category ascending.

select category, region, count(distinct(product_id)) as total_products 
from sales_raw
where year(order_date) in ('2015','2016')
group by category, region
having total_products > 100
order by category asc;
#use years as filter in when(not alias, just the sintax) and use it for grouping 
#dont use years in select or group by, it was not requested, the question just need category and region

# 3. What is the total quantity sold and average sales by segment and ship mode?
#    Only include orders where profit is greater than 0.
#    Exclude combinations where average sales are below $150.
#    Order by segment and average sales descending.

select segment, ship_mode, sum(quantity) as total_quantity_sold,avg(sales) as avg_sales
from sales_raw
where profit > 0
group by segment, ship_mode
having avg_sales >= 150
order by segment desc, avg_sales desc;

# 4. Which product categories have more than 500 orders with a discount
#    greater than 0.15? Show category, number of orders and average discount.
#    Order by number of orders descending.

select category, count(*) as total_orders, avg(discount) as avg_discount
from sales_raw
where discount > 0.15
group by category
having total_orders > 500
order by total_orders desc
;
#consider in the count(*) always as total orders 
#discount is the filter in where, not the avg_discount

# 5. What is the average delivery time in days by region and ship mode?
#    Only include orders from 2017.
#    Show only combinations where average delivery time is between 2 and 6 days.
#    Order by region and average delivery time ascending.

select region,ship_mode,avg(datediff(ship_date,order_date)) as avg_delivery_time
from sales_raw
where year(order_date) = 2017
group by region, ship_mode
having avg_delivery_time between 2 and 6 
order by region asc, avg_delivery_time asc
;

# CASE WHEN

# 6. Classify each order as 'High' (sales > 500), 'Medium' (sales between 100 and 500)
#    or 'Low' (sales < 100). Show the order_id, sales and the classification.
#    Order by sales descending.

select order_id, sales,
case 
when sales > 500 then 'High'
when sales between 100 and 500 then 'Medium'
when sales < 100 then 'Low'
end as classification
from sales_raw
order by sales desc
;
#Use case in select to generate new coumn with the classification, do not use , after then

# 7. For each category, show the total sales and classify the category as
#    'Top Performer' if total sales exceed $800,000, 'Mid Performer' if between
#    $400,000 and $800,000, or 'Low Performer' if below $400,000.

select category, 
case 
when sum(sales) > 800000 then 'Top Performer'
when sum(sales) between 400000 and 800000 then 'Mid Performer'
when sum(sales) < 400000 then 'Low Performer'
end as performance
from sales_raw
group by category
;
#use the case when with a agg function as condition


# 8. Show each region with its total profit and classify it as 'Profitable'
#    if total profit is positive or 'Loss' if negative.
#    Order by total profit descending.

select region, 
case 
when sum(profit)> 0 then 'Profitable'
when sum(profit)<0 then 'Loss'
end as classification
from sales_raw
group by region
order by sum(profit) desc
;
#use agg funct in order by , and in the case when 

# 9. For each order, calculate the profit margin (profit/sales) and classify it as
#    'Excellent' (>30%), 'Good' (10-30%), 'Break Even' (0-10%) or 'Loss' (negative).
#    Show order_id, sales, profit, profit margin and classification.
#    Only show orders where sales are greater than $500.

select order_id,sales,profit, profit/sales as 'profit margin',
case 
when profit/sales  > 0.3 then 'Excellent'
when profit/sales  between 0.1 and 0.3 then 'Good'
when profit/sales  between 0 and 0.1 then 'Break Even'
when profit/sales  < 0 then 'Loss'
end as classification
from sales_raw
where sales > 500
order by sales desc
;
#use the arithmethic expression inside the when clause,why can not i call the name of the column of the arithemtic expression?
#also, because here i want to see the whole table, not the segmented in groups, i didnt need to put an agg function to the calculation of the ratio, otherwise if
#i want to see the group version, i need to add the agg funct : Sum for the ratio

# 10. Count how many orders are 'Profitable' (profit > 0) and how many are
#     'Loss' (profit <= 0) per category and region.
#     Show category, region, profitable_orders and loss_orders in the same row.
#     Order by category.

select category, region, 
sum(case 
when profit > 0 then 1 else 0 end) as profitable_orders,
sum(case 
when profit <= 0 then 1 else 0 end) as loss_orders
from sales_raw
group by category, region
order by category;
#To count the total of the columns created, use the Sum before the case, and in the when use 1 for true value and 0 for the false

# Mix of WHERE, GROUP BY, HAVING, CASE WHEN, DATEDIFF
# Higher complexity: multiple conditions and logic combined

# 1. For each region and year, calculate the total sales, total profit
#    and profit margin percentage (profit/sales*100).
#    Classify the year as 'Growth' if profit margin > 15%,
#    'Stable' if between 5% and 15%, or 'Critical' if below 5%.
#    Only include years where total sales exceed $100,000.
#    Order by region and year ascending.

select year(order_date) as years, region, sum(sales) as total_sales, sum(profit) as total_profit, (sum(profit)/sum(sales)) * 100 as profit_margin,
case 
when (sum(profit)/sum(sales)) * 100 > 15 then 'Growth'
when (sum(profit)/sum(sales)) * 100 between 5 and 15 then 'Stable'
when (sum(profit)/sum(sales)) * 100 < 5 then 'Critical'
end as classification
from sales_raw
group by region, years
having total_sales > 100000
order by region asc , years asc 
;
#i am using group by, that is why i need to add the sum, because without it and using group by, it wont work at least i removed
#the group by, but i will have a table instead of the groups
#Important: inside group by never use an agg function
			#to use the group by, you use the agg functions inside the select, otherwise there is no sense to use it
            #understand the diff between showing each order (all the lines) so i dont need an agg function in the calculation , so i dont need group by
            #and each region(column) , here i need the agg function, so the group by

# 2. Which segments have more profitable orders than loss orders?
#    Show segment, number of profitable orders, number of loss orders
#    and the difference between them.
#    Order by difference descending.

SELECT segment, 
    SUM(CASE WHEN profit > 0 THEN 1 ELSE 0 END) AS profitable_orders,
    SUM(CASE WHEN profit <= 0 THEN 1 ELSE 0 END) AS loss_orders,
    SUM(CASE WHEN profit > 0 THEN 1 ELSE 0 END) - SUM(CASE WHEN profit <= 0 THEN 1 ELSE 0 END) AS diff_orders
FROM sales_raw
GROUP BY segment
HAVING profitable_orders > loss_orders
ORDER BY diff_orders DESC;

#for count use sum(case when... 
#for the difference, use all the expresion, not the alias
#use having to know the more profitable orders than loss orders? (greater than)

# 3. For each ship mode, calculate the average delivery time by year.
#    Classify delivery performance as 'Fast' (avg < 3 days),
#    'Normal' (3-5 days) or 'Slow' (> 5 days).
#    Only include years from 2015 onwards.
#    Exclude ship modes where average delivery time is 0.
#    Order by year and average delivery time ascending.

# 4. Show the total sales, total profit and number of orders by category
#    for orders that had a discount applied (discount > 0) vs no discount (discount = 0).
#    Show both groups in the same row per category using CASE WHEN.
#    (Hint: use SUM with CASE WHEN like Q10 from the previous set)

# 5. Which states have a higher number of loss orders than profitable orders?
#    Show state, region, profitable orders, loss orders and total orders.
#    Only include states with more than 50 total orders.
#    Order by loss orders descending.

# 6. For each category and segment, calculate:
#    - Total sales
#    - Average discount
#    - Total profit
#    - Profit margin % (profit/sales*100)
#    Only include combinations where:
#    - Total sales exceed $50,000
#    - Average discount is less than 0.3
#    - Profit margin is greater than 5%
#    Order by profit margin descending.

# 7. Calculate the average number of days between order and ship date
#    by region and segment.
#    Classify as 'Express' (< 2 days), 'Standard' (2-4 days) or 'Delayed' (> 4 days).
#    Only include orders from 2016 and 2017 where profit > 0.
#    Exclude combinations where average delivery time is 0.
#    Order by region and average delivery time ascending.

# 8. For each year and region, show:
#    - Total orders
#    - Orders with discount (discount > 0)
#    - Orders without discount (discount = 0)
#    - Percentage of orders with discount (discounted/total*100)
#    Only include combinations where percentage of discounted orders exceeds 40%.
#    Order by year and percentage descending.

# 9. Which sub-categories had their best sales year in 2017?
#    Show sub-category, total sales in 2016, total sales in 2017
#    and the growth percentage ((2017-2016)/2016*100).
#    Only include sub-categories where 2017 sales are higher than 2016.
#    Order by growth percentage descending.
#    (Hint: you will need CASE WHEN inside SUM for each year)

# 10. For each region, classify each order by delivery speed:
#     'Same Day' (0 days), 'Express' (1-2 days),
#     'Standard' (3-5 days), 'Slow' (> 5 days).
#     Show region, count of orders per delivery classification,
#     total sales per classification and average profit per classification.
#     Only include orders from 2017 where sales > 100.
#     Order by region and total sales descending.



# --- INTERMEDIATE-ADVANCED ---

# 6. For each category, what percentage of total company sales does it represent?
#    Show category, total sales and the percentage.

# 7. Which customers have placed more than 5 orders and have a total profit
#    greater than $500? Show customer name, number of orders and total profit.

# 8. What is the most sold sub-category (by quantity) in each region?

# 9. Show the top 3 cities by total sales within each region.

# 10. Which categories had higher total sales in 2017 compared to 2016?
#     Show the category, sales in 2016, sales in 2017 and the difference.

# --- ADVANCED ---

# 11. For each customer, what is their most recent order date and how many days
#     ago was it from the last date in the dataset?

# 12. What is the month-over-month sales growth percentage for the year 2017?

# 13. Which products have been ordered in every single region?

# 14. For each region, show the category that generates the highest
#     profit margin (profit/sales).

# 15. Rank customers by total sales within each segment,
#     showing only the top 3 per segment.