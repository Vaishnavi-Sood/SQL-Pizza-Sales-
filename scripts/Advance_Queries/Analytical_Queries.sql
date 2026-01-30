/*
Advanced analytical SQL queries leveraging joins, CTEs, and window functions
to evaluate sales performance, revenue trends, ranking metrics, and contribution
analysis across products and stores in a pizza ordering system.
*/

-- Rank Best Selling Pizzas

SELECT
	pm.pizza_name,
	SUM(oi.quantity) AS total_sold,
	RANK() OVER (ORDER BY SUM(oi.quantity) DESC) AS sales_rank
FROM order_items oi
JOIN pizza_variants pv ON oi.variant_id = pv.variant_id
JOIN pizza_menu pm ON pv.pizza_code = pm.pizza_code
GROUP BY pm.pizza_name;

-- Running Total of Revenue (Window Function)

SELECT 
	CAST(co.order_datetime AS DATE) AS order_date,
	SUM(oi.quantity * (pm.base_price * pv.price_multiplier)) AS daily_revenue,
	SUM(
		SUM(oi.quantity * (pm.base_price * pv.price_multiplier))
	) OVER (ORDER BY CAST(co.order_datetime AS DATE)) AS running_revenue
FROM customer_orders co
JOIN order_items oi ON co.order_id = oi.order_id
JOIN pizza_variants pv ON oi.variant_id = pv.variant_id
JOIN pizza_menu pm ON pv.pizza_code = pm.pizza_code
GROUP BY CAST(co.order_datetime AS DATE)
ORDER BY order_date;

-- CTE: High-Value Orders

WITH OrderTotals AS (
    SELECT 
        co.order_id,
        SUM(oi.quantity * (pm.base_price * pv.price_multiplier)) AS order_value
    FROM customer_orders co
    JOIN order_items oi ON co.order_id = oi.order_id
    JOIN pizza_variants pv ON oi.variant_id = pv.variant_id
    JOIN pizza_menu pm ON pv.pizza_code = pm.pizza_code
    GROUP BY co.order_id
)
SELECT *
FROM OrderTotals
WHERE order_value > 30;

-- Store Performance Comparison (Window Function)

SELECT 
    s.store_name,
    SUM(oi.quantity * (pm.base_price * pv.price_multiplier)) AS revenue,
    DENSE_RANK() OVER (ORDER BY SUM(oi.quantity * (pm.base_price * pv.price_multiplier)) DESC) AS store_rank
FROM stores s
JOIN customer_orders co ON s.store_id = co.store_id
JOIN order_items oi ON co.order_id = oi.order_id
JOIN pizza_variants pv ON oi.variant_id = pv.variant_id
JOIN pizza_menu pm ON pv.pizza_code = pm.pizza_code
GROUP BY s.store_name;

-- Percentage Contribution (Advanced Analytics)

SELECT 
    pm.pizza_name,
    SUM(oi.quantity) AS units_sold,
    CAST(
        100.0 * SUM(oi.quantity) /
        SUM(SUM(oi.quantity)) OVER () AS DECIMAL(5,2)
    ) AS sales_percentage
FROM order_items oi
JOIN pizza_variants pv ON oi.variant_id = pv.variant_id
JOIN pizza_menu pm ON pv.pizza_code = pm.pizza_code
GROUP BY pm.pizza_name;
