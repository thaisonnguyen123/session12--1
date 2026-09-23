CREATE DATABASE ecommerce;
USE ecommerce;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);

CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    quantity INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    status VARCHAR(20),
    total_amount DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE order_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO products (product_name, price) VALUES
('Laptop', 1500),
('Phone', 800),
('Headphones', 150);

INSERT INTO inventory (product_id, quantity) VALUES
(1, 10),
(2, 20),
(3, 50);

INSERT INTO orders (customer_name, status) VALUES
('Alice', 'Pending'),
('Bob', 'Completed');

INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 1500),
(1, 3, 2, 150),
(2, 2, 1, 800);

DELIMITER $$

CREATE TRIGGER check_inventory_before_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE stock INT;

    SELECT quantity INTO stock
    FROM inventory
    WHERE product_id = NEW.product_id;

    IF stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Not enough inventory';
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER update_total_after_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET total_amount = total_amount + (NEW.quantity * NEW.price)
    WHERE order_id = NEW.order_id;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER check_inventory_before_update
BEFORE UPDATE ON order_items
FOR EACH ROW
BEGIN
    DECLARE stock INT;

    SELECT quantity INTO stock
    FROM inventory
    WHERE product_id = NEW.product_id;

    IF stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Not enough inventory for update';
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER update_total_after_update
AFTER UPDATE ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET total_amount = total_amount
        - (OLD.quantity * OLD.price)
        + (NEW.quantity * NEW.price)
    WHERE order_id = NEW.order_id;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER prevent_delete_completed_order
BEFORE DELETE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot delete completed order';
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER restore_inventory_after_delete
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET quantity = quantity + OLD.quantity
    WHERE product_id = OLD.product_id;
END $$

DELIMITER ;

DROP TRIGGER IF EXISTS check_inventory_before_insert;
DROP TRIGGER IF EXISTS update_total_after_insert;
DROP TRIGGER IF EXISTS check_inventory_before_update;
DROP TRIGGER IF EXISTS update_total_after_update;
DROP TRIGGER IF EXISTS prevent_delete_completed_order;
DROP TRIGGER IF EXISTS restore_inventory_after_delete;

