--Compare total customer row and dimCustomer rows 
select count(*) as [Total customer rows]
from saleAU_NZ.dbo.customer
--9
select count(*) as [Total dimCustomer rows]
from dimCustomers
--9
--Compare total employee row and dimemployee rows 
select count(*) as [Total employee rows]
from saleAU_NZ.dbo.employee e
inner join  saleAU_NZ.dbo.office o
on e.officeCode=o.officeCode
--10
select count(*) as [Total dimEmployee rows]
from dimEmployee
--10
--Compare total product row and dimProduct rows 
select count(*) as [Total product rows]
from saleAU_NZ.dbo.product p
inner join saleAU_NZ.dbo.productline pl
on pl.productLine=p.productLine
--110
select count(*) as [Total dimProducts rows]
from dimProducts
--109 (one reject)
--Compare total payment row and dimPayment rows 
select count(*) as [Total payment rows]
from saleAU_NZ.dbo.payment
--23
select count(*) as [Total dimPayment rows]
from dimPayment
--5

print '***************************************************************'
print '****** 1: Validating Data in dimension tables'
print '***************************************************************'
print 'Validating dimCustomers data on CustomerNumber'
SELECT * 
FROM dimCustomers dc 
WHERE dc.CustomerNumber NOT IN 
( 
		select customerNumber
		from saleAU_NZ.dbo.Customer c
		where dc.CustomerNumber=c.customerNumber

)
print 'Validating dimEmployee data on EmployeeNumber'
SELECT * 
FROM dimEmployee de
WHERE de.employeeNumber NOT IN 
( 
		select employeeNumber
		from saleAU_NZ.dbo.employee e, 
			 saleAU_NZ.dbo.office o
		where de.employeeNumber =e.employeeNumber
		and   o.officeCode = e.officeCode
)
print 'Validating dimProducts data on ProductCode'
select *
from dimProducts dp
where dp.productCode NOT IN 
(
		select productCode
		from saleAU_NZ.dbo.product p, saleAU_NZ.dbo.productline pl
		where p.productLine = pl.productLine
		and dp.productCode=p.productCode
)

print 'Validating dimPayment data on checkNumber'
select *
from dimPayment dpa
where dpa.checkNumber NOT IN 
(
		select checkNumber
		from saleAU_NZ.dbo.payment p
		where dpa.checkNumber=p.checkNumber
)
print 'Validating factTable data'

SELECT count(*)
FROM factOrders f, dimProducts dp, dimCustomers dc, dimEmployee de, dimPayment dpa,
	 dimTime dt1, dimTime dt2, dimTime dt3
WHERE f.CustomerKey =dc.CustomerKey     
	  AND f.ProductKey = dp.ProductKey   
	  AND f.EmployeeKey = de.EmployeeKey
	  AND f.PaymentKey= dpa.PaymentKey
	  AND f.OrderDateKey = dt1.TimeKey     
	  AND f.RequiredDateKey = dt2.TimeKey     
	  AND f.ShippedDateKey = dt3.TimeKey
	  AND not EXISTS
	--not exists is simillar to NOT IN     
	(     SELECT *     
		  FROM saleAU_NZ.dbo.productorder po,			
			   saleAU_NZ.dbo.OrderDetail od,
			   saleAU_NZ.dbo.product p,
			   saleAU_NZ.dbo.customer c,
			   saleAU_NZ.dbo.employee e,
			   saleAU_NZ.dbo.payment pa
		  WHERE po.orderNumber= od.orderNumber           
		        AND f.orderNumber =po.orderNumber         
				AND dp.ProductCode = p.productCode         
				AND dc.CustomerNumber = c.customerNumber
				AND de.employeeNumber = e.employeeNumber
				AND dpa.checkNumber= pa.checkNumber
				AND dt1.Date = po.OrderDate         
				AND dt2.Date = po.RequiredDate 
				AND dt3.Date = po.shippedDate
				AND f.totalPrice = od.quantityOrdered * od.priceEach
				AND f.totalProfit =od.quantityOrdered*(od.priceEach-p.buyPrice)
				AND	f.totalPossibleProfit =  od.quantityOrdered *(p.MSRP-p.buyPrice)
)
--those are the date fixed data in rule 8 

SELECT count(*)
FROM factOrders f, dimProducts dp, dimCustomers dc, dimEmployee de, dimPayment dpa,
	 dimTime dt1, dimTime dt2, dimTime dt3
WHERE f.CustomerKey =dc.CustomerKey     
	  AND f.ProductKey = dp.ProductKey   
	  AND f.EmployeeKey = de.EmployeeKey
	  AND f.PaymentKey= dpa.PaymentKey
	  AND f.OrderDateKey = dt1.TimeKey     
	  AND f.RequiredDateKey = dt2.TimeKey     
	  AND f.ShippedDateKey = dt3.TimeKey
	  AND EXISTS
	--not exists is simillar to IN     
	(     SELECT *     
		  FROM saleAU_NZ.dbo.productorder po,			
			   saleAU_NZ.dbo.OrderDetail od,
			   saleAU_NZ.dbo.product p,
			   saleAU_NZ.dbo.customer c,
			   saleAU_NZ.dbo.employee e,
			   saleAU_NZ.dbo.payment pa
		  WHERE po.orderNumber= od.orderNumber           
		        AND f.orderNumber =po.orderNumber         
				AND dp.ProductCode = p.productCode         
				AND dc.CustomerNumber = c.customerNumber
				AND de.employeeNumber = e.employeeNumber
				AND dpa.checkNumber= pa.checkNumber
				AND dt1.Date = po.OrderDate         
				AND dt2.Date = po.RequiredDate 
				AND dt3.Date = po.shippedDate
				AND f.totalPrice = od.quantityOrdered * od.priceEach
				AND f.totalProfit =od.quantityOrdered*(od.priceEach-p.buyPrice)
				AND	f.totalPossibleProfit =  od.quantityOrdered *(p.MSRP-p.buyPrice)
)
--those are the date fit condition data



--customerNumber= 5114, OrderNumber = 510120
--should get the same number of different type of product in onrdernumber 510120, 510125, 510347
SELECT 
    o.orderNumber,
    COUNT(productCode) AS HowManyProductOrdered
FROM 
    saleAU_NZ.dbo.orderdetail o
JOIN 
    saleAU_NZ.dbo.productorder po ON o.orderNumber = po.orderNumber
WHERE 
    customerNumber = 5114 and o.orderNumber = 510120
GROUP BY 
    o.orderNumber;

SELECT 
    COUNT(DISTINCT fo.productKey) AS DistinctProductCount
FROM 
    factOrders AS fo
JOIN 
    dimCustomers AS dc ON fo.CustomerKey = dc.CustomerKey
WHERE 
    dc.CustomerNumber = 5114 AND fo.OrderNumber =510347;

-- All fact table orderNumber is from saleAU_NZ

select DISTINCT OrderNumber
from factOrders 
where OrderNumber not in (select DISTINCT o.orderNumber
from  saleAU_NZ.dbo.orderdetail o
JOIN 
    saleAU_NZ.dbo.productorder po ON o.orderNumber = po.orderNumber)
--All fact table's price from from saleAU_NZ orderDetail
SELECT *
FROM factOrders AS fo
JOIN dimProducts AS dp ON fo.ProductKey = dp.ProductKey
WHERE fo.PriceEach IN (
    SELECT DISTINCT PriceEach
    FROM saleAU_NZ.dbo.orderdetail
);
--Validate quantity in fact table
SELECT DISTINCT fo.QuantityOrdered
FROM factOrders AS fo
WHERE 
    fo.OrderNumber = 510120 
    AND  not EXISTS (
        SELECT 1
        FROM saleAU_NZ.dbo.orderdetail AS od
        WHERE 
            od.OrderNumber = fo.OrderNumber
            AND od.QuantityOrdered = fo.QuantityOrdered
    );

--validate total price 
SELECT 
    fo.TotalPrice AS TotalPriceInFactTable
FROM 
    factOrders AS fo
WHERE 
    fo.OrderNumber = 510120
AND fo.TotalPrice Not IN (
    SELECT od.QuantityOrdered * od.PriceEach AS CalculatedTotalPrice
    FROM saleAU_NZ.dbo.orderdetail AS od
    WHERE od.OrderNumber = 510120
);
--vaildate total profit 
SELECT 
    fo.TotalProfit
FROM 
    factOrders AS fo
WHERE 
    fo.OrderNumber = 510120
and fo.TotalProfit Not in (SELECT (od.QuantityOrdered * (od.PriceEach - p.buyPrice)) AS CalculatedTotalProfit
    FROM saleAU_NZ.dbo.orderdetail od, saleAU_NZ.dbo.product p 
    WHERE od.OrderNumber = 510120 and od.productCode=p.productCode)
--vaildate total Possible Profit
select fo.TotalPossibleProfit
FROM 
    factOrders AS fo
WHERE 
    fo.OrderNumber = 510120
and fo.TotalPossibleProfit Not in (SELECT (od.QuantityOrdered * (p.MSRP - p.buyPrice))   AS CalculatedPossibleProfit
    FROM saleAU_NZ.dbo.orderdetail od, saleAU_NZ.dbo.product p 
    WHERE od.OrderNumber = 510120 and od.productCode=p.productCode)


