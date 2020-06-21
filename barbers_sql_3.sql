/* CREATE DATABASE baa_baa_barbers_v3; */

USE baa_baa_barbers_v3;

/************************************ BARBERS JOB TITLE ************************************/

/*CREATE*/

CREATE TABLE tJobTitle (
	JobTitleID INT NOT NULL,
	JobTitleDescription VARCHAR(30) NOT NULL,
	PRIMARY KEY (JobTitleID)
);

/*POPULATE*/

INSERT INTO tJobTitle (
	JobTitleID,
	JobTitleDescription
)
VALUES 
(1,'Owner'),
(2,'Senior Barber'),
(3,'Barber'),
(4,'Trainee');

/************************************ BARBERS TAKINGs ************************************/

/*CREATE*/

CREATE TABLE tTakingsRetained (
	TakingsCode INT NOT NULL,
	TakingsRetained FLOAT NOT NULL,
	PRIMARY KEY (TakingsCode)
);

INSERT INTO tTakingsRetained (
	TakingsCode,
	TakingsRetained
)
VALUES 
(1,0),
(2,0.8),
(3,0.6),
(4,0.4);
  

/************************************ BARBERS ************************************/

/*CREATE*/

CREATE TABLE tBarber (
	BarberID INT NOT NULL,
	BarberFName VARCHAR(30) NOT NULL,
	BarberSName VARCHAR(30) NOT NULL,
	JobTitleID INT NOT NULL,
	StartedBarbering DATE NOT NULL,
	WhereTrained VARCHAR(50) NOT NULL,
	Qualification VARCHAR(30) NOT NULL,
	TakingsCode INT NOT NULL,
	TelNumber VARCHAR(12) NOT NULL,
	eMail VARCHAR(50) NOT NULL,
	SystemPassword VARCHAR(20) NOT NULL,
	PRIMARY KEY (BarberID)
);

/*POPULATE*/

INSERT INTO tBarber (
	BarberID,
	BarberFName,
	BarberSName,
	JobTitleID,
	StartedBarbering,
	WhereTrained,
	Qualification,
	TakingsCode,
	TelNumber,
	eMail,
	SystemPassword
) 
VALUES 
(1,'Che','Smith',1,'2014-03-26','Hair for Men Barber Academy','NVQ Level 3',1,'07958123452','che@yahoo.com','loopy1'),
(2,'Jez','Wilkins',2,'2011-07-13','London School of Barbering','NVQ Level 3',3,'07456720425','jez@yahoo.com','banana1'),
(3,'Jules','Morris',2,'2013-11-01','Total Barber Academy','NVQ Level 3',3,'07425715948','jules@yahoo.com','password1'),
(4,'Si','di Marco',3,'2017-01-27','Napoli Barbieri Accademia','None',3,'07234512784','si@yahoo.com','scifi1'),
(5,'Winston','Smith',3,'2017-09-11','Carls Jamaican Barbers','None',3,'07215451245','winston@yahoo.com','gabbo1'),
(6,'Kate','Breakspear',3,'2017-10-23','Blind Barber','None',3,'07875652425','kate@yahoo.com','damocles1');

/************************************ ABSENCE TYPES ************************************/

/*CREATE*/

CREATE TABLE tAbsenceType (
	AbsenceType INT NOT NULL,
	AbsenceDescription VARCHAR(50) NOT NULL,
	PRIMARY KEY (AbsenceType)
);

/*POPULATE*/

INSERT INTO tAbsenceType (
	AbsenceType,
	AbsenceDescription
)
VALUES 
(1,'Holiday'),
(2,'Sick leave'),
(3,'Compassionate'),
(4,'Jury duty'),
(5,'Maternity/Paternity'),
(6,'Other');

/************************************ ABSENCES ************************************/

/*CREATE*/

CREATE TABLE tAbsence (
	AbsenceDate DATE NOT NULL,
	AbsenceType VARCHAR(30) NOT NULL,
	AbsenceReason VARCHAR(200) NOT NULL,
	BarberID INT NOT NULL,
	PRIMARY KEY (AbsenceDate, BarberID)
	/* FOREIGN KEY (BarberID) REFERENCES tBarber(BarberID) */
);

/*POPULATE*/

INSERT INTO tAbsence (
	AbsenceDate,
	AbsenceType, /*holiday or sickness*/
	AbsenceReason,
	BarberID
) 
VALUES 
('2019-01-10',1,'',2),
('2019-04-10',4,'Lewes Crown Court',2),
('2019-04-18',2,'Cold',2),
('2019-01-14',1,'',3),
('2019-02-13',2,'Pulled back getting into car',3),
('2019-02-21',1,'',4),
('2019-03-18',5,'Girlfriend gave birth',4),
('2019-03-19',2,'Flu',4),
('2019-03-22',1,'',4),
('2019-04-02',3,'Uncle died',4),
('2019-04-13',2,'Doctors appointment - personal issue',4),
('2019-01-07',4,'Jury at Chichester Crown Court',5),
('2019-01-23',2,'Twisted ankle',6),
('2019-02-02',2,'Impetigo',6),
('2019-04-13',1,'',6);

/************************************ APPOINTMENT CANCELLATIONS ************************************/

/*CREATE*/

CREATE TABLE tCancellation (
	CancellationType INT NOT NULL,
	CancellationReason VARCHAR(50) NOT NULL,
	PRIMARY KEY (CancellationType)
);

/*POPULATE*/

INSERT INTO tCancellation (
	CancellationType,
	CancellationReason
)
VALUES 
(1,'Customer cancelled'),
(2,'Barber cancelled'),
(3,'Che cancelled');

/************************************ ROTA ************************************/

/*CREATE*/

CREATE TABLE tRota (
	BarberID INT NOT NULL,
	Monday INT NOT NULL,
	Tuesday INT NOT NULL,
	Wednesday INT NOT NULL,
	Thursday INT NOT NULL,
	Friday INT NOT NULL,
	Saturday INT NOT NULL,
	Sunday INT NOT NULL,
	PRIMARY KEY (BarberID)
	/* FOREIGN KEY (BarberID) REFERENCES tBarber(BarberID) */
);

/*POPULATE*/

INSERT INTO tRota (
	BarberID,
	Monday,
	Tuesday,
	Wednesday,
	Thursday,
	Friday,
	Saturday,
	Sunday
)
VALUES 
(1,1,1,1,1,1,0,0),
(2,0,1,1,1,1,1,0),
(3,1,0,1,1,1,1,0),
(4,1,1,0,1,1,1,0),
(5,1,1,1,0,1,1,0),
(6,1,1,1,1,0,1,0);

/************************************ ADDRESS ************************************/

/*CREATE*/

CREATE TABLE tAddress (
	Postcode VARCHAR(8) NOT NULL,
	Street VARCHAR(30) NOT NULL,
	Town VARCHAR(30) NOT NULL,
	County VARCHAR(20) NOT NULL,
	PRIMARY KEY (Postcode)
);

/*POPULATE*/

INSERT INTO tAddress (
	Postcode,
	Street,
	Town,
	County
)
VALUES
/*baa baa black sheep*/
('BN1 4ED','Grand Parade','Brighton','East Sussex'),
/*customer*/
('BN12 4AU','Elm Grove','Brighton','East Sussex'),
('BN21 6TF','Post Road','Brighton','East Sussex'),
('BN21 7TG','Post Road','Brighton','East Sussex'),
('BN65 6HB','Fake Street','Brighton','East Sussex'),
('BN8 1GC','Baron Close','Brighton','East Sussex'),
('BN15 3XX','Video Road','Southwick','East Sussex'),
('BN32 7GG','Avenger Mews','Hove','East Sussex'),
('BN83 8HH','Mystery Lane','Hove','East Sussex'),
('BN32 7GH','Penny Lane','Lancing','East Sussex'),
('BN32 7HD','Abbey Road','Lancing','East Sussex'),
/*supplier*/
('CW3 9DQ','Bowsey Wood Farm','Betley','Crewe'),
('CF10 4LJ','Luigi Road','Clos Marion','Cardiff');

/************************************ MARKUP ************************************/

/*CREATE*/

CREATE TABLE tMarkup (
	MarkupID INT NOT NULL,
	Multiplier FLOAT NOT NULL,
	PRIMARY KEY (MarkupID)
);

/*POPULATE*/

INSERT INTO tMarkup (
	MarkupID,
	Multiplier
)
VALUES
(1,1),
(2,1.5);

/************************************ CUSTOMER ************************************/

/*CREATE*/

CREATE TABLE tCustomer (
	CustomerID INT NOT NULL,
	CustFName VARCHAR(30) NOT NULL,
	CustSName VARCHAR(30) NOT NULL,
	TelNumber VARCHAR(12) NOT NULL,
	eMail VARCHAR(50) NOT NULL,
	DOB DATE NOT NULL,
	Password VARCHAR(30) NOT NULL,
	Student  INT NOT NULL,
	Postcode VARCHAR(8) NOT NULL,
	PRIMARY KEY (CustomerID)
	/* FOREIGN KEY (Postcode) REFERENCES tAddress(Postcode) */
);

/*POPULATE*/

INSERT INTO tCustomer (
	CustomerID,
	CustFName,
	CustSName,
	TelNumber,
	eMail,
	DOB,
	Password,
	Student,
	Postcode
)
VALUES
/*oaps - 65+ years*/
(1,'Paul','Smith','01273555845','paul@bt.com','1944-11-22','paul1',0,'BN21 6TF'),
(2,'Dave','Matthews','01273987654','fobby@bt.com','1950-06-12','dave1',0,'BN65 6HB'),
(3,'John','Mc Plomb','07985421457','musta@bt.com','1946-03-03','john1',0,'BN8 1GC'),
/*regulars*/
(4,'Norm','Cheers','07845124574','normo@bt.com','1965-03-24','norm1',0,'BN15 3XX'),
(5,'Jules','Verne','07962531597','julian@bt.com','1977-05-21','jules1',0,'BN21 7TG'),
(6,'Peter','Pecker','07985154278','peterp@bt.com','1980-12-12','peter1',0,'BN21 6TF'),
(7,'Steve','Sutch','07952648264','screaminglord@bt.com','2003-05-04','steve1',0,'BN32 7GG'),
(8,'John','McBland','07945127437','fanta@bt.com','2001-06-11','john1',0,'BN83 8HH'),
(9,'Quentin','Qwerty','07256245375','tobry@bt.com','1995-01-17','quentin1',0,'BN32 7GH'),
/*family - oap and his grandkids*/
(10,'Roger','Pants','07523421571','roger1@bt.com','1947-08-07','roger1',0,'BN12 4AU'),
(11,'Paul','Pants','07523421571','roger1@bt.com','2010-02-03','paul1',0,'BN12 4AU'),
(12,'John','Pants','07523421571','roger1@bt.com','2011-06-02','john1',0,'BN12 4AU'),
/*children - less than 11 years*/
(13,'Ian','Smith','07542316274','ianian@bt.com','2015-09-15','ian1',0,'BN8 1GC'),
(14,'Ian','Jenkins','07642891542','batman4@bt.com','2014-05-12','ian1',0,'BN21 7TG'),
(15,'Apu','Kristenshan','07248574316','apu78@bt.com','2013-08-11','apu1',0,'BN83 8HH'),
(16,'Irfan','Hassan','07542642875','irfie@bt.com','2011-04-04','irfan1',0,'BN32 7GH'),
/*students*/
(17,'Brian','Singer','07345275145','theonlybrian23@bt.com','1998-10-11','brian1',1,'BN83 8HH'),
(18,'Bryan','Trumpet','07345215724','theotherbryan23@bt.com','1999-02-01','bryan1',1,'BN12 4AU'),
(19,'Trevor','Sierra','07653425754','trevrules@bt.com','2003-12-14','trevor1',1,'BN65 6HB'),
(20,'Paul','Nova','07653425754','newstar@bt.com','2005-04-05','paul1',1,'BN32 7GG'),
/*barbers - added to customers because they can order supplies - not happy with this as duplicating info from barbers table*/
(21,'Che','Smith','07958123452','che@yahoo.com','1981-12-15','password1',0,'BN1 4ED'),
(22,'Jez','Wilkins','07456720425','jez@yahoo.com','1985-06-02','password1',0,'BN1 4ED'),
(23,'Jules','Morris','07425715948','jules@yahoo.com','1987-09-23','password1',0,'BN1 4ED'),
(24,'Si','di Marco','07234512784','si@yahoo.com','1998-12-30','password1',0,'BN1 4ED'),
(25,'Winston','Smith','07215451245','winston@yahoo.com','1997-03-05','password1',0,'BN1 4ED'),
(26,'Kate','Breakspear','07875652425','kate@yahoo.com','2001-12-15','password1',0,'BN1 4ED');


/************************************ SUPPLIER ************************************/

/*CREATE*/

CREATE TABLE tSupplier (
	SupplierID INT NOT NULL,
	Name VARCHAR(70) NOT NULL,
	AddressLine1 VARCHAR(30) NOT NULL,
	Phone VARCHAR(12) NOT NULL,
	eMail VARCHAR(50) NOT NULL,
	ContactPerson VARCHAR(30) NOT NULL,
	Website VARCHAR(50) NOT NULL,
	Postcode VARCHAR(8) NOT NULL,
	PRIMARY KEY (SupplierID)
	/* FOREIGN KEY (Postcode) REFERENCES tAddress(Postcode) */
);

/*POPULATE*/

INSERT INTO tSupplier (
	SupplierID,
	Name,
	AddressLine1,
	Phone,
	eMail,
	ContactPerson,
	Website,
	Postcode
)
VALUES
(1,'Baa Baa Black Sheep Barbers Shop','22','01273 85258','BaaBaa@BlackSheep.co.uk','Che Smith','www.BaaBaaBlackSheep.co.uk','BN1 4ED'),  /*use the business details for this dummy supplier*/
(2,'Barbers Shaving & Styling Products','Mill House','01270 630280','dss@yahoo.com','Karen Hughes','www.directsalonsupplies.co.uk','CW3 9DQ'),
(3,'Barber Blades','Unit 3 Charnwood Park','0800 6440234','barberblades@yahoo.com','Paul Humphries','www.barberblades.co.uk','CF10 4LJ');

/************************************ ORDER (CUSTOMER) ************************************/

/*CREATE*/

CREATE TABLE tOrder (
	InvoiceNumber INT NOT NULL,
	OrderDate DATE NOT NULL,
	Paid INT NOT NULL,
	CustomerID INT NOT NULL,
	BarberID INT NOT NULL,
	PRIMARY KEY (InvoiceNumber)
	/* FOREIGN KEY (CustomerID) REFERENCES tCustomer(CustomerID)
	FOREIGN KEY (BarberID) REFERENCES tBarber(BarberID) */
);

/*POPULATE*/

INSERT INTO tOrder (
	InvoiceNumber,
	OrderDate,
	Paid,
	CustomerID, /*1 - 26*/
	BarberID /*1 - 6*/
)

VALUES
/*oaps  mon - thurs*/
(1,'2019-02-06',1,1,3),
(2,'2019-02-27',1,1,6),
(3,'2019-03-13',0,1,2),
(4,'2019-01-21',1,2,1),
(5,'2019-03-14',1,2,4),
(6,'2019-04-11',1,3,2),
/*regulars*/
(7,'2019-01-07',1,4,3),
(8,'2019-02-23',1,4,5),
(9,'2019-03-20',1,4,5),
(10,'2019-01-16',1,5,2),
(11,'2019-02-15',1,5,5),
(12,'2019-03-13',1,5,5),
(13,'2019-04-10',0,5,1),
(14,'2019-01-11',1,6,4),
(15,'2019-03-15',1,6,4),
(16,'2019-02-20',1,7,6),
(17,'2019-02-26',1,8,6),
(18,'2019-03-12',1,9,6),
/*family*/
(19,'2019-02-05',1,10,4),
(20,'2019-04-17',1,10,1),
(21,'2019-02-05',1,11,5),
(22,'2019-04-17',1,11,2),
(23,'2019-02-05',1,12,6),
(24,'2019-04-17',1,12,3),
/*children*/
(25,'2019-02-11',1,13,5),
(26,'2019-03-11',1,15,3),
/*students mon - weds*/
(27,'2019-01-23',1,17,5),
(28,'2019-04-24',1,17,2),
(29,'2019-02-19',1,18,4),
(30,'2019-03-12',0,19,2),
(31,'2019-02-11',1,20,5),
(32,'2019-04-29',1,20,6),
/*barbers orders for clippers etc*/
(33,'2019-01-05',1,22,1),
(34,'2019-02-16',1,23,1),
(35,'2019-03-09',1,24,1),
(36,'2019-04-13',1,25,1);

/************************************ PURCHASE ORDER (FROM SUPPLIER)************************************/

/*CREATE*/

CREATE TABLE tPurchaseOrder (
	PurchaseNumber INT NOT NULL,
	PurchaseDate DATE NOT NULL,
	SupplierID INT NOT NULL,
	PRIMARY KEY (PurchaseNumber)
	/* FOREIGN KEY (SupplierID) REFERENCES tSupplier(SupplierID) */
);

/*POPULATE*/

INSERT INTO tPurchaseOrder (
	PurchaseNumber,
	PurchaseDate,
	SupplierID
)
VALUES
/*customer products*/
(1,'2019-01-14',2),
(2,'2019-01-28',2),
(3,'2019-02-18',2),
(4,'2019-02-25',2),
(5,'2019-03-11',2),
(6,'2019-03-25',2),
(7,'2019-04-15',2),
(8,'2019-04-29',2),
/*staff products*/
(9,'2019-01-07',3),
(10,'2019-02-18',3),
(11,'2019-03-11',3),
(12,'2019-04-15',3);



/************************************ PRODUCT ************************************/

/*CREATE*/

CREATE TABLE tProduct (
	Barcode VARCHAR(30) NOT NULL, /*because barcodes can start with 0*/
	Name VARCHAR(50) NOT NULL,
	Description VARCHAR(500) NOT NULL,
	Price FLOAT NOT NULL,
	StockLevel INT NOT NULL,
	StyleTime INT NOT NULL,
	ReorderPoint INT NOT NULL,
	SupplierID INT NOT NULL,
	MarkupID INT NOT NULL,
	PRIMARY KEY (Barcode)
	/* FOREIGN KEY (SupplierID) REFERENCES tSupplier(SupplierID),
	FOREIGN KEY (MarkupID) REFERENCES tMarkup(MarkupID) */
);

/*POPULATE*/

INSERT INTO tProduct (
	Barcode,
	Name,
	Description,
	Price,
	StockLevel,
	StyleTime,
	ReorderPoint,
	SupplierID,
	MarkupID
)
VALUES
/*add styles as products*/
('1','Haircut','',18.5,99999,30,0,1,1),
('2','Haircut & Beard Trim','',27.5,99999,45,0,1,1),
('3','Wet Shave','',35.0,99999,15,0,1,1),
('4','Childs cut','(10 and under)',15.0,99999,15,0,1,1),
('5','Crew Cut','',14.0,99999,15,0,1,1),
('6','OAP cut','(Mon - Thurs)',15.0,99999,30,0,1,1),
('7','Beard Trim','',10.0,99999,15,0,1,1),
('8','Student special','(Mon - Weds)',16.5,99999,30,0,1,1),
/*additional products*/
('05103214547','FUDGE Structure Wax 75g','Fudge structure is a heavy duty styling wax, with a hold factor of 11. Ideal for creating texture and definition. Its formulation makes moulding the hair effortless, holding style for longer and leaving a polished semi-shiny finish.',7.64,100,0,12,2,2),
('04564454656','Armargans Men’s Hair and Body Wash','All in one hair and body wash designed to both cleanse and moisturise. Infused with Argan Oil which will help to soften and moisturise your hair and body leaving both feeling refreshed and healthy. 500ml.',5.25,80,0,12,2,2),
('07875278258','Amargan Beard Oil 50ml','Keep your beard looking and feeling great with this daily use beard oil and skin conditioner. Rich in vitamin E, the unique blend of oils softens and moisturises your beard. It’s soothing action helps reduce that dry, itchy feeling without leaving any oily residue.',6.49,200,0,12,2,2),
('01274275275','Amargan Control Cream 100ml','Amargan Matt Finish 100ml, great styling product with argan oil which gives super hold. Keep your style in place for the whole day with maintained texture and high definition.',4.95,11,0,12,2,2),
('07427278822','Jack Dean Travel Kit','Fantastic 3 piece travel kit with a FREE Jack Dean wash bag that has a luxury soft touch finish and opens out with an integrated hanger.American Bay Rum Body Wash 250ml Conditioning Shampoo 250ml - Matt Styling Paste 100g - for sculpting shapes and creating bold styles.',15.95,10,0,12,2,2),
/*barber supplies*/
('01575778221','Wahl 5 star cordless clippers','Creates a smoother cut all round including blending and skin-tight fading.',110.0,0,0,-1,3,1),
('01752782782','Haito Akuma 15cm Barbers Scissors','Professional barbering scissor handmade from hardened steel with a Black Teflon coated body, Red Teflon coated inner blade and red poly nut screw system with built-in ball-bearing.',53.0,0,0,-1,3,1),
('07857827278','Babyliss Duo clipper set - Professional Edition','Limited edition duo set featuring the new Super Motor Cordless Clipper and Trimmer in a stylish black chrome finish wih dual charging stand for ultimate convenience.',215.0,0,0,-1,3,1);


/************************************ ORDERLINE ************************************/

/*CREATE*/

CREATE TABLE tOrderLine (
	Quantity INT NOT NULL,
	InvoiceNumber INT NOT NULL,
	Barcode VARCHAR(30) NOT NULL, /*because barcodes can start with 0*/
	PRIMARY KEY (InvoiceNumber, Barcode)
	/* FOREIGN KEY (InvoiceNumber) REFERENCES tOrder(InvoiceNumber),
	FOREIGN KEY (Barcode) REFERENCES tProduct(Barcode) */
);

/*POPULATE*/

INSERT INTO tOrderLine (
	Quantity,
	InvoiceNumber,
	Barcode
)

VALUES
/*oaps:  orders 1 - 6*/
(1,1,'6'),
(1,2,'6'),
(1,3,'6'),
(1,4,'6'),
(1,5,'6'),
(1,6,'6'),
/*regulars:  orders 7 - 18*/
(1,7,'1'),
(1,7,'05103214547'),
(1,8,'2'),
(1,9,'3'),
(2,9,'04564454656'),
(1,10,'5'),
(1,10,'07875278258'),
(4,10,'01274275275'),
(1,11,'7'),
(1,12,'1'),
(1,13,'2'),
(2,13,'07875278258'),
(1,13,'05103214547'),
(1,14,'3'),
(1,14,'04564454656'),
(5,14,'07427278822'),
(1,15,'5'),
(1,15,'05103214547'),
(1,16,'7'),
(1,17,'1'),
(1,18,'2'),
/*family:  orders 19 - 24*/
(1,19,'6'),
(1,20,'6'),
(2,20,'07875278258'),
(1,21,'4'),
(1,22,'4'),
(1,23,'4'),
(1,24,'4'),
/*children:  orders 25 - 26*/
(1,25,'4'),
(1,26,'4'),
/*students:  orders 27 - 32*/
(1,27,'8'),
(1,28,'8'),
(1,29,'8'),
(1,30,'8'),
(1,31,'8'),
(1,32,'8'),
(1,32,'07875278258'),
(2,32,'05103214547'),
/*barbers:  orders 33 - 36*/
(1,33,'01575778221'),
(1,34,'01752782782'),
(1,35,'07857827278'),
(1,36,'01575778221'),
(1,36,'01752782782');

/************************************ APPOINTMENT ************************************/

/*CREATE*/

CREATE TABLE tAppointment (
	AppointmentID INT NOT NULL,
	AppointmentDateTime DATE NOT NULL,
	Cancelled INT NOT NULL,
	BarberID INT NOT NULL,
	Barcode VARCHAR(30) NOT NULL,
	CustomerID INT NOT NULL,
	CancellationType INT NOT NULL,
	PRIMARY KEY (AppointmentID)
	/* FOREIGN KEY (BarberID) REFERENCES tBarber(BarberID),
	FOREIGN KEY (Barcode) REFERENCES tProduct(Barcode),
	FOREIGN KEY (CustomerID) REFERENCES tCustomer(CustomerID),
	FOREIGN KEY (CancellationType) REFERENCES tCancellation(CancellationType) */
);

/*POPULATE*/

INSERT INTO tAppointment (
	AppointmentID,
	AppointmentDateTime,
	Cancelled,
	BarberID,
	Barcode,
	CustomerID,
	CancellationType
)

VALUES

(1,'2019-05-07 09:00:00.000',0,1,'6',1,1),
(2,'2019-05-16 16:30:00.000',0,3,'2',5,1),
(3,'2019-05-23 14:00:00.000',0,1,'5',8,1),
(4,'2019-05-10 09:00:00.000',0,4,'7',4,1),
(5,'2019-05-15 11:45:00.000',0,3,'4',13,1),
(6,'2019-05-14 15:00:00.000',1,2,'5',9,3), /*cancelled by Che for loutish behaviour!*/ 
(7,'2019-05-25 09:00:00.000',0,6,'1',7,1),
(8,'2019-05-25 10:00:00.000',0,6,'3',6,1),
(9,'2019-06-03 09:00:00.000',0,4,'6',2,1),
(10,'2019-06-03 09:00:00.000',0,3,'8',18,1);

/************************************ STYLE AVAILABILITY ************************************/

/*CREATE*/

CREATE TABLE tStyleAvailability (
	Barcode VARCHAR(30) NOT NULL, /*because barcodes can start with 0*/
	Monday INT NOT NULL,
	Tuesday INT NOT NULL,
	Wednesday INT NOT NULL,
	Thursday INT NOT NULL,
	Friday INT NOT NULL,
	Saturday INT NOT NULL,
	Sunday INT NOT NULL,
	PRIMARY KEY (Barcode)
	/* FOREIGN KEY (Barcode) REFERENCES tProduct(Barcode) */
);

/*POPULATE*/

INSERT INTO tStyleAvailability (
	Barcode,
	Monday,
	Tuesday,
	Wednesday,
	Thursday,
	Friday,
	Saturday,
	Sunday
)
VALUES 
('1',1,1,1,1,1,1,0),
('2',1,1,1,1,1,1,0),
('3',1,1,1,1,1,1,0),
('4',1,1,1,1,1,1,0),
('5',1,1,1,1,1,1,0),
('6',1,1,1,1,0,0,0),
('7',1,1,1,1,1,1,0),
('8',1,1,1,0,0,0,0);

/************************************ PURCHASE ORDER LINE************************************/

/*CREATE*/

CREATE TABLE tPurchaseLine (
	Quantity INT CHECK (Quantity > 0 AND (Quantity % 12 = 0 OR Quantity = 1)), /*multiples of 12 only - need to make this work only for supplier 2*/
	PurchaseNumber INT NOT NULL,
	Barcode VARCHAR(30) NOT NULL,
	PRIMARY KEY (PurchaseNumber, Barcode)
	/* FOREIGN KEY (PurchaseNumber) REFERENCES tPurchaseOrder(PurchaseNumber),
	FOREIGN KEY (Barcode) REFERENCES tProduct(Barcode) */
);

/*POPULATE*/

INSERT INTO tPurchaseLine (
	Quantity,
	PurchaseNumber,
	Barcode
)

VALUES
/*order 1*/
(24,1,'05103214547'),
(12,1,'07427278822'),
(60,1,'07875278258'),
(12,1,'04564454656'),
/*order 2*/
(12,2,'05103214547'),
(12,2,'01274275275'),
/*order 3*/
(48,3,'04564454656'),
/*order 4*/
(12,4,'05103214547'),
(60,4,'07427278822'),
(24,4,'07875278258'),
/*order 5*/
(24,5,'07875278258'),
/*order 6*/
(12,6,'05103214547'),
(12,6,'07427278822'),
(60,6,'01274275275'),
(12,6,'04564454656'),
/*order 7*/
(24,7,'04564454656'),
(12,7,'01274275275'),
/*order 8*/
(60,8,'04564454656'),
(60,8,'01274275275'),
/*order 9*/
(1,9,'01575778221'),
/*order 10*/
(1,10,'01752782782'),
/*order 11*/
(1,11,'01575778221'),
/*order 12*/
(1,12,'07857827278');















