-- RFM segmentation: score customers on Recency, Frequency, Monetary, then assign a segment
with recency as (
	-- Days since each customer's most recent purchase, relative to the dataset's latest date
	select distinct
		c.customer_unique_id,
		max(purchase_date) over () -
			max(purchase_date) over (partition by c.customer_unique_id) as recency_days
	from clean.active_orders o
	left join clean.customers c
		on o.customer_id = c.customer_id
),
frequency as (
	-- Total number of orders per customer
	select
		customer_unique_id,
		count(*) as orders_cnt
	from clean.active_orders o
	left join clean.customers c
		on o.customer_id = c.customer_id
	group by customer_unique_id
),
monetary as (
	-- Total spend per customer (item price only, excluding freight)
	select
		c.customer_unique_id,
		coalesce(sum(items.price), 0) as customer_spending
	from clean.active_orders o
	left join