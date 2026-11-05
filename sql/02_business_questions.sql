-- 02_business_questions.sql
-- Dataset: `olist-sales-analysis-513816.olist`
-- If a query errors on timestamps, check the column types in the table schema first.

-- Business questions
-- Q0. How many orders per month? (decides which months to trim)
-- Q1. How does revenue change over time?
-- Q2. Which product categories make the most money?
-- Q3. Does delivery time affect review scores?
-- Q4. How do customers pay?
-- Q5. Which states bring in the most sales?


-- Q0. Orders per month
SELECT
  FORMAT_TIMESTAMP('%Y-%m', order_purchase_timestamp) AS month,
  COUNT(*) AS orders
FROM `olist-sales-analysis-513816.olist.orders`
GROUP BY month
ORDER BY month;


-- Q1. Revenue per month (delivered orders, trimmed to Jan 2017 - Aug 2018)
-- Adjust the dates after you look at Q0.
SELECT
  FORMAT_TIMESTAMP('%Y-%m', o.order_purchase_timestamp) AS month,
  COUNT(DISTINCT o.order_id) AS orders,
  ROUND(SUM(oi.price), 2) AS revenue,
  ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM `olist-sales-analysis-513816.olist.orders` o
JOIN `olist-sales-analysis-513816.olist.order_items` oi USING (order_id)
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= TIMESTAMP('2017-01-01')
  AND o.order_purchase_timestamp <  TIMESTAMP('2018-09-01')
GROUP BY month
ORDER BY month;


-- Q2. Top 15 categories by revenue (no-category products grouped as 'unknown')
SELECT
  COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
  COUNT(DISTINCT oi.order_id) AS orders,
  ROUND(SUM(oi.price), 2) AS revenue
FROM `olist-sales-analysis-513816.olist.order_items` oi
JOIN `olist-sales-analysis-513816.olist.orders` o USING (order_id)
JOIN `olist-sales-analysis-513816.olist.products` p USING (product_id)
LEFT JOIN `olist-sales-analysis-513816.olist.product_category_name_translation` t
  ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY revenue DESC
LIMIT 15;


-- Q3. Delivery time vs review score (delivered orders only)
SELECT
  r.review_score,
  COUNT(*) AS orders,
  ROUND(AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)), 1) AS avg_days_to_deliver,
  ROUND(AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date, DAY)), 1) AS avg_days_vs_estimate
FROM `olist-sales-analysis-513816.olist.orders` o
JOIN `olist-sales-analysis-513816.olist.order_reviews` r USING (order_id)
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;


-- Q4. Payment types
SELECT
  payment_type,
  COUNT(DISTINCT order_id) AS orders,
  ROUND(SUM(payment_value), 2) AS total_value,
  ROUND(AVG(payment_installments), 1) AS avg_installments
FROM `olist-sales-analysis-513816.olist.order_payments`
GROUP BY payment_type
ORDER BY total_value DESC;


-- Q5. Sales by customer state
SELECT
  c.customer_state,
  COUNT(DISTINCT o.order_id) AS orders,
  ROUND(SUM(oi.price), 2) AS revenue
FROM `olist-sales-analysis-513816.olist.orders` o
JOIN `olist-sales-analysis-513816.olist.customers` c USING (customer_id)
JOIN `olist-sales-analysis-513816.olist.order_items` oi USING (order_id)
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;
