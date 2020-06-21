use sars_3
go

set nocount on
go

----------------------------------------------------
--------------  T E M P  T A B L E S  --------------
----------------------------------------------------

/*
	These tables use data from CSV files to generate
	names of adopters & staff, and names & breeds for 
	animals

	They are deleted at the end of the creation process
	once they serve no further purpose
*/

/*
	Create and populate temp table of first names
*/

-- C r e a t e  T a b l e --

create table temp_fname (
  f_name varchar(255)
)
go

-- P o p u l a t e --

bulk insert temp_fname
from 'G:\university\year2\databases\project\csv\names_f.csv'
with (
	firstrow = 2,
	fieldterminator = ',',
	rowterminator = '\n',
	tablock
)
go

update temp_fname set f_name = trim(f_name)

/*
	Create and populate temp table of surnames
*/

-- C r e a t e  T a b l e --

create table temp_sname (
  s_name varchar(255)
);
go

-- P o p u l a t e --

bulk insert temp_sname
from 'G:\university\year2\databases\project\csv\names_s.csv'
with (
	firstrow = 2,
	fieldterminator = ',',
	rowterminator = '\n',
	tablock
)
go

update temp_sname set s_name = trim(s_name)

/*
	Create and populate temp table of pet names
*/

-- C r e a t e  T a b l e --

create table temp_petname (
  p_name varchar(255)
)
go

-- P o p u l a t e --

bulk insert temp_petname
from 'G:\university\year2\databases\project\csv\names_pet.csv'
with (
	firstrow = 2,
	fieldterminator = ',',
	rowterminator = '\n',
	tablock
)
go

/*
	Create and populate temp table of dog breeds
*/

-- C r e a t e  T a b l e --

create table temp_breed_dog (
  name varchar(255)
)
go

-- P o p u l a t e --

bulk insert temp_breed_dog
from 'G:\university\year2\databases\project\csv\breed_dog.csv'
with (
	firstrow = 2,
	fieldterminator = ',',
	rowterminator = '\n',
	tablock
)
go

/*
	Create and populate temp table of cat breeds
*/

-- C r e a t e  T a b l e --

create table temp_breed_cat (
  name varchar(255)
)
go

-- P o p u l a t e --

bulk insert temp_breed_cat
from 'G:\university\year2\databases\project\csv\breed_cat.csv'
with (
	firstrow = 2,
	fieldterminator = ',',
	rowterminator = '\n',
	tablock
)
go

/*
	Create and populate temp table of bird species
*/

-- C r e a t e  T a b l e --

create table temp_breed_bird (
  name varchar(255)
)
go

-- P o p u l a t e --

bulk insert temp_breed_bird
from 'G:\university\year2\databases\project\csv\breed_bird.csv'
with (
	firstrow = 2,
	fieldterminator = ',',
	rowterminator = '\n',
	tablock
)
go

/*
	Create and populate temp table of exotic species
*/

-- C r e a t e  T a b l e --

create table temp_breed_exotic (
  name varchar(255)
)
go

-- P o p u l a t e --

bulk insert temp_breed_exotic
from 'G:\university\year2\databases\project\csv\breed_exotic.csv'
with (
	firstrow = 2,
	fieldterminator = ',',
	rowterminator = '\n',
	tablock
)
go

----------------------------------------------------
-----------------  P O S T C O D E  ----------------
----------------------------------------------------

/*
	The postcode table is used to generate postcodes & road names
	for adopters, staff and the shelters.  This allows adopters & staff to 
	have multiple addresses (maybe someone adopts a working dog to their farm
	but also adopts a cat to their town house). 
	Note:  The postcodes imported are real postcodes and have an associated
	latitude and longitude.  I wanted to use geolocation so that adopters
	could be registered at their local shelter, rather than being registered to 
	a shelter in another part of sussex (and the associated travel problems
	involved)

	In reality, this database would be linked to the Royal Mail national 
	database to provide postcodes, but this one provides accurate 
	information for these purposes
*/

-- C r e a t e  T a b l e --

create table t_postcode(
	postcode varchar(9) not null,
	first_line varchar(50) not null,
	town varchar(30) not null,
	latitude float not null,
	longitude float not null,
	primary key (postcode)
)

/*
	Create index for first line of address 
	(Common way of searching for addresses if postcode not known)
*/

create index IX_t_postcode_first_line
    on t_postcode (first_line asc)
	with fillfactor = 70

go

-- P o p u l a t e --

bulk insert t_postcode
from 'G:\university\year2\databases\project\csv\postcodes.csv'
with (
	firstrow = 2,
	fieldterminator = ',',
	rowterminator = '\n',
	tablock
)
go

update t_postcode set postcode = trim(postcode),
	first_line = trim(first_line),
	town = trim(town)

---------------------------------------------
--------------  S H E L T E R  --------------
---------------------------------------------

/*
	This table generates shelter details
	Note: the postcode is a foreign key which
	allows us to geo-locate where the shelter is in the
	physical world
*/

-- C r e a t e  T a b l e --

create table t_shelter (
	shelter_id tinyint not null,
	shelter_name varchar(30) not null,
	building_number_name varchar(20) not null,
	postcode varchar(9), --added 'not null' below to allow picking at random
	primary key (shelter_id),
	foreign key (postcode) references t_postcode(postcode)
)

/*
	Create index by shelter name
*/

create index IX_t_shelter_shelter_name
    on t_shelter (shelter_name asc)
	with fillfactor = 70
	
-- P o p u l a t e --

insert into t_shelter(
	shelter_id,
	shelter_name,
	building_number_name
)
values 
	(1,'Shelter 1','1'),
	(2,'Shelter 2','2'),
	(3,'Shelter 3','3'),
	(4,'Shelter 4','4'),
	(5,'Shelter 5','5')
go

-- now insert values from t_postcode at random

with destination as (
	select
		row_number() over (order by newid()) as n,
		postcode
	from t_shelter
),
origin as (
	select
		row_number() over (order by newid()) as n,
		postcode
	from t_postcode
)
update destination
set postcode = (
	select postcode 
	from origin
	where (destination.n % (select count(*) from origin)) + 1 = origin.n
	--must mod the results using the other tables size 
	--(add one because modulus returns 0 to n(-1) - we need 1 - n)
)
go

/*
	Now the postcodes are added, we alter the 
	postcode field to be mandatory for the shelters

	Note: I did not add a filter for postcode format, 
	because the UK format varies so wildly:
	For example:
	BN18 0JA - valid
	BN1 3RL - valid
	E2 0AN - valid

	https://ideal-postcodes.co.uk/guides/uk-postcode-format
*/

alter table t_shelter
alter column postcode varchar(9) not null

---------------------------------------------
--------------  J O B  T Y P E  -------------
---------------------------------------------

/*
	This lookup table stores the job title and hourly
	rate for employees
*/

-- C r e a t e  T a b l e --

create table t_job_type (
	job_code tinyint not null,
	job_title varchar(20) not null,
	job_hourly_rate money check (job_hourly_rate >= 0),
	primary key (job_code)
)

/*
	Create index for job titles
*/

create index IX_t_job_type_job_title
    on t_job_type (job_title asc)
	with fillfactor = 70
	
-- P o p u l a t e --

insert into t_job_type (
	job_code,
	job_title,
	job_hourly_rate
)
values 
	(1,'General Manager',25.82),
	(2,'Assistant Manager',18.50),
	(3,'Line Manager',15.75),
	(4,'Regular',10.62),
	(5,'Volunteer',0)

---------------------------------------------
----------B U I L D I N G  T Y P E ----------
---------------------------------------------

/*
	This lookup table enumerates the four building 
	types considered by The Shelter
*/

-- C r e a t e  T a b l e --

create table t_building_type (
  building_id tinyint not null,
  building_type varchar(8) not null,
  primary key (building_id)
)

/*
	Create index for building types
*/

create index IX_t_building_type_building_type
    on t_building_type (building_type asc)
	with fillfactor = 70
	
-- P o p u l a t e --

insert into t_building_type (
	building_id,
	building_type
)
values 
	(1,'House'),
	(2,'Flat'),
	(3,'Bungalow'),
	(4,'Other')

---------------------------------------------
--------------  P E T  T Y P E  -------------
---------------------------------------------

/*
	This lookup table enumerates the different 
	animal types cared for by the shelters
*/

-- C r e a t e  T a b l e --

create table t_pet_type (
  pet_code tinyint not null,
  pet_type varchar(5) not null,
  primary key (pet_code)
)

/*
	Create index for animal names
*/

create index IX_t_pet_type_pet_type
    on t_pet_type (pet_type asc)
	with fillfactor = 70
	
-- P o p u l a t e --

insert into t_pet_type (
	pet_code,
	pet_type
)
values 
	(1,'Cat'),
	(2,'Dog'),
	(3,'Bird'),
	(4,'Other')

---------------------------------------------
---------  S T A F F  M E M B E R  ----------
---------------------------------------------

/*
	This table contains all details for staff
	and is used by the background check tables
	and also the shelter prosecution table

	Note:  The format and information about NI numbers is taken
	from here:
	https://www.gov.uk/hmrc-internal-manuals/national-insurance-manual/nim39110

*/

-- C r e a t e  T a b l e --

create table t_staff_member (
	staff_id int not null,
	staff_f_name varchar(30) check (
		len(staff_f_name) > 0
	),
	staff_s_name varchar(30) check (
		len(staff_s_name) > 0
	),
	shelter_id tinyint not null,
	job_code tinyint not null,
	staff_dob date check( 
		staff_dob < getdate()
	),
	staff_hire_date date,
	staff_leaving_date date,
	staff_manager tinyint,
	staff_hours float,
	staff_ni_number varchar(9) check (
		substring(staff_ni_number,1,2) like '[A-Za-z]%'
		and substring(staff_ni_number,3,6) like '[0-9]%'
		and substring(staff_ni_number,9,1) like '[A-Da-d]%'
	),
	primary key (staff_id),
	foreign key (shelter_id) references t_shelter(shelter_id),
	foreign key (job_code) references t_job_type(job_code)
)

/*
	Create index to search by staff surnames
*/

create index IX_t_staff_member_staff_s_name
    on t_staff_member (staff_s_name asc)
	with fillfactor = 70

/*
	Create index to search by NI number
*/

create index IX_t_staff_member_staff_ni_number
    on t_staff_member (staff_ni_number asc)
	with fillfactor = 70

-- P o p u l a t e --

/*
	Run a while loop to generate data and insert
	staff members
*/

declare @count int = 0
declare @shelter_count int = (select count(*) from t_shelter)
declare @date date = '1970-01-01'
while @count <101 begin
	set @count = @count + 1;
	-- generate job code (in sequence)
	declare @job_code tinyint = case
		when @count < 1 + @shelter_count then 1
		when @count < 1 + (2 * @shelter_count) then 2
		when @count < 1 + (6 * @shelter_count) then 3
		when @count < 1 + (15 * @shelter_count) then 4
		else 5
	end
	-- gen shelter ID for staff member
	declare @shelter_id tinyint = 1 + ((@count - 1) % @shelter_count)
	-- gen NI number
	declare @nino varchar(9) = ''
	declare @alphapool varchar(50) = 'QWERTYUIOPASDFGHJKLZXCVBNM'
	declare @alphapool_len int = len(@alphapool)
	declare @numberpool varchar(50) = '1234567890'
	declare @numberpool_len int = len(@numberpool)
	declare @suffixpool varchar(50) = 'ABCD'
	declare @suffixpool_len int = len(@suffixpool)
	declare @nino_loop_count int = 0
	--two leading letters
	while @nino_loop_count < 2 begin
		set @nino_loop_count = @nino_loop_count + 1
		set @nino = @nino + substring(@alphapool, convert(int, (rand() * (@alphapool_len - 1)) + 1), 1)
	end
	--six middle numbers
	set @nino_loop_count = 0
	while @nino_loop_count < 6 begin
		set @nino_loop_count = @nino_loop_count + 1
		set @nino = @nino + substring(@numberpool, convert(int, (rand() * (@numberpool_len - 1)) + 1), 1)
	end
	--suffix
	set @nino = @nino + substring(@suffixpool, convert(int, (rand() * (@suffixpool_len - 1)) + 1), 1)
	
	-- insert
	insert into t_staff_member (
		staff_id, 
		staff_f_name, 
		staff_s_name, 
		job_code, 
		shelter_id, 
		staff_dob, 
		staff_hire_date, 
		staff_leaving_date, 
		staff_manager, 
		staff_hours, 
		staff_ni_number
	)
	values (
		@count,
		(
			select top 1 f_name 
			from temp_fname 
			order by newid()
		),
		(
			select top 1 s_name 
			from temp_sname 
			order by newid()
		),
		@job_code,
		@shelter_id,
		dateadd(day, (abs(checksum(newid())) % 11323), @date),
		dateadd(day, (abs(checksum(newid())) % 3650), '2009-01-01'),
		null,
		case
			when @job_code = 5 or @job_code = 4 then (
				select top 1 staff_id 
				from t_staff_member 
				where job_code = 3 and shelter_id = @shelter_id
			)
			when @job_code = 3 then (
				select top 1 staff_id 
				from t_staff_member 
				where job_code = 2 and shelter_id = @shelter_id
			)
			when @job_code = 2 then (
				select top 1 staff_id 
				from t_staff_member 
				where job_code = 1 and shelter_id = @shelter_id
			)
			else null
		end,
		(abs(checksum(newid())) % 20) + 20,
		@nino
	)
end
go

---------------------------------------------
----------------   P E T S  -----------------
---------------------------------------------

/*
	This table contains all info for pets

	Note: deceased and neutered are timestamps rather than boolean
	This is more useful as it indicates when, and not just yes or no

	The pet microchip number and format inforation is taken from here: 
	https://www.pet-detect.com/pages/Interpreting-microchip-numeric-codes.aspx?pageid=610
*/

-- C r e a t e  T a b l e --

create table t_pets (
	pet_id int not null,
	pet_name varchar(35) not null,
	pet_description varchar(50) not null,
	pet_dob date not null,
	pet_code tinyint not null,
	pet_deceased date,
	pet_neutered date,
	pet_microchip_number bigint check (
		pet_microchip_number is null
		or (len(pet_microchip_number) = 15 and
			left(pet_microchip_number, 3) = 826
		)
	),
	pet_source varchar(1000) not null,
	pet_suitable_to_rehome tinyint not null,
	pet_restrictions varchar(1000),
	primary key (pet_id),
	foreign key (pet_code) references t_pet_type(pet_code)
)

/*
	Create index to search by pet name
*/

create index IX_t_pets_pet_name
    on t_pets (pet_name asc)
	with fillfactor = 70

/*
	Create index to search by pet microchip number
*/
	
create index IX_t_pets_pet_microchip_number
    on t_pets (pet_microchip_number asc)
	with fillfactor = 70
	
-- P o p u l a t e --

/*
	Run a while loop to generate data and insert
	records for pets
*/

declare @count int = 0
declare @pet_type_count int = (select count(*) from t_pet_type)
declare @date date = '2004-01-01'
while @count < 200 begin
	-- set random pet type
	declare @pet_type int = 1 + ((@count) % @pet_type_count);
	-- set random pet name
	declare @suffix int = @count + 1
	declare @name varchar(255) = (
		select top 1 p_name 
		from temp_petname 
		order by newid()
	)
	-- set random pet DOB
	declare @dob date = dateadd(day, (abs(checksum(newid())) % 5479), @date)
	-- set if neutered or not
	declare @neutered date
	if ceiling(rand()*100) < 70
		set @neutered = dateadd(day, (abs(checksum(newid())) % 60), @dob)
	else 
		set @neutered = null
	-- set if chipped or not
	declare @chipped bigint
	if ceiling(rand()*100) < 70
		set @chipped = 826999999999999 - (round(rand() * 999999999999, 0))
	else 
		set @chipped = null
	-- set pet source
	declare @pet_source int = ceiling(rand()*100)
	-- set if suitable to rehome
	declare @ok_to_rehome int = ceiling(rand()*100)
	-- set any restrictions
	declare @pet_restrictions int = ceiling(rand()*100)
	-- insert
	insert into t_pets (
		pet_id, 
		pet_name, 
		pet_description, 
		pet_dob, 
		pet_code, 
		pet_neutered, 
		pet_microchip_number,
		pet_source,
		pet_suitable_to_rehome,
		pet_restrictions
	)
	values (
		@count + 1,
		@name,
		case
			when @pet_type = 1 then (
				select top 1 name 
				from temp_breed_cat 
				order by newid()
			)
			when @pet_type = 2 then (
				select top 1 name 
				from temp_breed_dog 
				order by newid()
			)
			when @pet_type = 3 then (
				select top 1 name 
				from temp_breed_bird 
				order by newid()
			)
			else (
				select top 1 name 
				from temp_breed_exotic 
				order by newid()
			)
		end,
		@dob,
		@pet_type,
		@neutered,
		@chipped,
		case
			when @pet_source < 20 then 'Abandoned on streets'
			when @pet_source < 40 then 'Elderly owner - could not look after anymore'
			when @pet_source < 60 then 'Surrendered by family'
			when @pet_source < 80 then 'Rescued from owner'
			else ('found in wild')
		end,
		case
			when @ok_to_rehome < 75 then 1
			else (0)
		end,
		case
			when @pet_restrictions < 5 then 'Does not like young children'
			when @pet_restrictions < 10 then 'Does not like men'
			when @pet_restrictions < 15 then 'Does not like women'
			when @pet_restrictions < 20 then 'Nocturnal'
			when @pet_restrictions < 25 then 'Must have garden'
			when @pet_restrictions < 30 then 'Does not like dogs'
			when @pet_restrictions < 35 then 'Does not like cats'
			when @pet_restrictions < 40 then 'Cannot stand hairdriers'
			when @pet_restrictions < 45 then 'Does not like the outdoors'
			else (null)
		end
	)
	set @count = @count + 1;
end
go

---------------------------------------------
--------------  A D O P T E R  --------------
---------------------------------------------

/*
	This table contains information for adopters (both approved
	and awating verification).

	Note: As previously mentioned, their address info is kept in a
	separate table so they can have multiple addresses and also 
	allowing them to move and keep their old addresses on file
	(which is useful for historical checks).
*/

-- C r e a t e  T a b l e --

create table t_adopter (
	adopter_id int,
	adopter_f_name varchar(30) check (len(adopter_f_name) > 0),
	adopter_s_name varchar(30) check (len(adopter_s_name) > 0),
	mobile_tel_number varchar(11) check (
		mobile_tel_number is null or (
			len(mobile_tel_number) = 11 
			and substring(mobile_tel_number, 1, 2) = '07'
		)
	),
	other_pets varchar(255),
	approved_date date default cast(getdate() as date),
	email varchar(255) check (
		email is null 
		or email = '' 
		or email like '_%@_%._%'
	),
	shelter_id tinyint,
	staff_id int,
	adopter_children varchar(255),
	primary key (adopter_id)
	/*
		shelter_id and staff_id are set as foriegn keys only 
		after we set the adopters location in the 
		t_address_info table setup
	*/
	--foreign key (shelter_id) references t_shelter(shelter_id),
	--foreign key (staff_id) references t_staff_member(staff_id)
)

/*
	Create index to allow searching by surname
*/

create index IX_t_adopter_adopter_s_name
    on t_adopter (adopter_s_name asc)
	with fillfactor = 70

/*
	Create index to allow searching by telephone number
*/

create index IX_t_adopter_mobile_tel_number
    on t_adopter (mobile_tel_number asc)
	with fillfactor = 70
	
-- P o p u l a t e --

/*
	Run a while loop to generate data and insert
	adopters
*/

declare @count int = 0
while @count < 100 begin
	-- select random first name
	declare @fname varchar(255) = trim((select top 1 f_name from temp_fname order by newid()))
	-- select random surname
	declare @sname varchar(255) = ltrim(rtrim((select top 1 s_name from temp_sname order by newid())))
	-- generate email prefix based on name
	declare @email_prefix varchar(255) = trim(lower(@fname)) + trim(lower(@sname)) + cast(ceiling(rand()*100) as varchar(255))
	-- setup mobile phone number generation
	declare @random int = ceiling(rand()*100)
	declare @mobile varchar(255) = '07'
	declare @mobile_count int = 0
	-- generate approved date randomly (can be approved or null)
	declare @date date
	if ceiling(rand()*100) > 15
		set @date = dateadd(day, (abs(checksum(newid())) % 730), '2017-01-01')
	else
		set @date = null
	-- generate mobile phone number
	while @mobile_count < 9 begin
		set @mobile = @mobile + cast(floor(rand()*10) as varchar(255))
		set @mobile_count = @mobile_count + 1
	end
	-- gen random number to use in case statement
	declare @random_kids int = ceiling(rand()*100)

	insert into t_adopter(
		adopter_id, 
		adopter_f_name, 
		adopter_s_name, 
		email, 
		other_pets, 
		approved_date, 
		mobile_tel_number, 
		adopter_children
	)
	values (
		@count + 1,
		@fname,
		@sname,
		case
			when @random < 20 then replace(@email_prefix + '@gmail.com', ' ', '')
			when @random < 40 then replace(@email_prefix + '@hotmail.com', ' ', '')
			when @random < 60 then replace(@email_prefix + '@bt.com', ' ', '')
			when @random < 80 then replace(@email_prefix + '@imgur.com', ' ', '')
			else (replace(@email_prefix + '@three.com', ' ', ''))
		end,
		case
			when @random < 30 then null
			when @random < 40 then 'one cat'
			when @random < 45 then 'two cats'
			when @random < 55 then 'one dog'
			when @random < 60 then 'two dogs'
			when @random < 70 then 'one cat & one dog'
			when @random < 75 then 'two cats & one dog'
			when @random < 80 then 'three cats & one dog'
			when @random < 85 then 'two dogs & one cat'
			when @random < 90 then 'three dogs & one cat'
			else ('three dogs & one cat')
		end,
		@date,
		@mobile,
		case
			when @random_kids < 10 then 'one boy'
			when @random_kids < 20 then 'one girl'
			when @random_kids < 30 then 'one boy and one girl'
			when @random_kids < 40 then 'two boys'
			when @random_kids < 50 then 'two girls'
			else (null)
		end
	)
	set @count = @count + 1;
end
go




---------------------------------------------
-------  A D D R E S S  I N F O  ------------
---------------------------------------------

/*
	This table contains inforation on addresses and is common to the 
	adopters, abusers and staff tables

	Note: As mentioned, this allows for old addresses, multiple addresses 
	and shared addresses.  Additionally, this allows for different 
	billing, postal and primary addresses.
*/

-- C r e a t e  T a b l e --

create table t_address_info (
	address_id int not null,
	building_type_other_info varchar(255),
	garden bit default 1,
	home_tel_number varchar(11) check (
		home_tel_number is null or (
			len(home_tel_number) = 11 
			and substring(home_tel_number, 1, 2) = '01'
		)
	),
	house_number_name varchar(30) not null,
	building_id tinyint not null,
	adopter_id int, --can be null if staff/abuser live there
	staff_id int, --can be null if adopter/abuser lives there
	abuser_id int, --can be null if adopter/staff lives there
	postcode varchar(9) not null,
	postal_address bit default 1,
	billing_address bit default 1,
	primary_address bit default 1
	primary key (address_id),
	foreign key (building_id) references t_building_type(building_id),
	foreign key (adopter_id) references t_adopter(adopter_id),
	foreign key (staff_id) references t_staff_member(staff_id),
	foreign key (postcode) references t_postcode(postcode)
)

/*
	Create index to search by phone number
*/

create index IX_t_address_info_home_tel_number
    on t_address_info (home_tel_number asc)
	with fillfactor = 70

/*
	Create index to search by postcode
*/

create index IX_t_address_info_postcode
    on t_address_info (postcode asc)
	with fillfactor = 70
	
-- P o p u l a t e --
	
/*
	Run a while loop to generate data and insert
	adopter addresses
*/

declare @count int = 0
while @count < 100 begin
	-- randomly determine if address has a garden
	declare @random int = ceiling(rand()*100)
	declare @garden int = 0
	if ceiling(rand()*100) < 70
		set @garden = 1
	-- randomly assign home phone number
	declare @tel varchar(255) = '01273'
	declare @tel_count int = 0
	while @tel_count < 6 begin
		set @tel = @tel + cast(floor(rand()*10) as varchar(255))
		set @tel_count = @tel_count + 1
	end
	insert into t_address_info(
		address_id, 
		building_type_other_info, 
		garden, 
		house_number_name, 
		building_id, 
		home_tel_number, 
		adopter_id, 
		postcode, 
		postal_address, 
		billing_address, 
		primary_address
	)
	values (
		@count + 1,
		case
			when @random < 10 then 'second floor flat'
			when @random < 20 then 'noisy neighbours'
			when @random < 30 then 'near main road'
			when @random < 40 then 'first floor flat'
			else (null)
		end,
		@garden,
		cast(ceiling(rand() * 99) as varchar(255)),
		cast(ceiling(rand() * 4) as varchar(255)),
		@tel,
		@count + 1,
		(
			select top 1 postcode 
			from t_postcode 
			order by newid()
		),
		1,
		1,
		1
	)
	set @count = @count + 1;
end
go

/*
	Run a while loop to generate data and insert
	addresses for staff members
*/

declare @count int = 100
while @count < (select count(*) from t_staff_member) + 100 begin
	declare @random int = ceiling(rand()*100)
	declare @garden int = 0
	if ceiling(rand()*100) < 70
		set @garden = 1
	declare @tel varchar(255) = '01273'
	declare @tel_count int = 0
	while @tel_count < 6 begin
		set @tel = @tel + cast(floor(rand()*10) as varchar(255))
		set @tel_count = @tel_count + 1
	end
	insert into t_address_info(
		address_id, 
		building_type_other_info, 
		garden, 
		house_number_name, 
		building_id, 
		home_tel_number, 
		staff_id, 
		postcode, 
		postal_address, 
		billing_address, 
		primary_address
	)
	values (
		@count + 1,
		case
			when @random < 10 then 'second floor flat'
			when @random < 20 then 'noisy neighbours'
			when @random < 30 then 'near main road'
			when @random < 40 then 'first floor flat'
			else (null)
		end,
		@garden,
		cast(ceiling(rand() * 99) as varchar(255)),
		cast(ceiling(rand() * 4) as varchar(255)),
		@tel,
		@count - 99,
		(
			select top 1 postcode 
			from t_postcode 
			order by newid()
		),
		1,
		1,
		1
	)
	set @count = @count + 1;
end
go

/*
	Now addresses have been generated for staff and adopters, we can 
	reassign the adopters to their closest shelter

	ref: https://stackoverflow.com/questions/13026675/calculating-distance-between-two-points-latitude-longitude
*/

update t_adopter
	set shelter_id = (
		select top 1 shelter_id
		from t_shelter
		inner join t_postcode pc_start 
		on t_shelter.postcode = pc_start.postcode
		order by 
		2 * 
		3961 * 
		asin(sqrt(power ((sin(radians((pc_finish.latitude - pc_start.latitude) / 2))),2) 
			+ cos(radians(pc_start.latitude)) * cos(radians(pc_finish.latitude)) 
			* power((sin(radians((pc_finish.longitude - pc_start.longitude) / 2))),2))
		)
	)
	from t_adopter 
	inner join t_address_info on t_adopter.adopter_id = t_address_info.adopter_id
	inner join t_postcode pc_finish on t_address_info.postcode = pc_finish.postcode
go

/*
	Now we can assign a staff member to 'sign off' on adopters where
	they have been approved
*/

update t_adopter 
	set staff_id = (
		select top 1 staff_id
		from t_staff_member
		where (t_adopter.approved_date is not null 
			and t_adopter.shelter_id = t_staff_member.shelter_id
		)
		order by newid()
	)

/*
	Add the foreign keys to t_adopter that we omitted earlier
*/

alter table t_adopter
add foreign key (shelter_id) references t_shelter(shelter_id)
alter table t_adopter
add foreign key (staff_id) references t_staff_member(staff_id)
go

-----------------------------------------------
--  P E T S  &  S H E L T E R  H I S T O R Y --
-----------------------------------------------

/*
	This table contains the shelter history for all of the pets

	Note: Each pet will have only been admitted to a shelter once
*/

-- C r e a t e  T a b l e --

create table t_pet_shelter_history (
	ps_admitted_date date default cast(getdate() as date),
	shelter_id tinyint not null,
	pet_id int not null,
	primary key (ps_admitted_date, pet_id, shelter_id),
	foreign key (shelter_id) references t_shelter(shelter_id),
	foreign key (pet_id) references t_pets(pet_id)
)
go

-- P o p u l a t e --

/*
	Run a while loop to generate data and insert
	a record for each animal between dob & date 
	it was adopted (if it was adopted)
*/


declare @count int = 0
while @count < (select count(*) from t_pets) begin
	insert into t_pet_shelter_history(
		ps_admitted_date, 
		shelter_id, 
		pet_id
	)
	values (
		(
			select top 1 dateadd(day, (abs(checksum(newid())) % 30), pet_dob) 
			from t_pets 
			where t_pets.pet_id = @count + 1
		),
		(
			select top 1 shelter_id 
			from t_shelter 
			order by newid()
		),
		(
			select top 1 pet_id 
			from t_pets 
			where t_pets.pet_id = @count + 1
		)
	)
	set @count = @count + 1;
end
go

---------------------------------------------
-----------  A D O P T I O N S  -------------
---------------------------------------------

/*
	This table contains the records for each adoption
	Note: Each pet will have only been adopted once, and 
	not surrendered back to the Shelter
*/

-- C r e a t e  T a b l e --

create table t_adoptions (
	adoption_date date default cast(getdate() as date),
	adopter_id int not null,
	staff_id int not null,
	pet_id int not null,
	surrendered_on date,
	primary key (adoption_date, adopter_id, pet_id),
	foreign key (adopter_id) references t_adopter(adopter_id),
	foreign key (staff_id) references t_staff_member(staff_id),
	foreign key (pet_id) references t_pets(pet_id)
)

-- P o p u l a t e --

/*
	Run a while loop to generate data and insert
	a record for each adoption
*/

declare @count int = 0
while @count < 100 begin
	-- select adopter at random
	declare @adopter_id int = (
		select top 1 adopter_id 
		from t_adopter 
		where t_adopter.approved_date is not null
		order by newid()
	)
	-- select a pet
	declare @pet_id int = (select pet_id from t_pets where pet_id = @count + 1);
	declare @date_adopter_approved date = (
		select top 1 dateadd(day, (abs(checksum(newid())) % datediff(day, approved_date , getdate())), approved_date)
		from t_adopter 
		where t_adopter.adopter_id = @adopter_id
	)
	-- gen a date (after animal was sheltered)
	declare @date_sheltered date = (
		select dateadd(day, (abs(checksum(newid())) % datediff(day, ps_admitted_date , getdate())), ps_admitted_date)
		from t_pet_shelter_history
		where t_pet_shelter_history.pet_id = @pet_id
	)
	declare @diff1 int = datediff(day,@date_sheltered,@date_adopter_approved)
	declare @diff2 int = datediff(day,@date_adopter_approved,@date_sheltered)
	declare @date date = case 
	when @diff1 > @diff2 
		then @date_adopter_approved 
		else @date_sheltered 
	end
	-- insert
	insert into t_adoptions(
		adoption_date, 
		adopter_id, 
		staff_id, 
		pet_id
	)
	values (
		@date,
		@adopter_id,
		(
			select top 1 t_staff_member.staff_id 
			from t_staff_member 
			inner join t_adopter 
			on t_staff_member.staff_id = t_adopter.staff_id
			where @date is not null 
			and t_staff_member.shelter_id = t_adopter.shelter_id 
			and @adopter_id = t_adopter.adopter_id
			order by newid()
		),
		(select pet_id from t_pets where pet_id = @count + 1)
	)
	set @count = @count + 1;
end
go

---------------------------------------------
--------------  A D D R E S S  --------------
-----------  B A C K G R O U N D   ----------
---------------  C H E C K S   --------------
---------------------------------------------

/*
	This table is a record of the background checks on the
	address given by new adopters

	Note: staff ID is mandatory (as someone will be assigned to 
	complete the check).  The 'background_check_result' can be null 
	(while waiting on the results of the check).

	'date_validated' defaults to the current date (so checks can be
	tracked when they happen).
*/

-- C r e a t e  T a b l e --

create table t_address_background_checks (
	date_validated date default cast(getdate() as date),
	background_check_result bit,
	staff_id int not null,
	address_id int not null,
	primary key (date_validated, address_id),
	foreign key (address_id) references t_address_info(address_id),
	foreign key (staff_id) references t_staff_member(staff_id)
)
go

-- P o p u l a t e --

/*
	Run a while loop to generate data and insert
	completed address background checks for existing
	adopters
*/

declare @count int = 0
while @count < 100 begin
	if (select approved_date from t_adopter where adopter_id = @count + 1) is not null
		insert into t_address_background_checks(
			date_validated, 
			staff_id, 
			address_id, 
			background_check_result
		)
		values (
			(
				select dateadd(day, -1, approved_date) 
				from t_adopter 
				where adopter_id = @count + 1
			),
			(
				select staff_id 
				from t_adopter 
				where adopter_id = @count + 1
			),
			@count + 1,
			1
		)
	set @count = @count + 1;
end
go

/*
	Run a while loop to generate data and insert
	incomplete address background checks for potential
	adopters
*/

declare @count int = 0
while @count < 100 begin
	if (select approved_date from t_adopter where adopter_id = @count + 1) is null
		insert into t_address_background_checks(
			date_validated, 
			staff_id, 
			address_id
		)
		values (
			(
				select dateadd(day, -7, cast(getdate() as date)) 
				from t_adopter 
				where adopter_id = @count + 1
			),
			(
				select top 1 staff_id 
				from t_staff_member 
				order by newid()
			),
			@count + 1
		)
	set @count = @count + 1;
end
go

---------------------------------------------
-------------  A D O P T E R  ---------------
-----------  B A C K G R O U N D   ----------
---------------  C H E C K S   --------------
---------------------------------------------

/*
	This table is a record of the background checks on the 
	new adopters

	Note: staff ID is mandatory (as someone will be assigned to 
	complete the check).  The 'background_check_result' can be null 
	(while waiting on the results of the check).

	'check_date' defaults to the current date (so checks can be
	tracked when they happen).
*/

-- C r e a t e  T a b l e --

create table t_adopter_background_checks (
	check_date date default cast(getdate() as date),
	background_check_result int,
	adopter_id int not null,
	staff_id int not null,
	primary key (check_date, adopter_id),
	foreign key (adopter_id) references t_adopter(adopter_id),
	foreign key (staff_id) references t_staff_member(staff_id)
)

-- P o p u l a t e --

/*
	Run a while loop to generate data and insert
	adopter background checks for adopters who have 
	been approved
*/

declare @count int = 0
while @count < 100 begin
	if (select approved_date from t_adopter where adopter_id = @count + 1) is not null
		insert into t_adopter_background_checks(
			check_date, 
			adopter_id, 
			staff_id, 
			background_check_result
		)
		values (
			(
				select dateadd(day, -1, approved_date) 
				from t_adopter 
				where adopter_id = @count + 1
			),
			@count + 1,
			(
				select staff_id 
				from t_adopter 
				where adopter_id = @count + 1
			),
			1
		)
	set @count = @count + 1;
end
go

/*
	Run a while loop to generate data and insert
	incomplete adopter background checks for adopters
	not yet approved (this is useful for stored procedure task)
*/

declare @count int = 0
while @count < 100 begin
	if (select approved_date from t_adopter where adopter_id = @count + 1) is null
		insert into t_adopter_background_checks(
			check_date, 
			adopter_id, 
			staff_id
		)
		values (
			(
				select dateadd(day, -7, cast(getdate() as date)) 
				from t_adopter 
				where adopter_id = @count + 1
			),
			@count + 1,
			(
				select top 1 staff_id 
				from t_staff_member 
				order by newid()
			)
		)
	set @count = @count + 1;
end
go

---------------------------------------------
--------------  S H E L T E R  --------------
--------------  A B U S E R S  --------------
---------------------------------------------

/*
	This table holds records of anyone the shelter has 
	prosecuted in the past for animal cruelty

	Note:  These people will be seperate from any of the 
	adopters generated above
*/

create table t_shelter_abusers (
	abuser_id int,
	abuser_f_name varchar(30) check (len(abuser_f_name) > 0),
	abuser_s_name varchar(30) check (len(abuser_s_name) > 0),
	mobile_tel_number varchar(11) check (
		mobile_tel_number is null or (
			len(mobile_tel_number) = 11 
			and substring(mobile_tel_number, 1, 2) = '07'
		)
	),
	other_pets varchar(255),
	email varchar(255) check (
		email is null 
		or email = '' 
		or email like '_%@_%._%'
	),
	adopter_children varchar(255),
	primary key (abuser_id)
)

/*
	Note: 

	There are 201 addresses currently, so these addresses will
	have IDs from 202 to 211.

	Their addresses will use house numbers outside the range of the
	ones generated previously, so will not be the same as 
	adopter addresses.
*/
declare @abuser_count int = 1
declare @address_count int = 202
while @abuser_count < 11 begin
	-- insert abuser the shelter has prosecuted
	insert into t_shelter_abusers(
		abuser_id,
		abuser_f_name,
		abuser_s_name,
		mobile_tel_number,
		other_pets,
		email,
		adopter_children
	)
	values (
		@abuser_count,
		(
			select top 1 f_name 
			from temp_fname 
			order by newid()
		),
		(
			select top 1 s_name 
			from temp_sname 
			order by newid()
		),
		'07666666666',
		'cerberus',
		'badman@gmail.com',
		'no kids'
	)
	-- insert their address

	insert into t_address_info(
		address_id, 
		building_type_other_info, 
		garden, 
		house_number_name, 
		building_id, 
		home_tel_number,
		abuser_id,
		postcode, 
		postal_address, 
		billing_address, 
		primary_address
	)
	values (
		@address_count,
		'this should flag up as a bad address',
		1,
		'666',
		1,
		'01273666666',
		@abuser_count,
		(
			select top 1 postcode 
			from t_postcode 
			order by newid()
		),
		1,
		1,
		1
	)
	set @abuser_count = @abuser_count + 1
	set @address_count = @address_count + 1
end
go
---------------------------------------------
--------------  S H E L T E R  --------------
---------  P R O S E C U T I O N S  ---------
---------------------------------------------

/*
	This table contains records of all the prosecutions the 
	shelter has undertaken against individuals.

	Note: Each record will need an adopter, staff member and 
	address associated with it

	Also, this assumes that the Shelter will only procecute 
	its own adopters and NOT members of the general public.

	If that was the case, it would need to somehow link to a more national
	database in order to check previous convictions against animals
	for individuals.
*/

-- C r e a t e  T a b l e --

create table t_shelter_prosecutions (
	prosecution_id int not null,
	abuser_id int not null,
	staff_id int not null,
	address_id int not null,
	prosecution_started date default cast(getdate() as date),
	prosecution_resolved date,
	prosecution_result bit,
	primary key (prosecution_id),
	foreign key (abuser_id) references t_shelter_abusers(abuser_id),
	foreign key (staff_id) references t_staff_member(staff_id),
	foreign key (address_id) references t_address_info(address_id)
)
go

-- P o p u l a t e --

declare @abuser_count int = 1
declare @address_count int = 202

while @abuser_count < 11 begin
	-- pick random start date from 2016 - 2020
	declare @date_started date = dateadd(day, (abs(checksum(newid())) % 1460), '2016-01-02')
	-- pick random finish date up to 100 days later
	declare @date_finished date = dateadd(day, (abs(checksum(newid())) % 100), @date_started)
	insert into t_shelter_prosecutions 
	values (
		@abuser_count,
		@abuser_count,
		@abuser_count + 20, -- different member of staff each time
		@address_count,
		@date_started,
		@date_finished,
		@abuser_count % 2
	)
	set @abuser_count = @abuser_count + 1
	set @address_count = @address_count + 1
end
go

---------------------------------------------
-------------- A N I M A L S ----------------
-------------- I N V O L V E D  -------------
------------------ I N   --------------------
-------------- G E N E R A L  ---------------
---------  P R O S E C U T I O N S  ---------
---------------------------------------------

-- C r e a t e  T a b l e --

create table t_prosecution_animals (
	pet_id int not null,
	prosecution_id int not null,
	primary key (pet_id, prosecution_id),
	foreign key (pet_id) references t_pets(pet_id),
	foreign key (prosecution_id) references t_shelter_prosecutions(prosecution_id)
)
go

-- P o p u l a t e --

/*
	Assign animals to cases
	This is incremental so will be different amounts of animals
	for each case 1 for the first, 2 for second, 3 for third etc
	(loop within a loop)
*/

declare @prosecution_id int = 1

while @prosecution_id < 11 begin
	declare @pet_count int = 1
	while @pet_count < @prosecution_id + 1 begin
		insert into t_prosecution_animals 
		values (
			-- select random pet from table
			(
				select top 1 t_pets.pet_id
				from t_pets
				where pet_dob < '2016-01-01'
				order by newid()
			),
			@prosecution_id
		)
		set @pet_count = @pet_count + 1
	end
	set @prosecution_id = @prosecution_id + 1
end
go

---------------------------------------------
------------ D R O P  T E M P  --------------
-------------  T A B L E S  -----------------
---------------------------------------------

/*
drop table if exists temp_fname
drop table if exists temp_sname
drop table if exists temp_petname
drop table if exists temp_breed_dog
drop table if exists temp_breed_cat
drop table if exists temp_breed_bird
drop table if exists temp_breed_exotic
go*/