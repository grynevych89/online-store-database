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

- `oppgave-1-database.sql` – Oppgave 1 and 2, creates the database, tables and
  relationships, inserts the sample data, followed by verification queries
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

## Oppgave 2 – Insert sample data

`oppgave-1-database.sql`

The sample data is inserted in the same script, directly after the tables are
created, so one run builds the whole database from scratch.

### Order of insertion

`orders` refers to both `customers` and `products` through foreign keys. An
order can only be inserted when the customer and the product it points to
already exist, so the order is:

1. `products`
2. `customers`
3. `orders`

Inserting `orders` first would fail with a foreign key error.

### INSERT statements

Each table is filled with one multi-row `INSERT`, with the column list written
out explicitly:

| Table | Rows |
|---|---|
| `products` | 10 |
| `customers` | 8 |
| `orders` | 18 |

The ID values are inserted explicitly, exactly as given in the assignment, so
that the foreign keys in `orders` point to the intended customers and
products. `AUTO_INCREMENT` still works afterwards: MySQL moves the counter to
the highest existing value + 1, so new rows get the next free ID.

### Character set

This was added as a reflection after Oppgave 2 was finished. The sample data
contains Norwegian characters (`Tromsø`), and relying on the server's default
character set is not safe: on another server or client the same script could
store the data incorrectly. The character set is therefore set explicitly in
two places at the top of the script:

- `SET NAMES utf8mb4` – the connection between the client and the server.
  Without it, a client with a different default (for example the `mysql`
  command-line client in Docker) can read the file in the wrong encoding and
  store `Tromsø` as `TromsÃ¸`.
- `CREATE DATABASE nettbutikk CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci`
  – the database itself, so the tables inherit `utf8mb4` regardless of the
  server's default settings.

### Verification

Three queries at the end of the script check the data. The first checks the
character set of the database:

```sql
SELECT default_character_set_name, default_collation_name
FROM information_schema.schemata
WHERE schema_name = 'nettbutikk';
```

Expected result: `utf8mb4`, `utf8mb4_0900_ai_ci`.

The second counts the rows in all three tables:

```sql
SELECT (SELECT COUNT(*) FROM products)  AS products_count,
       (SELECT COUNT(*) FROM customers) AS customers_count,
       (SELECT COUNT(*) FROM orders)    AS orders_count;
```

Expected result: `10`, `8`, `18`.

The third checks that the Norwegian character was stored correctly:

```sql
SELECT city FROM customers WHERE city LIKE 'Troms%';
```

Expected result: `Tromsø`.

### Test cases

| # | Situation | Expected result | Result |
|---|---|---|---|
| 1 | Run the full script on an empty server | All tables created and filled, no errors | OK |
| 2 | Run the full script a second time | Database rebuilt, no duplicate rows | OK |
| 3 | Row count query | `10`, `8`, `18` | OK |
| 4 | Character set query | `utf8mb4`, `utf8mb4_0900_ai_ci` | OK |
| 5 | `Tromsø` query | `Tromsø`, not `TromsÃ¸` | OK |

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

### Oppgave 2

| Requirement | Status |
|---|---|
| Insert all sample data into `products` (10 rows) | Done |
| Insert all sample data into `customers` (8 rows) | Done |
| Insert all sample data into `orders` (18 rows) | Done |
| `INSERT` statements written by hand | Done |
| Correct order of insertion because of foreign keys | Done – `products`, `customers`, then `orders` |
| Sample data included in `oppgave-1-database.sql` | Done |
| Script creates the whole database and inserts all data from scratch | Done |

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
myself rather than copying it.

Point 1 was applied later, as a reflection after Oppgave 2 was finished: the
sample data contains `Tromsø`, and I decided not to rely on the server's
default character set. I added `SET NAMES utf8mb4` for the connection and an
explicit character set on `CREATE DATABASE`, together with two verification
queries (`information_schema.schemata` and the `Tromsø` query). I ran the
script and confirmed that the database uses `utf8mb4` and that `Tromsø` is
stored correctly.

No errors or problems were encountered when using AI for Oppgave 1.

### Prompt 2 — Oppgave 2, review

**Prompt:** the updated `oppgave-1-database.sql` with the `INSERT` statements,
sent for a review against the Oppgave 2 requirements. I wrote the solution
myself first.

**Response (summary):** all rows were checked line by line against the tables
in the assignment, and the order of insertion was confirmed as correct.
No errors were found. One optional suggestion: combine the three separate
`COUNT(*)` queries into one query, so the result is shown as a single row.

**How it was used and quality assured:** I applied the suggestion and ran the
script to confirm that the query returns `10`, `8` and `18`. No errors or
problems were encountered when using AI for Oppgave 2.

### Other sources

- Course material from completed lessons on the Gokstad Akademiet LMS
- MySQL 8.4 Reference Manual: https://dev.mysql.com/doc/