# Week 7 : Rankings

#Load schema
USE superstore;

#Exercise 1: Row Number and Rank
select customer_name,
sum(sales) as total_sales,
row_number()over(order by sum(sales) desc) as row_num,
rank()over(order by sum(sales) desc) as rnk_gaps,
dense_rank()over(order by sum(sales) desc) as rnk_nogaps
from sales_raw
group by customer_name
order by total_sales desc
limit 10;

#Exercise 2: Partition Ranks within groups
select region, customer_name,sum(sales) as total_sales,
dense_rank()over(partition by region order by sum(sales) desc) as rnk_region
from sales_raw
group by region, customer_name
order by region,rnk_region
limit 20;
#Partition by make restart at 1 at each region 

#Exercise 3:Lag for month over month

with monthly as (
select date_format(order_date, '%Y-%m') as ym, sum(sales) as total_sales
from sales_raw
group by ym
)
Select ym, total_sales, 
Lag(total_sales,1) over(order by ym) as prev_month_sales,
round(total_sales-Lag(total_sales,1) over(order by ym),2) as monthly_change
from monthly 
order by ym;

#Exercise 4: Running Total
with monthly as( 
select date_format(order_date,'%Y-%m') as ym,
sum(sales) as total_sales
from sales_raw
group by ym
)
select ym, total_sales,
sum(total_sales) over(order by ym) as running_total
from monthly
order by ym;
