
--A window function doesn't collapse rows like GROUP BY does. The row stays. 
--The calculation happens across a defined set of rows relative to the current one. 
--That's the whole idea. If you can't explain that in one sentence to an interviewer, you don't have it yet.

--GROUP BY collapses. PARTITION BY scopes without collapsing. Write that somewhere physical.

--GROUP BY collapses individual records into summary rows, reducing the total number of rows, 
--while PARTITION BY performs calculations over a defined set of rows (a "window") 
--but retains all original rows in the result set


--Window functions: ROW_NUMBER(), RANK(), DENSE_RANK()
--these three window functions are the go-to tools for ranking rows within a specific set. 
--While they all assign a number to rows based on a sorted order, 
--they handle "ties" (rows with the same value) differently.

--Rank customers by total revenue — using all three functions
SELECT
    customer_id,
    SUM(unit_price * quantity * (1 - discount)) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(unit_price * quantity * (1 - discount)) DESC) AS row_num,
    RANK()       OVER (ORDER BY SUM(unit_price * quantity * (1 - discount)) DESC) AS rnk,
    DENSE_RANK() OVER (ORDER BY SUM(unit_price * quantity * (1 - discount)) DESC) AS dense_rnk
FROM order_details od
JOIN orders o ON od.order_id = o.order_id
GROUP BY customer_id;

--OVER() with nothing inside it means "look at every row in the result." 
--OVER(PARTITION BY country) would mean "look only at rows with the same country as the current row." 
--OVER(ORDER BY revenue DESC) means "order the rows by revenue when assigning the rank."

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

--The spot where two customers share the same revenue_bucket. That's where:
--
--ROW_NUMBER still gives them different numbers — it breaks ties arbitrarily
--RANK gives both rank 3 (or whatever), then skips to 5
--DENSE_RANK gives both rank 3, then continues with 4

--Rank products by quantity sold
with product_qty_sold as (
	select p.product_name, sum(od.quantity) as qty_sold
	from products p
	join order_details od on p.product_id = od.product_id
	group by p.product_name 
)
select
	product_name,
	row_number() over (order by qty_sold desc) as row_num, 
	-->Its giving me just the number, doesnt matter if it has simmilar rows or not
	rank() over(order by qty_sold desc) as rnk, 
	-->Its giving me the rank, and when it finds rows that have the same / simmilar concept, it returns the same rank till that doesnt happen, and then it skips tille the row num is correct. Ex: 1, 2, 3, 3, 3, 6
	dense_rank() over(order by qty_sold desc) as dense_rnk 
	-->Its giving me the rank, and when it finds rows that have the same / simmilar concept, it returns the same rank till that doesnt happen, and then it continues with the next number. Ex: 1, 2, 3, 3, 3, 4
from product_qty_sold

--Rank customers by revenue within each country -- ADD Partition BY
with customer_revenue as (
	select
		c.company_name,
		c.country,
		sum(od.unit_price * od.quantity * (1 - od.discount)) as revenue
	from customers c
	join orders o on c.customer_id = o.customer_id
	join order_details od on o.order_id = od.order_id
	group by c.country, c.company_name
)
select
	company_name,
	country,
	rank() over(partition by country order by revenue desc) as rnk
	-->PARTITION BY scopes the window to the current country. ORDER BY inside the OVER tells it how to assign the rank within that scope. 
from customer_revenue

--The comparison query (Rewrite last query as a GROUP BY)
with customer_revenue as (
	select
		c.company_name,
		c.country,
		sum(od.unit_price * od.quantity * (1 - od.discount)) as revenue
	from customers c
	join orders o on c.customer_id = o.customer_id
	join order_details od on o.order_id = od.order_id
	group by c.country, c.company_name
)
SELECT
    c1.company_name,
    c1.country,
    COUNT(c2.company_name) + 1 AS rnk
FROM customer_revenue c1
JOIN customer_revenue c2 
    ON c1.country = c2.country 
    AND c2.revenue > c1.revenue
GROUP BY c1.company_name, c1.country, c1.revenue

-- GROUP BY collapses rows — you cannot rank within groups without either
-- a window function (PARTITION BY) or a self-join hack.
-- PARTITION BY scopes the window without collapsing rows, which is why
-- window functions exist. 
--> This is a core difference I may see in an interview.




