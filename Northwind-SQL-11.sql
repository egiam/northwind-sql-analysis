--5 Medium StrataScratch problems.


--Calculate the percentage of users who are both from the US and have an 'open' status, 
--as indicated in the fb_active_users table.

with users_us as (
    select count(user_id) qty_users_us
    from fb_active_users
    where country = 'USA' and status = 'open'
)
select
    round(
    (max(u.qty_users_us)::numeric / count(f.user_id) * 100), 2
    ) as percentage
from fb_active_users f
cross join users_us u


--Optimal solution:
SELECT SUM(CASE
               WHEN country = 'USA'
                    AND status = 'open' THEN 1
               ELSE 0
           END) * 100.0 / COUNT(*) AS us_active_share
FROM fb_active_users;

--for every row it asks "is this user from the USA with open status?" If yes, return 1. 
--If no, return 0. Then SUM() adds up all the 1s — that's your count of matching users. 
--Divide by COUNT(*) which is total users, multiply by 100.


---


--Given a single column of numbers, consider all possible permutations of two numbers with replacement, 
--assuming that pairs of numbers (x,y) and (y,x) are two different permutations. 
--Then, for each permutation, find the maximum of the two numbers.
--Output three columns: the first number, the second number and the maximum of the two.

select
    a.number,
    b.number,
    greatest(a.number, b.number) as maximum
from deloitte_numbers a
cross join deloitte_numbers b


SELECT dn1.number AS number1,
       dn2.number AS number2,
       CASE
           WHEN dn1.number > dn2.number THEN dn1.number
           ELSE dn2.number
       END AS max_number
FROM deloitte_numbers AS dn1
CROSS JOIN deloitte_numbers AS dn2


--table with one column of numbers
--"All permutations of two numbers with replacement" means pair every number with every other number, including itself
--		(1,1), (1,2), (1,3)
--		(2,1), (2,2), (2,3)
--		(3,1), (3,2), (3,3)

--"With replacement" means a number can pair with itself — so (1,1) is valid
--Then for each pair, just show the maximum of the two numbers
--GREATEST() is a PostgreSQL function that returns the largest value from a list of arguments. 
--Same as MAX() but for comparing columns within the same row rather than across rows.


---


--For each video, find how many unique users flagged it. A unique user can be identified using the 
--combination of their first name and last name. Do not consider rows in which there is no flag ID.

select
    count(DISTINCT (Concat(user_firstname, ' ', user_lastname))) as unique_users,
    video_id
from user_flags
where flag_id is not null
group by video_id



WITH unique_users AS
  (SELECT video_id,
          CONCAT(COALESCE(user_firstname, ''), COALESCE(user_lastname, '')) AS user_identifier
   FROM user_flags
   WHERE flag_id IS NOT NULL)
SELECT video_id,
       COUNT(DISTINCT user_identifier) AS num_unique_users
FROM unique_users
GROUP BY video_id;
-- COALESCE still recommended if NULLs exist



---

--Write a query to get the list of managers whose salary is less than twice the average salary of employees 
--reporting to them. For these managers, output their ID, salary and the average salary of employees reporting to them.

--WRONG APPROACH MINE
with avg_salary as (
    select avg(salary) as avg_sal
    from dim_employee
    )
select 
    d.empl_name,
    d.salary,
    avg_sal
from dim_employee d
join map_employee_hierarchy m on d.empl_id = m.empl_id
cross join avg_salary
where salary < avg_sal * 2 and manager_empl_id is not null
--WHat i did wrong:
--I joined the hierarchy table once and got a global average. I never separated the manager role from the employee role. 

--REAL APPROACH ANSWER
SELECT h.manager_empl_id,
       managers.salary AS manager_salary,
       AVG(employees.salary) AS avg_employee_salary
FROM map_employee_hierarchy h
JOIN dim_employee managers ON h.manager_empl_id = managers.empl_id
JOIN dim_employee employees ON h.empl_id = employees.empl_id
GROUP BY 1,2
HAVING managers.salary < 2 * AVG(employees.salary)

--The hierarchy table has two columns — manager_empl_id and empl_id. They join dim_employee twice with 
--different aliases. Once to get the manager's data, once to get the employee's data. 
--Same table, two roles, two aliases.



---


--The workforce planning team is analyzing department growth since the company's expansion, 
--focusing on teams that have grown substantially.
--For each department with 5 or more employees hired after 2020, return the name, headcount, total payroll, and average salary.

select
    count(id) as new_hires,
    department,
    sum(salary) as total_payroll,
    avg(salary) as avg_slry
from techcorp_workforce
where joining_date > '2020/12/31'
group by department
having count(id) > 4

--
SELECT
    department,
    COUNT(*) AS headcount,
    SUM(salary) AS total_payroll,
    AVG(salary) AS avg_salary
FROM techcorp_workforce
WHERE joining_date > '2020-12-31'
GROUP BY department
HAVING COUNT(*) >= 5;






