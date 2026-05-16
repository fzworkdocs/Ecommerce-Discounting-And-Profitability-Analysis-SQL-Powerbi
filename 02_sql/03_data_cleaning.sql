--CREATE CLEAN TABLE
CREATE TABLE sales_clean AS
SELECT 
    --customer info
    customer_id,
    gender,
    customer_login_type,
    --order info
    CAST(order_date AS DATE) AS order_date,
    CAST(time AS TIME)AS order_time,
    order_priority,
    COALESCE(aging,AVG(aging)OVER()) AS aging,
    --device channel info
    device_type,
    --product info
    product_category,
    product,
    --financial info
    quantity,
    sales,
    COALESCE(discount,0)AS discount,
    COALESCE(shipping_cost,0) AS shipping_cost,
    COALESCE(profit,0)AS profit,
    payment_method
FROM 
    sales_raw
WHERE
    sales IS NOT NULL AND quantity IS NOT NULL

--GET ALL DATA
SELECT *
FROM sales_clean

--CHANGE DATA TYPES OF COLUMNS
ALTER TABLE sales_clean
ALTER COLUMN sales TYPE numeric,
ALTER COLUMN profit TYPE numeric,
ALTER COLUMN shipping_cost TYPE numeric,
ALTER COLUMN discount TYPE numeric;

--REMOVING DECIMAL VALUES FROM AGING COLUMN
UPDATE sales_clean
SET aging = TRUNC(aging);

--REMOVING NULL FROM ORDER_PRIORITY COLUMN
UPDATE sales_clean
SET order_priority='Low'
WHERE order_priority IS NULL