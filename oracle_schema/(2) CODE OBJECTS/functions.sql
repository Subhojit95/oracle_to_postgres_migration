-- functions

CREATE OR REPLACE FUNCTION get_borrowed_books(
  p_student_id NUMBER
) RETURN borrowed_book_tab PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT b.book_id,
           b.title,
           b.author,
           bl.loan_date,
           bl.return_date AS due_date
    FROM book_loans bl
    JOIN library_books b ON bl.book_id = b.book_id
    WHERE bl.student_id = p_student_id
      AND bl.return_date IS NULL
  ) LOOP
    PIPE ROW (borrowed_book_obj(
      rec.book_id,
      rec.title,
      rec.author,
      rec.loan_date,
      rec.due_date
    ));
  END LOOP;
  RETURN;
END;
/

-----------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_enrollment_count (
  p_course_id     NUMBER,
  p_semester_code VARCHAR2 DEFAULT NULL
) RETURN NUMBER IS
  v_count NUMBER;
  v_exists NUMBER;
BEGIN
  -- Check that course exists
  SELECT COUNT(*) INTO v_exists
  FROM courses
  WHERE course_id = p_course_id;

  IF v_exists = 0 THEN
    RAISE_APPLICATION_ERROR(-20020, 'Course ID ' || p_course_id || ' does not exist.');
  END IF;

  -- Default semester: derive from SYSDATE if not given (example rule: YYYY + S1/S2)
  IF p_semester_code IS NULL THEN
    v_count := EXTRACT(YEAR FROM SYSDATE); -- placeholder logic
    RETURN 0; -- or raise error if semester is mandatory
  END IF;

  -- Actual count
  SELECT COUNT(*)
  INTO v_count
  FROM enrollments e
  WHERE e.course_id = p_course_id
    AND e.semester_code = p_semester_code;

  RETURN v_count;
END;
/

-------------------------------------------------------------------------------------------

create or replace FUNCTION get_faculty_by_department(p_dept_id NUMBER)
RETURN SYS_REFCURSOR IS
  v_cur SYS_REFCURSOR;
BEGIN
  OPEN v_cur FOR
    SELECT faculty_id, name, email
    FROM faculty f
    WHERE f.dept_id = p_dept_id;

  RETURN v_cur;
END;

-------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_hostel_capacity(p_hostel_id NUMBER)
RETURN NUMBER IS
  v_capacity NUMBER;
BEGIN
  SELECT capacity
  INTO v_capacity
  FROM hostels h
  WHERE h.hostel_id = p_hostel_id;

  RETURN v_capacity;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20030, 'Hostel ID ' || p_hostel_id || ' does not exist.');
END;
/

-------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_student_info(p_student_id NUMBER)
RETURN student_info_obj IS
  v_info student_info_obj;
BEGIN
  SELECT student_info_obj(
           s.student_id,
           s.name,
           s.email,
           d.dept_name,
           -- GPA
           (SELECT ROUND(AVG(g.grade_point), 2)
              FROM exam_results er
              JOIN grades g ON er.grade = g.grade
             WHERE er.student_id = s.student_id),
           -- Total scholarship
           (SELECT NVL(SUM(sch.amount),0)
              FROM student_scholarships ss
              JOIN scholarships sch ON ss.scholarship_id = sch.scholarship_id
             WHERE ss.student_id = s.student_id)
         )
  INTO v_info
  FROM students s
  JOIN departments d ON s.dept_id = d.dept_id
  WHERE s.student_id = p_student_id;

  RETURN v_info;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20061, 'Student ID ' || p_student_id || ' not found.');
END;
/

-----------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION is_book_available(p_book_id NUMBER)
RETURN VARCHAR2 IS
  v_count   NUMBER;
  v_exists  NUMBER;
BEGIN
  -- Check if the book exists
  SELECT COUNT(*) INTO v_exists
  FROM library_books
  WHERE book_id = p_book_id;

  IF v_exists = 0 THEN
    RAISE_APPLICATION_ERROR(-20070, 'Book ID ' || p_book_id || ' does not exist.');
  END IF;

  -- Check if there is an active loan
  SELECT COUNT(*) INTO v_count
  FROM book_loans
  WHERE book_id = p_book_id
    AND return_date IS NULL;

  RETURN CASE WHEN v_count = 0 THEN 'YES' ELSE 'NO' END;
END;
/

