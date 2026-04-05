
--1. Top 10 customers by total revenue
select 
	c.company_name,
	sum(unit_price * quantity * (1 - discount)) revenue
from customers c
join orders o on c.customer_id = o.customer_id
join order_details od on o.order_id = od.order_id
group by c.company_name
order by revenue desc
limit 10

--2. Month-over-month order growth (use window functions)
with orders_qty as (
	select
		date_trunc('month', order_date) as month,
		count(order_id) as qty_ord
	from orders
	group by date_trunc('month', order_date)
	)
select
	month,
	qty_ord,
	lag(qty_ord, 1) over(order by month) as prev_month_qty,
	round(
		((qty_ord - lag(qty_ord, 1) over(order by month))::numeric / lag(qty_ord, 1) over(order by month) * 100), 2
		) as mom_gwt_qty
from orders_qty	

--3. Which product categories are declining vs growing?
--"declining vs growing" means revenue per category per year, then compare years. 
--Usar with (CTE), Case, lag
with revenue_cat_yearly as (
	select
		c.category_name,
		date_trunc('year', o.order_date) as year,
		sum(od.unit_price * od.quantity * (1 - od.discount)) revenue
	from order_details od 
	join products p on od.product_id = p.product_id
	join categories c on p.category_id = c.category_id
	join orders o on o.order_id = od.order_id 
	group by c.category_name, date_trunc('year', o.order_date)
	order by c.category_name asc, "year" asc
)
select
	category_name,
	year,
	revenue,
	lag(revenue, 1) over(partition by category_name order by year) as prev_year,
	round(
		((revenue - lag(revenue, 1) over(partition by category_name order by year)) / lag(revenue, 1) over(partition by category_name order by year) * 100)::numeric, 2
	) as mom_gwt_rev,
	case
		when round(
		((revenue - lag(revenue, 1) over(partition by category_name order by year)) / lag(revenue, 1) over(partition by category_name order by year) * 100)::numeric, 2
	) > 0 then 'Growing'
		when round(
		((revenue - lag(revenue, 1) over(partition by category_name order by year)) / lag(revenue, 1) over(partition by category_name order by year) * 100)::numeric, 2
	) < 0 then 'Declining'
	else
		'N/A'
	end as trend
from revenue_cat_yearly
group by category_name, year, revenue

--Most efficient/redeable way to handle this duplication of round's:
with revenue_cat_yearly as (
	select
		c.category_name,
		date_trunc('year', o.order_date) as year,
		sum(od.unit_price * od.quantity * (1 - od.discount)) revenue
	from order_details od 
	join products p on od.product_id = p.product_id
	join categories c on p.category_id = c.category_id
	join orders o on o.order_id = od.order_id 
	group by c.category_name, date_trunc('year', o.order_date)
	order by c.category_name asc, "year" asc
), category_growth as (
    select
        category_name,
        year,
        revenue,
        lag(revenue, 1) over(partition by category_name order by year) as prev_year_rev,
        round(
            ((revenue - lag(revenue, 1) over(partition by category_name order by year)) 
            / lag(revenue, 1) over(partition by category_name order by year) * 100)::numeric, 2
        ) as yoy_growth_pct
    from revenue_cat_yearly
)
select
    category_name,
    year,
    revenue,
    prev_year_rev,
    yoy_growth_pct,
    case
        when yoy_growth_pct > 0 then 'Growing'
        when yoy_growth_pct < 0 then 'Declining'
        else 'N/A'
    end as trend
from category_growth

--4. Average order value by country
with avg_order_val as (
	select
	order_id, 
		sum(unit_price * quantity * (1 - discount)) as value
	from order_details
	group by order_id
)
select
	o.ship_country,
	avg(a.value ) as avg_value
from orders o 
join avg_order_val a on o.order_id = a.order_id
group by o.ship_country 


--5. Which employees have the highest sales this year vs last year?
--Treating 1998 as current year and 1997 as last year. 
with sales_year as (
	select
		e.first_name || ' ' || e.last_name as employee,
		sum(unit_price * quantity * (1 - discount)) as revenue,
		date_trunc('year', o.order_date) as year
	from employees e 
	join orders o on o.employee_id = e.employee_id 
	join order_details od on o.order_id = od.order_id
	group by e.first_name, e.last_name, date_trunc('year', o.order_date)
)
select
	employee,
	year,
	revenue,
	lag(revenue, 1) over(partition by employee order by year) as last_year_rev
from sales_year
where year > '1996-01-01'
order by revenue desc, last_year_rev desc
--Fine start, bad finisher...

--Better one:
with sales_year as (
	select
		e.first_name || ' ' || e.last_name as employee,
		sum(unit_price * quantity * (1 - discount)) as revenue,
		date_trunc('year', o.order_date) as year
	from employees e 
	join orders o on o.employee_id = e.employee_id 
	join order_details od on o.order_id = od.order_id
	group by e.first_name, e.last_name, date_trunc('year', o.order_date)
), sales_comparison as (
    select
        employee,
        year,
        revenue,
        lag(revenue, 1) over(partition by employee order by year) as last_year_rev
    from sales_year
    where year > '1996-01-01'
)
select
    employee,
    revenue as current_year_rev,
    last_year_rev
from sales_comparison
where year = '1998-01-01'
order by current_year_rev desc

