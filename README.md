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

## Day 5 — StrataScratch Practice (Easy tier)

Five real company interview problems solved on StrataScratch using PostgreSQL.

### Problems

1. **Unique users per client per month** — COUNT DISTINCT + EXTRACT(MONTH)
2. **Shipments per month** — DATE_TRUNC + composite key counting
3. **Average bathrooms and bedrooms per city and property type** — AVG + multi-column GROUP BY
4. **MacBook Pro user event counts** — COUNT + WHERE filter + ORDER BY
5. **Most profitable financial sector company** — HAVING + correlated subquery

### Mistakes and Lessons

**Problem 1** — Grouped by the full `time_id` date instead of the extracted month.
Result was one row per day instead of one row per month.
Fix: `GROUP BY EXTRACT(MONTH FROM time_id)`, not the raw date column.

**Problem 2** — Used `COUNT(shipment_id + sub_id)` to count unique composite keys.
That adds two numbers together which is meaningless — two different pairs can produce
the same sum. Correct approaches: `COUNT(DISTINCT (shipment_id, sub_id))` or
`COUNT(CONCAT(shipment_id, sub_id))`.

### Notes
- Problem 5 had multiple community solutions that passed the test but were
  logically wrong — they worked by coincidence because the highest-profit
  company in the entire dataset happened to be in financials. Always filter
  the subquery to the same scope as the outer query.
- The official solution for Problem 5 uses a CTE — same logic as my HAVING
  version but more readable. Both are correct.
  
---

## Day 6 — StrataScratch & HackerRank Practice (Easy tier)

Five problems across StrataScratch and HackerRank reinforcing Week 1 patterns
under real interview conditions.

### Problems

1. **TBD**
2. **TBD**
3. **TBD**
4. **TBD**
5. **TBD**

### Mistakes and Lessons

*(to be filled after problems are solved)*

### Notes
- Community solutions on both platforms are frequently wrong —
  always validate logic, not just output match
- StrataScratch problems often have multiple valid approaches;
  CTE version preferred for readability

---

## Day 7 — Window Functions: ROW_NUMBER, RANK, DENSE_RANK

Introduction to window functions using ranking functions across
customer revenue and product sales data.

### Queries

1. **ROW_NUMBER / RANK / DENSE_RANK** — All three ranking functions applied
   to customers by total revenue in a single query to expose tie-breaking behavior
2. **Products by quantity sold** — Same three functions applied to product sales,
   written independently without reference
3. **Per-country customer ranking** — PARTITION BY country added to scope
   rankings within each country without collapsing rows
4. **GROUP BY comparison** — Same per-country ranking attempted with GROUP BY
   alone to demonstrate why window functions exist

### Notes
- ROW_NUMBER always produces unique values — breaks ties arbitrarily
- RANK skips numbers after ties — three customers tied for 1st means
  next rank is 4, not 2
- DENSE_RANK never skips — three customers tied for 1st means
  next rank is 2
- PARTITION BY scopes the window without collapsing rows.
  GROUP BY collapses rows — you cannot rank within groups without either
  a window function or a self-join hack. This is the core difference
  interviewers test.
- Ties were manufactured using ROUND(revenue, -2) to bucket values —
  real data in Northwind has no natural revenue ties at customer level
- `rank` is a reserved word in PostgreSQL — always alias as `rnk`
  or `country_rank`
  
---

## Day 8 — Window Functions: LAG, LEAD, Running Totals

Time-series analysis using offset and cumulative window functions
on Northwind monthly revenue data.

### Queries

1. **LAG — Month-over-month revenue change** — Previous month revenue and
   percentage growth calculated using LAG(revenue, 1)
2. **LEAD — Next month revenue** — Forward-looking offset using LEAD(revenue, 1)
   to access the following month's value
3. **Running total** — Cumulative revenue across all months using
   SUM() OVER (ORDER BY month)

### Notes
- First row of LAG query returns NULL for prev_month_rev — no prior row exists
- Last row of LEAD query returns NULL for next_month_rev — no following row exists
- LEAD with a MoM growth formula is syntactically valid but analytically
  meaningless — MoM growth is a LAG question. LEAD's real use case is
  time-to-next-event analysis
- SUM() OVER (ORDER BY month) defaults to frame ROWS BETWEEN UNBOUNDED
  PRECEDING AND CURRENT ROW — each row accumulates all revenue up to
  and including itself
- PostgreSQL ROUND with precision requires ::numeric cast —
  ROUND(expression::numeric, 2). Double precision will throw error 42883.
- DATE_TRUNC('month', date_column) truncates to the first of the month —
  standard pattern for time series grouping
  
---

## Day 9 — Query Optimization and EXPLAIN ANALYZE

Reading and interpreting PostgreSQL query plans on existing Northwind queries.

### Queries Analyzed

1. **Customer ranking query** — Window function query from Day 7
2. **Anti-join query** — Customers who have never ordered from Day 2
3. **LAG MoM revenue query** — Time series query from Day 8

### Key Findings

1. **Customer ranking** — Hash Join on order_details and orders, perfect row
   estimate (89 estimated vs 89 actual). Execution time 1.2ms.
2. **Anti-join** — PostgreSQL rewrote LEFT JOIN to Hash Right Join internally.
   Slight row mismatch (1 estimated vs 2 actual) — harmless at this scale.
3. **LAG MoM query** — Bad row estimate (480 estimated vs 23 actual) caused by
   DATE_TRUNC producing a derived column with no statistics. Harmless at toy
   scale, dangerous on production tables with millions of rows.

### Notes
- EXPLAIN estimates without running. EXPLAIN ANALYZE runs and shows real numbers.
  Always use ANALYZE when you want truth.
- Read query plans bottom-up — innermost node executes first
- cost=X..Y means startup cost .. total cost. Relative units, not milliseconds.
- Estimated rows vs actual rows is the most important signal in a query plan.
  A large mismatch means PostgreSQL is flying blind and may choose wrong strategies.
- Derived columns (DATE_TRUNC, ROUND, expressions) have no statistics —
  PostgreSQL always guesses on these.
- All three queries used Seq Scans. Indexes were not added — Northwind is too
  small for indexes to change execution plans. PostgreSQL correctly determines
  that scanning 830 rows directly is cheaper than index lookup overhead.
  Indexes matter at scale, not on toy datasets.

---

## Day 10 — Chained CTEs

Multi-step query using three chained CTEs to calculate month-over-month
revenue growth, where each CTE depends on the previous one's output.

### Query

**Month-over-month revenue growth via chained CTEs**
- CTE 1 — Monthly revenue aggregated from order_details and orders
- CTE 2 — Pulls from CTE 1, adds LAG to get previous month revenue
- CTE 3 — Pulls from CTE 2, calculates MoM growth percentage

### Notes
- Each CTE references only the previous CTE — that's what makes it a chain,
  not three independent CTEs sitting next to each other
- GROUP BY only belongs in CTEs that perform aggregation. CTEs that only
  select, filter, or apply window functions do not need GROUP BY.
- This pattern maps directly to how dbt models are structured —
  each model builds on the previous one's output
- Over-engineered for this dataset intentionally — the point is practicing
  the pattern, not optimizing the query
  
---

## Day 11 — StrataScratch Medium Tier Practice

Five medium-level interview problems covering conditional aggregation,
self-joins, and multi-table logic.

### Problems

1. **US open user percentage** — Percentage of users from USA with open status
2. **Number permutations** — All pairs via CROSS JOIN with GREATEST() per pair
3. **Unique users per flagged video** — COUNT DISTINCT composite key with NULL handling
4. **Managers below twice report average** — Double JOIN on same table, HAVING filter
5. **Department growth post-2020** — WHERE date filter, HAVING headcount threshold

### Mistakes and Lessons

**Problem 1** — Integer division returns 0 before multiplying by 100.
Fix: cast numerator to numeric before dividing.
`count::numeric / total * 100` not `count / total * 100`

**Problem 1** — Mixed scalar CTE column with aggregate in SELECT causes
GroupingError. Fix: wrap scalar in MAX() when mixing with COUNT().

**Problem 2** — Dense academic wording disguising a simple CROSS JOIN.
Strip any problem to: what are the inputs, what does one output row look like.

**Problem 3** — CONCAT without separator causes false deduplication.
`CONCAT(firstname, lastname)` → 'John' + '' = 'Jo' + 'hn' = 'John'.
Fix: always use a separator. `CONCAT(firstname, '|', lastname)`

**Problem 4** — Compared manager salary against company-wide average
instead of per-manager average. Required joining dim_employee twice
with different aliases — once for manager role, once for employee role.

### Notes
- `SUM(CASE WHEN condition THEN 1 ELSE 0 END)` — conditional counting pattern.
  Counts a subset without filtering out the rest of the data. Use this constantly.
- `GREATEST(a, b)` returns the largest value across columns in the same row.
  Different from MAX() which aggregates across rows.
- Joining the same table twice with different aliases is a core pattern
  for hierarchical or role-based data. Write it cold.
- HAVING fires after aggregation. Any filter involving an aggregate
  belongs in HAVING, not WHERE.
- Medium tier wording is often deliberately complex. The SQL is rarely
  as hard as the description suggests.
  
  ---

## Files
- `Northwind-SQL-1.sql` — Day 1 business analysis queries
- `Northwind-SQL-2.sql` — Day 2 JOIN pattern queries
- `Northwind-SQL-3.sql` — Day 3 aggregation queries
- `Northwind-SQL-4.sql` — Day 4 subquery and CTE patterns
- `Northwind-SQL-5.sql` — Day 5 practice problems with notes on mistakes
- `Northwind-SQL-6.sql` — Day 6 practice problems with notes on mistakes
- `Rank-and-DenseRank-PartitionBy.sql` — Day 7 window function ranking queries
- `LAG-LEAD-SUM.sql` — Day 8 LAG, LEAD, and running total queries
- `Analyze.sql` — Day 9 EXPLAIN ANALYZE query plan analysis
- `CTE-concatenated.sql` — Day 10 chained CTE MoM growth query
- `Northwind-SQL-11.sql` — Day 11 medium tier practice problems