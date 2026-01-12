/* MOVIE DATABASE SYSTEM 
   Includes: Table Creation, Data Insertion, and Queries 1-5
*/

-------------------------------------------------------
-- 1. SCHEMA CREATION (DDL)
-------------------------------------------------------

CREATE TABLE ACTOR (
    Act_id INT PRIMARY KEY,
    Act_Name VARCHAR(50),
    Act_Gender CHAR(1)
);

CREATE TABLE DIRECTOR (
    Dir_id INT PRIMARY KEY,
    Dir_Name VARCHAR(50),
    Dir_Phone VARCHAR(15)
);

CREATE TABLE MOVIES (
    Mov_id INT PRIMARY KEY,
    Mov_Title VARCHAR(100),
    Mov_Year INT,
    Mov_Lang VARCHAR(20),
    Dir_id INT,
    FOREIGN KEY (Dir_id) REFERENCES DIRECTOR(Dir_id) ON DELETE CASCADE
);

CREATE TABLE MOVIE_CAST (
    Act_id INT,
    Mov_id INT,
    Role VARCHAR(50),
    PRIMARY KEY (Act_id, Mov_id),
    FOREIGN KEY (Act_id) REFERENCES ACTOR(Act_id) ON DELETE CASCADE,
    FOREIGN KEY (Mov_id) REFERENCES MOVIES(Mov_id) ON DELETE CASCADE
);

CREATE TABLE RATING (
    Mov_id INT PRIMARY KEY,
    Rev_Stars INT,
    FOREIGN KEY (Mov_id) REFERENCES MOVIES(Mov_id) ON DELETE CASCADE
);

-------------------------------------------------------
-- 2. DATA INSERTION (Sample Records)
-------------------------------------------------------

INSERT INTO ACTOR VALUES (1, 'James Stewart', 'M');
INSERT INTO ACTOR VALUES (2, 'Grace Kelly', 'F');
INSERT INTO ACTOR VALUES (3, 'Tom Hanks', 'M');
INSERT INTO ACTOR VALUES (4, 'Leonardo DiCaprio', 'M');
INSERT INTO ACTOR VALUES (5, 'Zendaya', 'F');

INSERT INTO DIRECTOR VALUES (10, 'Hitchcock', '999999');
INSERT INTO DIRECTOR VALUES (11, 'Steven Spielberg', '888888');
INSERT INTO DIRECTOR VALUES (12, 'Christopher Nolan', '777777');

INSERT INTO MOVIES VALUES (501, 'Vertigo', 1958, 'English', 10);
INSERT INTO MOVIES VALUES (502, 'Rear Window', 1954, 'English', 10);
INSERT INTO MOVIES VALUES (503, 'Jaws', 1975, 'English', 11);
INSERT INTO MOVIES VALUES (504, 'Inception', 2010, 'English', 12);
INSERT INTO MOVIES VALUES (505, 'Saving Private Ryan', 1998, 'English', 11);
INSERT INTO MOVIES VALUES (506, 'New Era Movie', 2024, 'English', 12);

-- Actor 3 (Tom Hanks) acts in 1998 and 2024 (for Query 3)
INSERT INTO MOVIE_CAST VALUES (3, 505, 'Captain Miller');
INSERT INTO MOVIE_CAST VALUES (3, 506, 'Lead');
-- Actor 1 acts in two Hitchcock movies (for Query 2)
INSERT INTO MOVIE_CAST VALUES (1, 501, 'Scottie');
INSERT INTO MOVIE_CAST VALUES (1, 502, 'Jeff');

INSERT INTO RATING VALUES (501, 4);
INSERT INTO RATING VALUES (502, 5);
INSERT INTO RATING VALUES (503, 3);
INSERT INTO RATING VALUES (504, 5);

-------------------------------------------------------
-- 3. SQL QUERIES
-------------------------------------------------------

-- Q1: List the titles of all movies directed by ‘Hitchcock’
SELECT Mov_Title 
FROM MOVIES M
JOIN DIRECTOR D ON M.Dir_id = D.Dir_id
WHERE D.Dir_Name = 'Hitchcock';

-- Q2: Find movie names where one or more actors acted in two or more movies
SELECT m.Mov_Title
FROM MOVIES m
JOIN MOVIE_CAST mc ON m.Mov_id = mc.Mov_id
WHERE mc.Act_id IN (
    SELECT Act_id 
    FROM MOVIE_CAST 
    GROUP BY Act_id 
    HAVING COUNT(*) >= 2
)

-- Q3: Actors who acted in a movie before 2000 and also after 2020
-- Using JOIN as requested
SELECT a.Act_Name
FROM ACTOR a
JOIN MOVIE_CAST mc1 ON a.Act_id = mc1.Act_id
JOIN MOVIES m1     ON mc1.Mov_id = m1.Mov_id
JOIN MOVIE_CAST mc2 ON a.Act_id = mc2.Act_id
JOIN MOVIES m2     ON mc2.Mov_id = m2.Mov_id
WHERE m1.Mov_Year < 2000
  AND m2.Mov_Year > 2020

-- Q4: Titles and stars (highest stars) for movies with at least one rating
-- Sorted by title
SELECT m.Mov_Title, r.Rev_Stars
FROM MOVIES m
JOIN RATING r ON m.Mov_id = r.Mov_id
ORDER BY m.Mov_Title

-- Q5: Update rating of all movies directed by ‘Steven Spielberg’ to 5
UPDATE RATING
SET Rev_Stars = 5
WHERE Mov_id IN (
    SELECT Mov_id 
    FROM MOVIES M
    JOIN DIRECTOR D ON M.Dir_id = D.Dir_id
    WHERE D.Dir_Name = 'Steven Spielberg'
);
