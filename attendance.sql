
-- Employee Attendance Analyzer
-- Database: SQLite

PRAGMA foreign_keys = ON;

-- 1. Department table
CREATE TABLE IF NOT EXISTS departments (
    department_id INTEGER PRIMARY KEY,
    department_name TEXT NOT NULL UNIQUE
);

-- 2. Employee table
CREATE TABLE IF NOT EXISTS employees (
    employee_id INTEGER PRIMARY KEY,
    employee_name TEXT NOT NULL,
    department_id INTEGER NOT NULL,
    hire_date TEXT NOT NULL,
    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);

-- 3. Attendance table
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INTEGER PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    attendance_date TEXT NOT NULL,
    login_time TEXT,
    logout_time TEXT,
    status TEXT NOT NULL
        CHECK (status IN ('Present', 'Absent', 'Leave')),

    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id),

    UNIQUE (employee_id, attendance_date),

    CHECK (
        (status = 'Absent' AND login_time IS NULL
                            AND logout_time IS NULL)
        OR
        (status = 'Leave' AND login_time IS NULL
                           AND logout_time IS NULL)
        OR
        (status = 'Present' AND login_time IS NOT NULL
                             AND logout_time IS NOT NULL
                             AND logout_time > login_time)
    )
);

-- 4. Indexes to improve query performance
CREATE INDEX IF NOT EXISTS idx_attendance_employee_date
ON attendance(employee_id, attendance_date);

CREATE INDEX IF NOT EXISTS idx_attendance_date_status
ON attendance(attendance_date, status);

CREATE INDEX IF NOT EXISTS idx_employees_department
ON employees(department_id);

-- 5. Staging table for checking duplicate imported records
-- Duplicates can be stored here before inserting into attendance.
CREATE TABLE IF NOT EXISTS attendance_import (
    import_id INTEGER PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    attendance_date TEXT NOT NULL,
    login_time TEXT,
    logout_time TEXT,
    status TEXT NOT NULL
);
