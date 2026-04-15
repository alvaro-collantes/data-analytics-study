# Week 6 : Dates

#Load schema
USE superstore;

#Exercise 1: Extract date parts
select 
order_date, 
Year(order_date) as years,
month(order_date) as months, 
date_format(order_date,'%Y-%m') as year_months
from sales_raw
limit 10;

#Exercise 2:Sales by Years and by Months
select 
year(order_date) as years, 
Sum(sales) as total_sales
from sales_raw
group by years
order by years;

#Exercise 3:Sales by Months
select 
month(order_date) as months, 
sum(sales) as total_sales
from sales_raw
group by months
order by months;

#Exercise 4:Shipping time in days
select order_id,order_date,ship_date,
datediff(ship_date,order_date) as shipping_days
from sales_raw
order by shipping_days desc
limit 20;

#Exercise 5:Avg Shipping time by ship mode
select ship_mode,
round(avg(datediff(ship_date,order_date))) as shipping_days
from sales_raw
group by ship_mode
order by shipping_days desc;