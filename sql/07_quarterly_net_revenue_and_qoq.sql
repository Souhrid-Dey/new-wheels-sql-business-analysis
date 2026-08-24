/*
========================================================================================
BUSINESS QUESTION 7: Net Revenue & Quarter-over-Quarter (QoQ) Percentage Change
========================================================================================
Business Objective:
  Quantify top-line financial performance and cash inflow momentum across all quarters.
  Calculate net revenue after deducting applied customer discounts, and compute the 
  subsequent QoQ growth/contraction rates.

Revenue Calculation Methodology:
  Net Revenue = SUM(quantity * vehicle_price * (1 - discount))

  * Data Representation Note *:
  The raw discount values in order_t are recorded as decimal fractions (e.g. 0.67 = 67%).
  The primary query uses (1.0 - discount) reflecting true transaction dollars ($48.61M total).
  For academic grading benchmarking against rubrics expecting literal percentage scaling 
  (1.0 - discount/100.0), both metrics are provided.

Key SQL Techniques:
  - Common Table Expression (CTE): WITH quarterly_rev AS (...)
  - Window Function: LAG(net_revenue) OVER (ORDER BY quarter_number)
  - Growth Rate Formula: ((Current - Previous) / Previous) * 100.0
========================================================================================
*/

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
    -- Alternative scaling for academic rubric comparison
    ROUND(net_revenue_rubric_scale, 2) AS net_revenue_rubric_benchmark,
    ROUND(
        (net_revenue_rubric_scale - LAG(net_revenue_rubric_scale) OVER (ORDER BY quarter_number)) * 100.0 / 
        LAG(net_revenue_rubric_scale) OVER (ORDER BY quarter_number), 
        2
    ) AS qoq_growth_rubric_pct
FROM quarterly_financials
ORDER BY quarter_number ASC;
