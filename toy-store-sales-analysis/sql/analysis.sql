--	+===========================+
--	 MAVEN TOYS - SALES ANALYSIS
--	+===========================+
--
-- Use database
USE MavenToys;



--	+--------------------+
--	 SALES OVERVIEW
--	+--------------------+

-- Date Range
SELECT MIN([Date]) AS DateMin,
	MAX([Date]) AS DateMax
FROM Sales;


-- Total Orders
SELECT COUNT(*) AS TotalOrders
FROM Sales AS s
INNER JOIN Products AS p
	ON s.Product_ID = p.Product_ID;


-- Total Sales
SELECT ROUND(SUM(s.Units * p.Product_Price), 2) AS TotalSales
FROM Sales AS s
INNER JOIN Products AS p
	ON s.Product_ID = p.Product_ID;


-- Total Profit
SELECT TotalProfit,
	ROUND(100 * TotalProfit / TotalSales, 2) AS ProfitMargin
FROM (
	SELECT SUM((s.Units * p.Product_Price) - (s.Units * Product_Cost
				)) AS TotalProfit,
		SUM(s.Units * p.Product_Price) AS TotalSales
	FROM Sales AS s
	INNER JOIN Products AS p
		ON s.Product_ID = p.Product_ID
	) AS t;



--	+--------------------+
--	 TIME SERIES ANALYSIS
--	+--------------------+

-- Create a temp table to retrieve data from the Sales, Products, and Stores table
DROP TABLE
IF EXISTS #SalesMasterTable;
	SELECT sal.Sale_ID,
		sal.[Date],
		sal.Units,
		(sal.Units * pro.Product_Price) AS Sales,
		(sal.Units * pro.Product_Price) - (sal.Units * pro.Product_Cost
			) AS Profit,
		pro.Product_ID,
		pro.Product_Name,
		pro.Product_Category,
		sto.*
	INTO #SalesMasterTable
	FROM Sales AS sal
	INNER JOIN Products AS pro
		ON sal.Product_ID = pro.Product_ID
	INNER JOIN Stores AS sto
		ON sal.Store_ID = sto.Store_ID;


-- Yearly sales
SELECT DATEPART(YEAR, [Date]) AS Year,
	COUNT(Sale_ID) AS TotalOrders,
	ROUND(SUM(Sales), 2) AS TotalRevenue,
	SUM(Profit) AS TotalProfit,
	ROUND(100 * (SUM(Profit) / SUM(Sales)), 2) AS ProfitMargin
FROM #SalesMasterTable
GROUP BY DATEPART(YEAR, [Date])
ORDER BY DATEPART(YEAR, [Date]);


-- Quarterly sales
SELECT DATEPART(YEAR, [Date]) AS Year,
	DATEPART(QUARTER, [Date]) AS Quarter,
	COUNT(Sale_ID) AS TotalOrders,
	ROUND(SUM(Sales), 2) AS TotalRevenue,
	SUM(Profit) AS TotalProfit,
	ROUND(100 * (SUM(Profit) / SUM(Sales)), 2) AS ProfitMargin
FROM #SalesMasterTable
GROUP BY DATEPART(YEAR, [Date]),
	DATEPART(QUARTER, [Date])
ORDER BY DATEPART(YEAR, [Date]),
	DATEPART(QUARTER, [Date]);


-- Year - Monthly sales
SELECT DATEPART(YEAR, [Date]) AS Year,
	DATEPART(MONTH, [Date]) AS MonthNum,
	DATENAME(MONTH, [Date]) AS MonthName,
	COUNT(Sale_ID) AS TotalOrders,
	ROUND(SUM(Sales), 2) AS TotalRevenue,
	SUM(Profit) AS TotalProfit,
	ROUND(100 * (SUM(Profit) / SUM(Sales)), 2) AS ProfitMargin
FROM #SalesMasterTable
GROUP BY DATEPART(YEAR, [Date]),
	DATEPART(MONTH, [Date]),
	DATENAME(MONTH, [Date])
ORDER BY DATEPART(YEAR, [Date]),
	DATEPART(MONTH, [Date]);


-- Monthly sales
SELECT DATEPART(MONTH, [Date]) AS MonthNum,
	DATENAME(MONTH, [Date]) AS MonthName,
	COUNT(Sale_ID) AS TotalOrders,
	ROUND(SUM(Sales), 2) AS TotalRevenue,
	SUM(Profit) AS TotalProfit,
	ROUND(100 * (SUM(Profit) / SUM(Sales)), 2) AS ProfitMargin
FROM #SalesMasterTable
GROUP BY DATEPART(MONTH, [Date]),
	DATENAME(MONTH, [Date])
ORDER BY DATEPART(MONTH, [Date]);


-- Weekday sales
SELECT DATEPART(WEEKDAY, [Date]) AS WeekdayNum,
	DATENAME(WEEKDAY, [Date]) AS WeekdayName,
	ROUND(SUM(Sales), 2) AS TotalSales
FROM #SalesMasterTable
GROUP BY DATEPART(WEEKDAY, [Date]),
	DATENAME(WEEKDAY, [Date])
ORDER BY DATEPART(WEEKDAY, [Date]);


-- 10 days with the highest sales
WITH DailySales
AS (
	SELECT [Date],
		ROUND((SUM(Sales)), 1) AS TotalSales,
		COUNT(*) AS Orders,
		SUM(Profit) AS TotalProfit
	FROM #SalesMasterTable
	GROUP BY [Date]
	)
SELECT TOP 10 *
FROM DailySales
ORDER BY TotalSales DESC;



--	+--------------------+
--	 PRODUCT ANALYSIS
--	+--------------------+

-- Number of products
SELECT COUNT(DISTINCT Product_ID) AS ProductNum
FROM Products;


-- Number of products category
SELECT COUNT(DISTINCT Product_Category) AS ProductCategoryNum
FROM Products;


-- Sales by product category
SELECT Product_Category,
	ROUND(SUM(Sales), 1) AS TotalSales,
	SUM(Profit) AS TotalProfit,
	COUNT(Sale_ID) AS Orders,
	SUM(Units) AS UnitSold,
	COUNT(DISTINCT Product_ID) AS ProductNum
FROM #SalesMasterTable
GROUP BY Product_Category
ORDER BY SUM(Sales) DESC;


-- Sales by Products
SELECT Product_Name,
	Product_Category,
	ROUND(SUM(Sales), 1) AS TotalSales,
	SUM(Profit) AS TotalProfit,
	COUNT(Sale_ID) AS Orders,
	SUM(Units) AS UnitSold
FROM #SalesMasterTable
GROUP BY Product_Name,
	Product_Category
ORDER BY SUM(Sales) DESC;


-- Most profitable product
SELECT TOP 5 Product_Name,
	Product_Category,
	SUM(Profit) AS TotalProfit,
	ROUND(SUM(Sales), 1) AS TotalSales,
	COUNT(Sale_ID) AS Orders,
	SUM(Units) AS UnitSold
FROM #SalesMasterTable
GROUP BY Product_Name,
	Product_Category
ORDER BY SUM(Profit) DESC;



--	+--------------------+
--	 STORE ANALYSIS
--	+--------------------+

-- Number of stores
SELECT COUNT(DISTINCT Store_ID) AS StoreNum
FROM Stores;


-- Number of stores per city
SELECT Store_City,
	COUNT(DISTINCT Store_ID) AS StoreNum
FROM Stores
GROUP BY Store_City
ORDER BY COUNT(DISTINCT Store_ID) DESC;


-- Number of stores per store location
SELECT Store_Location,
	COUNT(DISTINCT Store_ID) AS StoreNum
FROM Stores
GROUP BY Store_Location
ORDER BY COUNT(DISTINCT Store_ID) DESC;


-- Sales per store
SELECT Store_Name,
	ROUND(SUM(Sales), 1) AS TotalSalesperStore
FROM #SalesMasterTable
GROUP BY Store_Name
ORDER BY SUM(Sales) DESC;


-- Average sales per store
WITH SalesperStore
AS (
	SELECT Store_Name,
		ROUND(SUM(Sales), 1) AS TotalSalesperStore
	FROM #SalesMasterTable
	GROUP BY Store_Name
	)
SELECT AVG(TotalSalesperStore) AS AvgSalesperStore
FROM SalesperStore;


-- Sales by city
SELECT Store_City,
	ROUND(SUM(Sales), 1) AS SalesbyCity
FROM #SalesMasterTable
GROUP BY Store_City
ORDER BY SUM(Sales) DESC;


-- Average sales by city
WITH SalesbyCity
AS (
	SELECT Store_City,
		ROUND(SUM(Sales), 1) AS TotalSalesbyCity
	FROM #SalesMasterTable
	GROUP BY Store_City
	)
SELECT AVG(TotalSalesbyCity) AS AvgSalesbyCity
FROM SalesbyCity;


-- Sales by store location
SELECT Store_Location,
	ROUND(SUM(Sales), 1) AS TotalSalesbyStoreLocation
FROM #SalesMasterTable
GROUP BY Store_Location
ORDER BY SUM(Sales) DESC;


-- Average Sales by store location
WITH SalesbyStoreLocation
AS (
	SELECT Store_Location,
		ROUND(SUM(Sales), 1) AS TotalSalesbyStoreLocation
	FROM #SalesMasterTable
	GROUP BY Store_Location
	)
SELECT AVG(TotalSalesbyStoreLocation) AS AvgSalesbyStoreLocation
FROM SalesbyStoreLocation;


-- Top selling product category by store location
WITH ProductSalesbyStoreLocation
AS (
	SELECT Store_Location,
		Product_Category,
		ROUND(SUM(Sales), 1) AS TotalSales,
		SUM(Profit) AS TotalProfit,
		RANK() OVER (
			PARTITION BY Store_Location ORDER BY SUM(Sales) DESC
			) AS Sales_Rank
	FROM #SalesMasterTable
	GROUP BY Store_Location,
		Product_Category
	)
SELECT Store_Location,
	Sales_Rank,
	Product_Category,
	TotalSales,
	TotalProfit
FROM ProductSalesbyStoreLocation
ORDER BY Store_Location ASC, TotalSales DESC;



--	+--------------------+
--	 INVENTORY ANALYSIS
--	+--------------------+

-- Number of products per store
SELECT s.Store_Name,
	COUNT(DISTINCT p.Product_ID) AS ProductsSold
FROM Inventory AS i
INNER JOIN Products AS p
	ON i.Product_ID = p.Product_ID
INNER JOIN Stores AS s
	ON i.Store_ID = s.Store_ID
GROUP BY Store_Name;


-- Total product inventory value
SELECT SUM(Stock_On_Hand * Product_Cost) AS TotalInventoryValue
FROM Inventory AS i
INNER JOIN Products AS p
	ON i.Product_ID = p.Product_ID;


-- Total stockout product
WITH ProductStockperStore
AS (
	SELECT Store_ID,
		SUM(CASE WHEN Stock_On_Hand != 0 THEN 1 ELSE 0 END) AS InStock,
		SUM(CASE WHEN Stock_On_Hand = 0 THEN 1 ELSE 0 END) AS OutofStock
	FROM Inventory AS i
	INNER JOIN Products AS p
		ON i.Product_ID = p.Product_ID
	GROUP BY i.Store_ID
	)
SELECT ROUND(AVG(100 * CAST(OutofStock AS FLOAT) / (InStock + OutofStock)
		), 1) AS PercentageOutofStock,
	ROUND(AVG(100 * CAST(InStock AS FLOAT) / (InStock + OutofStock)), 1)
	AS PercentageInStock
FROM ProductStockperStore;


-- Product out-of-stock per store
WITH ProductStockperStore
AS (
	SELECT Store_ID,
		SUM(CASE WHEN Stock_On_Hand != 0 THEN 1 ELSE 0 END) AS InStock,
		SUM(CASE WHEN Stock_On_Hand = 0 THEN 1 ELSE 0 END) AS OutofStock
	FROM Inventory AS i
	INNER JOIN Products AS p
		ON i.Product_ID = p.Product_ID
	GROUP BY i.Store_ID
	)
SELECT Store_ID,
	(InStock + OutofStock) AS ProductSold,
	ROUND((100 * CAST(OutofStock AS FLOAT) / (InStock + OutofStock)
			), 1) AS PercentageOutofStock,
	ROUND((100 * CAST(InStock AS FLOAT) / (InStock + OutofStock)
			), 1) AS PercentageInfStock
FROM ProductStockperStore
ORDER BY CAST(Store_ID AS TINYINT);


-- Potential sales per store by stockout products
WITH DailyStoreProductSales AS (
	SELECT [DATE], Product_ID,
		Store_ID,
		SUM(Sales) AS DailySales
	FROM #SalesMasterTable
	GROUP BY [DATE], Product_ID,
		Store_ID
),
StoreAvgUnitSold AS (
	SELECT Product_ID, Store_ID, AVG(DailySales) AS AvgSales
	FROM DailyStoreProductSales
	GROUP BY Product_ID, Store_ID
)
SELECT s.Store_ID, ROUND(SUM(AvgSales), 1) AS SalesLost
FROM StoreAvgUnitSold AS s
	JOIN Inventory AS i
		ON s.Product_ID = i.Product_ID
		AND s.Store_ID = i.Store_ID
		AND Stock_On_Hand = 0
GROUP BY s.Store_ID
ORDER BY s.Store_ID;


-- Sales lost total
WITH DailyStoreProductSales AS (
	SELECT [DATE], Product_ID,
		Store_ID,
		SUM(Sales) AS DailySales
	FROM #SalesMasterTable
	GROUP BY [DATE], Product_ID,
		Store_ID
),
StoreAvgUnitSold AS (
	SELECT Product_ID, Store_ID, AVG(DailySales) AS AvgSales
	FROM DailyStoreProductSales
	GROUP BY Product_ID, Store_ID
),
SalesLostbyStore AS (
	SELECT s.Store_ID, ROUND(SUM(AvgSales), 1) AS SalesLost
	FROM StoreAvgUnitSold AS s
		JOIN Inventory AS i
			ON s.Product_ID = i.Product_ID
			AND s.Store_ID = i.Store_ID
			AND Stock_On_Hand = 0
	GROUP BY s.Store_ID
)
SELECT SUM(SalesLost) AS potential_sales_lost
FROM SalesLostbyStore;


-- Finding out how long the current stock last based on daily units sold
WITH UnitSoldperDay
AS (
	SELECT [Date],
		SUM(Units) AS UnitSold
	FROM Sales
	GROUP BY [Date]
	)
SELECT SUM(Stock_On_Hand) / (
		SELECT AVG(UnitSold)
		FROM UnitSoldperDay
		) AS DaysStockLast
FROM Inventory;
