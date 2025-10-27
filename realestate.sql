-- Step 1: Create a new database for the project
CREATE DATABASE RealEstateAnalysisDB;
GO

-- Set the context to use the new database
USE RealEstateAnalysisDB;
GO

-- 1. Location Dimension Table
CREATE TABLE location (
    location_id INT PRIMARY KEY,
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10)
);
GO

-- 2. Property Dimension Table
CREATE TABLE property (
    property_id INT PRIMARY KEY,
    property_type VARCHAR(50), -- e.g., 'House', 'Apartment'
    bedrooms INT,
    bathrooms INT
);
GO

-- 3. Time Dimension Table
CREATE TABLE time (
    time_id INT PRIMARY KEY,
    date_key DATE,
    year INT,
    quarter INT, -- 1, 2, 3, or 4
    month INT
);
GO

-- Fact Table: price_prediction
CREATE TABLE price_prediction (
    sale_id INT PRIMARY KEY,
    
    -- Foreign Keys linking to the Dimension Tables
    location_id INT REFERENCES location(location_id),
    property_id INT REFERENCES property(property_id),
    time_id INT REFERENCES time(time_id),
    
    -- The Measure (The data we analyze)
    sale_price DECIMAL(18, 2),
    sq_footage INT
);
GO

-- Insert Sample Data into Dimension Tables
INSERT INTO location (location_id, city, state, zip_code) VALUES
(1, 'LA', 'CA', '90001'),
(2, 'NY', 'NY', '10001'),
(3, 'MIA', 'FL', '33101');

INSERT INTO property (property_id, property_type, bedrooms, bathrooms) VALUES
(101, 'House', 3, 2),
(102, 'Apartment', 1, 1),
(103, 'Condo', 2, 2);

INSERT INTO time (time_id, date_key, year, quarter, month) VALUES
(1001, '2024-01-15', 2024, 1, 1),
(1002, '2024-04-20', 2024, 2, 4),
(1003, '2024-07-10', 2024, 3, 7);

-- Insert Sample Data into Fact Table (Price Prediction)
INSERT INTO price_prediction (sale_id, location_id, property_id, time_id, sale_price, sq_footage) VALUES
(1, 1, 101, 1001, 550000.00, 1500),  -- LA, House, Q1
(2, 2, 102, 1001, 300000.00, 750),   -- NY, Apartment, Q1
(3, 1, 101, 1002, 800000.00, 2200),  -- LA, House, Q2
(4, 3, 103, 1003, 400000.00, 1000),  -- MIA, Condo, Q3
(5, 2, 102, 1002, 320000.00, 800);   -- NY, Apartment, Q2

-- Check that all data was inserted (Optional)
SELECT * FROM price_prediction;

-- OLAP Operation 1: ROLL-UP
SELECT
    l.city,
    SUM(pp.sale_price) AS Total_Sales
FROM
    price_prediction pp
JOIN
    location l ON pp.location_id = l.location_id
GROUP BY 
    ROLLUP(l.city)
ORDER BY
    l.city;

    -- OLAP Operation 2: DRILL-DOWN
SELECT
    l.city,
    p.property_type,
    SUM(pp.sale_price) AS Total_Sales
FROM
    price_prediction pp
JOIN
    location l ON pp.location_id = l.location_id
JOIN
    property p ON pp.property_id = p.property_id
GROUP BY
    l.city, p.property_type
ORDER BY
    l.city, p.property_type;

    -- OLAP Operation 3: SLICE
SELECT
    p.property_id,
    SUM(pp.sale_price) AS Total_Sales_in_LA
FROM
    price_prediction pp
JOIN
    property p ON pp.property_id = p.property_id
JOIN
    location l ON pp.location_id = l.location_id
WHERE
    l.city = 'LA'  -- The SLICE filter
GROUP BY
    p.property_id
ORDER BY
    p.property_id;

  -- OLAP Operation 4: PIVOT / DICING
SELECT
    l.city,
    SUM(CASE WHEN t.quarter = 1 THEN pp.sale_price ELSE 0 END) AS Q1_Sales,
    SUM(CASE WHEN t.quarter = 2 THEN pp.sale_price ELSE 0 END) AS Q2_Sales,
    SUM(CASE WHEN t.quarter = 3 THEN pp.sale_price ELSE 0 END) AS Q3_Sales,
    SUM(CASE WHEN t.quarter = 4 THEN pp.sale_price ELSE 0 END) AS Q4_Sales
FROM
    price_prediction pp
JOIN
    location l ON pp.location_id = l.location_id
JOIN
    time t ON pp.time_id = t.time_id
GROUP BY
    l.city
ORDER BY
    l.city;
