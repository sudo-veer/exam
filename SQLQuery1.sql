-- create database
CREATE DATABASE Online_Shopping_DW;

-- use the database
USE Online_Shopping_DW;

-- create date dimension
CREATE TABLE Dim_Date (
    Date_id INT PRIMARY KEY,
    Full_Date DATE,
    Year INT,
    Quarter INT,
    Month INT
);

-- create product dimension
CREATE TABLE Dim_Product (
    Product_Key INT PRIMARY KEY,
    Product_Name VARCHAR(100),
    Category VARCHAR(50),
    Subcategory VARCHAR(50),
    Brand VARCHAR(50)
);

-- create customer dimension
CREATE TABLE Dim_Customer (
    Customer_Key INT PRIMARY KEY,
    Customer_id_NK INT,
    First_Name VARCHAR(50),
    Last_Name VARCHAR(50),
    Email VARCHAR(100),
    City VARCHAR(50)
);

-- create order dimension
CREATE TABLE Dim_Order (
    Order_Key INT PRIMARY KEY,
    Shipping_Type VARCHAR(50)
);

DROP TABLE IF EXISTS Fact_Sales;

-- create fact table
CREATE TABLE Fact_Sales (
    Sales_Key INT IDENTITY(1,1) PRIMARY KEY,   -- auto increment in SQL Server
    Date_id INT,
    Product_Key INT,
    Customer_Key INT,
    Order_Key INT,
    Quantity_Sold INT,
    Total_Sales_Amount DECIMAL(10,2),
    FOREIGN KEY (Date_id) REFERENCES Dim_Date(Date_id),
    FOREIGN KEY (Product_Key) REFERENCES Dim_Product(Product_Key),
    FOREIGN KEY (Customer_Key) REFERENCES Dim_Customer(Customer_Key),
    FOREIGN KEY (Order_Key) REFERENCES Dim_Order(Order_Key)
);

-- insert data in Dim_Date
INSERT INTO Dim_Date VALUES
(1, '2025-10-01', 2025, 4, 10),
(2, '2025-10-02', 2025, 4, 10),
(3, '2025-10-03', 2025, 4, 10);

-- insert data in Dim_Product
INSERT INTO Dim_Product VALUES
(101, 'iPhone 15', 'Electronics', 'Mobile', 'Apple'),
(102, 'Galaxy S24', 'Electronics', 'Mobile', 'Samsung'),
(103, 'Nike Shoes', 'Fashion', 'Footwear', 'Nike');

-- insert data in Dim_Customer
INSERT INTO Dim_Customer VALUES
(1, 1001, 'Karan', 'Patel', 'karan@gmail.com', 'Mumbai'),
(2, 1002, 'Priya', 'Sharma', 'priya@gmail.com', 'Delhi'),
(3, 1003, 'Amit', 'Verma', 'amit@gmail.com', 'Pune');

-- insert data in Dim_Order
INSERT INTO Dim_Order VALUES
(1, 'Standard Shipping'),
(2, 'Express Shipping');

-- insert data in Fact_Sales
INSERT INTO Fact_Sales (Date_id, Product_Key, Customer_Key, Order_Key, Quantity_Sold, Total_Sales_Amount)
VALUES
(1, 101, 1, 2, 1, 79999.00),
(2, 102, 2, 1, 1, 74999.00),
(3, 103, 3, 1, 2, 9998.00),
(1, 103, 1, 1, 1, 4999.00);

-- check data
SELECT * FROM Dim_Date;
SELECT * FROM Dim_Product;
SELECT * FROM Dim_Customer;
SELECT * FROM Dim_Order;
SELECT * FROM Fact_Sales;

-- 1. ROLL-UP example: total sales by category and subcategory
SELECT 
    P.Category,
    P.Subcategory,
    SUM(F.Total_Sales_Amount) AS Total_Sales
FROM Fact_Sales F
JOIN Dim_Product P ON F.Product_Key = P.Product_Key
GROUP BY P.Category, P.Subcategory
WITH ROLLUP;

-- 2. DRILL-DOWN example: sales by product each day
SELECT 
    D.Full_Date,
    P.Product_Name,
    SUM(F.Total_Sales_Amount) AS Total_Sales
FROM Fact_Sales F
JOIN Dim_Date D ON F.Date_id = D.Date_id
JOIN Dim_Product P ON F.Product_Key = P.Product_Key
GROUP BY D.Full_Date, P.Product_Name
ORDER BY D.Full_Date;

-- 3. SLICE example: only Electronics category
SELECT 
    P.Product_Name,
    SUM(F.Total_Sales_Amount) AS Total_Sales
FROM Fact_Sales F
JOIN Dim_Product P ON F.Product_Key = P.Product_Key
WHERE P.Category = 'Electronics'
GROUP BY P.Product_Name;

-- 4. DICE example: Electronics or Fashion and city = Mumbai or Delhi
SELECT 
    C.City,
    P.Category,
    SUM(F.Total_Sales_Amount) AS Total_Sales
FROM Fact_Sales F
JOIN Dim_Product P ON F.Product_Key = P.Product_Key
JOIN Dim_Customer C ON F.Customer_Key = C.Customer_Key
WHERE P.Category IN ('Electronics', 'Fashion')
  AND C.City IN ('Mumbai', 'Delhi')
GROUP BY C.City, P.Category;
