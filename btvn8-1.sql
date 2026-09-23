USE studentss;

CREATE TABLE customerss (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    address VARCHAR(255) NOT NULL
);

-- Unique Index cho email
CREATE UNIQUE INDEX idx_customers_email
ON customers(email);

-- Non-Unique Index cho phone
CREATE INDEX idx_customers_phone
ON customers(phone);
