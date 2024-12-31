---------------------------Triggers------------------------
	
CREATE TRIGGER trg_Departments_Delete
ON Departments
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Employees WHERE department_id IN (SELECT id FROM deleted)
    )
    BEGIN
        RAISERROR('Cannot delete department with assigned employees.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        DELETE FROM Departments WHERE id IN (SELECT id FROM deleted);
    END
END; 

DELETE FROM Departments WHERE id = 1

------------------------------------------------

CREATE TRIGGER trg_Courses_Update
ON Courses
FOR UPDATE
AS
BEGIN
    -- Check if the hours column in the updated rows is less than 10
    IF EXISTS (SELECT 1 FROM inserted WHERE hours < 10)
    BEGIN
        -- Raise an error message and roll back the transaction
        RAISERROR('Courses must have at least 10 hours.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

UPDATE Courses 
SET hours = 5 
WHERE id = 5

-------------------------------------------------------

CREATE TRIGGER prevent_delete_level4
ON student
FOR DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM deleted
        WHERE level_id = 4
    )
    BEGIN
        RAISERROR ('Deletion is not allowed for students in level 4.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

DELETE FROM Student 
WHERE level_id = 4

----------------------------------------------------------------

CREATE TRIGGER set_failed_status
ON studentexams
AFTER INSERT, UPDATE
AS
BEGIN
    -- Update status to 'failed' if grade is F
    UPDATE studentexams
    SET status = CASE
                   WHEN grade = 'F' THEN 'failed'
                   ELSE 'passed'
                 END
    WHERE student_id IN (SELECT student_id FROM inserted)
      AND exam_id IN (SELECT exam_id FROM inserted);
END;

--------------------------------------------- queries

-------1. number of students in each level  
SELECT l.name AS level_name, COUNT(s.id) AS student_count
FROM Levels l INNER JOIN Student s ON s.level_id = l.id
GROUP BY l.name;


----------2. number of courses and their names that each proff teach   3   
SELECT
    e.name AS professor_name,
    COUNT(cp.course_id) AS course_count,
    STRING_AGG(c.name, ', ') AS course_names
FROM Employees e
INNER JOIN Professors p ON e.id = p.employee_id
INNER JOIN CoursesProfessors cp ON p.employee_id = cp.professor_id
INNER JOIN Courses c ON cp.course_id = c.id
GROUP BY e.name;


-------3. profs that do not manage a department
SELECT e.name AS professor_name
FROM Employees e
INNER JOIN Professors p ON e.id = p.employee_id LEFT JOIN Departments d ON d.manager_id = p.employee_id
WHERE d.id IS NULL;

