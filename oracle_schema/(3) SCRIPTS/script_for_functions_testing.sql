-- 1st function

SELECT *
FROM TABLE(get_borrowed_books(101));

------------------------------------------------------------------------------

-- 2nd function

SELECT get_enrollment_count(101, 'SEM5') AS enrollment_count
FROM dual;

------------------------------------------------------------------------------

-- 3rd function

DECLARE
  v_cur SYS_REFCURSOR;
BEGIN
  -- Call the function
  v_cur := get_faculty_by_department(10);

  -- Return the cursor to the client (SQL*Plus / SQL Developer / TOAD can display it)
  DBMS_SQL.RETURN_RESULT(v_cur);
END;
/

-------------------------------------------------------------------------------

-- 4th function

SELECT get_hostel_capacity(5) AS hostel_capacity
FROM dual;

-- error case

SELECT get_hostel_capacity(9999)
FROM dual;

-------------------------------------------------------------------------------

-- 5th function

SET SERVEROUTPUT ON;

DECLARE
  v_info student_info_obj;
BEGIN
  -- Call the function
  v_info := get_student_info(101);

  -- Print results
  DBMS_OUTPUT.PUT_LINE('Student ID      : ' || v_info.student_id);
  DBMS_OUTPUT.PUT_LINE('Name            : ' || v_info.student_name);
  DBMS_OUTPUT.PUT_LINE('Email           : ' || v_info.student_email);
  DBMS_OUTPUT.PUT_LINE('Department      : ' || v_info.department_name);

  IF v_info.gpa IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('GPA             : ' || v_info.gpa);
  ELSE
    DBMS_OUTPUT.PUT_LINE('GPA             : N/A');
  END IF;

  DBMS_OUTPUT.PUT_LINE('Scholarship Amt : ' || v_info.total_scholarship);
END;
/

-------------------------------------------------------------------------------

-- 6th function

SELECT is_book_available(301) AS availability
FROM dual;

