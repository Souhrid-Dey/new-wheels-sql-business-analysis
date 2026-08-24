# New-Wheels Database Data Dictionary

This document outlines the entity-relationship schema, table structures, column definitions, data types, and key constraints for the **New-Wheels** vehicle resale database.

---

## Entity Relationship Overview

The database consists of 4 normalized relational tables:
- **`customer_t`**: Demographic, geographic, and payment details of registered customers.
- **`product_t`**: Inventory catalog detailing vehicle maker, model, manufacturing year, and list price.
- **`shipper_t`**: Logistics and shipping vendor directory.
- **`order_t`**: Transactional facts connecting customers, products, and shippers with fulfillment dates, discounts, pricing, and customer feedback.

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   customer_t    │       │     order_t     │       │    product_t    │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ customer_id PK  │◄──────┤ customer_id FK  │──────►│ product_id PK   │
│ customer_name   │       │ product_id  FK  │       │ vehicle_maker   │
│ gender          │       │ shipper_id  FK  │       │ vehicle_model   │
│ job_title       │       │ order_id    PK  │       │ vehicle_color   │
│ phone_number    │       │ quantity        │       │ vehicle_model_yr│
│ email_address   │       │ vehicle_price   │       │ vehicle_price   │
│ city, state     │       │ order_date      │       └─────────────────┘
│ credit_card_type│       │ ship_date       │
└─────────────────┘       │ discount        │       ┌─────────────────┐
                          │ customer_feedbk │       │    shipper_t    │
                          │ quarter_number  │       ├─────────────────┤
                          └───────┬─────────┘       │ shipper_id PK   │
                                  └────────────────►│ shipper_name    │
                                                    │ contact_details │
                                                    └─────────────────┘
```

---

## Detailed Table Specifications

### 1. `customer_t` (Customer Demographics & Payment Attributes)
- **Primary Key**: `customer_id`
- **Total Records**: 994

| Column Name | Data Type | Nullable | Description | Sample Value |
| :--- | :--- | :--- | :--- | :--- |
| `customer_id` | `VARCHAR(25)` | **No** | Unique identifier for each customer | `'0002-4115'` |
| `customer_name` | `VARCHAR(25)` | Yes | Full name of the customer | `'Rafaela Hummerston'` |
| `gender` | `VARCHAR(15)` | Yes | Gender of the customer (`Male`, `Female`) | `'Female'` |
| `job_title` | `VARCHAR(50)` | Yes | Customer occupation / employment title | `'Research Associate'` |
| `phone_number` | `VARCHAR(20)` | Yes | Customer contact telephone number | `'862-258-2947'` |
| `email_address` | `VARCHAR(50)` | Yes | Customer email address | `'rhummerston0@google.ca'` |
| `city` | `VARCHAR(25)` | Yes | Residing municipality / city | `'Newark'` |
| `country` | `VARCHAR(25)` | Yes | Residing country | `'United States'` |
| `state` | `VARCHAR(25)` | Yes | Residing US state (49 distinct states) | `'New Jersey'` |
| `customer_address`| `VARCHAR(50)` | Yes | Street address | `'56880 Brentwood Lane'` |
| `postal_code` | `VARCHAR(20)` | Yes | ZIP / Postal code | `'07195'` |
| `credit_card_type`| `VARCHAR(30)` | Yes | Payment card issuer type (16 distinct types) | `'jcb'`, `'mastercard'` |
| `credit_card_number`| `BIGINT` | Yes | Tokenized / registered credit card number | `4018780000000000` |

---

### 2. `product_t` (Vehicle Inventory Catalog)
- **Primary Key**: `product_id`
- **Total Records**: 1,000

| Column Name | Data Type | Nullable | Description | Sample Value |
| :--- | :--- | :--- | :--- | :--- |
| `product_id` | `INT` | **No** | Unique product identifier | `1` |
| `vehicle_maker` | `VARCHAR(60)` | Yes | Manufacturer / OEM brand name (29 distinct makers) | `'Chevrolet'`, `'Ford'`, `'Toyota'` |
| `vehicle_model` | `VARCHAR(60)` | Yes | Specific model name | `'Suburban 1500'` |
| `vehicle_color` | `VARCHAR(60)` | Yes | Exterior paint finish | `'Turquoise'` |
| `vehicle_model_year`| `INT` | Yes | Year of manufacture | `2008` |
| `vehicle_price` | `DECIMAL(10,2)`| Yes | Suggested retail price (MSRP / listing price) | `72762.15` |

---

### 3. `shipper_t` (Logistics & Carriers)
- **Primary Key**: `shipper_id`
- **Total Records**: 1,000

| Column Name | Data Type | Nullable | Description | Sample Value |
| :--- | :--- | :--- | :--- | :--- |
| `shipper_id` | `INT` | **No** | Unique logistics carrier identifier | `1` |
| `shipper_name` | `VARCHAR(50)` | Yes | Corporate name of the shipping partner | `'United Parcel Service'` |
| `shipper_contact_details`| `VARCHAR(30)`| Yes | Carrier contact telephone number | `'708-616-2489'` |

---

### 4. `order_t` (Transaction & Fulfillment Facts)
- **Primary Key**: `order_id`
- **Foreign Keys**: `customer_id` -> `customer_t(customer_id)`, `product_id` -> `product_t(product_id)`, `shipper_id` -> `shipper_t(shipper_id)`
- **Total Records**: 1,000

| Column Name | Data Type | Nullable | Description | Sample Value |
| :--- | :--- | :--- | :--- | :--- |
| `order_id` | `VARCHAR(25)` | **No** | Unique order transaction number | `'33276-809'` |
| `customer_id` | `VARCHAR(25)` | Yes | Customer who placed the order | `'0002-4115'` |
| `shipper_id` | `INT` | Yes | Assigned carrier ID | `1` |
| `product_id` | `INT` | Yes | Purchased vehicle ID | `1` |
| `quantity` | `INT` | Yes | Units purchased in order | `1` |
| `vehicle_price` | `DECIMAL(10,2)`| Yes | Unit price at transaction time | `72762.15` |
| `order_date` | `DATE` | Yes | Date order was placed | `'2020-04-18'` |
| `ship_date` | `DATE` | Yes | Date order was delivered / shipped | `'2020-05-18'` |
| `discount` | `DECIMAL(4,2)` | Yes | Applied promotional discount rate (decimal fraction, e.g. 0.67 = 67%) | `0.67` |
| `ship_mode` | `VARCHAR(25)` | Yes | Shipping speed class (`Standard Class`, `First Class`, etc.) | `'Standard Class'` |
| `shipping` | `VARCHAR(30)` | Yes | Fulfillment status (`Shipped`, `In Transit`) | `'Shipped'` |
| `customer_feedback`| `VARCHAR(20)`| Yes | Post-delivery satisfaction rating (`Very Bad`, `Bad`, `Okay`, `Good`, `Very Good`) | `'Good'` |
| `quarter_number` | `INT` | Yes | Fiscal quarter of the order (`1`, `2`, `3`, `4`) | `1` |
