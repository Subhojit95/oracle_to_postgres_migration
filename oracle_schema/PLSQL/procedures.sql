-- procedures

create or replace PROCEDURE allocate_hostel (
  p_alloc_id NUMBER,
  p_student_id NUMBER,
  p_hostel_id NUMBER,
  p_room_number VARCHAR2,
  p_allocation_date DATE,
  p_notes CLOB
) AS
BEGIN
  INSERT INTO hostel_allocations
  VALUES (p_alloc_id, p_student_id, p_hostel_id, p_room_number, p_allocation_date, p_notes);
END;

------------------------------------------------------------------------------------------------------

create or replace PROCEDURE allocate_room_to_student (
  p_alloc_id NUMBER,
  p_student_id NUMBER,
  p_hostel_id NUMBER,
  p_room_number VARCHAR2,
  p_allocation_date DATE,
  p_notes CLOB
) AS
BEGIN
  INSERT INTO hostel_allocations
  VALUES (p_alloc_id, p_student_id, p_hostel_id, p_room_number, p_allocation_date, p_notes);
END;

-------------------------------------------------------------------------------------------------------

create or replace PROCEDURE bulk_insert_students(p_students IN student_bulk_insert_tab) IS
BEGIN
  FOR i IN 1 .. p_students.COUNT LOOP
    INSERT INTO students (
      student_id,
      name,
      dob,
      email,
      dept_id,
      enrollment_date
    ) VALUES (
      seq_students.NEXTVAL, -- auto-generated ID
      p_students(i).name,
      p_students(i).dob,
      p_students(i).email,
      p_students(i).dept_id,
      p_students(i).enrollment_date
    );
  END LOOP;
END;

--------------------------------------------------------------------------------------------------------

create or replace PROCEDURE enroll_student_in_course (
  p_enrollment_id NUMBER,
  p_student_id NUMBER,
  p_course_id NUMBER,
  p_semester_code VARCHAR2,
  p_grade VARCHAR2,
  p_notes CLOB
) AS
BEGIN
  INSERT INTO enrollments
  VALUES (p_enrollment_id, p_student_id, p_course_id, p_semester_code, p_grade, p_notes);
END;

---------------------------------------------------------------------------------------------------------

create or replace PROCEDURE loan_book_to_student (
  p_loan_id NUMBER,
  p_book_id NUMBER,
  p_student_id NUMBER,
  p_loan_date DATE,
  p_return_date DATE,
  p_notes CLOB
) AS
BEGIN
  INSERT INTO book_loans
  VALUES (p_loan_id, p_book_id, p_student_id, p_loan_date, p_return_date, p_notes);
END;

----------------------------------------------------------------------------------------------------------

create or replace PROCEDURE log_disciplinary_action (
    p_student_id     IN NUMBER,
    p_faculty_id     IN NUMBER,
    p_action_date    IN DATE,
    p_description    IN VARCHAR2,
    p_action_details IN CLOB
)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_action_id NUMBER;
BEGIN
    -- Input validation (example)
    IF p_student_id IS NULL OR p_faculty_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Student ID and Faculty ID cannot be NULL');
    END IF;

    -- Generate new primary key value
    SELECT disciplinary_actions_seq.NEXTVAL
    INTO v_action_id
    FROM dual;

    INSERT INTO disciplinary_actions (
        action_id,
        student_id,
        faculty_id,
        action_date,
        description,
        action_details
    ) VALUES (
        v_action_id,
        p_student_id,
        p_faculty_id,
        p_action_date,
        p_description,
        p_action_details
    );

    COMMIT; -- commit autonomous transaction

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- rollback in case of error
        RAISE_APPLICATION_ERROR(-20002, SQLERRM); -- raise error with message
END log_disciplinary_action;

--------------------------------------------------------------------------------------------------------------

create or replace PROCEDURE merge_course_details (
  p_course_id NUMBER,
  p_code VARCHAR2,
  p_name VARCHAR2,
  p_credits NUMBER,
  p_dept_id NUMBER,
  p_description CLOB
) AS
BEGIN
  MERGE INTO courses c
  USING (SELECT p_course_id AS course_id FROM dual) src
  ON (c.course_id = src.course_id)
  WHEN MATCHED THEN
    UPDATE SET c.course_code = p_code,
               c.course_name = p_name,
               c.credits = p_credits,
               c.dept_id = p_dept_id,
               c.course_description = p_description
  WHEN NOT MATCHED THEN
    INSERT (course_id, course_code, course_name, credits, dept_id, course_description)
    VALUES (p_course_id, p_code, p_name, p_credits, p_dept_id, p_description);
END;

--------------------------------------------------------------------------------------------------------------

create or replace PROCEDURE merge_faculty_profile (
  p_faculty_id NUMBER,
  p_name VARCHAR2,
  p_email VARCHAR2,
  p_dept_id NUMBER,
  p_hire_date DATE,
  p_profile CLOB
) AS
BEGIN
  MERGE INTO faculty f
  USING (SELECT p_faculty_id AS faculty_id FROM dual) src
  ON (f.faculty_id = src.faculty_id)
  WHEN MATCHED THEN
    UPDATE SET f.name = p_name,
               f.email = p_email,
               f.dept_id = p_dept_id,
               f.hire_date = p_hire_date,
               f.profile = p_profile
  WHEN NOT MATCHED THEN
    INSERT (faculty_id, name, email, dept_id, hire_date, profile)
    VALUES (p_faculty_id, p_name, p_email, p_dept_id, p_hire_date, p_profile);
END;

--------------------------------------------------------------------------------------------------------------

create or replace PROCEDURE merge_hostel_info (
  p_hostel_id NUMBER,
  p_name VARCHAR2,
  p_capacity NUMBER,
  p_description CLOB
) AS
BEGIN
  MERGE INTO hostels h
  USING (SELECT p_hostel_id AS hostel_id FROM dual) src
  ON (h.hostel_id = src.hostel_id)
  WHEN MATCHED THEN
    UPDATE SET h.name = p_name,
               h.capacity = p_capacity,
               h.hostel_description = p_description
  WHEN NOT MATCHED THEN
    INSERT (hostel_id, name, capacity, hostel_description)
    VALUES (p_hostel_id, p_name, p_capacity, p_description);
END;

-------------------------------------------------------------------------------------------------------------

create or replace PROCEDURE record_book_return (
  p_loan_id NUMBER,
  p_return_date DATE
) AS
BEGIN
  UPDATE book_loans
  SET return_date = p_return_date
  WHERE loan_id = p_loan_id;
END;

--------------------------------------------------------------------------------------------------------------

create or replace PROCEDURE record_disciplinary_action (
  p_action_id NUMBER,
  p_student_id NUMBER,
  p_faculty_id NUMBER,
  p_action_date DATE,
  p_description VARCHAR2,
  p_details CLOB
) AS
BEGIN
  INSERT INTO disciplinary_actions
  VALUES (p_action_id, p_student_id, p_faculty_id, p_action_date, p_description, p_details);
END;

---------------------------------------------------------------------------------------------------------------

create or replace PROCEDURE schedule_exam_for_course (
  p_exam_id NUMBER,
  p_course_id NUMBER,
  p_semester_code VARCHAR2,
  p_exam_date DATE,
  p_instructions CLOB
) AS
BEGIN
  INSERT INTO exams
  VALUES (p_exam_id, p_course_id, p_semester_code, p_exam_date, p_instructions);
END;

---------------------------------------------------------------------------------------------------------------

create or replace PROCEDURE send_fee_due_email (
    p_subject IN VARCHAR2 := 'Outstanding Student Fees'
) AS
    v_body        CLOB;
    v_host        VARCHAR2(100) := 'smtp.gmail.com';
    v_port        NUMBER := 587;
    v_mail_conn   UTL_SMTP.CONNECTION;
    v_sender      VARCHAR2(100) := 'subhojeet43@gmail.com';
    v_password    VARCHAR2(100) := 'hkilolzndaurvhse';
    v_recipient   VARCHAR2(100) := 'purbashadasgupta47@gmail.com';

    CURSOR fee_due_cur IS
        SELECT student_id, amount, TO_CHAR(due_date, 'YYYY-MM-DD') AS due_date
        FROM fees
        WHERE amount > 0;

    FUNCTION base64_encode(p_text VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN UTL_ENCODE.TEXT_ENCODE(p_text, 'WE8ISO8859P1', UTL_ENCODE.BASE64);
    END;
BEGIN
    -- Build the email body
    v_body := '📋 List of Students with Outstanding Fees:' || CHR(10) || CHR(10);

    FOR rec IN fee_due_cur LOOP
        v_body := v_body || '🧑 Student ID: ' || rec.student_id
                        || ' | 💰 Amount Due: ₹' || rec.amount
                        || ' | 📆 Due Date: ' || rec.due_date || CHR(10);
    END LOOP;

    -- Connect and authenticate
    v_mail_conn := UTL_SMTP.OPEN_CONNECTION(v_host, v_port);
    UTL_SMTP.HELO(v_mail_conn, v_host);
    UTL_SMTP.STARTTLS(v_mail_conn);

    -- Manual AUTH LOGIN sequence
    UTL_SMTP.COMMAND(v_mail_conn, 'AUTH LOGIN');
    UTL_SMTP.COMMAND(v_mail_conn, base64_encode(v_sender));
    UTL_SMTP.COMMAND(v_mail_conn, base64_encode(v_password));

    UTL_SMTP.MAIL(v_mail_conn, v_sender);
    UTL_SMTP.RCPT(v_mail_conn, v_recipient);

    -- Write headers and content
    UTL_SMTP.OPEN_DATA(v_mail_conn);
    UTL_SMTP.WRITE_DATA(v_mail_conn, 'Subject: ' || p_subject || CHR(13) || CHR(10));
    UTL_SMTP.WRITE_DATA(v_mail_conn, 'Content-Type: text/plain; charset=US-ASCII' || CHR(13) || CHR(10) || CHR(13) || CHR(10));
    UTL_SMTP.WRITE_DATA(v_mail_conn, v_body);
    UTL_SMTP.CLOSE_DATA(v_mail_conn);

    UTL_SMTP.QUIT(v_mail_conn);
    DBMS_OUTPUT.PUT_LINE('Email sent successfully.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error sending email: ' || SQLERRM);
END;

--------------------------------------------------------------------------------------------------------------

create or replace PROCEDURE upsert_student_info (
  p_student_id NUMBER,
  p_name VARCHAR2,
  p_dob DATE,
  p_email VARCHAR2
) AS
BEGIN
  MERGE INTO students s
  USING (SELECT p_student_id AS student_id,
               p_name AS name,
               p_dob AS dob,
               p_email AS email
         FROM dual) src
  ON (s.student_id = src.student_id)
  WHEN MATCHED THEN
    UPDATE SET s.name = src.name,
               s.dob = src.dob,
               s.email = src.email
  WHEN NOT MATCHED THEN
    INSERT (student_id, name, dob, email)
    VALUES (src.student_id, src.name, src.dob, src.email);
END;

