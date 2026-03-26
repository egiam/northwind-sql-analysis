
--Write a query that returns the number of unique users per client for each month. 
--Assume all events occur within the same year, so only month needs to be be in the output as a number from 1 to 12.

SELECT client_id, 
       EXTRACT(MONTH FROM time_id) AS month, 
       COUNT(DISTINCT user_id) AS unique_users
FROM fact_events
GROUP BY client_id, EXTRACT(MONTH FROM time_id)
ORDER BY client_id, month;
-- MY ERROR: i was writing just group by time_id instead of doing the whole setup. This was building it in a wrong setting



--Write a query that will calculate the number of shipments per month. 
--The unique key for one shipment is a combination of shipment_id and sub_id. 
--Output the year_month in format YYYY-MM and the number of shipments in that month.
select count(shipment_id + sub_id) as Total_shipments, TO_CHAR(DATE_TRUNC('month', shipment_date), 'YYYY-MM') AS month
from amazon_shipment
group by TO_CHAR(DATE_TRUNC('month', shipment_date), 'YYYY-MM')


--Better solution:
SELECT
    TO_CHAR(shipment_date, 'YYYY-MM') AS yyyy_mm,
    COUNT(CONCAT(shipment_id, sub_id)) AS uniq_key
FROM amazon_shipment
GROUP BY
    yyyy_mm


--or 
    
SELECT to_char(shipment_date, 'YYYY-MM') AS year_month,
       count(distinct (shipment_id, sub_id))
FROM amazon_shipment
GROUP BY 1



--Find the average number of bathrooms and bedrooms for each city’s property types. 
--Output the result along with the city name and the property type.


select
    AVG(bathrooms) as AVG_bath,
    AVG(bedrooms) as AVG_bed,
    city,
    property_type
from airbnb_search_details
group by
    city,
    property_type

--Count the number of user events performed by MacBookPro users.
--Output the result along with the event name.
--Sort the result based on the event count in the descending order.
    
select
    count(user_id) as Qty_events,
    event_name
from playbook_events
where device = 'macbook pro'
group by 
    event_name
order by count(user_id) desc


SELECT event_name,
       count(*) AS event_count
FROM playbook_events
WHERE device = 'macbook pro'
GROUP BY event_name
ORDER BY event_count desc




--Find the most profitable company from the financial sector. Output the result along with the continent.

select 
    company,
    continent
from forbes_global_2010_2014
where sector = 'Financials'
group by company, continent
having max(profits) >= (select max(profits) from forbes_global_2010_2014 where sector = 'Financials')

--real result
WITH max_profits AS
  (SELECT MAX(profits) AS max_profit
   FROM forbes_global_2010_2014
   WHERE sector = 'Financials')
SELECT company,
       continent
FROM forbes_global_2010_2014
JOIN max_profits ON forbes_global_2010_2014.profits = max_profits.max_profit
WHERE sector = 'Financials';

--result from others:
select company,continent,profits as most_profitble
from forbes_global_2010_2014
where sector='Financials'
order by profits desc
limit 1

select company,continent from forbes_global_2010_2014 where sector = 'Financials'
and profits = (select max(profits) from forbes_global_2010_2014 where sector = 'Financials');






    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    