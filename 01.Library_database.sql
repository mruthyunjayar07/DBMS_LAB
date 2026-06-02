/* LIBRARY DATABASE SYSTEM
   Includes: Table Creation, Data Insertion, and Queries 1-6
*/

-------------------------------------------------------
-- 1. TABLE CREATION (DDL)
-------------------------------------------------------

CREATE TABLE PUBLISHER (
    Name VARCHAR(100) PRIMARY KEY,
    Address VARCHAR(255),
    Phone VARCHAR(15)
);

CREATE TABLE BOOK (
    Book_id INT PRIMARY KEY,
    Title VARCHAR(255),
    Publisher_Name VARCHAR(100),
    Pub_Year INT,
    FOREIGN KEY (Publisher_Name) REFERENCES PUBLISHER(Name) ON DELETE CASCADE
);

CREATE TABLE BOOK_AUTHORS (
    Book_id INT,
    Author_Name VARCHAR(100),
    PRIMARY KEY (Book_id, Author_Name),
    FOREIGN KEY (Book_id) REFERENCES BOOK(Book_id) ON DELETE CASCADE
);

CREATE TABLE LIBRARY_BRANCH (
    Branch_id INT PRIMARY KEY,
    Branch_Name VARCHAR(100),
    Address VARCHAR(255)
);

CREATE TABLE BOOK_COPIES (
    Book_id INT,
    Branch_id INT,
    No_of_Copies INT,
    PRIMARY KEY (Book_id, Branch_id),
    FOREIGN KEY (Book_id) REFERENCES BOOK(Book_id) ON DELETE CASCADE,
    FOREIGN KEY (Branch_id) REFERENCES LIBRARY_BRANCH(Branch_id) ON DELETE CASCADE
);

CREATE TABLE BOOK_LENDING (
    Book_id INT,
    Branch_id INT,
    Card_No INT,
    Date_Out DATE,
    Due_Date DATE,
    PRIMARY KEY (Book_id, Branch_id, Card_No),
    FOREIGN KEY (Book_id) REFERENCES BOOK(Book_id) ON DELETE CASCADE,
    FOREIGN KEY (Branch_id) REFERENCES LIBRARY_BRANCH(Branch_id) ON DELETE CASCADE
);

-------------------------------------------------------
-- 2. INSERTING SAMPLE DATA (5 RECORDS PER CATEGORY)
-------------------------------------------------------

INSERT INTO PUBLISHER VALUES
    ('Pearson', 'New York', '123456'),
    ('O-Reilly', 'California', '789012'),
    ('McGraw Hill', 'New Delhi', '456789');

INSERT INTO BOOK VALUES
    (101, 'DBMS Basics', 'Pearson', 2021),
    (102, 'Python Pro', 'O-Reilly', 2020),
    (103, 'SQL Mastery', 'Pearson', 2022),
    (104, 'AI Ethics', 'O-Reilly', 2019),
    (105, 'Data Science', 'McGraw Hill', 2020);

INSERT INTO BOOK_AUTHORS VALUES
    (101, 'Navathe'),
    (102, 'Mark Lutz'),
    (103, 'S. Sudarshan'),
    (104, 'Timnit Gebru'),
    (105, 'DJ Patil');

INSERT INTO LIBRARY_BRANCH VALUES
    (1, 'Central', 'Downtown'),
    (2, 'East End', 'Suburbs');

INSERT INTO BOOK_COPIES VALUES
    (101, 1, 10),
    (101, 2, 5),
    (102, 1, 7),
    (103, 1, 12),
    (104, 2, 8);

INSERT INTO BOOK_LENDING VALUES
    (101, 1, 501, '2021-01-10', '2021-01-25'),
    (102, 1, 501, '2021-02-10', '2021-02-25'),
    (103, 1, 501, '2021-03-10', '2021-03-25'),
    (104, 1, 501, '2021-04-10', '2021-04-25'),
    (105, 2, 502, '2022-01-05', '2022-01-20');


-------------------------------------------------------
-- 3. QUERIES
-------------------------------------------------------

-- Q1: Retrieve all book details
SELECT B.Book_id, B.Title, B.Publisher_Name, A.Author_Name, C.Branch_id, C.No_of_Copies
FROM BOOK B
JOIN BOOK_AUTHORS A ON B.Book_id = A.Book_id
JOIN BOOK_COPIES C ON B.Book_id = C.Book_id;

-- Q2: Borrowers who borrowed more than 3 books (Jan 2020 to Jun 2022)
SELECT Card_No
FROM BOOK_LENDING
WHERE Date_Out BETWEEN '2020-01-01' AND '2022-06-30'
GROUP BY Card_No
HAVING COUNT(*) > 3;

-- Q3: Delete a book and Update tables
-- This demonstrates DML. Note: Cascade will handle child tables.
DELETE FROM BOOK WHERE Book_id = 105;
UPDATE BOOK SET Title = 'Advanced SQL Mastery' WHERE Book_id = 103;

-- Q4: View for BOOK based on year of publication
CREATE VIEW BOOKS_2020_PLUS AS
SELECT Book_id, Title, Pub_Year 
FROM BOOK 
WHERE Pub_Year >= 2020;

-- Demonstrate working for Q4
SELECT * FROM BOOKS_2020_PLUS;

-- Q5: View of books and total number of copies currently available
CREATE VIEW BOOK_INVENTORY AS
SELECT B.Title, SUM(C.No_of_Copies) AS Total_Copies
FROM BOOK B
JOIN BOOK_COPIES C ON B.Book_id = C.Book_id
GROUP BY B.Title;

-- Demonstrate working for Q5
SELECT * FROM BOOK_INVENTORY;

-- Q6: Demonstrate usage of view creation (Filtering via view)
-- Here we use the view created in Q5 to find books with low stock
SELECT Title 
FROM BOOK_INVENTORY 
WHERE Total_Copies < 10;
