---############################## 314 Match #########################################
--########################### TIER 1 ################################################
USE [Compliance]
GO
DROP TABLE IF EXISTS [dbo].[314_match_tier_1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[314_match_tier_1](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[sbi_name] [nvarchar](max) NOT NULL,
	[sbi_name_alias] [nvarchar](max) NULL,
	[sbi_number] [nvarchar](max) NULL,
	[sbi_country] [nvarchar](max) NULL,
	[314_last_name] [nvarchar](max) NULL,
	[314_first_name] [nvarchar](max) NULL,
	[314_middle_name] [nvarchar](max) NULL,
	[314_suffix] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
DECLARE @cnt INT = 1;
DECLARE @cnt_total INT = (
	select count(*) from [Compliance].[dbo].[Persons 2019-09-04 14555]);
WHILE @cnt <= @cnt_total
BEGIN
INSERT INTO [Compliance].[dbo].[314_match_tier_1]
	SELECT a.Nombre,a.[Nombre Fantasía], CONCAT(a.[Nº Documento]
		,' ',a.[Tipo de documento]),a.[País del documento]
		,b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[clientesFirmantes] a
		,[Compliance].[dbo].[Persons 2019-09-04 14555] b
	WHERE a.Nombre LIKE '%' +
		(SELECT distinct CONCAT(
			'%',LEFT(b.first_name,2),'%'
			,RIGHT(b.first_name,1),'%')
		FROM [Compliance].[dbo].[Persons 2019-09-04 14555] b 
		where b.Id = @cnt) + '%' AND b.Id = @cnt
		OR a.Nombre LIKE '%' +
		(SELECT distinct CONCAT(
			'%',LEFT(b.last_name,2),'%')
		FROM [Compliance].[dbo].[Persons 2019-09-04 14555] b 
		where b.Id = @cnt) + '%' AND b.Id = @cnt
SET @cnt = @cnt + 1;
END;
--########################### TIER 1 CLEANED ########################################
GO
DROP TABLE IF EXISTS [Compliance].[dbo].[314_PERSON_MATCH_FIRST_NAME_DISTINCT]
GO
CREATE TABLE [dbo].[314_PERSON_MATCH_FIRST_NAME_DISTINCT](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[last_name] [nvarchar](max) NOT NULL,
	[first_name] [nvarchar](max) NULL,
	[middle_name] [nvarchar](max) NULL,
	[suffix] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[314_PERSON_MATCH_FIRST_NAME_DISTINCT]
	SELECT distinct [last_name]
	      ,[first_name]
	      ,[middle_name]
	      ,[suffix]
	  FROM [Compliance].[dbo].[314_PERSON_MATCH_FIRST_NAME]
GO
DROP TABLE IF EXISTS [dbo].[314_PERSON_MATCH_FIRST_NAME]
GO
DROP TABLE IF EXISTS [dbo].[314_MATCH_FIRST_NAME_DISTINCT]
GO
CREATE TABLE [dbo].[314_MATCH_FIRST_NAME_DISTINCT](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[sbi_name] [nvarchar](max) NOT NULL,
	[sbi_name_alias] [nvarchar](max) NULL,
	[sbi_number] [nvarchar](max) NULL,
	[sbi_country] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[314_MATCH_FIRST_NAME_DISTINCT]
	SELECT DISTINCT [sbi_name]
      ,[sbi_name_alias]
      ,[sbi_number]
      ,[sbi_country]
	FROM [Compliance].[dbo].[314_MATCH_FIRST_NAME]
GO
DROP TABLE IF EXISTS [dbo].[314_MATCH_FIRST_NAME]
GO
--########################### TIER 2 ################################################
DROP TABLE IF EXISTS [dbo].[314_MATCH_FIRST_LAST_NAME]
GO
CREATE TABLE [dbo].[314_MATCH_FIRST_LAST_NAME](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[sbi_name] [nvarchar](max) NOT NULL,
	[sbi_name_alias] [nvarchar](max) NULL,
	[sbi_number] [nvarchar](max) NULL,
	[sbi_country] [nvarchar](max) NULL,
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
DROP TABLE IF EXISTS [dbo].[314_PERSON_MATCH_FIRST_LAST_NAME]
GO
CREATE TABLE [dbo].[314_PERSON_MATCH_FIRST_LAST_NAME](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[last_name] [nvarchar](max) NOT NULL,
	[first_name] [nvarchar](max) NULL,
	[middle_name] [nvarchar](max) NULL,
	[suffix] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
DECLARE @cnt INT = 1;
DECLARE @cnt_total INT = (
	select count(*) from [Compliance].[dbo].[314_PERSON_MATCH_FIRST_NAME_DISTINCT]);
WHILE @cnt < @cnt_total
BEGIN
INSERT INTO [Compliance].[dbo].[314_MATCH_FIRST_LAST_NAME]
	SELECT a.sbi_name, a.sbi_name_alias,a.sbi_number,a.sbi_country
	FROM [Compliance].[dbo].[314_MATCH_FIRST_NAME_DISTINCT] a
	,[Compliance].[dbo].[314_PERSON_MATCH_FIRST_NAME_DISTINCT] b
	WHERE a.sbi_name LIKE '%' +
		(SELECT distinct CONCAT('%',LEFT(b.first_name,LEN(b.first_name)/2),'%'
			,LEFT(b.last_name,2),'%')
		FROM [Compliance].[dbo].[314_PERSON_MATCH_FIRST_NAME_DISTINCT] b 
		where b.Id = @cnt) + '%' AND b.Id = @cnt
		OR a.sbi_name LIKE '%' +
		(SELECT distinct CONCAT('%',LEFT(b.last_name,LEN(b.last_name)/2),'%'
			,LEFT(b.first_name,LEN(b.first_name)/2),'%')
		FROM [Compliance].[dbo].[314_PERSON_MATCH_FIRST_NAME_DISTINCT] b 
		where b.Id = @cnt) + '%' AND b.Id = @cnt
INSERT INTO [Compliance].[dbo].[314_PERSON_MATCH_FIRST_LAST_NAME]
	SELECT b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[clientesRelaciones] a
	,[Compliance].[dbo].[314_PERSON_MATCH_FIRST_NAME_DISTINCT] b
	WHERE a.Nombre LIKE '%' +
		(SELECT distinct CONCAT(
			'%',LEFT(b.first_name,2),'%'
			,RIGHT(b.first_name,1),'%')
		FROM [Compliance].[dbo].[314_PERSON_MATCH_FIRST_NAME_DISTINCT] b 
		where b.Id = @cnt) + '%' AND b.Id = @cnt
		OR a.Nombre LIKE '%' +
		(SELECT distinct CONCAT(
			'%',LEFT(b.last_name,2),'%')
		FROM [Compliance].[dbo].[314_PERSON_MATCH_FIRST_NAME_DISTINCT] b 
		where b.Id = @cnt) + '%' AND b.Id = @cnt
SET @cnt = @cnt + 1;
END;
--########################### TIER 2 CLEANED ########################################
GO
DROP TABLE IF EXISTS [dbo].[314_MATCH_FIRST_LAST_NAME_DISTINCT]
GO
CREATE TABLE [dbo].[314_MATCH_FIRST_LAST_NAME_DISTINCT](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[sbi_name] [nvarchar](max) NOT NULL,
	[sbi_name_alias] [nvarchar](max) NULL,
	[sbi_number] [nvarchar](max) NULL,
	[sbi_country] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[314_MATCH_FIRST_LAST_NAME_DISTINCT]
	SELECT  distinct [sbi_name]
      ,[sbi_name_alias]
      ,[sbi_number]
      ,[sbi_country]
	FROM [Compliance].[dbo].[314_MATCH_FIRST_LAST_NAME]
GO
DROP TABLE IF EXISTS [dbo].[314_MATCH_FIRST_LAST_NAME]
GO
DROP TABLE IF EXISTS [Compliance].[dbo].[314_PERSON_MATCH_FIRST_LAST_NAME_DISTINCT]
GO
CREATE TABLE [dbo].[314_PERSON_MATCH_FIRST_LAST_NAME_DISTINCT](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[last_name] [nvarchar](max) NOT NULL,
	[first_name] [nvarchar](max) NULL,
	[middle_name] [nvarchar](max) NULL,
	[suffix] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[314_PERSON_MATCH_FIRST_LAST_NAME_DISTINCT]
	SELECT distinct [last_name]
	      ,[first_name]
	      ,[middle_name]
	      ,[suffix]
	  FROM [Compliance].[dbo].[314_PERSON_MATCH_FIRST_LAST_NAME]
GO
DROP TABLE IF EXISTS [dbo].[314_PERSON_MATCH_FIRST_LAST_NAME]
GO
--########################### TIER 3 ################################################
DROP TABLE IF EXISTS [dbo].[314_MATCH_DISCARD]
GO
CREATE TABLE [dbo].[314_MATCH_DISCARD](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[sbi_name] [nvarchar](max) NOT NULL,
	[sbi_name_alias] [nvarchar](max) NULL,
	[sbi_number] [nvarchar](max) NULL,
	[sbi_country] [nvarchar](max) NULL,
	[314a_match_person] [nvarchar](max) NULL,
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
DECLARE @cnt INT = 1;
DECLARE @cnt_total INT = (
	select count(*) from [Compliance].[dbo].[314_PERSON_MATCH_FIRST_LAST_NAME_DISTINCT]);
WHILE @cnt < @cnt_total
BEGIN
INSERT INTO [Compliance].[dbo].[314_MATCH_DISCARD]
	SELECT a.sbi_name, a.sbi_name_alias,a.sbi_number,a.sbi_country
		,CONCAT(b.first_name,' ',b.last_name,' '
			,b.middle_name,' ',b.suffix) AS '314a_Matched_Person'
	FROM [Compliance].[dbo].[314_MATCH_FIRST_LAST_NAME_DISTINCT] a
	,[Compliance].[dbo].[314_PERSON_MATCH_FIRST_LAST_NAME_DISTINCT] b
	WHERE a.sbi_name LIKE '%' +
		(SELECT distinct CONCAT('%'
			,substring(b.first_name,((len(b.first_name)/2)/2)+1,((len(b.first_name)/2)/1.5)+1)
			,'%'
			--,LEFT(b.last_name,2)
			,substring(b.last_name,((len(b.last_name)/2)/2)+1,((len(b.last_name)/2)/1.5)+1)
			,'%')
		FROM [Compliance].[dbo].[314_PERSON_MATCH_FIRST_LAST_NAME_DISTINCT] b 
		where b.Id = @cnt) + '%' AND b.Id = @cnt
		OR a.sbi_name LIKE '%' +
		(SELECT distinct CONCAT('%'
			,substring(b.last_name,((len(b.last_name)/2)/2)+1,((len(b.last_name)/2)/1.5)+1)
			,'%'
			--,LEFT(b.first_name,LEN(b.first_name)/2)
			,substring(b.first_name,((len(b.first_name)/2)/2)+1,((len(b.first_name)/2)/1.5)+1)
			,'%')
		FROM [Compliance].[dbo].[314_PERSON_MATCH_FIRST_LAST_NAME_DISTINCT] b 
		where b.Id = @cnt) + '%' AND b.Id = @cnt
SET @cnt = @cnt + 1;
END;
--########################### TIER 3 CLEANED ########################################
GO
DROP TABLE IF EXISTS [dbo].[314_MATCH_DISCARD_DISTINCT]
GO
CREATE TABLE [dbo].[314_MATCH_DISCARD_DISTINCT](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[sbi_name] [nvarchar](max) NOT NULL,
	[sbi_name_alias] [nvarchar](max) NULL,
	[sbi_number] [nvarchar](max) NULL,
	[sbi_country] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[314_MATCH_DISCARD_DISTINCT]
	SELECT  distinct [sbi_name]
      ,[sbi_name_alias]
      ,[sbi_number]
      ,[sbi_country]
	FROM [Compliance].[dbo].[314_MATCH_DISCARD]
GO
DROP TABLE IF EXISTS [dbo].[314_MATCH_DISCARD]
GO
----################################ BUSINESS #######################################
USE [Compliance]
GO
DROP TABLE IF EXISTS [dbo].[314_MATCH_BUSINESS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[314_MATCH_BUSINESS](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[sbi_Nombre] [nvarchar](max) NULL,
    [sbi_Pais_Reside_Cli] [nvarchar](max) NULL,
    [sbi_Observaciones_1] [nvarchar](max) NULL,
    [sbi_Nombre_1] [nvarchar](max) NULL,
    [sbi_Nombre_2] [nvarchar](max) NULL,
    [sbi_Banco_Rec] [nvarchar](max) NULL,
    [sbi_Nombre_3] [nvarchar](max) NULL,
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
DECLARE @cnt INT = 1;
DECLARE @cnt_total INT = (
	select count(*) from [Compliance].[dbo].[Businesses 2019-09-04 14555]);
WHILE @cnt <= @cnt_total
BEGIN
INSERT INTO [Compliance].[dbo].[314_MATCH_BUSINESS]
	SELECT a.Nombre,a.[Pais_Reside_Cli],a.Observaciones_1,a.Nombre_1,a.Nombre_2
		,a.Banco_Rec,a.Nombre_3
		
	FROM [Compliance].[dbo].[transactionsFrom2018ToPresent] a
	,[Compliance].[dbo].[Businesses 2019-09-04 14555] b
	WHERE a.Nombre LIKE '%' +
		(SELECT CONCAT(
			'%',LEFT(b.business_name,2),'%'
			,RIGHT(b.business_name,1),'%') AS 'matchedString'
		FROM [Compliance].[dbo].[Businesses 2019-09-04 14555] b 
		where b.Id = @cnt) + '%' AND b.Id = @cnt
	SET @cnt = @cnt + 1;
END;
GO
USE [Compliance]
GO
DROP TABLE IF EXISTS [dbo].[314_MATCH_BUSINESS_DISC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[314_MATCH_BUSINESS_DISC](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[sbi_business_name] [nvarchar](max) NOT NULL,
	[sbi_Obs_1] [nvarchar](max) NULL,
	[sbi_Obs_2] [nvarchar](max) NULL,
	[sbi_Obs_3] [nvarchar](max) NULL,
	[sbi_Obs_4] [nvarchar](max) NULL,
	[sbi_Obs_5] [nvarchar](max) NULL,
	[sbi_Obs_6] [nvarchar](max) NULL,
	[314a_business_name] [nvarchar](max) NULL,
    [314a_dba_name] [nvarchar](max) NULL,
    [314a_number] [nvarchar](max) NULL,
    [314a_number_type] [nvarchar](max) NULL,
    [314a_street] [nvarchar](max) NULL,
    [314a_city] [nvarchar](max) NULL,
    [314a_state] [nvarchar](max) NULL,
    [314a_zip] [nvarchar](max) NULL,
    [314a_country] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
DECLARE @cnt INT = 1;
DECLARE @cnt_total INT = (
	select count(*) from [Compliance].[dbo].[Businesses 2019-09-04 14555]);
WHILE @cnt < @cnt_total
BEGIN
--INSERT INTO [Compliance].[dbo].[314_MATCH_BUSINESS_DISC]
	SELECT a.sbi_Nombre,a.sbi_Pais_Reside_Cli,a.sbi_Observaciones_1,
		   a.sbi_Nombre_1,a.sbi_Nombre_2,a.sbi_Banco_Rec,a.sbi_Nombre_3,
		   b.business_name,b.dba_name,b.number,b.number_type,b.street,
		   b.city,b.state,b.zip,b.country
	FROM [Compliance].[dbo].[314_MATCH_BUSINESS] a
	,[Compliance].[dbo].[Businesses 2019-09-04 14555] b
	WHERE a.sbi_Nombre LIKE '%' +
		(SELECT CONCAT('%',RIGHT(b.business_name,4),'%') AS 'matchedString'
		FROM [Compliance].[dbo].[Businesses 2019-09-04 14555] b 
		where b.Id = @cnt) + '%' AND b.Id = @cnt
	SET @cnt = @cnt + 1;
END;



---################################ 314 Match #######################################


SELECT distinct CONCAT('%',LEFT(b.first_name,len(b.first_name)/2),'%'
			,LEFT(b.last_name,len(b.last_name)/2),'%')
		FROM [Compliance].[dbo].[Persons 2019-09-04 14555] b
select distinct 
	b.first_name
	,LEFT(b.first_name,len(b.first_name)/1.5) as fromstart
	,len(b.first_name) as total
	,len(b.first_name)/2 as half
	,(len(b.first_name)/2)/2 as halfofhalf
	,((len(b.first_name)/2)/2)+1 as halfofhalfplus1
	,(len(b.first_name)/2)-1 as halfminus1
	,substring(b.first_name,((len(b.first_name)/2)/2)+1,((len(b.first_name)/2)/1.5)+1)
FROM [Compliance].[dbo].[Persons 2019-09-04 14555] b
select distinct 
	b.first_name
	,substring(b.last_name,((len(b.last_name)/2)/2)+1,((len(b.last_name)/2)/1.5)+1)
FROM [Compliance].[dbo].[Persons 2019-09-04 14555] b



select distinct len(b.first_name) FROM [Compliance].[dbo].[Persons 2019-09-04 14555] b





USE [Compliance]
GO
DROP TABLE IF EXISTS [dbo].[314_MATCH_BUSINESS_DISC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[314_MATCH_BUSINESS_DISC](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[sbi_business_name] [nvarchar](max) NOT NULL,
	[314a_business_name] [nvarchar](max) NULL,
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
GO
DECLARE @cnt INT = 1;
DECLARE @cnt_total INT = (
	select count(*) from [Compliance].[dbo].[Businesses 2019-09-04 14555]);
WHILE @cnt < @cnt_total
BEGIN
INSERT INTO [Compliance].[dbo].[314_MATCH_BUSINESS_DISC]
	SELECT a.Nombre, b.business_name as '314a_match'
	FROM [Compliance].[dbo].[clientesRelaciones] a
	,[Compliance].[dbo].[Businesses 2019-09-04 14555] b
	WHERE a.Nombre LIKE
		(SELECT distinct CONCAT('%'
			,substring(b.business_name,((len(b.business_name)/2)/2)+1,((len(b.business_name)/2)/1.5)+1)
			,'%')
		FROM [Compliance].[dbo].[Businesses 2019-09-04 14555] b 
		where b.Id = @cnt) + '%' AND b.Id = @cnt
SET @cnt = @cnt + 1;
END;


--########################### TIER 2 OLD ############################################
--DROP TABLE IF EXISTS [dbo].[314_MATCH_FIRST_LAST_NAME]
--GO
--CREATE TABLE [dbo].[314_MATCH_FIRST_LAST_NAME](
--	[Id] [int] IDENTITY(1,1) NOT NULL,
--	[sbi_name] [nvarchar](max) NOT NULL,
--	[sbi_name_alias] [nvarchar](max) NULL,
--	[sbi_number] [nvarchar](max) NULL,
--	[sbi_country] [nvarchar](max) NULL,
--	[314a_match_person] [nvarchar](max) NULL,
--	[314a_match_person_alias] [nvarchar](max) NULL,
--	[314a_dob] [nvarchar](max) NULL,
--	[314a_number] [nvarchar](max) NULL,
--	[314a_country] [nvarchar](max) NULL
--) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
--GO
--DECLARE @cnt INT = 1;
--DECLARE @cnt_total INT = (
--	select count(*) from [Compliance].[dbo].[Persons 2019-09-04 14555]);
--WHILE @cnt < @cnt_total
--BEGIN
--INSERT INTO [Compliance].[dbo].[314_MATCH_FIRST_LAST_NAME]
--	SELECT a.sbi_name, a.sbi_name_alias,a.sbi_number,a.sbi_country
--	,CONCAT(b.first_name,' ',b.last_name,' '
--		,b.middle_name,' ',b.suffix) AS '314a_Matched_Person'
--	,CONCAT(b.alias_first_name,' ',b.alias_last_name,' '
--		,b.alias_middle_name,' ',b.alias_suffix) AS '314a_Matched_Person_Alias'
--	,b.dob
--	,CONCAT(b.number,' ',b.number_type) AS '314a_Number'
--	,b.country
--	FROM [Compliance].[dbo].[314_MATCH_FIRST_NAME_DISTINCT] a
--	,[Compliance].[dbo].[Persons 2019-09-04 14555] b
--	WHERE a.sbi_name LIKE '%' +
--		(SELECT CONCAT('%',LEFT(b.first_name,2),'%',RIGHT(b.first_name,1),'%'
--			,LEFT(b.last_name,2),'%')
--		FROM [Compliance].[dbo].[Persons 2019-09-04 14555] b 
--		where b.Id = @cnt) + '%' AND b.Id = @cnt
--		OR a.sbi_name LIKE '%' +
--		(SELECT CONCAT('%',LEFT(b.last_name,2),'%'
--			,LEFT(b.first_name,2),'%',RIGHT(b.first_name,1),'%')
--		FROM [Compliance].[dbo].[Persons 2019-09-04 14555] b 
--		where b.Id = @cnt) + '%' AND b.Id = @cnt
--	SET @cnt = @cnt + 1;
--END;