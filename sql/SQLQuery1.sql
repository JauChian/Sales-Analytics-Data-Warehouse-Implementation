MERGE INTO dimProducts AS dp
USING
(
    SELECT 
    p.productCode, 
    p.ProductName,
    p.ProductLine,
    p.quantityInStock,
    p.buyPrice,
    p.MSRP

    FROM saleAU_NZ.dbo.product AS p
    INNER JOIN 
    saleAU_NZ.dbo.productLine AS pl ON pl.productLine =p.productLine
    WHERE 
    p.%%physloc%% NOT IN(
        SELECT ROWID
        FROM DQLOG
        WHERE 
        DBName = 'saleAU_NZ'
        AND TableName = 'product'
        AND RuleNo IN(1,4) 
        AND Action = 'Reject')
) AS p ON (dp.productCode = p.productCode)
WHEN MATCHED THEN --if employeenumber matched, do notih
            UPDATE SET
            dp.productCode = p.productCode
WHEN NOT MATCHED THEN
    INSERT
    (productCode,productName,productLine,
        quantityInStock,buyPrice,MSRP)
    VALUES
    (p.productCode,p.ProductName,p.productLine,
        p.quantityInStock,p.buyPrice,p.MSRP);