-- =====================================================
-- TABLE: payments
-- =====================================================

-- Row count
SELECT COUNT(*) AS total_rows
FROM order_payments;

-- Duplicate composite key
SELECT
    COUNT(*) -
    COUNT(DISTINCT (order_id, payment_sequential))
    AS duplicate_payments
FROM order_payments;

-- Missing values
SELECT
    COUNT(*) - COUNT(order_id) AS order_id_nulls,
    COUNT(*) - COUNT(payment_type) AS payment_type_nulls,
    COUNT(*) - COUNT(payment_installments) AS installments_nulls,
    COUNT(*) - COUNT(payment_value) AS payment_value_nulls
FROM order_payments;

-- Negative payments
SELECT *
FROM order_payments
WHERE payment_value <= 0;

-- negative payments exist

-- Invalid installments
SELECT *
FROM order_payments
WHERE payment_installments < 1;

-- invalid installments exist