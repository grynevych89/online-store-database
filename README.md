# Arbeidskrav 2 – Database

**Student:** Mykola Grynevych
**Repository:** https://github.com/grynevych89/online-store-database

## How to run

Developed and tested with MySQL 8.4 running in Docker on macOS, using
DataGrip as the SQL client. Any MySQL 8.x server works.

### Option 1 – Docker (no local MySQL needed)

Start a MySQL container:

```bash
docker run --name nettbutikk-mysql \
  -e MYSQL_ROOT_PASSWORD=root \
  -p 3306:3306 \
  -d mysql:8.4
```

Wait until the server is ready:

```bash
docker logs nettbutikk-mysql 2>&1 | grep 'ready for connections'
```

Run the script from the project folder:

```bash
docker exec -i nettbutikk-mysql mysql -uroot -proot -t < oppgave-1-database.sql
```

`-t` prints the verification queries as tables in the terminal.

### Option 2 – existing MySQL server

```bash
mysql -u <user> -p -t < oppgave-1-database.sql
```

The user needs permission to drop and create the `nettbutikk` database.

### Option 3 – GUI client (DataGrip, MySQL Workbench, DBeaver)

Open `oppgave-1-database.sql`, select a MySQL connection and run the whole
file.

The script can be run any number of times: it drops and recreates the
database on every run.

## File structure

- `oppgave-1-database.sql` – Oppgave 1, creates the database, tables and
  relationships, followed by verification queries
- `README.md` – this file

The SQL file names are kept exactly as required by the assignment.

## Oppgave 1 – Create the database and tables

`oppgave-1-database.sql`

### Rerunnable script

The script starts with `DROP DATABASE IF EXISTS nettbutikk`, then
`CREATE DATABASE` and `USE`. The database is rebuilt from scratch on every
run, so it never has to be deleted by hand.

### Order of creation

`orders` has foreign keys to both `customers` and `products`, so a referenced
table must exist before `orders` can be created. The order is therefore:

1. `customers`
2. `products`
3. `orders`

### Tables

| Table | Primary key | Other constraints |
|---|---|---|
| `customers` | `customer_id` (`AUTO_INCREMENT`) | `email` is `UNIQUE` (`uq_customers_email`) |
| `products` | `product_id` (`AUTO_INCREMENT`) | – |
| `orders` | `order_id` (`AUTO_INCREMENT`) | `fk_orders_customer`, `fk_orders_product` |

Column names, data types and text lengths follow the data model exactly.
Every column is `NOT NULL`. `price` is `DECIMAL(10, 2)` rather than a
floating-point type, so monetary values are stored exactly.

Constraints are given explicit names (`uq_…`, `fk_…`) so they are easy to
recognise in error messages and in `information_schema`.

### Relationships

| Foreign key | From | To | Meaning |
|---|---|---|---|
| `fk_orders_customer` | `orders.customer_id` | `customers.customer_id` | An order belongs to exactly one existing customer |
| `fk_orders_product` | `orders.product_id` | `products.product_id` | An order refers to exactly one existing product |

Both foreign key columns are `NOT NULL`, so an order cannot exist without a
customer and a product (`1` side). Nothing forces a customer or a product to
have orders, which gives the `0..*` side of both relationships.

### Verification

The end of the script checks the result:

| Query | Checks |
|---|---|
| `SHOW DATABASES LIKE 'nettbutikk'` | The database exists |
| `SHOW TABLES` | All three tables exist |
| `DESCRIBE customers` / `products` / `orders` | Columns, data types, `NULL`, keys, `auto_increment` |
| `information_schema.table_constraints` | Primary keys, foreign keys and the `UNIQUE` constraint on `email` |
| `information_schema.key_column_usage` | Which columns the foreign keys reference |

Expected result: 1 database, 3 tables, 6 constraints (3 × `PRIMARY KEY`,
1 × `UNIQUE`, 2 × `FOREIGN KEY`) and 2 foreign key references.

### Test cases

| # | Situation | Expected result | Result |
|---|---|---|---|
| 1 | Run the script on an empty server | Database and three tables created, no errors | OK |
| 2 | Run the script a second time | Database dropped and recreated, no errors | OK |
| 3 | `DESCRIBE` on all tables | Types and lengths match the data model | OK |
| 4 | Constraint query | 3 PK, 1 UNIQUE, 2 FK | OK |
| 5 | Foreign key query | `orders.customer_id` → `customers`, `orders.product_id` → `products` | OK |

## Requirements compliance

### Oppgave 1

| Requirement | Status |
|---|---|
| Create the database `nettbutikk` | Done |
| Script rerunnable without deleting the database manually | Done – `DROP DATABASE IF EXISTS` |
| Create `customers`, `products`, `orders` in a correct order | Done |
| Column names, data types, text lengths as in the model | Done |
| `PRIMARY KEY`, `NOT NULL`, `AUTO_INCREMENT` | Done |
| `UNIQUE` email | Done |
| Foreign keys: order → existing customer and existing product | Done |
| Verify database, tables, types, keys and unique constraint | Done – verification queries at the end of the script |
| Save in `oppgave-1-database.sql` | Done |

## Git

Development is done in a Git repository with one branch per task
(`oppgave1`, …), merged into `main` when the task is complete:

https://github.com/grynevych89/online-store-database/commits/main

## AI Documentation

I have used AI (Claude) to a limited extent while working on this arbeidskrav.

- Translating the assignment text into my native language, so that I could
  understand the requirements correctly.

This did not influence the design or the logic of my solution and is therefore
not documented as an individual prompt.

The exchanges that had a direct influence on the work are documented below.

### Prompt 1 — Oppgave 1, review

**Prompt:** "Everything seems to be ready. Check it against Task 1"
(originally: «Вроде все готово. Проверь на соответствии с заданием №1»), with
`oppgave-1-database.sql` and `README.md` attached. I wrote the solution myself
first and asked for a review against the assignment requirements.

**Response (summary):** a requirement-by-requirement check of the script:
database creation, rerunnability, order of table creation, column names, data
types, text lengths, primary keys, foreign keys, `NOT NULL`, `AUTO_INCREMENT`,
`UNIQUE` on `email` and the verification queries. No errors were found.
Optional suggestions:

1. Set the character set explicitly (`utf8mb4`) so that values like `Tromsø`
   are stored correctly on any server.
2. Add `constraint_name` to the foreign key verification query.
3. Use a more reliable way to wait for the MySQL container to be ready, since
   `ready for connections` is logged twice on first start.
4. Mention the difference between `1..n` in the diagram and `0..*` in the
   assignment text.

**How it was used and quality assured:** The table structure, keys and
verification queries were written by me. I reviewed each suggestion and
decided which ones to apply. The optional points are handled separately as
part of debugging and reflection, so that I can test and explain each change
myself rather than copying it. No errors or problems were encountered when
using AI for Oppgave 1.

### Other sources

- Course material from completed lessons on the Gokstad Akademiet LMS
- MySQL 8.4 Reference Manual: https://dev.mysql.com/doc/