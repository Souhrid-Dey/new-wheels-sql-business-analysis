/*
========================================================================================
BUSINESS QUESTION 1: Customer Reach & Geographic Distribution
========================================================================================
Business Objective:
  Determine the total size of New-Wheels' active customer base (customers who have 
  placed at least one order) and analyze their geographic dispersion across US states 
  to identify key revenue territories and market penetration opportunities.

Analytical Approach:
  - Part 1A: Count distinct customer IDs in the order ledger to establish total active buyers.
  - Part 1B: Aggregate distinct customers per state, calculate state market share (% of total),
             and rank states by customer density.

Key SQL Techniques:
  - Aggregation: COUNT(DISTINCT customer_id)
  - Subquery / Scalar Ratio: Multiplied by 100.0 for floating-point precision percentage
  - Table Joining: INNER JOIN customer_t ON order_t.customer_id = customer_t.customer_id
========================================================================================
*/

-- -------------------------------------------------------------------------------------
-- Part 1A: Total Distinct Customers Who Have Placed Orders
-- -------------------------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT customer_id) AS total_active_customers
FROM order_t;


-- -------------------------------------------------------------------------------------
-- Part 1B: Geographic Customer Distribution Across States
-- -------------------------------------------------------------------------------------
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
