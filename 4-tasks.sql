USE HomeWork;

---------------------------------- Level 1: Simple SELECTs & Filtering ----------------------------------

-- 1. List all album titles and corresponding artist IDs.
SELECT Title, ArtistId FROM Album;

-- 2. Get all customers who live in 'Canada'.
SELECT * FROM Customer WHERE Country = 'Canada';

-- 3. Display employees' full names and emails.
SELECT FirstName + ' ' + LastName AS FullName, Email
FROM Employee;

-- 4. Select all invoices where the total is greater than $10.
SELECT *
FROM Invoice
WHERE total > 10;

--------------------------------- Level 2: Joins, Filtering, Aggregation ---------------------------------

-- 5. Display each album title along with the artist's name.
SELECT album.Title, artist.Name
FROM Album album
JOIN Artist artist 
    ON album.ArtistId = artist.ArtistId; 

-- 6. Show a list of customers with the full name of their support rep (employee).
SELECT *, employee.FirstName + ' ' + employee.LastName AS FullName
FROM Customer customer
JOIN Employee employee
    ON customer.SupportRepId = employee.EmployeeId

-- 7. List track name, genre name, and media type using JOIN.
SELECT track.Name, genre.Name, mediaType.Name
FROM Track track
JOIN Genre genre ON 
    track.GenreId = genre.GenreId
JOIN MediaType mediaType ON
    track.MediaTypeId = mediaType.MediaTypeId;
    
-- 8. Count number of customers per country.
SELECT Country, Count(*) AS CountPerCountry
FROM Customer
GROUP BY Country;

-- 9. Group invoices by customer and sum the total.
SELECT CustomerId, SUM (Total) AS TotalSpent
FROM Invoice
GROUP BY CustomerId;

-- 10. Display the 5 longest tracks based on duration.
SELECT TOP (5) *
FROM Track track
ORDER BY track.Milliseconds Desc;

-- 11. List all artists and the number of albums they have.
SELECT artist.Name, Count(album.AlbumId) AS CountOfAlbums
FROM Artist artist
LEFT JOIN Album album ON artist.ArtistId = album.ArtistId
GROUP BY artist.ArtistId, artist.Name
ORDER BY CountOfAlbums Desc;

-- 12. Show cities with more than 1 customer
SELECT customer.City, Count(*) AS CountOfCustomers
FROM Customer customer
GROUP BY customer.City
Having Count(*) > 1;

--------------------------------- Level 3: Subqueries, Unions, Nested SELECTs ----------------------------------

-- 13. Return albums that have more than 5 associated tracks - with join.
SELECT 
    album.Title AS AlbumTitle,
    album.ArtistId,
    album.AlbumId,
    COUNT (track.Name) AS CountOfTracks
FROM Album album
JOIN Track track ON album.AlbumId = track.AlbumId
GROUP BY album.Title, album.AlbumId, album.ArtistId
HAVING COUNT(track.Name)>5
ORDER BY COUNT(track.Name) DESC;

-- 13 - using subqueries and nested selects
SELECT album.Title as AlbumTitle,
       album.ArtistId,
       album.AlbumId,
       ( SELECT COUNT (track.AlbumId)
         FROM Track track
         WHERE track.AlbumId = album.AlbumId
       ) AS CountOfAlbums
FROM Album album
WHERE album.AlbumId IN (SELECT track.AlbumId
                        FROM Track track
                        GROUP BY track.AlbumId
                        HAVING COUNT(track.AlbumId)>5)
ORDER BY CountOfAlbums DESC;

-- 14. Find customers who have made at least 2 purchases
SELECT customer.LastName + ' ' + customer.FirstName AS FullName,
       (SELECT Count(invoice.InvoiceId) 
        FROM Invoice invoice
        WHERE invoice.CustomerId = customer.CustomerId) AS CountOfPurchases
FROM Customer customer
WHERE customer.CustomerId IN ( SELECT invoice.CustomerId 
                               FROM Invoice invoice
                               WHERE invoice.CustomerId = customer.CustomerId
                               GROUP BY invoice.CustomerId
                               HAVING COUNT(invoice.InvoiceId) >= 2)
ORDER BY CountOfPurchases ASC;

-- 15. Return tracks that don’t appear in any playlist.
SELECT track.Name AS TrackName
FROM Track track
WHERE track.TrackId NOT IN ( SELECT playListTrack.TrackId
                             FROM PlaylistTrack playListTrack )

-- 16. Find the most purchased track.
SELECT TOP (1)
    track.TrackId,
    track.Name AS TrackName,
    SUM(invoiceLine.Quantity) AS TotalSold
FROM InvoiceLine AS invoiceLine
JOIN Track AS track ON track.TrackId = invoiceLine.TrackId
GROUP BY track.TrackId, track.Name
ORDER BY TotalSold DESC;

-- 17. Combine customer lists from USA and Canada using UNION.
SELECT *
FROM Customer customer
WHERE customer.Country = 'USA'

UNION

SELECT *
FROM Customer customer
WHERE customer.Country = 'Canada'


-- Level 4: CRUD Operations + Triggers + Stored Procedures/Functions

-- 18. Insert a new customer into the Customer table.
INSERT INTO Customer (FirstName, LastName, Company, Address, City, State, Country, PostalCode, Phone, Fax, Email, SupportRepId)
VALUES ('John', 'Doe', 'JD Solutions', '123 Elm St', 'Springfield', 'IL', 'USA', '62701', '555-1234', '555-5678', 'john.doe@example.com', 1);

-- 19. Update the UnitPrice of a specific track by 20%.
UPDATE Track
SET UnitPrice = UnitPrice * 1.2
WHERE TrackId = 1

-- 20. Create a trigger that logs new customer inserts in 'CustomerLog' table. Fire it and get the result from the log table.
IF OBJECT_ID('dbo.CustomerLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CustomerLog
    (
        LogId         INT IDENTITY(1,1) PRIMARY KEY,
        CustomerId    INT,
        FirstName     VARCHAR(40),
        LastName      VARCHAR(20),
        Email         VARCHAR(60),
        InsertedAt    DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

IF OBJECT_ID('dbo.tr_Customer_Insert_Log', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_Customer_Insert_Log;
GO

CREATE TRIGGER dbo.tr_Customer_Insert_Log
ON dbo.Customer
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.CustomerLog (CustomerId, FirstName, LastName, Email, InsertedAt)
    SELECT  i.CustomerId, i.FirstName, i.LastName, i.Email, SYSUTCDATETIME()
    FROM inserted i;
END
GO

INSERT INTO dbo.Customer (CustomerId, FirstName, LastName, Email)
VALUES (1002, 'Bob', 'Marley', 'bob.marley@example.com');

SELECT * FROM dbo.CustomerLog ORDER BY LogId DESC;
 DROP TRIGGER dbo.tr_Customer_Insert_Log;
GO

-- 21. Create a stored procedure to insert an invoice and invoice lines. Execute the procedure.

IF OBJECT_ID('dbo.InsertInvoiceSimple', 'P') IS NOT NULL
    DROP PROCEDURE dbo.InsertInvoiceSimple;
GO

CREATE PROCEDURE dbo.InsertInvoiceSimple
    @CustomerId INT,
    @TrackId    INT,
    @Quantity   INT,
    @NewInvoiceId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UnitPrice NUMERIC(10,2) = (SELECT UnitPrice FROM dbo.Track WHERE TrackId = @TrackId);

    IF @UnitPrice IS NULL
    BEGIN
        RAISERROR('TrackId not found.', 16, 1);
        RETURN;
    END

    DECLARE @InvoiceId INT  = (SELECT ISNULL(MAX(InvoiceId),0) + 1 FROM dbo.Invoice);
    DECLARE @LineId    INT  = (SELECT ISNULL(MAX(InvoiceLineId),0) + 1 FROM dbo.InvoiceLine);

    DECLARE @Total NUMERIC(10,2) = CAST(@UnitPrice * @Quantity AS NUMERIC(10,2));

    BEGIN TRAN;

        INSERT INTO dbo.Invoice (InvoiceId, CustomerId, InvoiceDate, BillingAddress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total)
        VALUES (@InvoiceId, @CustomerId, CAST(GETDATE() AS DATE), NULL, NULL, NULL, NULL, NULL, @Total);

        INSERT INTO dbo.InvoiceLine (InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity)
        VALUES (@LineId, @InvoiceId, @TrackId, @UnitPrice, @Quantity);

    COMMIT;

    SET @NewInvoiceId = @InvoiceId;
END
GO


DECLARE @id INT;

EXEC dbo.InsertInvoiceSimple
     @CustomerId = 1,    
     @TrackId    = 1,    
     @Quantity   = 2,
     @NewInvoiceId = @id OUTPUT;

SELECT @id AS NewInvoiceId;

SELECT * FROM dbo.Invoice     WHERE InvoiceId = @id;
SELECT * FROM dbo.InvoiceLine WHERE InvoiceId = @id ORDER BY InvoiceLineId;


-- 22. Create a function to return total amount spent by a customer. Call the function in a query to get each customer total spent amount.
IF OBJECT_ID('dbo.TotalSpentByCustomer', 'FN') IS NOT NULL
    DROP FUNCTION dbo.TotalSpentByCustomer;
GO

CREATE FUNCTION dbo.TotalSpentByCustomer (@CustomerId INT)
RETURNS NUMERIC(10,2)
AS
BEGIN
    DECLARE @sum NUMERIC(10,2);
    SELECT @sum = CAST(ISNULL(SUM(Total), 0) AS NUMERIC(10,2))
    FROM dbo.Invoice
    WHERE CustomerId = @CustomerId;

    RETURN @sum;
END
GO

SELECT dbo.TotalSpentByCustomer(1) AS TotalSpent;

SELECT 
    c.CustomerId,
    c.FirstName,
    c.LastName,
    dbo.TotalSpentByCustomer(c.CustomerId) AS TotalSpent
FROM dbo.Customer c
ORDER BY TotalSpent DESC;

