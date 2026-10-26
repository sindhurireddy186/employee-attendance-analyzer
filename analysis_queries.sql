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


-- 2. Employees with the most late arrivals
SELECT
    e.employee_id,
    e.employee_name,
    COUNT(*) AS late_arrivals
FROM employees e
JOIN attendance a
    ON e.employee_id = a.employee_id
WHERE a.status = 'Present'
  AND a.login_time > '09:15:00'
GROUP BY e.employee_id, e.employee_name
ORDER BY late_arrivals DESC
LIMIT 10;

-- 3. Attendance percentage by department
SELECT
    d.department_name,
    ROUND(
        100.0 * SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS attendance_percentage
FROM departments d
JOIN employees e
    ON d.department_id = e.department_id
JOIN attendance a
    ON e.employee_id = a.employee_id
GROUP BY d.department_id, d.department_name
ORDER BY attendance_percentage DESC;

-- 4. Monthly attendance trends
SELECT
    strftime('%Y-%m', attendance_date) AS attendance_month,
    COUNT(*) AS total_records,
    SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) AS present_days,
    SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END) AS absent_days,
    ROUND(
        100.0 * SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS attendance_percentage
FROM attendance
GROUP BY strftime('%Y-%m', attendance_date)
ORDER BY attendance_month;

-- 5. Employees absent for 3 or more consecutive calendar days
WITH absence_dates AS (
    SELECT
        employee_id,
        attendance_date,
        LAG(attendance_date, 1) OVER (
            PARTITION BY employee_id ORDER BY attendance_date
        ) AS previous_date,
        LAG(attendance_date, 2) OVER (
            PARTITION BY employee_id ORDER BY attendance_date
        ) AS two_days_before
    FROM attendance
    WHERE status = 'Absent'
)
SELECT
    e.employee_id,
    e.employee_name,
    attendance_date
FROM absence_dates ad
JOIN employees e
    ON e.employee_id = ad.employee_id
WHERE julianday(ad.attendance_date) - julianday(ad.previous_date) = 1
  AND julianday(ad.previous_date) - julianday(ad.two_days_before) = 1
ORDER BY e.employee_id, attendance_date;

-- 6. Find duplicate attendance records in the import staging table
SELECT
    employee_id,
    attendance_date,
    COUNT(*) AS duplicate_count
FROM attendance_import
GROUP BY employee_id, attendance_date
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
-- 7. Employees who worked on weekends
SELECT
    e.employee_id,
    e.employee_name,
    COUNT(*) AS weekend_workdays
FROM employees e
JOIN attendance a
    ON e.employee_id = a.employee_id
WHERE a.status = 'Present'
  AND strftime('%w', a.attendance_date) IN ('0', '6')
GROUP BY e.employee_id, e.employee_name
ORDER BY weekend_workdays DESC
LIMIT 10;

-- 8. Average login and logout times by department
SELECT
    d.department_name,
    ROUND(AVG(
        CAST(substr(a.login_time, 1, 2) AS INTEGER) * 60 +
        CAST(substr(a.login_time, 4, 2) AS INTEGER)
    ), 2) AS avg_login_minutes,
    ROUND(AVG(
        CAST(substr(a.logout_time, 1, 2) AS INTEGER) * 60 +
        CAST(substr(a.logout_time, 4, 2) AS INTEGER)
    ), 2) AS avg_logout_minutes
FROM departments d
JOIN employees e
    ON d.department_id = e.department_id
JOIN attendance a
    ON e.employee_id = a.employee_id
WHERE a.status = 'Present'
GROUP BY d.department_id, d.department_name
ORDER BY d.department_name;
