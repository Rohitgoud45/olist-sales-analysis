-- 01_exploration.sql
-- Quick checks on the Olist data in BigQuery (dataset: olist)

-- 1. Row counts per table
SELECT table_id, row_count
FROM olist.__TABLES__
ORDER BY row_count DESC;

-- 2. Date range of orders
SELECT
  MIN(order_purchase_timestamp) AS first_order,
  MAX(order_purchase_timestamp) AS last_order,
  DATE_DIFF(DATE(MAX(order_purchase_timestamp)), DATE(MIN(order_purchase_timestamp)), DAY) AS days_covered
FROM olist.orders;

-- 3. Orders by status (delivered vs canceled etc.)
SELECT
  order_status,
  COUNT(*) AS orders,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM olist.orders
GROUP BY order_status
ORDER BY orders DESC;

-- 4. Nulls in key columns
SELECT 'orders' AS tbl,
  COUNTIF(order_id IS NULL) AS null_id,
  COUNTIF(customer_id IS NULL) AS null_customer_id,
  COUNTIF(order_purchase_timestamp IS NULL) AS null_purchase_ts,
  COUNTIF(order_approved_at IS NULL) AS null_approved_at,
  COUNTIF(order_delivered_customer_date IS NULL) AS null_delivered_date
FROM olist.orders;

SELECT 'order_items' AS tbl,
  COUNTIF(order_id IS NULL) AS null_order_id,
  COUNTIF(product_id IS NULL) AS null_product_id,
  COUNTIF(seller_id IS NULL) AS null_seller_id,
  COUNTIF(price IS NULL) AS null_price
FROM olist.order_items;

SELECT 'products' AS tbl,
  COUNTIF(product_id IS NULL) AS null_product_id,
  COUNTIF(product_category_name IS NULL) AS null_category,
  COUNTIF(product_weight_g IS NULL) AS null_weight
FROM olist.products;

SELECT 'order_reviews' AS tbl,
  COUNTIF(review_score IS NULL) AS null_score,
  COUNTIF(review_comment_message IS NULL) AS null_comment
FROM olist.order_reviews;

SELECT 'order_payments' AS tbl,
  COUNTIF(payment_type IS NULL) AS null_type,
  COUNTIF(payment_value IS NULL) AS null_value
FROM olist.order_payments;

-- 5. Duplicate check on primary keys
SELECT 'orders' AS tbl, COUNT(*) - COUNT(DISTINCT order_id) AS dup_keys FROM olist.orders
UNION ALL
SELECT 'customers', COUNT(*) - COUNT(DISTINCT customer_id) FROM olist.customers
UNION ALL
SELECT 'products', COUNT(*) - COUNT(DISTINCT product_id) FROM olist.products
UNION ALL
SELECT 'sellers', COUNT(*) - COUNT(DISTINCT seller_id) FROM olist.sellers;
