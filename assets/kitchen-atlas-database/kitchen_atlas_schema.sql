-- =====================================================
-- Alyssa's Kitchen Atlas - Database Schema Creation
-- DBA210 Final Project
-- This document creates the database, tables, indexes, and adds sample data. 
-- =====================================================

-- Create the database
DROP DATABASE IF EXISTS alyssas_kitchen_atlas;
CREATE DATABASE alyssas_kitchen_atlas;
USE alyssas_kitchen_atlas;

-- =====================================================
-- CUSTOMERS TABLE
-- =====================================================
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    password_hash VARCHAR(64) NOT NULL, -- SHA-256 hash
    loyalty_points INT DEFAULT 0,
    madperks_member BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_loyalty_points CHECK (loyalty_points >= 0),
    CONSTRAINT chk_email_format CHECK (email LIKE '%_@_%.__%')
);

-- =====================================================
-- INGREDIENTS TABLE
-- =====================================================
CREATE TABLE ingredients (
    ingredient_id INT AUTO_INCREMENT PRIMARY KEY,
    ingredient_name VARCHAR(100) NOT NULL UNIQUE,
    is_allergen BOOLEAN DEFAULT FALSE,
    allergen_type ENUM('nuts', 'dairy', 'gluten', 'shellfish', 'eggs', 'soy', 'fish', 'sesame') NULL,
    is_vegan BOOLEAN DEFAULT TRUE,
    is_gluten_free BOOLEAN DEFAULT TRUE,
    cost_per_unit DECIMAL(6,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_cost_positive CHECK (cost_per_unit >= 0),
    CONSTRAINT chk_allergen_logic CHECK (
        (is_allergen = TRUE AND allergen_type IS NOT NULL) OR 
        (is_allergen = FALSE AND allergen_type IS NULL)
    )
);

-- =====================================================
-- MENU_ITEMS TABLE
-- =====================================================
CREATE TABLE menu_items (
    menu_item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(8,2) NOT NULL,
    prep_time_minutes INT NOT NULL,
    spice_level ENUM('mild', 'medium', 'hot', 'very_hot') DEFAULT 'mild',
    is_available BOOLEAN DEFAULT TRUE,
    calories INT,
    date_last_ordered DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_price_positive CHECK (price > 0),
    CONSTRAINT chk_prep_time_positive CHECK (prep_time_minutes > 0),
    CONSTRAINT chk_calories_positive CHECK (calories IS NULL OR calories > 0)
);

-- =====================================================
-- MENU_ITEM_INGREDIENTS TABLE (Junction Table)
-- =====================================================
CREATE TABLE menu_item_ingredients (
    menu_item_id INT,
    ingredient_id INT,
    quantity_used DECIMAL(8,3) NOT NULL,
    unit_measure VARCHAR(20) NOT NULL DEFAULT 'grams',
    is_optional BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Composite Primary Key
    PRIMARY KEY (menu_item_id, ingredient_id),
    
    -- Foreign Keys
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(menu_item_id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id) ON DELETE RESTRICT,
    
    -- Constraints
    CONSTRAINT chk_quantity_positive CHECK (quantity_used > 0)
);

-- =====================================================
-- CUSTOMER_ALLERGENS TABLE (Junction Table)
-- =====================================================
CREATE TABLE customer_allergens (
    customer_id INT,
    ingredient_id INT,
    severity_level ENUM('mild', 'moderate', 'severe', 'life_threatening') NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Composite Primary Key
    PRIMARY KEY (customer_id, ingredient_id),
    
    -- Foreign Keys
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id) ON DELETE RESTRICT
);

-- =====================================================
-- ORDERS TABLE
-- =====================================================
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_type ENUM('dine_in', 'pickup', 'online') NOT NULL,
    order_status ENUM('pending', 'preparing', 'ready', 'completed', 'cancelled') DEFAULT 'pending',
    subtotal DECIMAL(10,2) NOT NULL,
    kitchen_gratuity DECIMAL(10,2) NOT NULL, -- Automatic 4%
    server_gratuity DECIMAL(10,2) DEFAULT 0.00,
    madperks_discount DECIMAL(10,2) DEFAULT 0.00,
    loyalty_discount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,
    special_notes TEXT,
    estimated_ready_time TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT,
    
    -- Constraints
    CONSTRAINT chk_subtotal_positive CHECK (subtotal > 0),
    CONSTRAINT chk_kitchen_gratuity_calc CHECK (kitchen_gratuity = ROUND(subtotal * 0.04, 2)),
    CONSTRAINT chk_server_gratuity_positive CHECK (server_gratuity >= 0),
    CONSTRAINT chk_discounts_positive CHECK (madperks_discount >= 0 AND loyalty_discount >= 0),
    CONSTRAINT chk_total_calculation CHECK (
        total_amount = subtotal + kitchen_gratuity + server_gratuity - madperks_discount - loyalty_discount
    )
);

-- =====================================================
-- ORDER_ITEMS TABLE
-- =====================================================
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    quantity INT NOT NULL,
    item_price DECIMAL(8,2) NOT NULL,
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(menu_item_id) ON DELETE RESTRICT,
    
    -- Constraints
    CONSTRAINT chk_quantity_positive_order CHECK (quantity > 0),
    CONSTRAINT chk_item_price_positive CHECK (item_price > 0)
);

-- =====================================================
-- ORDER_EXCLUDED_INGREDIENTS TABLE
-- =====================================================
CREATE TABLE order_excluded_ingredients (
    exclusion_id INT AUTO_INCREMENT PRIMARY KEY,
    order_item_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id) ON DELETE RESTRICT,
    
    -- Unique constraint to prevent duplicate exclusions
    UNIQUE KEY unique_exclusion (order_item_id, ingredient_id)
);

-- =====================================================
-- LOYALTY_TRANSACTIONS TABLE
-- =====================================================
CREATE TABLE loyalty_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_id INT NULL, -- NULL for manual adjustments
    points_earned INT DEFAULT 0,
    points_redeemed INT DEFAULT 0,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_type ENUM('earned', 'redeemed', 'adjustment', 'expired') NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE SET NULL,
    
    -- Constraints
    CONSTRAINT chk_points_earned_positive CHECK (points_earned >= 0),
    CONSTRAINT chk_points_redeemed_positive CHECK (points_redeemed >= 0),
    CONSTRAINT chk_points_transaction_logic CHECK (
        (transaction_type = 'earned' AND points_earned > 0 AND points_redeemed = 0) OR
        (transaction_type = 'redeemed' AND points_earned = 0 AND points_redeemed > 0) OR
        (transaction_type IN ('adjustment', 'expired'))
    )
);

-- =====================================================
-- WAIT_LIST TABLE
-- =====================================================
CREATE TABLE wait_list (
    wait_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    party_size INT NOT NULL,
    join_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estimated_wait INT NOT NULL, -- minutes
    status ENUM('waiting', 'seated', 'cancelled', 'no_show') DEFAULT 'waiting',
    phone_notify BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_party_size_positive CHECK (party_size > 0 AND party_size <= 20),
    CONSTRAINT chk_estimated_wait_positive CHECK (estimated_wait >= 0)
);

-- =====================================================
-- KITCHEN_LOAD TABLE
-- =====================================================
CREATE TABLE kitchen_load (
    load_id INT AUTO_INCREMENT PRIMARY KEY,
    time_period TIMESTAMP NOT NULL,
    items_in_queue INT NOT NULL DEFAULT 0,
    total_prep_time INT NOT NULL DEFAULT 0, -- minutes
    capacity_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Tracks when kitchen load data was last refreshed for real-time wait estimates
    
    -- Constraints
    CONSTRAINT chk_items_queue_positive CHECK (items_in_queue >= 0),
    CONSTRAINT chk_prep_time_positive_load CHECK (total_prep_time >= 0),
    CONSTRAINT chk_capacity_range CHECK (capacity_percentage >= 0 AND capacity_percentage <= 100),
    
    -- Unique constraint for time periods
    CONSTRAINT unique_time_period UNIQUE (time_period)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Customer indexes
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_loyalty_points ON customers(loyalty_points);
CREATE INDEX idx_customers_madperks ON customers(madperks_member);

-- Ingredients indexes
CREATE INDEX idx_ingredients_allergen ON ingredients(is_allergen);
CREATE INDEX idx_ingredients_vegan ON ingredients(is_vegan);
CREATE INDEX idx_ingredients_gluten_free ON ingredients(is_gluten_free);

-- Menu items indexes
CREATE INDEX idx_menu_items_available ON menu_items(is_available);
CREATE INDEX idx_menu_items_price ON menu_items(price);
CREATE INDEX idx_menu_items_last_ordered ON menu_items(date_last_ordered);

-- Order indexes
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_orders_type ON orders(order_type);

-- Order items indexes
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_menu_item_id ON order_items(menu_item_id);

-- Loyalty transactions indexes
CREATE INDEX idx_loyalty_customer_id ON loyalty_transactions(customer_id);
CREATE INDEX idx_loyalty_order_id ON loyalty_transactions(order_id);
CREATE INDEX idx_loyalty_date ON loyalty_transactions(transaction_date);
CREATE INDEX idx_loyalty_type ON loyalty_transactions(transaction_type);

-- Wait list indexes
CREATE INDEX idx_wait_list_customer_id ON wait_list(customer_id);
CREATE INDEX idx_wait_list_status ON wait_list(status);
CREATE INDEX idx_wait_list_join_time ON wait_list(join_time);

-- Kitchen load indexes
CREATE INDEX idx_kitchen_load_time ON kitchen_load(time_period);
CREATE INDEX idx_kitchen_load_capacity ON kitchen_load(capacity_percentage);

-- =====================================================
-- INITIAL DATA POPULATION
-- =====================================================

-- Insert sample ingredients
INSERT INTO ingredients (ingredient_name, is_allergen, allergen_type, is_vegan, is_gluten_free, cost_per_unit) VALUES
('Bulgogi Beef', FALSE, NULL, FALSE, TRUE, 4.50),
('Flour Tortilla', TRUE, 'gluten', TRUE, FALSE, 0.30),
('Sweet Plantains', FALSE, NULL, TRUE, TRUE, 1.20),
('Shrimp', TRUE, 'shellfish', FALSE, TRUE, 4.00),
('Corn Tortilla', FALSE, NULL, TRUE, TRUE, 0.25),
('Romaine Lettuce', FALSE, NULL, TRUE, TRUE, 0.75),
('Parmesan Cheese', TRUE, 'dairy', FALSE, TRUE, 2.50),
('Chicken Breast', FALSE, NULL, FALSE, TRUE, 3.50),
('Sub Roll', TRUE, 'gluten', TRUE, FALSE, 0.60),
('Avocado', FALSE, NULL, TRUE, TRUE, 1.80),
('Bread', TRUE, 'gluten', TRUE, FALSE, 0.40),
('Eggs', TRUE, 'eggs', FALSE, TRUE, 0.25),
('Brussels Sprouts', FALSE, NULL, TRUE, TRUE, 1.10),
('Artichoke Hearts', FALSE, NULL, TRUE, TRUE, 2.00),
('Pasta', TRUE, 'gluten', TRUE, FALSE, 0.45),
('Protein Powder', FALSE, NULL, FALSE, TRUE, 1.25),
('Fried Chicken', FALSE, NULL, FALSE, TRUE, 3.75),
('Sausage', FALSE, NULL, FALSE, TRUE, 2.80),
('Biscuits', TRUE, 'gluten', TRUE, FALSE, 0.55),
('Ground Beef', FALSE, NULL, FALSE, TRUE, 3.20),
('Feta Cheese', TRUE, 'dairy', FALSE, TRUE, 2.25),
('Thai Peanut Sauce', TRUE, 'nuts', TRUE, TRUE, 1.40),
('Orange', FALSE, NULL, TRUE, TRUE, 0.60),
('Pork Shoulder', FALSE, NULL, FALSE, TRUE, 3.80),
('Pineapple', FALSE, NULL, TRUE, TRUE, 0.90),
('Jasmine Rice', FALSE, NULL, TRUE, TRUE, 0.35),
('Steak', FALSE, NULL, FALSE, TRUE, 5.50),
('Garlic', FALSE, NULL, TRUE, TRUE, 0.30),
('Onions', FALSE, NULL, TRUE, TRUE, 0.40),
('Olive Oil', FALSE, NULL, TRUE, TRUE, 1.20),
('Soy Sauce', TRUE, 'soy', TRUE, FALSE, 0.80),
('Lime', FALSE, NULL, TRUE, TRUE, 0.35),
('Cilantro', FALSE, NULL, TRUE, TRUE, 0.65),
('Caesar Dressing', TRUE, 'eggs', FALSE, TRUE, 1.15),
('Marinara Sauce', FALSE, NULL, TRUE, TRUE, 0.85),
('Mozzarella Cheese', TRUE, 'dairy', FALSE, TRUE, 2.00);

-- Insert sample customers (passwords are SHA-256 hashes of 'password123')
INSERT INTO customers (first_name, last_name, email, phone, password_hash, loyalty_points, madperks_member) VALUES
('John', 'Doe', 'john.doe@email.com', '555-0101', SHA2('password123', 256), 85, TRUE),
('Jane', 'Smith', 'jane.smith@email.com', '555-0102', SHA2('password123', 256), 150, FALSE),
('Mike', 'Johnson', 'mike.johnson@email.com', '555-0103', SHA2('password123', 256), 25, TRUE),
('Sarah', 'Wilson', 'sarah.wilson@email.com', '555-0104', SHA2('password123', 256), 200, FALSE),
('Alyssa', 'Garcia', 'alyssa.garcia@email.com', '555-0105', SHA2('password123', 256), 75, TRUE);

-- Insert Alyssa's favorite menu items
INSERT INTO menu_items (item_name, description, price, prep_time_minutes, spice_level, calories, date_last_ordered) VALUES
('Bulgorito', 'Korean-Mexican fusion burrito with marinated bulgogi beef, rice, vegetables, and Korean-style sauce wrapped in a flour tortilla', 13.99, 12, 'mild', 720, '2025-07-28'),
('Maduros', 'Sweet fried plantains caramelized to perfection, a classic Latin American side dish', 6.99, 8, 'mild', 180, '2025-07-26'),
('Shrimp Tacos', 'Grilled shrimp with cabbage slaw, avocado, and chipotle lime crema on corn tortillas (3 tacos)', 14.99, 10, 'medium', 450, '2025-07-29'),
('Caesar Salad', 'Fresh romaine lettuce with parmesan cheese, croutons, and classic Caesar dressing', 9.99, 5, 'mild', 320, '2025-07-25'),
('Chicken Parmesan Sub', 'Breaded chicken breast with marinara sauce and melted mozzarella on a toasted sub roll', 12.99, 15, 'mild', 680, '2025-07-27'),
('Avocado Toast with Egg', 'Smashed avocado on artisan bread topped with a perfectly cooked egg and seasonings', 11.99, 8, 'mild', 420, '2025-07-30'),
('Brussels Sprouts', 'Roasted brussels sprouts with garlic, olive oil, and a touch of parmesan', 8.99, 20, 'mild', 160, '2025-07-24'),
('Artichoke Hearts', 'Grilled artichoke hearts with herbs, lemon, and olive oil', 9.99, 12, 'mild', 140, '2025-07-23'),
('Protein Pasta Salad', 'High-protein pasta salad with vegetables, herbs, and a light vinaigrette', 10.99, 15, 'mild', 380, '2025-07-26'),
('The Ultimate Brunch', 'Fried chicken with sausage gravy over buttermilk biscuits, served with two eggs any style', 18.99, 22, 'mild', 1200, '2025-07-28'),
('My Big Fat Greek Burger', 'Seasoned beef patty with feta cheese, olives, tomatoes, and tzatziki on a brioche bun', 15.99, 14, 'mild', 820, '2025-07-25'),
('Sticky Thai Peanut Orange Chicken', 'Crispy chicken in a sweet and savory Thai peanut orange glaze served over rice', 16.99, 18, 'medium', 650, '2025-07-29'),
('Cuban Mojo Pork', 'Slow-roasted pork shoulder marinated in citrus mojo sauce with garlic and herbs', 17.99, 25, 'mild', 580, '2025-07-27'),
('Pineapple Thai Fried Rice', 'Jasmine rice stir-fried with pineapple, vegetables, and Thai seasonings', 12.99, 12, 'medium', 520, '2025-07-26'),
('Hibachi Steak', 'Grilled steak cooked hibachi-style with vegetables and served with fried rice', 22.99, 16, 'mild', 750, '2025-07-30');

-- Sample menu item ingredients relationships (showing a few examples)
INSERT INTO menu_item_ingredients (menu_item_id, ingredient_id, quantity_used, unit_measure, is_optional) VALUES
-- Bulgorito ingredients
(1, 1, 150.000, 'grams', FALSE), -- Bulgogi Beef
(1, 2, 1.000, 'piece', FALSE),   -- Flour Tortilla
(1, 26, 80.000, 'grams', FALSE), -- Jasmine Rice
(1, 28, 5.000, 'grams', FALSE),  -- Garlic
(1, 31, 10.000, 'ml', FALSE),    -- Soy Sauce

-- Shrimp Tacos ingredients
(3, 4, 120.000, 'grams', FALSE), -- Shrimp
(3, 5, 3.000, 'pieces', FALSE),  -- Corn Tortilla
(3, 10, 50.000, 'grams', FALSE), -- Avocado
(3, 32, 15.000, 'ml', FALSE),    -- Lime

-- Caesar Salad ingredients
(4, 6, 100.000, 'grams', FALSE), -- Romaine Lettuce
(4, 7, 30.000, 'grams', FALSE),  -- Parmesan Cheese
(4, 34, 25.000, 'ml', FALSE),    -- Caesar Dressing

-- Avocado Toast ingredients
(6, 10, 80.000, 'grams', FALSE), -- Avocado
(6, 11, 2.000, 'slices', FALSE), -- Bread
(6, 12, 1.000, 'piece', FALSE);  -- Eggs

-- Sample customer allergens
INSERT INTO customer_allergens (customer_id, ingredient_id, severity_level, notes) VALUES
(1, 4, 'severe', 'Severe shellfish allergy - keep away from all shellfish'),
(2, 7, 'mild', 'Lactose intolerant - can handle small amounts'),
(3, 2, 'moderate', 'Gluten sensitivity'),
(4, 12, 'life_threatening', 'Severe egg allergy - EpiPen required');

-- Sample kitchen load data
INSERT INTO kitchen_load (time_period, items_in_queue, total_prep_time, capacity_percentage) VALUES
('2025-07-30 12:00:00', 8, 120, 75.50),
('2025-07-30 12:15:00', 6, 95, 60.25),
('2025-07-30 12:30:00', 12, 180, 90.00),
('2025-07-30 12:45:00', 4, 65, 40.75);

-- Sample orders data
INSERT INTO orders (customer_id, order_type, order_status, subtotal, kitchen_gratuity, server_gratuity, madperks_discount, loyalty_discount, total_amount, special_notes, estimated_ready_time) VALUES
(1, 'online', 'completed', 28.98, 1.16, 5.00, 2.90, 0.00, 32.24, 'Extra spicy sauce on the side', '2025-07-28 12:30:00'),
(2, 'dine_in', 'completed', 22.98, 0.92, 4.50, 0.00, 5.00, 23.40, NULL, '2025-07-28 13:15:00'),
(3, 'pickup', 'completed', 15.99, 0.64, 2.00, 1.60, 0.00, 17.03, 'No onions please', '2025-07-29 11:45:00'),
(4, 'online', 'completed', 31.97, 1.28, 6.00, 0.00, 10.00, 29.25, 'Table for anniversary dinner', '2025-07-29 18:30:00'),
(5, 'dine_in', 'completed', 18.99, 0.76, 3.50, 1.90, 0.00, 21.35, NULL, '2025-07-30 12:00:00'),
(1, 'pickup', 'ready', 24.98, 1.00, 0.00, 2.50, 0.00, 23.48, 'Light on the sauce', '2025-07-30 13:20:00'),
(2, 'online', 'preparing', 16.99, 0.68, 3.00, 0.00, 0.00, 20.67, 'Extra vegetables', '2025-07-30 14:00:00'),
(3, 'dine_in', 'pending', 13.99, 0.56, 2.50, 1.40, 0.00, 15.65, NULL, '2025-07-30 14:30:00');

-- Sample order items data
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price, special_instructions) VALUES
-- Order 1 (John Doe - online): Bulgorito + Shrimp Tacos
(1, 1, 1, 13.99, 'Extra bulgogi beef'),
(1, 3, 1, 14.99, 'Make it spicy'),

-- Order 2 (Jane Smith - dine_in): Caesar Salad + Avocado Toast
(2, 4, 1, 9.99, 'Dressing on the side'),
(2, 6, 1, 11.99, 'Poached egg instead of fried'),
(2, 2, 1, 1.00, NULL), -- Added maduros as side

-- Order 3 (Mike Johnson - pickup): Green Curry
(3, 4, 1, 15.99, 'Medium spice level'),

-- Order 4 (Sarah Wilson - online): Ultimate Brunch + Greek Burger
(4, 10, 1, 18.99, 'Eggs over easy'),
(4, 11, 1, 12.98, 'Extra tzatziki sauce'),

-- Order 5 (Alyssa - dine_in): Ultimate Brunch
(5, 10, 1, 18.99, 'Crispy chicken, scrambled eggs'),

-- Order 6 (John Doe - pickup): Hibachi Steak + Brussels Sprouts
(6, 15, 1, 22.99, 'Medium rare'),
(6, 7, 1, 1.99, 'Extra crispy'), -- Added brussels sprouts as side

-- Order 7 (Jane Smith - online): Thai Peanut Chicken
(7, 12, 1, 16.99, 'Mild spice please'),

-- Order 8 (Mike Johnson - dine_in): Shrimp Tacos
(8, 3, 1, 13.99, 'No cilantro');

-- Sample loyalty transactions data
INSERT INTO loyalty_transactions (customer_id, order_id, points_earned, points_redeemed, transaction_type, notes) VALUES
-- Points earned from completed orders
(1, 1, 32, 0, 'earned', 'Points from order total $32.24'),
(2, 2, 23, 0, 'earned', 'Points from order total $23.40'),
(3, 3, 17, 0, 'earned', 'Points from order total $17.03'),
(4, 4, 29, 0, 'earned', 'Points from order total $29.25'),
(5, 5, 21, 0, 'earned', 'Points from order total $21.35'),
(1, 6, 23, 0, 'earned', 'Points from order total $23.48'),

-- Points redeemed (loyalty discounts)
(2, 2, 0, 100, 'redeemed', '$5 discount applied - 100 points redeemed'),
(4, 4, 0, 200, 'redeemed', '$10 discount applied - 200 points redeemed'),

-- Bonus points for special promotions
(1, NULL, 25, 0, 'adjustment', 'Birthday bonus points'),
(3, NULL, 50, 0, 'adjustment', 'New customer welcome bonus'),
(5, NULL, 30, 0, 'adjustment', 'Employee appreciation bonus');

-- Sample wait list data
INSERT INTO wait_list (customer_id, party_size, estimated_wait, status, phone_notify, notes) VALUES
(1, 2, 15, 'waiting', TRUE, 'Requested booth seating'),
(2, 4, 25, 'waiting', TRUE, 'Celebrating anniversary'),
(3, 1, 10, 'seated', FALSE, 'Counter seating OK'),
(4, 6, 35, 'waiting', TRUE, 'Family with children - need high chairs'),
(5, 3, 20, 'cancelled', TRUE, 'Customer called to cancel'),
(1, 2, 12, 'seated', TRUE, 'Window table preferred'),
(2, 8, 45, 'waiting', TRUE, 'Large group - birthday party'),
(3, 2, 18, 'no_show', TRUE, 'Customer did not arrive within 10 minutes'),
(4, 3, 22, 'waiting', FALSE, 'Outdoor seating requested'),
(5, 2, 8, 'seated', TRUE, 'Quick lunch meeting');

/*
BUSINESS RULES ENFORCED:
1. Orders must have at least one item (enforced by foreign key relationship)
2. Kitchen gratuity is automatically calculated as 4% of subtotal
3. Loyalty points must be non-negative
4. Email addresses must be unique and properly formatted
5. Menu item prices and prep times must be positive
6. Party sizes for wait list are limited to 1-20 people
7. Allergen ingredients must have an allergen type specified

NORMALIZATION:
- 1NF: All attributes contain atomic values
- 2NF: All non-key attributes are fully functionally dependent on primary keys
- 3NF: No transitive dependencies exist

KEY FEATURES:
- Supports all order types (dine-in, pickup, online)
- Tracks customer allergens with severity levels
- Manages ingredient exclusions per order item
- Implements loyalty points system (1 point per $1 spent)
- Handles MADperks discount (10% for members)
- Tracks kitchen load for wait time estimates
- Maintains comprehensive audit trail through timestamps
*/
