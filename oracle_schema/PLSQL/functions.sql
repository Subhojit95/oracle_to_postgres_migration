-- functions

create or replace FUNCTION get_borrowed_books(student_id NUMBER)
RETURN SYS_REFCURSOR IS
  v_cur SYS_REFCURSOR;
BEGIN
  OPEN v_cur FOR
    SELECT b.book_id, b.title, b.author
    FROM book_loans bl JOIN library_books b ON bl.book_id = b.book_id
    WHERE bl.student_id = student_id AND bl.return_date IS NULL;

  RETURN v_cur;
END;

-----------------------------------------------------------------------------------------

create or replace FUNCTION get_enrollment_count(course_id NUMBER, semester_code VARCHAR2)
RETURN NUMBER IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM enrollments
  WHERE course_id = course_id AND semester_code = semester_code;

  RETURN v_count;
END;

-------------------------------------------------------------------------------------------

create or replace FUNCTION get_faculty_by_department(dept_id NUMBER)
RETURN SYS_REFCURSOR IS
  v_cur SYS_REFCURSOR;
BEGIN
  OPEN v_cur FOR
    SELECT faculty_id, name, email
    FROM faculty
    WHERE dept_id = dept_id;

  RETURN v_cur;
END;

-------------------------------------------------------------------------------------------

create or replace FUNCTION get_hostel_capacity(hostel_id NUMBER)
RETURN NUMBER IS
  v_capacity NUMBER;
BEGIN
  SELECT capacity INTO v_capacity
  FROM hostels
  WHERE hostel_id = hostel_id;

  RETURN v_capacity;
END;

-------------------------------------------------------------------------------------------

create or replace FUNCTION get_student_department_name(p_student_id NUMBER)
RETURN VARCHAR2 IS
  v_dept_name VARCHAR2(100);
BEGIN
  SELECT d.dept_name INTO v_dept_name
  FROM students s JOIN departments d ON s.dept_id = d.dept_id
  WHERE s.student_id = p_student_id;

  RETURN v_dept_name;
END;

--------------------------------------------------------------------------------------------

create or replace FUNCTION get_student_email(p_student_id NUMBER)
RETURN VARCHAR2 IS
  v_email VARCHAR2(100);
BEGIN
  SELECT email INTO v_email
  FROM students
  WHERE student_id = p_student_id;

  RETURN v_email;
END;

---------------------------------------------------------------------------------------------

create or replace FUNCTION get_student_exam_grades
RETURN SYS_REFCURSOR
IS
    result_cursor SYS_REFCURSOR;
BEGIN
    OPEN result_cursor FOR
    SELECT 
        s.name AS student_name,
        er.exam_id,
        er.grade,
        g.grade_point
    FROM 
        exam_results er
    JOIN 
        students s ON s.student_id = er.student_id
    JOIN 
        grades g ON g.grade = er.grade;

    RETURN result_cursor;
END;

----------------------------------------------------------------------------------------------

create or replace FUNCTION get_student_gpa(student_id NUMBER)
RETURN NUMBER IS
  v_gpa NUMBER;
BEGIN
  SELECT ROUND(AVG(g.grade_point), 2)
  INTO v_gpa
  FROM exam_results er JOIN grades g ON er.grade = g.grade
  WHERE er.student_id = student_id;

  RETURN v_gpa;
END;

----------------------------------------------------------------------------------------------

create or replace FUNCTION get_total_scholarship_awarded(p_student_id NUMBER)
RETURN NUMBER IS
  v_total NUMBER := 0;
BEGIN
  SELECT NVL(SUM(s.amount), 0)
  INTO v_total
  FROM student_scholarships ss JOIN scholarships s ON ss.scholarship_id = s.scholarship_id
  WHERE ss.student_id = p_student_id;

  RETURN v_total;
END;

-----------------------------------------------------------------------------------------------

create or replace FUNCTION is_book_available(book_id NUMBER)
RETURN VARCHAR2 IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM book_loans
  WHERE book_id = book_id AND return_date IS NULL;

  RETURN CASE WHEN v_count = 0 THEN 'YES' ELSE 'NO' END;
END;

