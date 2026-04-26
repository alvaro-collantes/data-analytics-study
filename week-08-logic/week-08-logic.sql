# Week 8 : Logic

#Load schema
USE superstore;

#Exercise 1: Rank of the monthly sales
With monthly_sales as (
select date_format(order_date,'%Y-%m') as ym, sum(sales) as total_sales
from sales_raw
group by ym), 
ranked_months as (
select ym, total_sales,
rank() over(order by total_sales desc) as rnk
from monthly_sales)
select * 
from ranked_months
where rnk <= 5
;