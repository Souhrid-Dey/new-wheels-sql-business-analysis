/*
========================================================================================
BUSINESS QUESTION 9: Credit Card Discount Policy & Margin Impact Analysis
========================================================================================
Business Objective:
  Evaluate the discount distribution offered across 16 different credit card payment methods.
  Determine whether promotional price-cuts are disproportionately favoring specific issuers 
  and assess overall margin leakage from payment-tier discounting.

Analytical Approach:
  - Join order facts with customer payment attributes.
  - Group by credit_card_type to compute average, minimum, and maximum discount rates.
  - Calculate total aggregate dollar discount given per credit card type.
  - Sort by average discount rate descending.

Key SQL Techniques:
  - Table Joining: INNER JOIN customer_t c ON o.customer_id = c.customer_id
  - Multi-aggregation: AVG(discount), MIN(discount), MAX(discount), SUM(dollars_discounted)
  - Sorting: ORDER BY avg_discount_rate DESC
========================================================================================
*/

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
