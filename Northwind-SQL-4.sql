
--A CTE (Common Table Expression) is a temporary named result set you define at the top of a query and reference below it. It exists only for the duration of that single query — it's not stored anywhere.
--
--WITH cte_name AS (
--    SELECT ...
--)
--SELECT * FROM cte_name;
--
--View — stored permanently in the database, reusable across queries
--Stored Procedure — stored logic that executes on demand
--CTE — temporary, lives only inside one query, invisible to everything else
--
--Why it exists:
--Query 6 from Northwind-SQL-3 where it has the same subquery twice. A CTE lets you write it once, name it, and reference it multiple times in the same query. It also makes complex queries readable — instead of nested subqueries inside subqueries, you stack named CTEs on top and the final SELECT reads like plain English.
--The honest difference between CTE and subquery:
--They often produce identical execution plans. CTEs are not faster. The advantage is purely readability and maintainability — which in a team environment is everything.


-- Find all customers whose total spending is above the average customer spending
--Version 1 — Subquery
select c.company_name, sum(od.revenue_per_order ) as total_spending
from customers c 
join orders o on c.customer_id = o.customer_id
join (
	select order_id, SUM(unit_price * quantity * (1 - discount)) as revenue_per_order 
	from order_details 
	group by order_id 
	) od on o.order_id = od.order_id
group by c.company_name
having sum(od.revenue_per_order ) > (
	select AVG(ot.revenue_per_order) as avg_order_value
	from (
		select order_id, SUM(unit_price * quantity * (1 - discount)) as revenue_per_order 
		from order_details 
		group by order_id 
		) ot
	)

--Version 2 — CTE
with cte_revenue as (
	select order_id, SUM(unit_price * quantity * (1 - discount)) as revenue_per_order 
	from order_details 
	group by order_id 
	)
select c.company_name, sum(od.revenue_per_order ) as total_spending
from customers c 
join orders o on c.customer_id = o.customer_id
join cte_revenue od on o.order_id = od.order_id
group by c.company_name
having sum(od.revenue_per_order ) > (
	select AVG(ot.revenue_per_order) as avg_order_value
	from cte_revenue ot
	)

	
--Version 3 — JOIN
SELECT c.company_name, customer_totals.total_spending
FROM customers c
JOIN (
    SELECT o.customer_id, 
           SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_spending
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.customer_id
) customer_totals ON c.customer_id = customer_totals.customer_id
JOIN (
    SELECT AVG(total_spending) AS avg_spending
    FROM (
        SELECT o.customer_id, 
               SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_spending
        FROM orders o
        JOIN order_details od ON o.order_id = od.order_id
        GROUP BY o.customer_id
    ) t
) avg_totals ON customer_totals.total_spending > avg_totals.avg_spending
ORDER BY total_spending DESC;





