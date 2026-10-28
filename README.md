Employee Attendance Analyzer

Project Overview

The Employee Attendance Analyzer is a Python and SQLite project that stores employee attendance records and uses SQL queries to analyze working hours, late arrivals, department attendance percentages, monthly trends, consecutive absences, duplicate records, weekend work, and average login and logout times.

Technologies Used

* Python — to create and populate the database.
* SQLite — to store and query attendance data.
* SQL — to analyze attendance patterns using joins, aggregate functions, CTEs, and window functions.
* VS Code — for development and testing.

Database Structure

The project uses four tables:

* departments — stores department information.
* employees — stores employee details and department assignments.
* attendance — stores daily attendance records.
* attendance_import — holds imported attendance data for checking duplicates.

The schema includes primary keys, foreign keys, unique constraints, check constraints, and indexes.

Dataset

The sample database contains 5 departments, 50 employees, and 3,000 attendance records. The data is generated for project testing and demonstration.

Analysis Queries

The project includes SQL queries for:

1. Top 10 employees by total working hours.
2. Employees with frequent late arrivals.
3. Attendance percentage by department.
4. Monthly attendance trends.
5. Consecutive absences.
6. Duplicate attendance records in the import table.
7. Weekend workers.
8. Average login and logout times by department.

Project Files

* attendance.sql — database schema, constraints, and indexes.
* analysis_queries.sql — attendance analysis queries.
* setup_db.py — creates and populates the sample database.
* attendance.db — SQLite database containing the sample data.
* screenshots/ — screenshots of query results, if saved in this folder.

How to Run

1. Install Python 3.
2. Open a terminal in the project folder.
3. Run:

python setup_db.py

4. Open attendance.db using a SQLite-compatible tool.
5. Run the queries in analysis_queries.sql to explore the results.

Notes

This project uses synthetic sample data for learning and demonstration. Attendance percentages and trends are based on the generated dataset.

SQL Optimization Techniques

The Employee Attendance Analyzer uses the following SQL techniques to improve query readability, maintain data integrity, and support efficient analysis.

1. Indexing

Indexes can improve query performance when filtering, joining, or sorting attendance records. Indexes should be created on frequently queried columns, such as employee IDs and attendance dates, based on actual query usage.

2. Common Table Expressions (CTEs)

CTEs (WITH clauses) break complex queries into smaller, readable steps. They make attendance summaries and monthly trend calculations easier to maintain.

3. Window Functions

Window functions such as ROW_NUMBER(), RANK(), and LAG() support ranking employees, identifying consecutive absences, and analyzing attendance patterns without losing row-level detail.

4. Joins

Joins combine employee, department, and attendance data using their related keys, allowing meaningful reports without unnecessarily duplicating data.

5. CASE Expressions

CASE expressions classify attendance records, such as identifying late arrivals or categorizing attendance statuses, directly within SQL queries.

6. Query Filtering and Aggregation

WHERE, GROUP BY, and aggregate functions such as COUNT() and AVG() help filter records and calculate attendance percentages, working hours, and monthly statistics.

7. Data Integrity

Primary keys, foreign keys, unique constraints, and check constraints help prevent invalid or inconsistent data from entering the database.

8. Performance Validation

Indexes and query performance should be evaluated using representative data and SQLite’s EXPLAIN QUERY PLAN. Indexes should be retained when they improve relevant queries without adding unnecessary write overhead.
