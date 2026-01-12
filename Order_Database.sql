/* ORDER DATABASE SYSTEM
   Includes: Table Creation, Data Insertion, and Queries 1-6
*/

-------------------------------------------------------
-- 1. SCHEMA CREATION (DDL)
-------------------------------------------------------

CREATE TABLE SALESMAN (
    Salesman_id INT PRIMARY KEY,
    Name VARCHAR(50),
    City VARCHAR(50),
    Commission DECIMAL(5,2)
);

CREATE TABLE CUSTOMER (
    Customer_id INT PRIMARY KEY,
    Cust_Name VARCHAR(50),
    City VARCHAR(50),
    Grade INT,
    Salesman_id INT,
    FOREIGN KEY (Salesman_id) REFERENCES SALESMAN(Salesman_id) ON DELETE SET NULL
);

CREATE TABLE ORDERS (
    Ord_No INT PRIMARY KEY,
    Purchase_Amt DECIMAL(10,2),
    Ord_Date DATE,
    Customer_id INT,
    Salesman_id INT,
    -- ON DELETE CASCADE ensures orders are removed when the salesman is deleted (Req #5)
    FOREIGN KEY (Customer_id) REFERENCES CUSTOMER(Customer_id) ON DELETE CASCADE,
    FOREIGN KEY (Salesman_id) REFERENCES SALESMAN(Salesman_id) ON DELETE CASCADE
);

-------------------------------------------------------
-- 2. DATA INSERTION (5 Sample Records)
-------------------------------------------------------

INSERT INTO SALESMAN VALUES (1000, 'John Doe', 'Bangalore', 15.00);
INSERT INTO SALESMAN VALUES (1001, 'Jane Smith', 'Mysore', 12.50);
INSERT INTO SALESMAN VALUES (1002, 'Ravi Kumar', 'Bangalore', 10.00);
INSERT INTO SALESMAN VALUES (1003, 'Anita Rao', 'Chennai', 11.00);
INSERT INTO SALESMAN VALUES (1004, 'Chris Gayle', 'Mumbai', 14.00);

INSERT INTO CUSTOMER VALUES (501, 'Tech Corp', 'Bangalore', 100, 1000);
INSERT INTO CUSTOMER VALUES (502, 'Global Inc', 'Mumbai', 200, 1001);
INSERT INTO CUSTOMER VALUES (503, 'A1 Services', 'Bangalore', 150, 1000);
INSERT INTO CUSTOMER VALUES (504, 'Retail Mart', 'Delhi', 100, 1002);
INSERT INTO CUSTOMER VALUES (505, 'Design Co', 'Bangalore', 300, 1001);

INSERT INTO ORDERS VALUES (201, 5000, '2023-10-01', 501, 1000);
INSERT INTO ORDERS VALUES (202, 2500, '2023-10-01', 503, 1000);
INSERT INTO ORDERS VALUES (203, 7500, '2023-10-02', 502, 1001);
INSERT INTO ORDERS VALUES (204, 1000, '2023-10-02', 504, 1002);
INSERT INTO ORDERS VALUES (205, 9000, '2023-10-03', 505, 1001);

-------------------------------------------------------
-- 3. SQL QUERIES
-------------------------------------------------------

-- Q1: Count the customers with grades above Bangalore’s average
SELECT COUNT(*) AS High_Grade_Customers
FROM CUSTOMER
WHERE Grade > (SELECT AVG(Grade) FROM CUSTOMER WHERE City = 'Bangalore');

-- Q2: Find the name and numbers of all salesmen who had more than one customer
SELECT s.Salesman_id, s.Name
FROM SALESMAN s
JOIN CUSTOMER c ON s.Salesman_id = c.Salesman_id
GROUP BY s.Salesman_id, s.Name
HAVING COUNT(*) > 1;

-- Q3: List all salesmen and indicate those who have/don’t have customers in their cities
-- (Using UNION operation)
SELECT s.Name AS Salesman_Name, 'YES' AS Has_Customer_In_City
FROM SALESMAN s
WHERE EXISTS (
    SELECT 1 
    FROM CUSTOMER c 
    WHERE c.City = s.City 
    AND c.Salesman_id = s.Salesman_id
)

UNION

SELECT s.Name AS Salesman_Name, 'NO' AS Has_Customer_In_City
FROM SALESMAN s
WHERE NOT EXISTS (
    SELECT 1 
    FROM CUSTOMER c 
    WHERE c.City = s.City 
    AND c.Salesman_id = s.Salesman_id
);

-- Q4: Create view for salesman with the highest order of a day
CREATE VIEW TopSalesmanPerDay AS
SELECT o.Ord_Date, s.Name, c.Cust_Name, o.Purchase_Amt
FROM ORDERS o
JOIN SALESMAN s ON s.Salesman_id = o.Salesman_id
JOIN CUSTOMER c ON c.Customer_id = o.Customer_id
WHERE o.Purchase_Amt = (
    SELECT MAX(Purchase_Amt) 
    FROM ORDERS 
    WHERE Ord_Date = o.Ord_Date
);

-- Demonstrate view
SELECT * FROM TOP_SALES_PER_DAY;

-- Q5: Delete salesman with id 1000 (Cascades to ORDERS)
DELETE FROM SALESMAN WHERE Salesman_id = 1000;

-- Demonstrate deletion (The orders 201 and 202 should be gone)
SELECT * FROM ORDERS;

-- Q6: Create an index on Customer(Customer_id)
CREATE INDEX idx_cust_id ON CUSTOMER(Customer_id);

-- Demonstrate usage (Engine uses index for filtering)
SELECT * FROM CUSTOMER WHERE Customer_id = 502;
