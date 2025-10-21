-- 1.Monthly sales and profit/loss report for each product line. For each product line, display its name,
-- the number of products in that category, the total number of sales of all the products in that category,
-- and the total profits/loss generated so far. Rank the line based on the total profits/loss generated in
-- descending order.

SELECT
    dp.ProductLine,
    COUNT(DISTINCT fo.ProductKey) AS total_products,
    SUM(fo.TotalPrice) AS total_sales,
    SUM(fo.TotalProfit) AS total_profit_loss,
    dT.DayOfMonth, dT.Year

FROM
    dimProducts dp
        JOIN factOrders fo ON dp.ProductKey = fo.ProductKey
        join dimTime dT on dT.TimeKey = fo.OrderDateKey
GROUP BY
    dp.ProductLine, dT.DayOfMonth, dT.Year
ORDER BY
    dT.Year, dT.DayOfMonth, total_profit_loss DESC;


-- 2.Monthly report on the most profitable employees. For each employee, display its name, city, country,
-- the total number of customers he/she supported, the total number of payments from his/her customers processed.
-- Rank the employees based on the number of profits generated in descending order.

SELECT
        de.EmployeeName,
        de.city,
        de.country,
        COUNT(DISTINCT fo.CustomerKey) AS total_customers_supported,
        COUNT(fo.PaymentKey) AS total_payments_processed,
        dT.DayOfMonth, dT.Year
FROM
    dimEmployee de
        JOIN factOrders fo ON de.EmployeeKey = fo.EmployeeKey
        join dimTime dT on dT.TimeKey = fo.OrderDateKey
GROUP BY
    de.EmployeeName,
    de.city,
    de.country, dT.DayOfMonth, dT.Year
ORDER BY
    dT.Year, dT.DayOfMonth, total_payments_processed DESC;


-- 3.Summary report on the total sales based on City. For each city, display its name, country,
-- the total number of products sold, the total number of product category sold, the total number
-- of customers who live there and the total sales of product sold. Rank the city based on the total
-- sales of products sold.


SELECT
    dc.city,
    dc.country,
    COUNT(DISTINCT fo.ProductKey) AS total_products_sold,
    COUNT(DISTINCT fo.CustomerKey) AS total_customers,
    SUM(fo.TotalPrice) AS total_sales
FROM
    dimCustomers dc
        JOIN factOrders fo ON dc.CustomerKey = fo.CustomerKey
GROUP BY
    dc.city,
    dc.country
ORDER BY
    total_sales DESC;


-- 4.Monthly report on the customers who have bought the most. For each customer, display the customer’s name,
-- the total number of products bought, the total number of product categories bought, the total sales of products
-- bought and the total profits/loss generated so far. Rank the customer based on the total profits/loss generated
-- in descending order.

SELECT
    dc.customerName AS customer_name,
    COUNT(DISTINCT fo.ProductKey) AS total_products_bought,
    COUNT(DISTINCT fo.ProductKey) AS total_product_categories_bought,
    SUM(fo.TotalPrice) AS total_sales,
    SUM(fo.TotalProfit) AS total_profit_loss,
    dT.DayOfMonth, dT.Year
FROM
    dimCustomers dc
        JOIN factOrders fo ON dc.CustomerKey = fo.CustomerKey
        join dimTime dT on dT.TimeKey = fo.OrderDateKey
GROUP BY
    dc.customerName, dT.DayOfMonth, dT.Year
ORDER BY
    dT.Year, dT.DayOfMonth, total_profit_loss DESC;



-- 5.Monthly sales report that list and comparer of Total-Profit with Total-Possible-Profit for each product line.
-- For each product line, display its name, the total number of sales of all the products in that category,
-- and the total profits, total possible profit and different between last two parameters. Rank the line based
-- on the total profits generated in descending order.

SELECT
    dp.ProductLine,
    SUM(fo.TotalPrice) AS total_sales,
    SUM(fo.TotalProfit) AS total_profit,
    SUM(fo.TotalPossibleProfit) AS total_possible_profit,
    SUM(fo.TotalProfit) - SUM(fo.TotalPossibleProfit) AS difference,
    dT.DayOfMonth, dT.Year
FROM
    dimProducts dp
        JOIN factOrders fo ON dp.ProductKey = fo.ProductKey
        join dimTime dT on dT.TimeKey = fo.OrderDateKey
GROUP BY
    dp.ProductLine, dT.DayOfMonth, dT.Year
ORDER BY
    dT.Year, dT.DayOfMonth, total_profit DESC;
