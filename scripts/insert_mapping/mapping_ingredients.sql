/*=======================================================================
PIZZA → INGREDIENTS MAPPING (pizza_recipe INSERTS)

Purpose:
- Defines the Bill of Materials (BOM) for each pizza
- Maps pizzas to their required ingredients
- Specifies ingredient quantities per pizza
- Supports cost analysis, inventory tracking, and recipe analytics

Tables Used:
- ingredients       : Source of ingredient IDs
- pizza_recipe      : Stores pizza-to-ingredient relationships
- pizza_menu        : Used later for verification
=======================================================================*/

-- Margherita (PZ01)

INSERT INTO pizza_recipe (pizza_code, ingredient_id, quantity_required)
SELECT 'PZ01', ingredient_id, 2 FROM ingredients WHERE ingredient_name IN
('mozzarella cheese','tomato sauce');
-------------------------------------------------------------------------------------

-- Pepperoni (PZ02)

INSERT INTO pizza_recipe (pizza_code, ingredient_id, quantity_required)
SELECT 'PZ02', ingredient_id,
       CASE 
           WHEN ingredient_name = 'pepperoni' THEN 3
           ELSE 2
       END
FROM ingredients
WHERE ingredient_name IN ('mozzarella cheese','tomato sauce','pepperoni');
---------------------------------------------------------------------------------------

-- BBQ Chicken (PZ03)

INSERT INTO pizza_recipe (pizza_code, ingredient_id, quantity_required)
SELECT 'PZ03', ingredient_id,
       CASE 
           WHEN ingredient_name = 'chicken' THEN 3
           ELSE 2
       END
FROM ingredients
WHERE ingredient_name IN ('mozzarella cheese','bbq sauce','chicken','onion');
-------------------------------------------------------------------------------------------

-- Veggie Supreme (PZ04)

INSERT INTO pizza_recipe (pizza_code, ingredient_id, quantity_required)
SELECT 'PZ04', ingredient_id, 2
FROM ingredients
WHERE ingredient_name IN
('mozzarella cheese','tomato sauce','onion','capsicum','mushroom','black olives');
---------------------------------------------------------------------------------------------

-- Farmhouse (PZ05)

INSERT INTO pizza_recipe (pizza_code, ingredient_id, quantity_required)
SELECT 'PZ05', ingredient_id, 2
FROM ingredients
WHERE ingredient_name IN
('mozzarella cheese','tomato sauce','onion','capsicum','sweet corn','mushroom');
--------------------------------------------------------------------------------------------

-- Four Cheese (PZ06)

INSERT INTO pizza_recipe (pizza_code, ingredient_id, quantity_required)
SELECT 'PZ06', ingredient_id, 2
FROM ingredients
WHERE ingredient_name IN
('mozzarella cheese','cheddar cheese','parmesan cheese','feta cheese');
-------------------------------------------------------------------------------------------

-- Hawaiian (PZ07)

INSERT INTO pizza_recipe (pizza_code, ingredient_id, quantity_required)
SELECT 'PZ07', ingredient_id,
       CASE 
           WHEN ingredient_name = 'chicken' THEN 2
           ELSE 1
       END
FROM ingredients
WHERE ingredient_name IN
('mozzarella cheese','tomato sauce','chicken','sweet corn');
---------------------------------------------------------------------------------------------

-- Truffle Mushroom (PZ08)

INSERT INTO pizza_recipe (pizza_code, ingredient_id, quantity_required)
SELECT 'PZ08', ingredient_id, 2
FROM ingredients
WHERE ingredient_name IN
('mozzarella cheese','alfredo sauce','mushroom','garlic');
---------------------------------------------------------------------------------------------

-- Mediterranean Veg (PZ09)

INSERT INTO pizza_recipe (pizza_code, ingredient_id, quantity_required)
SELECT 'PZ09', ingredient_id, 2
FROM ingredients
WHERE ingredient_name IN
('mozzarella cheese','tomato sauce','black olives','spinach','tomato');
---------------------------------------------------------------------------------------------

-- Spicy Mexican (PZ10)

INSERT INTO pizza_recipe (pizza_code, ingredient_id, quantity_required)
SELECT 'PZ10', ingredient_id,
       CASE 
           WHEN ingredient_name = 'jalapeno' THEN 3
           ELSE 2
       END
FROM ingredients
WHERE ingredient_name IN
('mozzarella cheese','tomato sauce','jalapeno','onion','capsicum');
-------------------------------------------------------------------------------------------------

-- Verify Mapping

SELECT 
    pm.pizza_name,
    i.ingredient_name,
    pr.quantity_required
FROM pizza_recipe pr
JOIN pizza_menu pm ON pr.pizza_code = pm.pizza_code
JOIN ingredients i ON pr.ingredient_id = i.ingredient_id
ORDER BY pm.pizza_name;
