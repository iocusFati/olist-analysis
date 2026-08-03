-- View: each customer's first purchase month (their cohort)
create view clean.customer_first_purchase as
select
	c.customer_unique_id,
	date_trunc('month', min(o.purchase_date)) cohort_mth
from clean.active_orders o
left join clean.customers c
	on o.customer_id = c.customer_id
group by 1


-- Cohort retention analysis
with customer_purchase as (
	-- Every distinct month each customer purchased in, alongside their cohort month
	select distinct
		c.customer_unique_id,
		cohort_mth,
		date_trunc('month', o.purchase_date) as purchase_mth
	from clean.active_orders o
	left join clean.customers c
		on o.customer_id = c.customer_id
	left join clean.customer_first_purchase fp
		on c.customer_unique_id = fp.customer_unique_id
),
cohort_counts as (
	-- Number of active customers per cohort per period (months since first purchase)
	select
		cohort_mth,
		(extract(year from cp.purchase_mth) * 12 + extract(month from cp.purchase_mth)) -
			(extract(year from cp.cohort_mth) * 12 + extract(month from cp.cohort_mth)) as month_from_purchase,
		count(distinct customer_unique_id) customer_cnt
	from customer_purchase cp
	group by 1,2
	order by cohort_mth, month_from_purchase
)

-- Final output: retention % per cohort per period, relative to each cohort's starting size
select
	curr_cohort.cohort_mth,
	curr_cohort.month_from_purchase,
	curr_cohort.customer_cnt,
	round(curr_cohort.customer_cnt::numeric / zero_cohort.customer_cnt * 100, 2) as retention_pct
from cohort_counts curr_cohort
inner join cohort_counts zero_cohort
	on curr_cohort.cohort_mth = zero_cohort.cohort_mth
		and zero_cohort.month_from_purchase = 0;