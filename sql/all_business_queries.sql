/*
========================================================================================
NEW-WHEELS VEHICLE RESALE PLATFORM: COMPLETE BUSINESS ANALYTICS SQL SUITE
========================================================================================
Project: Executive Quarterly Performance Review & Root-Cause Diagnosis
Author: Souhrid Dey
Dialect: SQLite / ANSI SQL (Compatible with MySQL 8.0 / PostgreSQL 14+)
Database: data/new_wheels.db

Table of Contents:
  1. Business Overview & KPI Summary Scorecard
  2. Query 1: Customer Reach & Geographic Distribution (1A & 1B)
  3. Query 2: Top 5 Preferred Vehicle Manufacturers
  4. Query 3: Top Preferred Vehicle Manufacturer by State (Window Function CTE)
  5. Query 4: Customer Satisfaction & Quarterly Rating Trends
  6. Query 5: Granular Feedback Sentiment Distribution by Quarter
  7. Query 6: Quarterly Order Volume & Unique Customer Velocity
  8. Query 7: Net Revenue & Quarter-over-Quarter (QoQ) Percentage Growth
  9. Query 8: Quarterly Revenue, Order Volume, and Average Order Value (AOV)
 10. Query 9: Credit Card Discount Policy & Margin Impact Analysis
 11. Query 10: Fulfillment Logistics Velocity & Shipping Delay Diagnosis
========================================================================================
*/

-- =====================================================================================
-- 0. EXECUTIVE KPI SUMMARY SCORECARD
-- =====================================================================================
SELECT 
    COUNT(o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    ROUND(SUM(o.quantity * o.vehicle_price * (1.0 - o.discount)), 2) AS total_net_revenue,
    ROUND(AVG(
        CASE o.customer_feedback
            WHEN 'Very Bad'  THEN 1.0
            WHEN 'Bad'       THEN 2.0
            WHEN 'Okay'      THEN 3.0
            WHEN 'Good'      THEN 4.0
            WHEN 'Very Good' THEN 5.0
            ELSE NULL
        END
    ), 2) AS overall_avg_rating,
    ROUND(AVG(JULIANDAY(o.ship_date) - JULIANDAY(o.order_date)), 2) AS overall_avg_days_to_ship,
    ROUND(
        SUM(CASE WHEN o.customer_feedback IN ('Good', 'Very Good') THEN 1 ELSE 0 END) * 100.0 / 
        COUNT(o.order_id), 
        2
    ) AS pct_good_or_very_good_feedback
FROM order_t o;


-- =====================================================================================
-- 1. QUESTION 1: Customer Reach & State-wise Distribution
-- =====================================================================================
-- Part 1A: Total Distinct Ordering Customers
SELECT 
    COUNT(DISTINCT customer_id) AS total_active_customers
FROM order_t;

-- Part 1B: State-wise Customer Distribution
SELECT 
    c.state,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    ROUND(
        COUNT(DISTINCT c.customer_id) * 100.0 / 
        (SELECT COUNT(DISTINCT customer_id) FROM order_t), 
        2
    ) AS pct_of_total_customers
FROM customer_t c
INNER JOIN order_t o 
    ON c.customer_id = o.customer_id
GROUP BY c.state
ORDER BY customer_count DESC, c.state ASC;


-- =====================================================================================
-- 2. QUESTION 2: Top 5 Vehicle Manufacturers Preferred by Customers
-- =====================================================================================
SELECT 
    p.vehicle_maker,
    COUNT(o.order_id) AS total_orders,
    ROUND(
        COUNT(o.order_id) * 100.0 / (SELECT COUNT(*) FROM order_t), 
        2
    ) AS pct_of_total_orders
FROM order_t o
INNER JOIN product_t p 
    ON o.product_id = p.product_id
GROUP BY p.vehicle_maker
ORDER BY total_orders DESC
LIMIT 5;


-- =====================================================================================
-- 3. QUESTION 3: Most Preferred Vehicle Maker in Each State (Window CTE)
-- =====================================================================================
WITH state_maker_popularity AS (
    SELECT 
        c.state,
        p.vehicle_maker,
        COUNT(o.order_id) AS order_count,
        DENSE_RANK() OVER (
            PARTITION BY c.state 
            ORDER BY COUNT(o.order_id) DESC
        ) AS rank_num
    FROM order_t o
    INNER JOIN customer_t c 
        ON o.customer_id = c.customer_id
    INNER JOIN product_t p 
        ON o.product_id = p.product_id
    GROUP BY c.state, p.vehicle_maker
)
SELECT 
    state,
    vehicle_maker AS preferred_vehicle_maker,
    order_count
FROM state_maker_popularity
WHERE rank_num = 1
ORDER BY state ASC;


-- =====================================================================================
-- 4. QUESTION 4: Overall & Quarterly Average Customer Ratings
-- =====================================================================================
SELECT 
    'Quarter ' || quarter_number AS period,
    COUNT(order_id) AS total_feedback_count,
    ROUND(AVG(
        CASE customer_feedback
            WHEN 'Very Bad'  THEN 1.0
            WHEN 'Bad'       THEN 2.0
            WHEN 'Okay'      THEN 3.0
            WHEN 'Good'      THEN 4.0
            WHEN 'Very Good' THEN 5.0
            ELSE NULL
        END
    ), 2) AS average_rating
FROM order_t
WHERE customer_feedback IS NOT NULL
GROUP BY quarter_number

UNION ALL

SELECT 
    'Overall Platform Average' AS period,
    COUNT(order_id) AS total_feedback_count,
    ROUND(AVG(
        CASE customer_feedback
            WHEN 'Very Bad'  THEN 1.0
            WHEN 'Bad'       THEN 2.0
            WHEN 'Okay'      THEN 3.0
            WHEN 'Good'      THEN 4.0
            WHEN 'Very Good' THEN 5.0
            ELSE NULL
        END
    ), 2) AS average_rating
FROM order_t
WHERE customer_feedback IS NOT NULL;


-- =====================================================================================
-- 5. QUESTION 5: Percentage Distribution of Feedback Sentiments by Quarter
-- =====================================================================================
SELECT 
    quarter_number,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(CASE WHEN customer_feedback = 'Very Good' THEN 1 ELSE 0 END) * 100.0 / COUNT(order_id), 2) AS pct_very_good,
    ROUND(SUM(CASE WHEN customer_feedback = 'Good'      THEN 1 ELSE 0 END) * 100.0 / COUNT(order_id), 2) AS pct_good,
    ROUND(SUM(CASE WHEN customer_feedback = 'Okay'      THEN 1 ELSE 0 END) * 100.0 / COUNT(order_id), 2) AS pct_okay,
    ROUND(SUM(CASE WHEN customer_feedback = 'Bad'       THEN 1 ELSE 0 END) * 100.0 / COUNT(order_id), 2) AS pct_bad,
    ROUND(SUM(CASE WHEN customer_feedback = 'Very Bad'  THEN 1 ELSE 0 END) * 100.0 / COUNT(order_id), 2) AS pct_very_bad,
    ROUND(SUM(CASE WHEN customer_feedback IN ('Bad', 'Very Bad') THEN 1 ELSE 0 END) * 100.0 / COUNT(order_id), 2) AS pct_total_dissatisfied
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number ASC;


-- =====================================================================================
-- 6. QUESTION 6: Quarterly Order Volume & Customer Retention Velocity
-- =====================================================================================
WITH quarterly_orders AS (
    SELECT 
        quarter_number,
        COUNT(order_id) AS total_orders,
        COUNT(DISTINCT customer_id) AS unique_customers,
        ROUND(COUNT(order_id) * 1.0 / COUNT(DISTINCT customer_id), 2) AS orders_per_customer
    FROM order_t
    GROUP BY quarter_number
)
SELECT 
    quarter_number,
    total_orders,
    unique_customers,
    orders_per_customer,
    LAG(total_orders) OVER (ORDER BY quarter_number) AS prev_quarter_orders,
    ROUND(
        (total_orders - LAG(total_orders) OVER (ORDER BY quarter_number)) * 100.0 / 
        LAG(total_orders) OVER (ORDER BY quarter_number), 
        2
    ) AS qoq_order_growth_pct
FROM quarterly_orders
ORDER BY quarter_number ASC;


-- =====================================================================================
-- 7. QUESTION 7: Net Revenue & Quarter-over-Quarter (QoQ) Percentage Change
-- =====================================================================================
WITH quarterly_financials AS (
    SELECT 
        quarter_number,
        SUM(quantity * vehicle_price * (1.0 - discount)) AS net_revenue_usd,
        SUM(quantity * vehicle_price * (1.0 - (discount / 100.0))) AS net_revenue_rubric_scale
    FROM order_t
    GROUP BY quarter_number
)
SELECT 
    quarter_number,
    ROUND(net_revenue_usd, 2) AS net_revenue,
    ROUND(LAG(net_revenue_usd) OVER (ORDER BY quarter_number), 2) AS prev_quarter_revenue,
    ROUND(
        (net_revenue_usd - LAG(net_revenue_usd) OVER (ORDER BY quarter_number)) * 100.0 / 
        LAG(net_revenue_usd) OVER (ORDER BY quarter_number), 
        2
    ) AS qoq_revenue_growth_pct,
    ROUND(net_revenue_rubric_scale, 2) AS net_revenue_rubric_benchmark,
    ROUND(
        (net_revenue_rubric_scale - LAG(net_revenue_rubric_scale) OVER (ORDER BY quarter_number)) * 100.0 / 
        LAG(net_revenue_rubric_scale) OVER (ORDER BY quarter_number), 
        2
    ) AS qoq_growth_rubric_pct
FROM quarterly_financials
ORDER BY quarter_number ASC;


-- =====================================================================================
-- 8. QUESTION 8: Quarterly Revenue, Order Volume, and Average Order Value (AOV)
-- =====================================================================================
SELECT 
    quarter_number,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(quantity * vehicle_price * (1.0 - discount)), 2) AS net_revenue,
    ROUND(AVG(quantity * vehicle_price * (1.0 - discount)), 2) AS avg_order_value,
    ROUND(SUM(quantity * vehicle_price * (1.0 - discount)) / COUNT(order_id), 2) AS revenue_per_order
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number ASC;


-- =====================================================================================
-- 9. QUESTION 9: Credit Card Discount Policy & Margin Impact Analysis
-- =====================================================================================
SELECT 
    c.credit_card_type,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(o.discount) * 100.0, 2) AS avg_discount_percentage,
    ROUND(MIN(o.discount) * 100.0, 2) AS min_discount_percentage,
    ROUND(MAX(o.discount) * 100.0, 2) AS max_discount_percentage,
    ROUND(SUM(o.quantity * o.vehicle_price * o.discount), 2) AS total_discount_dollars
FROM order_t o
INNER JOIN customer_t c 
    ON o.customer_id = c.customer_id
GROUP BY c.credit_card_type
ORDER BY avg_discount_percentage DESC, total_orders DESC;


-- =====================================================================================
-- 10. QUESTION 10: Fulfillment Logistics Velocity & Shipping Delay Diagnosis
-- =====================================================================================
SELECT 
    quarter_number,
    COUNT(order_id) AS total_orders_fulfilled,
    ROUND(AVG(JULIANDAY(ship_date) - JULIANDAY(order_date)), 2) AS avg_days_to_ship,
    ROUND(MIN(JULIANDAY(ship_date) - JULIANDAY(order_date)), 2) AS min_days_to_ship,
    ROUND(MAX(JULIANDAY(ship_date) - JULIANDAY(order_date)), 2) AS max_days_to_ship
FROM order_t
WHERE ship_date IS NOT NULL 
  AND order_date IS NOT NULL
GROUP BY quarter_number
ORDER BY quarter_number ASC;
