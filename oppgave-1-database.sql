DROP DATABASE IF EXISTS nettbutikk;
CREATE DATABASE nettbutikk;
USE nettbutikk;

CREATE TABLE customers (
                           customer_id INT NOT NULL AUTO_INCREMENT,
                           first_name VARCHAR(50) NOT NULL,
                           last_name VARCHAR(50) NOT NULL,
                           email VARCHAR(100) NOT NULL,
                           city VARCHAR(50) NOT NULL,
                           registered_date DATE NOT NULL,
                           PRIMARY KEY (customer_id),
                           CONSTRAINT uq_customers_email UNIQUE (email)
);

CREATE TABLE products (
                          product_id INT NOT NULL AUTO_INCREMENT,
                          product_name VARCHAR(100) NOT NULL,
                          category VARCHAR(50) NOT NULL,
                          price DECIMAL(10, 2) NOT NULL,
                          stock INT NOT NULL,
                          PRIMARY KEY (product_id)
);

CREATE TABLE orders (
                        order_id INT NOT NULL AUTO_INCREMENT,
                        customer_id INT NOT NULL,
                        product_id INT NOT NULL,
                        quantity INT NOT NULL,
                        order_date DATE NOT NULL,
                        status VARCHAR(20) NOT NULL,
                        PRIMARY KEY (order_id),
                        CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
                        CONSTRAINT fk_orders_product FOREIGN KEY (product_id) REFERENCES products (product_id)
);

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