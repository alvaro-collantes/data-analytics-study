# Week 9 : Visualization

#Load schema
USE superstore;

#Exercise 1: Monthly Sales Trend
Create view monthly_sales as 
Select 
	date_format(order_date,'%Y-%m') as year_months,
    sum(sales) as total_sales,
    sum(profit) as total_profit,
    count(distinct(order_id)) as num_orders
from sales_raw
group by year_months;

select * 
from monthly_sales 
where year_months >= '2017';
