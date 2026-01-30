/* 
Professional, normalized relational database schema for a multi-store pizza ordering system.
Designed to support transactional sales, pricing variants, customer orders, and ingredient-level
analytics with referential integrity and scalability in mind.
*/

-- Store Table (Multiple Outlets Support)

CREATE TABLE stores (
	store_id INT IDENTITY PRIMARY KEY,
	store_name VARCHAR(100),
	city VARCHAR(50),
	opening_date DATE
);

-- Customer Order Table (High Level Order Info)

CREATE TABLE customer_orders (
	order_id INT IDENTITY PRIMARY KEY,
	store_id INT,
	order_datetime DATETIME,
	order_channel VARCHAR(20),
	payment_method VARCHAR(20),
	FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- Pizza Master Table (Product Catalog)

CREATE TABLE pizza_menu (
	pizza_code VARCHAR(10) PRIMARY KEY,
	pizza_name VARCHAR(100),
	base_price DECIMAL(6,2),
	pizza_style VARCHAR(30),
);

-- Pizza Size & Pricing Strategy table

CREATE TABLE pizza_variants (
	variant_id INT IDENTITY PRIMARY KEY,
	pizza_code VARCHAR(10),
	pizza_size CHAR(1),
	price_multiplier DECIMAL(4,2),
	FOREIGN KEY (pizza_code) REFERENCES pizza_menu(pizza_code)
);

-- Order Line Items Table (Sales Details)
CREATE TABLE order_items (
	item_id INT IDENTITY PRIMARY KEY,
	order_id INT,
	variant_id INT,
	quantity INT,
	discount_applied DECIMAL(5,2),
	FOREIGN KEY (order_id) REFERENCES customer_orders(order_id),
    FOREIGN KEY (variant_id) REFERENCES pizza_variants(variant_id)
);

-- Ingredients Table (Advanced Analytics)

CREATE TABLE ingredients (
    ingredient_id INT IDENTITY PRIMARY KEY,
    ingredient_name VARCHAR(50),
    cost_per_unit DECIMAL(5,2)
);

-- Pizza Recipe Mapping (Many-to-Many)

CREATE TABLE pizza_recipe (
    pizza_code VARCHAR(10),
    ingredient_id INT,
    quantity_required INT,
    PRIMARY KEY (pizza_code, ingredient_id),
    FOREIGN KEY (pizza_code) REFERENCES pizza_menu(pizza_code),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);
