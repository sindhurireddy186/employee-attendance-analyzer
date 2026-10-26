"""Create a sample employee attendance database using SQLite."""

import random
import sqlite3
from datetime import date, timedelta
from pathlib import Path

DATABASE_FILE = Path(__file__).with_name("attendance.db")
SQL_FILE = Path(__file__).with_name("attendance.sql")

random.seed(42)

DEPARTMENTS = [
    "Engineering",
    "Human Resources",
    "Finance",
    "Sales",
    "Marketing",
]

FIRST_NAMES = [
    "Aarav", "Ananya", "Rohan", "Priya", "Ishaan",
    "Meera", "Arjun", "Diya", "Kabir", "Sana",
    "Vivaan", "Aditi", "Rahul", "Neha", "Karan",
    "Pooja", "Advik", "Ira", "Dev", "Nisha",
]

LAST_NAMES = [
    "Sharma", "Patel", "Reddy", "Kumar", "Singh",
    "Shah", "Nair", "Das", "Joshi", "Rao",
]


def create_database() -> None:
    """Create tables and indexes using the SQL schema file."""
    if not SQL_FILE.exists():
        raise FileNotFoundError("attendance.sql was not found.")

    with sqlite3.connect(DATABASE_FILE) as connection:
        connection.execute("PRAGMA foreign_keys = ON")
        connection.executescript(SQL_FILE.read_text(encoding="utf-8"))


def add_sample_data() -> None:
    """Insert departments, employees, and attendance records."""
    with sqlite3.connect(DATABASE_FILE) as connection:
        connection.execute("PRAGMA foreign_keys = ON")

        connection.executemany(
            "INSERT OR IGNORE INTO departments (department_name) VALUES (?)",
            [(name,) for name in DEPARTMENTS],
        )

        department_rows = connection.execute(
            "SELECT department_id FROM departments"
        ).fetchall()
        department_ids = [row[0] for row in department_rows]

        # Create 50 employees.
        for employee_id in range(1, 51):
            first = FIRST_NAMES[(employee_id - 1) % len(FIRST_NAMES)]
            last = LAST_NAMES[
                ((employee_id - 1) // len(FIRST_NAMES)) % len(LAST_NAMES)
            ]
            name = f"{first} {last}"
            department_id = department_ids[(employee_id - 1) % len(department_ids)]

            connection.execute(
                """
                INSERT OR IGNORE INTO employees
                    (employee_id, employee_name, department_id, hire_date)
                VALUES (?, ?, ?, ?)
                """,
                (employee_id, name, department_id, "2025-01-01"),
            )

        # Generate attendance for 50 employees across 60 days.
        # Weekends are included to support weekend-work analysis.
        start_date = date(2026, 1, 1)
        records = []

        for employee_id in range(1, 51):
            for day_number in range(60):
                attendance_day = start_date + timedelta(days=day_number)
                day_text = attendance_day.isoformat()

                # Include some absences and leave days.
                status_roll = random.random()
                if status_roll < 0.08:
                    status = "Absent"
                    login_time = None
                    logout_time = None
                elif status_roll < 0.12:
                    status = "Leave"
                    login_time = None
                    logout_time = None
                else:
                    status = "Present"

                    # A few employees arrive late more often.
                    late = employee_id % 10 == 0 or random.random() < 0.15
                    login_hour = 10 if late else 9
                    login_minute = random.randint(0, 59)

                    login_time = f"{login_hour:02d}:{login_minute:02d}"
                    logout_hour = random.choice([17, 18, 19])
                    logout_minute = random.randint(0, 59)
                    logout_time = f"{logout_hour:02d}:{logout_minute:02d}"

                records.append(
                    (
                        employee_id,
                        day_text,
                        login_time,
                        logout_time,
                        status,
                    )
                )

        connection.executemany(
            """
            INSERT OR IGNORE INTO attendance
                (employee_id, attendance_date, login_time, logout_time, status)
            VALUES (?, ?, ?, ?, ?)
            """,
            records,
        )

        # Add a few deliberately repeated rows to the staging table.
        # The main attendance table still prevents duplicate daily records.
        connection.execute("DELETE FROM attendance_import")
        sample_imports = [
            (1, "2026-01-02", "09:10", "18:00", "Present"),
            (1, "2026-01-02", "09:10", "18:00", "Present"),
            (2, "2026-01-03", "09:20", "17:30", "Present"),
            (2, "2026-01-03", "09:20", "17:30", "Present"),
        ]
        connection.executemany(
            """
            INSERT INTO attendance_import
                (employee_id, attendance_date, login_time, logout_time, status)
            VALUES (?, ?, ?, ?, ?)
            """,
            sample_imports,
        )

        employee_count = connection.execute(
            "SELECT COUNT(*) FROM employees"
        ).fetchone()[0]
        attendance_count = connection.execute(
            "SELECT COUNT(*) FROM attendance"
        ).fetchone()[0]
        department_count = connection.execute(
            "SELECT COUNT(*) FROM departments"
        ).fetchone()[0]

    print("Database setup completed!")
    print(f"Database file: {DATABASE_FILE}")
    print(f"Departments: {department_count}")
    print(f"Employees: {employee_count}")
    print(f"Attendance records: {attendance_count}")
    print("Duplicate-check sample records: 4")


def main() -> None:
    """Run the database setup."""
    create_database()
    add_sample_data()


if __name__ == "__main__":
    main()
    