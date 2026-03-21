
--1. What is the product that most customers bought (maybe ranked, not top 1)
--select p.product_name, p.product_id, count(p.product_id )
--from products p 
--join order_details od on p.product_id = od.product_id
--group by p.product_name, p.product_id 
--order by count(od.product_id ) desc;

SELECT p.product_name, p.product_id, COUNT(DISTINCT o.customer_id) AS customer_count
FROM products p
JOIN order_details od ON p.product_id = od.product_id
JOIN orders o ON od.order_id = o.order_id
GROUP BY p.product_name, p.product_id
ORDER BY customer_count DESC;

--2. What employee sold the most
select e.first_name || ' ' || e.last_name as Employee, COUNT(o.order_id) as orders_sold
from employees e join orders o on e.employee_id = o.employee_id
group by e.first_name, e.last_name
order by orders_sold desc;

--3. From which suppliers come the most sold (by volume)
select s.company_name, SUM(od.quantity) as Volume_product
from suppliers s 
join products p on s.supplier_id = p.supplier_id
join order_details od on p.product_id = od.product_id 
group by s.company_name 
order by volume_product desc;

select * from order_details od

--4. Top performing products by revenue
select p.product_name, SUM(od.quantity * od.unit_price * (1 - od.discount)) as revenue
from products p
join order_details od on p.product_id = od.product_id
group by p.product_name 
order by revenue desc; 

--5. Customers who haven't ordered in 3 months (1 quarter)
select MAX(o.order_date ) as last_order, c.company_name 
from customers c
join orders o on c.customer_id = o.customer_id
group by c.company_name 
having MAX(o.order_date) < (SELECT MAX(order_date) FROM orders) - INTERVAL '3 months'
order by last_order desc

--6. Employee performance by revenue generated
select e.first_name || ' ' || e.last_name as Employee, SUM(od.quantity * od.unit_price * (1 - od.discount)) as revenue
from employees e 
join orders o on e.employee_id = o.employee_id
join order_details od on od.order_id = o.order_id 
group by e.first_name, e.last_name
order by revenue desc;

--7. Which product categories drive the most revenue
select c.category_name, SUM(od.quantity * od.unit_price * (1 - od.discount)) as revenue
from products p 
join order_details od on p.product_id = od.product_id
join categories c on p.category_id = c.category_id
group by c.category_name 
order by revenue desc;

--8.  Most profitable cities
select c.city, SUM(od.quantity * od.unit_price * (1 - od.discount)) as revenue
from customers c 
join orders o on c.customer_id = o.customer_id
join order_details od on o.order_id = od.order_id
group by c.city 
order by revenue desc;

--9. The highest revenue suppliers
select s.company_name, SUM(od.quantity * od.unit_price * (1 - od.discount)) as revenue
from suppliers s
join products p on s.supplier_id = p.supplier_id
join order_details od on p.product_id = od.product_id
group by s.company_name 
order by revenue desc;

--10. Customers ranked by average order value
select c.company_name, AVG(order_total) AS avg_order_value
from customers c
join orders o on c.customer_id = o.customer_id
join (
    SELECT order_id, SUM(quantity * unit_price * (1 - discount)) AS order_total
    FROM order_details
    GROUP BY order_id
) od ON o.order_id = od.order_id
group by c.company_name 
order by avg_order_value desc;









