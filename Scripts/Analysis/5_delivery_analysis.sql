-- Does delivery outcome on a customer's first order predict whether they return?
-- Excludes customers whose first order was never delivered (not comparable to late/on-time)
with first_orders as (
	-- Each customer's orders, numbered by purchase date to isolate the first
	select
		o.order_id,
		c.customer_unique_id,
		o.delivered_date,
		o.estimated_delivery_date,
		row_number() over (
			partition by c.customer_unique_id
			order by o.purchase_date asc
		) as rn
	from clean.active_orders o
	left join clean.customers c
		on o.customer_id = c.customer_id
),
first_order_delivery as (
	-- Delivery status of each customer's first order (late vs on time)
	select
		customer_unique_id,
		order_id,
		case
			when delivered_date > estimated_delivery_date then 'late'
			else 'on_time'
		end as delivery_status
	from first_orders
	where rn = 1 and delivered_date is not null
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

-- Retention rate grouped by first-order delivery outcome
select
	fod.delivery_status,
	count(*) as customer_cnt,
	count(*) filter (where oc.order_cnt > 1) as retained_cnt,
	round(
		count(*) filter (where oc.order_cnt > 1)::numeric / count(*) * 100
	, 2) as retention_pct
from first_order_delivery fod
join order_counts oc
	on fod.customer_unique_id = oc.customer_unique_id
group by fod.delivery_status
order by fod.delivery_status;