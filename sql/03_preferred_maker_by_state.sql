/*
========================================================================================
BUSINESS QUESTION 3: Most Preferred Vehicle Maker in Each State
========================================================================================
Business Objective:
  Determine the #1 vehicle manufacturer by order volume in each state to facilitate 
  hyper-localized inventory stocking, regional dealership partnerships, and targeted geo-ads.

Analytical Approach:
  - Join order_t, customer_t, and product_t across 3 tables.
  - Group by state and vehicle_maker to calculate regional order counts.
  - Apply the window function DENSE_RANK() / RANK() partitioned by state and ordered by order volume.
  - Filter the outer query for rank = 1 to isolate the market leader in each state.

Key SQL Techniques:
  - Multi-table Joins: 3-way join across customer, order, and product entities
  - Common Table Expression (CTE): WITH ranked_state_makers AS (...)
  - Window Function: DENSE_RANK() OVER (PARTITION BY state ORDER BY order_count DESC)
========================================================================================
*/

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
