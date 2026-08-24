/*
========================================================================================
BUSINESS QUESTION 10: Fulfillment Velocity & Logistics Bottleneck Diagnostics
========================================================================================
Business Objective:
  Analyze the average, minimum, and maximum shipping duration (days from order placement 
  to delivery) across all four quarters. Diagnose whether supply chain bottlenecks and 
  logistics delays are the root cause of declining customer satisfaction ratings.

Analytical Approach:
  - Calculate fulfillment duration in days using SQLite's JULIANDAY() date arithmetic:
      JULIANDAY(ship_date) - JULIANDAY(order_date)
    *(Equivalent to MySQL DATEDIFF(ship_date, order_date))*.
  - Group by quarter_number to observe operational lag trends.
  - Calculate min, avg, and max turnaround days.

Key SQL Techniques:
  - Date/Time Arithmetic: JULIANDAY(ship_date) - JULIANDAY(order_date)
  - Null Filtering: WHERE ship_date IS NOT NULL AND order_date IS NOT NULL
  - Group Aggregation: AVG, MIN, MAX
========================================================================================
*/

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
