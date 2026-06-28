/*1. Выведите список клиентов с непрерывной историей за год, то есть каждый месяц на регулярной основе без пропусков за указанный годовой период,
средний чек за период с 01.06.2015 по 01.06.2016, средняя сумма покупок за месяц, количество всех операций по клиенту за период; */

with Continuous as (select id_client
from
(select distinct id_client, date_new from transactions
order by id_client, date_new) as CustomersDates
where date_new between '2015-06-01' and '2016-05-01'
group by id_client
having count(date_new) = 12)

select id_client, round(sum(sum_payment) / count(distinct id_check), 2) as avg_check, round(sum(sum_payment) / 12, 2) as avg_monthly_purchases, count(distinct id_check) as total_operations
from transactions
where id_client in (select id_client from Continuous)
group by id_client
order by id_client;

/*2. Выведите информацию в разрезе месяцев:
a) средняя сумма чека в месяц;
b) среднее количество операций в месяц;
c) среднее количество клиентов, которые совершали операции;
d) долю от общего количества операций за год и долю в месяц от общей суммы операций;
e) вывести % соотношение M/F/NA в каждом месяце с их долей затрат;
 */

select date_new, round(sum(sum_payment) / count(distinct id_check), 2) as avg_monthly_check, round(count(distinct id_check) * 1.0 / count(distinct transactions.id_client), 2) as avg_monthly_operations_per_client,
count(distinct transactions.id_client) as monthly_active_users,
round((count(distinct id_check) * 1.0 / sum(count(distinct id_check)) over()) * 100, 2) as share_of_yearly_operations,
round((sum(sum_payment) * 1.0 / sum(sum(sum_payment)) over()) * 100, 2) as share_of_yearly_revenue,
round((count(distinct case when gender = 'M' then transactions.id_client end) * 1.0 / count(distinct transactions.id_client)) * 100, 2) as male_customers_share,
round((sum(case when gender = 'M' then sum_payment else 0 end) * 1.0 / sum(sum_payment)) * 100, 2) as male_customers_spending_share,
round((count(distinct case when gender = 'F' then transactions.id_client end) * 1.0 / count(distinct transactions.id_client)) * 100, 2) as female_customers_share,
round((sum(case when gender = 'F' then sum_payment else 0 end) * 1.0 / sum(sum_payment)) * 100, 2) as female_customers_spending_share,
round((count(distinct case when gender is Null then transactions.id_client end) * 1.0 / count(distinct transactions.id_client)) * 100, 2) as na_customers_share,
round((sum(case when gender is Null then sum_payment else 0 end) * 1.0 / sum(sum_payment)) * 100, 2) as na_customers_spending_share
from transactions join customers on transactions.id_client = customers.id_client
group by date_new
order by date_new;

/*3. Выведите возрастные группы клиентов с шагом 10 лет и отдельно клиентов, у которых нет данной информации, с параметрами сумма и количество операций за весь период,
и поквартально - средние показатели и %.*/
select min(age), max(age)
from customers;

select case
when c.age between 1 and 10 then '1-10'
when c.age between 11 and 20 then '11-20'
when c.age between 21 and 30 then '21-30'
when c.age between 31 and 40 then '31-40'
when c.age between 41 and 50 then '41-50'
when c.age between 51 and 60 then '51-60'
when c.age between 61 and 70 then '61-70'
when c.age between 71 and 80 then '71-80'
when c.age between 81 and 90 then '81-90'
when c.age > 90 then '90+'
when c.age is null then 'N/A'
end as age_group, sum(sum_payment) as total_spending, count(distinct id_check) as total_operations
from customers c right join transactions t on c.id_client = t.id_client
group by 1;

with QuarterData as (select year(date_new) as order_year, quarter(date_new) as order_quarter, case
when c.age between 1 and 10 then '1-10'
when c.age between 11 and 20 then '11-20'
when c.age between 21 and 30 then '21-30'
when c.age between 31 and 40 then '31-40'
when c.age between 41 and 50 then '41-50'
when c.age between 51 and 60 then '51-60'
when c.age between 61 and 70 then '61-70'
when c.age between 71 and 80 then '71-80'
when c.age between 81 and 90 then '81-90'
when c.age > 90 then '90+'
when c.age is null then 'N/A'
end as age_group,
sum(t.sum_payment) as total_spending, count(distinct t.id_check) as total_operations, count(distinct t.id_client) as total_active_customers
from transactions t left join customers c using(id_client)
where t.date_new between '2015-06-01' and '2016-05-01'
group by 1, 2, 3
order by 1, 2, 3)

select order_year, order_quarter, age_group, round(total_spending / total_operations, 2) as avg_check, round(total_operations / total_active_customers, 2) as avg_purchases_per_client,
round((total_spending / sum(total_spending) over(partition by order_year, order_quarter)) * 100, 2) as age_group_spending_percent,
round((total_operations / sum(total_operations) over(partition by order_year, order_quarter)) * 100, 2) as age_group_operations_percent
from QuarterData
order by 1, 2, 3