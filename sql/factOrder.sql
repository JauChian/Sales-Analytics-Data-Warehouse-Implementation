-----------------------------------------------------------
-----------factTable checking 
--Step 1: 
--Fix and Merge: ((orderDate > requiredDate) or requiredDate IS NULL)
--Fix: Set requiredDate = orderDate+7 

--Fix and Merge:((orderDate > shippedDate) or (shippedDate IS NULL and status='Shipped'))
--Fix: Set shippedDate = orderDate+2

MERGE INTO factOrders AS fo
USING (
    SELECT
        dp.ProductKey,
        dc.CustomerKey,
        de.EmployeeKey,
        dpa.PaymentKey,
        dt1.TimeKey AS OrderDateKey,
        -- Conditionally set RequiredDateKey using a CASE statement
        CASE 
            WHEN (po.OrderDate > po.RequiredDate OR po.RequiredDate IS NULL) THEN dt2.TimeKey  -- If OrderDate > RequiredDate or RequiredDate is NULL
            ELSE dt3.TimeKey  -- Use po.RequiredDate otherwise
        END AS RequiredDateKey,
        -- Conditionally set ShippedDateKey using a CASE statement
        CASE
            WHEN (po.OrderDate > po.ShippedDate OR (po.ShippedDate IS NULL AND po.Status = 'Shipped')) THEN dt4.TimeKey  -- If OrderDate > ShippedDate or (ShippedDate is NULL and status='Shipped')
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
        INNER JOIN dimTime dt2 ON dt2.Date = DATEADD(DAY, 7, po.OrderDate)  -- Adding 7 days to OrderDate for RequiredDate 
        INNER JOIN dimTime dt3 ON dt3.Date = po.requiredDate
        INNER JOIN dimTime dt4 ON dt4.Date = DATEADD(DAY, 2, po.OrderDate)  -- Adding 2 days to OrderDate for ShippedDate 
        INNER JOIN dimTime dt5 ON dt5.Date = po.ShippedDate
    WHERE 
        po.%%physloc%% IN (
            SELECT RowID
            FROM DW_Assignment.dbo.DQlog
            WHERE 
                DBName = 'saleAU_NZ' 
                AND TableName = 'productOrder' 
                AND RuleNo = 8
                AND Action = 'fix'
        )
) AS src
ON (
    src.ProductKey = fo.ProductKey
)
WHEN NOT MATCHED THEN
    INSERT (
        ProductKey,
        CustomerKey,
        EmployeeKey,
        PaymentKey,
        OrderDateKey,
        RequiredDateKey,
        ShippedDateKey,
        Status,
        OrderNumber,
        QuantityOrdered,
        PriceEach,
        TotalPrice,
        TotalProfit,
        TotalPossibleProfit
    )
    VALUES (
        src.ProductKey,
        src.CustomerKey,
        src.EmployeeKey,
        src.PaymentKey,
        src.OrderDateKey,
        src.RequiredDateKey,
        src.ShippedDateKey,
        src.Status,
        src.OrderNumber,
        src.QuantityOrdered,
        src.PriceEach,
        src.TotalPrice,
        src.TotalProfit,
        src.TotalPossibleProfit
    );
--(71 rows affected)
-----------------------------------------------------------------------------------------
--Step 2: 
--Merge data not in DQlog
MERGE INTO factOrders AS fo
USING (
    SELECT
        dp.ProductKey,
        dc.CustomerKey,
        de.EmployeeKey,
        dpa.PaymentKey,
        dt1.TimeKey AS OrderDateKey,
        dt2.TimeKey AS RequiredDateKey,
        dt3.TimeKey AS ShippedDateKey,
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
        INNER JOIN dimTime dt2 ON dt2.Date = po.RequiredDate
        INNER JOIN dimTime dt3 ON dt3.Date = po.ShippedDate
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
	AND 
		po.%%physloc%% NOT IN (
            SELECT RowID
            FROM DW_Assignment.dbo.DQlog
            WHERE 
                DBName = 'saleAU_NZ' 
                AND TableName = 'productOrder' 
                AND RuleNo = 8
                AND Action = 'fix'
        )
) AS src
ON (
    src.ProductKey = fo.ProductKey
)
WHEN NOT MATCHED THEN
    INSERT (
        ProductKey,
        CustomerKey,
        EmployeeKey,
        PaymentKey,
        OrderDateKey,
        RequiredDateKey,
        ShippedDateKey,
        Status,
        OrderNumber,
        QuantityOrdered,
        PriceEach,
        TotalPrice,
        TotalProfit,
        TotalPossibleProfit
    )
    VALUES (
        src.ProductKey,
        src.CustomerKey,
        src.EmployeeKey,
        src.PaymentKey,
        src.OrderDateKey,
        src.RequiredDateKey,
        src.ShippedDateKey,
        src.Status,
        src.OrderNumber,
        src.QuantityOrdered,
        src.PriceEach,
        src.TotalPrice,
        src.TotalProfit,
        src.TotalPossibleProfit
    );
--(300 rows affected)
---------------------------------------------------------------------------------------------