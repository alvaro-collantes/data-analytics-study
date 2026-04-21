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


