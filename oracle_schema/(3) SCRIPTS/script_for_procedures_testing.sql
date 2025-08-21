-- 1. Ensure Department exists (needed for foreign key in STUDENTS)
MERGE INTO departments d
USING (SELECT 50 AS dept_id FROM dual) src
ON (d.dept_id = src.dept_id)
WHEN NOT MATCHED THEN
    INSERT (dept_id, dept_name, head_of_dept, dept_description)
    VALUES (50, 'Test Department', 'Dr. Smith', 'Department for procedure test');

-- 2. Ensure Student exists
MERGE INTO students s
USING (SELECT 2001 AS student_id FROM dual) src
ON (s.student_id = src.student_id)
WHEN NOT MATCHED THEN
    INSERT (student_id, name, dob, email, dept_id, enrollment_date, notes)
    VALUES (2001, 'Merged Test Student', DATE '2000-05-12', 'merged.test@student.com', 50, SYSDATE, 'Test student for merged proc');

-- 3. Ensure Hostel exists
MERGE INTO hostels h
USING (SELECT 20 AS hostel_id FROM dual) src
ON (h.hostel_id = src.hostel_id)
WHEN NOT MATCHED THEN
    INSERT (hostel_id, name, capacity, hostel_description)
    VALUES (20, 'North Block Hostel', 200, 'Hostel for merged procedure test');

-- 4. Call the merged procedure (allocate_hostel_room)
BEGIN
    allocate_hostel_room(
        p_alloc_id        => NULL,   -- Trigger + SEQ_HOSTEL_ALLOCATIONS will assign
        p_student_id      => 2001,
        p_hostel_id       => 20,
        p_room_number     => 'N-101',
        p_allocation_date => DATE '2025-08-21',
        p_notes           => 'Allocated via merged procedure test'
    );
END;
/

-- 5. Verify result
SELECT *
FROM hostel_allocations
WHERE student_id = 2001
  AND hostel_id = 20;

-------------------------------------------------------------------------------------------------------------

-- ensure dept exists
MERGE INTO departments d
USING (SELECT 60 AS dept_id, 'Bulk Test Dept' AS dept_name FROM dual) src
ON (d.dept_id = src.dept_id)
WHEN NOT MATCHED THEN
  INSERT (dept_id, dept_name) VALUES (src.dept_id, src.dept_name);

COMMIT;

-- now test bulk insert
DECLARE
    v_students student_bulk_insert_tab := student_bulk_insert_tab();
BEGIN
    v_students.EXTEND;
    v_students(1) := student_bulk_insert_obj(
        'Alice Bulk',
        DATE '2002-01-15',
        'alice.bulk@test.com',
        60,
        DATE '2020-08-01'
    );

    v_students.EXTEND;
    v_students(2) := student_bulk_insert_obj(
        'Bob Bulk',
        DATE '2001-06-22',
        'bob.bulk@test.com',
        60,
        DATE '2021-01-15'
    );

    bulk_insert_students(v_students);
    COMMIT;
END;
/

-- verify
SELECT student_id, name, dob, email, dept_id, enrollment_date
FROM students
WHERE email IN ('alice.bulk@test.com', 'bob.bulk@test.com');

---------------------------------------------------------------------------------------------------

-- Make sure you have a student and a course available
-- (assuming student_id = 101, course_id = 201 exist)

BEGIN
  enroll_student_in_course(
    p_student_id    => 100,
    p_course_id     => 200,
    p_semester_code => 'SEM8',
    p_grade         => 'A',
    p_notes         => 'Enrolled via procedure test'
  );
END;
/

-- Verify
SELECT * 
FROM enrollments
WHERE student_id = 100 
  AND course_id = 200;

-----------------------------------------------------------------------------------------------------

-- 1. Insert a sample book into LIBRARY_BOOKS
INSERT INTO library_books (book_id, title, author, isbn, summary)
VALUES (seq_library_books.NEXTVAL, 
        'Database Systems', 
        'Elmasri', 
        '9781234567890', 
        'Core database systems textbook');
        
COMMIT;

-- 2. Insert a sample student into STUDENTS
INSERT INTO students (student_id, name, dob, email, dept_id, enrollment_date)
VALUES (seq_students.NEXTVAL, 
        'John Doe', 
        DATE '2000-05-12', 
        'john.doe@example.com', 
        1, 
        SYSDATE);
        
COMMIT;

-- 3. Call the loan_book_to_student procedure
DECLARE
    v_book_id    NUMBER;
    v_student_id NUMBER;
BEGIN
    -- Get last inserted book_id
    SELECT MAX(book_id) INTO v_book_id FROM library_books;
    
    -- Get last inserted student_id
    SELECT MAX(student_id) INTO v_student_id FROM students;
    
    -- Call the procedure
    loan_book_to_student(
        p_loan_id     => NULL,             -- Trigger/sequence will handle this
        p_book_id     => v_book_id,
        p_student_id  => v_student_id,
        p_loan_date   => SYSDATE,
        p_return_date => SYSDATE + 14,
        p_notes       => 'Loan issued for testing'
    );
    
    --COMMIT;
END;
/

-- 4. Verify loan was created
SELECT * FROM book_loans
where loan_id = (select max(loan_id)
                        from book_loans);
-------------------------------------------------------------------------------------------------------------------

-- 1. Insert a sample student (if none exists)
INSERT INTO students (student_id, name, dob, email, dept_id, enrollment_date)
VALUES (null, 
        'Test Student', 
        DATE '2001-01-01', 
        'test.student@xample.com', 
        1, 
        SYSDATE);

-- 2. Insert a sample faculty (if none exists)
INSERT INTO faculty (faculty_id, name, email, dept_id, hire_date, profile)
VALUES (seq_faculty.NEXTVAL, 
        'Dr. Smith', 
        'dr.smith@example.com', 
        1, 
        SYSDATE, 
        'Senior Professor of Computer Science');

COMMIT;

-- 3. Call the procedure
DECLARE
    v_student_id NUMBER;
    v_faculty_id NUMBER;
BEGIN
    -- Get latest student and faculty IDs
    SELECT MAX(student_id) INTO v_student_id FROM students;
    SELECT MAX(faculty_id) INTO v_faculty_id FROM faculty;

    -- Call the logging procedure
    log_disciplinary_action(
        p_student_id     => v_student_id,
        p_faculty_id     => v_faculty_id,
        p_action_date    => SYSDATE,
        p_description    => 'Classroom Misconduct',
        p_action_details => 'Student was found using a mobile phone during an exam.'
    );
END;
/

-- 4. Verify the log entry
SELECT * 
FROM disciplinary_actions 
ORDER BY action_id DESC;

-----------------------------------------------------------------------------------------------------------------

-- 1. Case A: Insert a new course (not yet in COURSES)
BEGIN
  merge_course_details(
    p_course_id   => 201,
    p_code        => 'CS101',
    p_name        => 'Introduction to Computer Science',
    p_credits     => 4,
    p_dept_id     => 1,
    p_description => 'Basics of programming, algorithms, and computer systems.'
  );
END;
/

-- Verify insert
SELECT * FROM courses WHERE course_id = 201;


-- 2. Case B: Update the same course (COURSE_ID already exists)
BEGIN
  merge_course_details(
    p_course_id   => 201,
    p_code        => 'CS101-REV',
    p_name        => 'Intro to Computer Science (Revised)',
    p_credits     => 5,
    p_dept_id     => 1,
    p_description => 'Updated description: fundamentals of programming and systems.'
  );
END;
/

-- Verify update
SELECT * FROM courses WHERE course_id = 201;

---------------------------------------------------------------------------------------------------------

-- 1. Case A: Insert a new faculty record
BEGIN
  merge_faculty_profile(
    p_faculty_id => 101,
    p_name       => 'Dr. Alan Turing',
    p_email      => 'aturing@university.edu',
    p_dept_id    => 1,
    p_hire_date  => DATE '2020-08-15',
    p_profile    => 'Expert in theoretical computer science and AI.'
  );
END;
/

-- Verify insert
SELECT * FROM faculty WHERE faculty_id = 101;


-- 2. Case B: Update the same faculty record
BEGIN
  merge_faculty_profile(
    p_faculty_id => 101,
    p_name       => 'Prof. Alan M. Turing',
    p_email      => 'alan.turing@university.edu',
    p_dept_id    => 2,
    p_hire_date  => DATE '2020-09-01',
    p_profile    => 'Revised profile: pioneering researcher in algorithms and AI.'
  );
END;
/

-- Verify update
SELECT * FROM faculty WHERE faculty_id = 101;

-----------------------------------------------------------------------------------------------------------------

-- 1. Case A: Insert a new hostel
BEGIN
  merge_hostel_info(
    p_hostel_id   => 10,
    p_name        => 'North Block Hostel',
    p_capacity    => 200,
    p_description => 'Hostel reserved for first-year undergraduate students.'
  );
END;
/

-- Verify insert
SELECT * FROM hostels WHERE hostel_id = 10;


-- 2. Case B: Update the same hostel
BEGIN
  merge_hostel_info(
    p_hostel_id   => 10,
    p_name        => 'North Block Hostel (Renovated)',
    p_capacity    => 250,
    p_description => 'Renovated hostel with expanded capacity for UG students.'
  );
END;
/

-- Verify update
SELECT * FROM hostels WHERE hostel_id = 10;

-----------------------------------------------------------------------------------------------------------------

-- Case A: Insert a loan record (not yet returned)
INSERT INTO book_loans (
    loan_id, book_id, student_id, loan_date, return_date, loan_notes
) VALUES (
    2001, 31, 102, DATE '2025-08-01', NULL, 'Borrowed for DBMS project'
);
COMMIT;


-- Case B: Record the return (✅ success)
BEGIN
  record_book_return(2001, DATE '2025-08-20');
END;
/

-- Verify
SELECT * FROM book_loans WHERE loan_id = 2001;


-- Case C: Try to return again (❌ should raise error)
BEGIN
  record_book_return(2001, DATE '2025-08-22');
END;
/

-- Case D: Try a non-existent loan (❌ should raise error)
BEGIN
  record_book_return(9999, DATE '2025-08-22');
END;
/

------------------------------------------------------------------------------------------------------------

-- Insert a course first (if none exists)
MERGE INTO courses c
USING (SELECT 201 AS course_id FROM dual) src
ON (c.course_id = src.course_id)
WHEN NOT MATCHED THEN
  INSERT (course_id, course_code, course_name, credits, dept_id, course_description)
  VALUES (201, 'CS101', 'Database Systems', 4, 11, 'Intro to DBMS');

COMMIT;

-- Call the procedure
BEGIN
  schedule_exam_for_course(
    p_course_id      => 201,
    p_semester_code  => 'SEM8',
    p_exam_date      => DATE '2025-09-15',
    p_instructions   => 'Closed book, no laptops allowed.'
  );
END;
/

-- Verify
SELECT * FROM exams WHERE course_id = 201;

--------------------------------------------------------------------------------------------------------

BEGIN
  upsert_student_info(
    p_student_id      => NULL,
    p_name            => 'Charlie Brown',
    p_dob             => DATE '2001-12-12',
    p_email           => 'charlie.brown@example.com',
    p_dept_id         => 1,
    p_enrollment_date => SYSDATE,
    p_notes           => 'New student test'
  );
END;
/

BEGIN
  upsert_student_info(
    p_student_id      => 1,
    p_name            => 'Alice Smith Updated',
    p_dob             => DATE '2002-05-14',
    p_email           => 'alice.smith@example.com', -- same email is fine if belongs to ID=1
    p_dept_id         => 2,
    p_enrollment_date => SYSDATE,
    p_notes           => 'Update case'
  );
END;
/
