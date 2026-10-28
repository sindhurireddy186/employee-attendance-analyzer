-- SQLite
-- Query 1: Top 10 employees by total working hours
SELECT
    e.employee_id,
    e.employee_name,
    ROUND(
        SUM(
            (CAST(substr(a.logout_time, 1, 2) AS INTEGER) * 60
             + CAST(substr(a.logout_time, 4, 2) AS INTEGER))
            -
            (CAST(substr(a.login_time, 1, 2) AS INTEGER) * 60
             + CAST(substr(a.login_time, 4, 2) AS INTEGER))
        ) / 60.0,
        2
    ) AS total_working_hours
FROM employees e
JOIN attendance a
    ON e.employee_id = a.employee_id
WHERE a.status = 'Present'
GROUP BY e.employee_id, e.employee_name
ORDER BY total_working_hours DESC
LIMIT 10;

SELECT name
FROM sqlite_master
WHERE type ='table';