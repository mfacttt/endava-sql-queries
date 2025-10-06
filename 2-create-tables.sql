-------------------------------------------------------------  Create tables --------------------------------------------------------- 

USE HomeWork;

CREATE TABLE [Artist] (
    [ArtistId] INT NOT NULL,
    [Name] VARCHAR(120),
    CONSTRAINT [PK_Artist] PRIMARY KEY ([ArtistId])
);

CREATE TABLE [Album] (
    [AlbumId] INT NOT NULL,
    [Title] VARCHAR(160) NOT NULL,
    [ArtistId] INT NOT NULL,
    CONSTRAINT [PK_Album] PRIMARY KEY ([AlbumId]),
    CONSTRAINT [FK_Album_Artist] FOREIGN KEY ([ArtistId]) REFERENCES [Artist]([ArtistId])
);

CREATE TABLE [Employee] (
    [EmployeeId] INT NOT NULL,
    [LastName] VARCHAR(20) NOT NULL,
    [FirstName] VARCHAR(20) NOT NULL,
    [Title] VARCHAR(30),
    [ReportsTo] INT,
    [BirthDate] DATE,
    [HireDate] DATE,
    [Address] VARCHAR(70),
    [City] VARCHAR(40),
    [State] VARCHAR(40),
    [Country] VARCHAR(40),
    [PostalCode] VARCHAR(10),
    [Phone] VARCHAR(24),
    [Fax] VARCHAR(24),
    [Email] VARCHAR(60),
    CONSTRAINT [PK_Employee] PRIMARY KEY ([EmployeeId]),
    CONSTRAINT [FK_Employee_ReportsTo] FOREIGN KEY ([ReportsTo]) REFERENCES [Employee]([EmployeeId])
);

CREATE TABLE [Customer] (
    [CustomerId] INT NOT NULL,
    [FirstName] VARCHAR(40) NOT NULL,
    [LastName] VARCHAR(20) NOT NULL,
    [Company] VARCHAR(80),
    [Address] VARCHAR(70),
    [City] VARCHAR(40),
    [State] VARCHAR(40),
    [Country] VARCHAR(40),
    [PostalCode] VARCHAR(10),
    [Phone] VARCHAR(24),
    [Fax] VARCHAR(24),
    [Email] VARCHAR(60) NOT NULL,
    [SupportRepId] INT,
    CONSTRAINT [PK_Customer] PRIMARY KEY ([CustomerId]),
    CONSTRAINT [FK_Customer_Employee] FOREIGN KEY ([SupportRepId]) REFERENCES [Employee]([EmployeeId])
);

CREATE TABLE [Genre] (
    [GenreId] INT NOT NULL,
    [Name] VARCHAR(120),
    CONSTRAINT [PK_Genre] PRIMARY KEY ([GenreId])
);

CREATE TABLE [MediaType] (
    [MediaTypeId] INT NOT NULL,
    [Name] VARCHAR(120),
    CONSTRAINT [PK_MediaType] PRIMARY KEY ([MediaTypeId])
);

CREATE TABLE [Track] (
    [TrackId] INT NOT NULL,
    [Name] VARCHAR(200) NOT NULL,
    [AlbumId] INT,
    [MediaTypeId] INT NOT NULL,
    [GenreId] INT,
    [Composer] VARCHAR(220),
    [Milliseconds] INT NOT NULL,
    [Bytes] INT,
    [UnitPrice] NUMERIC(10,2) NOT NULL,
    CONSTRAINT [PK_Track] PRIMARY KEY ([TrackId]),
    CONSTRAINT [FK_Track_Album] FOREIGN KEY ([AlbumId]) REFERENCES [Album]([AlbumId]),
    CONSTRAINT [FK_Track_MediaType] FOREIGN KEY ([MediaTypeId]) REFERENCES [MediaType]([MediaTypeId]),
    CONSTRAINT [FK_Track_Genre] FOREIGN KEY ([GenreId]) REFERENCES [Genre]([GenreId])
);

CREATE TABLE [Invoice] (
    [InvoiceId] INT NOT NULL,
    [CustomerId] INT NOT NULL,
    [InvoiceDate] DATE NOT NULL,
    [BillingAddress] VARCHAR(70),
    [BillingCity] VARCHAR(40),
    [BillingState] VARCHAR(40),
    [BillingCountry] VARCHAR(40),
    [BillingPostalCode] VARCHAR(10),
    [Total] NUMERIC(10,2) NOT NULL,
    CONSTRAINT [PK_Invoice] PRIMARY KEY ([InvoiceId]),
    CONSTRAINT [FK_Invoice_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [Customer]([CustomerId])
);

CREATE TABLE [InvoiceLine] (
    [InvoiceLineId] INT NOT NULL,
    [InvoiceId] INT NOT NULL,
    [TrackId] INT NOT NULL,
    [UnitPrice] NUMERIC(10,2) NOT NULL,
    [Quantity] INT NOT NULL,
    CONSTRAINT [PK_InvoiceLine] PRIMARY KEY ([InvoiceLineId]),
    CONSTRAINT [FK_InvoiceLine_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [Invoice]([InvoiceId]),
    CONSTRAINT [FK_InvoiceLine_Track] FOREIGN KEY ([TrackId]) REFERENCES [Track]([TrackId])
);

CREATE TABLE [Playlist] (
    [PlaylistId] INT NOT NULL,
    [Name] VARCHAR(120),
    CONSTRAINT [PK_Playlist] PRIMARY KEY ([PlaylistId])
);

CREATE TABLE [PlaylistTrack] (
    [PlaylistId] INT NOT NULL,
    [TrackId] INT NOT NULL,
    CONSTRAINT [PK_PlaylistTrack] PRIMARY KEY ([PlaylistId], [TrackId]),
    CONSTRAINT [FK_PlaylistTrack_Playlist] FOREIGN KEY ([PlaylistId]) REFERENCES [Playlist]([PlaylistId]),
    CONSTRAINT [FK_PlaylistTrack_Track] FOREIGN KEY ([TrackId]) REFERENCES [Track]([TrackId])
);