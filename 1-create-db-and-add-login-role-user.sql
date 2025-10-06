--------------------------------------------------------- Drop if exists and create database --------------------------------------------------------- 

USE master;

IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'HomeWork')
    BEGIN
        ALTER DATABASE HomeWork SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE HomeWork;
    END

CREATE DATABASE HomeWork;

-------------------------------------------------------------  Create role, login and user.   --------------------------------------------------------- 

IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = N'developer-Alex')
BEGIN
    CREATE LOGIN [developer-Alex] WITH PASSWORD = N'Ruscald12345.';
END

USE HomeWork;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'developer')
BEGIN
    CREATE ROLE [developer];
    GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO [developer];
    GRANT EXECUTE ON SCHEMA::dbo TO [developer];
    GRANT CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE FUNCTION TO [developer];
END

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'user-developer-Alex')
BEGIN
    CREATE USER [user-developer-Alex] FOR LOGIN [developer-Alex] WITH DEFAULT_SCHEMA = [dbo];
END

ALTER ROLE [developer] ADD MEMBER [user-developer-Alex];

SELECT name AS Roles FROM sys.database_principals WHERE name = 'developer';
SELECT name AS Logins FROM sys.sql_logins WHERE name = 'developer-Alex'
SELECT name AS Users FROM sys.database_principals WHERE name = 'user-developer-Alex'