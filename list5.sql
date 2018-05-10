alter table blady.DIM_CUSTOMER
add [Name] nvarchar(100);

UPDATE blady.DIM_CUSTOMER
SET [Name] = 
CASE
	WHEN (FirstName IS NULL AND LastName IS NULL) THEN NULL
	ELSE CONCAT(CONCAT(FirstName, ' '), LastName)
END;

select * from blady.Dim_customer;


alter table blady.DIM_SALESPERSON
add [Name] nvarchar(100);

UPDATE blady.DIM_SALESPERSON
SET [Name] = 
CASE
	WHEN (FirstName IS NULL AND LastName IS NULL) THEN NULL
	ELSE CONCAT(CONCAT(FirstName, ' '), LastName)
END;

select * from blady.Dim_SALESPERSON;

select sum(OrderQty)/(count(FactSalesID)) from blady.FACT_SALES;

SELECT * FROM blady.FACT_SALES;

SELECT SUM(LineTotal) FROM blady.FACT_SALES;


ALTER TABLE [blady].[FACT_SALES]
ADD [TotalCost] money;

UPDATE [blady].[FACT_SALES]
SET [TotalCost] = OrderQty * UnitPrice;

SELECT * FROM [blady].FACT_SALES WHERE LineTotal != TotalCost;

SELECT SUM(TotalCost)/SUM(UnitPrice) FROM blady.FACT_SALES;

ALTER TABLE blady.FACT_SALES
ADD CONSTRAINT fk_dFactSales_oDate
FOREIGN KEY ([OrderDate]) REFERENCES blady.DIM_TIME([PK_TIME]);

select Rok, Miesiac, sum(LineTotal)
from blady.FACT_SALES join blady.DIM_TIME on OrderDate = PK_TIME
where Rok = 2012 or Rok = 2013
group by Rok, Miesiac
order by Rok;

select SubCategoryName, sum(OrderQty)
from blady.FACT_SALES join blady.DIM_PRODUCT on blady.FACT_SALES.ProductID = blady.DIM_PRODUCT.ProductID
group by SubCategoryName
order by sum(OrderQty) desc;