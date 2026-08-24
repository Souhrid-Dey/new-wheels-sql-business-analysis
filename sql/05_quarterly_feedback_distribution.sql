/*
========================================================================================
BUSINESS QUESTION 5: Percentage Distribution of Feedback Sentiments by Quarter
========================================================================================
Business Objective:
  Examine the detailed sentiment composition (Very Good, Good, Okay, Bad, Very Bad) 
  quarter-by-quarter to determine the exact trajectory of customer dissatisfaction and 
  uncover early warning signs in after-sales experience.

Analytical Approach:
  - Employ conditional aggregation (SUM of CASE expressions) to calculate bucket counts per quarter.
  - Divide bucket counts by total quarterly order volume and scale to 100.0 for percentage shares.
  - Order chronologically by quarter_number.

Key SQL Techniques:
  - Conditional Aggregation: SUM(CASE WHEN feedback = '...' THEN 1 ELSE 0 END)
  - Ratio & Percentage Scaling: * 100.0 / COUNT(order_id)
  - Time-series Grouping: GROUP BY quarter_number ORDER BY quarter_number ASC
========================================================================================
*/

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
