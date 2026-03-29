
--LAG looks back. LEAD looks forward. Both let you access a value from a different row without a self-join. 
--The most common use case in analytics is exactly what you're building today
--comparing a period to the previous period.

LAG(column, offset, default) OVER (PARTITION BY ... ORDER BY ...)


LAG(expression [, offset [, default_value]]) 
OVER (
    [PARTITION BY partition_expression, ... ]
    ORDER BY sort_expression [ASC | DESC], ...
)

--Build a query showing month-over-month revenue change using LAG
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


--Build a query showing month-over-month revenue change using LEAD
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
	Lead(revenue, 1) over (order by month) as next_month_rev,
	-->LEAD is useful when you want to calculate time to next event
	ROUND(
    ((revenue - lead(revenue, 1) OVER (ORDER BY month))
    / lead(revenue, 1) OVER (ORDER BY month) * 100)::numeric
    -->PostgreSQL ROUND with precision requires ::numeric cast
	, 2) AS mom_growth_pct_lead
from monthly_revenue
order by month



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
	sum(revenue) over(order by month) as running_total
	-- SUM() OVER (ORDER BY col) = running total
	-- Default frame: ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	-- You rarely need to write the frame explicitly, but you need to know it exists
from monthly_revenue
order by month

