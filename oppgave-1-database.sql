SET NAMES utf8mb4;
DROP DATABASE IF EXISTS nettbutikk;
CREATE DATABASE nettbutikk CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE nettbutikk;

CREATE TABLE customers
(
    customer_id     INT          NOT NULL AUTO_INCREMENT,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL,
    city            VARCHAR(50)  NOT NULL,
    registered_date DATE         NOT NULL,
    PRIMARY KEY (customer_id),
    CONSTRAINT uq_customers_email UNIQUE (email)
);

CREATE TABLE products
(
    product_id   INT            NOT NULL AUTO_INCREMENT,
    product_name VARCHAR(100)   NOT NULL,
    category     VARCHAR(50)    NOT NULL,
    price        DECIMAL(10, 2) NOT NULL,
    stock        INT            NOT NULL,
    PRIMARY KEY (product_id)
);

CREATE TABLE orders
(
    order_id    INT         NOT NULL AUTO_INCREMENT,
    customer_id INT         NOT NULL,
    product_id  INT         NOT NULL,
    quantity    INT         NOT NULL,
    order_date  DATE        NOT NULL,
    status      VARCHAR(20) NOT NULL,
    PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
    CONSTRAINT fk_orders_product FOREIGN KEY (product_id) REFERENCES products (product_id)
);

INSERT INTO products (product_id, product_name, category, price, stock)
VALUES (1, 'Laptop Pro 15', 'Computers', 12999.00, 8),
       (2, 'Wireless mouse', 'Accessories', 399.00, 45),
       (3, 'Mechanical keyboard', 'Accessories', 899.00, 22),
       (4, '27-inch monitor', 'Monitors', 3299.00, 14),
       (5, 'USB-C hub', 'Accessories', 699.00, 30),
       (6, 'HD webcam', 'Accessories', 799.00, 18),
       (7, 'Gaming headset', 'Audio', 1199.00, 16),
       (8, 'Bluetooth speaker', 'Audio', 1499.00, 12),
       (9, 'External SSD 1TB', 'Storage', 1099.00, 25),
       (10, 'Laptop stand', 'Accessories', 549.00, 35);

INSERT INTO customers (customer_id, first_name, last_name, email, city, registered_date)
VALUES (1, 'Ola', 'Nordmann', 'ola.nordmann@example.com', 'Oslo', '2025-01-15'),
       (2, 'Kari', 'Hansen', 'kari.hansen@example.com', 'Bergen', '2025-02-03'),
       (3, 'Per', 'Johansen', 'per.johansen@example.com', 'Trondheim', '2025-02-18'),
       (4, 'Anne', 'Larsen', 'anne.larsen@example.com', 'Oslo', '2025-03-01'),
       (5, 'Thomas', 'Andersen', 'thomas.andersen@example.com', 'Stavanger', '2025-03-12'),
       (6, 'Maria', 'Nilsen', 'maria.nilsen@example.com', 'Kristiansand', '2025-04-05'),
       (7, 'Erik', 'Olsen', 'erik.olsen@example.com', 'Bergen', '2025-04-21'),
       (8, 'Ingrid', 'Berg', 'ingrid.berg@example.com', 'Tromsø', '2025-05-10');

INSERT INTO orders (order_id, customer_id, product_id, quantity, order_date, status)
VALUES (1, 1, 1, 1, '2025-06-01', 'Delivered'),
       (2, 1, 2, 2, '2025-06-01', 'Delivered'),
       (3, 2, 4, 1, '2025-06-03', 'Delivered'),
       (4, 3, 3, 1, '2025-06-05', 'Delivered'),
       (5, 4, 5, 2, '2025-06-08', 'Delivered'),
       (6, 5, 7, 1, '2025-06-10', 'Delivered'),
       (7, 6, 8, 1, '2025-06-12', 'Delivered'),
       (8, 7, 9, 2, '2025-06-15', 'Delivered'),
       (9, 2, 2, 1, '2025-07-01', 'Delivered'),
       (10, 3, 5, 1, '2025-07-04', 'Delivered'),
       (11, 4, 4, 2, '2025-07-06', 'Delivered'),
       (12, 5, 9, 1, '2025-07-09', 'Delivered'),
       (13, 1, 9, 1, '2025-08-02', 'Shipped'),
       (14, 3, 2, 3, '2025-08-05', 'Shipped'),
       (15, 5, 4, 1, '2025-08-08', 'Processing'),
       (16, 7, 5, 2, '2025-08-10', 'Processing'),
       (17, 6, 3, 1, '2025-08-12', 'Shipped'),
       (18, 2, 6, 2, '2025-08-15', 'Processing');

SHOW DATABASES LIKE 'nettbutikk';
SHOW TABLES;

DESCRIBE customers;
DESCRIBE products;
DESCRIBE orders;

SELECT table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'nettbutikk'
ORDER BY table_name, constraint_type;

SELECT table_name, column_name, referenced_table_name, referenced_column_name
FROM information_schema.key_column_usage
WHERE table_schema = 'nettbutikk'
  AND referenced_table_name IS NOT NULL;

SELECT default_character_set_name, default_collation_name
FROM information_schema.schemata
WHERE schema_name = 'nettbutikk';

SELECT city FROM customers WHERE city LIKE 'Troms%';

SELECT (SELECT COUNT(*) FROM products)  AS products_count,
       (SELECT COUNT(*) FROM customers) AS customers_count,
       (SELECT COUNT(*) FROM orders)    AS orders_count;