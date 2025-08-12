-- package

create or replace PACKAGE exam_utils AS
  -- Schedule a new exam
  PROCEDURE schedule_exam(
    p_exam_id IN NUMBER,
    p_course_id IN NUMBER,
    p_semester_code IN VARCHAR2,
    p_exam_date IN DATE,
    p_exam_instructions IN VARCHAR2
  );

  -- Assign grade to a student
  PROCEDURE assign_grade(
    p_student_id IN NUMBER,
    p_exam_id IN NUMBER,
    p_grade IN VARCHAR2,
    p_remarks IN VARCHAR2 DEFAULT NULL
  );

  -- Get grade distribution for an exam
  FUNCTION get_exam_statistics(
    p_exam_id IN NUMBER
  ) RETURN grade_stats_tab PIPELINED;
END exam_utils;

-- package body

create or replace PACKAGE BODY exam_utils AS

  PROCEDURE schedule_exam(
    p_exam_id IN NUMBER,
    p_course_id IN NUMBER,
    p_semester_code IN VARCHAR2,
    p_exam_date IN DATE,
    p_exam_instructions IN VARCHAR2
  ) IS
  BEGIN
    INSERT INTO exams (
      exam_id, course_id, semester_code, exam_date, exam_instructions
    ) VALUES (
      p_exam_id, p_course_id, p_semester_code, p_exam_date, p_exam_instructions
    );
  END schedule_exam;

  PROCEDURE assign_grade(
    p_student_id IN NUMBER,
    p_exam_id IN NUMBER,
    p_grade IN VARCHAR2,
    p_remarks IN VARCHAR2 DEFAULT NULL
  ) IS
  BEGIN
    INSERT INTO exam_results (
      student_id, exam_id, grade, remarks
    ) VALUES (
      p_student_id, p_exam_id, p_grade, p_remarks
    );
  END assign_grade;

  FUNCTION get_exam_statistics(
    p_exam_id IN NUMBER
  ) RETURN grade_stats_tab PIPELINED IS
    v_row grade_stats;
  BEGIN
    FOR rec IN (
      SELECT grade, COUNT(*) AS count
      FROM exam_results
      WHERE exam_id = p_exam_id
      GROUP BY grade
    ) LOOP
      v_row := grade_stats(rec.grade, rec.count);
      PIPE ROW(v_row);
    END LOOP;
    RETURN;
  END get_exam_statistics;

END exam_utils;