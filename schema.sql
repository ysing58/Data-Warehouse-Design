-- ================================================
-- Data Warehouse Schema Design
-- Star Schema for Retail Analytics
-- ================================================

-- ================================================
-- DIMENSION TABLES
-- ================================================

-- Date Dimension
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    date_value DATE NOT NULL,
    day_of_week VARCHAR(10),
    day_of_month INT,
    day_of_year INT,
    week_of_year INT,
    month_number INT,
    month_name VARCHAR(10),
    quarter INT,
    year INT,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN,
    fiscal_period VARCHAR(10),
    UNIQUE(date_value)
);

-- Customer Dimension
CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    customer_segment VARCHAR(50),
    customer_tier VARCHAR(20),
    registration_date DATE,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    effective_date DATE NOT NULL,
    expiration_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    UNIQUE(customer_id, effective_date)
);

-- Product Dimension
CREATE TABLE dim_product (
    product_key INT PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(200),
    product_description TEXT,
    category VARCHAR(50),
    subcategory VARCHAR(50),
    brand VARCHAR(50),
    unit_price DECIMAL(10,2),
    unit_cost DECIMAL(10,2),
    supplier_name VARCHAR(100),
    effective_date DATE NOT NULL,
    expiration_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    UNIQUE(product_id, effective_date)
);

-- Store Dimension
CREATE TABLE dim_store (
    store_key INT PRIMARY KEY,
    store_id VARCHAR(50) NOT NULL,
    store_name VARCHAR(100),
    store_type VARCHAR(50),
    store_size VARCHAR(20),
    city VARCHAR(50),
    state VARCHAR(50),
    region VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    opening_date DATE,
    manager_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(store_id)
);

-- ================================================
-- FACT TABLES
-- ================================================

-- Sales Fact Table
CREATE TABLE fact_sales (
    sales_key BIGINT PRIMARY KEY,
    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    store_key INT NOT NULL,
    order_id VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2),
    discount_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(12,2),
    cost_amount DECIMAL(12,2),
    profit_amount DECIMAL(12,2),
    payment_method VARCHAR(50),
    transaction_timestamp TIMESTAMP,
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (store_key) REFERENCES dim_store(store_key)
);

CREATE INDEX idx_sales_date ON fact_sales(date_key);
CREATE INDEX idx_sales_customer ON fact_sales(customer_key);
CREATE INDEX idx_sales_product ON fact_sales(product_key);
CREATE INDEX idx_sales_store ON fact_sales(store_key);
CREATE INDEX idx_sales_timestamp ON fact_sales(transaction_timestamp);

-- Inventory Fact Table
CREATE TABLE fact_inventory (
    inventory_key BIGINT PRIMARY KEY,
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    store_key INT NOT NULL,
    quantity_on_hand INT,
    quantity_allocated INT,
    quantity_available INT,
    reorder_level INT,
    reorder_quantity INT,
    unit_cost DECIMAL(10,2),
    inventory_value DECIMAL(12,2),
    snapshot_timestamp TIMESTAMP,
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (store_key) REFERENCES dim_store(store_key)
);

CREATE INDEX idx_inventory_date ON fact_inventory(date_key);
CREATE INDEX idx_inventory_product ON fact_inventory(product_key);
CREATE INDEX idx_inventory_store ON fact_inventory(store_key);

-- ================================================
-- AGGREGATE TABLES (for performance optimization)
-- ================================================

-- Daily Sales Aggregate
CREATE TABLE agg_daily_sales (
    date_key INT,
    store_key INT,
    total_transactions INT,
    total_quantity INT,
    total_revenue DECIMAL(15,2),
    total_cost DECIMAL(15,2),
    total_profit DECIMAL(15,2),
    average_transaction_value DECIMAL(10,2),
    PRIMARY KEY (date_key, store_key),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (store_key) REFERENCES dim_store(store_key)
);

-- Monthly Product Performance
CREATE TABLE agg_monthly_product (
    year_month VARCHAR(7),
    product_key INT,
    units_sold INT,
    revenue DECIMAL(15,2),
    cost DECIMAL(15,2),
    profit DECIMAL(15,2),
    profit_margin DECIMAL(5,2),
    PRIMARY KEY (year_month, product_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key)
);

-- ================================================
-- VIEWS FOR COMMON QUERIES
-- ================================================

-- Sales Summary View
CREATE VIEW vw_sales_summary AS
SELECT 
    d.date_value,
    d.month_name,
    d.year,
    c.customer_name,
    c.customer_tier,
    p.product_name,
    p.category,
    s.store_name,
    s.region,
    f.quantity,
    f.total_amount,
    f.profit_amount
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_store s ON f.store_key = s.store_key
WHERE c.is_current = TRUE
  AND p.is_current = TRUE;

-- Top Products by Revenue
CREATE VIEW vw_top_products AS
SELECT 
    p.product_name,
    p.category,
    p.brand,
    SUM(f.quantity) as total_quantity,
    SUM(f.total_amount) as total_revenue,
    SUM(f.profit_amount) as total_profit,
    ROUND(AVG(f.unit_price), 2) as avg_price
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
WHERE p.is_current = TRUE
GROUP BY p.product_name, p.category, p.brand
ORDER BY total_revenue DESC;

-- ================================================
-- END OF SCHEMA
-- ================================================
