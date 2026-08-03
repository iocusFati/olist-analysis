-- =====================================================
-- TABLE: customers
-- =====================================================

-- Row count
SELECT COUNT(*) AS total_rows
FROM customers;

-- Duplicate primary key
SELECT
    COUNT(*) - COUNT(DISTINCT customer_id) AS duplicate_customer_ids
FROM customers;

-- Missing values
SELECT
    COUNT(*) - COUNT(customer_id) AS customer_id_nulls,
    COUNT(*) - COUNT(customer_unique_id) AS customer_unique_id_nulls,
    COUNT(*) - COUNT(customer_state) AS customer_state_nulls
FROM customers;

-- Invalid states
SELECT DISTINCT customer_state
FROM customers
ORDER BY customer_state;