-- TABLE: departments
CREATE TABLE departments (
    dept_id           NUMBER PRIMARY KEY,
    dept_name         VARCHAR2(100) NOT NULL,
    head_of_dept      VARCHAR2(100),
    dept_description  CLOB
);

-- TABLE: students
CREATE TABLE students (
    student_id     NUMBER PRIMARY KEY,
    name           VARCHAR2(100) NOT NULL,
    dob            DATE,
    email          VARCHAR2(100) UNIQUE,
    dept_id        NUMBER REFERENCES departments(dept_id),
    enrollment_date DATE,
    notes          CLOB
);

-- TABLE: faculty
CREATE TABLE faculty (
    faculty_id    NUMBER PRIMARY KEY,
    name          VARCHAR2(100) NOT NULL,
    email         VARCHAR2(100) UNIQUE,
    dept_id       NUMBER REFERENCES departments(dept_id),
    hire_date     DATE,
    profile       CLOB
);

-- TABLE: courses
CREATE TABLE courses (
    course_id          NUMBER PRIMARY KEY,
    course_code        VARCHAR2(10) UNIQUE,
    course_name        VARCHAR2(100),
    credits            NUMBER,
    dept_id            NUMBER REFERENCES departments(dept_id),
    course_description CLOB
);

-- TABLE: classrooms
CREATE TABLE classrooms (
    room_id       VARCHAR2(10) PRIMARY KEY,
    building_name VARCHAR2(100),
    capacity      NUMBER,
    room_notes    CLOB
);

-- TABLE: semesters
CREATE TABLE semesters (
    semester_code  VARCHAR2(10) PRIMARY KEY,
    start_date     DATE,
    end_date       DATE,
    semester_notes CLOB
);

-- TABLE: schedules
CREATE TABLE schedules (
    schedule_id      NUMBER PRIMARY KEY,
    course_id        NUMBER REFERENCES courses(course_id),
    room_id          VARCHAR2(10) REFERENCES classrooms(room_id),
    faculty_id       NUMBER REFERENCES faculty(faculty_id),
    semester_code    VARCHAR2(10) REFERENCES semesters(semester_code),
    schedule_time    VARCHAR2(50),
    schedule_details CLOB
);

-- TABLE: course_prerequisites
CREATE TABLE course_prerequisites (
    course_id       NUMBER REFERENCES courses(course_id),
    prerequisite_id NUMBER REFERENCES courses(course_id),
    justification   CLOB,
    PRIMARY KEY (course_id, prerequisite_id)
);

-- TABLE: course_offerings
CREATE TABLE course_offerings (
    offering_id     NUMBER PRIMARY KEY,
    course_id       NUMBER REFERENCES courses(course_id),
    semester_code   VARCHAR2(10) REFERENCES semesters(semester_code),
    offering_notes  CLOB
);

-- TABLE: grades
CREATE TABLE grades (
    grade             VARCHAR2(2) PRIMARY KEY,
    grade_point       NUMBER(3,2),
    grade_description CLOB
);

-- TABLE: enrollments
CREATE TABLE enrollments (
    enrollment_id    NUMBER PRIMARY KEY,
    student_id       NUMBER REFERENCES students(student_id),
    course_id        NUMBER REFERENCES courses(course_id),
    semester_code    VARCHAR2(10) REFERENCES semesters(semester_code),
    grade            VARCHAR2(2) REFERENCES grades(grade),
    enrollment_notes CLOB
);

-- TABLE: attendance_records
CREATE TABLE attendance_records (
    record_id     NUMBER PRIMARY KEY,
    enrollment_id NUMBER REFERENCES enrollments(enrollment_id),
    date_attended DATE,
    status        VARCHAR2(10),
    remarks       CLOB
);

-- TABLE: fees
CREATE TABLE fees (
    fee_id          NUMBER PRIMARY KEY,
    student_id      NUMBER REFERENCES students(student_id),
    amount          NUMBER,
    due_date        DATE,
    fee_description CLOB
);

-- TABLE: payments
CREATE TABLE payments (
    payment_id     NUMBER PRIMARY KEY,
    fee_id         NUMBER REFERENCES fees(fee_id),
    amount_paid    NUMBER,
    payment_date   DATE,
    payment_notes  CLOB
);

-- TABLE: library_books
CREATE TABLE library_books (
    book_id   NUMBER PRIMARY KEY,
    title     VARCHAR2(200),
    author    VARCHAR2(100),
    isbn      VARCHAR2(20) UNIQUE,
    summary   CLOB
);

-- TABLE: book_loans
CREATE TABLE book_loans (
    loan_id     NUMBER PRIMARY KEY,
    book_id     NUMBER REFERENCES library_books(book_id),
    student_id  NUMBER REFERENCES students(student_id),
    loan_date   DATE,
    return_date DATE,
    loan_notes  CLOB
);

-- TABLE: hostels
CREATE TABLE hostels (
    hostel_id           NUMBER PRIMARY KEY,
    name                VARCHAR2(100),
    capacity            NUMBER,
    hostel_description  CLOB
);

-- TABLE: hostel_allocations
CREATE TABLE hostel_allocations (
    alloc_id          NUMBER PRIMARY KEY,
    student_id        NUMBER REFERENCES students(student_id),
    hostel_id         NUMBER REFERENCES hostels(hostel_id),
    room_number       VARCHAR2(10),
    allocation_date   DATE,
    allocation_notes  CLOB
);

-- TABLE: disciplinary_actions
CREATE TABLE disciplinary_actions (
    action_id      NUMBER PRIMARY KEY,
    student_id     NUMBER REFERENCES students(student_id),
    faculty_id     NUMBER REFERENCES faculty(faculty_id),
    action_date    DATE,
    description    VARCHAR2(500),
    action_details CLOB
);

-- TABLE: scholarships
CREATE TABLE scholarships (
    scholarship_id          NUMBER PRIMARY KEY,
    name                    VARCHAR2(100),
    amount                  NUMBER,
    scholarship_description CLOB
);

-- TABLE: student_scholarships
CREATE TABLE student_scholarships (
    student_scholarship_id NUMBER PRIMARY KEY,
    student_id             NUMBER REFERENCES students(student_id),
    scholarship_id         NUMBER REFERENCES scholarships(scholarship_id),
    award_date             DATE,
    award_notes            CLOB
);

-- TABLE: exams
CREATE TABLE exams (
    exam_id           NUMBER PRIMARY KEY,
    course_id         NUMBER REFERENCES courses(course_id),
    semester_code     VARCHAR2(10) REFERENCES semesters(semester_code),
    exam_date         DATE,
    exam_instructions CLOB
);

-- TABLE: exam_results
CREATE TABLE exam_results (
    result_id  NUMBER PRIMARY KEY,
    student_id NUMBER REFERENCES students(student_id),
    exam_id    NUMBER REFERENCES exams(exam_id),
    grade      VARCHAR2(2) REFERENCES grades(grade),
    remarks    CLOB
);

-- TABLE: notifications
CREATE TABLE notifications (
    notification_id NUMBER PRIMARY KEY,
    message         VARCHAR2(500),
    student_id      NUMBER REFERENCES students(student_id),
    faculty_id      NUMBER REFERENCES faculty(faculty_id),
    sent_date       DATE,
    message_body    CLOB
);
