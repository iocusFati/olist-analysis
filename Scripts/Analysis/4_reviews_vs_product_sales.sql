-- Does a product's average review score relate to how often it sells?
with info as (
	select
		r.order_id,
		i.product_id,
		r.review_score,
		i.price
	from clean.order_reviews r
	left join clean.order_items i
		on r.order_id = i.order_id
),
by_score as (
	-- One row per product: its average score, order count, and revenue
	select
		product_id,
		avg(review_score) as avg_score,
		count(order_id) as order_cnt,
		sum(price) as revenue
	from info
	where review_score is not null
	group by product_id
	having count(order_id) > 1
)

-- Group products into score buckets, compare average orders and revenue
select
	case
		when avg_score < 2 then '1-2'
		when avg_score < 3 then '2-3'
		when avg_score < 4 then '3-4'
		else '4-5'
	end as score_bucket,
	round(avg(order_cnt), 2) as avg_order_cnt,
	round(sum(revenue)::numeric, 0) as revenue,
	count(*) as product_cnt
from by_score
group by 1
order by 1;


-- Does photo count on a product's listing relate to its average review score?
select
	case
		when p.photos_qty = 0 then '0'
		when p.photos_qty between 1 and 4 then '1-4'
		when p.photos_qty between 5 and 10 then '5-10'
		else '10+'
	end as photo_bucket,
	round(avg(r.review_score), 1) as avg_score,
	count(o.order_id) as orders_cnt,
	-- Numeric sort key, since the text bucket labels don't sort correctly on their own
	case
		when p.photos_qty = 0 then 0
		when p.photos_qty between 1 and 4 then 1
		when p.photos_qty between 5 and 10 then 2
		else 3
	end as sort_key
from clean.order_items o
left join clean.products p
	on o.product_id = p.product_id
left join clean.order_reviews r
	on o.order_id = r.order_id
group by 1, 4
order by sort_key;


-- Does product description length relate to its average review score?
select
	case
		when p.description_length = 0 then '0'
		when p.description_length between 1 and 250 then '1-250'
		when p.description_length between 251 and 750 then '251-750'
		when p.description_length between 751 and 1500 then '751-1500'
		else '1500+'
	end as description_bucket,
	round(avg(r.review_score), 1) as avg_score,
	count(o.order_id) as orders_cnt,
	-- Numeric sort key, since the text bucket labels don't sort correctly on their own
	case
		when p.description_length = 0 then 0
		when p.description_length between 1 and 250 then 1
		when p.description_length between 251 and 750 then 2
		when p.description_length between 751 and 1500 then 3
		else 4
	end as sort_key
from clean.order_items o
left join clean.products p
	on o.product_id = p.product_id
left join clean.order_reviews r
	on o.order_id = r.order_id
group by 1, 4
order by sort_key