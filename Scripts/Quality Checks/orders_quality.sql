-- =====================================================
-- DATA QUALITY CHECKS
-- Table: orders
-- Expected rows: 99,441
-- Primary Key: order_id
-- =====================================================


-- =====================================================
-- 1. Row Count
-- =====================================================

SELECT COUNT(distinct order_id) AS total_rows
FROM orders;


-- =====================================================
-- 2. Duplicate Primary Keys
-- Expected: 0
-- =====================================================

SELECT
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_order_ids
FROM orders;


-- =====================================================
-- 3. Missing Values
-- =====================================================

SELECT
    COUNT(*) - COUNT(order_id) AS order_id_nulls,
    COUNT(*) - COUNT(customer_id) AS customer_id_nulls,
    COUNT(*) - COUNT(order_status) AS order_status_nulls,
    COUNT(*) - COUNT(order_purchase_timestamp) AS purchase_timestamp_nulls,
    COUNT(*) - COUNT(order_delivered_customer_date) AS delivered_customer_nulls,
    COUNT(*) - COUNT(order_estimated_delivery_date) AS estimated_delivery_nulls
FROM orders;

-- 2965 delivered_customer nulls


-- =====================================================
-- 4. Order Status Distribution
-- =====================================================

SELECT
    order_status,
    COUNT(*) AS orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;


-- =====================================================
-- 5. Orders Without Customer
-- Expected: 0
-- =====================================================

SELECT COUNT(*) AS orders_without_customer
FROM orders
WHERE customer_id IS NULL;


-- =====================================================
-- 6. Invalid Dates
-- Purchase date should never be after delivery date
-- =====================================================

SELECT COUNT(*) AS invalid_dates
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp > order_delivered_customer_date;