-- Revenue concentration by order value bracket
with percentile_values as (
	-- Calculate percentile boundaries (p10, p25, p50, p75, p90) across all order totals
	select
		percentile_cont(0.10) within group (order by order_total) as p10,
		percentile_cont(0.25) within group (order by order_total) as p25,
		percentile_cont(0.50) within group (order by order_total) as p50,
		percentile_cont(0.75) within group (order by order_total) as p75,
		percentile_cont(0.90) within group (order by order_total) as p90
	from (
		select
			o.order_id,
			sum(items.price) as order_total
		from clean.active_orders o
		left join clean.order_items items
			on items.order_id = o.order_id
		group by o.order_id
	) t
),
orders_totals as (
	-- Total value and item count per order
	select
		o.order_id,
		max(order_item_id) as items_in_order,
		sum(items.price) as order_total
	from clean.active_orders o
	inner join clean.order_items items
		on items.order_id = o.order_id
	group by o.order_id
),
totals_ranked as (
	-- Assign each order to a percentile-based bracket, with both a numeric rank
	-- (for sorting) and a readable price range label (for display)
	select
		ot.order_id,
		ot.items_in_order,
		ot.order_total,
		case
			when ot.order_total <= pv.p10 then 1
			when ot.order_total <= pv.p25 then 2
			when ot.order_total <= pv.p50 then 3
			when ot.order_total <= pv.p75 then 4
			when ot.order_total <= pv.p90 then 5
			else 6
		end as bucket_rank,
		case
			when ot.order_total <= pv.p10 then '0 - ' || round(pv.p10::numeric, 2)
			when ot.order_total <= pv.p25 then round(pv.p10::numeric, 2) || ' - ' || round(pv.p25::numeric, 2)
			when ot.order_total <= pv.p50 then round(pv.p25::numeric, 2) || ' - ' || round(pv.p50::numeric, 2)
			when ot.order_total <= pv.p75 then round(pv.p50::numeric, 2) || ' - ' || round(pv.p75::numeric, 2)
			when ot.order_total <= pv.p90 then round(pv.p75::numeric, 2) || ' - ' || round(pv.p90::numeric, 2)
			else round(pv.p90::numeric, 2) || '+'
		end as price_range
	from orders_totals ot
	cross join percentile_values pv
)

-- Final output: order count %, revenue %, and avg items per order, per bracket
select distinct
	bucket_rank,
	price_range,
	round(avg(items_in_order) over (partition by bucket_rank), 2) avg_items_in_order,
	sum(order_total) over (partition by bucket_rank) as bucket_revenue,
	count(*) over (partition by bucket_rank) as bucket_order_count,
	round((sum(order_total) over (partition by bucket_rank) / sum(order_total) over () * 100)::numeric, 2) as revenue_pct,
	round((count(*) over (partition by bucket_rank)::numeric / count(*) over () * 100), 2) as orders_pct
from totals_ranked
order by bucket_rank asc;