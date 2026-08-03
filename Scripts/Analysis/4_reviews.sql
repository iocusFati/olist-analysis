-- % of active orders that have at least one review
select
	round(
		count(distinct r.order_id)::numeric / count(distinct o.order_id) * 100
	, 2) as pct_orders_with_review
from clean.active_orders o
left join clean.order_reviews r
	on o.order_id = r.order_id;


-- Distribution of review scores across all reviews
select
	review_score,
	count(*)
from clean.order_reviews
group by 1;


-- Does the review score on a customer's first order predict whether they return?
with first_orders as (
	-- Each customer's orders, numbered by purchase date to isolate the first
	select
		o.order_id,
		c.customer_unique_id,
		row_number() over (
			partition by c.customer_unique_id
			order by o.purchase_date asc
		) as rn
	from clean.active_orders o
	left join clean.customers c
		on o.customer_id = c.customer_id
),
first_order_score as (
	-- Review score of each customer's first order
	select
		fo.customer_unique_id,
		fo.order_id,
		r.review_score
	from first_orders fo
	left join clean.order_reviews r
		on fo.order_id = r.order_id
	where fo.rn = 1
),
order_counts as (
	-- Total order count per customer, to determine repeat purchase behavior
	select
		c.customer_unique_id,
		count(*) as order_cnt
	from clean.active_orders o
	left join clean.customers c
		on o.customer_id = c.customer_id
	group by c.customer_unique_id
)

-- Retention rate grouped by first-order review score
select
	fos.review_score,
	count(*) as customer_cnt,
	count(*) filter (where oc.order_cnt > 1) as retained_cnt,
	round(
		count(*) filter (where oc.order_cnt > 1)::numeric / count(*) * 100
	, 2) as retention_pct
from first_order_score fos
join order_counts oc
	on fos.customer_unique_id = oc.customer_unique_id
group by fos.review_score
order by fos.review_score