/*
========================================================================================
BUSINESS QUESTION 8: Revenue, Order Volume, and Average Order Value (AOV) Trends
========================================================================================
Business Objective:
  Correlate quarterly revenue with order volumes to analyze Average Order Value (AOV) 
  and Revenue per Order. Diagnose whether the revenue collapse is driven by loss of order 
  volume, product mix shifts (cheaper cars), or severe discounting pressure.

Analytical Approach:
  - Aggregate total orders and net revenue per quarter.
  - Compute Average Order Value (AOV = Net Revenue / Total Orders).
  - Track changes in ticket size over time.

Key SQL Techniques:
  - Multi-metric Aggregation: COUNT(order_id), SUM(net_revenue), AVG(net_revenue)
  - Derived Unit Economics: ROUND(SUM(...) / COUNT(...), 2)
  - Time-series Grouping: GROUP BY quarter_number
========================================================================================
*/

SELECT 
    quarter_number,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(quantity * vehicle_price * (1.0 - discount)), 2) AS net_revenue,
    ROUND(AVG(quantity * vehicle_price * (1.0 - discount)), 2) AS avg_order_value,
    ROUND(SUM(quantity * vehicle_price * (1.0 - discount)) / COUNT(order_id), 2) AS revenue_per_order
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number ASC;
