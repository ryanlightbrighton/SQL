/*
	Create a trigger to check that when registering a potential adopter, they, 
	or their address, has NOT been involved with a prosecution (whatever the outcome).
*/

/*
	Note:  I elected to use two triggers.  The reasoning is that if a new application
	is made by a potential adopter, they will fill out a form (online or on paper).
	The information will update two tables (t_adopter and t_address_info).
	
	If the trigger is attached to t_adopter for example, and the query that updates 
	t_address_info has not ran by the time the trigger has run, then it is possible
	that a bad address might not be picked up by the trigger because it fired too 
	quickly.
	
	Therefore, I settled on using two triggers.  One will detect a new insert on
	t_adopter, and the other monitors inserts on t_address_info.
	
	This has the added benefit of checking when an existing customer changes their
	address, to check they haven't moved to somewhere involved in prosecutions.
*/

use sars_3
go

create trigger tgr_adopter_background_check on t_adopter
after insert
as begin
	/*
		Check this potential adopter is not in the 
		't_shelter_abusers' table.
		Only check first name and last name
		All other details could easily change.
		Potentially, their name could change (marriage, divorce,
		or deed poll)
		Note: the two pieces of info that wouldn't 
		change is NI number and birthdate.  However, the shelter does 
		not hold those pieces of info for their adopters.  (As 
		seen on their adoption form and the top-down normalisation
		from it.  If the shelter did decide to record NI numbers 
		and birthdates for adopters, then that would make it more 
		secure.  
		However, they would also need to be recording the NI number
		and birthdates of people they prosecute.
	*/
	print '-------------------------------------'
	print 'Inserted new potential adopter record'
	print '-------------------------------------'
	declare @first_name varchar(30)
	declare @last_name varchar(30)
	select @first_name = ins.adopter_f_name from inserted ins
	select @last_name = ins.adopter_s_name from inserted ins
	print 'Potential adopter is: ' + @first_name + ' ' + @last_name
	print '-------------------------------------'
	if (select count(*) 
		from t_shelter_abusers t 
		where (
			t.abuser_f_name = @first_name
			and t.abuser_s_name = @last_name
		)
	) = 0
		print 'Adopter NOT involved with prosecution'
	else
		print 'Adopter is/was involved with prosecution'
	print '---------------------------'
end
go

create trigger tgr_address_background_check on t_address_info
after insert
as begin
	/*
		Check this address is not the same as any in 
		't_shelter_prosecutions'.
		We can compare 'house_number_name' and 'postcode'
		Do not use home tel number as it is easy to change.
		Do not use building_id because houses can be converted to 
		flats and vice versa

		Note: It is possible to change the name of your house, so
		this is a weakness of this approach.  However; it is only weak
		because we are using a local address database table.  If it was
		connected to the Royal Mail postal database, any change there
		would be reflected in this database and any queries.
	*/
	print '---------------------------'
	print 'Inserted new address record'
	print '---------------------------'
	declare @house_name_or_number varchar(30)
	declare @postcode varchar(9)
	select @house_name_or_number = ins.house_number_name from inserted ins
	select @postcode = ins.postcode from inserted ins
	print 'House number or name is: ' + @house_name_or_number
	print 'Postcode is: ' + @postcode
	print '---------------------------'
	if (select count(*) 
		from t_shelter_prosecutions sp
		inner join t_address_info ai
		on ai.address_id = sp.address_id
		where (
			ai.house_number_name = @house_name_or_number
			and ai.postcode = @postcode
		)
	) = 0
		print 'Address NOT involved with prosecution'
	else
		print 'Address is involved with prosecution'
	print '---------------------------'
end
go

-- add new previously prosecuted adopter

insert into t_adopter
values (
	101,
    'Bad',
    'Man',
    '07252656458',
    'two lions',
    null,
    'newadopter@gmail.com',
    null,
    null,
    'two boys'
)

-- add new normal adopter

insert into t_adopter
values (
	102,
    'Good',
    'Man',
    '07252656458',
    'two lions',
    null,
    'newadopter@gmail.com',
    null,
    null,
    'two boys'
)

--add new address associated with conviction

insert into t_address_info (
	address_id,
	building_type_other_info,
	garden,
	home_tel_number,
	house_number_name,
	building_id,
	adopter_id,
	postcode,
	postal_address,
	billing_address,
	primary_address
)
values(
	212,
	'building site out back',
	1,
	'01273555241',
	'666',
	1,
	102,
	' BN3 6PQ',
	1,
	1,
	1
)

--add new address NOT associated with conviction

insert into t_address_info (
	address_id,
	building_type_other_info,
	garden,
	home_tel_number,
	house_number_name,
	building_id,
	adopter_id,
	postcode,
	postal_address,
	billing_address,
	primary_address
)
values(
	213,
	'meadows out back',
	1,
	'01273457124',
	'21',
	1,
	102,
	' BN27 2ND',
	1,
	1,
	1
)
