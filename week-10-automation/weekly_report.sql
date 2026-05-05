# Week 10 : Automation

#Load schema
USE superstore;

#Exercise 1: Create Index (For West Region)
create index idx_region on sales_raw(region); 
create index idx_category on sales_raw(category);
create index idx_order_date on sales_raw(order_date);
#Check indexes
Show index from sales_raw;
#Verify the query uses the index
EXPLAIN SELECT * FROM sales_raw WHERE Region = 'West';
