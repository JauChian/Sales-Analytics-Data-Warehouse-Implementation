SELECT COUNT(*)
FROM saleAU_NZ.dbo.productorder AS po
INNER JOIN saleAU_NZ.dbo.orderdetail  AS od ON od.orderNumber = po.orderNumber
INNER JOIN saleAU_NZ.dbo.product AS p ON p.productCode = od.productCode
INNER JOIN saleAU_NZ.dbo.customer AS c ON c.customerNumber = po.customerNumber
INNER JOIN saleAU_NZ.dbo.payment AS m on m.customerNumber= c.customerNumber
INNER JOIN saleAU_NZ.dbo.employee AS e ON e.employeeNumber = c.salesRepEmployeeNumber
INNER JOIN saleAU_NZ.dbo.office AS o ON o.officeCode = e.officeCode
WHERE  od.orderNumber= po.OrderNumber