/*
========================================================================================
BUSINESS QUESTION 2: Top 5 Vehicle Manufacturers Preferred by Customers
========================================================================================
Business Objective:
  Identify the top 5 vehicle manufacturers with the highest consumer demand to optimize 
  procurement contracts, inventory holding allocations, and marketing budget prioritization.

Analytical Approach:
  - Join order facts with product dimensions to resolve manufacturer brand names.
  - Aggregate total order volume and compute the percentage contribution of each manufacturer 
    to overall platform sales.
  - Rank in descending order and limit to the top 5 OEM brands.

Key SQL Techniques:
  - Table Joining: INNER JOIN product_t ON order_t.product_id = product_t.product_id
  - Window/Scalar Ratio Calculation: Percentage share of total platform orders
  - Sorting & Pagination: ORDER BY total_orders DESC LIMIT 5
========================================================================================
*/

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
