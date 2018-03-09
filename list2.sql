--zad1
CREATE TABLE Sprzedaz (
	pracID INT	CONSTRAINT nn_Sprzedaz_pracID NOT NULL
				CONSTRAINT fk_Sprzedarz_Employee REFERENCES HumanResources.Employee,
	prodID INT	CONSTRAINT nn_Sprzedaz_prodID NOT NULL
				CONSTRAINT fk_Sprzedarz_Product REFERENCES Production.Product,
	nazwa_produktu NVARCHAR(50) CONSTRAINT nn_Sprzedaz_nazwa NOT NULL,
	Rok INT,
	Liczba INT
)

DROP TABLE dbo.Sprzedaz;

SELECT Sales.SalesOrderHeader.SalesPersonID "pracID", Sales.SalesOrderDetail.ProductID "prodID", MAX(Production.Product.Name) "Nazwa_produktu", YEAR(Sales.SalesOrderHeader.ShipDate) Rok, COUNT(*) "Liczba"
INTO Sprzedaz
FROM Sales.SalesOrderHeader RIGHT JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
	JOIN Production.Product ON Production.Product.ProductID = Sales.SalesOrderDetail.ProductID
GROUP BY YEAR(Sales.SalesOrderHeader.ShipDate), Sales.SalesOrderHeader.SalesPersonID, Sales.SalesOrderDetail.ProductID;

SELECT * FROM dbo.Sprzedaz;

--a
SELECT SalesPersonID,
	Name, 
	[2011],
	[2012],
	[2013],
	[2014]
FROM (SELECT Sales.SalesOrderHeader.SalesPersonID, 
	Sales.SalesOrderDetail.ProductID, 
	Production.Product.Name, 
	YEAR(Sales.SalesOrderHeader.ShipDate) AS Rok
	FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
		JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
	WHERE SalesPersonID IS NOT NULL) AS SourceTable
	PIVOT (
		COUNT(ProductID) FOR Rok IN([2011], [2012], [2013], [2014])
	) AS PivotTable;

--b
WITH Test AS
(
	SELECT Sales.SalesOrderHeader.SalesPersonID "pracID", 
		Sales.SalesOrderDetail.ProductID "prodID", 
		MAX(Production.Product.Name) "Nazwa_produktu",  
		COUNT(Sales.SalesOrderDetail.ProductID) 'Liczba',
		ROW_NUMBER() OVER(ORDER BY COUNT(Sales.SalesOrderDetail.ProductID) DESC) AS ROWNUM
	FROM Sales.SalesOrderHeader RIGHT JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
		JOIN Production.Product ON Production.Product.ProductID = Sales.SalesOrderDetail.ProductID
	WHERE Sales.SalesOrderHeader.SalesPersonID IS NOT NULL
	GROUP BY Sales.SalesOrderDetail.ProductID, Sales.SalesOrderHeader.SalesPersonID
)
SELECT * FROM Test WHERE ROWNUM < 6;


SELECT ProductID,
	Name, 
	[1],
	[2],
	[3],
	[4],
	[5]
FROM (SELECT Sales.SalesOrderDetail.ProductID, 
	Production.Product.Name, 
	ROW_NUMBER() OVER(ORDER BY COUNT(Sales.SalesOrderDetail.ProductID) DESC) AS rn,
	Sales.SalesOrderDetail.SalesOrderID
	FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
		JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID) AS SourceTable
	PIVOT (
		COUNT(Sales.SalesOrderDetail.SalesOrderID) FOR rn IN([1],[2],[3],[4],[5])
	) AS PivotTable;


SELECT ProductID,
	Name, 
	[2011],
	[2012],
	[2013],
	[2014]
FROM (SELECT Sales.SalesOrderHeader.SalesPersonID, 
	Sales.SalesOrderDetail.ProductID, 
	Production.Product.Name, 
	YEAR(Sales.SalesOrderHeader.ShipDate) AS Rok
	FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
		JOIN Production.Product ON Production.Product.ProductID = Sales.SalesOrderDetail.ProductID) AS SourceTable
	PIVOT (
		COUNT(SalesPersonID) FOR Rok IN([2011], [2012], [2013], [2014])
	) AS PivotTable;



--zad2
SELECT YEAR(ShipDate) "YEAR", COUNT(DISTINCT CustomerID) "CUST NUMBER"
FROM Sales.SalesOrderHeader
GROUP BY YEAR(ShipDate)
ORDER BY YEAR(ShipDate);

SELECT YEAR(ShipDate) "YEAR", MONTH(ShipDate) "MONTH", COUNT(DISTINCT CustomerID) "CUST NUMBER"
FROM Sales.SalesOrderHeader
GROUP BY YEAR(ShipDate), MONTH(ShipDate)
ORDER BY YEAR(ShipDate), MONTH(ShipDate);

SELECT 'CUST NUMBER', [2011], [2012], [2013], [2014]
FROM (SELECT DISTINCT CustomerID, YEAR(ShipDate) AS year
	FROM Sales.SalesOrderHeader) AS SourceTable
	PIVOT (COUNT(CustomerID)
		FOR year IN ([2011], [2012], [2013], [2014])
	) AS PivotTable;

SELECT 'CUST NUMBER', [1], [2], [3], [4],[5],[6],[7],[8],[9],[10],[11],[12]
FROM (SELECT DISTINCT CustomerID, MONTH(ShipDate) AS mon
	FROM Sales.SalesOrderHeader) AS SourceTable
	PIVOT (COUNT(CustomerID)
		FOR mon IN ([1], [2], [3], [4],[5],[6],[7],[8],[9],[10],[11],[12])
	) AS PivotTable;



--zad3
SELECT CONCAT(Person.Person.FirstName, ' ', Person.Person.LastName), COUNT(*)
		FROM Sales.SalesOrderHeader JOIN Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
			JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
		GROUP BY Sales.Customer.CustomerID, CONCAT(Person.Person.FirstName, ' ', Person.Person.LastName);

SELECT CONCAT(firstName, ' ', lastName) "Imie i nazwisko", 
	COALESCE(SUM(CASE WHEN yr = 2012 THEN 1 END), 0) [2012],
	COALESCE(SUM(CASE WHEN yr = 2014 THEN 1 END), 0) [2014]
FROM 
	(
		SELECT Sales.Customer.CustomerID AS id, Person.Person.FirstName AS firstName, Person.Person.LastName AS lastName, YEAR(OrderDate) AS yr
		FROM Sales.SalesOrderHeader JOIN Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
			JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
		WHERE YEAR(OrderDate) NOT IN (2011, 2013)
	) AS SourceTable
GROUP BY id, CONCAT(firstName, ' ', lastName);



--zad4
SELECT id, c, cost, [2011], [2012], [2013], [2014]
FROM
(
	SELECT ProductID AS id, COUNT(ProductID) AS c, SubTotal AS cost, YEAR(OrderDate) AS yr
	FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
) AS SourceTable
PIVOT 
(
	SUM(cost) FOR yr IN ([2011], [2012], [2013], [2014])
) AS PivotTable

SELECT ProductID AS id, COUNT(ProductID) AS count, SUM(SubTotal) AS cost, YEAR(OrderDate) AS yr
FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
GROUP BY YEAR(OrderDate), ProductID
ORDER BY ProductID, YEAR(OrderDate);

SELECT ProductID AS id, COUNT(ProductID) AS count, SUM(SubTotal) AS cost, MONTH(OrderDate) AS mon
FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
GROUP BY MONTH(OrderDate), ProductID
ORDER BY ProductID, MONTH(OrderDate);

SELECT ProductID AS id, COUNT(ProductID) AS count, SUM(SubTotal) AS cost, DAY(OrderDate) AS d
FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
GROUP BY DAY(OrderDate), ProductID
ORDER BY ProductID, DAY(OrderDate);

SELECT ProductID AS id, COUNT(ProductID) AS count, SUM(SubTotal) AS cost, YEAR(OrderDate) AS yr, MONTH(OrderDate) AS mon, DAY(OrderDate) AS d
FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
GROUP BY YEAR(OrderDate), MONTH(OrderDate), DAY(OrderDate), ProductID
ORDER BY ProductID, YEAR(OrderDate), MONTH(OrderDate), DAY(OrderDate);

SELECT ProductID AS id, SubTotal AS cost, YEAR(OrderDate) AS yr, MONTH(OrderDate) AS mon, DAY(OrderDate) AS d
FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
ORDER BY ProductID, YEAR(OrderDate), MONTH(OrderDate), DAY(OrderDate);



--zad7
WITH NumOfGoodBuys2011 AS
(
	SELECT BusinessEntityID, COUNT(*) num2011
	FROM Sales.SalesOrderHeader JOIN Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
		JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
	WHERE SubTotal > (
		SELECT 1.5 * AVG(SubTotal)
		FROM Sales.SalesOrderHeader)
		AND
		YEAR(OrderDate) = 2011 
	GROUP BY BusinessEntityID
),
NumOfGoodBuys2012 AS
(
	SELECT BusinessEntityID, COUNT(*) num2012
	FROM Sales.SalesOrderHeader JOIN Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
		JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
	WHERE SubTotal > (
		SELECT 1.5 * AVG(SubTotal)
		FROM Sales.SalesOrderHeader)
		AND
		YEAR(OrderDate) = 2012 
	GROUP BY BusinessEntityID
),
NumOfGoodBuys2013 AS
(
	SELECT BusinessEntityID, COUNT(*) num2013
	FROM Sales.SalesOrderHeader JOIN Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
		JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
	WHERE SubTotal > (
		SELECT 1.5 * AVG(SubTotal)
		FROM Sales.SalesOrderHeader)
		AND
		YEAR(OrderDate) = 2013 
	GROUP BY BusinessEntityID
),
NumOfGoodBuys2014 AS
(
	SELECT BusinessEntityID, COUNT(*) num2014
	FROM Sales.SalesOrderHeader JOIN Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
		JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
	WHERE SubTotal > (
		SELECT 1.5 * AVG(SubTotal)
		FROM Sales.SalesOrderHeader)
		AND
		YEAR(OrderDate) = 2014 
	GROUP BY BusinessEntityID
),
NumOfGoodBuys AS
(
	SELECT BusinessEntityID, COUNT(*) num
	FROM Sales.SalesOrderHeader JOIN Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
		JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
	WHERE SubTotal > (
		SELECT 1.5 * AVG(SubTotal)
		FROM Sales.SalesOrderHeader)
	GROUP BY BusinessEntityID
)
SELECT DISTINCT CONCAT(FirstName, ' ', LastName) "Name", 
	COUNT(SalesOrderID) OVER(PARTITION BY Person.Person.BusinessEntityID) AS TRANSACTION_COUNT,
	SUM(SubTotal) OVER(PARTITION BY Person.Person.BusinessEntityID) "COST",
	CASE 
		WHEN COUNT(SalesOrderID) OVER(PARTITION BY Person.Person.BusinessEntityID) > 4 THEN 'Srebrna'
		WHEN n.num > 2 THEN 'Zlota'
		WHEN n11.num2011 > 2 AND n12.num2012 > 2 AND n13.num2013 > 2 AND n14.num2014 > 2 THEN 'Platyna'
	END AS c
FROM Sales.SalesOrderHeader JOIN Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
	JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
	LEFT JOIN NumOfGoodBuys n ON Person.Person.BusinessEntityID = n.BusinessEntityID
	LEFT JOIN NumOfGoodBuys2011 n11 ON Person.Person.BusinessEntityID = n11.BusinessEntityID
	LEFT JOIN NumOfGoodBuys2012 n12 ON Person.Person.BusinessEntityID = n12.BusinessEntityID
	LEFT JOIN NumOfGoodBuys2013 n13 ON Person.Person.BusinessEntityID = n13.BusinessEntityID
	LEFT JOIN NumOfGoodBuys2014 n14 ON Person.Person.BusinessEntityID = n14.BusinessEntityID
;


SELECT 1.5 * AVG(SubTotal)
FROM Sales.SalesOrderHeader;

SELECT COUNT(*)
FROM Sales.SalesOrderHeader JOIN Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
	JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
WHERE SubTotal > (
	SELECT 1.5 * AVG(SubTotal)
	FROM Sales.SalesOrderHeader)
	AND
	YEAR(OrderDate) = 2011 
GROUP BY BusinessEntityID;