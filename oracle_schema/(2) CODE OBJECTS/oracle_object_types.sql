-- Recreate the object type with more detail
CREATE OR REPLACE TYPE grade_stats AS OBJECT (
  grade        VARCHAR2(2),
  count        NUMBER,
  percentage   NUMBER,
  grade_point  NUMBER
);
/

-- Table type
CREATE OR REPLACE TYPE grade_stats_tab AS TABLE OF grade_stats;
/

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

-- borrowed_book_obj
CREATE OR REPLACE TYPE borrowed_book_obj AS OBJECT (
  book_id   NUMBER,
  title     VARCHAR2(200),
  author    VARCHAR2(100),
  loan_date DATE,
  due_date  DATE
);

-- borrowed_book_tab
CREATE OR REPLACE TYPE borrowed_book_tab AS TABLE OF borrowed_book_obj;

-- student_info_obj

CREATE OR REPLACE TYPE student_info_obj AS OBJECT (
  student_id       NUMBER,
  student_name     VARCHAR2(100),
  student_email    VARCHAR2(100),
  department_name  VARCHAR2(100),
  gpa              NUMBER,
  total_scholarship NUMBER
);
/
