-- ================================================= --
-- 1. TABLE CREATION
-- ================================================= --

CREATE TABLE DEPARTMENT (
    DNo INT PRIMARY KEY,
    DName VARCHAR(50),
    MgrSSN CHAR(9),
    MgrStartDate DATE
);

CREATE TABLE EMPLOYEE (
    SSN CHAR(9) PRIMARY KEY,
    Name VARCHAR(50),
    Address VARCHAR(100),
    Sex CHAR(1),
    Salary DECIMAL(10, 2),
    SuperSSN CHAR(9),
    DNo INT,
  FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo) ON DELETE CASCADE
);

CREATE TABLE DLOCATION (
    DNo INT,
    DLoc VARCHAR(50),
    PRIMARY KEY (DNo, DLoc),
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo) ON DELETE CASCADE
);

CREATE TABLE PROJECT (
    PNo INT PRIMARY KEY,
    PName VARCHAR(50),
    PLocation VARCHAR(50),
    DNo INT ,
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo) ON DELETE CASCADE
);

CREATE TABLE WORKS_ON (
    SSN CHAR(9),
    PNo INT,
    Hours DECIMAL(4,1),
    PRIMARY KEY (SSN, PNo),
    FOREIGN KEY (SSN) REFERENCES EMPLOYEE(SSN) ON DELETE CASCADE,
    FOREIGN KEY (PNo) REFERENCES PROJECT(PNo) ON DELETE CASCADE
);

-- ================================================= --
-- 2. INSERTING VALUES
-- ================================================= --

-- Departments
INSERT INTO DEPARTMENT VALUES (1, 'Accounts', '101', '2020-01-01');
INSERT INTO DEPARTMENT VALUES (5, 'Research', '105', '2021-05-15');

-- Employees (Including 6 for Dept 1 to satisfy Query 5)
INSERT INTO EMPLOYEE VALUES ('101', 'John Scott', 'Bangalore', 'M', 700000, NULL, 1);
INSERT INTO EMPLOYEE VALUES ('102', 'Alice Scott', 'Delhi', 'F', 500000, '101', 5);
INSERT INTO EMPLOYEE VALUES ('103', 'Robert Smith', 'Mumbai', 'M', 800000, '101', 1);
INSERT INTO EMPLOYEE VALUES ('104', 'Suresh Kumar', 'Chennai', 'M', 650000, '101', 1);
INSERT INTO EMPLOYEE VALUES ('105', 'Jane Scott', 'Bangalore', 'F', 620000, '101', 5);
INSERT INTO EMPLOYEE VALUES ('106', 'Emily Davis', 'Mysore', 'F', 610000, '101', 1);
INSERT INTO EMPLOYEE VALUES ('107', 'Michael Oh', 'Kochi', 'M', 900000, '101', 1);
INSERT INTO EMPLOYEE VALUES ('108', 'Rahul Dravid', 'Hubli', 'M', 605000, '101', 1);

-- Projects
INSERT INTO PROJECT VALUES (10, 'IoT', 'Bangalore', 5);
INSERT INTO PROJECT VALUES (20, 'FinTech', 'Mumbai', 1);
INSERT INTO PROJECT VALUES (30, 'DataSync', 'Bangalore', 5);

-- Works On (Employee 102 works on all projects in Dept 5)
INSERT INTO WORKS_ON VALUES ('102', 10, 20.0);
INSERT INTO WORKS_ON VALUES ('102', 30, 15.0);
INSERT INTO WORKS_ON VALUES ('101', 20, 40.0);

-- ================================================= --
-- 3. QUERIES
-- ================================================= --

-- Q1: Projects involving 'Scott' (as worker or manager)
SELECT DISTINCT P.PNo
FROM PROJECT P
WHERE P.DNo IN (SELECT DNo FROM DEPARTMENT WHERE MgrSSN IN (SELECT SSN FROM EMPLOYEE WHERE Name LIKE '%Scott'))
   OR P.PNo IN (SELECT PNo FROM WORKS_ON WHERE SSN IN (SELECT SSN FROM EMPLOYEE WHERE Name LIKE '%Scott'))
    
-- Q2: 10% raise for 'IoT' project workers
SELECT Name, Salary * 1.10 AS New_Salary
FROM EMPLOYEE E, WORKS_ON W, PROJECT P
WHERE E.SSN = W.SSN AND W.PNo = P.PNo AND P.PName = 'IoT';

-- Q3: Stats for 'Accounts'
SELECT SUM(Salary) AS Total, MAX(Salary) AS Max, MIN(Salary) AS Min, AVG(Salary) AS Avg
FROM EMPLOYEE E, DEPARTMENT D
WHERE E.DNo = D.DNo AND D.DName = 'Accounts';

-- Q4: Employee who works on ALL projects controlled by Dept 5
SELECT E.Name FROM EMPLOYEE E
WHERE NOT EXISTS (
    SELECT PNo FROM PROJECT WHERE DNo = 5
    EXCEPT
    SELECT PNo FROM WORKS_ON W WHERE W.SSN = E.SSN
);

-- Q5: Depts with > 5 employees, count employees making > 6,00,000
SELECT DNo, COUNT(SSN)
FROM EMPLOYEE E
WHERE Salary > 600000
  AND NOT EXISTS (
      SELECT 1 FROM EMPLOYEE
      WHERE DNo = E.DNo
      GROUP BY DNo
      HAVING COUNT(*) <= 5
  )
GROUP BY DNo;
