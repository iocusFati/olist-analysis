-- Overall retention rate, restricted to customers whose first order was actually delivered
with first_orders as (
	-- Each customer's orders, numbered by purchase date to find their first
	select
		o.order_id,
		c.customer_unique_id,
		o.delivered_date,
		row_number() over (
			partition by c.customer_unique_id
			order by o.purchase_date asc
		) as rn
	from clean.active_orders o
	left join clean.customers c
		on o.customer_id = c.customer_id
),
delivered_first_orders as (
	-- Customers whose first order has a confirmed delivery date
	select customer_unique_id
	from first_orders
	where rn = 1
		and delivered_date is not null
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

-- Final retention rate among customers whose first order was delivered
select
	count(*) as total_customers,
	count(*) filter (where oc.order_cnt > 1) as repeat_customers,
	round(
		count(*) filter (where oc.order_cnt > 1)::numeric / count(*) * 100
	, 2) as retention_pct
from delivered_first_orders dfo
join order_counts oc
	on dfo.customer_unique_id = oc.customer_unique_id