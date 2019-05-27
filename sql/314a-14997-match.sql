---############################## 314 Match #########################################
--########################### TIER 1 ################################################
USE [Compliance]
GO
DROP TABLE IF EXISTS [dbo].[314a_14997_Match_Tier1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[314a_14997_Match_Tier1](
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
--this substring accounts FOR SHORT NAMES matchString first name
DECLARE @allPersonsfn table(
	[match_string] [nvarchar](4000) NULL,
	[last_name] [nvarchar](4000) NULL,
	[first_name] [nvarchar](4000) NULL,
	[middle_name] [nvarchar](4000) NULL,
	[suffix] [nvarchar](4000) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL)
INSERT INTO @allPersonsfn
	SELECT distinct concat('%',b.first_name,'%'),
		b.last_name,b.first_name,b.middle_name,b.suffix 
	FROM [Compliance].[dbo].[314a-Person-14997] b where LEN(b.first_name) <= 4
INSERT INTO @allPersonsfn
	SELECT distinct concat('%',
		substring(b.first_name,1,CEILING((LEN(b.first_name)/1.5)/1.5)),'%')
		, b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[314a-Person-14997] b where LEN(b.first_name) > 4
WHILE @cnt <= (select count(*) from @allPersonsfn)
BEGIN
	--############### INSERT FROM CLIENTESFIRMANTEStable ###############
INSERT INTO [Compliance].[dbo].[314a_14997_Match_Tier1]
	SELECT a.Nombre,a.[Nombre Fantasía], CONCAT(a.[Nº Documento]
		,' ',a.[Tipo de documento]),a.[País del documento],
		b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[clientesFirmantes] a
	,@allPersonsfn b
	WHERE a.Nombre LIKE 
		(select b.match_string
		FROM @allPersonsfn b
		where b.id = @cnt) AND b.id = @cnt
SET @cnt = @cnt + 1;
END;
-------------check only last name------------------------
DECLARE @allPersonsln table(
	[match_string] [nvarchar](4000) NULL,
	[last_name] [nvarchar](4000) NULL,
	[first_name] [nvarchar](4000) NULL,
	[middle_name] [nvarchar](4000) NULL,
	[suffix] [nvarchar](4000) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL)
INSERT INTO @allPersonsln
	SELECT distinct concat('%',b.last_name,'%'), b.last_name,b.first_name,b.middle_name,b.suffix FROM [Compliance].[dbo].[314a-Person-14997] b where LEN(b.last_name) <= 4
INSERT INTO @allPersonsln
	SELECT distinct concat('%',
		substring(b.last_name,1,CEILING((LEN(b.last_name)/1.5)/1.5)),'%')
		, b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[314a-Person-14997] b where LEN(b.last_name) > 4
SET @cnt = 1;
WHILE @cnt <= (select count(*) from @allPersonsln)
BEGIN
	--############### INSERT FROM CLIENTESFIRMANTEStable ###############
INSERT INTO [Compliance].[dbo].[314a_14997_Match_Tier1]
	SELECT a.Nombre,a.[Nombre Fantasía], CONCAT(a.[Nº Documento]
		,' ',a.[Tipo de documento]),a.[País del documento],
		b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[clientesFirmantes] a
	,@allPersonsln b
	WHERE a.Nombre LIKE 
		(select b.match_string
		FROM @allPersonsln b
		where b.id = @cnt) AND b.id = @cnt
SET @cnt = @cnt + 1;
END;
	--############### INSERT FROM TRANSACTIONS table ###############
SET @cnt = 1;
WHILE @cnt <= (select count(*) from @allPersonsfn)
BEGIN
INSERT INTO [Compliance].[dbo].[314a_14997_Match_Tier1]
	SELECT a.Nombre,'','',''
		,b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[TRNCONSULTA-2019-05-23names] a
		,@allPersonsfn b
	WHERE a.Nombre LIKE
		(select b.match_string
		FROM @allPersonsfn b
		where b.id = @cnt) AND b.id = @cnt
SET @cnt = @cnt + 1;
END;
SET @cnt = 1;
WHILE @cnt <= (select count(*) from @allPersonsln)
BEGIN
INSERT INTO [Compliance].[dbo].[314a_14997_Match_Tier1]
	SELECT a.Nombre,'','',''
		,b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[TRNCONSULTA-2019-05-23names] a
		,@allPersonsln b
	WHERE a.Nombre LIKE
		(select b.match_string
		FROM @allPersonsln b
		where b.id = @cnt) AND b.id = @cnt
SET @cnt = @cnt + 1;
END;
--########################### TIER 1 CLEANED ########################################
GO
DROP TABLE IF EXISTS [Compliance].[dbo].[314a_14997_MatchPerson_Tier1]
GO
CREATE TABLE [dbo].[314a_14997_MatchPerson_Tier1](
	[last_name] [nvarchar](max) NOT NULL,
	[first_name] [nvarchar](max) NULL,
	[middle_name] [nvarchar](max) NULL,
	[suffix] [nvarchar](max) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[314a_14997_MatchPerson_Tier1]
	SELECT distinct [last_name]
	      ,[first_name]
	      ,[middle_name]
	      ,[suffix]
	  FROM [Compliance].[dbo].[314a_14997_Match_Tier1]
GO
DROP TABLE IF EXISTS [dbo].[314a_14997_sbiMatch_Tier1]
GO
CREATE TABLE [dbo].[314a_14997_sbiMatch_Tier1](
	[sbi_name] [nvarchar](max) NOT NULL,
	[sbi_name_alias] [nvarchar](max) NULL,
	[sbi_number] [nvarchar](max) NULL,
	[sbi_country] [nvarchar](max) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[314a_14997_sbiMatch_Tier1]
	SELECT DISTINCT [sbi_name]
      ,[sbi_name_alias]
      ,[sbi_number]
      ,[sbi_country]
	FROM [Compliance].[dbo].[314a_14997_Match_Tier1]
GO
--########################### TIER 2 ################################################
DROP TABLE IF EXISTS [dbo].[314a_14997_Match_Tier2]
GO
CREATE TABLE [dbo].[314a_14997_Match_Tier2](
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
---------2nd tier------------------------------------------
---ACCOUNTING FOR SHORT NAMES-- format last_name firstname
DECLARE @allPersonslnfn table(
	[match_string] [nvarchar](4000) NULL,
	[last_name] [nvarchar](4000) NULL,
	[first_name] [nvarchar](4000) NULL,
	[middle_name] [nvarchar](4000) NULL,
	[suffix] [nvarchar](4000) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL)
INSERT INTO @allPersonslnfn
	SELECT distinct concat('%',b.last_name,'%',b.first_name,'%'),
		b.last_name,b.first_name,b.middle_name,b.suffix 
	FROM [Compliance].[dbo].[314a_14997_MatchPerson_Tier1] b where LEN(b.last_name) <= 4 or LEN(b.first_name) <= 4
INSERT INTO @allPersonslnfn
	SELECT distinct concat('%',
		substring(b.last_name,2,CEILING((LEN(b.last_name)/1.5)/1.5)),'%',
		substring(b.first_name,2,CEILING((LEN(b.first_name)/1.5)/1.5)),'%')
		, b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[314a_14997_MatchPerson_Tier1] b where LEN(b.last_name) > 4 or LEN(b.first_name) > 4
--select * from @allPersonslnfn
---ACCOUNTING FOR SHORT NAMES-- format firstname last_name
DECLARE @allPersonsfnln table(
	[match_string] [nvarchar](4000) NULL,
	[last_name] [nvarchar](4000) NULL,
	[first_name] [nvarchar](4000) NULL,
	[middle_name] [nvarchar](4000) NULL,
	[suffix] [nvarchar](4000) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL)
INSERT INTO @allPersonsfnln
	SELECT distinct concat('%',b.first_name,'%',b.last_name,'%'),
		b.last_name,b.first_name,b.middle_name,b.suffix 
	FROM [Compliance].[dbo].[314a_14997_MatchPerson_Tier1] b where LEN(b.last_name) <= 4 or LEN(b.first_name) <= 4
INSERT INTO @allPersonsfnln
	SELECT distinct concat('%',
		substring(b.first_name,2,CEILING((LEN(b.first_name)/1.5)/1.5)),'%',
		substring(b.last_name,2,CEILING((LEN(b.last_name)/1.5)/1.5)),'%')
		, b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[314a_14997_MatchPerson_Tier1] b where LEN(b.last_name) > 4 or LEN(b.first_name) > 4
--select * from @allPersonsfnln
---------2nd tier------------------------------------------
DECLARE @cnt INT = 1;
WHILE @cnt <= (select count(*) from @allPersonsfnln)
BEGIN
INSERT INTO [Compliance].[dbo].[314a_14997_Match_Tier2]
	SELECT a.sbi_name, a.sbi_name_alias,a.sbi_number,a.sbi_country,
		b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[314a_14997_sbiMatch_Tier1] a
	,@allPersonsfnln b
	WHERE a.sbi_name LIKE
		(select b.match_string
		FROM @allPersonsfnln b
		where b.id = @cnt) AND b.id = @cnt
SET @cnt = @cnt + 1;
END;
SET @cnt = 1;
WHILE @cnt <= (select count(*) from @allPersonslnfn)
BEGIN
INSERT INTO [Compliance].[dbo].[314a_14997_Match_Tier2]
	SELECT a.sbi_name, a.sbi_name_alias,a.sbi_number,a.sbi_country,
		b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[314a_14997_sbiMatch_Tier1] a
	,@allPersonslnfn b
	WHERE a.sbi_name LIKE
		(select b.match_string
		FROM @allPersonslnfn b
		where b.id = @cnt) AND b.id = @cnt
SET @cnt = @cnt + 1;
END;
--########################### TIER 2 CLEANED ########################################
GO
DROP TABLE IF EXISTS [Compliance].[dbo].[314a_14997_MatchPerson_Tier2]
GO
CREATE TABLE [dbo].[314a_14997_MatchPerson_Tier2](
	[last_name] [nvarchar](max) NOT NULL,
	[first_name] [nvarchar](max) NULL,
	[middle_name] [nvarchar](max) NULL,
	[suffix] [nvarchar](max) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[314a_14997_MatchPerson_Tier2]
	SELECT distinct [last_name]
	      ,[first_name]
	      ,[middle_name]
	      ,[suffix]
	  FROM [Compliance].[dbo].[314a_14997_Match_Tier2]
GO
DROP TABLE IF EXISTS [dbo].[314a_14997_sbiMatch_Tier2]
GO
CREATE TABLE [dbo].[314a_14997_sbiMatch_Tier2](
	[sbi_name] [nvarchar](max) NOT NULL,
	[sbi_name_alias] [nvarchar](max) NULL,
	[sbi_number] [nvarchar](max) NULL,
	[sbi_country] [nvarchar](max) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[314a_14997_sbiMatch_Tier2]
	SELECT DISTINCT [sbi_name]
      ,[sbi_name_alias]
      ,[sbi_number]
      ,[sbi_country]
	FROM [Compliance].[dbo].[314a_14997_Match_Tier2]
GO


----################################ BUSINESS #######################################
GO
DROP TABLE IF EXISTS [Compliance].[dbo].[314a_Business_14997_Match_Tier1]
GO
CREATE TABLE [Compliance].[dbo].[314a_Business_14997_Match_Tier1](
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
DECLARE @allBusiness table(
	[match_string] [nvarchar](4000) NULL,
	[business_name] [nvarchar](4000) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL)
INSERT INTO @allBusiness
	SELECT distinct concat('%',b.business_name,'%') as 'match_string',
		b.business_name
	FROM [Compliance].[dbo].[314a-Business-14997] b where LEN(b.business_name) <= 4
INSERT INTO @allBusiness
	SELECT distinct concat('%',
		substring(b.business_name,2,CEILING((LEN(b.business_name)/1.5)/1.5)),'%')
		as 'match_string',b.business_name
	FROM [Compliance].[dbo].[314a-Business-14997] b where LEN(b.business_name) > 4
WHILE @cnt <= (select count(*) from @allBusiness)
BEGIN
INSERT INTO [Compliance].[dbo].[314a_Business_14997_Match_Tier1]
	SELECT a.Nombre,'','','',''
		,'',''
		,b.business_name
	FROM [Compliance].[dbo].[TRNCONSULTA-2019-05-23names] a
	,@allBusiness b
	WHERE a.Nombre LIKE
		(select b.match_string
		FROM @allBusiness b
		where b.id = @cnt) AND b.id = @cnt
	SET @cnt = @cnt + 1;
END;
GO
DROP TABLE IF EXISTS [dbo].[314a_Business_14997_Match_Tier2]
GO
CREATE TABLE [dbo].[314a_Business_14997_Match_Tier2](
	[sbi_business_name] [nvarchar](max) NOT NULL,
	[314a_business_name] [nvarchar](max) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
DECLARE @cnt INT = 1;
DECLARE @allBusiness table(
	[match_string] [nvarchar](4000) NULL,
	[business_name] [nvarchar](4000) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL)
INSERT INTO @allBusiness
	SELECT distinct concat('%',b.business_name,'%') as 'match_string',
		b.business_name
	FROM [Compliance].[dbo].[314a-Business-14997] b where LEN(b.business_name) <= 4
INSERT INTO @allBusiness
	SELECT distinct concat('%',
		substring(b.business_name,2,CEILING((LEN(b.business_name)/1.5)/1)),'%')
		as 'match_string',b.business_name
	FROM [Compliance].[dbo].[314a-Business-14997] b where LEN(b.business_name) > 4
WHILE @cnt <= (select count(*) from @allBusiness)
BEGIN
INSERT INTO [Compliance].[dbo].[314a_Business_14997_Match_Tier2]
	SELECT a.sbi_Nombre,
		   b.business_name
	FROM [Compliance].[dbo].[314a_Business_14997_Match_Tier1] a
	,@allBusiness b
	WHERE a.sbi_Nombre LIKE (select b.match_string
		FROM @allBusiness b
		where b.id = @cnt) AND b.id = @cnt
	SET @cnt = @cnt + 1;
END;



---################################ --------- #######################################














---ALGORITHM TESTING
SELECT distinct b.last_name, b.first_name
FROM [Compliance].[dbo].[314a-Person-14997] b

GO
DECLARE @cnt INT = 1;
DECLARE @cnt_total INT = (select count(*) from [Compliance].[dbo].[314a-Person-14997] b);
DECLARE @shortName integer;



---------1st tier------------------------------------------
-------ACCOUNTING FOR SHORT NAMES-check only first name------------------------
DECLARE @allPersonsfn table(
	[match_string] [nvarchar](4000) NULL,
	[last_name] [nvarchar](4000) NULL,
	[first_name] [nvarchar](4000) NULL,
	[middle_name] [nvarchar](4000) NULL,
	[suffix] [nvarchar](4000) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL)
INSERT INTO @allPersonsfn
	SELECT distinct concat('%',b.first_name,'%'), b.last_name,b.first_name,b.middle_name,b.suffix FROM [Compliance].[dbo].[314a-Person-14997] b where LEN(b.first_name) <= 4
INSERT INTO @allPersonsfn
	SELECT distinct concat('%',
		substring(b.first_name,1,CEILING((LEN(b.first_name)/1.5)/1.5)),'%')
		, b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[314a-Person-14997] b where LEN(b.first_name) > 4
--SELECT * from @allPersonsfn a
-------------check only last name------------------------
DECLARE @allPersonsln table(
	[match_string] [nvarchar](4000) NULL,
	[last_name] [nvarchar](4000) NULL,
	[first_name] [nvarchar](4000) NULL,
	[middle_name] [nvarchar](4000) NULL,
	[suffix] [nvarchar](4000) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL)
INSERT INTO @allPersonsln
	SELECT distinct concat('%',b.last_name,'%'), b.last_name,b.first_name,b.middle_name,b.suffix FROM [Compliance].[dbo].[314a-Person-14997] b where LEN(b.last_name) <= 4
INSERT INTO @allPersonsln
	SELECT distinct concat('%',
		substring(b.last_name,1,CEILING((LEN(b.last_name)/1.5)/1.5)),'%')
		, b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[314a-Person-14997] b where LEN(b.last_name) > 4
--SELECT * from @allPersonsln a
---------2nd tier------------------------------------------
---ACCOUNTING FOR SHORT NAMES-- format last_name firstname
DECLARE @allPersonslnfn table(
	[match_string] [nvarchar](4000) NULL,
	[last_name] [nvarchar](4000) NULL,
	[first_name] [nvarchar](4000) NULL,
	[middle_name] [nvarchar](4000) NULL,
	[suffix] [nvarchar](4000) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL)
INSERT INTO @allPersonslnfn
	SELECT distinct concat('%',b.last_name,'%',b.first_name,'%'), b.last_name,b.first_name,b.middle_name,b.suffix FROM [Compliance].[dbo].[314a-Person-14997] b where LEN(b.last_name) <= 4 or LEN(b.first_name) <= 4
INSERT INTO @allPersonslnfn
	SELECT distinct concat('%',
		substring(b.last_name,2,CEILING((LEN(b.last_name)/1.5)/1.5)),'%',
		substring(b.first_name,2,CEILING((LEN(b.first_name)/1.5)/1.5)),'%')
		, b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[314a-Person-14997] b where LEN(b.last_name) > 4 or LEN(b.first_name) > 4
SELECT * from @allPersonslnfn a
---ACCOUNTING FOR SHORT NAMES-- format firstname last_name
DECLARE @allPersonsfnln table(
	[match_string] [nvarchar](4000) NULL,
	[last_name] [nvarchar](4000) NULL,
	[first_name] [nvarchar](4000) NULL,
	[middle_name] [nvarchar](4000) NULL,
	[suffix] [nvarchar](4000) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL)
INSERT INTO @allPersonsfnln
	SELECT distinct concat('%',b.first_name,'%',b.last_name,'%'), b.last_name,b.first_name,b.middle_name,b.suffix FROM [Compliance].[dbo].[314a-Person-14997] b where LEN(b.last_name) <= 4 or LEN(b.first_name) <= 4
INSERT INTO @allPersonsfnln
	SELECT distinct concat('%',
		substring(b.first_name,2,CEILING((LEN(b.first_name)/1.5)/1.5)),'%',
		substring(b.last_name,2,CEILING((LEN(b.last_name)/1.5)/1.5)),'%')
		, b.last_name,b.first_name,b.middle_name,b.suffix
	FROM [Compliance].[dbo].[314a-Person-14997] b where LEN(b.last_name) > 4 or LEN(b.first_name) > 4
SELECT * from @allPersonsfnln a
---------2nd tier------------------------------------------



--SELECT distinct a.match_string, b.last_name, b.first_name, b.middle_name, b.suffix  from @allPersons a right join [Compliance].[dbo].[314a-Person-14997] b on b.last_name like a.match_string
---ACCOUNTING FOR SHORT NAMES
SET @shortName = 4
WHILE @cnt < @cnt_total
BEGIN
	
	--IF @shortName <= (SELECT LEN(b.last_name) FROM [Compliance].[dbo].[314a-Person-14997] b where b.id = @cnt)
	--	select distinct concat('%',b.last_name,'%') 
	--	from [Compliance].[dbo].[314a-Person-14997] b
	--	where b.id = @cnt and LEN(b.last_name) <= @shortName;
	--ELSE
	--	select distinct concat('%',substring(b.last_name,2,CEILING((LEN(b.last_name)/1.5)/1.5)),'%')
	--	from [Compliance].[dbo].[314a-Person-14997] b
	--	where b.id = @cnt;
	SET @cnt = @cnt + 1;
END;
 
SELECT distinct CONCAT('%',LEFT(b.first_name,LEN(b.first_name)/2),'%'
			,LEFT(b.last_name,2),'%')
		FROM [Compliance].[dbo].[314a-Person-14997] b 

select LEN(b.first_name) as total,CEILING(LEN(b.first_name)/1.5) as charsToBring_ceil, (LEN(b.first_name)/1.5)/2, CEILING((LEN(b.first_name)/1.5)/1.5) as charsToCount_ceil
		FROM [Compliance].[dbo].[314a-Person-14997] b 

select b.first_name,concat('%',substring(b.first_name,2,CEILING((LEN(b.first_name)/1.5)/1.5)),'%')
FROM [Compliance].[dbo].[314a-Person-14997] b 

select b.last_name,concat('%',substring(b.last_name,2,CEILING((LEN(b.last_name)/1.5)/1.5)),'%')
FROM [Compliance].[dbo].[314a-Person-14997] b 

SELECT distinct concat('%',substring(b.last_name,1,CEILING((LEN(b.last_name)/1.5)/1.5)),'%') FROM [Compliance].[dbo].[314a-Person-14997] b