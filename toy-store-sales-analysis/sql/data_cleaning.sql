--	+=========================+
--	MAVEN TOYS - SALES ANALYSIS
--	DATA CLEANING
--	+=========================+



--	+-----------------------+
--	 Checking for duplicates
--	+-----------------------+
-- Sales table
SELECT Sale_ID,
	[Date],
	COUNT(*) AS CountSaleID
FROM Sales
GROUP BY Sale_ID,
	[Date]
HAVING COUNT(*) > 1;


-- Products table
SELECT Product_ID,
	Product_Name,
	COUNT(*) AS ProductCount
FROM Products
GROUP BY Product_ID,
	Product_Name
HAVING COUNT(*) > 1;


-- Stores table
SELECT Store_ID,
	COUNT(*) AS StoreCount
FROM Stores
GROUP BY Store_ID
HAVING COUNT(*) > 1;


-- Inventory table
SELECT Store_ID,
	Product_ID,
	COUNT(*) AS InventoryCount
FROM Inventory
GROUP BY Store_ID,
	Product_ID
HAVING COUNT(*) > 1;



--	+-----------------------+
--	 Spelling Error
--	+-----------------------+

-- Fixing typo in city name, "Cuidad de Mexico" to "Ciudad de Mexico"
UPDATE Stores
SET Store_City = 'Ciudad de Mexico'
WHERE Store_City LIKE 'Cuidad%';
