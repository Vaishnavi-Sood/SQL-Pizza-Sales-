/*=======================================================================
SAMPLE DATA POPULATION SCRIPT

Purpose:
- Populate master and transaction tables with sample data
- Create stores, pizza catalog, size variants, ingredients, and orders
- Generate realistic transactional data for testing and analytics

What this script does:
1. Inserts sample pizza stores across multiple cities
2. Populates pizza menu with classic, gourmet, premium, and fusion pizzas
3. Creates size-based pricing variants for all pizzas
4. Auto-generates 500 customer orders with random channels and payments
5. Inserts order line items linked to generated orders
6. Populates ingredients master with costs for food-cost analysis

Intended Use:
- Demo / testing environment
- SQL analytics practice
- Reporting, joins, and performance testing
=======================================================================*/

-- Insert Sample Stores
INSERT INTO stores (store_name, city, opening_date)
VALUES 
('Downtown Pizza', 'New York', '2020-01-15'),
('Urban Slice', 'Chicago', '2021-06-10'),
('Crust Corner', 'Los Angeles', '2019-09-01');

-- Insert Pizza Menu

INSERT INTO pizza_menu (pizza_code, pizza_name, base_price, pizza_style)
VALUES
('PZ01', 'Margherita', 8.00, 'Classic'),
('PZ02', 'Pepperoni', 10.00, 'Classic'),
('PZ03', 'BBQ Chicken', 12.00, 'Gourmet'),
('PZ04', 'Veggie Supreme', 11.00, 'Gourmet');

-- Add More Pizza 

INSERT INTO pizza_menu (pizza_code, pizza_name, base_price, pizza_style)
VALUES
-- Classic Pizzas
('PZ05', 'Farmhouse', 11.00, 'Classic'),
('PZ06', 'Four Cheese', 12.50, 'Classic'),
('PZ07', 'Hawaiian', 11.50, 'Classic'),

-- Gourmet Pizzas
('PZ08', 'Truffle Mushroom', 14.00, 'Gourmet'),
('PZ09', 'Mediterranean Veg', 13.00, 'Gourmet'),
('PZ10', 'Spicy Mexican', 12.00, 'Gourmet'),

-- Meat Lovers
('PZ11', 'Meat Lovers', 14.50, 'Meat'),
('PZ12', 'Chicken Tikka', 13.50, 'Meat'),
('PZ13', 'Peri Peri Chicken', 14.00, 'Meat'),

-- Speciality / Premium
('PZ14', 'Seafood Deluxe', 15.50, 'Premium'),
('PZ15', 'Buffalo Chicken', 14.25, 'Premium'),
('PZ16', 'Smoky Sausage', 13.75, 'Premium'),

-- Vegetarian Specials
('PZ17', 'Paneer Makhani', 12.75, 'Vegetarian'),
('PZ18', 'Spinach & Feta', 12.25, 'Vegetarian'),
('PZ19', 'Corn & Cheese', 11.25, 'Vegetarian'),

-- Fusion & Unique
('PZ20', 'Cheesy BBQ Burst', 13.50, 'Fusion'),
('PZ21', 'Masala Twist', 12.00, 'Fusion'),
('PZ22', 'Garlic Alfredo Veg', 12.50, 'Fusion');


-- Insert Pizza Variants (Sizes)

INSERT INTO pizza_variants (pizza_code, pizza_size, price_multiplier)
VALUES
('PZ01','S',1.0), ('PZ01','M',1.3), ('PZ01','L',1.6),
('PZ02','S',1.0), ('PZ02','M',1.4), ('PZ02','L',1.7),
('PZ03','M',1.5), ('PZ03','L',1.8),
('PZ04','M',1.4), ('PZ04','L',1.7);

-- ADD SIZE VARIANTS FOR NEW PIZZAS

INSERT INTO pizza_variants (pizza_code, pizza_size, price_multiplier)
SELECT pizza_code, 'S', 1.0 FROM pizza_menu
UNION ALL
SELECT pizza_code, 'M', 1.4 FROM pizza_menu
UNION ALL
SELECT pizza_code, 'L', 1.7 FROM pizza_menu;


-- Insert 500 Orders Automatically (BEST WAY)

DECLARE @i INT = 1;

WHILE @i <= 500
BEGIN
    INSERT INTO customer_orders 
    (store_id, order_datetime, order_channel, payment_method)
    VALUES
    (
        ABS(CHECKSUM(NEWID())) % 3 + 1,
        DATEADD(MINUTE, -ABS(CHECKSUM(NEWID())) % 50000, GETDATE()),
        CHOOSE(ABS(CHECKSUM(NEWID())) % 3 + 1, 'Dine-In', 'Online', 'Takeaway'),
        CHOOSE(ABS(CHECKSUM(NEWID())) % 3 + 1, 'Cash', 'Card', 'UPI')
    );

    SET @i = @i + 1;
END;

-- Insert Orders Items (Linked to Orders)

INSERT INTO order_items (order_id, variant_id, quantity, discount_applied)
SELECT 
    o.order_id,
    ABS(CHECKSUM(NEWID())) % 10 + 1,
    ABS(CHECKSUM(NEWID())) % 3 + 1,
    ABS(CHECKSUM(NEWID())) % 3
FROM customer_orders o;

-- Insert Values for ingredients table

INSERT INTO ingredients (ingredient_name, cost_per_unit)
VALUES
-- Cheese & Dairy
('Mozzarella Cheese', 0.80),
('Cheddar Cheese', 0.90),
('Parmesan Cheese', 1.10),
('Feta Cheese', 1.00),
('Butter', 0.40),

-- Sauces
('Tomato Sauce', 0.30),
('BBQ Sauce', 0.50),
('Alfredo Sauce', 0.60),
('Pesto Sauce', 0.70),

-- Vegetables
('Onion', 0.20),
('Capsicum', 0.25),
('Mushroom', 0.35),
('Black Olives', 0.45),
('Sweet Corn', 0.30),
('Spinach', 0.28),
('Tomato', 0.22),
('Jalapeno', 0.32),
('Garlic', 0.15),

-- Meats & Protein
('Pepperoni', 1.20),
('Chicken', 1.00),
('Sausage', 1.30),
('Bacon', 1.40),
('Seafood Mix', 1.80),
('Paneer', 0.90),

-- Herbs & Seasoning
('Oregano', 0.10),
('Chili Flakes', 0.12),
('Basil', 0.14),
('Black Pepper', 0.08);
