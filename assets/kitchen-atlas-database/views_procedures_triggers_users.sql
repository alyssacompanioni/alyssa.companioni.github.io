-- =====================================================
-- Alyssa's Kitchen Atlas - Complete Database Implementation
-- DBA210 Final Project 
-- This document contains Views, Stored Procedures, Triggers, Test Queries, User Accounts, 
--  Sample Transactions, Data Validation Queries, and Performance Monitoring Queries
-- =====================================================

USE alyssas_kitchen_atlas;

-- =====================================================
-- VIEWS SECTION
-- =====================================================

-- View 1: Popular Dishes (shows order frequency and recent activity)
CREATE VIEW popular_dishes_view AS
SELECT 
    mi.menu_item_id,
    mi.item_name,
    mi.price,
    mi.prep_time_minutes,
    mi.spice_level,
    mi.calories,
    mi.date_last_ordered,
    COALESCE(COUNT(oi.order_item_id), 0) as total_orders,
    COALESCE(SUM(oi.quantity), 0) as total_quantity_sold,
    COALESCE(AVG(oi.item_price), mi.price) as avg_selling_price,
    COALESCE(SUM(oi.quantity * oi.item_price), 0) as total_revenue,
    CASE 
        WHEN mi.date_last_ordered >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) THEN 'Hot'
        WHEN mi.date_last_ordered >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN 'Popular'
        WHEN mi.date_last_ordered >= DATE_SUB(CURDATE(), INTERVAL 90 DAY) THEN 'Moderate'
        ELSE 'Cold'
    END as popularity_status,
    mi.is_available
FROM menu_items mi
LEFT JOIN order_items oi ON mi.menu_item_id = oi.menu_item_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.order_status != 'cancelled'
GROUP BY mi.menu_item_id, mi.item_name, mi.price, mi.prep_time_minutes, 
         mi.spice_level, mi.calories, mi.date_last_ordered, mi.is_available
ORDER BY total_quantity_sold DESC, mi.date_last_ordered DESC;

-- View 2: Customer Order History Summary
CREATE VIEW customer_order_history_view AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.email,
    c.phone,
    c.loyalty_points,
    c.madperks_member,
    c.is_active,
    COALESCE(COUNT(DISTINCT o.order_id), 0) as total_orders,
    COALESCE(SUM(o.total_amount), 0.00) as total_spent,
    COALESCE(AVG(o.total_amount), 0.00) as avg_order_value,
    COALESCE(MAX(o.created_at), c.created_at) as last_order_date,
    COALESCE(SUM(o.server_gratuity), 0.00) as total_tips_given,
    COALESCE(SUM(CASE WHEN o.madperks_discount > 0 THEN 1 ELSE 0 END), 0) as madperks_uses,
    COALESCE(SUM(CASE WHEN o.loyalty_discount > 0 THEN 1 ELSE 0 END), 0) as loyalty_redemptions,
    CASE 
        WHEN COUNT(DISTINCT o.order_id) >= 20 THEN 'VIP'
        WHEN COUNT(DISTINCT o.order_id) >= 10 THEN 'Frequent'
        WHEN COUNT(DISTINCT o.order_id) >= 5 THEN 'Regular'
        WHEN COUNT(DISTINCT o.order_id) >= 1 THEN 'Occasional'
        ELSE 'New'
    END as customer_tier
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status != 'cancelled'
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.phone, 
         c.loyalty_points, c.madperks_member, c.is_active, c.created_at
ORDER BY total_spent DESC, total_orders DESC;

-- View 3: Kitchen Performance Dashboard
CREATE VIEW kitchen_performance_view AS
SELECT 
    DATE(o.created_at) as order_date,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(oi.order_item_id) as total_items,
    AVG(mi.prep_time_minutes) as avg_prep_time,
    SUM(mi.prep_time_minutes * oi.quantity) as total_kitchen_minutes,
    COUNT(CASE WHEN o.order_status = 'completed' THEN 1 END) as completed_orders,
    COUNT(CASE WHEN o.order_status = 'cancelled' THEN 1 END) as cancelled_orders,
    ROUND((COUNT(CASE WHEN o.order_status = 'completed' THEN 1 END) * 100.0 / COUNT(*)), 2) as completion_rate,
    AVG(o.total_amount) as avg_order_value,
    SUM(o.total_amount) as daily_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id
WHERE o.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(o.created_at)
ORDER BY order_date DESC;

-- =====================================================
-- STORED PROCEDURES SECTION
-- =====================================================

-- Stored Procedure 1: Calculate Estimated Wait Time for Order
DELIMITER //
CREATE PROCEDURE CalculateEstimatedWaitTime(
    IN p_customer_id INT,
    IN p_order_items JSON, -- Format: [{"menu_item_id": 1, "quantity": 2}, ...]
    OUT p_estimated_minutes INT,
    OUT p_estimated_ready_time TIMESTAMP
)
BEGIN
    DECLARE v_total_prep_time INT DEFAULT 0;
    DECLARE v_current_kitchen_load INT DEFAULT 0;
    DECLARE v_kitchen_capacity_factor DECIMAL(3,2) DEFAULT 1.0;
    DECLARE v_order_complexity_factor DECIMAL(3,2) DEFAULT 1.0;
    DECLARE v_item_count INT DEFAULT 0;
    
    -- Calculate total prep time for the order
    SELECT 
        SUM(mi.prep_time_minutes * JSON_UNQUOTE(JSON_EXTRACT(p_order_items, CONCAT('$[', idx, '].quantity'))))
    INTO v_total_prep_time
    FROM menu_items mi
    JOIN JSON_TABLE(
        p_order_items,
        '$[*]' COLUMNS(
            idx FOR ORDINALITY,
            menu_item_id INT PATH '$.menu_item_id',
            quantity INT PATH '$.quantity'
        )
    ) jt ON mi.menu_item_id = jt.menu_item_id;
    
    -- Get current kitchen load
    SELECT COALESCE(AVG(capacity_percentage), 50) / 100
    INTO v_kitchen_capacity_factor
    FROM kitchen_load
    WHERE time_period >= DATE_SUB(NOW(), INTERVAL 30 MINUTE);
    
    -- Count items for complexity factor
    SELECT JSON_LENGTH(p_order_items) INTO v_item_count;
    
    -- Apply complexity factor (more items = slightly longer per item)
    SET v_order_complexity_factor = 1 + (v_item_count * 0.05);
    
    -- Calculate final estimated time
    SET p_estimated_minutes = CEILING(v_total_prep_time * v_kitchen_capacity_factor * v_order_complexity_factor);
    
    -- Ensure minimum of 5 minutes
    IF p_estimated_minutes < 5 THEN
        SET p_estimated_minutes = 5;
    END IF;
    
    -- Calculate ready time
    SET p_estimated_ready_time = DATE_ADD(NOW(), INTERVAL p_estimated_minutes MINUTE);
END //
DELIMITER ;

-- Stored Procedure 2: Apply Loyalty Discount
DELIMITER //
CREATE PROCEDURE ApplyLoyaltyDiscount(
    IN p_customer_id INT,
    IN p_order_subtotal DECIMAL(10,2),
    OUT p_discount_amount DECIMAL(10,2),
    OUT p_points_to_redeem INT
)
BEGIN
    DECLARE v_available_points INT DEFAULT 0;
    DECLARE v_max_discounts INT DEFAULT 0;
    
    -- Get customer's current loyalty points
    SELECT loyalty_points INTO v_available_points
    FROM customers
    WHERE customer_id = p_customer_id;
    
    -- Calculate maximum $5 discounts available (100 points = $5)
    SET v_max_discounts = FLOOR(v_available_points / 100);
    
    -- Limit discount to 25% of order subtotal
    WHILE (v_max_discounts * 5) > (p_order_subtotal * 0.25) AND v_max_discounts > 0 DO
        SET v_max_discounts = v_max_discounts - 1;
    END WHILE;
    
    -- Set output values
    SET p_discount_amount = v_max_discounts * 5.00;
    SET p_points_to_redeem = v_max_discounts * 100;
END //
DELIMITER ;

-- Stored Procedure 3: Process Complete Order
DELIMITER //
CREATE PROCEDURE ProcessCompleteOrder(
    IN p_customer_id INT,
    IN p_order_type ENUM('dine_in', 'pickup', 'online'),
    IN p_order_items JSON,
    IN p_server_gratuity DECIMAL(10,2),
    IN p_special_notes TEXT,
    IN p_use_madperks BOOLEAN,
    IN p_use_loyalty_points BOOLEAN,
    OUT p_order_id INT,
    OUT p_total_amount DECIMAL(10,2),
    OUT p_estimated_ready_time TIMESTAMP
)
BEGIN
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_kitchen_gratuity DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_madperks_discount DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_loyalty_discount DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_points_to_redeem INT DEFAULT 0;
    DECLARE v_estimated_minutes INT DEFAULT 0;
    DECLARE v_is_madperks_member BOOLEAN DEFAULT FALSE;
    DECLARE v_points_earned INT DEFAULT 0;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Calculate subtotal
    SELECT 
        SUM(mi.price * JSON_UNQUOTE(JSON_EXTRACT(p_order_items, CONCAT('$[', idx, '].quantity'))))
    INTO v_subtotal
    FROM menu_items mi
    JOIN JSON_TABLE(
        p_order_items,
        '$[*]' COLUMNS(
            idx FOR ORDINALITY,
            menu_item_id INT PATH '$.menu_item_id',
            quantity INT PATH '$.quantity'
        )
    ) jt ON mi.menu_item_id = jt.menu_item_id;
    
    -- Calculate kitchen gratuity (4%)
    SET v_kitchen_gratuity = ROUND(v_subtotal * 0.04, 2);
    
    -- Check for MADperks membership and apply discount
    SELECT madperks_member INTO v_is_madperks_member
    FROM customers WHERE customer_id = p_customer_id;
    
    IF p_use_madperks AND v_is_madperks_member THEN
        SET v_madperks_discount = ROUND(v_subtotal * 0.10, 2);
    END IF;
    
    -- Apply loyalty discount if requested
    IF p_use_loyalty_points THEN
        CALL ApplyLoyaltyDiscount(p_customer_id, v_subtotal, v_loyalty_discount, v_points_to_redeem);
    END IF;
    
    -- Calculate final total
    SET p_total_amount = v_subtotal + v_kitchen_gratuity + p_server_gratuity - v_madperks_discount - v_loyalty_discount;
    
    -- Calculate estimated wait time
    CALL CalculateEstimatedWaitTime(p_customer_id, p_order_items, v_estimated_minutes, p_estimated_ready_time);
    
    -- Create the order
    INSERT INTO orders (
        customer_id, order_type, subtotal, kitchen_gratuity, server_gratuity,
        madperks_discount, loyalty_discount, total_amount, special_notes, estimated_ready_time
    ) VALUES (
        p_customer_id, p_order_type, v_subtotal, v_kitchen_gratuity, p_server_gratuity,
        v_madperks_discount, v_loyalty_discount, p_total_amount, p_special_notes, p_estimated_ready_time
    );
    
    SET p_order_id = LAST_INSERT_ID();
    
    -- Insert order items
    INSERT INTO order_items (order_id, menu_item_id, quantity, item_price)
    SELECT 
        p_order_id,
        jt.menu_item_id,
        jt.quantity,
        mi.price
    FROM JSON_TABLE(
        p_order_items,
        '$[*]' COLUMNS(
            menu_item_id INT PATH '$.menu_item_id',
            quantity INT PATH '$.quantity'
        )
    ) jt
    JOIN menu_items mi ON jt.menu_item_id = mi.menu_item_id;
    
    -- Update date_last_ordered for menu items
    UPDATE menu_items 
    SET date_last_ordered = CURDATE()
    WHERE menu_item_id IN (
        SELECT DISTINCT JSON_UNQUOTE(JSON_EXTRACT(p_order_items, CONCAT('$[', idx, '].menu_item_id')))
        FROM JSON_TABLE(
            p_order_items,
            '$[*]' COLUMNS(idx FOR ORDINALITY)
        ) jt
    );
    
    -- Process loyalty points
    IF v_points_to_redeem > 0 THEN
        -- Redeem points
        UPDATE customers 
        SET loyalty_points = loyalty_points - v_points_to_redeem
        WHERE customer_id = p_customer_id;
        
        INSERT INTO loyalty_transactions (customer_id, order_id, points_redeemed, transaction_type)
        VALUES (p_customer_id, p_order_id, v_points_to_redeem, 'redeemed');
    END IF;
    
    -- Award new loyalty points (1 point per dollar spent)
    SET v_points_earned = FLOOR(p_total_amount);
    
    UPDATE customers 
    SET loyalty_points = loyalty_points + v_points_earned
    WHERE customer_id = p_customer_id;
    
    INSERT INTO loyalty_transactions (customer_id, order_id, points_earned, transaction_type)
    VALUES (p_customer_id, p_order_id, v_points_earned, 'earned');
    
    COMMIT;
END //
DELIMITER ;

-- Stored Procedure 4: Update Menu Item Availability
DELIMITER //
CREATE PROCEDURE UpdateMenuItemAvailability(
    IN p_menu_item_id INT,
    IN p_is_available BOOLEAN,
    IN p_reason TEXT
)
BEGIN
    DECLARE v_item_name VARCHAR(100);
    
    -- Get item name for logging
    SELECT item_name INTO v_item_name
    FROM menu_items
    WHERE menu_item_id = p_menu_item_id;
    
    -- Update availability
    UPDATE menu_items 
    SET is_available = p_is_available,
        updated_at = CURRENT_TIMESTAMP
    WHERE menu_item_id = p_menu_item_id;
    
    -- Log the change (you could create an audit table for this)
    SELECT CONCAT('Menu item "', v_item_name, '" availability changed to ', 
                  CASE WHEN p_is_available THEN 'AVAILABLE' ELSE 'UNAVAILABLE' END,
                  '. Reason: ', COALESCE(p_reason, 'Not specified')) as change_log;
END //
DELIMITER ;

-- =====================================================
-- TRIGGERS SECTION
-- =====================================================

-- Trigger 1: Auto-update kitchen load when orders are placed
DELIMITER //
CREATE TRIGGER update_kitchen_load_after_order
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE v_total_prep_time INT DEFAULT 0;
    DECLARE v_item_count INT DEFAULT 0;
    DECLARE v_current_period TIMESTAMP;
    
    -- Round to nearest 15-minute period
    SET v_current_period = DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:00');
    SET v_current_period = DATE_ADD(v_current_period, 
        INTERVAL (FLOOR(MINUTE(NOW()) / 15) * 15 - MINUTE(NOW())) MINUTE);
    
    -- Get prep time for this order
    SELECT 
        COALESCE(SUM(mi.prep_time_minutes * oi.quantity), 0),
        COUNT(oi.order_item_id)
    INTO v_total_prep_time, v_item_count
    FROM order_items oi
    JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id
    WHERE oi.order_id = NEW.order_id;

    -- Ensure we have valid values
    SET v_total_prep_time = COALESCE(v_total_prep_time, 0);
    SET v_item_count = COALESCE(v_item_count, 0);
    
    -- Only update kitchen load if we have items
    IF v_item_count > 0 THEN
        -- Update or insert kitchen load
        INSERT INTO kitchen_load (time_period, items_in_queue, total_prep_time, capacity_percentage)
        VALUES (v_current_period, v_item_count, v_total_prep_time, 
                LEAST(100, (v_total_prep_time / 15) * 100))
        ON DUPLICATE KEY UPDATE
            items_in_queue = items_in_queue + v_item_count,
            total_prep_time = total_prep_time + v_total_prep_time,
            capacity_percentage = LEAST(100, (total_prep_time / 15) * 100);
    END IF;
END //
DELIMITER ;

-- =====================================================
-- TEST QUERIES SECTION
-- =====================================================

-- Test Query 1: Retrieve all available menu items with their popularity
-- This query shows the current menu with popularity metrics
SELECT 
    item_name,
    price,
    prep_time_minutes,
    spice_level,
    popularity_status,
    total_quantity_sold,
    total_revenue
FROM popular_dishes_view
WHERE is_available = TRUE
ORDER BY total_quantity_sold DESC;

-- +-----------------------------------+-------+-------------------+-------------+-------------------+---------------------+---------------+
-- | item_name                         | price | prep_time_minutes | spice_level | popularity_status | total_quantity_sold | total_revenue |
-- +-----------------------------------+-------+-------------------+-------------+-------------------+---------------------+---------------+
-- | Shrimp Tacos                      | 14.99 |                10 | medium      | Hot               |                   2 |         28.98 |
-- | The Ultimate Brunch               | 18.99 |                22 | mild        | Hot               |                   2 |         37.98 |
-- | Caesar Salad                      |  9.99 |                 5 | mild        | Hot               |                   2 |         25.98 |
-- | Avocado Toast with Egg            | 11.99 |                 8 | mild        | Hot               |                   1 |         11.99 |
-- | Hibachi Steak                     | 22.99 |                16 | mild        | Hot               |                   1 |         22.99 |
-- | Sticky Thai Peanut Orange Chicken | 16.99 |                18 | medium      | Hot               |                   1 |         16.99 |
-- | Bulgorito                         | 13.99 |                12 | mild        | Hot               |                   1 |         13.99 |
-- | Maduros                           |  6.99 |                 8 | mild        | Hot               |                   1 |          1.00 |
-- | My Big Fat Greek Burger           | 15.99 |                14 | mild        | Hot               |                   1 |         12.98 |
-- | Brussels Sprouts                  |  8.99 |                20 | mild        | Hot               |                   1 |          1.99 |
-- | Chicken Parmesan Sub              | 12.99 |                15 | mild        | Hot               |                   0 |          0.00 |
-- | Cuban Mojo Pork                   | 17.99 |                25 | mild        | Hot               |                   0 |          0.00 |
-- | Protein Pasta Salad               | 10.99 |                15 | mild        | Hot               |                   0 |          0.00 |
-- | Pineapple Thai Fried Rice         | 12.99 |                12 | medium      | Hot               |                   0 |          0.00 |
-- | Artichoke Hearts                  |  9.99 |                12 | mild        | Popular           |                   0 |          0.00 |
-- +-----------------------------------+-------+-------------------+-------------+-------------------+---------------------+---------------+


-- Test Query 2: Find customers with high loyalty points
-- This query identifies VIP customers for targeted marketing
SELECT 
    customer_name,
    email,
    loyalty_points,
    total_spent,
    customer_tier,
    madperks_member
FROM customer_order_history_view
WHERE loyalty_points >= 100 OR total_orders >= 10
ORDER BY loyalty_points DESC;

-- +---------------+------------------------+----------------+-------------+---------------+-----------------+
-- | customer_name | email                  | loyalty_points | total_spent | customer_tier | madperks_member |
-- +---------------+------------------------+----------------+-------------+---------------+-----------------+
-- | Sarah Wilson  | sarah.wilson@email.com |            200 |       29.25 | Occasional    |               0 |
-- | Jane Smith    | jane.smith@email.com   |            150 |       44.07 | Occasional    |               0 |
-- +---------------+------------------------+----------------+-------------+---------------+-----------------+

-- Test Query 3: Check for potential allergen conflicts for a customer
-- This query helps prevent serving allergens to sensitive customers
SELECT DISTINCT
    c.first_name,
    c.last_name,
    i.ingredient_name,
    ca.severity_level,
    ca.notes,
    mi.item_name
FROM customers c
JOIN customer_allergens ca ON c.customer_id = ca.customer_id
JOIN ingredients i ON ca.ingredient_id = i.ingredient_id
JOIN menu_item_ingredients mii ON i.ingredient_id = mii.ingredient_id
JOIN menu_items mi ON mii.menu_item_id = mi.menu_item_id
WHERE c.customer_id = 1 -- John Doe has severe shellfish allergy
ORDER BY ca.severity_level DESC;

-- +------------+-----------+-----------------+----------------+---------------------------------------------------------+--------------+
-- | first_name | last_name | ingredient_name | severity_level | notes                                                   | item_name    |
-- +------------+-----------+-----------------+----------------+---------------------------------------------------------+--------------+
-- | John       | Doe       | Shrimp          | severe         | Severe shellfish allergy - keep away from all shellfish | Shrimp Tacos |
-- +------------+-----------+-----------------+----------------+---------------------------------------------------------+--------------+

-- Test Query 4: Daily sales report with kitchen performance
-- This query provides management dashboard information
SELECT 
    order_date,
    total_orders,
    total_items,
    ROUND(avg_prep_time, 1) as avg_prep_time_minutes,
    completion_rate,
    CONCAT('$', FORMAT(daily_revenue, 2)) as formatted_revenue
FROM kitchen_performance_view
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY order_date DESC;

-- +------------+--------------+-------------+-----------------------+-----------------+-------------------+
-- | order_date | total_orders | total_items | avg_prep_time_minutes | completion_rate | formatted_revenue |
-- +------------+--------------+-------------+-----------------------+-----------------+-------------------+
-- | 2025-07-30 |            8 |          13 |                  13.1 |           69.23 | $314.84           |
-- +------------+--------------+-------------+-----------------------+-----------------+-------------------+

-- Test Query 5: Find menu items that haven't been ordered recently
-- This query helps identify items that might need promotion or removal
SELECT 
    item_name,
    price,
    date_last_ordered,
    DATEDIFF(CURDATE(), date_last_ordered) as days_since_last_order,
    is_available
FROM menu_items
WHERE date_last_ordered < DATE_SUB(CURDATE(), INTERVAL 14 DAY)
   OR date_last_ordered IS NULL
ORDER BY date_last_ordered ASC;

-- Empty set (0.01 sec)

-- Test Query 6: Calculate potential revenue from loyalty point redemptions
-- This query shows the financial impact of the loyalty program
SELECT 
    customer_name,
    loyalty_points,
    FLOOR(loyalty_points / 100) as available_discounts,
    FLOOR(loyalty_points / 100) * 5 as potential_discount_value,
    total_spent
FROM customer_order_history_view
WHERE loyalty_points >= 100
ORDER BY potential_discount_value DESC;

-- +---------------+----------------+---------------------+--------------------------+-------------+
-- | customer_name | loyalty_points | available_discounts | potential_discount_value | total_spent |
-- +---------------+----------------+---------------------+--------------------------+-------------+
-- | Sarah Wilson  |            200 |                   2 |                       10 |       29.25 |
-- | Jane Smith    |            150 |                   1 |                        5 |       44.07 |
-- +---------------+----------------+---------------------+--------------------------+-------------+

-- =====================================================
-- USER ACCOUNT MANAGEMENT
-- =====================================================

-- Create database users with appropriate privileges

-- 1. Admin User (Full Access)
CREATE USER IF NOT EXISTS 'atlas_admin'@'%' IDENTIFIED BY 'AdminKitchen2025!';
GRANT ALL PRIVILEGES ON alyssas_kitchen_atlas.* TO 'atlas_admin'@'%';

-- 2. Manager User (Reports and Analytics)
CREATE USER IF NOT EXISTS 'atlas_manager'@'%' IDENTIFIED BY 'ManagerView2025!';
GRANT SELECT ON alyssas_kitchen_atlas.* TO 'atlas_manager'@'%';
GRANT SELECT ON alyssas_kitchen_atlas.popular_dishes_view TO 'atlas_manager'@'%';
GRANT SELECT ON alyssas_kitchen_atlas.customer_order_history_view TO 'atlas_manager'@'%';
GRANT SELECT ON alyssas_kitchen_atlas.kitchen_performance_view TO 'atlas_manager'@'%';
GRANT EXECUTE ON PROCEDURE alyssas_kitchen_atlas.CalculateEstimatedWaitTime TO 'atlas_manager'@'%';

-- 3. Kitchen Staff User (Order Management)
CREATE USER IF NOT EXISTS 'atlas_kitchen'@'%' IDENTIFIED BY 'KitchenStaff2025!';
GRANT SELECT, UPDATE ON alyssas_kitchen_atlas.orders TO 'atlas_kitchen'@'%';
GRANT SELECT ON alyssas_kitchen_atlas.order_items TO 'atlas_kitchen'@'%';
GRANT SELECT ON alyssas_kitchen_atlas.menu_items TO 'atlas_kitchen'@'%';
GRANT SELECT, INSERT, UPDATE ON alyssas_kitchen_atlas.kitchen_load TO 'atlas_kitchen'@'%';
GRANT EXECUTE ON PROCEDURE alyssas_kitchen_atlas.UpdateMenuItemAvailability TO 'atlas_kitchen'@'%';

-- 4. Customer Service User (Customer and Order Info)
CREATE USER IF NOT EXISTS 'atlas_service'@'%' IDENTIFIED BY 'ServiceDesk2025!';
GRANT SELECT ON alyssas_kitchen_atlas.customers TO 'atlas_service'@'%';
GRANT SELECT, INSERT, UPDATE ON alyssas_kitchen_atlas.orders TO 'atlas_service'@'%';
GRANT SELECT, INSERT, UPDATE ON alyssas_kitchen_atlas.order_items TO 'atlas_service'@'%';
GRANT SELECT ON alyssas_kitchen_atlas.menu_items TO 'atlas_service'@'%';
GRANT SELECT, INSERT ON alyssas_kitchen_atlas.wait_list TO 'atlas_service'@'%';
GRANT EXECUTE ON PROCEDURE alyssas_kitchen_atlas.ProcessCompleteOrder TO 'atlas_service'@'%';
GRANT EXECUTE ON PROCEDURE alyssas_kitchen_atlas.CalculateEstimatedWaitTime TO 'atlas_service'@'%';

-- 5. Application User (Limited Access for Web/Mobile App)
CREATE USER IF NOT EXISTS 'atlas_app'@'%' IDENTIFIED BY 'AppAccess2025!';
GRANT SELECT ON alyssas_kitchen_atlas.menu_items TO 'atlas_app'@'%';
GRANT SELECT ON alyssas_kitchen_atlas.customers TO 'atlas_app'@'%';
GRANT INSERT, UPDATE ON alyssas_kitchen_atlas.orders TO 'atlas_app'@'%';
GRANT INSERT ON alyssas_kitchen_atlas.order_items TO 'atlas_app'@'%';
GRANT SELECT ON alyssas_kitchen_atlas.popular_dishes_view TO 'atlas_app'@'%';

-- 6. Read-Only User for Professor Evaluation
CREATE USER IF NOT EXISTS 'atlas_readonly'@'%' IDENTIFIED BY 'Professor2025!';
GRANT SELECT ON alyssas_kitchen_atlas.* TO 'atlas_readonly'@'%';

-- Flush privileges to ensure changes take effect
FLUSH PRIVILEGES;

-- =====================================================
-- SAMPLE TRANSACTION EXAMPLES
-- =====================================================

-- Example 1: Process a complete order for John Doe
-- This demonstrates the full order process including discounts and loyalty points
CALL ProcessCompleteOrder(
    1,  -- John Doe's customer_id
    'online',  -- order_type
    '[{"menu_item_id": 1, "quantity": 1}, {"menu_item_id": 3, "quantity": 2}]',  -- Bulgorito + 2 Shrimp Tacos
    5.00,  -- server_gratuity
    'Extra spicy sauce on the side',  -- special_notes
    TRUE,  -- use_madperks (John is a member)
    FALSE,  -- don't use loyalty points this time
    @order_id,
    @total_amount,
    @ready_time
);

SELECT @order_id as new_order_id, @total_amount as order_total, @ready_time as estimated_ready;

-- +--------------+-------------+---------------------+
-- | new_order_id | order_total | estimated_ready     |
-- +--------------+-------------+---------------------+
-- |           11 |       31.30 | 2025-07-31 03:17:23 |
-- +--------------+-------------+---------------------+

-- Example 2: Check estimated wait time for a large order
CALL CalculateEstimatedWaitTime(
    2,  -- Jane Smith's customer_id
    '[{"menu_item_id": 10, "quantity": 2}, {"menu_item_id": 15, "quantity": 1}, {"menu_item_id": 4, "quantity": 3}]',  -- Ultimate Brunch x2, Hibachi Steak, Caesar Salad x3
    @wait_minutes,
    @ready_timestamp
);

SELECT @wait_minutes as estimated_wait_minutes, @ready_timestamp as estimated_ready_time;

-- +------------------------+----------------------+
-- | estimated_wait_minutes | estimated_ready_time |
-- +------------------------+----------------------+
-- |                     41 | 2025-07-31 03:45:35  |
-- +------------------------+----------------------+

-- =====================================================
-- DATA VALIDATION QUERIES
-- =====================================================

-- Verify business rules are enforced
-- 1. Check that kitchen gratuity is exactly 4%
SELECT 
    order_id,
    subtotal,
    kitchen_gratuity,
    ROUND(subtotal * 0.04, 2) as calculated_gratuity,
    CASE 
        WHEN kitchen_gratuity = ROUND(subtotal * 0.04, 2) THEN 'CORRECT'
        ELSE 'ERROR'
    END as validation_status
FROM orders
LIMIT 10;

-- +----------+----------+------------------+---------------------+-------------------+
-- | order_id | subtotal | kitchen_gratuity | calculated_gratuity | validation_status |
-- +----------+----------+------------------+---------------------+-------------------+
-- |        1 |    28.98 |             1.16 |                1.16 | CORRECT           |
-- |        2 |    22.98 |             0.92 |                0.92 | CORRECT           |
-- |        3 |    15.99 |             0.64 |                0.64 | CORRECT           |
-- |        4 |    31.97 |             1.28 |                1.28 | CORRECT           |
-- |        5 |    18.99 |             0.76 |                0.76 | CORRECT           |
-- |        6 |    24.98 |             1.00 |                1.00 | CORRECT           |
-- |        7 |    16.99 |             0.68 |                0.68 | CORRECT           |
-- |        8 |    13.99 |             0.56 |                0.56 | CORRECT           |
-- |       11 |    27.98 |             1.12 |                1.12 | CORRECT           |
-- +----------+----------+------------------+---------------------+-------------------+

-- 2. Verify total amount calculation
SELECT 
    order_id,
    subtotal + kitchen_gratuity + server_gratuity - madperks_discount - loyalty_discount as calculated_total,
    total_amount,
    CASE 
        WHEN ABS((subtotal + kitchen_gratuity + server_gratuity - madperks_discount - loyalty_discount) - total_amount) < 0.01 THEN 'CORRECT'
        ELSE 'ERROR'
    END as validation_status
FROM orders
LIMIT 10;

-- +----------+------------------+--------------+-------------------+
-- | order_id | calculated_total | total_amount | validation_status |
-- +----------+------------------+--------------+-------------------+
-- |        1 |            32.24 |        32.24 | CORRECT           |
-- |        2 |            23.40 |        23.40 | CORRECT           |
-- |        3 |            17.03 |        17.03 | CORRECT           |
-- |        4 |            29.25 |        29.25 | CORRECT           |
-- |        5 |            21.35 |        21.35 | CORRECT           |
-- |        6 |            23.48 |        23.48 | CORRECT           |
-- |        7 |            20.67 |        20.67 | CORRECT           |
-- |        8 |            15.65 |        15.65 | CORRECT           |
-- |       11 |            31.30 |        31.30 | CORRECT           |
-- +----------+------------------+--------------+-------------------+

-- 3. Check loyalty points are non-negative
SELECT 
    customer_id,
    first_name,
    last_name,
    loyalty_points,
    CASE 
        WHEN loyalty_points >= 0 THEN 'VALID'
        ELSE 'ERROR'
    END as points_validation
FROM customers;

-- +-------------+------------+-----------+----------------+-------------------+
-- | customer_id | first_name | last_name | loyalty_points | points_validation |
-- +-------------+------------+-----------+----------------+-------------------+
-- |           1 | John       | Doe       |            116 | VALID             |
-- |           2 | Jane       | Smith     |            150 | VALID             |
-- |           3 | Mike       | Johnson   |             25 | VALID             |
-- |           4 | Sarah      | Wilson    |            200 | VALID             |
-- |           5 | Alyssa     | Garcia    |             75 | VALID             |
-- +-------------+------------+-----------+----------------+-------------------+

-- =====================================================
-- PERFORMANCE MONITORING QUERIES
-- =====================================================

-- Query to monitor database performance
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    DATA_LENGTH,
    INDEX_LENGTH,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) as size_mb
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'alyssas_kitchen_atlas'
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;

-- +-----------------------------+------------+-------------+--------------+---------+
-- | TABLE_NAME                  | TABLE_ROWS | DATA_LENGTH | INDEX_LENGTH | size_mb |
-- +-----------------------------+------------+-------------+--------------+---------+
-- | customers                   |          5 |       16384 |        65536 |    0.08 |
-- | ingredients                 |         36 |       16384 |        65536 |    0.08 |
-- | kitchen_load                |          4 |       16384 |        49152 |    0.06 |
-- | menu_items                  |         15 |       16384 |        49152 |    0.06 |
-- | loyalty_transactions        |          0 |       16384 |        32768 |    0.05 |
-- | order_excluded_ingredients  |          0 |       16384 |        32768 |    0.05 |
-- | order_items                 |          0 |       16384 |        32768 |    0.05 |
-- | customer_allergens          |          0 |       16384 |        16384 |    0.03 |
-- | menu_item_ingredients       |          0 |       16384 |        16384 |    0.03 |
-- | orders                      |          0 |       16384 |        16384 |    0.03 |
-- | wait_list                   |          0 |       16384 |        16384 |    0.03 |
-- | customer_order_history_view |       NULL |        NULL |         NULL |    NULL |
-- | kitchen_performance_view    |       NULL |        NULL |         NULL |    NULL |
-- | popular_dishes_view         |       NULL |        NULL |         NULL |    NULL |
-- +-----------------------------+------------+-------------+--------------+---------+
