-- =====================================================
-- TABLE: order_items
-- =====================================================

-- Row count
SELECT COUNT (distinct order_id) AS total_rows
FROM order_items;

-- Duplicate composite key
SELECT
    COUNT(*) -
    COUNT(DISTINCT (order_id, order_item_id))
    AS duplicate_items
FROM order_items;

-- Missing values
SELECT
    COUNT(*) - COUNT(order_id) AS order_id_nulls,
    COUNT(*) - COUNT(order_item_id) AS order_item_id_nulls,
    COUNT(*) - COUNT(product_id) AS product_id_nulls,
    COUNT(*) - COUNT(seller_id) AS seller_id_nulls,
    COUNT(*) - COUNT(price) AS price_nulls,
    COUNT(*) - COUNT(freight_value) AS freight_nulls
FROM order_items;

-- Negative prices
SELECT *
FROM order_items
WHERE price < 0;

-- Negative freight
SELECT *
FROM order_items
WHERE freight_value < 0;


