-- package

CREATE OR REPLACE PACKAGE exam_utils AS
  -- Schedule a new exam
  PROCEDURE schedule_exam(
    p_exam_id           IN NUMBER,
    p_course_id         IN NUMBER,
    p_semester_code     IN VARCHAR2,
    p_exam_date         IN DATE,
    p_exam_instructions IN VARCHAR2
  );

  -- Assign grade to a student
  PROCEDURE assign_grade(
    p_student_id IN NUMBER,
    p_exam_id    IN NUMBER,
    p_grade      IN VARCHAR2,
    p_remarks    IN VARCHAR2 DEFAULT NULL
  );

  -- Get detailed grade distribution for an exam
  FUNCTION get_exam_statistics(
    p_exam_id IN NUMBER
  ) RETURN grade_stats_tab PIPELINED;
END exam_utils;
/

------------------------------------------------------------------

-- package body

CREATE OR REPLACE PACKAGE BODY exam_utils AS

  PROCEDURE schedule_exam(
    p_exam_id           IN NUMBER,
    p_course_id         IN NUMBER,
    p_semester_code     IN VARCHAR2,
    p_exam_date         IN DATE,
    p_exam_instructions IN VARCHAR2
  ) IS
    v_exists NUMBER;
  BEGIN
    -- validate course
    SELECT COUNT(*) INTO v_exists FROM courses WHERE course_id = p_course_id;
    IF v_exists = 0 THEN
      RAISE_APPLICATION_ERROR(-20100, 'Course ID ' || p_course_id || ' does not exist.');
    END IF;

    -- validate semester
    SELECT COUNT(*) INTO v_exists FROM semesters WHERE semester_code = p_semester_code;
    IF v_exists = 0 THEN
      RAISE_APPLICATION_ERROR(-20101, 'Semester ' || p_semester_code || ' does not exist.');
    END IF;

    -- validate exam date
    IF p_exam_date < SYSDATE THEN
      RAISE_APPLICATION_ERROR(-20102, 'Exam date cannot be in the past.');
    END IF;

    -- insert exam
    INSERT INTO exams (
      exam_id, course_id, semester_code, exam_date, exam_instructions
    ) VALUES (
      p_exam_id, p_course_id, p_semester_code, p_exam_date, p_exam_instructions
    );
  END schedule_exam;

  PROCEDURE assign_grade(
    p_student_id IN NUMBER,
    p_exam_id    IN NUMBER,
    p_grade      IN VARCHAR2,
    p_remarks    IN VARCHAR2 DEFAULT NULL
  ) IS
    v_exists NUMBER;
  BEGIN
    -- validate student
    SELECT COUNT(*) INTO v_exists FROM students WHERE student_id = p_student_id;
    IF v_exists = 0 THEN
      RAISE_APPLICATION_ERROR(-20110, 'Student ID ' || p_student_id || ' does not exist.');
    END IF;

    -- validate exam
    SELECT COUNT(*) INTO v_exists FROM exams WHERE exam_id = p_exam_id;
    IF v_exists = 0 THEN
      RAISE_APPLICATION_ERROR(-20111, 'Exam ID ' || p_exam_id || ' does not exist.');
    END IF;

    -- validate grade
    SELECT COUNT(*) INTO v_exists FROM grades WHERE grade = UPPER(p_grade);
    IF v_exists = 0 THEN
      RAISE_APPLICATION_ERROR(-20112, 'Invalid grade ' || p_grade);
    END IF;

    -- prevent duplicate entry
    SELECT COUNT(*) INTO v_exists
    FROM exam_results
    WHERE student_id = p_student_id
      AND exam_id    = p_exam_id;
    IF v_exists > 0 THEN
      RAISE_APPLICATION_ERROR(-20113, 'Student ' || p_student_id ||
                                         ' already graded for exam ' || p_exam_id);
    END IF;

    -- insert grade
    INSERT INTO exam_results (student_id, exam_id, grade, remarks)
    VALUES (p_student_id, p_exam_id, UPPER(p_grade), p_remarks);
  END assign_grade;

  FUNCTION get_exam_statistics(p_exam_id IN NUMBER)
  RETURN grade_stats_tab PIPELINED IS
    v_row grade_stats;
  BEGIN
    FOR rec IN (
      SELECT er.grade,
             COUNT(*) AS cnt,
             ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct,
             AVG(g.grade_point) AS avg_gp
      FROM exam_results er
      JOIN grades g ON er.grade = g.grade
      WHERE er.exam_id = p_exam_id
      GROUP BY er.grade
      ORDER BY er.grade
    ) LOOP
      v_row := grade_stats(rec.grade, rec.cnt, rec.pct, rec.avg_gp);
      PIPE ROW (v_row);
    END LOOP;

    RETURN;
  END get_exam_statistics;

END exam_utils;
/
