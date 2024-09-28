-- Table for Province Lookup
CREATE TABLE Province_Lookup (
    Province_ID INT PRIMARY KEY,
    Province_Name VARCHAR(50)
);

-- Table for Average Family Total Income Data
CREATE TABLE Avg_Family_Income_Data (
    Province_ID INT,
    Grp_ID INT,
    Status_ID INT,
    Char_ID INT,
    Year_2019 DECIMAL(10, 2),
    Year_2020 DECIMAL(10, 2)
);

-- Table for Average Sale Price Data
CREATE TABLE Avg_Sale_Price_Data (
    Province_ID INT,
    Grp_ID INT,
    Status_ID INT,
    Char_ID INT,
    Year_2019 DECIMAL(10, 2),
    Year_2020 DECIMAL(10, 2)
);

-- Table for Buyer Characteristics Lookup
CREATE TABLE Buyer_Char_Lookup (
    Char_ID INT PRIMARY KEY,
    Buyer_Characteristics VARCHAR(50)
);

-- Table for Buyer Status Lookup
CREATE TABLE Buyer_Status_Lookup (
    Status_ID INT PRIMARY KEY,
    Buyer_Status VARCHAR(50)
);

-- Table for Buyers Group Type Lookup
CREATE TABLE Buyers_Group_Type_Lookup (
    Grp_ID INT PRIMARY KEY,
    Buyers_Grp_Type VARCHAR(50)
);

-- Table for Property Sold (Num) Data
CREATE TABLE Property_Sold_Num_Data (
    Province_ID INT,
    Grp_ID INT,
    Status_ID INT,
    Char_ID INT,
    Year_2019 INT,
    Year_2020 INT
);

------ ENTERING DATA IN TABLES ------- 

----- Locating local directory of SQL
SHOW data_directory

------------------------------- LOOKUP TABLES -----------------------------------
	
----- Province_Lookup Table
INSERT INTO Province_Lookup (Province_ID, Province_Name) VALUES
(1, 'Nova Scotia'),
(2, 'New Brunswick'),
(3, 'Manitoba'),
(4, 'British Columbia'),
(5, 'Yukon');

-- Buyer_Char_Lookup
INSERT INTO Buyer_Char_Lookup (Char_ID, Buyer_Characteristics) VALUES
(1, 'Male'),
(2, 'Female'),
(3, 'Immigrant 20'),
(4, 'Non-immigrant');

----- Buyers_Status_Lookup 
INSERT INTO Buyer_Status_Lookup (Status_ID, Buyer_Status) VALUES
(1, 'Not first-time home buyer'),
(2, 'First-time home buyer');

----- Buyers_Group_Lookup
INSERT INTO Buyers_Group_Type_Lookup (Grp_ID, Buyers_Grp_Type) VALUES
(1, 'Single buyer'),
(2, 'Paired buyer'),
(3, 'Buyer in a group of three or more');

------------------------------- DATA TABLES -----------------------------------

----- Avg_Sale_Price_Data
COPY avg_sale_price_data(Province_ID, Grp_ID, Status_ID, Char_ID, Year_2019, Year_2020)
FROM 'C:\Program Files\PostgreSQL\16\data\Average Sale Price Data.csv'
DELIMITER ','
CSV HEADER;

----- Avg_Family_Total_Income_Data
COPY Avg_Family_Income_Data(Province_ID, Grp_ID, Status_ID, Char_ID,Year_2019, Year_2020)
FROM 'C:\Program Files\PostgreSQL\16\data\Average family total income Data.csv'
DELIMITER ','
CSV HEADER;


----- Number_of_Buyers_Data
COPY Property_Sold_Num_Data (Province_ID,Grp_ID,Status_ID,Char_ID,Year_2019,Year_2020)
FROM 'C:\Program Files\PostgreSQL\16\data\Num_of_Buyers_Data.csv'
DELIMITER ','
CSV HEADER;



SELECT *
FROM avg_sale_price_data;




------------------------------Avg Incomoe By province -----------------------------
 
SELECT 
p.Province_Name, 
AVG(f.Year_2020) AS Avg_Income_2020
FROM 
Avg_Family_Income_Data f
JOIN 
Province_Lookup p ON f.Province_ID = p.Province_ID
GROUP BY 
p.Province_Name;

--------------------------Average Sale Price by Buyer Status ----------------------

SELECT 
b.Buyer_Status, 
AVG(s.Year_2020) AS Avg_Sale_Price_2020
FROM 
Avg_Sale_Price_Data s
JOIN 
Buyer_Status_Lookup b ON s.Status_ID = b.Status_ID
GROUP BY 
b.Buyer_Status;


-----------------------Average Sale Price by Province ------------------

SELECT 
    p.Province_Name, 
    AVG(s.Year_2020) AS Avg_Sale_Price_2020
FROM 
    Avg_Sale_Price_Data s
JOIN 
    Province_Lookup p ON s.Province_ID = p.Province_ID
GROUP BY 
    p.Province_Name;
 

----------------------- Change in Average Sale Price by Province -------------------

SELECT 
    p.Province_Name, 
    AVG(s.Year_2019) AS Avg_Sale_Price_2019,
    AVG(s.Year_2020) AS Avg_Sale_Price_2020,
    (AVG(s.Year_2020) - AVG(s.Year_2019)) AS Price_Change
FROM 
    Avg_Sale_Price_Data s
JOIN 
    Province_Lookup p ON s.Province_ID = p.Province_ID
GROUP BY 
    p.Province_Name;

------------------------- Buyers’ Insight ---------------

-- Total number of Immigrant buyers from 2019 to 2020
SELECT 
    SUM(Year_2019 + Year_2020) AS Total_Immigrant_Buyers
FROM 
    Property_Sold_Num_Data
WHERE 
    Char_ID = (SELECT Char_ID FROM Buyer_Char_Lookup WHERE Buyer_Characteristics LIKE '%Immigrant%');
 
-- Total number of Non-Immigrant buyers from 2019 to 2020
SELECT 
    SUM(Year_2019 + Year_2020) AS Total_Non_Immigrant_Buyers
FROM 
    Property_Sold_Num_Data
WHERE 
    Char_ID = (SELECT Char_ID FROM Buyer_Char_Lookup WHERE Buyer_Characteristics LIKE '%Non-immigrant%');
 
-- Total number of Male buyers from 2019 to 2020
SELECT 
    SUM(Year_2019 + Year_2020) AS Total_Male_Buyers
FROM 
    Property_Sold_Num_Data
WHERE 
    Char_ID = (SELECT Char_ID FROM Buyer_Char_Lookup WHERE Buyer_Characteristics LIKE '%Male%');
 
-- Total number of Female buyers from 2019 to 2020
SELECT 
    SUM(Year_2019 + Year_2020) AS Total_Female_Buyers
FROM 
    Property_Sold_Num_Data
WHERE 
    Char_ID = (SELECT Char_ID FROM Buyer_Char_Lookup WHERE Buyer_Characteristics LIKE '%Female%');
 
--------------- percentage of immigrant property ----------
 
-- Calculate the percentage of immigrant property buyers compared to non-immigrant buyers in 2020
SELECT 
    (CAST(SUM(CASE WHEN Char_ID = (SELECT Char_ID FROM Buyer_Char_Lookup WHERE Buyer_Characteristics LIKE '%Immigrant%') 
                   THEN Year_2020 ELSE 0 END) AS FLOAT) 
    / 
    SUM(CASE WHEN Char_ID = (SELECT Char_ID FROM Buyer_Char_Lookup WHERE Buyer_Characteristics LIKE '%Non-immigrant%') 
             THEN Year_2020 ELSE 0 END)) * 100 AS Immigrant_Buyer_Percentage
FROM 
    Property_Sold_Num_Data; 

--------------------------  The trend in Average Sale Price Over Time by Buyer Group Type ---------------


    g.Buyers_Grp_Type, 
    AVG(s.Year_2019) AS Avg_Sale_Price_2019, 
    AVG(s.Year_2020) AS Avg_Sale_Price_2020
FROM 
    Avg_Sale_Price_Data s
JOIN 
    Buyers_Group_Type_Lookup g ON s.Grp_ID = g.Grp_ID
GROUP BY 
    g.Buyers_Grp_Type;
 

-------------------------- The trend in the Number of Buyers Over Time by Province --------------

SELECT 
    p.Province_Name, 
    SUM(n.Year_2019) AS Buyers_2019, 
    SUM(n.Year_2020) AS Buyers_2020
FROM 
    Property_Sold_Num_Data n
JOIN 
    Province_Lookup p ON n.Province_ID = p.Province_ID
GROUP BY 
    p.Province_Name;
 	
---------------------------------------------- END ----------------------------------
