--zad1
CREATE SCHEMA [blady];

--zad2
CREATE TABLE [blady].[DIM_CUSTOMER]
(
	[CustomerID] INT CONSTRAINT nn_dCust_id NOT NULL,
	[FirstName] Name,
	[LastName] Name,
	[TerritoryName] Name,
	[CountryRegionCode] NVARCHAR(3),
	[Group] NVARCHAR(50)
);

CREATE TABLE [blady].[DIM_PRODUCT]
(
	[ProductID] INT CONSTRAINT nn_dProd_id NOT NULL,
	[Name] Name,
	[ListPrice] money,
	[Color] NVARCHAR(15),
	[Rating] INT,
	[SubCategoryName] Name,
	[CategoryName] Name
);

GO
CREATE FUNCTION [blady].[getHireDate](@employeeID INT)
RETURNS date
AS
BEGIN
	RETURN 
	(
		SELECT HireDate 
		FROM HumanResources.Employee 
		WHERE BusinessEntityID = @employeeID
	)
END
GO;

GO
CREATE FUNCTION [blady].[getBirthDate](@employeeID INT)
RETURNS date
AS
BEGIN
	RETURN 
	(
		SELECT BirthDate 
		FROM HumanResources.Employee 
		WHERE BusinessEntityID = @employeeID
	)
END
GO;

CREATE TABLE [blady].[DIM_SALESPERSON]
(
	[SalesPersonID] INT CONSTRAINT nn_dSP_id NOT NULL,
	[FirstName] Name,
	[LastName] Name,
	[Title] NVARCHAR(8),
	[Gender] NCHAR(1),
	[CountryRegionCode] NVARCHAR(3),
	[Group] NVARCHAR(50),
	[Age] AS DATEDIFF(YEAR, blady.getBirthDate(SalesPersonID), GETDATE()),
	[Seniority] AS DATEDIFF(YEAR, blady.getHireDate(SalesPersonID), GETDATE())
);

GO
CREATE FUNCTION [blady].[datetimeToInt](@date datetime)
RETURNS INT
AS
BEGIN
	RETURN YEAR(@date) * 10000 + MONTH(@date) * 100 + DAY(@date)
END
GO;

CREATE TABLE [blady].[FACT_SALES]
(
	[FactSalesID] INT IDENTITY(1,1),
	[ProductID] INT,
	[CustomerID] INT,
	[SalesPersonID] INT,
	[OrderDate] INT,
	[ShipDate] INT,
	[OrderQty] SMALLINT,
	[UnitPrice] money,
	[UnitPriceDiscount] money,
	[LineTotal] numeric(38,6)
);
DBCC CHECKIDENT ('blady.FACT_SALES', RESEED, 0);

DROP table blady.FACT_SALES;
DROP TABLE blady.DIM_CUSTOMER;
DROP TABLE blady.DIM_PRODUCT;
DROP TABLE blady.DIM_SALESPERSON;


--zad3
--DIM_CUSTOMER
INSERT INTO [blady].[DIM_CUSTOMER]
SELECT CustomerID, Firstname, LastName, SalesTerritory.[Name], CountryRegionCode, [Group]
FROM Sales.Customer LEFT JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
LEFT JOIN Sales.SalesTerritory ON Sales.Customer.TerritoryID = Sales.SalesTerritory.TerritoryID;

SELECT * FROM [blady].[DIM_CUSTOMER];

--DIM_PRODUCT
INSERT INTO [blady].[DIM_PRODUCT]
SELECT DISTINCT Product.ProductID, Product.[Name], ListPrice, Color, AVG(Rating) OVER(PARTITION BY Product.ProductID), ProductSubcategory.[Name], ProductCategory.[Name]
FROM Production.Product LEFT JOIN Production.ProductSubcategory ON Product.ProductSubcategoryID = ProductSubcategory.ProductSubcategoryID
LEFT JOIN Production.ProductCategory ON ProductSubcategory.ProductCategoryID = ProductCategory.ProductCategoryID
LEFT JOIN Production.ProductReview ON Product.ProductID = ProductReview.ProductID;

SELECT * FROM Production.ProductReview;

SELECT * FROM [blady].[DIM_PRODUCT];

--DIM_SALESPERSON
INSERT INTO [blady].[DIM_SALESPERSON]
SELECT SalesPerson.BusinessEntityID, FirstName, LastName, Title, Gender, CountryRegionCode, [Group]
FROM Sales.SalesPerson LEFT JOIN Sales.SalesTerritory ON SalesPerson.TerritoryID = Salesterritory.TerritoryID
LEFT JOIN Person.Person ON SalesPerson.BusinessEntityID = Person.BusinessEntityID
LEFT JOIN HumanResources.Employee ON SalesPerson.BusinessEntityID = Employee.BusinessEntityID;

SELECT * FROM [blady].[DIM_SALESPERSON];

--FACT_SALES
INSERT INTO [blady].[FACT_SALES](ProductID, CustomerID, SalesPersonID, OrderDate, ShipDate, OrderQty, UnitPrice, UnitPriceDiscount, LineTotal)
SELECT ProductID, CustomerID, SalesPersonID, blady.datetimeToInt(OrderDate), blady.datetimeToInt(ShipDate), OrderQty, UnitPrice, UnitPriceDiscount, LineTotal
FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID;

SELECT * FROM [blady].[FACT_SALES];


--zad4
--DIM_CUSTOMER
ALTER TABLE [blady].[DIM_CUSTOMER]
ADD CONSTRAINT pk_dCust_id 
PRIMARY KEY([CustomerID]);

--DIM_PRODUCT
ALTER TABLE [blady].[DIM_PRODUCT]
ADD CONSTRAINT pk_dProd_id
PRIMARY KEY ([ProductID]);

--DIM_SALESPERSON
ALTER TABLE [blady].[DIM_SALESPERSON]
ADD CONSTRAINT pk_dSalesPerson_id
PRIMARY KEY ([SalesPersonID]);

--FACT_SALES
ALTER TABLE [blady].[FACT_SALES]
ADD CONSTRAINT fk_dFactSales_pId
FOREIGN KEY ([ProductID]) REFERENCES blady.DIM_PRODUCT([ProductID]);

ALTER TABLE [blady].[FACT_SALES]
ADD CONSTRAINT fk_dFactSales_cId
FOREIGN KEY ([CustomerID]) REFERENCES blady.DIM_CUSTOMER([CustomerID]);

ALTER TABLE [blady].[FACT_SALES]
ADD CONSTRAINT fk_dFactSales_spId
FOREIGN KEY ([SalesPersonID]) REFERENCES blady.DIM_SALESPERSON([SalesPersonID]);

ALTER TABLE [blady].[FACT_SALES]
ADD CONSTRAINT pk_dFactSales_id
PRIMARY KEY ([FactSalesID]);


--zad5
--DIM_CUSTOMER
SELECT * FROM Sales.Customer;
SELECT * FROM blady.DIM_CUSTOMER;

INSERT INTO blady.DIM_CUSTOMER VALUES
(99999, 'Jan', 'Kowalski', 'Poland', 'PL', 'Europe');

INSERT INTO blady.DIM_CUSTOMER VALUES
(1, 'Jan', 'Kowalski', 'Poland', 'PL', 'Europe');

--DIM_PRODUCT
SELECT * FROM Production.Product;
SELECT * FROM blady.DIM_PRODUCT;

INSERT INTO blady.DIM_PRODUCT VALUES
(99999, 'Prod', 0.00, 'Blue', '1', 'Sub', 'Cat');

INSERT INTO blady.DIM_PRODUCT VALUES
(1, 'Prod', 0.00, 'Blue', '1', 'Sub', 'Cat');

--DIM_SALESPERSON
SELECT * FROM Sales.SalesPerson;
SELECT * FROM blady.DIM_SALESPERSON;

INSERT INTO blady.DIM_SALESPERSON VALUES
(99999, 'Jan', 'Kowalski', null, 'F', 'PL', 'Europe');

INSERT INTO blady.DIM_SALESPERSON VALUES
(274, 'Jan', 'Kowalski', null, 'F', 'PL', 'Europe');

--FACT_SALES
SELECT * FROM Sales.SalesOrderDetail;
SELECT * FROM blady.FACT_SALES;

INSERT INTO blady.FACT_SALES VALUES
(99999, 123, null, 20110531, 20110531, 3, 123.123, 0.00, 123.123);

INSERT INTO blady.FACT_SALES VALUES
(776, 99999, null, 20110531, 20110531, 3, 123.123, 0.00, 123.123);

INSERT INTO blady.FACT_SALES VALUES
(776, 29825, 99999, 20110531, 20110531, 3, 123.123, 0.00, 123.123);

SET IDENTITY_INSERT blady.FACT_SALES ON;



--zad6
IF EXISTS
(
	SELECT * 
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'DIM_CUSTOMER' AND TABLE_SCHEMA = 'blady'
)
DROP TABLE blady.DIM_CUSTOMER;

IF EXISTS
(
	SELECT * 
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'DIM_PRODUCT' AND TABLE_SCHEMA = 'blady'
)
DROP TABLE blady.DIM_PRODUCT;

IF EXISTS
(
	SELECT * 
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'DIM_SALESPERSON' AND TABLE_SCHEMA = 'blady'
)
DROP TABLE blady.DIM_SALESPERSON;

IF EXISTS
(
	SELECT * 
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'FACT_SALES' AND TABLE_SCHEMA = 'blady'
)
DROP TABLE blady.FACT_SALES;

DROP FUNCTION IF EXISTS [blady].[getBirthDate];
DROP FUNCTION IF EXISTS [blady].[getHireDate];
DROP FUNCTION IF EXISTS [blady].[datetimeToInt];
DROP SCHEMA IF EXISTS blady;

--zad7

IF EXISTS
(
	SELECT * 
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'DIM_CUSTOMER' AND TABLE_SCHEMA = 'blady'
)
DROP TABLE blady.DIM_CUSTOMER
GO
IF EXISTS
(
	SELECT * 
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'DIM_PRODUCT' AND TABLE_SCHEMA = 'blady'
)
DROP TABLE blady.DIM_PRODUCT
GO
IF EXISTS
(
	SELECT * 
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'DIM_SALESPERSON' AND TABLE_SCHEMA = 'blady'
)
DROP TABLE blady.DIM_SALESPERSON
GO
IF EXISTS
(
	SELECT * 
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'FACT_SALES' AND TABLE_SCHEMA = 'blady'
)
DROP TABLE blady.FACT_SALES
GO
DROP FUNCTION IF EXISTS [blady].[getBirthDate]
GO
DROP FUNCTION IF EXISTS [blady].[getHireDate]
GO
DROP FUNCTION IF EXISTS [blady].[datetimeToInt]
GO

DROP SCHEMA IF EXISTS [blady]
GO


CREATE SCHEMA [blady]
GO

CREATE FUNCTION [blady].[getHireDate](@employeeID INT)
RETURNS date
AS
BEGIN
	RETURN 
	(
		SELECT HireDate 
		FROM HumanResources.Employee 
		WHERE BusinessEntityID = @employeeID
	)
END
GO

CREATE FUNCTION [blady].[getBirthDate](@employeeID INT)
RETURNS date
AS
BEGIN
	RETURN 
	(
		SELECT BirthDate 
		FROM HumanResources.Employee 
		WHERE BusinessEntityID = @employeeID
	)
END
GO

CREATE FUNCTION [blady].[datetimeToInt](@date datetime)
RETURNS INT
AS
BEGIN
	RETURN YEAR(@date) * 10000 + MONTH(@date) * 100 + DAY(@date)
END
GO

CREATE TABLE [blady].[DIM_CUSTOMER]
(
	[CustomerID] INT CONSTRAINT nn_dCust_id NOT NULL,
	[FirstName] Name,
	[LastName] Name,
	[TerritoryName] Name,
	[CountryRegionCode] NVARCHAR(3),
	[Group] NVARCHAR(50)
)
GO

CREATE TABLE [blady].[DIM_PRODUCT]
(
	[ProductID] INT CONSTRAINT nn_dProd_id NOT NULL,
	[Name] Name,
	[ListPrice] money,
	[Color] NVARCHAR(15),
	[Rating] INT,
	[SubCategoryName] Name,
	[CategoryName] Name
)
GO

CREATE TABLE [blady].[DIM_SALESPERSON]
(
	[SalesPersonID] INT CONSTRAINT nn_dSP_id NOT NULL,
	[FirstName] Name,
	[LastName] Name,
	[Title] NVARCHAR(8),
	[Gender] NCHAR(1),
	[CountryRegionCode] NVARCHAR(3),
	[Group] NVARCHAR(50),
	[Age] AS DATEDIFF(YEAR, blady.getBirthDate(SalesPersonID), GETDATE()),
	[Seniority] AS DATEDIFF(YEAR, blady.getHireDate(SalesPersonID), GETDATE())
)
GO

CREATE TABLE [blady].[FACT_SALES]
(
	[FactSalesID] INT IDENTITY(1,1),
	[ProductID] INT,
	[CustomerID] INT,
	[SalesPersonID] INT,
	[OrderDate] INT,
	[ShipDate] INT,
	[OrderQty] SMALLINT,
	[UnitPrice] money,
	[UnitPriceDiscount] money,
	[LineTotal] numeric(38,6)
)
GO
DBCC CHECKIDENT ('blady.FACT_SALES', RESEED, 0)
GO

INSERT INTO [blady].[DIM_CUSTOMER]
SELECT CustomerID, Firstname, LastName, SalesTerritory.[Name], CountryRegionCode, [Group]
FROM Sales.Customer LEFT JOIN Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
LEFT JOIN Sales.SalesTerritory ON Sales.Customer.TerritoryID = Sales.SalesTerritory.TerritoryID;

INSERT INTO [blady].[DIM_PRODUCT]
SELECT DISTINCT Product.ProductID, Product.[Name], ListPrice, Color, AVG(Rating) OVER(PARTITION BY Product.ProductID), ProductSubcategory.[Name], ProductCategory.[Name]
FROM Production.Product LEFT JOIN Production.ProductSubcategory ON Product.ProductSubcategoryID = ProductSubcategory.ProductSubcategoryID
LEFT JOIN Production.ProductCategory ON ProductSubcategory.ProductCategoryID = ProductCategory.ProductCategoryID
LEFT JOIN Production.ProductReview ON Product.ProductID = ProductReview.ProductID;

INSERT INTO [blady].[DIM_SALESPERSON]
SELECT SalesPerson.BusinessEntityID, FirstName, LastName, Title, Gender, CountryRegionCode, [Group]
FROM Sales.SalesPerson LEFT JOIN Sales.SalesTerritory ON SalesPerson.TerritoryID = Salesterritory.TerritoryID
LEFT JOIN Person.Person ON SalesPerson.BusinessEntityID = Person.BusinessEntityID
LEFT JOIN HumanResources.Employee ON SalesPerson.BusinessEntityID = Employee.BusinessEntityID;

INSERT INTO [blady].[FACT_SALES](ProductID, CustomerID, SalesPersonID, OrderDate, ShipDate, OrderQty, UnitPrice, UnitPriceDiscount, LineTotal)
SELECT ProductID, CustomerID, SalesPersonID, blady.datetimeToInt(OrderDate), blady.datetimeToInt(ShipDate), OrderQty, UnitPrice, UnitPriceDiscount, LineTotal
FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID;


ALTER TABLE [blady].[DIM_CUSTOMER]
ADD CONSTRAINT pk_dCust_id 
PRIMARY KEY([CustomerID]);

ALTER TABLE [blady].[DIM_PRODUCT]
ADD CONSTRAINT pk_dProd_id
PRIMARY KEY ([ProductID]);

ALTER TABLE [blady].[DIM_SALESPERSON]
ADD CONSTRAINT pk_dSalesPerson_id
PRIMARY KEY ([SalesPersonID]);

ALTER TABLE [blady].[FACT_SALES]
ADD CONSTRAINT fk_dFactSales_pId
FOREIGN KEY ([ProductID]) REFERENCES blady.DIM_PRODUCT([ProductID]);

ALTER TABLE [blady].[FACT_SALES]
ADD CONSTRAINT fk_dFactSales_cId
FOREIGN KEY ([CustomerID]) REFERENCES blady.DIM_CUSTOMER([CustomerID]);

ALTER TABLE [blady].[FACT_SALES]
ADD CONSTRAINT fk_dFactSales_spId
FOREIGN KEY ([SalesPersonID]) REFERENCES blady.DIM_SALESPERSON([SalesPersonID]);

ALTER TABLE [blady].[FACT_SALES]
ADD CONSTRAINT pk_dFactSales_id
PRIMARY KEY ([FactSalesID]);


SELECT * FROM [blady].[DIM_CUSTOMER];
SELECT * FROM [blady].[DIM_PRODUCT];
SELECT * FROM [blady].[DIM_SALESPERSON];
SELECT * FROM [blady].[FACT_SALES];