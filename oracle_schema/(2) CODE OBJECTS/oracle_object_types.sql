-- grade_stats
create or replace TYPE grade_stats AS OBJECT (
  grade VARCHAR2(2),
  count NUMBER
);  

-- grade_stats_tab
create or replace TYPE grade_stats_tab AS TABLE OF grade_stats;

-- student_bulk_insert_obj
create or replace TYPE student_bulk_insert_obj AS OBJECT (
  name            VARCHAR2(100),
  dob             DATE,
  email           VARCHAR2(100),
  dept_id         NUMBER,
  enrollment_date DATE
);

-- student_bulk_insert_tab
create or replace TYPE student_bulk_insert_tab AS TABLE OF student_bulk_insert_obj;

-- student_grade_report_obj
create or replace TYPE student_grade_report_obj AS OBJECT (
  student_id   NUMBER,
  student_name VARCHAR2(100),
  course_name  VARCHAR2(100),
  semester     VARCHAR2(10),
  grade        VARCHAR2(2)
);

-- student_grade_report_tab
create or replace TYPE student_grade_report_tab AS TABLE OF student_grade_report_obj;