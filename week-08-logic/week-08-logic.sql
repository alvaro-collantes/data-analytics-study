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

#Exercise 2: customers whose total sales exceed the overall average
select customer_name,sum(sales) as total_sales
from sales_raw
group by customer_name
having sum(sales) > (
	select avg(total_per_customer)
    from (select customer_name, sum(sales) as total_per_customer
			from sales_raw
			group by customer_name) as customer_total
)
order by total_sales desc 
limit 5;

#Exercise 3: Classification 
select order_id, sales, profit,
case 
	when profit < 0 then 'Loss'
    when profit/sales >= 0.25 then 'High Margin'
    when profit/sales >= 0.10 then 'Medium Margin'
    else 'Low Margin'
end as margin_tier
from sales_raw
limit 20;

