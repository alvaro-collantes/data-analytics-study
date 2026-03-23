# Week 4 : Joins

#Load schema
USE superstore;

#Exercise 0: Create 2 tables to work

#Table 1:Unique Orders (1 row per order)
create table orders as 
select distinct(order_id) , order_date, customer_id, region, segment from sales_raw;
#Test
select count(*) from orders;

#Table 2:Line items(1 row per product in an order)
create table line_items as 
select order_id, product_name, category, sales, profit from sales_raw;
#Test
select count(*) from line_items;

#Exercise 1:Get the orders that match by segment, region, product name, category and sales
select 
	o.order_id, o.order_date, o.segment, o.region,
	d.product_name, d.category,d.sales
from orders o
join line_items d on o.order_id=d.order_id
limit 10;

#Exercise 2:Get the num of orders , total sales and avg ticket by segment
select 
	o.segment, count(distinct o.order_id) as num_orders,
    sum(d.sales) as total_sales,
    round(avg(d.sales),2) as avg_ticket
from orders o 
join line_items d on o.order_id=d.order_id
group by o.segment 
order by total_sales desc;

#Exercise 3:Find unmatched rows (find the nulls)
#1. Add an order in the table that does not match
insert into orders(order_id, order_date,customer_id,region,segment)
values ('CA-FAKE-001','2017-06-15','CUST-999','West','Consumer');

select 
	o.order_id, d.sales, o.order_date
from orders o
left join line_items d on o.order_id=d.order_id
where d.order_id is null; 

 