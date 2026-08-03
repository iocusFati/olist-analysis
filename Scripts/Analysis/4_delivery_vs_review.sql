select 
	o.delivery_status,
	round(avg(review_score), 1) as avg_score
from clean.active_orders o
left join clean.order_reviews r
	on o.order_id = r.order_id
where delivery_status != 'not delivered'
group by 1