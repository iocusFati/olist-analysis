-- =====================================================
-- TABLE: products
-- =====================================================

-- Row count
SELECT COUNT(*) AS total_rows
FROM products;

-- Duplicate PK
SELECT
    COUNT(*) - COUNT(DISTINCT product_id) AS duplicate_products
FROM products;

-- Missing values
SELECT
    COUNT(*) - COUNT(product_id) AS product_id_nulls,
    COUNT(*) - COUNT(product_category_name) AS category_nulls,
    COUNT(*) - COUNT(product_name_lenght) AS name_length_nulls,
    COUNT(*) - COUNT(product_description_lenght) AS description_nulls,
    COUNT(*) - COUNT(product_photos_qty) AS photos_nulls
FROM products;

-- 610 description columns null