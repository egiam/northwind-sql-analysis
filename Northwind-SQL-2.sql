--Simmilar to a VENN diagram:
--	INNER — only the overlapping middle
--	LEFT — entire left circle + middle (NULLs for right side where no match)
--	RIGHT — entire right circle + middle (NULLs for left side where no match)
--	FULL OUTER — both entire circles including the middle, NULLs wherever there's no match
--	Anti-join — left circle only, explicitly excluding the middle (LEFT JOIN WHERE NULL)


--INNER — Orders with their assigned employees (only matched orders)
select o.order_id, o.order_date, o.customer_id, e.first_name || ' ' || e.last_name AS employee
from orders o
inner join employees e on o.employee_id = e.employee_id;

--INNER — Products with their categories and suppliers in one query
select p.product_name, c.category_name, s.company_name 
from products p 
inner join categories c on p.category_id = c.category_id
inner join suppliers s on p.supplier_id = s.supplier_id;

--LEFT — All customers, including those who have never placed an order
select c.company_name, o.order_id 
from customers c 
left join orders o on c.customer_id = o.customer_id;

--LEFT — All products, including those that have never been ordered
select p.product_name, od.order_id 
from products p 
left join order_details od on p.product_id = od.product_id;

--RIGHT — All employees, including those who've never processed an order
select e.first_name  || ' ' || e.last_name as Full_name, o.order_id 
from orders o 
right join employees e on o.employee_id = e.employee_id;

--FULL OUTER — All customers and all orders, showing unmatched rows on both sides
select c.company_name, o.order_id 
from customers c 
full outer join orders o on c.customer_id = o.customer_id;

--Anti-join — Customers who have never ordered
select c.company_name, o.order_id 
from customers c 
left join orders o on c.customer_id = o.customer_id
where o.order_id is null;

--Anti-join — Products that have never appeared in any order
select p.product_name, od.order_id 
from products p 
left join order_details od on p.product_id = od.product_id 
where od.order_id is null;


