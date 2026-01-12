-- 1. Create tables with basic constraints first
-- We define MgrSSN without the constraint here to avoid the circular reference error
CREATE TABLE DEPARTMENT (
    DNo INT PRIMARY KEY,
    DName VARCHAR(50),
    MgrSSN CHAR(9), 
    MgrStartDate DATE
);

-- 2. Create EMPLOYEE with its reference to DEPARTMENT
CREATE TABLE EMPLOYEE (
    SSN CHAR(9) PRIMARY KEY,
    Name VARCHAR(50),
    Address VARCHAR(100),
    Sex CHAR(1),
    Salary DECIMAL(10, 2),
    SuperSSN CHAR(9),
    DNo INT,
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo),
    FOREIGN KEY (SuperSSN) REFERENCES EMPLOYEE(SSN)
);

-- 3. Create other dependent tables
CREATE TABLE DLOCATION (
    DNo INT,
    DLoc VARCHAR(50),
    PRIMARY KEY (DNo, DLoc),
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo)
);

CREATE TABLE PROJECT (
    PNo INT PRIMARY KEY,
    PName VARCHAR(50),
    PLocation VARCHAR(50),
    DNo INT,
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo)
);

CREATE TABLE WORKS_ON (
    SSN CHAR(9),
    PNo INT,
    Hours DECIMAL(4, 1),
    PRIMARY KEY (SSN, PNo),
    FOREIGN KEY (SSN) REFERENCES EMPLOYEE(SSN),
    FOREIGN KEY (PNo) REFERENCES PROJECT(PNo)
);

---
-- DATA INSERTION (Order Matters!)
---

-- First, insert Departments with NULL for MgrSSN
INSERT INTO DEPARTMENT (DNo, DName, MgrSSN, MgrStartDate) VALUES (1, 'Accounts', NULL, '2020-01-01');
INSERT INTO DEPARTMENT (DNo, DName, MgrSSN, MgrStartDate) VALUES (2, 'IT', NULL, '2020-02-01');

-- Now insert Employees (who now have departments to point to)
INSERT INTO EMPLOYEE (SSN, Name, Address, Sex, Salary, SuperSSN, DNo) VALUES 
('E1', 'Alice Scott', '123 Lane', 'F', 700000, NULL, 1),
('E2', 'James Scott', '456 Road', 'M', 500000, 'E1', 2),
('E3', 'Bob Smith', '789 Blvd', 'M', 650000, 'E1', 1),
('E4', 'Charlie Black', '101 Ave', 'M', 400000, 'E2', 2),
('E5', 'Diana Prince', '202 Street', 'F', 800000, 'E1', 1),
('E6', 'Edward Nygma', '303 Drive', 'M', 300000, 'E2', 1);

-- Finally, update the Department managers (Now that the Employees exist)
UPDATE DEPARTMENT SET MgrSSN = 'E1' WHERE DNo = 1;
UPDATE DEPARTMENT SET MgrSSN = 'E2' WHERE DNo = 2;

-- Rest of the data
INSERT INTO PROJECT VALUES 
(10, 'IoT', 'Bangalore', 2),
(20, 'Audit', 'Mysore', 1),
(30, 'Taxation', 'Bangalore', 1);

INSERT INTO WORKS_ON VALUES 
('E2', 10, 40.0),
('E4', 10, 20.0),
('E1', 20, 10.0),
('E1', 30, 10.0);
---
-- 2. DATA INSERTION
---

-- Note: Insertions follow a specific order to satisfy Foreign Key constraints
INSERT INTO DEPARTMENT (DNo, DName, MgrSSN, MgrStartDate) VALUES (1, 'Accounts', NULL, '2020-01-01');
INSERT INTO DEPARTMENT (DNo, DName, MgrSSN, MgrStartDate) VALUES (2, 'IT', NULL, '2020-02-01');

INSERT INTO EMPLOYEE (SSN, Name, Address, Sex, Salary, SuperSSN, DNo) VALUES 
('E1', 'Alice Scott', '123 Lane', 'F', 700000, NULL, 1),
('E2', 'James Scott', '456 Road', 'M', 500000, 'E1', 2),
('E3', 'Bob Smith', '789 Blvd', 'M', 650000, 'E1', 1),
('E4', 'Charlie Black', '101 Ave', 'M', 400000, 'E2', 2),
('E5', 'Diana Prince', '202 Street', 'F', 800000, 'E1', 1),
('E6', 'Edward Nygma', '303 Drive', 'M', 300000, 'E2', 1);

-- Update Managers
UPDATE DEPARTMENT SET MgrSSN = 'E1' WHERE DNo = 1;
UPDATE DEPARTMENT SET MgrSSN = 'E2' WHERE DNo = 2;

INSERT INTO PROJECT VALUES 
(10, 'IoT', 'Bangalore', 2),
(20, 'Audit', 'Mysore', 1),
(30, 'Taxation', 'Bangalore', 1);

INSERT INTO WORKS_ON VALUES 
('E2', 10, 40.0),
('E4', 10, 20.0),
('E1', 20, 10.0),
('E1', 30, 10.0);

---
-- 3. SQL QUERIES
---

-- Query 1: Projects involving 'Scott' as worker or manager
SELECT DISTINCT P.PNo
FROM PROJECT P
WHERE P.PNo IN (
    -- Case: Scott is a worker on the project
    SELECT W.PNo 
    FROM WORKS_ON W JOIN EMPLOYEE E ON W.SSN = E.SSN 
    WHERE E.Name LIKE '%Scott'
) OR P.DNo IN (
    -- Case: Scott is the manager of the department controlling the project
    SELECT D.DNo 
    FROM DEPARTMENT D JOIN EMPLOYEE E ON D.MgrSSN = E.SSN 
    WHERE E.Name LIKE '%Scott'
);

-- Query 2: Show 10% raised salaries for employees on 'IoT' project
SELECT E.Name, E.Salary AS Old_Salary, (E.Salary * 1.10) AS Raised_Salary
FROM EMPLOYEE E
JOIN WORKS_ON W ON E.SSN = W.SSN
JOIN PROJECT P ON W.PNo = P.PNo
WHERE P.PName = 'IoT';

-- Query 3: Aggregates for 'Accounts' department
SELECT SUM(Salary) AS Total_Salary, MAX(Salary) AS Max_Salary, 
       MIN(Salary) AS Min_Salary, AVG(Salary) AS Avg_Salary
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNo = D.DNo
WHERE D.DName = 'Accounts';

-- Query 4: Employees who work on ALL projects controlled by their department
SELECT E.Name
FROM EMPLOYEE E
WHERE NOT EXISTS (
    SELECT P.PNo 
    FROM PROJECT P 
    WHERE P.DNo = E.DNo
    AND NOT EXISTS (
        SELECT W.PNo 
        FROM WORKS_ON W 
        WHERE W.PNo = P.PNo AND W.SSN = E.SSN
    )
);

-- Query 5: Departments > 5 employees, count those earning > 6,00,000
SELECT E1.DNo, COUNT(*) AS Rich_Employee_Count
FROM EMPLOYEE E1
WHERE E1.Salary > 600000 AND E1.DNo IN (
    SELECT DNo 
    FROM EMPLOYEE 
    GROUP BY DNo 
    HAVING COUNT(*) > 5
)
GROUP BY E1.DNo;
