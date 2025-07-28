-- 1. Ümumi maliyyələşməsi 100000-dən çox olan binaların nömrələri
SELECT Building
FROM Departments
GROUP BY Building
HAVING SUM(Financing) > 100000;

-- 2. Software Development departamentinin 5-ci kurs qrupları (ilk həftədə 10-dan çox cüt dərsi olan)
SELECT G.Name
FROM Groups G
JOIN Departments D ON G.DepartmentId = D.Id
JOIN GroupsLectures GL ON G.Id = GL.GroupId
JOIN Lectures L ON GL.LectureId = L.Id
WHERE G.Year = 5
AND D.Name = 'Software Development'
AND DATEPART(WEEK, L.Date) = 1
GROUP BY G.Name
HAVING COUNT(*) > 10;

-- 3. Reytinqi "D221" qrupundan yüksək olan qruplar
SELECT G.Name
FROM Groups G
JOIN GroupsStudents GS ON G.Id = GS.GroupId
JOIN Students S ON GS.StudentId = S.Id
GROUP BY G.Id, G.Name
HAVING AVG(S.Rating) > (
SELECT AVG(S.Rating)
FROM Groups G2
JOIN GroupsStudents GS2 ON G2.Id = GS2.GroupId
JOIN Students S ON GS2.StudentId = S.Id
WHERE G2.Name = 'D221'
);

-- 4. Maaşı professorların ortalama maaşından yüksək olan müəllimlər
SELECT Name + ' ' + Surname AS FullName
FROM Teachers
WHERE Salary > (
SELECT AVG(Salary)
FROM Teachers
WHERE IsProfessor = 1
);

-- 5. Bir neçə kuratoru olan qruplar
SELECT G.Name
FROM Groups G
JOIN GroupsCurators GC ON G.Id = GC.GroupId
GROUP BY G.Id, G.Name
HAVING COUNT(GC.CuratorId) > 1;

-- 6. Reytinqi 5-ci kurs minimumundan aşağı olan qruplar
SELECT G.Name
FROM Groups G
JOIN GroupsStudents GS ON G.Id = GS.GroupId
JOIN Students S ON GS.StudentId = S.Id
GROUP BY G.Id, G.Name
HAVING AVG(S.Rating) < (
SELECT MIN(AvgRating)
FROM (
    SELECT AVG(S.Rating) AS AvgRating
    FROM Groups G2
    JOIN GroupsStudents GS2 ON G2.Id = GS2.GroupId
    JOIN Students S ON GS2.StudentId = S.Id
    WHERE G2.Year = 5
    GROUP BY G2.Id
) AS Sub
);

-- 7. Maliyyəsi "Computer Science" departamentindən çox olan fakültələr
SELECT F.Name
FROM Faculties F
JOIN Departments D ON D.FacultyId = F.Id
GROUP BY F.Id, F.Name
HAVING SUM(D.Financing) > (
    SELECT SUM(D.Financing)
    FROM Departments D
    WHERE D.Name = 'Computer Science'
);

-- 8. Ən çox mühazirə verilən fənlər və müəllimlər
SELECT TOP 1 WITH TIES S.Name AS SubjectName,T.Name + ' ' + T.Surname AS TeacherFullName,
COUNT(*) AS LectureCount
FROM Lectures L
JOIN Subjects S ON L.SubjectId = S.Id
JOIN Teachers T ON L.TeacherId = T.Id
GROUP BY S.Name, T.Name, T.Surname
ORDER BY COUNT(*) DESC;

-- 9. Ən az mühazirə keçirilən fənnin adı
SELECT TOP 1 WITH TIES S.Name
FROM Lectures L
JOIN Subjects S ON L.SubjectId = S.Id
GROUP BY S.Name
ORDER BY COUNT(*) ASC;

-- 10. Software Development departamentində tələbə və fənn sayı
SELECT 
    (SELECT COUNT(DISTINCT GS.StudentId)
     FROM Groups G
     JOIN Departments D ON G.DepartmentId = D.Id
     JOIN GroupsStudents GS ON G.Id = GS.GroupId
     WHERE D.Name = 'Software Development') AS StudentCount,

    (SELECT COUNT(DISTINCT L.SubjectId)
     FROM Groups G
     JOIN Departments D ON G.DepartmentId = D.Id
     JOIN GroupsLectures GL ON G.Id = GL.GroupId
     JOIN Lectures L ON GL.LectureId = L.Id
     WHERE D.Name = 'Software Development') AS SubjectCount;