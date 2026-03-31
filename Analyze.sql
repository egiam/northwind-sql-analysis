
--EXPLAIN vs EXPLAIN ANALYZE
--EXPLAIN — estimates. Shows the query plan PostgreSQL thinks it will use. No query is actually run.
--EXPLAIN ANALYZE — actually runs the query and shows real numbers alongside the estimates. 
--Always use ANALYZE when you want truth.

EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 'ALFKI';

--**How to read the output**
--The output is a tree. Read it bottom-up — the innermost node executes first.
--Each node shows:
--Seq Scan on orders  (cost=0.00..1.34 rows=11 width=54) 
--                     (actual time=0.012..0.018 rows=11 loops=1)


--cost=0.00..1.34 — estimated startup cost .. total cost. Arbitrary units, relative not absolute
--rows=11 — estimated row count
--actual time — real milliseconds
--actual rows — real row count

explain analyze
WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(unit_price * quantity * (1 - discount)) AS total_revenue
    FROM order_details od
    JOIN orders o ON od.order_id = o.order_id
    GROUP BY customer_id
)
SELECT
    customer_id,
    ROUND(total_revenue::numeric, -2) AS revenue_bucket, -- rounds to nearest 100, forces ties
    ROW_NUMBER() OVER (ORDER BY ROUND(total_revenue::numeric, -2) DESC) AS row_num,
    RANK()       OVER (ORDER BY ROUND(total_revenue::numeric, -2) DESC) AS rnk,
    DENSE_RANK() OVER (ORDER BY ROUND(total_revenue::numeric, -2) DESC) AS dense_rnk
FROM customer_revenue;

--PostgreSQL scanned both tables fully — Seq Scan on both. Expected for 2155 rows.
--Hash Join is the join method — builds a hash table on orders, probes it with order_details. Fast for this size.
--Estimated rows=89, actual rows=89. Perfect estimate. PostgreSQL knew exactly what it was getting.
--Total execution: 1.2ms. Northwind is tiny.


explain analyze
select c.company_name, o.order_id 
from customers c 
left join orders o on c.customer_id = o.customer_id
where o.order_id is null;

--Filter removed 830 rows, kept 2. That's your anti-join working.
--Estimated rows=1, actual rows=2. Slight mismatch
--harmless here but in production on millions of rows that kind of underestimate causes bad plans.


explain analyze
with monthly_revenue as (
	select 
		date_trunc('month', o.order_date) as month,
		-->truncates to the first of the month. That's how you group time series data cleanly. 
		sum(od.unit_price * od.quantity * (1 - od.discount)) revenue
	from order_details od 
	join orders o on od.order_id = o.order_id
	group by date_trunc('month', o.order_date)
)
select 
	month,
	revenue,
	Lag(revenue, 1) over (order by month) as prev_month_rev,
	-->Lag gives me the field placed but looking back the amount of time said, in this case 1.
	-->If you were doing this per country or per category you'd add PARTITION BY country ORDER BY month and the rank would reset per country
	ROUND(
    ((revenue - LAG(revenue, 1) OVER (ORDER BY month))
    / LAG(revenue, 1) OVER (ORDER BY month) * 100)::numeric
    -->PostgreSQL ROUND with precision requires ::numeric cast
	, 2) AS mom_growth_pct
from monthly_revenue
order by month

--Estimated rows=480, actual rows=23. This is a bad estimate. PostgreSQL expected 480 monthly buckets, got 23.
--Why? Because DATE_TRUNC on order_date produces a derived column
--PostgreSQL has no statistics on it, only on the raw column. It guessed wrong by 20x.
--Execution was still fast at 0.9ms because the dataset is tiny. 
--On a real table with millions of rows this mismatch would cause PostgreSQL to choose the wrong join 
--strategy or allocate wrong memory.



-- Estimated rows vs actual rows is the most important thing in EXPLAIN ANALYZE.
-- A big mismatch means PostgreSQL is flying blind.
-- Derived columns (DATE_TRUNC, ROUND, expressions) have no statistics —
-- PostgreSQL always guesses on these. In production this causes bad plans.




--Why indexes do nothing on small datasets
--PostgreSQL has two ways to find rows: scan the whole table (Seq Scan), 
--or use an index to jump directly to matching rows (Index Scan).
--The index is only worth using when you're fetching a small percentage of the table. 
--If you have 1 million rows and need 10, an index saves you from reading 999,990 rows. That's the win.
--Northwind has 830 orders and 2155 order_details rows. 
--When PostgreSQL calculates the cost of using an index vs just scanning everything, 
--it looks at the table size and concludes — correctly —
--that reading all 830 rows directly is faster than the overhead of looking up an index first. 
--Sequential reads on small tables beat index lookups every time.
--This is why I told you Wednesday's benchmarking plan was a trap. You'd add the index, see no difference, 
--and either conclude indexes don't work or not learn anything real.
--The rule: indexes matter at scale, not on toy datasets. In production you add indexes on columns you 
--filter or join on frequently, on large tables, when you see Seq Scans with high cost estimates in EXPLAIN ANALYZE.
