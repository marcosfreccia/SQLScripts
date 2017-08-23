USE master
go

IF EXISTS ( SELECT  name
            FROM    sys.databases
            WHERE   name = 'DropObjects' ) 
    BEGIN
        DROP DATABASE DropObjects
    END

CREATE DATABASE DropObjects
GO
USE DropObjects
GO
CREATE TABLE tblAddress
    (
      AddressID INT IDENTITY
                    PRIMARY KEY ,
      AddressLine VARCHAR(250) ,
      City VARCHAR(50)
    )
GO

CREATE TABLE tblCustomer
    (
      CustomerID INT IDENTITY
                     PRIMARY KEY ,
      FirstName VARCHAR(50) ,
      LastName VARCHAR(50) ,
      AddressId INT
    )
ALTER TABLE tblCustomer  WITH CHECK ADD  CONSTRAINT [FK_Customer_Address_AddressID] FOREIGN KEY(AddressID)
REFERENCES tblAddress (AddressID)
GO

CREATE TABLE tblSalesOrderHeader
    (
      SalesOrderId INT IDENTITY
                       PRIMARY KEY ,
      CustomerID INT ,
      TotalDue MONEY
    )

ALTER TABLE tblSalesOrderHeader  WITH CHECK ADD  CONSTRAINT [FK_Sales_Customer_AddressID] FOREIGN KEY(CustomerID)
REFERENCES tblCustomer (CustomerID)
	

CREATE TABLE tblProduct
    (
      ProductID INT IDENTITY
                    PRIMARY KEY ,
      ProductName VARCHAR(100) ,
      ProductPrice MONEY
    )
	GO
CREATE PROCEDURE spgetTotalSales
AS 
    SELECT  SUM(TotalDue) AS TotalSales
    FROM    tblSalesOrderHeader

GO
CREATE PROCEDURE spGetSalesByCustomer
AS 
    SELECT  FirstName + ' ' + LastName AS CustomerName ,
            SUM(TotalDue) AS TotalDue
    FROM    tblSalesOrderHeader AS OrderHeader
            RIGHT JOIN tblCustomer AS Cust ON OrderHeader.CustomerID = Cust.CustomerID
    GROUP BY FirstName + ' ' + LastName
    ORDER BY TotalDue DESC

GO

CREATE FUNCTION fnGetDate ( )
RETURNS DATETIME
AS 
    BEGIN
        DECLARE @date DATETIME
        SELECT  @date = GETDATE() 
        RETURN @date 
    END

GO

CREATE FUNCTION fnGetSalesByCustomer ( @CustomerID INT )
RETURNS TABLE
AS
RETURN
    ( SELECT    *
      FROM      tblSalesOrderHeader
      WHERE     CustomerID = @CustomerID
    )

GO

CREATE VIEW vwSalesByCustomer
AS
  SELECT  FirstName + ' ' + LastName AS CustomerName ,
            SUM(TotalDue) AS TotalDue
    FROM    tblSalesOrderHeader AS OrderHeader
            RIGHT JOIN tblCustomer AS Cust ON OrderHeader.CustomerID = Cust.CustomerID
    GROUP BY FirstName + ' ' + LastName
GO

INSERT  INTO dbo.tblAddress
        ( AddressLine, City )
VALUES  ( 'Rua São Mateus', 'Porto Alegre' ),
        ( 'Rua Curt Hering', 'Blumenau' ),
        ( 'Rua XV de Novembro', 'Blumenau' )


INSERT  INTO dbo.tblCustomer
        ( FirstName, LastName, AddressId )
VALUES  ( 'Marcos', 'Freccia', 1 ),
        ( 'Sara', 'Barbosa', 1 )

INSERT  INTO dbo.tblSalesOrderHeader
        ( CustomerID, TotalDue )
VALUES  ( 1, 530 ),
        ( 1, 330 ),
        ( 2, 760 ),
        ( 2, 110 )

INSERT  INTO dbo.tblProduct
        ( ProductName, ProductPrice )
VALUES  ( 'Arroz', 1.50 ),
        ( 'Feijão', 2.20 )

EXEC dbo.spGetSalesByCustomer
EXEC dbo.spgetTotalSales

SELECT  *
FROM    dbo.fnGetSalesByCustomer(1)

SELECT  dbo.fnGetDate()