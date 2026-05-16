--ALL DATA
SELECT *
FROM sales_clean

--DATE RANGE(2018)
SELECT MIN(order_date)AS oldest,
MAX(order_date) AS latest
FROM sales_clean

--TOTAL REVENUE=78,13,285
--TOTAL PROFIT=36,10,971.9
--PROFIT MARGIN=46.22
SELECT
    SUM(sales) AS Total_Revenue,
    ROUND(SUM(profit),2) AS Total_Profit,
    ROUND(
        (SUM(profit)/NULLIF(SUM(sales),0))*100,
        2) AS Profit_Margin
FROM 
    sales_clean

SELECT discount
from sales_clean
group by discount
order by discount DESC

--HIGH DISCOUNT VS LOW DISCOUNT ON SALES AND PROFIT
SELECT
    CASE 
        WHEN discount=0 THEN 'No Discount'
        WHEN discount<=0.15 THEN 'Low (5-15%)'
        WHEN discount<=0.35 THEN 'Medium (20-35%)'
        WHEN discount<=0.50 THEN 'High(35-50%)'
        ELSE 'Very High'
    END AS discount_bracket,
    COUNT(*) AS total_orders,
    SUM(sales) AS Total_Revenue,
    ROUND(SUM(profit),0) AS Total_Profit,
    ROUND(
        (SUM(profit)/NULLIF(SUM(sales),0)*100),0)AS Profit_Margin,
   ROUND(AVG(profit),0) AS avg_profit_per_order
FROM sales_clean
GROUP BY
    discount_bracket
ORDER BY
    total_revenue DESC,total_profit DESC

--PRODUCT CATEGORY ON SALES AND PROFIT
SELECT 
    product_category,
    COUNT(*) AS total_orders,
    SUM(sales) AS Total_Revenue,
    ROUND(SUM(profit),0) AS Total_Profit,
      ROUND(
        (SUM(profit)/NULLIF(SUM(sales),0)*100),0)AS Profit_Margin
FROM sales_clean
GROUP BY product_category
ORDER BY Total_Revenue DESC,Total_Profit DESC

--ELECTRONIC CATEGORY PRODUCTS
SELECT 
    product,
    COUNT(*) AS Total_Orders,
    SUM(sales) AS Total_Revenue,
    ROUND(SUM(profit),0) AS Total_Profit
FROM sales_clean
WHERE product_category='Electronic'
GROUP BY product
ORDER BY Total_Revenue DESC,Total_Product

--TOP AND BOTTOM PRODUCTS
SELECT 
    product,
    COUNT(*) AS Total_Orders,
    SUM(sales) AS Total_Revenue,
    ROUND(SUM(profit),0) AS Total_Profit,
     ROUND(
        (SUM(profit)/NULLIF(SUM(sales),0)*100),0)AS Profit_Margin
FROM sales_clean
GROUP BY product
ORDER BY Total_Revenue DESC ,Total_Profit DESC
LIMIT 5

--PRODUCT AND PRODUCT CATEGORY WITH DELIVERY TIME TAKEN

/*SELECT aging
FROM sales_clean
GROUP BY aging
ORDER BY aging*/ 

SELECT
    CASE
        WHEN aging<=3 THEN 'Fast(<3)'
        WHEN aging<=7 THEN 'Medium(4-7)'
        ELSE 'Slow(8-10)'
        END AS Delivery_Rates,
    COUNT(*) AS Total_Orders,
    SUM(sales) AS Total_Revenue,
    ROUND(SUM(profit),0) AS Total_Profit,
    ROUND(
        (SUM(profit)/NULLIF(SUM(sales),0)*100),0)AS Profit_Margin,
    AVG(sales) AS avg_sales
FROM sales_clean
GROUP BY Delivery_Rates
ORDER BY Total_Revenue DESC, Total_Profit DESC

--MAXIMUM DISCOUNT GIVEN TO PRODUCT CATEGORIES
SELECT MAX(discount)*100 AS max_discount,
product_category
FROM sales_clean
GROUP BY product_category
--FOR PRODUCT
SELECT
    product,
    SUM(sales) AS Total_Revenue,
    ROUND(SUM(profit),0) AS Total_Profit,
    ROUND(CAST(AVG(aging) as integer),0) AS avg_delivery_time
FROM sales_clean
GROUP BY product
ORDER BY total_revenue DESC,total_profit DESC

--CHECKING IF LOW PROFIT PRODUCTS HAVE HIGH DISCOUNTS
SELECT 
    product_category,
    ROUND(AVG(discount)*100,2) AS avg_discount
FROM sales_clean
GROUP BY product_category
ORDER BY avg_discount DESC

--PRODUCT CATEGORY WISE ORDER PRIORITY

SELECT
    product_category,
    MODE() WITHIN GROUP (ORDER BY order_priority) AS most_order_priority_given
FROM sales_clean
GROUP BY product_category

--REVENUE AND PROFIT BY ORDER_PRIORITY
SELECT
    order_priority,
    SUM(sales) AS Total_Revenue,
    ROUND(SUM(profit),0) AS Total_Profit
FROM sales_clean
GROUP BY order_priority
ORDER BY total_revenue DESC,total_profit DESC

--AVERAGE SHIPPING COST PER PRODUCT CATEGORY
SELECT product_category,
AVG(shipping_cost) AS avg_ship_cost
FROM sales_clean
GROUP BY product_category

--IF PAYMENT METHOD AFFECTS ELECTRONIC LOW PROFITS
SELECT 
    product_category,
    MODE()WITHIN GROUP (ORDER BY payment_method) AS most_used_payment_method
FROM sales_clean
GROUP BY product_category

--MALE OR FEMALE MOST PURCHASE PRODUCTS FROM CERTAIN CATEGORIES
SELECT 
    product_category,
    MODE()WITHIN GROUP (ORDER BY gender) AS gender_wise_purchase
FROM sales_clean
GROUP BY product_category

--which type of customer login is most popular
--is electronic department having the login type least popular
SELECT customer_login_type,
COUNT(*) AS orders
FROM sales_clean
GROUP BY customer_login_type

--POPULAR LOGIN TYPE IN EACH PRODUCT CATEGORY
SELECT 
    product_category,
    MODE()WITHIN GROUP (ORDER BY customer_login_type) AS most_login_type
FROM sales_clean
GROUP BY product_category

--COUNT OF ORDER PER DEVICE TYPE
SELECT device_type,
COUNT(*) AS orders
FROM sales_clean
GROUP BY device_type

--QUANTITY PURCHASED IN EACH PRODUCT CATEGORY
SELECT product_category,
SUM(quantity) AS total_quantity
FROM sales_clean
GROUP BY product_category

--TOP CUSTOMERS
SELECT customer_id,
COUNT(*) AS total_orders,
ROUND(CAST(AVG(sales) AS INTEGER),0) AS avg_sales,
SUM(sales) AS Total_Revenue,
ROUND(SUM(profit),0) AS Total_Profit
FROM sales_clean
GROUP BY customer_id
ORDER BY total_orders DESC,total_revenue DESC,total_profit DESC

--IS ELECTRONIC PRODUCT CATEGORY HAVE LOW PRICE ITEMS
SELECT product_category,
ROUND(AVG(profit),1) AS average_profit
FROM sales_clean
GROUP  BY product_category
ORDER BY average_profit DESC

SELECT product_category,
ROUND(AVG(sales),1) AS average_sales
FROM sales_clean
GROUP  BY product_category
ORDER BY average_sales DESC

--MONTH AND YEAR NAMES
SELECT 
    TO_CHAR(order_date,'Month') AS month_name,
    EXTRACT(YEAR FROM order_date) AS year
FROM sales_clean
GROUP BY month_name,year

--MoM AVERAGE DISCOUNT 
WITH monthly_metrics AS(
    SELECT 
        DATE_TRUNC('month',order_date) AS month,
       ROUND(AVG(discount)*100,1) AS avg_discount
    FROM sales_clean
    GROUP BY 1
)
SELECT 
    TO_CHAR(month,'Month') AS month_name,
    avg_discount,
    LAG(avg_discount) OVER (ORDER BY month),
    --MoM
    (avg_discount-LAG(avg_discount) OVER (ORDER BY month))/
    NULLIF( LAG(avg_discount) OVER (ORDER BY month),0)*100 
    AS mom_discount
FROM monthly_metrics
ORDER BY month 

--MTD
SELECT SUM(profit) as total_profit
FROM sales_clean
WHERE EXTRACT(MONTH FROM order_date)=12
--MoM profit 
WITH monthly_profit AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) as yr,
        EXTRACT(MONTH FROM order_date) as mon,
        SUM(profit) as total_profit
    FROM sales_clean
    GROUP BY 1, 2
)
SELECT 
    yr, 
    mon,
    total_profit,
    LAG(total_profit) OVER (ORDER BY yr, mon) as prev_month_profit,
    ROUND((total_profit - LAG(total_profit) OVER (ORDER BY yr, mon)) 
          / NULLIF(LAG(total_profit) OVER (ORDER BY yr, mon), 0) * 100, 2) as mom_pct
FROM monthly_profit;

--MoM revenue 
WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) as yr,
        EXTRACT(MONTH FROM order_date) as mon,
        SUM(sales) as total_revenue
    FROM sales_clean
    GROUP BY 1, 2
)
SELECT 
    yr, 
    mon,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY yr, mon) as prev_month_sales,
    ROUND((total_revenue - LAG(total_revenue) OVER (ORDER BY yr, mon)) 
          / NULLIF(LAG(total_revenue) OVER (ORDER BY yr, mon), 0) * 100, 2) as mom_pct
FROM monthly_sales;

--MoM profit margin 
WITH monthly_profit AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) as yr,
        EXTRACT(MONTH FROM order_date) as mon,
       ROUND(
        (SUM(profit)/NULLIF(SUM(sales),0)*100),0)AS profit_margin
    FROM sales_clean
    GROUP BY 1, 2
)
SELECT 
    yr, 
    mon,
    profit_margin,
    LAG( profit_margin) OVER (ORDER BY yr, mon) as prev_month_profit,
    ROUND(( profit_margin- LAG( profit_margin) OVER (ORDER BY yr, mon)) 
          / NULLIF(LAG( profit_margin) OVER (ORDER BY yr, mon), 0) * 100, 2) as mom_pct
FROM monthly_profit;

--CHECK MONTH WISE AVERAGE QUANTITY SOLD AVERAGE PRICE OF SALE AND AVERAGE DISCOUNT
SELECT 
    EXTRACT(MONTH FROM order_date) AS month_num,
    TO_CHAR(order_date,'Month') AS month_name,
    ROUND(AVG(discount)*100,0) AS avg_discount,
    ROUND(CAST(AVG(quantity) AS INTEGER),0) AS avg_quantity,
    ROUND(AVG(sales),0)AS avg_sales
FROM sales_clean 
GROUP BY month_name,month_num
ORDER BY month_num


WITH MonthlyData AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month_date,
        TO_CHAR(order_date, 'Month') AS month_name,
        SUM(sales) AS total_revenue,
        SUM(profit) AS total_profit
    FROM sales_clean
    GROUP BY 1, 2
    ORDER BY 1
),
Lags AS (
    SELECT 
        month_name,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY month_date) AS prev_revenue,
        total_profit,
        LAG(total_profit) OVER (ORDER BY month_date) AS prev_profit
    FROM MonthlyData
)
SELECT 
    month_name,
    -- Revenue MoM % Calculation
    ROUND(
        ((total_revenue - prev_revenue) / NULLIF(prev_revenue, 0)) * 100, 
        2
    ) || '%' AS mom_revenue_pct,
    -- Profit MoM % Calculation
    ROUND(
        ((total_profit - prev_profit) / NULLIF(prev_profit, 0)) * 100, 
        2
    ) || '%' AS mom_profit_pct
FROM Lags;

--Basket Analysis
WITH transactions AS (
    SELECT
        CONCAT(customer_id, '_', order_date) AS transaction_id,
        product
    FROM sales_clean
),

product_pairs AS (
    SELECT
        t1.product AS product_1,
        t2.product AS product_2,
        COUNT(*) AS combo_frequency
    FROM transactions t1
    JOIN transactions t2
        ON t1.transaction_id = t2.transaction_id
       AND t1.product < t2.product
    GROUP BY
        t1.product,
        t2.product
)

SELECT *
FROM product_pairs
ORDER BY combo_frequency DESC
LIMIT 10;

SELECT customer_id,
COUNT(*)
FROM sales_clean
GROUP BY customer_id