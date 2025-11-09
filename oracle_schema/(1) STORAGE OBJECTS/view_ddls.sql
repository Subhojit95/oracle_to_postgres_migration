--------------------------------------------------------
--  DDL for View STUDENT_DISCIPLINARY_LOG
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "UNIVOFFICE"."STUDENT_DISCIPLINARY_LOG" ("STUDENT_ID", "STUDENT_NAME", "FACULTY_NAME", "ACTION_DATE", "DESCRIPTION", "ACTION_DETAILS") AS 
  SELECT
  s.student_id,
  s.name AS student_name,
  f.name AS faculty_name,
  da.action_date,
  da.description,
  da.action_details
FROM students s
JOIN disciplinary_actions da ON s.student_id = da.student_id
JOIN faculty f ON da.faculty_id = f.faculty_id
;

--------------------------------------------------------
--  DDL for View STUDENT_EXAM_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "UNIVOFFICE"."STUDENT_EXAM_SCHEDULE" ("STUDENT_ID", "STUDENT_NAME", "COURSE_NAME", "EXAM_DATE", "SEMESTER_CODE", "SEMESTER_START", "SEMESTER_END") AS 
  SELECT 
  s.student_id,
  s.name AS student_name,
  c.course_name,
  e.exam_date,
  sem.semester_code,
  sem.start_date AS semester_start,
  sem.end_date AS semester_end
FROM students s
JOIN enrollments en ON s.student_id = en.student_id
JOIN courses c ON en.course_id = c.course_id
JOIN exams e ON c.course_id = e.course_id AND en.semester_code = e.semester_code
JOIN semesters sem ON sem.semester_code = en.semester_code
;

--------------------------------------------------------
--  DDL for View STUDENT_HOSTEL_STATUS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "UNIVOFFICE"."STUDENT_HOSTEL_STATUS" ("STUDENT_ID", "STUDENT_NAME", "HOSTEL_NAME", "ROOM_NUMBER", "ALLOCATION_DATE", "CAPACITY") AS 
  SELECT
  s.student_id,
  s.name AS student_name,
  h.name AS hostel_name,
  ha.room_number,
  ha.allocation_date,
  h.capacity
FROM students s
JOIN hostel_allocations ha ON s.student_id = ha.student_id
JOIN hostels h ON ha.hostel_id = h.hostel_id
;