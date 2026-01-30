/*
Comprehensive data simulation and analytical workflow to populate transactional tables
with realistic multi-store order data and derive month-level revenue, growth trends,
and comparative performance insights using CTEs and window functions.
*/

-- 50 orders Per store month

DECLARE @startDate DATE = '2025-01-01';
DECLARE @endDate   DATE = '2025-12-31';

INSERT INTO customer_orders (store_id, order_datetime, order_channel, payment_method)
SELECT
    s.store_id,

    DATEADD(
        MINUTE,
        ABS(CHECKSUM(NEWID())) % 900,
        CAST(
            DATEADD(
                DAY,
                ABS(CHECKSUM(NEWID())) % DATEDIFF(DAY, @startDate, @endDate),
                @startDate
            ) AS DATETIME
        )
    ) AS order_datetime,

    CHOOSE(ABS(CHECKSUM(NEWID())) % 3 + 1, 'Dine-In', 'Online', 'Takeaway'),
    CHOOSE(ABS(CHECKSUM(NEWID())) % 3 + 1, 'Cash', 'Card', 'UPI')

FROM stores s
CROSS JOIN (
    SELECT TOP (50) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) n
    FROM sys.objects
) t;

-- Auto Generate Order Items

INSERT INTO order_items (order_id, variant_id, quantity, discount_applied)
SELECT 
    o.order_id,
    ABS(CHECKSUM(NEWID())) % (SELECT COUNT(*) FROM pizza_variants) + 1,
    ABS(CHECKSUM(NEWID())) % 3 + 1,
    ABS(CHECKSUM(NEWID())) % 2
FROM customer_orders o;

-- Monthly Revenue per Store 

WITH MonthlySales AS (
    SELECT 
        s.store_name,
        FORMAT(co.order_datetime, 'yyyy-MM') AS sales_month,
        SUM(oi.quantity * (pm.base_price * pv.price_multiplier)) AS monthly_revenue
    FROM stores s
    JOIN customer_orders co ON s.store_id = co.store_id
    JOIN order_items oi ON co.order_id = oi.order_id
    JOIN pizza_variants pv ON oi.variant_id = pv.variant_id
    JOIN pizza_menu pm ON pv.pizza_code = pm.pizza_code
    GROUP BY 
        s.store_name,
        FORMAT(co.order_datetime, 'yyyy-MM')
)
SELECT * 
FROM MonthlySales
ORDER BY store_name, sales_month;


-- Month Over Month Growth 📈

WITH MonthlySales AS (
    SELECT 
        s.store_name,
        FORMAT(co.order_datetime, 'yyyy-MM') AS sales_month,
        SUM(oi.quantity * (pm.base_price * pv.price_multiplier)) AS revenue
    FROM stores s
    JOIN customer_orders co ON s.store_id = co.store_id
    JOIN order_items oi ON co.order_id = oi.order_id
    JOIN pizza_variants pv ON oi.variant_id = pv.variant_id
    JOIN pizza_menu pm ON pv.pizza_code = pm.pizza_code
    GROUP BY 
        s.store_name,
        FORMAT(co.order_datetime, 'yyyy-MM')
),
GrowthCalc AS (
    SELECT
        store_name,
        sales_month,
        revenue,
        LAG(revenue) OVER (PARTITION BY store_name ORDER BY sales_month) AS prev_month_revenue
    FROM MonthlySales
)
SELECT 
    store_name,
    sales_month,
    revenue,
    prev_month_revenue,
    CAST(
        (revenue - prev_month_revenue) * 100.0 /
        NULLIF(prev_month_revenue, 0)
        AS DECIMAL(6, 2)
    ) AS growth_percentage
FROM GrowthCalc
ORDER BY store_name, sales_month;

-- Best Growing Store Per Month

WITH GrowthData AS (
    SELECT
        s.store_name,
        FORMAT(co.order_datetime, 'yyyy-MM') AS sales_month,
        SUM(oi.quantity * (pm.base_price * pv.price_multiplier)) AS revenue
    FROM stores s
    JOIN customer_orders co ON s.store_id = co.store_id
    JOIN order_items oi ON co.order_id = oi.order_id
    JOIN pizza_variants pv ON oi.variant_id = pv.variant_id
    JOIN pizza_menu pm ON pv.pizza_code = pm.pizza_code
    GROUP BY 
        s.store_name,
        FORMAT(co.order_datetime, 'yyyy-MM')
),
RankedGrowth AS (
    SELECT *,
        RANK() OVER (PARTITION BY sales_month ORDER BY revenue DESC) AS rank_in_month
    FROM GrowthData
)
SELECT * 
FROM RankedGrowth
WHERE rank_in_month = 1;
