---############################## 314 Match #########################################
--########################### TIER 1 ################################################
USE [Compliance]
GO
DROP TABLE IF EXISTS [dbo].[314a_14845_Match_Tier1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[314a_14845_Match_Tier1](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[sbi_name] [nvarchar](max) NOT NULL,
	[sbi_name_alias] [nvarchar](max) NULL,
	[sbi_number] [nvarchar](max) NULL,
	[sbi_country] [nvarchar](max) NULL,
	[last_name] [nvarchar](max) NOT NULL,
	[first_name] [nvarchar](max) NULL,
	[middle_name] [nvarchar](max) NULL,
	[suffix] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
DECLARE @cnt INT = 1;
DECLARE @cnt_total INT = (
	select count(*) from [Compliance].[dbo].[314a-Persons-14845]);
WHILE @cnt <= @cnt_total
BEGIN
	--############### INSERT FROM CLIENTESFIRMANTEStable ###############
INSERT INTO [Compliance].[dbo].[314a_14845_Match_Tier1]
	SELECT a.Nombre,a.[Nombre Fantasía], CONCAT(a.[Nº Documento]
		,' ',a.[Tipo de documento]),a.[País del documento],
		b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[clientesFirmantes] a
	,[Compliance].[dbo].[314a-Persons-14845] b
	WHERE a.Nombre LIKE
		(SELECT distinct concat(
			'%',
			substring(b.first_name,2,CEILING((LEN(b.first_name)/1.5)/1.5)),
			'%')
		FROM [Compliance].[dbo].[314a-Persons-14845] b 
		where b.id = @cnt) AND b.id = @cnt
		OR a.Nombre LIKE
		(SELECT distinct concat(
			'%',
			substring(b.last_name,2,CEILING((LEN(b.last_name)/1.5)/1.5)),
			'%')
		FROM [Compliance].[dbo].[314a-Persons-14845] b 
		where b.id = @cnt) AND b.id = @cnt
		OR a.Nombre LIKE
		(SELECT distinct concat(
			'%',
			substring(b.middle_name,2,CEILING((LEN(b.middle_name)/1.5)/1.5)),
			'%')
		FROM [Compliance].[dbo].[314a-Persons-14845] b 
		where b.id = @cnt) AND b.id = @cnt
	--############### INSERT FROM TRANSACTIONS table ###############
INSERT INTO [Compliance].[dbo].[314a_14845_Match_Tier1]
	SELECT a.Nombre,'','',''
		,b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[TRNCONSULTA-2019-05-09names] a
		,[Compliance].[dbo].[314a-Persons-14845] b
	WHERE a.Nombre LIKE
		(SELECT distinct concat(
			'%',
			substring(b.first_name,2,CEILING((LEN(b.first_name)/1.5)/1.5)),
			'%')
		FROM [Compliance].[dbo].[314a-Persons-14845] b 
		where b.id = @cnt) AND b.id = @cnt
		OR a.Nombre LIKE
		(SELECT distinct concat(
			'%',
			substring(b.last_name,2,CEILING((LEN(b.last_name)/1.5)/1.5)),
			'%')
		FROM [Compliance].[dbo].[314a-Persons-14845] b 
		where b.id = @cnt) AND b.id = @cnt
		OR a.Nombre LIKE
		(SELECT distinct concat(
			'%',
			substring(b.middle_name,2,CEILING((LEN(b.middle_name)/1.5)/1.5)),
			'%')
		FROM [Compliance].[dbo].[314a-Persons-14845] b 
		where b.id = @cnt) AND b.id = @cnt
		--############### INSERT FROM TRNCONSULTA ###############
SET @cnt = @cnt + 1;
END;
--########################### TIER 1 CLEANED ########################################
GO
DROP TABLE IF EXISTS [Compliance].[dbo].[314a_14845_MatchPerson_Tier1]
GO
CREATE TABLE [dbo].[314a_14845_MatchPerson_Tier1](
	[last_name] [nvarchar](max) NOT NULL,
	[first_name] [nvarchar](max) NULL,
	[middle_name] [nvarchar](max) NULL,
	[suffix] [nvarchar](max) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[314a_14845_MatchPerson_Tier1]
	SELECT distinct [last_name]
	      ,[first_name]
	      ,[middle_name]
	      ,[suffix]
	  FROM [Compliance].[dbo].[314a_14845_Match_Tier1]
GO
DROP TABLE IF EXISTS [dbo].[314a_14845_sbiMatch_Tier1]
GO
CREATE TABLE [dbo].[314a_14845_sbiMatch_Tier1](
	[sbi_name] [nvarchar](max) NOT NULL,
	[sbi_name_alias] [nvarchar](max) NULL,
	[sbi_number] [nvarchar](max) NULL,
	[sbi_country] [nvarchar](max) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[314a_14845_sbiMatch_Tier1]
	SELECT DISTINCT [sbi_name]
      ,[sbi_name_alias]
      ,[sbi_number]
      ,[sbi_country]
	FROM [Compliance].[dbo].[314a_14845_Match_Tier1]
GO
--########################### TIER 2 ################################################
DROP TABLE IF EXISTS [dbo].[314a_14845_Match_Tier2]
GO
CREATE TABLE [dbo].[314a_14845_Match_Tier2](
	[sbi_name] [nvarchar](max) NOT NULL,
	[sbi_name_alias] [nvarchar](max) NULL,
	[sbi_number] [nvarchar](max) NULL,
	[sbi_country] [nvarchar](max) NULL,
	[last_name] [nvarchar](max) NOT NULL,
	[first_name] [nvarchar](max) NULL,
	[middle_name] [nvarchar](max) NULL,
	[suffix] [nvarchar](max) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
DECLARE @cnt INT = 1;
DECLARE @cnt_total INT = (
	select count(*) from [Compliance].[dbo].[314a_14845_MatchPerson_Tier1]);
WHILE @cnt < @cnt_total
BEGIN
INSERT INTO [Compliance].[dbo].[314a_14845_Match_Tier2]
	SELECT a.sbi_name, a.sbi_name_alias,a.sbi_number,a.sbi_country,
		b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[314a_14845_sbiMatch_Tier1] a
	,[Compliance].[dbo].[314a_14845_MatchPerson_Tier1] b
	WHERE a.sbi_name LIKE
		(SELECT distinct concat(
			'%',
			substring(b.first_name,2,CEILING((LEN(b.first_name)/1.5)/1.5)),
			'%',
			substring(b.last_name,2,CEILING((LEN(b.last_name)/1.5)/1.5)),
			'%')
		FROM [Compliance].[dbo].[314a_14845_MatchPerson_Tier1] b 
		where b.id = @cnt) AND b.id = @cnt
		OR a.sbi_name LIKE
		(SELECT distinct concat(
			'%',
			substring(b.last_name,2,CEILING((LEN(b.last_name)/1.5)/1.5)),
			'%',
			substring(b.first_name,2,CEILING((LEN(b.first_name)/1.5)/1.5)),
			'%')
		FROM [Compliance].[dbo].[314a_14845_MatchPerson_Tier1] b 
		where b.id = @cnt) AND b.id = @cnt
		OR a.sbi_name LIKE
		(SELECT distinct concat(
			'%',
			substring(b.first_name,2,CEILING((LEN(b.first_name)/1.5)/1.5)),
			'%',
			substring(b.middle_name,2,CEILING((LEN(b.middle_name)/1.5)/1.5)),
			'%')
		FROM [Compliance].[dbo].[314a_14845_MatchPerson_Tier1] b 
		where b.id = @cnt) AND b.id = @cnt
		OR a.sbi_name LIKE
		(SELECT distinct concat(
			'%',
			substring(b.middle_name,2,CEILING((LEN(b.middle_name)/1.5)/1.5)),
			'%',
			substring(b.last_name,2,CEILING((LEN(b.last_name)/1.5)/1.5)),
			'%')
		FROM [Compliance].[dbo].[314a_14845_MatchPerson_Tier1] b 
		where b.id = @cnt) AND b.id = @cnt
		OR a.sbi_name LIKE
		(SELECT distinct concat(
			'%',
			substring(b.last_name,2,CEILING((LEN(b.last_name)/1.5)/1.5)),
			'%',
			substring(b.middle_name,2,CEILING((LEN(b.middle_name)/1.5)/1.5)),
			'%')
		FROM [Compliance].[dbo].[314a_14845_MatchPerson_Tier1] b 
		where b.id = @cnt) AND b.id = @cnt
SET @cnt = @cnt + 1;
END;
--########################### TIER 2 CLEANED ########################################
GO
DROP TABLE IF EXISTS [Compliance].[dbo].[314a_14845_MatchPerson_Tier2]
GO
CREATE TABLE [dbo].[314a_14845_MatchPerson_Tier2](
	[last_name] [nvarchar](max) NOT NULL,
	[first_name] [nvarchar](max) NULL,
	[middle_name] [nvarchar](max) NULL,
	[suffix] [nvarchar](max) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[314a_14845_MatchPerson_Tier2]
	SELECT distinct [last_name]
	      ,[first_name]
	      ,[middle_name]
	      ,[suffix]
	  FROM [Compliance].[dbo].[314a_14845_Match_Tier2]
GO
DROP TABLE IF EXISTS [dbo].[314a_14845_sbiMatch_Tier2]
GO
CREATE TABLE [dbo].[314a_14845_sbiMatch_Tier2](
	[sbi_name] [nvarchar](max) NOT NULL,
	[sbi_name_alias] [nvarchar](max) NULL,
	[sbi_number] [nvarchar](max) NULL,
	[sbi_country] [nvarchar](max) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[314a_14845_sbiMatch_Tier2]
	SELECT DISTINCT [sbi_name]
      ,[sbi_name_alias]
      ,[sbi_number]
      ,[sbi_country]
	FROM [Compliance].[dbo].[314a_14845_Match_Tier2]
GO
--########################### TIER 3 ################################################
DROP TABLE IF EXISTS [dbo].[314a_14845_Match_Tier3]
GO
CREATE TABLE [dbo].[314a_14845_Match_Tier3](
	[sbi_name] [nvarchar](max) NOT NULL,
	[sbi_name_alias] [nvarchar](max) NULL,
	[sbi_number] [nvarchar](max) NULL,
	[sbi_country] [nvarchar](max) NULL,
	[last_name] [nvarchar](max) NOT NULL,
	[first_name] [nvarchar](max) NULL,
	[middle_name] [nvarchar](max) NULL,
	[suffix] [nvarchar](max) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
DECLARE @cnt INT = 1;
DECLARE @cnt_total INT = (
	select count(*) from [Compliance].[dbo].[314a_14845_MatchPerson_Tier2]);
WHILE @cnt < @cnt_total
BEGIN
INSERT INTO [Compliance].[dbo].[314a_14845_Match_Tier3]
	SELECT a.sbi_name, a.sbi_name_alias,a.sbi_number,a.sbi_country,
		b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[314a_14845_sbiMatch_Tier2] a
		,[Compliance].[dbo].[314a_14845_MatchPerson_Tier2] b
	WHERE a.sbi_name LIKE
		(SELECT distinct concat(
			b.last_name,
			'_',
			substring(b.first_name,1,CEILING((LEN(b.first_name)/1.5)/1.5)),
			'%')
		FROM [Compliance].[dbo].[314a_14845_MatchPerson_Tier2] b 
		where b.id = @cnt) AND b.id = @cnt
		OR a.sbi_name LIKE
		(SELECT distinct concat(
			b.first_name,
			'_',
			substring(b.last_name,1,CEILING((LEN(b.last_name)/1.5)/1.5)),
			'%')
		FROM [Compliance].[dbo].[314a_14845_MatchPerson_Tier2] b 
		where b.id = @cnt) AND b.id = @cnt
		--OR a.sbi_name LIKE
		--(SELECT distinct concat(
		--	'%'
		--	,b.first_name
		--	,'_'
		--	,b.middle_name
		--	,'_'
		--	,b.last_name
		--	,'%')
		--FROM [Compliance].[dbo].[314a_14845_MatchPerson_Tier2] b 
		--where b.id = @cnt) AND b.id = @cnt
		--OR a.sbi_name LIKE
		--(SELECT distinct concat(
		--	'%'
		--	,b.first_name
		--	,'_'
		--	,b.middle_name
		--	,'%')
		--FROM [Compliance].[dbo].[314a_14845_MatchPerson_Tier2] b 
		--where b.id = @cnt) AND b.id = @cnt
SET @cnt = @cnt + 1;
END;




----################################ BUSINESS #######################################
GO
DROP TABLE IF EXISTS [Compliance].[dbo].[314a_Business_14845_Match_Tier1]
GO
CREATE TABLE [Compliance].[dbo].[314a_Business_14845_Match_Tier1](
	[sbi_Nombre] [nvarchar](max) NULL,
    [sbi_Pais_Reside_Cli] [nvarchar](max) NULL,
    [sbi_Observaciones_1] [nvarchar](max) NULL,
    [sbi_Nombre_1] [nvarchar](max) NULL,
    [sbi_Nombre_2] [nvarchar](max) NULL,
    [sbi_Banco_Rec] [nvarchar](max) NULL,
    [sbi_Nombre_3] [nvarchar](max) NULL,
	[314a_business_name] [nvarchar](max) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
DECLARE @cnt INT = 1;
DECLARE @cnt_total INT = (
	select count(*) from [Compliance].[dbo].[314a-Business-14845]);
WHILE @cnt <= @cnt_total
BEGIN
INSERT INTO [Compliance].[dbo].[314a_Business_14845_Match_Tier1]
	SELECT a.Nombre,'','','',''
		,'',''
		,b.business_name
	FROM [Compliance].[dbo].[TRNCONSULTA-2019-05-09names] a
	,[Compliance].[dbo].[314a-Business-14845] b
	WHERE a.Nombre LIKE
		(SELECT distinct concat(
			'%',
			substring(b.business_name,2,CEILING((LEN(b.business_name)/1.5)/1.5)),
			'%')
		FROM [Compliance].[dbo].[314a-Business-14845] b 
		where b.id = @cnt) AND b.id = @cnt
	SET @cnt = @cnt + 1;
END;
GO
DROP TABLE IF EXISTS [dbo].[314a_Business_14845_Match_Tier2]
GO
CREATE TABLE [dbo].[314a_Business_14845_Match_Tier2](
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
    [314a_country] [nvarchar](max) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
DECLARE @cnt INT = 1;
DECLARE @cnt_total INT = (
	select count(*) from [Compliance].[dbo].[314a-Business-14845]);
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



---################################ --------- #######################################














---ALGORITHM TESTING
SELECT distinct b.last_name, b.first_name
FROM [Compliance].[dbo].[314a-Persons-14845] b

GO
DECLARE @cnt INT = 1;
DECLARE @cnt_total INT = (select count(*) from [Compliance].[dbo].[314a-Persons-14845] b);
DECLARE @shortName integer;
---ACCOUNTING FOR SHORT NAMES
DECLARE @allPersons table(
	[match_string] [nvarchar](4000) NULL,
	[last_name] [nvarchar](4000) NULL,
	[first_name] [nvarchar](4000) NULL,
	[middle_name] [nvarchar](4000) NULL,
	[suffix] [nvarchar](4000) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL)
INSERT INTO @allPersons
	SELECT distinct concat('%',b.last_name,'%',b.first_name,'%'), b.last_name,b.first_name,b.middle_name,b.suffix FROM [Compliance].[dbo].[314a-Persons-14845] b where LEN(b.last_name) <= 4 or LEN(b.first_name) <= 4
INSERT INTO @allPersons
	SELECT distinct concat('%',
		substring(b.last_name,1,CEILING((LEN(b.last_name)/1.5)/1.5)),'%',
		substring(b.first_name,1,CEILING((LEN(b.first_name)/1.5)/1.5)),'%')
		, b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[314a-Persons-14845] b where LEN(b.last_name) > 4 or LEN(b.first_name) > 4
SELECT * from @allPersons a
--SELECT distinct a.match_string, b.last_name, b.first_name, b.middle_name, b.suffix  from @allPersons a right join [Compliance].[dbo].[314a-Persons-14845] b on b.last_name like a.match_string
---ACCOUNTING FOR SHORT NAMES
SET @shortName = 4
WHILE @cnt < @cnt_total
BEGIN
	
	--IF @shortName <= (SELECT LEN(b.last_name) FROM [Compliance].[dbo].[314a-Persons-14845] b where b.id = @cnt)
	--	select distinct concat('%',b.last_name,'%') 
	--	from [Compliance].[dbo].[314a-Persons-14845] b
	--	where b.id = @cnt and LEN(b.last_name) <= @shortName;
	--ELSE
	--	select distinct concat('%',substring(b.last_name,2,CEILING((LEN(b.last_name)/1.5)/1.5)),'%')
	--	from [Compliance].[dbo].[314a-Persons-14845] b
	--	where b.id = @cnt;
	SET @cnt = @cnt + 1;
END;
 
SELECT distinct CONCAT('%',LEFT(b.first_name,LEN(b.first_name)/2),'%'
			,LEFT(b.last_name,2),'%')
		FROM [Compliance].[dbo].[314a-Persons-14845] b 

select LEN(b.first_name) as total,CEILING(LEN(b.first_name)/1.5) as charsToBring_ceil, (LEN(b.first_name)/1.5)/2, CEILING((LEN(b.first_name)/1.5)/1.5) as charsToCount_ceil
		FROM [Compliance].[dbo].[314a-Persons-14845] b 

select b.first_name,concat('%',substring(b.first_name,2,CEILING((LEN(b.first_name)/1.5)/1.5)),'%')
FROM [Compliance].[dbo].[314a-Persons-14845] b 

select b.last_name,concat('%',substring(b.last_name,2,CEILING((LEN(b.last_name)/1.5)/1.5)),'%')
FROM [Compliance].[dbo].[314a-Persons-14845] b 

SELECT distinct concat('%',substring(b.last_name,1,CEILING((LEN(b.last_name)/1.5)/1.5)),'%') FROM [Compliance].[dbo].[314a-Persons-14845] b