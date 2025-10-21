DROP TABLE DQLog;
CREATE TABLE DQLog
(
LogID 		int PRIMARY KEY IDENTITY,
RowID 		varbinary(32),		-- This is a physical address of a row stored on a disk and it is UNIQUE
DBName 		nchar(20),
TableName	nchar(20),
RuleNo		smallint,
Action		nchar(6) CHECK (action IN ('allow','fix','reject')) -- Action can be ONLY 'allow','fix','reject'
);

print '***************************************************************'
print '****** DQ Checking and Logging based on DQ Rules***************'
print '***************************************************************'
print '================ BEGIN RULE 1 CHECKING =================='
print 'DQ Rule 1: 	BuyPrice is 0 or Null'
print 'Action: 		Reject'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		Product'
print '------------------------'
--rule 1.1: buyPrice  checking in Products(buyPriced is null or 0)
INSERT INTO 	DQLog(RowID, DBName, TableName, RuleNo, Action) 
SELECT 	%%physloc%%, 'saleAU_NZ','product',1,'reject' 
FROM 	saleAU_NZ.dbo.[product] 
WHERE 	(buyPrice is null )or buyPrice = 0

--check in DQlog table
--SELECT * from DQLog 
--0 row effect 

print 'DQ Rule 1: 	buyPrice is negative'
print 'Action: 		Fix'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		Products'
print '------------------------'
--rule 1.2: buyPrice  checking in Products  (buyPrice is negative)
INSERT INTO 	DQLog(RowID, DBName, TableName, RuleNo, Action) 
SELECT 	%%physloc%%, 'saleAU_NZ','product',1,'fix' 
FROM 	saleAU_NZ.dbo.[product] 
WHERE 	(buyPrice <0)

--check in DQlog table
--SELECT * from DQLog 
--1 row effect 

--product physical add: 0xB801000001000E00
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[Product] p 
--WHERE 	p.%%physloc%% = 0xB801000001000E00;  
-- result buyPrice is -55.70
print '=============== END RULE 1 CHECKING ===================='
----------------------------------------------------------------------------------------
print '================ BEGIN RULE 2 CHECKING ================='
print 'DQ Rule 2: 	priceEach is negative'
print 'Action: 		Fix'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		OrderDetails'
print '------------------------'
--rule 2.1: priceEach checking in orderDetail(priceEach is null or 0)
INSERT INTO 	DQLog(RowID, DBName, TableName, RuleNo, Action) 
SELECT 	%%physloc%%, 'saleAU_NZ','orderDetail',2,'reject' 
FROM 	saleAU_NZ.dbo.[orderDetail] 
WHERE 	(priceEach is null )or priceEach = 0

--check in DQlog table
--SELECT * from DQLog 
--0 row effect 
print 'DQ Rule 2: 	priceEach is 0 or Null'
print 'Action: 		Reject'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		OrderDetails'
print '------------------------'
--rule 2.2: priceEach checking in orderDetails(priceEach is negative)
INSERT INTO 	DQLog(RowID, DBName, TableName, RuleNo, Action) 
SELECT 	%%physloc%%, 'saleAU_NZ','orderDetail',2,'fix' 
FROM 	saleAU_NZ.dbo.[orderDetail] 
WHERE 	(priceEach <0)

--0 row effect 
print '=============== END RULE 2 CHECKING ===================='
-------------------------------------------------------------------
print '================ BEGIN RULE 3 CHECKING ================='
print 'DQ Rule 3: 	Quantity Ordered is 0 or Null'
print 'Action: 		Reject'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		OrderDetails'
print '------------------------'
--rule 3.1: quantityOrdered checking in orderDetail(quantityOrdered is null or 0)
INSERT INTO 	DQLog(RowID, DBName, TableName, RuleNo, Action) 
SELECT 	%%physloc%%, 'saleAU_NZ','orderDetail',3,'reject' 
FROM 	saleAU_NZ.dbo.[orderDetail] 
WHERE 	(quantityOrdered is null )or priceEach = 0

--check in DQlog table
--SELECT * from DQLog 
--0 row effect 

print 'DQ Rule 3: 	Quantity Ordered is negative'
print 'Action: 		Fix'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		OrderDetails'
print '------------------------'
--rule 3.2: quantityOrdered checking in orderDetail(quantityOrdered is negative)
INSERT INTO 	DQLog(RowID, DBName, TableName, RuleNo, Action) 
SELECT 	%%physloc%%, 'saleAU_NZ','orderDetail',3,'fix' 
FROM 	saleAU_NZ.dbo.[orderDetail] 
WHERE 	(quantityOrdered <0)

--check in DQlog table
--SELECT * from DQLog 
--0 row effect 
print '=============== END RULE 3 CHECKING ===================='
--------------------------------------------------------------------------------------------
print '================ BEGIN RULE 4 CHECKING ================='
print 'DQ Rule 4: 	MSRP < buyPrice on a product'
print 'Action: 		Reject'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		Products'
print '------------------------'
--rule 4: MSRP checking in Product  
INSERT INTO 	DQLog(RowID, DBName, TableName, RuleNo, Action) 
SELECT 	%%physloc%%, 'saleAU_NZ','product',4,'reject' 
FROM 	saleAU_NZ.dbo.[product] 
WHERE 	MSRP<buyPrice

--check in DQlog table
--SELECT * from DQLog 
--1 row effect 

--product physical add: 0xB801000001000800
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[Product] p 
--WHERE 	p.%%physloc%% = 0xB801000001000800;  
-- result buyPrice is 77.90 MSRP is -136.67
print '=============== END RULE 4 CHECKING ===================='
-------------------------------------------------------------------------------------
print '================ BEGIN RULE 5 CHECKING =================='
print 'DQ Rule 5: 	Customers with wrong Country format'
print 'Action: 		Fix'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		customers'
print '------------------------'
--rule 5.1: Country checking in Customers 
INSERT INTO 	DQLog(RowID, DBName, TableName, RuleNo, Action) 
SELECT 	%%physloc%%, 'saleAU_NZ','customer',5,'fix' 
FROM 	saleAU_NZ.dbo.[customer] 
where Country in ( 'Australia', 'New Zealand ')
--check in DQlog table
--SELECT * from DQLog 
--9 row effect 

--logID=3  product physical add: 0x3801000001000000
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[customer] p 
--WHERE 	p.%%physloc%% = 0x3801000001000000;  
--logID=4 product physical add: 0x3801000001000100
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[customer] p 
--WHERE 	p.%%physloc%% = 0x3801000001000100;  
--logID=5 product physical add: 0x3801000001000200
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[customer] p 
--WHERE 	p.%%physloc%% = 0x3801000001000200;  
--logID=6 product physical add: 0x3801000001000300
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[customer] p 
--WHERE 	p.%%physloc%% = 0x3801000001000300;  
--logID=7 product physical add: 0x3801000001000400
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[customer] p 
--WHERE 	p.%%physloc%% = 0x3801000001000400;  
--logID=8 product physical add: 0x3801000001000500
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[customer] p 
--WHERE 	p.%%physloc%% = 0x3801000001000500;  
--logID=9 product physical add: 0x3801000001000600
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[customer] p 
--WHERE 	p.%%physloc%% = 0x3801000001000600;  
--logID=10 product physical add: 0x3801000001000700
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[customer] p 
--WHERE 	p.%%physloc%% = 0x3801000001000700;  
--logID=11 product physical add: 0x3801000001000800
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[customer] p 
--WHERE 	p.%%physloc%% = 0x3801000001000800;  
print 'DQ Rule 5: 	Office with wrong Country format'
print 'Action: 		Fix'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		offices'
print '------------------------'
--rule 5.2: Country checking in Office
INSERT INTO 	DQLog(RowID, DBName, TableName, RuleNo, Action) 
SELECT 	%%physloc%%, 'saleAU_NZ','office',5,'fix' 
FROM 	saleAU_NZ.dbo.[office] 
where Country in ('Australia', 'New Zealand ')
--check in DQlog table
--SELECT * from DQLog 
--4 rows effect 

--logID=11 product physical add: 0x3801000001000800
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[customer] p 
--WHERE 	p.%%physloc%% = 0x3801000001000800;  
--logID=12 product physical add: 0x2001000001000000
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[office] p 
--WHERE 	p.%%physloc%% = 0x2001000001000000;  
--logID=13 product physical add: 0x2001000001000100
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[office] p 
--WHERE 	p.%%physloc%% =0x2001000001000100;  
--logID=14 product physical add: 0x2001000001000200
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[office] p 
--WHERE 	p.%%physloc%% =0x2001000001000200;  
--logID=15 product physical add: 0x2001000001000300
--SELECT 	* 
--FROM 	saleAU_NZ.dbo.[office] p 
--WHERE 	p.%%physloc%% =0x2001000001000300;  
print '=============== END RULE 5 CHECKING ===================='
-------------------------------------------------------
print '================ BEGIN RULE 6 CHECKING ===================='
print 'DQ Rule 6: 	ProductCode doesnt exist or is null '
print 'Action: 		Reject'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		OrderDetail'
print '------------------------'
--rule 6: ProductCode checking in Order Details  
INSERT INTO 	DQLog(RowID, DBName, TableName, RuleNo, Action) 
SELECT 	%%physloc%%, 'saleAU_NZ','orderDetail',6,'reject' 
FROM 	saleAU_NZ.dbo.[orderDetail] 
WHERE 	productCode IS NULL OR NOT EXISTS (select productCode from saleAU_NZ.dbo.product)

--check in DQlog table
--SELECT * from DQLog 
--0 row effect 
print '=============== END RULE 6 CHECKING ======================'
--------------------------------------------------------------------
print '================ BEGIN RULE 7 CHECKING ===================='
print 'DQ Rule 7: 	CustomerNumber doesn¡¯t exist or is null and any of: addressLine1, addressLine2 and City are null'
print 'Action: 		Reject'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		Customer'
print '------------------------'
--rule 7: CustomerNumber, addressLine1, addressLine2 and City checking in Customers 
INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT 	%%physloc%%, 'saleAU_NZ','customer',7,'reject'
FROM saleAU_NZ.dbo.[customer]  
WHERE customerNumber is NULL and (addressLine1 is NULL or addressLine2 is null or city is NULL)

--check in DQlog table
--SELECT * from DQLog 
--0 row effect 
print '=============== END RULE 7 CHECKING ======================'
-------------------------------------------------------------------------------------------------------------------
print '================ BEGIN RULE 8 CHECKING ===================='
print 'DQ Rule 8: 	requiredDate checking in Orders'
print 'Action: 		Fix'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		productorder'
print '------------------------'
--rule 8: requiredDate, shippedDate checking in productOrder
INSERT INTO 	DQLog(RowID, DBName, TableName, RuleNo, Action) 
SELECT 	%%physloc%%, 'saleAU_NZ','productOrder',8,'fix' 
FROM 	saleAU_NZ.dbo.[productorder] 
where  ((orderDate > requiredDate) or requiredDate IS NULL);
--3 rows 
print 'DQ Rule 8: 	shippedDate checking in Orders'
print 'Action: 		Fix'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		productorder'
print '------------------------'
INSERT INTO 	DQLog(RowID, DBName, TableName, RuleNo, Action) 
SELECT 	%%physloc%%, 'saleAU_NZ','productOrder',8,'fix' 
FROM 	saleAU_NZ.dbo.[productorder] 
where((orderDate > shippedDate) or (shippedDate IS NULL and status='Shipped'));
--1 row effect 
print '=============== END RULE 8 CHECKING ======================'
---------------------------------------------------------------------------------------------------------
print '================ BEGIN RULE 9 CHECKING ===================='
print 'DQ Rule 9: 	amount checking is null or 0 in Payment'
print 'Action: 		Reject'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		payment'
print '------------------------'

--rule 9.1: amount checking in Payment(amount is null or 0)
INSERT INTO 	DQLog(RowID, DBName, TableName, RuleNo, Action) 
SELECT 	%%physloc%%, 'saleAU_NZ','Payment',9,'reject' 
FROM 	saleAU_NZ.dbo.[payment] 
WHERE 	(amount is null )or amount = 0
--(0 rows affected)
print 'DQ Rule 9: 	amount checking is nagetive Payment'
print 'Action: 		Fix'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		payment'
print '------------------------'
--rule 9.2: amount checking in Payment(amount is nagetive)
INSERT INTO 	DQLog(RowID, DBName, TableName, RuleNo, Action) 
SELECT 	%%physloc%%, 'saleAU_NZ','Payment',9,'fix' 
FROM 	saleAU_NZ.dbo.[payment] 
WHERE 	(amount <0)
--(0 rows affected)
print '================ END RULE 9 CHECKING ======================'
print '================ BEGIN RULE 10 CHECKING ===================='
print 'DQ Rule 10: 	paymenntDate checking in payment'
print 'Action: 		allow'
print 'Database: 	saleAU_NZ'
print '------------------------'
print 'Table: 		payment'
print '------------------------'

--rule 10.1 paymentDate checking in Payment (orderDate>paymentDate)
INSERT INTO DQLog(RowID,DBName,TableName,RuleNo,Action)
SELECT        m.%%physloc%%,  'saleAU_NZ','payment',10,'allow'
FROM saleAU_NZ.dbo.payment m
INNER JOIN saleAU_NZ.dbo.customer c ON c.customerNumber = m.customerNumber
INNER JOIN saleAU_NZ.dbo.productorder po ON po.customerNumber = c.customerNumber
WHERE po.orderDate> m.paymentDate
--(23 rows affected)
print '================ END RULE 10 CHECKING ======================'

print '***************************************************************'
print '******************* End of DQlog checking *********************'
print '***************************************************************'
print 'Total rows affected'
 SELECT		TableName, RuleNo, action, COUNT(*) as TotalRecords 
 FROM		DQLog
 GROUP BY	TableName, RuleNo, action;
