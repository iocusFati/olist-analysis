-- =====================================================
-- TABLE: reviews
-- =====================================================

-- Row count
SELECT COUNT(*) AS total_rows
FROM public.order_reviews;

-- Duplicate PK
SELECT
    COUNT(*) - COUNT(DISTINCT (review_id, order_id)) AS duplicate_reviews
FROM public.order_reviews;

SELECT
    review_id,
    order_id
FROM order_reviews
WHERE review_id IN (
    SELECT review_id
    FROM order_reviews
    GROUP BY review_id
    HAVING COUNT(*) > 1
)
ORDER BY review_id;

-- Missing values
SELECT
    COUNT(*) - COUNT(review_id) AS review_id_nulls,
    COUNT(*) - COUNT(order_id) AS order_id_nulls,
    COUNT(*) - COUNT(review_score) AS review_score_nulls,
    COUNT(*) - COUNT(review_creation_date) AS review_creation_nulls
FROM order_reviews;

-- Invalid scores
SELECT *
FROM order_reviews
WHERE review_score NOT BETWEEN 1 AND 5;