# Northwind SQL Analysis

Business analysis of the Northwind dataset using PostgreSQL.
Covers revenue analysis, employee performance, customer behavior,
supplier insights, and JOIN patterns across multiple tables.

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

## Files
- `queries.sql` — Day 1 business analysis queries
- `joins.sql` — Day 2 JOIN pattern queries