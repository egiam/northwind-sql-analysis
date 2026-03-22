--WHERE filters rows before grouping happens. It never sees aggregated values.
--HAVING filters groups after aggregation. It only exists because WHERE can't touch aggregated values.


--COUNT — Number of orders per customer
select c.company_name, count(o.order_id) as Qty_orders
from customers c 
join orders o on c.customer_id = o.customer_id
group by c.company_name;


--COUNT + HAVING — Customers who have placed more than 5 orders
select c.company_name, count(o.order_id) as Qty_orders
from customers c
join orders o on c.customer_id = o.customer_id
group by c.company_name 
having count(o.order_id) > 5


--SUM — Total revenue per year
select EXTRACT(YEAR FROM o.order_date ) as year, SUM(od.unit_price * od.quantity * (1 - od.discount)) as revenue
from order_details od 
join orders o on od.order_id = o.order_id
group by "year"

--SUM + HAVING — Product categories that have generated more than $100,000 in revenue
select c.category_name, SUM(od.unit_price * od.quantity * (1 - od.discount)) as revenue
from products p 
join categories c on p.category_id = c.category_id
join order_details od on p.product_id = od.product_id
group by c.category_name 
having SUM(od.unit_price * od.quantity * (1 - od.discount)) > 100000

--AVG — Average order value per employee
select e.first_name || ' ' || e.last_name as employee_name, AVG(od.revenue_per_order) as avg_order_value
from employees e 
join orders o on e.employee_id = o.employee_id
join (select order_id, SUM(unit_price * quantity * (1 - discount)) as revenue_per_order from order_details group by order_id ) od on o.order_id = od.order_id
group by e.first_name, e.last_name 

--AVG + HAVING — Employees whose average order value exceeds the overall average
select e.first_name || ' ' || e.last_name as employee_name, AVG(od.revenue_per_order) as avg_order_value
from employees e 
join orders o on e.employee_id = o.employee_id
join (
	select order_id, SUM(unit_price * quantity * (1 - discount)) as revenue_per_order 
	from order_details 
	group by order_id 
	) od on o.order_id = od.order_id
group by e.first_name, e.last_name 
having AVG(od.revenue_per_order) > (
	select AVG(ot.revenue_per_order) as avg_order_value
	from (
		select order_id, SUM(unit_price * quantity * (1 - discount)) as revenue_per_order 
		from order_details 
		group by order_id 
		) ot
	)

--MIN / MAX — Earliest and latest order date per customer
select c.company_name, min(o.order_date ) as earliest_order, max(o.order_date ) as latest_order
from customers c
join orders o on c.customer_id = o.customer_id
group by c.company_name 

--MIN/MAX price per category (product names require window functions -- revisit later)
select c.category_name, min(p.unit_price) as cheapest, max(p.unit_price) as most_expensive
from products p 
join categories c on p.category_id = c.category_id
group by c.category_name 

--MIN / MAX — Price range per category with product count
select c.category_name, min(p.unit_price) as cheapest, max(p.unit_price) as most_expensive, count(p.product_id) as total_products
from categories c 
join products p on c.category_id = p.category_id
group by c.category_name 

--COUNT + SUM combined — Number of orders and total revenue per country
select o.ship_country, count(o.order_id ) as Qty_orders, SUM(unit_price * quantity * (1 - discount)) as revenue
from orders o
join order_details od on o.order_id = od.order_id
group by o.ship_country 

--Multi-level HAVING — Suppliers with more than 3 products that have generated over $50,000 in total revenue
select s.company_name, count(p.product_id) as qty_products, SUM(od.unit_price * od.quantity * (1 - od.discount)) as revenue
from suppliers s 
join products p on s.supplier_id = p.supplier_id
join order_details od on od.product_id = p.product_id 
group by s.company_name 
having count(p.product_id) > 3 and SUM(od.unit_price * od.quantity * (1 - od.discount)) > 50000



