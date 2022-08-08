-- Selecting the data

SELECT *
FROM 
     QVI_transaction_data AS T
JOIN 
     QVI_Customer AS C
ON 
     T.LYLTY_CARD_NBR = C.LYLTY_CARD_NBR

-- 264,836 rows returned

-- Checking for outliers

SELECT
     Product_Quantity
FROM 
     QVI_transaction_data
ORDER BY 1 DESC


SELECT
     Product_Quantity
FROM
     QVI_transaction_data
ORDER BY 1

-- There seem to be an outlier in Product_Quantity. 200 packs of chips seems abnormal so i will exclude it using "WHERE Product_Quantity <> 200"


-- The product name category has a set of products not chips. That is the salsa products. I will also exclude it from my analysis

SELECT *
FROM 
     QVI_transaction_data AS T
JOIN 
     QVI_Customer AS C
ON 
     T.LYLTY_CARD_NBR = C.LYLTY_CARD_NBR
WHERE
     Product_Name NOT LIKE '%salsa%' AND Product_Quantity <> 200

-- 246,740 rows returned. Meaning i have just the dataset i need


-- Let's see the Total Sales generated over the year

SELECT 
     ROUND(SUM(Total_sales), 0) AS Total_Sales
FROM 
     QVI_transaction_data AS T
JOIN 
     QVI_Customer AS C
ON 
     T.LYLTY_CARD_NBR = C.LYLTY_CARD_NBR
WHERE
     Product_Name NOT LIKE '%salsa%' AND Product_Quantity <> 200

-- Julia has a Total Sales of $1,805,172


-- Let's also see the total number of Customers for the year

SELECT 
     COUNT(DISTINCT T.LYLTY_CARD_NBR) AS Total_Customers
FROM 
     QVI_transaction_data AS T
JOIN 
     QVI_Customer AS C
ON 
     T.LYLTY_CARD_NBR = C.LYLTY_CARD_NBR
WHERE
     Product_Name NOT LIKE '%salsa%' AND Product_Quantity <> 200

-- A total of 71,287 Customers


-- We want query for the Total Sales per each customer segment to present to Julia her top 3 Customers that generated the Highest Sales
-- Note that Customer Segement is a factor of Lifestage and Premium_Customer

SELECT
      C.Lifestage,
      C.Premium_customer,
      ROUND(SUM(Total_Sales), 0) AS TotalSales
FROM 
     QVI_transaction_data AS T
JOIN 
     QVI_Customer AS C
ON 
     T.LYLTY_CARD_NBR = C.LYLTY_CARD_NBR
WHERE
     Product_Name NOT LIKE '%salsa%' AND Product_Quantity <> 200
GROUP BY 
     C.Lifestage, 
     C.Premium_customer
ORDER BY 3 DESC

-- Julia's top 3 Customers that generated more sales are:
-- 1. Older families with a Budget, 
-- 2. Young Singles/Couples with Mainstream,
-- 3. Retirees with Mainstream.


-- Exploring the data, it will be good to know if 'Older families with a Budget' are the highest due to the Number of Customers who bought more chips.
-- We want to know the total number Customers per each Customer Segment.

SELECT
      C.Lifestage,
      C.Premium_customer,
      COUNT(Distinct T.LYLTY_CARD_NBR) AS Total_Customers 
FROM
     QVI_transaction_data AS T
JOIN 
     QVI_Customer AS C
ON 
     T.LYLTY_CARD_NBR = C.LYLTY_CARD_NBR
WHERE
     Product_Name NOT LIKE '%salsa%' AND Product_Quantity <> 200
GROUP BY 
     C.Lifestage,
     C.Premium_customer
ORDER BY 3 DESC

-- After pulling out this query, Young Singles/Couples Mainstream had the highest number of Customers with a total of 7,917 Customers.
-- This contributes to there being more sales to these customer segments but this is not a major driver for the Budget - Older families segment.


-- Over to how many chips are bought per customer by segment i.e Who Buys More?

SELECT
      C.Lifestage,
      SUM(Product_Quantity)/COUNT(DISTINCT T.LYLTY_CARD_NBR) AS AverageUnitTransaction
FROM 
     QVI_transaction_data AS T
JOIN 
     QVI_Customer AS C
ON 
     T.LYLTY_CARD_NBR = C.LYLTY_CARD_NBR
WHERE
     Product_Name NOT LIKE '%salsa%' AND Product_Quantity <> 200
GROUP BY 
     C.Lifestage
ORDER BY 2 DESC

-- Older Familes will buy more chips followed by Young Families and Older Singles/Couples.


-- We can also dig more by finding out the average chip price by customer segment i.e Who Pays More?

SELECT
      C.Lifestage,
      C.Premium_customer,
      ROUND(SUM(Total_Sales)/SUM(Product_Quantity),2) AS AverageChipPrice
FROM
     QVI_transaction_data AS T
JOIN
     QVI_Customer AS C
ON
     T.LYLTY_CARD_NBR = C.LYLTY_CARD_NBR
WHERE
     Product_Name NOT LIKE '%salsa%' AND Product_Quantity <> 200
GROUP BY
     C.Lifestage,
     C.Premium_customer
ORDER BY 3 DESC

-- Here we can see Young Singles/Couples Mainstream will pay more to buy chips. Followed by Midage Singles/Couples Mainstream.


--We want to know the top 5 pack size that generated most Sales in general

SELECT
     TOP 5(Pack_Size),
     SUM(Total_Sales) AS Total_Sales
FROM(
    SELECT 
         RIGHT(Product_Name, 4) AS Pack_Size,
         ROUND(SUM(Total_Sales), 0) AS Total_Sales
    FROM 
         QVI_transaction_data AS T
    JOIN 
         QVI_Customer AS C
    ON 
         T.LYLTY_CARD_NBR = C.LYLTY_CARD_NBR
    GROUP BY 
         Product_Name) AS T1
GROUP BY
     Pack_Size
ORDER BY 2 DESC

-- 175g geenerated the most sales with a sales


-- Lastly, let's see each month with their total sales
-- Firstly we need to summarize the total sales by each month of the year

SELECT 
      YEAR(date) AS Year,
      MONTH(date) AS Month,
      ROUND(SUM(Total_Sales), 0) AS Monthly_Sales
FROM
     QVI_transaction_data AS T
JOIN
     QVI_Customer AS C
ON
     T.LYLTY_CARD_NBR = C.LYLTY_CARD_NBR
WHERE
     Product_Name NOT LIKE '%salsa%' AND Product_Quantity <> 200
GROUP BY 
     YEAR(date),
     MONTH(date)
ORDER BY 1,2

-- Next we need to determine the highest Monthly_Sales

SELECT
      MAX(Monthly_Sales)
FROM (
    SELECT 
         YEAR(date) AS Year,
         MONTH(date) AS Month,
         ROUND(SUM(Total_Sales), 0) AS Monthly_Sales
    FROM 
         QVI_transaction_data AS T
    JOIN
         QVI_Customer AS C
    ON 
         T.LYLTY_CARD_NBR = C.LYLTY_CARD_NBR
    WHERE
         Product_Name NOT LIKE '%salsa%' AND Product_Quantity <> 200
    GROUP BY
         YEAR(date),
         MONTH(date)) AS Y

-- The maximum sales is $156,462. Now we can figure out the month and year with the highest Sales

SELECT *
FROM (
    SELECT 
         YEAR(date) AS Year,
         MONTH(date) AS Month,
         ROUND(SUM(Total_Sales), 0) AS Monthly_Sales
    FROM
         QVI_transaction_data AS T
    JOIN
         QVI_Customer AS C
    ON
         T.LYLTY_CARD_NBR = C.LYLTY_CARD_NBR
    WHERE
         Product_Name NOT LIKE '%salsa%' AND Product_Quantity <> 200
    GROUP BY
         YEAR(date),
         MONTH(date)) AS T1
WHERE Monthly_Sales = 156462

-- The month_year sales was highest is December 2018 with a Total Sales of $156,462
