-- Merge data into dimCustomers table
MERGE INTO dimCustomers AS dc
USING (
    SELECT 
        customerNumber, customerName, city, country, salesRepEmployeeNumber
    FROM 
        saleAU_NZ.dbo.customer c
    WHERE 
        c.%%physloc%% NOT IN (
            SELECT RowID
            FROM DW_Assignment.dbo.DQlog
            WHERE 
                DBName = 'saleAU_NZ' 
                AND TableName = 'customer' 
                AND RuleNo = 7 
                AND Action = 'reject'
        )
) AS c ON dc.customerNumber = c.customerNumber
WHEN NOT MATCHED THEN
    INSERT (customerNumber, customerName, city, country, salesRepEmployeeNumber)
    VALUES (c.customerNumber, c.customerName, c.city, c.country, c.salesRepEmployeeNumber);
--(9 rows affected)
-- Apply Data Quality Rule 5: Standardize country values to 'AU' for Australia
UPDATE dimCustomers
SET Country = 'AU' 
WHERE Country IN ('Australia', 'australia');
--(5 rows affected)
-- Apply Data Quality Rule 5: Standardize country values to 'NZ' for New Zealand
UPDATE dimCustomers
SET Country = 'NZ' 
WHERE Country IN ('New Zealand', 'new zealand');
--(4 rows affected)

---------------------------------------------------------------------------------------
-- Merge data into dimEmployee table
MERGE INTO dimEmployee AS de
USING (
    SELECT 
        e.employeeNumber, 
        e.firstName + ' ' + e.lastName AS employeeName, 
        o.city, 
        o.country
    FROM 
        saleAU_NZ.dbo.employee e
    JOIN 
        saleAU_NZ.dbo.office o ON e.officeCode = o.officeCode
) AS src ON de.employeeNumber = src.employeeNumber

WHEN NOT MATCHED THEN
    INSERT (employeeNumber, employeeName, city, country)
    VALUES (src.employeeNumber, src.employeeName, src.city, src.country);
--(10 rows affected)
-- Apply Data Quality Rule 5: Standardize country values to 'AU' for Australia
UPDATE dimEmployee
SET Country = 'AU' 
WHERE Country IN ('Australia', 'australia');
--(6 rows affected)
-- Apply Data Quality Rule 5: Standardize country values to 'NZ' for New Zealand
UPDATE dimEmployee
SET Country = 'NZ' 
WHERE Country IN ('New Zealand', 'new zealand');
--(4 rows affected)
---------------------------------------------------------------------------------------
-- Merge data into dimProduct table
MERGE INTO dimProducts AS dp
USING (
    SELECT 
        p.productCode,
        p.productName,
        pl.productLine,
        p.quantityInStock,
        p.buyPrice,
        p.MSRP
    FROM 
        saleAU_NZ.dbo.product p
    JOIN 
        saleAU_NZ.dbo.productLine pl ON p.productLine = pl.productLine
    WHERE 
        p.%%physloc%% NOT IN (
            SELECT RowID
            FROM DW_Assignment.dbo.DQlog
            WHERE 
                DBName = 'saleAU_NZ' 
                AND TableName = 'product' 
                AND RuleNo IN (1, 4) -- both rules 1 and 4
                AND Action = 'reject'
        )
) AS src ON dp.productCode = src.productCode
WHEN NOT MATCHED THEN
    INSERT (productCode, productName, productLine, quantityInStock, buyPrice, MSRP)
    VALUES (src.productCode, src.productName, src.productLine, src.quantityInStock, src.buyPrice, src.MSRP);
--(109 rows affected)
-- Apply Data Quality Rule 1: if buyPrice is negative, convert it to a positive number  
UPDATE dimProducts
SET buyPrice = ABS(buyPrice)
WHERE buyPrice < 0;
--(1 row affected)
---------------------------------------------------------------------------------------
-- Merge data into dimPayment table
MERGE INTO dimPayment AS dp
USING (
    SELECT 
        customerNumber,
        checkNumber,
        paymentDate,
        amount
    FROM 
        saleAU_NZ.dbo.payment p
	 WHERE 
        p.%%physloc%% NOT IN (
            SELECT RowID
            FROM DW_Assignment.dbo.DQlog
            WHERE 
                DBName = 'saleAU_NZ' 
                AND TableName = 'payment' 
                AND RuleNo = 9
                AND Action ='reject'
        )
) AS src ON dp.checkNumber = src.checkNumber
WHEN NOT MATCHED THEN
    INSERT (customerNumber, checkNumber, paymentDate, amount)
    VALUES (src.customerNumber, src.checkNumber, src.paymentDate, src.amount);
--(23 rows affected)
UPDATE dimPayment
SET amount = ABS(Amount)
WHERE Amount < 0;
--(0 rows affected)

--------------------------------------------------------------------------------------------------------------
MERGE INTO factOrders AS fo
USING (
    SELECT
        dp.ProductKey,
        dc.CustomerKey,
        de.EmployeeKey,
        dpa.PaymentKey,
        dt1.TimeKey AS OrderDateKey,
        -- Conditionally set RequiredDateKey using a CASE statement
        CASE -- If OrderDate > RequiredDate or RequiredDate is NULL
            WHEN (po.OrderDate > po.RequiredDate OR po.RequiredDate IS NULL) THEN dt2.TimeKey 
            ELSE dt3.TimeKey  -- Use po.RequiredDate otherwise
        END AS RequiredDateKey,
        -- Conditionally set ShippedDateKey using a CASE statement
        CASE-- If OrderDate > ShippedDate or (ShippedDate is NULL and status='Shipped')
            WHEN (po.OrderDate > po.ShippedDate OR (po.ShippedDate IS NULL AND po.Status = 'Shipped')) THEN dt4.TimeKey  
            ELSE dt5.TimeKey  -- Use po.ShippedDate otherwise
        END AS ShippedDateKey,
        po.Status,
        po.OrderNumber,
        od.QuantityOrdered,
        od.PriceEach,
        od.QuantityOrdered * od.PriceEach AS TotalPrice,
        od.QuantityOrdered * (od.PriceEach - dp.BuyPrice) AS TotalProfit,
        od.QuantityOrdered * (dp.MSRP - dp.BuyPrice) AS TotalPossibleProfit
    FROM
        saleAU_NZ.dbo.ProductOrder po
        INNER JOIN saleAU_NZ.dbo.OrderDetail od ON od.OrderNumber = po.OrderNumber
        INNER JOIN dimProducts dp ON dp.ProductCode = od.ProductCode
        INNER JOIN dimCustomers dc ON dc.CustomerNumber = po.CustomerNumber
        INNER JOIN dimEmployee de ON de.EmployeeNumber = dc.SalesRepEmployeeNumber
        INNER JOIN dimPayment dpa ON dpa.CustomerNumber = dc.CustomerNumber
        INNER JOIN dimTime dt1 ON dt1.Date = po.OrderDate 
        INNER JOIN dimTime dt2 ON dt2.Date = DATEADD(DAY, 7, po.OrderDate)  -- Adding 7 days to OrderDate for RequiredDate if needed
        INNER JOIN dimTime dt3 ON dt3.Date = po.requiredDate
        INNER JOIN dimTime dt4 ON dt4.Date = DATEADD(DAY, 2, po.OrderDate)  -- Adding 2 days to OrderDate for ShippedDate if needed
        INNER JOIN dimTime dt5 ON dt5.Date = po.ShippedDate
    WHERE 
         od.%%physloc%% NOT IN (
            SELECT RowID
            FROM DW_Assignment.dbo.DQlog
            WHERE 
                DBName = 'saleAU_NZ' 
                AND TableName = 'orderDetail' 
                AND RuleNo in (2,3,6)
                AND Action = 'reject'
        )
) AS src
ON (
    src.ProductKey = fo.ProductKey
)
WHEN NOT MATCHED THEN
    INSERT (
        ProductKey, CustomerKey, EmployeeKey, PaymentKey,
		OrderDateKey, RequiredDateKey, ShippedDateKey,
        Status,
        OrderNumber,
        QuantityOrdered,
        PriceEach,
        TotalPrice,
        TotalProfit,
        TotalPossibleProfit
    )
    VALUES (
        src.ProductKey, src.CustomerKey, src.EmployeeKey, src.PaymentKey,
        src.OrderDateKey, src.RequiredDateKey, src.ShippedDateKey,
        src.Status,
        src.OrderNumber,
        src.QuantityOrdered,
        src.PriceEach,
        src.TotalPrice,
        src.TotalProfit,
        src.TotalPossibleProfit
    );
-- (371 rows affected)
-----------------------------------------------------------------------------------------
-- Apply Data Quality Rule 2: if priceEach is negative, need to convert to positive number  
UPDATE factOrders
SET priceEach = ABS(priceEach)
WHERE priceEach < 0;
--(0 rows affected)

-- Apply Data Quality Rule 3: Fix if Quantity Ordered is negative, need to convert to positive number  
UPDATE factOrders
SET quantityOrdered = ABS(quantityOrdered)
WHERE quantityOrdered < 0;
--(0 rows affected)
