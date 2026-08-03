CREATE SCHEMA IF NOT EXISTS clean;

create view clean.customers as
SELECT *
FROM public.customers;

create view clean.order_items as
SELECT *
FROM public.order_items;

drop view clean.orders;
create or replace VIEW clean.orders AS
SELECT
    order_id,
    customer_id,
    order_status,
    cast(order_purchase_timestamp as date) as purchase_date,
    cast(order_delivered_customer_date as date) as delivered_date,
    cast(order_estimated_delivery_date as date) as estimated_delivery_date,
    CASE 
        WHEN order_delivered_customer_date IS NULL THEN 'Not Delivered'
        ELSE 'Delivered'
    END AS delivery_status
FROM public.orders;

CREATE or replace VIEW clean.active_orders AS
SELECT
    order_id,
    customer_id,
    order_status,
    cast(order_purchase_timestamp as date) as purchase_date,
    cast(order_delivered_customer_date as date) as delivered_date,
    cast(order_estimated_delivery_date as date) as estimated_delivery_date,
    CASE 
        WHEN order_delivered_customer_date IS NULL THEN 'not delivered'
        when cast(order_delivered_customer_date as date) > cast(order_estimated_delivery_date as date) then 'late'
        ELSE 'on time'
    END AS delivery_status
FROM public.orders
where order_status NOT IN ('canceled', 'unavailable');

create view clean.order_payments as
SELECT *
FROM public.order_payments;

create or replace view clean.products as
select
	p.product_id,
	case
		when p.product_category_name = '' then 'unknown'
		else coalesce(pcnt.product_category_name_english, 'unknown')
	end as category_name,
	coalesce(p.product_name_lenght, 0) name_length,
	coalesce(p.product_description_lenght , 0) description_length,
	coalesce(p.product_photos_qty, 0) photos_qty
FROM public.products p
left join public.product_category_name_translation pcnt 
	 ON pcnt.product_category_name = p.product_category_name;

drop view clean.order_reviews;
create view clean.order_reviews as
select 
	review_id,
	order_id,
	review_score,
	review_creation_date
from (
	select
		*,
		row_number() over (
			partition by review_id
			order by review_answer_timestamp desc
		) as rn
	from public.order_reviews
) t
where rn = 1;











