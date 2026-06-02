/* COLLEGE DATABASE SYSTEM 
   Includes: Table Creation, Data Insertion, and Queries 1-5
*/

-------------------------------------------------------
-- 1. SCHEMA CREATION (DDL)
-------------------------------------------------------

CREATE TABLE STUDENT (
    USN VARCHAR(10) PRIMARY KEY,
    SName VARCHAR(50),
    Address VARCHAR(100),
    Phone VARCHAR(15),
    Gender CHAR(1)
);

CREATE TABLE SEMSEC (
    SSID VARCHAR(5) PRIMARY KEY,
    Sem INT,
    Sec CHAR(1)
);

CREATE TABLE CLASS (
    USN VARCHAR(10),
    SSID VARCHAR(5),
    PRIMARY KEY (USN, SSID),
    FOREIGN KEY (USN) REFERENCES STUDENT(USN) ON DELETE CASCADE,
    FOREIGN KEY (SSID) REFERENCES SEMSEC(SSID) ON DELETE CASCADE
);

CREATE TABLE SUBJECT (
    Subcode VARCHAR(10) PRIMARY KEY,
    Title VARCHAR(50),
    Sem INT,
    Credits INT
);

CREATE TABLE IAMARKS (
    USN VARCHAR(10),
    Subcode VARCHAR(10),
    SSID VARCHAR(5),
    Test1 INT,
    Test2 INT,
    Test3 INT,
    FinalIA INT,
    PRIMARY KEY (USN, Subcode, SSID),
    FOREIGN KEY (USN) REFERENCES STUDENT(USN) ON DELETE CASCADE,
    FOREIGN KEY (Subcode) REFERENCES SUBJECT(Subcode) ON DELETE CASCADE,
    FOREIGN KEY (SSID) REFERENCES SEMSEC(SSID) ON DELETE CASCADE
);

-------------------------------------------------------
-- 2. DATA INSERTION (Sample Records)
-------------------------------------------------------

INSERT INTO STUDENT VALUES ('01JSTIS001', 'Abhishek', 'Mysuru', '988001', 'M');
INSERT INTO STUDENT VALUES ('01JSTIS002', 'Bhavana', 'Bengaluru', '988002', 'F');
INSERT INTO STUDENT VALUES ('01JSTIS003', 'Chaitra', 'Mysuru', '988003', 'F');

INSERT INTO SEMSEC VALUES ('5B', 5, 'B');
INSERT INTO SEMSEC VALUES ('8A', 8, 'A');
INSERT INTO SEMSEC VALUES ('8B', 8, 'B');

INSERT INTO CLASS VALUES ('01JSTIS001', '5B');
INSERT INTO CLASS VALUES ('01JSTIS002', '8A');
INSERT INTO CLASS VALUES ('01JSTIS003', '8B');

INSERT INTO SUBJECT VALUES ('IS51', 'DBMS', 5, 4);
INSERT INTO SUBJECT VALUES ('IS81', 'Big Data', 8, 3);

INSERT INTO IAMARKS (USN, Subcode, SSID, Test1, Test2, Test3) 
VALUES ('01JSTIS001', 'IS51', '5B', 15, 18, 19);
INSERT INTO IAMARKS (USN, Subcode, SSID, Test1, Test2, Test3) 
VALUES ('01JSTIS002', 'IS81', '8A', 10, 12, 11);

-------------------------------------------------------
-- 3. SQL QUERIES
-------------------------------------------------------

-- Q1: Student details in 5th Semester 'B' Section
SELECT S.* FROM STUDENT S
JOIN CLASS C ON S.USN = C.USN
JOIN SEMSEC SS ON C.SSID = SS.SSID
WHERE SS.Sem = 5 AND SS.Sec = 'B';

-- Q2: Count Male and Female students per Semester and Section
SELECT SS.Sem, SS.Sec, S.Gender, COUNT(*) AS Total
FROM STUDENT S
JOIN CLASS C ON S.USN = C.USN
JOIN SEMSEC SS ON C.SSID = SS.SSID
GROUP BY SS.Sem, SS.Sec, S.Gender;

-- Q3: View of Test1 marks for USN '01JSTIS001'
CREATE VIEW Event1_View AS
SELECT s.USN, s.SName, sub.Title, i.Test1
FROM STUDENT s
JOIN IAMARKS i ON s.USN = i.USN
JOIN SUBJECT sub ON i.Subcode = sub.Subcode
WHERE s.USN LIKE '01JSTIS%';

-- Demonstrate View
SELECT * FROM Event1_View;

-- Q4: Calculate Final IA (Average of best two)
-- Logic: (Sum of all three - Minimum value) / 2
UPDATE IAMARKS
SET FinalIA = (
    Test1 + Test2 + Test3 - 
    MIN(Test1, MIN(Test2, Test3))
) / 2;

-- Q5: Categorize 8th Semester (A, B, C) students based on IA
SELECT S.SName, IA.FinalIA,
    CASE 
        WHEN IA.FinalIA BETWEEN 17 AND 20 THEN 'Outstanding'
        WHEN IA.FinalIA BETWEEN 12 AND 16 THEN 'Average'
        ELSE 'Weak'
    END AS CAT
FROM STUDENT S
JOIN IAMARKS IA ON S.USN = IA.USN
JOIN SEMSEC SS ON IA.SSID = SS.SSID
WHERE SS.Sem = 8 AND SS.Sec IN ('A', 'B', 'C');
