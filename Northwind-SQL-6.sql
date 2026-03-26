

--Find the inspection date and risk category (pe_description) of facilities named 'STREET CHURROS' that received a score below 95.

select 
    activity_date,
    pe_description
from los_angeles_restaurant_health_inspections
where facility_name = 'STREET CHURROS' and score < 95


--Find the number of employees working in the Admin department that joined in April or later, in any year.
select count(worker_id)
from worker
where Extract(month from joining_date) > 3 and department = 'Admin'

-- Other solutions:
SELECT COUNT(*) AS n_admins
FROM worker
WHERE lower(department) LIKE 'admin'
  AND EXTRACT(MONTH
              FROM joining_date) >= 4
              
SELECT COUNT(DISTINCT(worker_id)) as n_admins
FROM worker
WHERE department ILIKE 'Admin'
    AND EXTRACT(MONTH FROM joining_date) >= 4
    

--Find the number of workers by department who joined on or after April 1, 2014.
--Output the department name along with the corresponding number of workers.
--Sort the results based on the number of workers in descending order.
select department, count(worker_id) as Qty_workers
from worker
where joining_date >= '04/01/2014'
group by department
order by count(worker_id) desc


-- Other solutions:
WITH filtered_worker AS (
    SELECT *
    FROM worker
    WHERE joining_date >= DATE '2014-04-01'
)

SELECT department,
       COUNT(worker_id) AS num_workers
FROM filtered_worker
GROUP BY department
ORDER BY num_workers desc








