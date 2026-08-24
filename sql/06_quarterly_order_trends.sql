/*
========================================================================================
BUSINESS QUESTION 6: Quarterly Order Volume and Customer Engagement Trends
========================================================================================
Business Objective:
  Track the quarterly velocity of order fulfillment and unique customer participation to 
  gauge operational throughput, market acquisition momentum, and repeat purchasing patterns.

Analytical Approach:
  - Count total orders and distinct customer IDs per quarter.
  - Calculate the ratio of orders per customer to detect repeat buying vs. one-time churn.
  - Calculate Quarter-over-Quarter (QoQ) percentage change in order volume using LAG().

Key SQL Techniques:
  - Aggregation: COUNT(order_id), COUNT(DISTINCT customer_id)
  - Window Function: LAG(total_orders) OVER (ORDER BY quarter_number)
  - Derived KPI: orders_per_customer ratio
========================================================================================
*/

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
