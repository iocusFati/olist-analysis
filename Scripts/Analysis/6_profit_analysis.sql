-- Monthly revenue trend (2016 excluded as an incomplete/unrepresentative launch period)
-- Note: named "profit" here, but this is revenue (sum of item price) — no cost data
-- exists in this dataset to calculate actual profit
with order_profit as (
	select
		order_id,
		sum(price) as profit
	from clean.order_items items
	group by 1
)

select
	date_trunc('month', o.purchase_date)::date,
	sum(profit) as profit
from order_profit as op
left join clean.orders o
	on op.order_id = o.order_id
where purchase_date >= '2017-01-01' and purchase_date < '2018-09-01'
group by 1
order by 1 asc