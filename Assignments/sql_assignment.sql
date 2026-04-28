-- Section 1: Basic Queries

-- 1. Retrieve all products with ListPrice > 100.
select * from dbo.ProductMaster where ListPrice >100;

-- 2. Display distinct product categories using DISTINCT.
select distinct ProductSubcategoryID  from dbo.ProductMaster ;

-- 3. Find products where ProductName LIKE '%Bike%'.
Select * from dbo.ProductMaster where ProductName like '%Bike%';

-- 4. Retrieve top 10 most expensive products using TOP.
Select top 10 ProductName from dbo.ProductMaster order by ListPrice desc;

-- 5. List customers ordered by CustomerName
Select * from dbo.CustomerMaster order by Customer;

--Section 2: Filtering & Sorting--
--6. Retrieve orders where TotalDue > 1000.
Select * from dbo.OrderHeader where TotalDue > 1000;

-- 7. Find customers whose email contains 'gmail'.
Select * from dbo.CustomerMaster where EmailAddress like '%gmail%';

-- 8. Sort products by StandardCost descending.
Select * from dbo.ProductMaster order by StandardCost desc;

-- 9. Retrieve products where Size IS NOT NULL.
Select * from dbo.ProductMaster where Size is not null;

-- 10. Display orders between two dates
Select * from dbo.OrderHeader where OrderDate >= '2013-01-01' and OrderDate < '2026-07-01';

-- Section 3: Aggregations --

-- 11. Find total sales per product using GROUP BY.
Select pm.product as Product, SUM(SalesAmount) as TotalSales 
from dbo.orderDetail od
Join dbo.ProductMaster pm on od.ProductNo = pm.ProductID 
group by PRODUCT order by TotalSales;


-- 12. Count number of orders per customer.
Select cm.CustomerID as Id, cm.CustomerName, count(*) as Orders 
from dbo.CustomerMaster cm
Join dbo.OrderHeader oh on cm.CustomerID = oh.CustomerNo
Group By cm.CustomerID, cm.CustomerName order by orders;

-- 13. Find average order value.
Select AVG(SubTotal) as AverageOrderValue from dbo.OrderHeader;

-- 14. Retrieve categories having total sales > 5000 using HAVING.

-- 15. Find max and min ListPrice
Select max(ListPrice) as MaxListPrice, min(ListPrice) as MinListPrice from dbo.ProductMaster;

-- Section 4: CASE WHEN
-- 16. Categorize products as 'Expensive' or 'Cheap' based on ListPrice.
SELECT ProductID, ProductName, ListPrice,
    CASE
        WHEN ListPrice > 1000 THEN 'Expensive'
        ELSE 'Cheap'
    END AS PriceCategory
FROM dbo.ProductMaster 
Order By ProductID;

-- 17. Classify orders as 'High', 'Medium', 'Low' based on TotalDue.
Select OrderID, CustomerNo, TotalDue, 
	Case
		When Totaldue > 10000 then 'High'
		When Totaldue between 5000 and 10000 then 'Medium'
		else 'Low'
	End as OrderClassification
from dbo.OrderHeader
Order by CustomerNo;

-- Section 5: Subqueries

-- 18. Find products with ListPrice greater than average price.
Select ProductName, ListPrice from dbo.ProductMaster  where ListPrice > 
(Select AVG(ListPrice) as avgListPrice from dbo.ProductMaster);

-- 19. Retrieve customers who placed orders above average order value.
Select  Distinct cm.CustomerID as Id, cm.CustomerName from dbo.CustomerMaster cm
Join dbo.OrderHeader oh on cm.CustomerID = oh.CustomerNo
where oh.SubTotal > 
(Select AVG(SubTotal) as AverageOrderValue from dbo.OrderHeader);


-- 20. Find second highest TotalDue using subquery
Select top 1 TotalDue from 
(Select top 2 TotalDue from OrderHeader order by TotalDue desc) 
as td Order by TotalDue asc;

-- Section 6: CTEs

-- 21. Use CTE to calculate total sales per product and filter top 5.
With ProductSales as (
Select od.ProductNo, pm.ProductName, SUM(od.SalesAmount) as TotalSales from dbo.ProductMaster pm
Join dbo.OrderDetail od on pm.ProductID = od.ProductNo
Group By od.ProductNo, pm.ProductName
) 
Select TOP 5 ProductSales.ProductName, ProductSales.TotalSales from ProductSales Order by TotalSales Desc

-- 22. Use CTE to rank customers based on spending.
 With CustomerSpending as (
 Select cm.CustomerID, cm.CustomerName, SUM(oh.SubTotal) as Spending from dbo.CustomerMaster cm
 Join dbo.OrderHeader oh on cm.CustomerID = oh.CustomerNo
 Group by cm.CustomerID, cm.CustomerName)
 Select  Rank() over (Order By Spending desc) as SpendingRank, CustomerID, CustomerName, Spending from CustomerSpending;

-- Section 7: IF ELSE

-- 23. Write a query using IF ELSE to check if total orders exceed 100.
 DECLARE @TotalOrders INT;

SELECT @TotalOrders = count(*) FROM dbo.OrderHeader;
IF @TotalOrders > 100
    PRINT 'Total orders exceed 100. Count: ' + CAST(@TotalOrders AS VARCHAR);
ELSE
    PRINT 'Total orders do not exceed 100. Count: ' + CAST(@TotalOrders AS VARCHAR);

-- 24. Use IF ELSE to categorize business performance based on revenue.
 DECLARE @TotalRevenue Decimal(18,4);
 Select @TotalRevenue = SUM(SubTotal) from dbo.OrderHeader
 IF @TotalRevenue > 1000000
 PRINT 'Excellent Performance. Revenue: ' + CAST(@TotalRevenue AS VARCHAR);
 ELSE
 PRINT 'Needs Improvement. Revenue: ' + CAST(@TotalRevenue AS VARCHAR);

 Print @TotalRevenue;

-- Section 8: JOINS

-- 25. Retrieve all orders with corresponding customer names (INNER JOIN).
Select  cm.CustomerName, oh.OrderID, oh.OrderDate, oh.ShipDate, oh.SubTotal, oh.TaxAmt, oh.TotalDue from dbo.OrderHeader oh
Inner Join dbo.CustomerMaster cm on oh.CustomerNo = cm.CustomerID 
Order by OrderDate 

-- 26. List all products sold in each order (JOIN Products, OrderDetails).
Select pm.ProductID, pm.ProductName, od.SalesOrderID from dbo.ProductMaster pm
Join dbo.OrderDetail od on pm.ProductID = od.ProductNo
Order by od.SalesOrderID

-- 27. Find customers who have not placed any orders (LEFT JOIN).
Select cm.CustomerName from dbo.CustomerMaster cm
 left join dbo.OrderHeader oh on cm.CustomerID = oh.CustomerNo
WHERE oh.CustomerNo IS NULL
ORDER BY cm.CustomerID;

-- 28. Retrieve total sales per product using joins.
Select pm.ProductID, pm.ProductName, Sum(od.SalesAmount) as TotalSales from dbo.ProductMaster pm
Join dbo.OrderDetail od on pm.ProductID = od.ProductNo
Group by pm.ProductID, pm.ProductName
Order by pm.ProductID;

-- 29. Display order details with product name, quantity, and sales amount.
Select pm.ProductName, od.OrderQty, od.SalesAmount from dbo.ProductMaster pm
Join dbo.OrderDetail od on pm.ProductID = od.ProductNo
Order by pm.ProductID;

-- 30. Find total revenue generated per customer using joins.
Select cm.CustomerID, cm.CustomerName, SUM(oh.SubTotal) AS TotalRevenue
from dbo.CustomerMaster cm
Left Join dbo.OrderHeader oh ON cm.CustomerID = oh.CustomerNo
Group by cm.CustomerID, cm.CustomerName
order by cm.CustomerID;


-- Section 9: System Stored Procedures

-- 31. Use sp_help to view table structure.
sp_help 'dbo.CustomerMaster'

-- 32. Use sp_columns to list columns of Products table.
sp_columns 'dbo.CustomerMaster'

-- 33. Use sp_spaceused to check table size.
sp_spaceused 'dbo.CustomerMaster'
