-- Order volume by day of week (0 = Sunday ... 6 = Saturday)
select
	extract(dow from purchase_date) as day_of_week,
	count(*) as order_cnt
from clean.active_orders
where purchase_date >= '2017-01-01' and purchase_date < '2018-09-01'
group by 1
order by 1;


-- New customer acquisition trend by month
select
	date_trunc('month', cohort_mth) as month,
	count(*) as new_customers
from clean.customer_first_purchase
where cohort_mth >= '2017-01-01' and cohort_mth < '2018-09-01'
group by 1
order by 1;