create database Customers_transactions;

update customers set gender = null where gender = '';
update customers set age = null where age = '';

alter table customers modify age int null;

select * from customers;

create table transactions
(date_new date,
Id_check int,
ID_client int,
Count_products decimal(10,3),
Sum_payment decimal(10,2));

load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions_final.csv"
into table transactions
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;

select * from transactions;

drop table transactions;