/*
========================================================================================
BUSINESS QUESTION 4: Overall & Quarterly Average Customer Rating Trends
========================================================================================
Business Objective:
  Track customer sentiment over time by converting categorical qualitative feedback into 
  standardized 1-5 numerical ratings. Evaluate whether customer satisfaction is holding 
  steady or deteriorating across quarters.

Mapping Scale:
  - "Very Bad"  -> 1.0
  - "Bad"       -> 2.0
  - "Okay"      -> 3.0
  - "Good"      -> 4.0
  - "Very Good" -> 5.0

Key SQL Techniques:
  - Conditional CASE Statement: Map string feedback to numerical scores
  - Aggregation: AVG(numerical_rating), COUNT(order_id)
  - Result Stacking: UNION ALL to present quarterly breakdowns alongside overall benchmark
========================================================================================
*/

-- Quarterly breakdown of average customer rating
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

-- Overall benchmark average rating across all orders
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
