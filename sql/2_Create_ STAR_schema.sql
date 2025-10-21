Drop Table dimProducts;
drop table dimEmployee;
drop table dimCustomers;
drop table dimPayment;
CREATE TABLE dimProducts(
                            ProductKey		int			IDENTITY(1,1)	    PRIMARY KEY,
                            ProductCode		nvarchar(15)					NOT NULL,
                            ProductName		nvarchar(70)					NOT NULL,
                            ProductLine 	nvarchar(50)					NOT NULL,
                            QuantityInStock SMALLINT                        NOT NULL,
                            BuyPrice        DECIMAL(10,2)                   NOT NULL,
                            MSRP            decimal(10,2)                   NOT NULL
);

CREATE TABLE dimCustomers(
                             CustomerKey		int			IDENTITY(1,1)		PRIMARY KEY,
                             CustomerNumber     int                             NOT NULL,
                             CustomerName       varchar(50)                     NOT NULL,
                             City               varchar(50)                     NOT NULL,
                             Country            varchar(50)                     NOT NULL,
                             SalesRepEmployeeNumber     int                         DEFAULT NULL,
);

CREATE TABLE dimEmployee(
                            EmployeeKey     INT       IDENTITY(1,1)		PRIMARY KEY,
                            EmployeeNumber  INT                         NOT NULL,
                            EmployeeName        varchar(50)                 NOT NULL,
                            City            varchar(50)                 NOT NULL,
                            Country         varchar(50)                 NOT NULL
);

CREATE TABLE dimPayment(
                            PaymentKey      INT IDENTITY(1,1)		PRIMARY KEY,
                            CustomerNumber  int                     NOT NULL,
                            CheckNumber     varchar(50)             NOT NULL,
                            PaymentDate     date                    NOT NULL,
                            Amount          decimal(10,2)           NOT NULL,

);

Drop Table factOrders;
CREATE TABLE factOrders(
                           ProductKey		    INT			    FOREIGN KEY REFERENCES dimProducts(ProductKey),
                           CustomerKey		    INT			    FOREIGN KEY REFERENCES dimCustomers(CustomerKey),
                           EmployeeKey          INT             FOREIGN KEY REFERENCES dimEmployee(EmployeeKey),
                           PaymentKey           INT             FOREIGN KEY REFERENCES dimPayment(PaymentKey),
                           OrderDateKey	        INT			    FOREIGN KEY REFERENCES dimTime(TimeKey),
                           RequiredDateKey	    INT			    FOREIGN KEY REFERENCES dimTime(TimeKey),
						   ShippedDateKey		INT			    FOREIGN KEY REFERENCES dimTime(TimeKey),
				           Status               varchar(15)     NOT NULL,
				           OrderNumber		    INT	     NOT NULL,
                           QuantityOrdered      INT             NOT NULL,
                           PriceEach            decimal(10,2)   NOT NULL,
                           TotalPrice           money		    NOT NULL,
                           TotalProfit          money		    NOT NULL,
                           TotalPossibleProfit  money		    NOT NULL,
                           PRIMARY KEY(CustomerKey, ProductKey, OrderDateKey, EmployeeKey, PaymentKey)
);

