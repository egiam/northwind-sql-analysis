
--Build a query with exactly 3 CTEs:
--	CTE 1 — monthly revenue
--	CTE 2 — previous month revenue using LAG
--	CTE 3 — calculates MoM growth percentage
--
--Final SELECT should show: month, revenue, prev_month_revenue, mom_growth_pct


with month_revenue as (
	select 
		date_trunc('month', o.order_date) as month_rev,
		sum(od.unit_price * od.quantity * (1 - od.discount)) as revenue
	from order_details od 
	join orders o on od.order_id = o.order_id
	group by date_trunc('month', o.order_date)
	), prev_month_rev as (
	select 
		month_rev,
		revenue,
		lag(revenue, 1) over(order by month_rev) as prev_month_lag
	from month_revenue
	), mom_growth_percentage as (
	select 
		month_rev,
		revenue,
		prev_month_lag,
		round(
		((revenue - prev_month_lag) / prev_month_lag * 100)::numeric, 2
		) as mom_growth_pct
	from prev_month_rev 
	)
select 
	month_rev,
	revenue,
	prev_month_lag,
	mom_growth_pct
from mom_growth_percentage 





