SELECT * FROM dim_date

DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_location CASCADE

---Top 5 Mostnprofitable Product---
SELECT 
    p.product_name,
    SUM(f.profit) AS total_profit
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_profit DESC
LIMIT 5;

---Which category is losing Money?---
SELECT 
    p.category,
    SUM(f.profit) AS total_profit
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_profit;

---Does discount reduces profit?---
SELECT 
    discount,
    ROUND(AVG(profit)::numeric, 2) AS avg_profit
FROM fact_sales
GROUP BY discount
ORDER BY discount;

---Why is furniture losing money?---
SELECT 
    dp.category,
    ROUND(SUM(fs.sales)::numeric, 2) AS total_sales,
    ROUND(SUM(fs.profit)::numeric, 2) AS total_profit
FROM fact_sales fs
JOIN dim_product dp 
    ON fs.product_key = dp.product_key
GROUP BY dp.category
ORDER BY total_profit;

---Which sub-category is dragging furniture down?---
SELECT 
    dp.sub_category,
    ROUND(SUM(fs.sales)::numeric, 2) AS total_sales,
    ROUND(SUM(fs.profit)::numeric, 2) AS total_profit
FROM fact_sales fs
JOIN dim_product dp 
    ON fs.product_key = dp.product_key
WHERE dp.category = 'Furniture'
GROUP BY dp.sub_category
ORDER BY total_profit;

---Renaming the sub-category column to sub_category---
ALTER TABLE dim_product
RENAME COLUMN "sub-category" TO sub_category;

---Is discount causing the loss?---
SELECT 
    fs.discount,
    ROUND(AVG(fs.profit)::numeric, 2) AS avg_profit,
    COUNT(*) AS transaction_count
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_key = dp.product_key
WHERE dp.category = 'Furniture'
GROUP BY fs.discount
ORDER BY fs.discount;

---Top 10 loss making Products---
SELECT 
    dp.product_name,
    ROUND(SUM(fs.sales)::numeric, 2) AS total_sales,
    ROUND(SUM(fs.profit)::numeric, 2) AS total_profit
FROM fact_sales fs
JOIN dim_product dp 
    ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY total_profit ASC
LIMIT 10;

---Which Region is causing the furniture loss---
SELECT 
    dl.region,
    ROUND(SUM(fs.sales)::numeric, 2) AS total_sales,
    ROUND(SUM(fs.profit)::numeric, 2) AS total_profit
FROM fact_sales fs
JOIN dim_product dp 
    ON fs.product_key = dp.product_key
JOIN dim_location dl
    ON fs.location_key = dl.location_key
WHERE dp.category = 'Furniture'
GROUP BY dl.region
ORDER BY total_profit;

ALTER TABLE dim_date
ADD PRIMARY KEY (date_key);

ALTER TABLE fact_sales
ADD PRIMARY KEY (row_id);

ALTER TABLE fact_sales
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_key)
REFERENCES dim_customer(customer_key);

ALTER TABLE fact_sales
ADD CONSTRAINT fk_product
FOREIGN KEY (product_key)
REFERENCES dim_product(product_key);

ALTER TABLE fact_sales
ADD CONSTRAINT fk_location
FOREIGN KEY (location_key)
REFERENCES dim_location(location_key);

ALTER TABLE fact_sales
ADD CONSTRAINT fk_date
FOREIGN KEY (date_key)
REFERENCES dim_date(date_key);

SELECT COUNT(*) FROM fact_sales;