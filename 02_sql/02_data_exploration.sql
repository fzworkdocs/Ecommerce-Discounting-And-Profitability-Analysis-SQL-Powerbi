--TABLE CONTENT
SELECT *
FROM sales_raw

--INFORMATION OF COLUMNS
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'sales_raw'
ORDER BY ordinal_position

--COUNT OF ROWS
SELECT COUNT(*)
FROM sales_raw

--DISTINCT PRODUCT CATEGORY
SELECT product_category
FROM sales_raw
GROUP BY product_category

--LIST OF PRODUCTS IN EACH PRODUCT CATEGORY
SELECT product_category,product
FROM sales_raw
GROUP BY product_category,product
ORDER BY product_category

--DISTINCT PRODUCT
SELECT product
FROM sales_raw
GROUP BY product

--DISTINCT PAYMENT METHODS
SELECT payment_method
FROM sales_raw
GROUP BY payment_method

--CHECK FOR NULLS
SELECT *
FROM sales_raw
WHERE quantity IS NULL OR
aging IS NULL OR
shipping_cost IS NULL OR
profit IS NULL OR
discount IS NULL OR
sales IS NULL

