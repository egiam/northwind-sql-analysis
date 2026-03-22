# Northwind SQL Analysis

Business analysis of the Northwind dataset using PostgreSQL.
Covers revenue analysis, employee performance, customer behavior,
supplier insights, JOIN patterns, and aggregation techniques.

## Tech Stack
- PostgreSQL
- DBeaver

## Dataset
Classic Northwind sample database. Source: [pthom/northwind_psql](https://github.com/pthom/northwind_psql)

---

## Day 1 — Business Analysis Queries

Ten analytical queries focused on revenue, performance, and customer behavior.

### Business Questions

1. Which products have been purchased by the most customers?
2. Which employee processed the most orders?
3. Which suppliers provide the highest volume of sold products?
4. Which products generate the most revenue?
5. Which customers have not placed an order in the last quarter?
6. Which employees generate the most revenue?
7. Which product categories drive the most revenue?
8. Which cities generate the most revenue?
9. Which suppliers generate the most revenue?
10. Which customers have the highest average order value?

### Notes
- Revenue calculations account for per-item discounts
- Question 5 uses a dynamic date reference based on the dataset's
  latest order date rather than a hardcoded value
- Question 10 aggregates to order level before averaging
  to avoid line-item dilution

---

## Day 2 — JOIN Patterns

Eight queries demonstrating practical use cases for each JOIN type.

### Queries

1. **INNER** — Orders with their assigned employees
2. **INNER** — Products with their categories and suppliers in one query
3. **LEFT** — All customers, including those who have never placed an order
4. **LEFT** — All products, including those that have never been ordered
5. **RIGHT** — All employees, including those who have never processed an order
6. **FULL OUTER** — All customers and all orders, showing unmatched rows on both sides
7. **Anti-join** — Customers who have never ordered
8. **Anti-join** — Products that have never appeared in any order

### Notes
- RIGHT JOIN in query 5 is intentional — equivalent to flipping table order
  and using LEFT JOIN, but included to demonstrate the concept
- Anti-joins use LEFT JOIN + WHERE NULL pattern, not a separate SQL keyword
- FULL OUTER exposes orphaned records on both sides — critical pattern
  for detecting data integrity issues in real-world datasets

---

## Day 3 — Aggregations

Eleven queries covering COUNT, SUM, AVG, MIN, MAX with GROUP BY and HAVING.

### Queries

1. **COUNT** — Number of orders per customer
2. **COUNT + HAVING** — Customers who have placed more than 5 orders
3. **SUM** — Total revenue per year
4. **SUM + HAVING** — Product categories that have generated more than $100,000 in revenue
5. **AVG** — Average order value per employee
6. **AVG + HAVING** — Employees whose average order value exceeds the overall average
7. **MIN / MAX** — Earliest and latest order date per customer
8. **MIN / MAX** — Price range per category
9. **MIN / MAX** — Cheapest and most expensive product per category (price only — product names require window functions, revisited later)
10. **COUNT + SUM** — Number of orders and total revenue per country
11. **Multi-level HAVING** — Suppliers with more than 3 products that have generated over $50,000 in revenue

### Notes
- WHERE filters rows before grouping; HAVING filters groups after aggregation
- Query 6 uses a subquery inside HAVING to dynamically calculate the overall
  average rather than hardcoding a value
- Query 9 intentionally scoped to price range only — retrieving the specific
  product name at MIN/MAX price requires window functions
- Query 11 combines COUNT and SUM conditions in a single HAVING clause

---

## Day 4 — Subqueries and CTEs

The same business question solved three ways to compare readability and structure.

### Business Question
Which customers have total spending above the average customer spending?

### Versions

1. **Subquery** — Inline subquery inside HAVING to calculate the average dynamically
2. **CTE** — Order-level revenue defined once as a named CTE, referenced twice
3. **JOIN** — Average spending calculated as a single-row subquery and joined
   onto the main query without a key

### Notes
- All three versions produce identical results
- CTEs are not faster than subqueries — the advantage is readability
  and avoiding repetition of the same logic
- Version 1 writes the order-level revenue subquery twice — exactly
  the problem CTEs solve
- Version 3 demonstrates cross-joining a scalar value by omitting ON
  and using it as a filter condition instead
- Readability verdict: CTE is the clearest — logic is defined once,
  named, and the final SELECT reads as plain English

---

## Files
- `Northwind-SQL-1.sql` — Day 1 business analysis queries
- `Northwind-SQL-2.sql` — Day 2 JOIN pattern queries
- `Northwind-SQL-3.sql` — Day 3 aggregation queries