#Raw data

#Step 0:Verify SQL verification
#verify if it is ON, if it is ON, go to Step 1
show variables like 'local_infile';
#in case it is OFF, close, open, edit connections and add OPT_LOCAL_INFILE = 1 in advanced tab
#connect to sql and run
set global local_infile = 1;
show variables like 'local_infile';

#Step 1:Create database and table headers
create database if not exists storeprac;
use storeprac;
#explore the headers on the cmd: more absolute path of csv
#avoid using spaces or capital letter, easier for manipulation
#use varchar for all the data types
create table if not exists sales (
row_id varchar(50),
order_id varchar(50),
order_date varchar(50),
ship_date varchar(50),
ship_mode varchar(50),
customer_id varchar(50),
customer_name varchar(50),
segment varchar(50)
,country varchar(50),
city varchar(50),
state varchar(50),
postal_code varchar(50),
region varchar(50),
product_id varchar(50),
category varchar(50),
sub_category varchar(50),
product_name varchar(50),
sales varchar(50),
quantity varchar(50),
discount varchar(50),
profit varchar(50)
	);

#Step 2:Load data
load data local infile 'C:/ARCHIVOS/DOCUMENTS/Alvaro Universidad/M2 FIT/Practice/Sample - Superstore.csv'
into table sales
character set latin1
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines; 

#Step 3:Explore the data
select count(*) as total_rows
from sales;
select *
from sales;
#check correct data types
#date:order_date,ship_date
#decimal:sales,discount,profit
#int:row_id,quantity
#varchar:the others

#Step 4:Create new table with correct data types
drop table if exists sales_cor;
create table sales_cor as
select
cast(row_id as signed) as row_id,
order_id,
str_to_date(order_date , '%m/%d/%Y') as order_date,
str_to_date(ship_date , '%m/%d/%Y') as ship_date,
ship_mode ,
customer_id ,
customer_name ,
segment,
country ,
city ,
state ,
postal_code ,
region ,
product_id ,
category ,
sub_category ,
product_name ,
cast(sales as decimal(10,2)) as sales ,
cast(quantity as unsigned) as quantity,
cast(discount as decimal(5,4)) as discount,
cast(profit as decimal(10,2)) as profit
from sales;

#verify
select count(*) as total_rows
from sales_cor;
describe sales_cor;

