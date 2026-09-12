-- ============================================================
-- EXTRACT DATA THE LOOK E-COMMERCE
-- ============================================================
-- FACT SALES
-- Data penjualan berdasarkan order item yang order-nya tidak Cancelled
SELECT
    oi.id AS order_item_id,
    oi.order_id,
    oi.user_id AS customer_id,
    oi.product_id,
    p.distribution_center_id,
    DATE(o.created_at) AS sales_date,

    1 AS quantity,

    oi.sale_price,

    p.cost AS product_cost,

    oi.sale_price * 1 AS total_sales,

    (oi.sale_price - p.cost) * 1 AS profit

FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

INNER JOIN `bigquery-public-data.thelook_ecommerce.orders` AS o
    ON oi.order_id = o.order_id

INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
    ON oi.product_id = p.id

WHERE o.status != 'Cancelled';


-- DIMENSION CUSTOMER
SELECT
    id AS customer_id,
    first_name,
    last_name,
    gender,
    age,
    city,
    state,
    country,
    traffic_source
FROM `bigquery-public-data.thelook_ecommerce.users`;


-- DIMENSION PRODUCT
SELECT
    id AS product_id,
    name AS product_name,
    category,
    brand,
    department,
    sku,
    cost,
    retail_price,
    distribution_center_id
FROM `bigquery-public-data.thelook_ecommerce.products`;



-- DIMENSION DISTRIBUTION CENTER
SELECT
    id AS dc_id,
    name AS dc_name,
    latitude,
    longitude
FROM `bigquery-public-data.thelook_ecommerce.distribution_centers`;


-- DIMENSION DATE
SELECT DISTINCT
    DATE(created_at) AS full_date
FROM `bigquery-public-data.thelook_ecommerce.orders`
WHERE created_at IS NOT NULL
ORDER BY full_date;
