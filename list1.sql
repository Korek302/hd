--zad1
SELECT COUNT(*) FROM Production.Product;

SELECT COUNT(*) FROM Production.ProductCategory;

SELECT COUNT(*) FROM Production.ProductSubcategory;

--zad2
SELECT * 
FROM Production.Product
WHERE Color IS NULL;