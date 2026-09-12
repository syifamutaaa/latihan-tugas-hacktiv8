-----------------------------------------
--ddl
-----------------------------------------
--buat db
CREATE DATABASE thelook_dw;

-- DIMENSION CUSTOMER
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    gender VARCHAR(20),
    age INTEGER,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    traffic_source VARCHAR(100),
    created_at TIMESTAMP
);

-- DIMENSION PRODUCT
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL UNIQUE,
    product_name VARCHAR(255),
    category VARCHAR(100),
    brand VARCHAR(100),
    department VARCHAR(100),
    sku VARCHAR(100),
    retail_price NUMERIC(12,2),
    product_cost NUMERIC(12,2),
    distribution_center_id INTEGER
);

-- DIMENSION DISTRIBUTION CENTER
CREATE TABLE dim_distribution_center (
    distribution_center_key SERIAL PRIMARY KEY,
    distribution_center_id INTEGER NOT NULL UNIQUE,
    distribution_center_name VARCHAR(255),
    latitude NUMERIC(10,6),
    longitude NUMERIC(10,6)
);

-- DIMENSION DATE
CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL,
    day INTEGER,
    month INTEGER,
    month_name VARCHAR(20),
    quarter INTEGER,
    year INTEGER
);

-- FACT SALES
CREATE TABLE fact_sales (
    sales_key BIGSERIAL PRIMARY KEY,

    order_item_id INTEGER NOT NULL,
    order_id INTEGER NOT NULL,

    customer_key INTEGER,
    product_key INTEGER,
    distribution_center_key INTEGER,
    date_key INTEGER,

    quantity INTEGER,
    sale_price NUMERIC(12,2),
    total_sales NUMERIC(14,2),
    product_cost NUMERIC(12,2),
    profit NUMERIC(14,2),

    CONSTRAINT fk_customer
        FOREIGN KEY (customer_key)
        REFERENCES dim_customer(customer_key),

    CONSTRAINT fk_product
        FOREIGN KEY (product_key)
        REFERENCES dim_product(product_key),

    CONSTRAINT fk_distribution
        FOREIGN KEY (distribution_center_key)
        REFERENCES dim_distribution_center(distribution_center_key),

    CONSTRAINT fk_date
        FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key)
);


-------------------------------------------------
--DML
-------------------------------------------------
-- ============================================================
-- DML DATA WAREHOUSE THE LOOK
-- ============================================================

-- 1. DIM CUSTOMER
COPY dim_customer (
    customer_id,
    first_name,
    last_name,
    gender,
    age,
    city,
    state,
    country,
    traffic_source
)
FROM 'D:\latihan_tugas_hacktive\output\dim_customer\dim_customer.csv'
WITH (FORMAT csv, HEADER true);


-- 2. DIM PRODUCT
COPY dim_product (
    product_id,
    product_name,
    category,
    brand,
    department,
    sku,
    product_cost,
    retail_price,
    distribution_center_id
)
FROM 'D:\latihan_tugas_hacktive\output\dim_product\dim_product.csv'
WITH (FORMAT csv, HEADER true);


-- 3. DIM DISTRIBUTION CENTER
COPY dim_distribution_center (
    distribution_center_id,
    distribution_center_name,
    latitude,
    longitude
)
FROM 'D:\latihan_tugas_hacktive\output\dim_distribution_center\dim_distribution_center.csv'
WITH (FORMAT csv, HEADER true);


-- 4. DIM DATE
COPY dim_date (
    date_key,
    full_date,
    day,
    month,
    month_name,
    quarter,
    year
)
FROM 'D:\latihan_tugas_hacktive\output\dim_date\dim_date.csv'
WITH (FORMAT csv, HEADER true);


-- 5. STAGING FACT SALES
CREATE TEMP TABLE staging_fact_sales (
    order_item_id INTEGER,
    order_id INTEGER,
    customer_id INTEGER,
    product_id INTEGER,
    distribution_center_id INTEGER,
    date_key INTEGER,
    quantity INTEGER,
    sale_price NUMERIC(12,2),
    total_sales NUMERIC(14,2),
    product_cost NUMERIC(12,2),
    profit NUMERIC(14,2)
);


COPY staging_fact_sales
FROM 'D:\latihan_tugas_hacktive\output\fact_sales\fact_sales.csv'
WITH (FORMAT csv, HEADER true);


-- 6. FACT SALES
INSERT INTO fact_sales (
    order_item_id,
    order_id,
    customer_key,
    product_key,
    distribution_center_key,
    date_key,
    quantity,
    sale_price,
    total_sales,
    product_cost,
    profit
)
SELECT
    s.order_item_id,
    s.order_id,
    c.customer_key,
    p.product_key,
    dc.distribution_center_key,
    s.date_key,
    s.quantity,
    s.sale_price,
    s.total_sales,
    s.product_cost,
    s.profit
FROM staging_fact_sales s
JOIN dim_customer c
    ON s.customer_id = c.customer_id
JOIN dim_product p
    ON s.product_id = p.product_id
JOIN dim_distribution_center dc
    ON s.distribution_center_id = dc.distribution_center_id
JOIN dim_date d
    ON s.date_key = d.date_key;

-- 7. VALIDASI
SELECT COUNT(*) AS total_customer FROM dim_customer;
SELECT COUNT(*) AS total_product FROM dim_product;
SELECT COUNT(*) AS total_distribution_center FROM dim_distribution_center;
SELECT COUNT(*) AS total_date FROM dim_date;
SELECT COUNT(*) AS total_fact_sales FROM fact_sales;

--setelah selesai copy
--Query validasi yang dijalankan di PostgreSQL:

SELECT COUNT(*) FROM dim_customer;
SELECT COUNT(*) FROM dim_product;
SELECT COUNT(*) FROM dim_distribution_center;
SELECT COUNT(*) FROM dim_date;
SELECT COUNT(*) FROM fact_sales;
