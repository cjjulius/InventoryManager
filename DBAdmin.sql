USE [master]
GO

/****** Object:  Database [DBAdmin]    Script Date: 11/14/2016 5:21:25 PM ******/
CREATE DATABASE [DBAdmin]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DBAdmin', FILENAME = N'D:\Data\DBAdmin\DBAdmin.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'DBAdmin_log', FILENAME = N'L:\Logs\DBAdmin\DBAdmin_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO

ALTER DATABASE [DBAdmin] SET COMPATIBILITY_LEVEL = 110
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DBAdmin].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [DBAdmin] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [DBAdmin] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [DBAdmin] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [DBAdmin] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [DBAdmin] SET ARITHABORT OFF 
GO

ALTER DATABASE [DBAdmin] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [DBAdmin] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [DBAdmin] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [DBAdmin] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [DBAdmin] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [DBAdmin] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [DBAdmin] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [DBAdmin] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [DBAdmin] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [DBAdmin] SET  DISABLE_BROKER 
GO

ALTER DATABASE [DBAdmin] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [DBAdmin] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [DBAdmin] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [DBAdmin] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [DBAdmin] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [DBAdmin] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [DBAdmin] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [DBAdmin] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [DBAdmin] SET  MULTI_USER 
GO

ALTER DATABASE [DBAdmin] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [DBAdmin] SET DB_CHAINING OFF 
GO

ALTER DATABASE [DBAdmin] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [DBAdmin] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO

ALTER DATABASE [DBAdmin] SET  READ_WRITE 
GO


