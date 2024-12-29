------------------------------- Stored Procedure --------------------------
-- Add new student to Student table

CREATE PROCEDURE setStudent
    @StudName VARCHAR(255),
    @Address VARCHAR(50),
    @Email VARCHAR(50),
    @phone VARCHAR(50),
	@Gender VARCHAR(50),
	@DOB DATE, 
	@DeptId INT,
	@LevelId INT,
	@ScholarId INT
AS
BEGIN
    INSERT INTO [student] (name, DOB, gender, address, phone, email, department_id, level_id,Scholar_id)
    VALUES (@StudName, @DOB, @Gender, @Address, @phone, @Email, @DeptId, @LevelId,@ScholarId);
END;

EXEC setStudent
    @StudName = 'John Doe',
    @Address = '123 Main St',
    @Email = 'johndoe@example.com',
    @phone = '123-456-7890',
    @Gender = 'Male',
    @DOB = '2000-01-01',
    @DeptId = 1,
    @LevelId = 2,
    @ScholarId = 3;

SELECT * FROM Student

-----------------------------------------------------------------------------------------------------------
-- Get all students
CREATE PROCEDURE GetAllStudents

AS
BEGIN
    SELECT id , name , address , gender , DOB , phone , email , department_id , level_id , Scholar_id
    FROM Student
END;

EXEC GetAllStudents
-------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetOneStudent
	@studId int
AS
BEGIN
    SELECT *
    FROM Student
	where id = @studId
END;

EXEC GetOneStudent 2
-------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE DeleteStudent 
	@studId INT 
AS
BEGIN
    DELETE FROM Student
	WHERE id = @studId
END;

EXEC DeleteStudent  6
--------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE UpdateStudent
	@studId int,
    @StudName VARCHAR(255),
    @Address VARCHAR(50),
    @Email VARCHAR(50),
    @phone VARCHAR(50),
	@Gender VARCHAR(50),
	@DOB DATE, 
	@DeptId INT,
	@LevelId INT,
	@ScholarId INT
AS
BEGIN
    UPDATE [student]
    SET name = @StudName, DOB = @DOB, 
		gender = @Gender, address = @Address, 
		phone = @phone, email = @Email, 
		department_id = @DeptId, level_id = @LevelId,
		Scholar_id = @ScholarId
	WHERE Id = @studId;
END;

--EXEC UpdateStudent BLA BLA
----------------------------------------------------------------------------


CREATE PROCEDURE GetStudentWithName
    @studName VARCHAR(50)
AS
BEGIN
    SELECT  id , name , address , gender , DOB , phone , email , department_id , level_id , Scholar_id
    FROM Student
    WHERE name LIKE '%' + @studName + '%'
END;

EXEC GetStudentWithName @studName = 'Michael Brown' 
-------------------------------------------------------------------------------
CREATE PROCEDURE Getlevel
AS
BEGIN
    SELECT id , name 
    FROM Levels
END;

EXEC Getlevel
-------------------------------------------------------------------------------------
CREATE PROCEDURE GetScholarships
AS
BEGIN
    SELECT id , name 
    FROM Scholarships
END;

EXEC GetScholarships
----------------------------------------------------------------------------------------
CREATE PROCEDURE GetDepartments
AS
BEGIN
    SELECT id , name 
    FROM Departments
END;

EXEC GetDepartments
-----------------------------------------------------------------------------------------
CREATE PROCEDURE GetCoursec
AS
BEGIN
    SELECT id , name 
    FROM Courses
END;

EXEC GetCoursec
-----------------------------------------------------------------------------------------
CREATE PROCEDURE GetStudWithGrade
	@grade VARCHAR(2),
	@courseId VARCHAR(50),
	@levelId INT
AS
BEGIN
		SELECT  id , name , address , gender , DOB , phone , email , department_id , level_id , Scholar_id 
        FROM Student 
        WHERE id IN (
            SELECT student_id 
            FROM StudentExams 
            WHERE grade = @grade 
              AND exam_id IN (
                  SELECT id 
                  FROM Exams 
                  WHERE course_id = @courseId AND level_id = @levelId
              )
        ) 
          AND level_id = @levelId;
END;

EXEC GetStudWithGrade 'A' , 2 ,1
---------------------------------------------------------------------------------------
---------------------------------------Views------------------------------------
CREATE VIEW Schedule AS
SELECT 
    C.[name] AS CourseName,
    P.[name] AS PlaceName,
    L.[day] AS [Day],
    L.start_time AS StartTime,
    L.end_time AS EndTime
FROM 
    Lectures L
JOIN 
    Courses C ON L.course_id = C.id
JOIN 
    Places P ON L.place_id = P.id;


SELECT * FROM Schedule

---------------------------------------------------

CREATE VIEW CourseDetails AS
SELECT 
    C.[name] AS CourseName,
    C.[hours] AS [Hours],
    L.[name] AS LevelName,
    D.[name] AS DepartmentName
FROM 
    Courses C
JOIN 
    Levels L ON C.level_id = L.id
JOIN 
    Departments D ON C.department_id = D.id;

SELECT * FROM CourseDetails
---------------------------------------------------

CREATE VIEW ExamResults AS
SELECT 
    S.[name] AS StudentName,
    E.[date] AS ExamDate,
    E.[type] AS ExamType,
    SE.[status] AS [Status],
    SE.grade AS Grade
FROM 
    StudentExams SE
JOIN 
    Exams E ON SE.exam_id = E.id
JOIN 
    Student S ON SE.student_id = S.id;

SELECT * FROM ExamResults

-------------------------------------------

CREATE VIEW StudentBooks AS
SELECT 
    B.title AS BookTitle,
    B.author AS Author,
    C.[name] AS CourseName
FROM 
    Books B
JOIN 
    Courses C ON B.course_id = C.id;

SELECT * FROM StudentBooks

-------------------------------------

CREATE VIEW StudentsCountByDepartment AS
SELECT 
    D.[name] AS DepartmentName,
    COUNT(S.id) AS StudentCount
FROM 
    Departments D
LEFT JOIN 
    Student S ON S.department_id = D.id
GROUP BY 
    D.[name];

SELECT * FROM StudentsCountByDepartment

-------------------------------------

CREATE VIEW ProfessorsOverview AS
SELECT 
    E.[name] AS ProfessorName,
	C.[name] AS CourseName,
    D.[name] AS DepartmentName,
    L.[name] AS LevelName
FROM 
    Professors P
JOIN 
    Employees E ON P.employee_id = E.id
JOIN 
    CoursesProfessors CP ON P.employee_id = CP.professor_id
JOIN 
    Courses C ON CP.course_id = C.id
JOIN 
    Levels L ON C.level_id = L.id
JOIN 
    Departments D ON C.department_id = D.id

SELECT * FROM ProfessorsOverview
