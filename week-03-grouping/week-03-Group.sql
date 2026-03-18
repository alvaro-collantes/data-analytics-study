# Week 3 : Grouping

#Load schema
USE superstore;

#Exercise 1: Sales by category
select category,sum(sales) as total_sales
from sales_raw
group by category;

#Exercise 2: Multiple metrics with Order By
select category, sum(sales) as total_sales, avg(sales) as avg_sales, max(sales) as max_sales, sum(profit) as total_profit,
round(sum(profit)/sum(sales) * 100,2) as margin_pct
from sales_raw
group by category
order by total_sales desc;

#Exercise 3: Group by two columns
select region, category, sum(sales) as total_sales 
from sales_raw
group by region, category
order by total_sales desc;

#Exercise 4: filter groups after aggregation (total sales higher than 75K)
select category, sum(sales) as total_sales
from sales_raw
group by category 
having sum(sales) > 75000;
