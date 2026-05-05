# Week 10 : Automation

#Load schema
USE superstore;

#Exercise 1: Create Index (For West Region)
create index idx_region on sales_raw(region); 
create index idx_category on sales_raw(category);
create index idx_order_date on sales_raw(order_date);
#Check indexes
Show index from sales_raw;
#Verify the query uses the index
EXPLAIN SELECT * FROM sales_raw WHERE Region = 'West';

#Exercise 2: Create the view 
CREATE VIEW v_sales_detail AS
SELECT
    YEAR(order_date)            AS year,
    MONTH(order_date)           AS month,
    DATE_FORMAT(order_date, '%Y-%m') AS year_months,
    Category, Region, Segment,
    SUM(sales)                  AS total_sales,
    SUM(profit)                 AS total_profit,
    COUNT(*)                    AS num_rows
FROM sales_raw
GROUP BY year, month, year_months, Category, Region, Segment;

#Filter Query for a year and region 
SELECT * FROM v_sales_detail 
WHERE year = 2017 AND Region = 'West';