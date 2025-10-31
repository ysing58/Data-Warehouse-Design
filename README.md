# Data-Warehouse-Design

## Overview
This repository contains SQL scripts and schema documentation for a dimensional data warehouse design. The project demonstrates best practices in building scalable data warehouse solutions for analytical workloads and business intelligence.

## Schema Design
The data warehouse follows a **Star Schema** architecture optimized for analytical queries and reporting.

### Design Principles
- **Star Schema**: Central fact tables surrounded by dimension tables
- **Slowly Changing Dimensions (SCD)**: Type 2 implementation for historical tracking
- **Denormalization**: Optimized for query performance
- **Grain Definition**: Clearly defined granularity for each fact table
- **Surrogate Keys**: System-generated keys for dimension tables

## Database Objects

### Dimension Tables
1. **dim_date** - Time dimension with calendar and fiscal attributes
2. **dim_customer** - Customer attributes with SCD Type 2
3. **dim_product** - Product hierarchy and attributes with SCD Type 2
4. **dim_store** - Store location and attributes

### Fact Tables
1. **fact_sales** - Transactional sales data at order line level
2. **fact_inventory** - Daily inventory snapshots

### Aggregate Tables
1. **agg_daily_sales** - Pre-aggregated daily sales metrics
2. **agg_monthly_product** - Monthly product performance summary

### Views
1. **vw_sales_summary** - Comprehensive sales analysis view
2. **vw_top_products** - Product performance ranking

## Schema Diagram
```
                    +-------------+
                    |  dim_date   |
                    +-------------+
                           |
    +-------------+        |        +-------------+
    |dim_customer |        |        | dim_product |
    +-------------+        |        +-------------+
            \              |              /
             \             |             /
              \     +-------------+    /
               \----|  fact_sales |---/
                    +-------------+
                           |
                    +-------------+
                    |  dim_store  |
                    +-------------+
```

## Key Features

### Performance Optimization
- Strategic indexing on foreign keys and frequently queried columns
- Partition strategies for large fact tables
- Materialized aggregate tables for common queries
- Appropriate data types to minimize storage

### Data Quality
- NOT NULL constraints on critical fields
- Foreign key relationships for referential integrity
- UNIQUE constraints on business keys
- Default values for optional fields

### Analytical Capabilities
- Time-series analysis support through date dimension
- Customer segmentation and tier analysis
- Product hierarchy for drill-down analysis
- Geographic analysis through store dimensions
- Historical tracking through SCD Type 2

## Files in Repository

- **schema.sql** - Complete DDL scripts for all database objects
- **README.md** - This documentation file

## Usage

### Creating the Schema
```sql
-- Execute the schema creation script
source schema.sql;

-- Or in PostgreSQL
\i schema.sql
```

### Sample Queries

#### Revenue by Region and Quarter
```sql
SELECT 
    s.region,
    d.quarter,
    d.year,
    SUM(f.total_amount) as total_revenue
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_store s ON f.store_key = s.store_key
GROUP BY s.region, d.quarter, d.year
ORDER BY d.year, d.quarter, s.region;
```

#### Top Customers by Purchase Value
```sql
SELECT 
    c.customer_name,
    c.customer_tier,
    COUNT(DISTINCT f.order_id) as order_count,
    SUM(f.total_amount) as total_spent
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE c.is_current = TRUE
GROUP BY c.customer_name, c.customer_tier
ORDER BY total_spent DESC
LIMIT 10;
```

## Technical Skills Demonstrated

- **Data Modeling**: Star schema, dimension design, fact table design
- **SQL**: DDL, complex queries, views, indexing
- **Data Warehouse Concepts**: SCD, grain definition, aggregations
- **Performance Tuning**: Indexing strategies, materialized aggregates
- **ETL Design**: Source-to-target mappings, data transformations
- **Business Intelligence**: Analytical query patterns, metrics definition

## Use Cases

- Retail analytics and reporting
- Sales performance analysis
- Inventory management
- Customer behavior analysis
- Product performance tracking
- Regional comparisons
- Time-series analysis

## Database Compatibility

The schema is written in standard SQL and can be adapted for:
- PostgreSQL
- MySQL
- Oracle
- Microsoft SQL Server
- Amazon Redshift
- Google BigQuery
- Snowflake

## Author
Designed for Data Engineering and Analytics portfolio demonstrations
