--zad1
SELECT CONCAT(FirstName, LastName) AS [Klient], YEAR(OrderDate) AS [Rok], SUM(SubTotal) AS [Kwota]
FROM Sales.SalesOrderHeader JOIN Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
GROUP BY CONCAT(FirstName, LastName), YEAR(OrderDate) WITH CUBE
ORDER BY CONCAT(FirstName, LastName) ASC, YEAR(OrderDate) DESC;

SELECT CONCAT(FirstName, LastName) AS [Klient], YEAR(OrderDate) AS [Rok], SUM(SubTotal) AS [Kwota]
FROM Sales.SalesOrderHeader JOIN Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
GROUP BY CONCAT(FirstName, LastName), YEAR(OrderDate) WITH ROLLUP
ORDER BY CONCAT(FirstName, LastName) ASC, YEAR(OrderDate) DESC;

SELECT CONCAT(FirstName, LastName) AS [Klient], YEAR(OrderDate) AS [Rok], SUM(SubTotal) AS [Kwota]
FROM Sales.SalesOrderHeader JOIN Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
GROUP BY GROUPING SETS((), (CONCAT(FirstName, LastName)), (CONCAT(FirstName, LastName), YEAR(OrderDate)))
ORDER BY CONCAT(FirstName, LastName) ASC, YEAR(OrderDate) DESC;

--zad2
SELECT ProductCategory.Name AS [Kategoria], Product.Name AS [Produkt], YEAR(OrderDate) AS [Rok], SUM(OrderQty * UnitPriceDiscount) AS [Kwota]
FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
JOIN Production.ProductCategory ON Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID
GROUP BY ProductCategory.Name, Product.Name, YEAR(OrderDate) WITH CUBE
ORDER BY ProductCategory.Name, Product.Name, YEAR(OrderDate);

SELECT ProductCategory.Name AS [Kategoria], Product.Name AS [Produkt], YEAR(OrderDate) AS [Rok], SUM(OrderQty * UnitPriceDiscount) AS [Kwota]
FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
JOIN Production.ProductCategory ON Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID
GROUP BY ProductCategory.Name, Product.Name, YEAR(OrderDate) WITH ROLLUP
ORDER BY ProductCategory.Name, Product.Name, YEAR(OrderDate);

SELECT ProductCategory.Name AS [Kategoria], Product.Name AS [Produkt], YEAR(OrderDate) AS [Rok], SUM(OrderQty * UnitPriceDiscount) AS [Kwota]
FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
JOIN Production.ProductCategory ON Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID
GROUP BY GROUPING SETS((), (ProductCategory.Name), (ProductCategory.Name, Product.Name), (ProductCategory.Name, Product.Name, YEAR(OrderDate)))
ORDER BY ProductCategory.Name, Product.Name, YEAR(OrderDate);

--zad3
SELECT DISTINCT ProductCategory.Name AS [Nazwa], YEAR(OrderDate) AS [Rok], 
(SUM(SubTotal) OVER(partition by ProductCategory.Name, YEAR(OrderDate)))/(SUM(SubTotal)OVER(partition by ProductCategory.Name)) * 100 AS [Procent]
FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
JOIN Production.ProductCategory ON Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID
WHERE ProductCategory.Name = 'Bikes'
--GROUP BY GROUPING SETS((), (SubTotal), (ProductCategory.Name, YEAR(OrderDate)), (ProductCategory.Name, YEAR(OrderDate), SubTotal))
--ORDER BY YEAR(OrderDate);
UNION
SELECT null, null, 100
ORDER BY 2;


--zad4
SELECT DISTINCT CustomerID AS [Klient], YEAR(OrderDate) AS [Rok], 
COUNT(*) OVER(PARTITION BY CustomerID ORDER BY YEAR(OrderDate)) AS [Liczba zamowien narastajaco]
FROM Sales.SalesOrderHeader
ORDER BY CustomerID, YEAR(OrderDate);
--WHERE CustomerID = 30117;



--zad5
--to
SELECT DISTINCT CONCAT(FirstName, LastName) AS [Imie i nazwisko], YEAR(OrderDate) AS [Rok], MONTH(OrderDate) AS [Miesiac],
COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID, YEAR(OrderDate), MONTH(OrderDate) ORDER BY SalesOrderID RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS [W miesiacu],
COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID, YEAR(OrderDate) ORDER BY SalesOrderID RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS [W roku],
COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID, YEAR(OrderDate) ORDER BY SalesOrderID) AS [W roku narastajaco],
COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID, YEAR(OrderDate), MONTH(OrderDate) ORDER BY SalesOrderID ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS [Obecny i poprzedni miesiac]
FROM Sales.SalesOrderHeader JOIN Person.Person ON Sales.SalesOrderHeader.SalesPersonID = Person.Person.BusinessEntityID
ORDER BY CONCAT(FirstName, LastName), YEAR(OrderDate), MONTH(OrderDate);

--to2
WITH temp AS
(
	SELECT SalesOrderID AS [id], CONCAT(FirstName, LastName) AS [Imie i nazwisko], YEAR(OrderDate) AS [Rok], MONTH(OrderDate) AS [Miesiac],
	COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID, YEAR(OrderDate), MONTH(OrderDate) ORDER BY SalesOrderID RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS [W miesiacu],
	COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID, YEAR(OrderDate) ORDER BY SalesOrderID RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS [W roku],
	COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID, YEAR(OrderDate) ORDER BY SalesOrderID) AS [W roku narastajaco]
	FROM Sales.SalesOrderHeader JOIN Person.Person ON Sales.SalesOrderHeader.SalesPersonID = Person.Person.BusinessEntityID
	WHERE FirstName = 'Amy' AND LastName = 'Alberts' AND YEAR(OrderDate) = 2013
)
SELECT temp.[Imie i nazwisko], temp.[Rok], temp.[Miesiac], temp.[W miesiacu], temp.[W roku], temp.[W roku narastajaco],
SUM([W miesiacu]) OVER (ORDER BY SalesOrderID ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS [Obecny i poprzedni miesiac]
FROM Sales.SalesOrderHeader JOIN Person.Person ON Sales.SalesOrderHeader.SalesPersonID = Person.Person.BusinessEntityID 
JOIN temp ON Sales.SalesOrderHeader.SalesOrderID = id;

--toooo
WITH temp AS
(
	SELECT SalesOrderID AS [id], CONCAT(FirstName, LastName) AS [Imie i nazwisko], YEAR(OrderDate) AS [Rok], MONTH(OrderDate) AS [Miesiac],
	COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID, YEAR(OrderDate), MONTH(OrderDate) ORDER BY SalesOrderID RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS [W miesiacu],
	COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID, YEAR(OrderDate) ORDER BY SalesOrderID RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS [W roku],
	COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID, YEAR(OrderDate) ORDER BY SalesOrderID) AS [W roku narastajaco]
	FROM Sales.SalesOrderHeader JOIN Person.Person ON Sales.SalesOrderHeader.SalesPersonID = Person.Person.BusinessEntityID
)
SELECT temp.[Imie i nazwisko], temp.[Rok], temp.[Miesiac], temp.[W miesiacu], temp.[W roku], temp.[W roku narastajaco],
SUM([W miesiacu]) OVER (PARTITION BY SalesPersonID, YEAR(OrderDate) ORDER BY SalesOrderID ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS [Obecny i poprzedni miesiac]
FROM Sales.SalesOrderHeader JOIN Person.Person ON Sales.SalesOrderHeader.SalesPersonID = Person.Person.BusinessEntityID 
JOIN temp ON Sales.SalesOrderHeader.SalesOrderID = id
ORDER BY CONCAT(FirstName, LastName), YEAR(OrderDate), MONTH(OrderDate);

--zad6
--z over
WITH maxValues AS
(
	SELECT DISTINCT Production.ProductSubcategory.ProductSubcategoryID AS [id_maxV], MAX(ListPrice) OVER(PARTITION BY Production.ProductSubcategory.Name) AS [maxV]
	FROM Production.Product JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
)
SELECT DISTINCT name AS [Kategoria], SUM([max]) OVER(PARTITION BY name) AS [Suma]
FROM
(
	SELECT DISTINCT Production.ProductCategory.Name AS [name], maxV AS [max]
	FROM Production.Product JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
	JOIN Production.ProductCategory ON Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID
	JOIN maxValues ON Production.ProductSubcategory.ProductSubcategoryID = id_maxV
) AS subquery;


--z group by
WITH maxValues AS
(
	SELECT Production.ProductSubcategory.ProductSubcategoryID AS [id_maxV], MAX(ListPrice) AS [maxV]
	FROM Production.Product JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID 
	GROUP BY Production.ProductSubcategory.ProductSubcategoryID
)
SELECT n, SUM(m)
FROM
(
	SELECT DISTINCT Production.ProductCategory.Name AS n, Production.ProductSubcategory.Name, maxV AS m
	FROM Production.Product JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
	JOIN Production.ProductCategory ON Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID
	JOIN maxValues ON Production.ProductSubcategory.ProductSubcategoryID = id_maxV
) AS sub
GROUP BY n;
