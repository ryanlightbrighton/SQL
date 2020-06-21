/*
	NEW BUILD DATA DICTIONARY QUERY (have not tried yet)
	https://sqlarts.blogspot.com/2017/12/generate-data-dictionary-for-sql.html
*/

SELECT  
   DB_NAME() AS [Database Name],
   OBJECT_SCHEMA_NAME(TBL.[object_id],DB_ID()) AS [Schema],   
   TBL.[name] AS [Table name], 
   AC.[name] AS [Column name],   
   UPPER(TY.[name]) AS DataType, 
   AC.[max_length] AS [Length],  
   AC.[precision], 
   AC.[scale], 
   AC.[is_nullable] AS IsNullable,
   ISNULL(SI.is_primary_key,0) AS IsPrimaryKey,
   SKC.name as [Primary Key Constarint],
   (CASE WHEN SIC.index_column_id > 0 THEN 1 ELSE 0 END) AS IsIndexed,
   ISNULL(is_included_column, 0) AS IsIncludedIndex,
   SI.name AS [Index Name],
   OBJECT_NAME(SFC.constraint_object_id) as [Foreign Key Constraint],
   OBJECT_NAME(SFC.referenced_object_id) as [Parent Table],
   SDC.name AS [Default Constraint],
   SEP.value AS Comments 
FROM sys.tables AS TBL
INNER JOIN sys.all_columns AC ON TBL.[object_id] = AC.[object_id]  
INNER JOIN sys.types TY ON AC.[system_type_id] = TY.[system_type_id] AND AC.[user_type_id] = TY.[user_type_id]   
LEFT JOIN sys.index_columns SIC on sic.object_id = TBL.object_id AND AC.column_id = SIC.column_id
LEFT JOIN sys.indexes SI on SI.object_id = TBL.object_id AND SIC.index_id = SI.index_id
LEFT JOIN sys.foreign_key_columns SFC on SFC.parent_object_id = TBL.object_id AND SFC.parent_column_id = AC.column_id
LEFT JOIN sys.key_constraints SKC on skc.parent_object_id = TBL.object_id AND SIC.index_column_id = SKC.unique_index_id
LEFT JOIN sys.default_constraints SDC on SDC.parent_column_id = AC.column_id
LEFT JOIN sys.extended_properties SEP on SEP.major_id = TBL.object_id AND SEP.minor_id = AC.column_id
ORDER BY TBL.[name], AC.[column_id]


/*BUILD DATA DICTIONARY QUERY*/

select schema_name(tab.schema_id) as schema_name,
       tab.name as table_name, 
       col.name as column_name, 
       t.name as data_type,    
       t.name + 
       case when t.is_user_defined = 0 then 
                 isnull('(' + 
                 case when t.name in ('binary', 'char', 'nchar', 
                           'varchar', 'nvarchar', 'varbinary') then
                           case col.max_length 
                                when -1 then 'MAX' 
                                else 
                                     case when t.name in ('nchar', 
                                               'nvarchar') then
                                               cast(col.max_length/2 
                                               as varchar(4)) 
                                          else cast(col.max_length 
                                               as varchar(4)) 
                                     end
                           end
                      when t.name in ('datetime2', 'datetimeoffset', 
                           'time') then 
                           cast(col.scale as varchar(4))
                      when t.name in ('decimal', 'numeric') then
                            cast(col.precision as varchar(4)) + ', ' +
                            cast(col.scale as varchar(4))
                 end + ')', '')        
            else ':' + 
                 (select c_t.name + 
                         isnull('(' + 
                         case when c_t.name in ('binary', 'char', 
                                   'nchar', 'varchar', 'nvarchar', 
                                   'varbinary') then 
                                    case c.max_length 
                                         when -1 then 'MAX' 
                                         else   
                                              case when t.name in 
                                                        ('nchar', 
                                                        'nvarchar') then 
                                                        cast(c.max_length/2
                                                        as varchar(4))
                                                   else cast(c.max_length
                                                        as varchar(4))
                                              end
                                    end
                              when c_t.name in ('datetime2', 
                                   'datetimeoffset', 'time') then 
                                   cast(c.scale as varchar(4))
                              when c_t.name in ('decimal', 'numeric') then
                                   cast(c.precision as varchar(4)) + ', ' 
                                   + cast(c.scale as varchar(4))
                         end + ')', '') 
                    from sys.columns as c
                         inner join sys.types as c_t 
                             on c.system_type_id = c_t.user_type_id
                   where c.object_id = col.object_id
                     and c.column_id = col.column_id
                     and c.user_type_id = col.user_type_id
                 )
        end as data_type_ext,
        case when col.is_nullable = 0 then 'N' 
             else 'Y' end as nullable,
        case when def.definition is not null then def.definition 
             else '' end as default_value,
        case when pk.column_id is not null then 'PK' 
             else '' end as primary_key, 
        case when fk.parent_column_id is not null then 'FK' 
             else '' end as foreign_key, 
        case when uk.column_id is not null then 'UK' 
             else '' end as unique_key,
        case when ch.check_const is not null then ch.check_const 
             else '' end as check_contraint,
        cc.definition as computed_column_definition,
        ep.value as comments
   from sys.tables as tab
        left join sys.columns as col
            on tab.object_id = col.object_id
        left join sys.types as t
            on col.user_type_id = t.user_type_id
        left join sys.default_constraints as def
            on def.object_id = col.default_object_id
        left join (
                  select index_columns.object_id, 
                         index_columns.column_id
                    from sys.index_columns
                         inner join sys.indexes 
                             on index_columns.object_id = indexes.object_id
                            and index_columns.index_id = indexes.index_id
                   where indexes.is_primary_key = 1
                  ) as pk 
            on col.object_id = pk.object_id 
           and col.column_id = pk.column_id
        left join (
                  select fc.parent_column_id, 
                         fc.parent_object_id
                    from sys.foreign_keys as f 
                         inner join sys.foreign_key_columns as fc 
                             on f.object_id = fc.constraint_object_id
                   group by fc.parent_column_id, fc.parent_object_id
                  ) as fk
            on fk.parent_object_id = col.object_id 
           and fk.parent_column_id = col.column_id    
        left join (
                  select c.parent_column_id, 
                         c.parent_object_id, 
                         'Check' check_const
                    from sys.check_constraints as c
                   group by c.parent_column_id,
                         c.parent_object_id
                  ) as ch
            on col.column_id = ch.parent_column_id
           and col.object_id = ch.parent_object_id
        left join (
                  select index_columns.object_id, 
                         index_columns.column_id
                    from sys.index_columns
                         inner join sys.indexes 
                             on indexes.index_id = index_columns.index_id
                            and indexes.object_id = index_columns.object_id
                    where indexes.is_unique_constraint = 1
                    group by index_columns.object_id, 
                          index_columns.column_id
                  ) as uk
            on col.column_id = uk.column_id 
           and col.object_id = uk.object_id
        left join sys.extended_properties as ep 
            on tab.object_id = ep.major_id
           and col.column_id = ep.minor_id
           and ep.name = 'MS_Description'
           and ep.class_desc = 'OBJECT_OR_COLUMN'
        left join sys.computed_columns as cc
            on tab.object_id = cc.object_id
           and col.column_id = cc.column_id
  order by schema_name,
        table_name, 
        column_name; 

/*dynamic query example*/

CREATE PROCEDURE dbo.myProcedure @fname varchar(75)
AS
	BEGIN
		SELECT * FROM tCustomer WHERE CustFName = @fname
	END
GO

/*execute like this*/

dbo.myProcedure @fname = 'Paul';

/*--------------------------- DYNAMIC QUERY - MONTHLY ---------------------------*/

CREATE PROCEDURE dbo.getMonthlyOrders @thisMonth int
AS
	BEGIN
		SELECT * FROM tOrder WHERE MONTH(OrderDate) = @thisMonth
	END
GO

/*execute like this*/

dbo.getMonthlyOrders @thisMonth = 1;

/*--------------------------- DYNAMIC QUERY - WEEKLY ---------------------------*/

CREATE PROCEDURE dbo.getWeeklyOrders @thisWeek int
AS
	BEGIN
		SELECT * FROM tOrder WHERE DATEPART(week, OrderDate) = @thisWeek
	END
GO

/*execute like this*/

dbo.getWeeklyOrders @thisWeek = 1;

/*--------------------------- DYNAMIC QUERY - WEEKLY & MONTHLY---------------------------*/

CREATE PROCEDURE dbo.getWeeklyMonthlyOrders @dateSelector int, @weekOrMonth varchar(1)
AS
	BEGIN
		IF @weekOrMonth IN ('w','W')
			SELECT * FROM tOrder WHERE DATEPART(week, OrderDate) = @dateSelector
		ELSE
			IF @weekOrMonth IN ('m','M')
				SELECT * FROM tOrder WHERE MONTH(OrderDate) = @dateSelector
			ELSE
				PRINT('You must select ''w'' for weekly or ''m'' for monthly!');
	END
GO

/*execute like this*/

dbo.getWeeklyMonthlyOrders
@dateSelector = 1,
@weekOrMonth = 'w';

/*--------------------------- PASSWORD CONSTRAINT ---------------------------*/

/*check password contains numbers and letters*/

DECLARE @str AS VARCHAR(50)
SET @str = 'Herbie111'

IF PATINDEX('%[a-z]%', @str) > 0 AND PATINDEX('%[0-9]%', @str) > 0
   PRINT 'YES'
ELSE
   PRINT 'NO'
   
   

/*-----------------------------------------------------------------------------------------*/   
/*---------------------------------------- QUERIES ----------------------------------------*/
/*-----------------------------------------------------------------------------------------*/



/*ABSENCES*/


/* cancelled appointments */

SELECT AppointmentID, tCustomer.CustFName, tCustomer.CustSName
FROM tAppointment
INNER JOIN tCustomer
ON tAppointment.CustomerID = tCustomer.CustomerID
WHERE tAppointment.Cancelled = 1;

/* sick days for January*/

SELECT AbsenceDate, AbsenceDescription, BarberFName, BarberSName
FROM tAbsence
INNER JOIN  tBarber
ON tAbsence.BarberID = tBarber.BarberID
INNER JOIN  tAbsenceType
ON tAbsence.AbsenceType = tAbsenceType.AbsenceType
WHERE tAbsence.AbsenceType = 2 AND AbsenceDate BETWEEN '2019-01-01' AND '2019-01-31';

/* all 'Senior Barber' absences for Jan*/

SELECT AbsenceDate, AbsenceDescription, BarberFName, BarberSName
FROM tAbsence
INNER JOIN  tBarber
ON tAbsence.BarberID = tBarber.BarberID
INNER JOIN  tAbsenceType
ON tAbsence.AbsenceType = tAbsenceType.AbsenceType
INNER JOIN  tJobTitle
ON tBarber.JobTitleID = tJobTitle.JobTitleID
WHERE tJobTitle.JobTitleDescription = 'Senior Barber' AND AbsenceDate BETWEEN '2019-01-01' AND '2019-01-31';

/* all absences by description for each barber */

SELECT count(AbsenceDate) AS INCIDENCES, AbsenceDescription, BarberFName, BarberSName
FROM tAbsence
INNER JOIN  tBarber
ON tAbsence.BarberID = tBarber.BarberID
INNER JOIN  tAbsenceType
ON tAbsence.AbsenceType = tAbsenceType.AbsenceType
GROUP BY AbsenceDescription, BarberFName, BarberSName
ORDER BY BarberSName;

/*all total absences for each barber*/

SELECT COUNT(AbsenceDate) AS INCIDENCES, BarberFName, BarberSName
FROM tAbsence
INNER JOIN  tBarber
ON tAbsence.BarberID = tBarber.BarberID
INNER JOIN  tAbsenceType
ON tAbsence.AbsenceType = tAbsenceType.AbsenceType
GROUP BY BarberFName, BarberSName
ORDER BY INCIDENCES DESC;



/*ROTA*/


/* all staff who work wednesdays (barber 4 does not work on a wednesday)*/

SELECT BarberFName, BarberSName
FROM tRota
INNER JOIN tBarber
ON tRota.BarberID = tBarber.BarberID
WHERE Wednesday = 1;

/*all staff at work on Wednesday 10 apr 2019 (barber 2 is at court)*/

SELECT tRota.BarberID, BarberFName, BarberSName
FROM tRota
INNER JOIN tBarber
ON tRota.BarberID = tBarber.BarberID
WHERE Wednesday = 1 AND NOT tRota.BarberID IN (SELECT BarberID FROM tAbsence WHERE AbsenceDate = '2019-04-10');

/*same query but checking Sat 2 feb 2019 (barber 6 is sick and Che does not work saturdays)*/

SELECT tRota.BarberID, BarberFName, BarberSName
FROM tRota
INNER JOIN tBarber
ON tRota.BarberID = tBarber.BarberID
WHERE Saturday = 1 AND NOT tRota.BarberID IN (SELECT BarberID FROM tAbsence WHERE AbsenceDate = '2019-02-02');



/*ORDERS*/

/*all orders not to staff.  Staff are customers 21 to 26 inclusive.  (testing out using variables)*/

DECLARE @first integer, @last integer;
set @first = 21;
set @last = 26;

SELECT *
FROM tOrder
WHERE CustomerID NOT BETWEEN @first and @last;

/*same but grouped by customer*/

DECLARE @firstStaff integer, @lastStaff integer;
set @firstStaff = 21;
set @lastStaff = 26;

SELECT count(InvoiceNumber) AS NumberOfOrders, CustFName, CustSName
FROM tOrder
INNER JOIN tCustomer
ON tOrder.CustomerID = tCustomer.CustomerID
WHERE tOrder.CustomerID NOT BETWEEN @firstStaff and @lastStaff
GROUP BY CustFName, CustSName;

/*alternative way to remove barbers from results - check tel numb and email of each cust aren't in the barbers table*/

SELECT count(InvoiceNumber) AS NumberOfOrders, CustFName, CustSName
FROM tOrder
INNER JOIN tCustomer
ON tOrder.CustomerID = tCustomer.CustomerID
WHERE tCustomer.TelNumber NOT IN (Select TelNumber FROM tBarber)
AND tCustomer.eMail NOT IN (Select eMail FROM tBarber)
GROUP BY CustFName, CustSName;

/*Get only product sales that aren't a haircut*/

SELECT tOrder.InvoiceNumber, CustFName, CustSName, tProduct.ProductName, tProduct.Price
FROM tOrder
INNER JOIN tCustomer
ON tOrder.CustomerID = tCustomer.CustomerID
INNER JOIN tOrderLine
ON tOrder.InvoiceNumber = tOrderLine.InvoiceNumber
INNER JOIN tProduct
ON tOrderLine.Barcode = tProduct.Barcode
WHERE tCustomer.TelNumber NOT IN (Select TelNumber FROM tBarber)
AND tCustomer.eMail NOT IN (Select eMail FROM tBarber)
AND tOrderLine.Barcode NOT IN ('1','2','3','4','5','6','7','8')

/*total sales grouped by product*/

DECLARE @VAT MONEY;
set @VAT = 1.2;

DECLARE @VAT DECIMAL(18,2);
set @VAT = 1.20;

SELECT tOrderLine.Barcode, tProduct.ProductName, tProduct.Price AS PriceEach, Multiplier,  
SUM(Quantity) AS TotalQtySold, 
SUM (Quantity * Price * Multiplier) AS TotalSalesBeforeVAT, 
SUM (Quantity * Price * Multiplier * @VAT) AS TotalSalesIncludingVAT
FROM tOrderLine
INNER JOIN tProduct
ON tOrderLine.Barcode = tProduct.Barcode
INNER JOIN tMarkup
ON tProduct.MarkupID = tMarkup.MarkupID
GROUP BY tOrderLine.Barcode, tProduct.ProductName, tProduct.Price, Multiplier
ORDER BY tOrderLine.Barcode ASC;

/*total sales grouped by product (excluding the barber supplies that Che buys in for the barbers)*/

DECLARE @VAT DECIMAL(18,2);
set @VAT = 1.20;

SELECT tOrderLine.Barcode, tProduct.ProductName, tProduct.Price AS PriceEach, Multiplier,  
SUM(Quantity) AS TotalQtySold, 
SUM (Quantity * Price * Multiplier) AS TotalSalesBeforeVAT, 
SUM (Quantity * Price * Multiplier * @VAT) AS TotalSalesIncludingVAT
FROM tOrderLine
INNER JOIN tProduct
ON tOrderLine.Barcode = tProduct.Barcode
INNER JOIN tMarkup
ON tProduct.MarkupID = tMarkup.MarkupID
INNER JOIN tSupplier
ON tProduct.SupplierID = tSupplier.SupplierID
WHERE NOT tSupplier.SupplierName = 'Barber Blades'
GROUP BY tOrderLine.Barcode, tProduct.ProductName, tProduct.Price, Multiplier
ORDER BY tOrderLine.Barcode ASC;

/*total value for each order*/

DECLARE @VAT DECIMAL(18,2);
set @VAT = 1.20;

SELECT tOrder.InvoiceNumber, tOrder.OrderDate, tOrder.CustomerID, SUM(tOrderLine.Quantity * tProduct.Price * Multiplier * @VAT) AS OrderTotal
FROM tOrder
INNER JOIN tOrderLine
ON tOrder.InvoiceNumber = tOrderLine.InvoiceNumber
INNER JOIN tProduct
ON tOrderLine.Barcode = tProduct.Barcode
INNER JOIN tMarkup
ON tProduct.MarkupID = tMarkup.MarkupID
INNER JOIN tSupplier
ON tProduct.SupplierID = tSupplier.SupplierID
WHERE NOT tSupplier.SupplierName = 'Barber Blades'
GROUP BY tOrder.InvoiceNumber, tOrder.OrderDate, tOrder.CustomerID 

/*total earnings for each barber - note Che earns zero because all of his money goes into the till*/

DECLARE @VAT DECIMAL(18,2);
set @VAT = 1.20;

SELECT tOrder.BarberID, tBarber.BarberFName, tBarber.BarberSName, SUM(tOrderLine.Quantity * tProduct.Price * Multiplier * @VAT * TakingsRetained) AS TOTAL
FROM tOrder
INNER JOIN tCustomer
ON tOrder.CustomerID = tCustomer.CustomerID
INNER JOIN tOrderLine
ON tOrder.InvoiceNumber = tOrderLine.InvoiceNumber
INNER JOIN tProduct
ON tOrderLine.Barcode = tProduct.Barcode
INNER JOIN tMarkup
ON tProduct.MarkupID = tMarkup.MarkupID
INNER JOIN tBarber
ON tOrder.BarberID = tBarber.BarberID
INNER JOIN tTakingsRetained
ON tBarber.TakingsCode = tTakingsRetained.TakingsCode
WHERE tCustomer.TelNumber NOT IN (Select TelNumber FROM tBarber)
AND tCustomer.eMail NOT IN (Select eMail FROM tBarber)
AND tOrderLine.Barcode IN ('1','2','3','4','5','6','7','8')
GROUP BY tOrder.BarberID, tBarber.BarberFName, tBarber.BarberSName

/*same as above but include the number of cuts*/

DECLARE @VAT DECIMAL(18,2);
set @VAT = 1.20;

SELECT COUNT(tOrder.InvoiceNumber) AS CUTS, tOrder.BarberID, tBarber.BarberFName, tBarber.BarberSName, SUM(tOrderLine.Quantity * tProduct.Price * Multiplier * @VAT * TakingsRetained) AS TOTAL
FROM tOrder
INNER JOIN tCustomer
ON tOrder.CustomerID = tCustomer.CustomerID
INNER JOIN tOrderLine
ON tOrder.InvoiceNumber = tOrderLine.InvoiceNumber
INNER JOIN tProduct
ON tOrderLine.Barcode = tProduct.Barcode
INNER JOIN tMarkup
ON tProduct.MarkupID = tMarkup.MarkupID
INNER JOIN tBarber
ON tOrder.BarberID = tBarber.BarberID
INNER JOIN tTakingsRetained
ON tBarber.TakingsCode = tTakingsRetained.TakingsCode
WHERE tCustomer.TelNumber NOT IN (Select TelNumber FROM tBarber)
AND tCustomer.eMail NOT IN (Select eMail FROM tBarber)
AND tOrderLine.Barcode IN ('1','2','3','4','5','6','7','8')
GROUP BY tOrder.BarberID, tBarber.BarberFName, tBarber.BarberSName

/*--------------------------------------------------------------------------------------------------*/   
/*---------------------------------------- ASSESSED QUERIES ----------------------------------------*/
/*--------------------------------------------------------------------------------------------------*/

/*
	Query One - Current appointments with responsible barber and customer details
*/



SELECT 
CONCAT(tCustomer.CustFName, ' ', tCustomer.CustSName) AS Customer,
CONCAT(SUBSTRING(tCustomer.TelNumber, 1, 5), ' ', SUBSTRING(tCustomer.TelNumber, 6, 6)) AS 'Contact Number',
CONVERT(VARCHAR(11), AppointmentDateTime, 113) AS 'Appointment Date',
CONVERT(varchar(5), AppointmentDateTime, 108) AS 'Appointment Time',
CONCAT(tBarber.BarberFName, ' ', tBarber.BarberSName) AS Barber,
tProduct.ProductName as Style,
CONVERT(varchar(5), DATEADD(mi, tProduct.StyleTime, AppointmentDateTime), 108) AS 'Expected Finish Time'
FROM tAppointment
INNER JOIN tCustomer
ON tAppointment.CustomerID = tCustomer.CustomerID
INNER JOIN tBarber
ON tAppointment.BarberID = tBarber.BarberID
INNER JOIN tProduct
ON tAppointment.Barcode = tProduct.Barcode
WHERE AppointmentDateTime >= GETDATE()
ORDER BY AppointmentDateTime ASC


/*
	Query Two - Appointment rates by month/week over the past year per barber
*/

/*monthly*/

SELECT count(tOrder.InvoiceNumber) as 'Appointments',
DATEPART(mm,tOrder.OrderDate) as 'Month',
DATEPART(yy,tOrder.OrderDate) as 'Year',
CONCAT(tBarber.BarberFName, ' ', tBarber.BarberSName) AS 'Barber'
FROM tOrder
INNER JOIN tOrderLine
ON tOrder.InvoiceNumber = tOrderLine.InvoiceNumber
INNER JOIN tBarber
ON tOrder.BarberID = tBarber.BarberID
WHERE tOrderLine.Barcode IN ('1','2','3','4','5','6','7','8')
GROUP BY tBarber.BarberFName, tBarber.BarberSName, DATEPART(mm,tOrder.OrderDate), DATEPART(yy,tOrder.OrderDate)
ORDER BY tBarber.BarberSName ASC, tBarber.BarberFName ASC, DATEPART(yy,tOrder.OrderDate) ASC, DATEPART(mm,tOrder.OrderDate) ASC;

/*weekly*/

SELECT count(tOrder.InvoiceNumber) as 'Appointments',
DATEPART(ww,tOrder.OrderDate) as 'Week',
DATEPART(yy,tOrder.OrderDate) as 'Year',
CONCAT(tBarber.BarberFName, ' ', tBarber.BarberSName) AS 'Barber'
FROM tOrder
INNER JOIN tOrderLine
ON tOrder.InvoiceNumber = tOrderLine.InvoiceNumber
INNER JOIN tBarber
ON tOrder.BarberID = tBarber.BarberID
WHERE tOrderLine.Barcode IN ('1','2','3','4','5','6','7','8')
GROUP BY tBarber.BarberFName, tBarber.BarberSName, DATEPART(ww,tOrder.OrderDate), DATEPART(yy,tOrder.OrderDate)
ORDER BY tBarber.BarberSName ASC, tBarber.BarberFName ASC, DATEPART(yy,tOrder.OrderDate) ASC, DATEPART(ww,tOrder.OrderDate) ASC;

/*
	Query Three - Weekly/monthly income
*/

/*monthly*/

DECLARE @VAT DECIMAL(18,2);
set @VAT = 1.20;

SELECT count(tProduct.Barcode) as 'Order Lines',
SUM(tOrderLine.Quantity * tProduct.Price * tMarkup.Multiplier * @VAT) AS 'Monthly Income',
DATEPART(mm,tOrder.OrderDate) as 'Month',
DATEPART(yy,tOrder.OrderDate) as 'Year'
FROM tOrder
INNER JOIN tOrderLine
ON tOrder.InvoiceNumber = tOrderLine.InvoiceNumber
INNER JOIN tProduct
ON tOrderLine.Barcode = tProduct.Barcode
INNER JOIN tMarkup
ON tProduct.MarkupID = tMarkup.MarkupID
INNER JOIN tSupplier
ON tProduct.SupplierID = tSupplier.SupplierID
WHERE NOT tSupplier.SupplierName = 'Barber Blades'
GROUP BY DATEPART(mm,tOrder.OrderDate), DATEPART(yy,tOrder.OrderDate)
ORDER BY DATEPART(yy,tOrder.OrderDate) ASC, DATEPART(mm,tOrder.OrderDate) ASC;

/*manually check January*/

select (
	(
		(1 * 15.0) +
		(1 * 18.5) +
		(1 * 7.64 * 1.5) +
		(1 * 14.0) +
		(1 * 6.49 * 1.5) +
		(4 * 4.95 * 1.5) +
		(1 * 35.0) +
		(1 * 5.25 * 1.5) +
		(5 * 15.95 * 1.5) +
		(1 * 16.5)
	) * 1.2
) as jan2019

/*weekly*/

DECLARE @VAT DECIMAL(18,2);
set @VAT = 1.20;

SELECT count(tProduct.Barcode) as 'Order Lines',
SUM(tOrderLine.Quantity * tProduct.Price * tMarkup.Multiplier * @VAT) AS 'Weekly Income',
DATEPART(ww,tOrder.OrderDate) as 'Week',
DATEPART(yy,tOrder.OrderDate) as 'Year'
FROM tOrder
INNER JOIN tOrderLine
ON tOrder.InvoiceNumber = tOrderLine.InvoiceNumber
INNER JOIN tProduct
ON tOrderLine.Barcode = tProduct.Barcode
INNER JOIN tMarkup
ON tProduct.MarkupID = tMarkup.MarkupID
INNER JOIN tSupplier
ON tProduct.SupplierID = tSupplier.SupplierID
WHERE NOT tSupplier.SupplierName = 'Barber Blades'
GROUP BY DATEPART(ww,tOrder.OrderDate), DATEPART(yy,tOrder.OrderDate)
ORDER BY DATEPART(yy,tOrder.OrderDate) ASC, DATEPART(ww,tOrder.OrderDate) ASC;






