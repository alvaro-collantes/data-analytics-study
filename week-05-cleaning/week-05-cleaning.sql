# Week 5 : Cleaning

#Load schema
USE superstore;

#Exercise 1: Handle null values (coalesce)
select 
	order_id,
    coalesce(postal_code,'Unknown') as `Postal Code` ,
    coalesce(profit,0) as Profit
from sales_raw
limit 15;

#Exercise 2: Standarize text
select
	trim(customer_name) as clean_name,
    Upper(category) as category_upper,
    lower(region) as region_lower
from sales_raw
limit 15;

#Exercise 3: Fix data types(Cast)
select 
	cast(sales as Real) as sales_numeric
from sales_raw
limit 5;

#Exercise 4: Find the counts nulls per column
select 
	sum(case when order_id is null then 1 else 0 end) as null_order_id,
    sum(case when customer_name is null then 1 else 0 end) as null_customer_name,
    sum(case when postal_code is null then 1 else 0 end) as null_postal_code,
    sum(case when sales is null then 1 else 0 end) as null_sales
from sales_raw;