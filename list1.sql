--zad1
SELECT COUNT(*) "NUMBER OF PRODUCTS" FROM Production.Product;

SELECT COUNT(*) "NUMBER OF CATEGORIES" FROM Production.ProductCategory;

SELECT COUNT(*) "NUMBER OF SUBCATEGORIES" FROM Production.ProductSubcategory;

--zad2
SELECT * 
FROM Production.Product
WHERE Color IS NULL;

--zad3 ?
SELECT YEAR(Sales.SalesOrderHeader.OrderDate) "YEAR", FORMAT(SUM(TotalDue), 'C') "PROFIT"
FROM Sales.SalesOrderHeader
WHERE Sales.SalesOrderHeader.Status = 5
GROUP BY YEAR(Sales.SalesOrderHeader.OrderDate);

SELECT COUNT(*) FROM Sales.Store GROUP BY SalesPersonID;

--zad4 ?
SELECT COUNT(*) "NUMBER OF SALESPERSONS" FROM Sales.SalesPerson;
SELECT COUNT(*) "NUMBER OF CUSTOMERS" FROM Sales.Customer;

SELECT StoreID "STORE ID", COUNT(*) "NUMBER OF CUSTOMERS" 
FROM Sales.Customer
GROUP BY StoreID;

SELECT COUNT(*) FROM Sales.Customer;

--zad5
SELECT YEAR(TransactionDate) "YEAR", COUNT(*) "NUMBER OF TRANSACTIONS"
FROM Production.TransactionHistory
GROUP BY YEAR(TransactionDate)
UNION
SELECT YEAR(TransactionDate), COUNT(*) 
FROM Production.TransactionHistoryArchive
GROUP BY YEAR(TransactionDate);

--zad6
SELECT DISTINCT(Production.Product.Name) "PRODUCT", Production.ProductCategory.Name "CATEGORY"
FROM (Production.Product 
	LEFT JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID)
	LEFT JOIN Production.ProductCategory ON Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID
EXCEPT
SELECT DISTINCT(Production.Product.Name) "PRODUCT", Production.ProductCategory.Name "CATEGORY"
FROM ((Production.Product JOIN Production.TransactionHistory ON Production.Product.ProductID = Production.TransactionHistory.ProductID)
	LEFT JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID)
	LEFT JOIN Production.ProductCategory ON Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID
ORDER BY 2;

--zad7
SELECT ProductSubcategory.Name "SUBCATEGORY", 
	MAX(Product.StandardCost - ProductCostHistory.StandardCost) "MAX DISCOUNT",
	MIN(Product.StandardCost - ProductCostHistory.StandardCost) "MIN DISCOUNT"
FROM (Production.Product JOIN Production.ProductCostHistory ON Production.Product.ProductID = Production.ProductCostHistory.ProductID)
JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
GROUP BY ProductSubcategory.Name;

SELECT ProductSubcategory.Name "SUBCATEGORY", 
	MAX(Product.ListPrice - Production.ProductListPriceHistory.ListPrice) "MAX DISCOUNT",
	MIN(Product.ListPrice - Production.ProductListPriceHistory.ListPrice) "MIN DISCOUNT"
FROM (Production.Product JOIN Production.ProductListPriceHistory ON Production.Product.ProductID = Production.ProductListPriceHistory.ProductID)
JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
GROUP BY ProductSubcategory.Name;

SELECT Production.ProductSubcategory.Name, 
	MAX(DiscountPct * ListPrice) "MAX DISCOUNT", 
		MIN(DiscountPct * ListPrice) "MIN DISCOUNT"
FROM ((Sales.SpecialOffer JOIN Sales.SpecialOfferProduct ON Sales.SpecialOffer.SpecialOfferID = Sales.SpecialOfferProduct.SpecialOfferID)
	JOIN Production.Product ON Production.Product.ProductID = Sales.SpecialOfferProduct.ProductID)
	JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
GROUP BY Production.ProductSubcategory.Name;

--zad8 ?
SELECT Production.Product.Name
FROM Production.Product
WHERE Production.Product.ListPrice > (SELECT AVG(Production.Product.ListPrice) FROM Production.Product);

--zad9
SELECT MONTH(ShipDate) "SHIPMENT MONTH", SUM(OrderQty) "SUM OF PRODUCTS"
FROM Sales.SalesOrderDetail JOIN Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
GROUP BY MONTH(ShipDate)
ORDER BY 1;

--zad10
SELECT Person.CountryRegion.Name "COUNTRY", AVG(DATEDIFF(DAY, OrderDate, DueDate)) "AVERAGE DELIVERY TIME"
FROM ((Sales.SalesOrderHeader JOIN Person.Address ON Sales.SalesOrderHeader.ShipToAddressID = Person.Address.AddressID)
JOIN Person.StateProvince ON Person.Address.StateProvinceID = Person.StateProvince.StateProvinceID)
JOIN Person.CountryRegion ON Person.StateProvince.CountryRegionCode = Person.CountryRegion.CountryRegionCode
GROUP BY Person.CountryRegion.Name;
