-- Найти день в который было рожденно наибольшее количество сотрудников в нашей компании.
USE HomeWork;

IF OBJECT_ID('dbo.EmployeeBirthDays', 'U') IS NOT NULL
    DROP TABLE dbo.EmployeeBirthDays;

CREATE TABLE [EmployeeBirthDays]
(
    [EmployeeId] INT PRIMARY KEY,
    [FirstName]  NVARCHAR(50) NOT NULL,
    [LastName]   NVARCHAR(50) NOT NULL,
    [BirthDate]  DATE NOT NULL
);


INSERT INTO dbo.EmployeeBirthDays (EmployeeId, FirstName, LastName, BirthDate) VALUES
-- 5 человек в одну дату
(2001, N'Emp201', N'User201', '1990-01-15'),
(2002, N'Emp202', N'User202', '1990-01-15'),
(2003, N'Emp203', N'User203', '1990-01-15'),
(2004, N'Emp204', N'User204', '1990-01-15'),
(2005, N'Emp205', N'User205', '1990-01-15'),

-- 3 человека в одну дату
(2006, N'Emp206', N'User206', '1991-03-08'),
(2007, N'Emp207', N'User207', '1991-03-08'),
(2008, N'Emp208', N'User208', '1991-03-08'),

-- 2 человека в одну дату
(2009, N'Emp209', N'User209', '1988-05-01'),
(2010, N'Emp210', N'User210', '1988-05-01'),

-- остальные 10 — произвольно
(2011, N'Emp211', N'User211', '1985-12-31'),
(2012, N'Emp212', N'User212', '1986-06-01'),
(2013, N'Emp213', N'User213', '1987-09-01'),
(2014, N'Emp214', N'User214', '1989-11-11'),
(2015, N'Emp215', N'User215', '1990-02-14'),
(2016, N'Emp216', N'User216', '1992-06-12'),
(2017, N'Emp217', N'User217', '1993-04-01'),
(2018, N'Emp218', N'User218', '1994-07-07'),
(2019, N'Emp219', N'User219', '1995-10-10'),
(2020, N'Emp220', N'User220', '1996-08-24'),
(2021, N'Emp221', N'User221', '1994-08-24'),
(2022, N'Emp222', N'User222', '1997-08-24'),
(2023, N'Emp223', N'User223', '1991-08-24'),
(2024, N'Emp224', N'User224', '1992-08-24'),
(2025, N'Emp225', N'User225', '1991-08-24');


SELECT * FROM EmployeeBirthDays


SELECT TOP 1 
       DAY(BirthDate) AS BirthDay,
       MONTH(BirthDate) AS BirthMonth,
       YEAR(BirthDate) AS BirthYear,
       COUNT(*) AS CountOfEmployees
FROM dbo.EmployeeBirthDays AS EBD
GROUP BY DAY(BirthDate), MONTH(BirthDate), YEAR(BirthDate)
ORDER BY CountOfEmployees DESC;

SELECT TOP (1) WITH TIES
       DAY(BirthDate)   AS BirthDay,
       MONTH(BirthDate) AS BirthMonth,
       COUNT(*)         AS CountOfEmployees
FROM dbo.EmployeeBirthDays
GROUP BY MONTH(BirthDate), DAY(BirthDate)
ORDER BY COUNT(*) DESC;
