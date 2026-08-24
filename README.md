<div align="center">

# 🚗 New-Wheels: Executive SQL Analytics & Root-Cause Diagnosis
### Diagnosing Quarterly Revenue Decline, Logistics Bottlenecks & Customer Sentiment Collapse

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Database: SQLite](https://img.shields.io/badge/Database-SQLite%203.40+-003B57?logo=sqlite&logoColor=white)](https://www.sqlite.org/)
[![Dialect: ANSI / MySQL](https://img.shields.io/badge/Dialect-MySQL%20%7C%20PostgreSQL-4479A1?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Python: 3.10+](https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Academic Score: 57/60](https://img.shields.io/badge/Academic%20Score-57%2F60%20(95.0%25)-10B981?logo=greatlearning&logoColor=white)](#-academic-evaluation--grading)

<p align="center">
  <img src="assets/social_preview.png" width="90%" alt="New-Wheels SQL Case Study Social Banner" />
</p>

</div>

---

## 📌 Executive Summary & Business Context

**New-Wheels** is an automotive e-commerce and pre-owned vehicle resale platform providing end-to-end digital transactions—from online vehicle selection and credit card financing to nationwide carrier shipping and doorstep delivery.

Over the past four operating quarters ($Q1$ to $Q4$), executive leadership observed severe business warning signs:
1. **Steady Order Contraction**: Order volume plummeted by **$-35.8\%$** (from $310$ to $199$ orders).
2. **Top-Line Revenue Collapse**: Net quarterly revenue contracted by **$-52.5\%$** (from $\$18.03\text{M}$ to $\$8.57\text{M}$).
3. **Severe Customer Dissatisfaction**: Customer feedback ratings collapsed from **$3.56$ to $2.40$** out of $5.00$, with negative feedback surging to **$59.8\%$** of all orders in $Q4$.

As Lead Data Analyst, this project conducts a comprehensive SQL diagnostic across all relational dimensions (**$1,000$ transactions, $994$ unique customers, $29$ vehicle makers, and $16$ payment issuers**) to uncover the root cause behind the platform's decline and deliver an executive turnaround playbook for the CEO.

---

## 📊 Executive KPI Scorecard

<p align="center">
  <img src="reports/figures/01_executive_kpi_dashboard.png" width="95%" alt="Executive KPI Scorecard" />
</p>

| Metric | Full Year Performance | $Q1$ Baseline | $Q4$ Status | Trajectory / Variance |
| :--- | :---: | :---: | :---: | :---: |
| **Total Net Revenue** | **$\$48,610,993.78$** | $\$18,032,549.90$ | $\$8,573,149.28$ | **$-52.46\%$** 🔻 |
| **Total Orders** | **$1,000$ Orders** | $310$ Orders | $199$ Orders | **$-35.81\%$** 🔻 |
| **Active Customer Base** | **$994$ Customers** | $310$ Buyers | $199$ Buyers | **$-35.81\%$** 🔻 |
| **Average Customer Rating** | **$3.09$ / $5.00$** | $3.56$ / $5.00$ | $2.40$ / $5.00$ | **$-32.58\%$** 🔻 |
| **Average Days to Ship** | **$99.44$ Days** | $57.17$ Days | $174.10$ Days | **$+204.53\%$** ⚠️ |
| **Positive Sentiment Share** | **$44.80\%$** | $58.71\%$ | $20.10\%$ | **$-65.76\%$** 🔻 |
| **Critical Dissatisfaction** | **$33.70\%$** | $22.26\%$ | $59.80\%$ | **$+168.64\%$** 🚨 |
| **Total Discounts Subsidized** | **$\$76,827,872.23$** | High Margin Drain | High Margin Drain | **$61.37\%$ Avg Discount** |

---

## 🏗️ Database Architecture & Relational Schema

The analytics pipeline queries a normalized schema comprising $4$ primary relational entities:

<p align="center">
  <img src="assets/erd_diagram.png" width="85%" alt="New-Wheels Entity Relationship Diagram" />
</p>

```
┌────────────────────────────────┐            ┌────────────────────────────────┐
│          CUSTOMER_T            │            │           PRODUCT_T            │
├────────────────────────────────┤            ├────────────────────────────────┤
│ customer_id (PK)  VARCHAR(25)  │            │ product_id (PK)     INT        │
│ customer_name     VARCHAR(25)  │            │ vehicle_maker       VARCHAR(60)│
│ gender            VARCHAR(15)  │            │ vehicle_model       VARCHAR(60)│
│ job_title         VARCHAR(50)  │            │ vehicle_color       VARCHAR(60)│
│ city, state       VARCHAR(25)  │            │ vehicle_model_year  INT        │
│ credit_card_type  VARCHAR(30)  │            │ vehicle_price       DECIMAL    │
└───────────────┬────────────────┘            └───────────────┬────────────────┘
                │ 1                                           │ 1
                │                                             │
                │ N                                           │ N
┌───────────────▼─────────────────────────────────────────────▼────────────────┐
│                                   ORDER_T                                    │
├──────────────────────────────────────────────────────────────────────────────┤
│ order_id (PK)          VARCHAR(25)   │  vehicle_price        DECIMAL(10,2)   │
│ customer_id (FK)       VARCHAR(25)   │  order_date           DATE            │
│ product_id (FK)        INT           │  ship_date            DATE            │
│ shipper_id (FK)        INT           │  discount             DECIMAL(4,2)    │
│ quantity               INT           │  customer_feedback    VARCHAR(20)     │
│ quarter_number         INT           │  ship_mode            VARCHAR(25)     │
└──────────────────────────────────────┬───────────────────────────────────────┘
                                       │ N
                                       │ 1
                        ┌──────────────▼─────────────────┐
                        │           SHIPPER_T            │
                        ├────────────────────────────────┤
                        │ shipper_id (PK)    INT         │
                        │ shipper_name       VARCHAR(50) │
                        │ contact_details    VARCHAR(30) │
                        └────────────────────────────────┘
```

> **Data Dictionary & Schema Details**: Full table descriptions, key constraints, and field definitions are documented in [`data/data_dictionary.md`](data/data_dictionary.md).

---

## 🔍 Key Analytical Findings & SQL Deep Dives

### 1. Customer Reach & Geographic Penetration
* **Total Active Buyers**: Exactly **$994$ unique customers** placed orders across **$49$ US states**.
* **Regional Concentration**: Top demand centers are concentrated in **Texas ($97$ buyers, $9.76\%$)**, **California ($97$ buyers, $9.76\%$)**, **Florida ($86$ buyers, $8.65\%$)**, **New York ($69$ buyers, $6.94\%$)**, and **Ohio ($40$ buyers, $4.02\%$)**.

<p align="center">
  <img src="reports/figures/02_state_customer_distribution.png" width="75%" alt="State Customer Distribution" />
</p>

```sql
-- Query 1B: State-wise Customer Distribution & Penetration
SELECT 
    c.state,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    ROUND(
        COUNT(DISTINCT c.customer_id) * 100.0 / 
        (SELECT COUNT(DISTINCT customer_id) FROM order_t), 
        2
    ) AS pct_of_total_customers
FROM customer_t c
INNER JOIN order_t o ON c.customer_id = o.customer_id
GROUP BY c.state
ORDER BY customer_count DESC, c.state ASC;
```

---

### 2. Vehicle Brand Preferences & Localized Demand
* **Market Leaders**: The top $5$ manufacturers account for **$31.8\%$** of total platform volume:
  1. **Chevrolet**: $83$ orders ($8.3\%$)
  2. **Ford**: $63$ orders ($6.3\%$)
  3. **Toyota**: $62$ orders ($6.2\%$)
  4. **Pontiac**: $60$ orders ($6.0\%$)
  5. **Dodge**: $50$ orders ($5.0\%$)
* **State-by-State Preference**: Utilizing window ranking (`DENSE_RANK() OVER (PARTITION BY state ORDER BY order_count DESC)`), **Chevrolet** leads in Texas ($12$ orders) and California ($11$ orders), while **Ford** dominates Florida ($9$ orders).

<p align="center">
  <img src="reports/figures/03_top_vehicle_makers.png" width="75%" alt="Top Vehicle Makers" />
</p>

```sql
-- Query 3: Most Preferred Vehicle Maker per State using Window CTE
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
    INNER JOIN customer_t c ON o.customer_id = c.customer_id
    INNER JOIN product_t p ON o.product_id = p.product_id
    GROUP BY c.state, p.vehicle_maker
)
SELECT state, vehicle_maker AS preferred_vehicle_maker, order_count
FROM state_maker_popularity
WHERE rank_num = 1
ORDER BY state ASC;
```

---

### 3. Customer Satisfaction Collapse & Sentiment Shift
* **Rating Deterioration**: Customer satisfaction dropped monotonically from **$3.56$ in $Q1$** to **$2.40$ in $Q4$** (a **$-32.6\%$** reduction).
* **Negative Sentiment Explosion**: Orders rated **"Bad" or "Very Bad"** surged from **$22.26\%$ in $Q1$** to **$59.80\%$ in $Q4$**, while "Very Good" ratings collapsed from $30.00\%$ to $10.05\%$.

<p align="center">
  <img src="reports/figures/04_quarterly_satisfaction_collapse.png" width="48%" alt="Rating Collapse" />
  <img src="reports/figures/05_feedback_sentiment_trend.png" width="48%" alt="Feedback Sentiment Trend" />
</p>

```sql
-- Query 5: Quarterly Feedback Distribution via Conditional Aggregation
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
```

---

### 4. Revenue Contraction & Margin Leakage
* **Top-Line Decay**: Quarterly net revenue fell by **$-52.5\%$**, dropping from **$\$18.03\text{M}$ ($Q1$)** $\rightarrow$ **$\$13.12\text{M}$ ($Q2$, $-27.2\%$ QoQ)** $\rightarrow$ **$\$8.88\text{M}$ ($Q3$, $-32.3\%$ QoQ)** $\rightarrow$ **$\$8.57\text{M}$ ($Q4$, $-3.5\%$ QoQ)**.
* **Average Order Value (AOV)**: Compressed from **$\$58,169$** in $Q1$ to **$\$43,081$** in $Q4$ due to product mix shifts and severe promotional discounting.
* **Credit Card Margin Drain**: Average discounts across all $16$ card issuers ranged from **$58.4\%$ to $64.4\%$**, with JCB driving **$424$ orders** and receiving over **$\$32.06\text{M}$ in discounts**.

<p align="center">
  <img src="reports/figures/06_revenue_and_order_trend.png" width="48%" alt="Revenue and Orders" />
  <img src="reports/figures/08_credit_card_discounts.png" width="48%" alt="Credit Card Discounts" />
</p>

```sql
-- Query 7: Net Revenue & Quarter-over-Quarter (QoQ) Growth using LAG()
WITH quarterly_financials AS (
    SELECT 
        quarter_number,
        SUM(quantity * vehicle_price * (1.0 - discount)) AS net_revenue_usd
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
    ) AS qoq_revenue_growth_pct
FROM quarterly_financials
ORDER BY quarter_number ASC;
```

---

### 5. 🎯 The Root Cause: Fulfillment Logistics Failure

By cross-analyzing shipping turnaround with customer ratings, the analysis reveals the definitive bottleneck driving New-Wheels' decline:

<p align="center">
  <img src="reports/figures/07_shipping_delay_vs_ratings.png" width="80%" alt="Shipping Delay vs Rating Collapse" />
</p>

```
                       THE CASUAL CHAIN OF PLATFORM CONTRACTION
┌─────────────────────────┐     ┌─────────────────────────┐     ┌─────────────────────────┐
│   LOGISTICS COLLAPSE    │     │   SENTIMENT COLLAPSE    │     │    BUSINESS ATTRITION   │
│ Shipping days tripled   │ ──► │ Negative feedback rose  │ ──► │ Order volume down -36%  │
│ from 57.2d to 174.1d    │     │ from 22.3% to 59.8%;    │     │ Net revenue down -52.5% │
│ (Max delivery 525 days) │     │ Ratings fell 3.56 ➔ 2.40│     │ Reputational contagion  │
└─────────────────────────┘     └─────────────────────────┘     └─────────────────────────┘
```

* **Shipping Duration Surge**: Average turnaround exploded from **$57.17$ days in $Q1$** to **$174.10$ days in $Q4$ ($+204.5\%$)**.
* **Extreme Outliers**: In $Q3$, maximum shipping turnaround reached **$525$ days** (nearly $1.5$ years).
* **Direct Causal Impact**: Customers waiting up to $6$ months for vehicle delivery left overwhelmingly critical reviews, creating negative word-of-mouth that depressed new customer acquisition in subsequent quarters.

---

## 💼 Strategic Recommendations Playbook

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                 NEW-WHEELS STRATEGIC TURNAROUND PLAYBOOK                    │
├───────────────────────┬─────────────────────────────────────────────────────┤
│ 🎯 PRIORITY 1         │ Logistics & 3PL Fulfillment SLA Overhaul            │
│ Carrier Restructuring │ • Enforce 14-day delivery SLAs with financial       │
│                       │   penalties for carrier breaches.                   │
│                       │ • Replace underperforming shippers with regional    │
│                       │   freight partners in TX, CA, and FL.               │
│                       │ • Deploy real-time GPS vehicle tracking portal.     │
├───────────────────────┼─────────────────────────────────────────────────────┤
│ 💳 PRIORITY 2         │ Discount Rationalization & Margin Protection        │
│ Margin Recovery       │ • Cap promotional credit card discounts (currently  │
│                       │   60-64%) at 15-20% tiered by vehicle aging.        │
│                       │ • Renegotiate interchange fees with JCB & Mastercard│
│                       │   to recover an estimated $20M+ annual margin.      │
├───────────────────────┼─────────────────────────────────────────────────────┤
│ 📍 PRIORITY 3         │ Hyper-Local Inventory Regional Hubs                 │
│ Demand Alignment      │ • Pre-position Chevrolet, Ford, and Toyota inventory│
│                       │   in Dallas/Houston, Los Angeles, and Orlando.      │
│                       │ • Reduce cross-country transit mileage by 65%.      │
├───────────────────────┼─────────────────────────────────────────────────────┤
│ 🤝 PRIORITY 4         │ Proactive Customer Recovery & Reputation Repair     │
│ Brand Rehabilitation  │ • Establish Customer Escalation Taskforce for       │
│                       │   orders exceeding 20 days in transit.              │
│                       │ • Provide automated fuel vouchers & service credits │
│                       │   to restore review ratings above 4.2 / 5.0.        │
└───────────────────────┴─────────────────────────────────────────────────────┘
```

---

## 🏆 Academic Evaluation & Grading

This project was submitted for formal academic evaluation in the **Post Graduate Program in Data Science** (*Introduction to SQL Module*), earning a score of **$57$ / $60$ ($95.0\%$)**:

```
========================================================================================
🏆 ACADEMIC EVALUATION SCORE: 57 / 60 (95.0%) - GRADE: EXCELLENT
========================================================================================
  Criteria                                  Max Points   Score Awarded   Status
  ─────────────────────────────────────────────────────────────────────────────
  1. Answering Business Questions (10 Qs)       40            37         ⚠️ -3.0 Marks
  2. Insights and Recommendations               10            10         ✅ Full Marks
  3. SQL Query Hygiene & Formatting             10            10         ✅ Full Marks
========================================================================================
```

### 🛠️ Post-Evaluation Enhancements & Fixes
Following academic evaluation, all identified rubric items and structural opportunities were addressed to achieve $100\%$ pro-grade industry quality:

1. **Explicit Customer Count (Q1 Fix)**: Decoupled total customer calculation (`COUNT(DISTINCT customer_id) = 994`) from state-level grouping to satisfy strict multi-part requirements.
2. **Complete Output Rendering (Q3 & Q7 Fixes)**: Resolved missing table screenshots in the initial submission by providing complete output DataFrames and high-resolution chart exports.
3. **Data Representation & Discount Semantics (Q7 & Q8 Fixes)**: Dissected decimal fraction encoding (`0.67` = $67\%$) versus academic rubric percentage-scale expectations, providing dual-benchmark transparency.
4. **Automated Figure Pipeline**: Developed an automated Python visualization engine generating $8$ publication-grade figures in [`reports/figures/`](reports/figures/).
5. **Modular SQL Architecture**: Refactored monolithic queries into individual, documented SQL files with CTEs, window functions, and cross-dialect compatibility.

---

## 📁 Repository Structure

```
new-wheels-sql-business-analysis/
│
├── README.md                            # Comprehensive executive case study & documentation
├── LICENSE                              # MIT License
├── requirements.txt                     # Python dependencies for analysis & visualization
├── .gitignore                           # Git exclusion rules for draft and internal files
│
├── data/
│   ├── new_wheels_dump.sql              # Reproducible SQL schema & seed script
│   ├── new_wheels.db                    # Pre-built SQLite database for instant querying
│   └── data_dictionary.md               # Detailed relational data dictionary & ER schema
│
├── sql/
│   ├── 01_customer_distribution.sql     # Q1: Customer reach & state distribution
│   ├── 02_top_vehicle_makers.sql        # Q2: Top 5 preferred vehicle manufacturers
│   ├── 03_preferred_maker_by_state.sql  # Q3: Most preferred maker per state (Window CTE)
│   ├── 04_quarterly_customer_ratings.sql# Q4: Quarterly & overall rating averages
│   ├── 05_quarterly_feedback_distribution.sql # Q5: Sentiment breakdown by quarter
│   ├── 06_quarterly_order_trends.sql    # Q6: Order volume & customer velocity
│   ├── 07_quarterly_net_revenue_and_qoq.sql # Q7: Net revenue & QoQ % change (LAG)
│   ├── 08_quarterly_revenue_and_order_trends.sql # Q8: Revenue, volume & AOV correlation
│   ├── 09_credit_card_discount_analysis.sql # Q9: Credit card discount policy & margins
│   ├── 10_shipping_logistics_efficiency.sql # Q10: Shipping turnaround & logistics lag
│   └── all_business_queries.sql         # Unified end-to-end SQL script
│
├── notebooks/
│   └── new_wheels_sql_analysis.ipynb    # Interactive Jupyter Notebook with outputs & plots
│
├── reports/
│   ├── New_Wheels_Executive_Business_Report.docx # Enhanced executive Word report
│   └── figures/                         # 8 exported publication-grade high-res visuals
│       ├── 01_executive_kpi_dashboard.png
│       ├── 02_state_customer_distribution.png
│       ├── 03_top_vehicle_makers.png
│       ├── 04_quarterly_satisfaction_collapse.png
│       ├── 05_feedback_sentiment_trend.png
│       ├── 06_revenue_and_order_trend.png
│       ├── 07_shipping_delay_vs_ratings.png
│       └── 08_credit_card_discounts.png
│
└── assets/
    ├── erd_diagram.png                  # Entity relationship diagram
    └── social_preview.png               # OpenGraph repository social card
```

---

## 🚀 Quickstart & Reproducibility

### 1. Clone Repository & Set Up Environment
```bash
# Clone repository
git clone https://github.com/Souhrid-Dey/new-wheels-sql-business-analysis.git
cd new-wheels-sql-business-analysis

# Create and activate virtual environment
python -m venv venv
# Windows:
venv\Scripts\activate
# Linux / macOS:
source venv/bin/activate

# Install required packages
pip install -r requirements.txt
```

### 2. Execute SQL Queries via SQLite CLI or Python
```bash
# Run the complete SQL suite against SQLite
sqlite3 data/new_wheels.db < sql/all_business_queries.sql
```

### 3. Launch Interactive Analysis Notebook
```bash
jupyter notebook notebooks/new_wheels_sql_analysis.ipynb
```

---

## 👤 Author

**Souhrid Dey**  
- **GitHub**: [@Souhrid-Dey](https://github.com/Souhrid-Dey)  
- **Program**: Post Graduate Program in Data Science  
- **Module**: Introduction to SQL  

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
