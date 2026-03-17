#Week 2: Filter

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
