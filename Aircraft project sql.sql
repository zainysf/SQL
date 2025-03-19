-- Aircraft Project

-- a. Find the names of aircraft such that all pilots certified to operate them earn more than $80,000.
SELECT aname
  FROM (
        SELECT DISTINCT aid, aname, MIN(salary) OVER (PARTITION BY aid) AS min_sal_by_aid
          FROM aircraft JOIN certified USING (aid)
                        JOIN employees USING (eid)
       )
 WHERE min_sal_by_aid > 80000;

SELECT aname
  FROM aircraft
 WHERE aid IN (SELECT aid
                 FROM certified JOIN employees USING (eid)
               GROUP BY aid
               HAVING MIN(salary) > 80000);
 
-- b. For each pilot who is certified for more than three aircraft, find the eid and the maximum cruising range of the aircraft for which she or he is certified.
SELECT eid, MAX(cruisingrange)
  FROM employees JOIN certified USING (eid)
                 JOIN aircraft USING (aid)
GROUP BY eid
HAVING COUNT(*) > 3;

SELECT eid, max_crg
FROM (
      SELECT DISTINCT
             eid,
             COUNT(*) OVER (PARTITION BY eid) AS cnt_ctf,
             MAX(cruisingrange) OVER (PARTITION BY eid) AS max_crg
        FROM employees JOIN certified USING (eid)
                       JOIN aircraft USING (aid)
     )
WHERE cnt_ctf > 3;

-- c. Find the names of pilots whose salary is less than the price of the cheapest route from Los Angeles to Honolulu.
SELECT ename
  FROM employees
 WHERE salary < ALL (SELECT price
                       FROM flights
                      WHERE origin = 'Los Angeles'
                        AND destination = 'Honolulu');
                        
SELECT ename
  FROM employees
 WHERE salary < (SELECT MIN(price)
                   FROM flights
                  WHERE origin = 'Los Angeles'
                    AND destination = 'Honolulu');

-- d. For all aircraft with cruising range over 1000 miles, find the name of the aircraft and the average salary of all pilots certified for this aircraft.
SELECT DISTINCT
       aname,
       ROUND(AVG(salary) OVER (PARTITION BY aid)) AS avg_sal_by_aid
  FROM employees JOIN certified USING (eid)
                 JOIN aircraft  USING (aid)
 WHERE cruisingrange > 1000;

-- e. Find the names of pilots certified for some Boeing aircraft.
SELECT DISTINCT
       ename
  FROM employees JOIN certified USING (eid)
                 JOIN aircraft  USING (aid)
 WHERE aname LIKE 'Boeing%';
 
SELECT ename
  FROM employees
 WHERE eid IN (SELECT eid
                 FROM certified JOIN aircraft  USING (aid)
                WHERE aname LIKE 'Boeing%');

-- f. Find the aids of all aircraft that can be used on routes from Los Angeles to Chicago.
SELECT aid
  FROM aircraft
 WHERE cruisingrange >= (SELECT MIN(distance) 
                           FROM flights 
                          WHERE origin = 'Los Angeles' 
                            AND destination = 'Chicago');

-- g. Identify the routes that can be piloted by every pilot who makes more than $100,000.
SELECT origin, destination
  FROM flights
 WHERE distance <= (SELECT MIN(max_cr)
                      FROM (
                            SELECT eid, MAX(cruisingrange) AS max_cr
                              FROM aircraft JOIN certified USING (aid)
                                            JOIN employees USING (eid)
                             WHERE salary > 100000
                            GROUP BY eid
                           )
                   );

-- h. Print the enames of pilots who can operate planes with cruising range greater than 3000 miles but are not certified on any Boeing aircraft.
SELECT ename
  FROM employees
 WHERE EXISTS     (SELECT 1
                     FROM certified JOIN aircraft USING(aid)
                    WHERE eid = employees.eid
                      AND cruisingrange > 3000)
   AND NOT EXISTS (SELECT 1
                     FROM certified JOIN aircraft USING(aid)
                    WHERE eid = employees.eid
                      AND aname LIKE 'Boeing%');

-- i. A customer wants to travel from Madison to New York with no more than two changes of flight. List the choice of departure times from Madison if the customer wants to arrive in New York by 6 p.m.
SELECT 0, origin || '/' || destination , departs, arrives 
  FROM flights
 WHERE origin = 'Madison'
   AND destination = 'New York'
   AND TO_NUMBER(TO_CHAR(arrives,'HH24MI')) < 1030
UNION ALL
SELECT 1, f1.origin || '/' || f2.origin || '/' || f2.destination, f1.departs, f2.arrives
  FROM flights f1 JOIN flights f2 ON (f1.destination = f2.origin)
 WHERE f1.origin = 'Madison'
   AND f2.destination = 'New York'
   AND TO_NUMBER(TO_CHAR(f2.arrives,'HH24MI')) < 1030
UNION ALL
SELECT 2, f1.origin || '/' || f2.origin || '/' || f3.origin || '/' || f3.destination, f1.departs, f3.arrives
  FROM flights f1 JOIN flights f2 ON (f1.destination = f2.origin)
                  JOIN flights f3 ON (f2.destination = f3.origin)
 WHERE f1.origin = 'Madison'
   AND f3.destination = 'New York'
   AND TO_NUMBER(TO_CHAR(f3.arrives,'HH24MI')) < 1030;

SELECT 2, f1.origin || '/' || f1.destination || '/' || f2.destination || '/' || f3.destination, f1.departs, coalesce(f3.arrives, f2.arrives, f1.arrives) as arrives
  FROM flights f1 LEFT OUTER JOIN flights f2 ON (f1.destination = f2.origin)
                  LEFT OUTER JOIN flights f3 ON (f2.destination = f3.origin)
 WHERE f1.origin = 'Madison'
   AND (f1.destination = 'New York' or f2.destination = 'New York' or f3.destination = 'New York')
   AND CASE 
          WHEN f2.origin IS NULL THEN TO_NUMBER(TO_CHAR(f1.arrives,'HH24MI'))
          WHEN f3.origin IS NULL THEN TO_NUMBER(TO_CHAR(f2.arrives,'HH24MI'))
          ELSE TO_NUMBER(TO_CHAR(f1.arrives,'HH24MI'))
       END < 1030;
   
-- j. Compute the difference between the average salary of a pilot and the average salary of all employees (including pilots).
SELECT (SELECT AVG(salary) FROM employees INNER JOIN certified USING (eid)) - (SELECT AVG(salary) FROM employees)
  FROM dual;

-- k. Print the name and salary of every non pilot whose salary is more than the average salary for pilots.
SELECT ename, salary
  FROM employees
 WHERE salary > (SELECT AVG(salary) 
                   FROM employees 
                  WHERE eid IN (SELECT eid 
                                  FROM certified))
   AND eid NOT IN (SELECT eid 
                     FROM certified);

-- l. Print the names of employees who are certified only on aircrafts with cruising range longer than 1000 miles.
SELECT ename
  FROM employees INNER JOIN certified USING (eid)
                 INNER JOIN aircraft  USING (aid)
 WHERE cruisingrange > 1000
SELECT ename
  FROM employees INNER JOIN certified USING (eid)
                 INNER JOIN aircraft  USING (aid)
 WHERE cruisingrange <= 1000;

-- m. Print the names of employees who are certified only on aircrafts with cruising range longer than 1000 miles, but on at least two such aircrafts.
SELECT ename, COUNT(*)
  FROM employees INNER JOIN certified USING (eid)
                 INNER JOIN aircraft  USING (aid)
 WHERE cruisingrange > 1000
GROUP BY ename
HAVING COUNT(*) >= 2;

-- n. Print the names of employees who are certified only on aircrafts with cruising range longer than 1000 miles and who are certified on some Boeing aircraft.
SELECT ename 
  FROM (
SELECT ename, 
       MIN(cruisingrange) OVER (PARTITION BY eid) min_cr_by_eid
  FROM employees INNER JOIN certified USING (eid)
                 INNER JOIN aircraft  USING (aid)
       )
 WHERE min_cr_by_eid > 1000

SELECT ename
  FROM employees INNER JOIN certified USING (eid)
                 INNER JOIN aircraft  USING (aid)
 WHERE aname LIKE 'Boeing%'
 
 
-- a) Print the names and ages of each employee who works in both the IT department and the Research department.
SELECT name, age
  FROM emp INNER JOIN works using (eid)
           INNER JOIN dept  using (did)
 WHERE dname = 'IT'

SELECT name, age
  FROM emp INNER JOIN works using (eid)
           INNER JOIN dept  using (did)
 WHERE dname = 'Research';
 
-- b) For each department with more than 3 full-time-equivalent employees (i.e., where the part-time and full-time employees add up to at least that many full-time employees), print the did together with the number of employees that work in that department.
SELECT dname, sum(pct_time), count(*)
  FROM dept INNER JOIN works using (did)
GROUP BY dname
HAVING sum(pct_time) > 3;

-- c) Print the name of each employee whose salary exceeds the budget of all of the departments that he or she works in.
SELECT name
  FROM emp
 WHERE salary > ALL (SELECT budget FROM dept INNER JOIN works USING (did) WHERE eid = emp.eid);
 
-- d) Find the manager ids of managers who manage only departments with budgets greater than 100000.
SELECT managerid, min(budget)
  FROM dept
 GROUP BY managerid
 HAVING min(budget) > 100000;
 
-- e) Find the enames of managers who manage the departments with the largest budgets.
SELECT name, lastname
  FROM (
SELECT name, lastname, RANK() OVER (ORDER BY budget DESC) AS rank_budget
  FROM dept INNER JOIN emp ON (managerid = eid)
  )
WHERE rank_budget = 1;

-- f) If a manager manages more than one department, he or she controls the sum of all the budgets for those departments. Find the manager ids of managers who control more than 200 000.
SELECT * FROM (
SELECT managerid, 
       COUNT(*) OVER (PARTITION BY managerid) AS count_dept, 
       SUM(budget) OVER (PARTITION BY managerid) AS sum_budget
  FROM dept
)
WHERE count_dept > 1
  AND sum_budget > 200000;


-- h) Find the enames of managers who manage only departments with budgets larger than 100000, but at least one department with budget less than 200000.
SELECT name, lastname
  FROM emp
 WHERE eid IN (SELECT managerid
                 FROM dept
               GROUP BY managerid
               HAVING MIN(budget) > 100000)
   AND eid IN (SELECT managerid
                 FROM dept
                WHERE budget < 200000);
 
