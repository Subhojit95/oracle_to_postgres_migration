-- Schedule an exam
BEGIN
  exam_utils.schedule_exam(501, 201, 'SEM6', DATE '2025-09-20', 'Closed book exam');
END;
/

-- Assign grades
BEGIN
  exam_utils.assign_grade(101, 501, 'A', 'Excellent');
  exam_utils.assign_grade(102, 501, 'B', 'Good');
  exam_utils.assign_grade(103, 501, 'C', 'Average');
END;
/

-- Fetch statistics
SELECT * FROM TABLE(exam_utils.get_exam_statistics(501));