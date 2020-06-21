/*
	1. Show current location of each animal (which may move between shelters).
	2. Keep staff information for all types of staff, including volunteers. This should include name, address, date of
	birth, pay (if applicable) etc. Each shelter has its own staff and volunteers.
	3. Record all animal information e.g. type, name, age, source (where it came from e.g. prosecution / death of
	owner / stray etc.), whether it is suitable for rehoming and, if so, if there are any restrictions e.g. not with
	young children / needs garden etc. ***
	4. List all animals that were adopted in the previous year, as well as their adopters.
	5. Record staff and animals involved in any prosecutions. Note that a single prosecution can involve multiple
	animals and will have one lead staff member. There will be an accused person and an address associated
	with each prosecution.
	6. Record the outcome of all prosecutions.
	7. List potential animal adopters who have been approved, but have not yet adopted an animal (so are
	available).
	8. Identify the manager for each shelter, and line managers for all other members of staff.
	9. Show the total number of each type of animal currently being cared for. (Note: one of the animal types is
	other, which covers odd animals e.g. the axolotl that was found last year).
	10. Calculate the monthly wage bill for each shelter.
	11. Identify animals available for rehoming that have been in the shelter for longer than the average length of
	stay for animals of their type.
	12. Create a stored procedure to record home visit outcomes, including member of staff, date of visit, and
	whether they were approved or not.
	13. Create a trigger to check that, when registering a potential adopter, they, or their address, has NOT been
	involved with a prosecution (whatever the outcome).
	14. Create an application to run the queries to meet requirements 1 - 11
*/

-- maybe change it so the "surrendered_on" attribute isn't a date but a reference to the subsequent t_pet_shelter_history entry
-- and therefore, the t_pet_shelter_history entry has an optional attribute that links to the corresponding t_adoption entry
-- https://stackoverflow.com/questions/2411559/how-do-i-query-sql-for-a-latest-record-date-for-each-user/2411763#2411763
use sars
go

/*
	1: Show current location of each animal (which may move between shelters).
*/

with last_pet_shelter_record_table as (
	select * from (
		select
			ps_admitted_date,
			shelter_id,
			t_pet_shelter_history.pet_id,
			row_number() over(partition by t_pet_shelter_history.pet_id order by ps_admitted_date desc) as row_num
		from t_pet_shelter_history
	) t
	where t.row_num = 1
)

select distinct 
	t_pets.pet_id, 
	t_pets.pet_name, 
	last_pet_shelter_record_table.shelter_id, 
	t_shelter.shelter_name
from t_pets
left outer join last_pet_shelter_record_table
on t_pets.pet_id = last_pet_shelter_record_table.pet_id
inner join t_shelter
on last_pet_shelter_record_table.shelter_id = t_shelter.shelter_id
left outer join t_adoptions
on t_pets.pet_id = t_adoptions.pet_id 
where (
	select count(*)
	from t_adoptions
	where t_pets.pet_id = t_adoptions.pet_id
	and t_adoptions.surrendered_on is null
) = 0
order by t_pets.pet_id
go

/*
	2) Keep staff information for all types of staff, including volunteers. 
	This should include name, address, date of birth, pay (if applicable) etc. 
	Each shelter has its own staff and volunteers
*/

select 
	jc.job_code as 'Job Code', 
	job_title as 'Job Title', 
	sh.shelter_name as 'Shelter Name', 
	sm.staff_id as 'Staff ID', 
	staff_f_name + ' ' + staff_s_name as 'Name',
	jc.job_hourly_rate as 'Hourly Rate',
	staff_hours as 'Weekly Hours',
	jc.job_hourly_rate * staff_hours as 'Weekly Wage',
	ai.house_number_name 
	+ ' ' + pc.first_line 
	+ ' ' + pc.town 
	+ ' ' + ai.postcode as 'Address',
	+ ai.home_tel_number as 'Home Tel'
from t_staff_member sm
inner join t_shelter sh
on sm.shelter_id = sh.shelter_id
inner join t_job_type jc
on sm.job_code = jc.job_code
inner join t_address_info ai
on sm.staff_id = ai.staff_id
inner join t_postcode pc
on ai.postcode = pc.postcode
group by 
	sh.shelter_id, 
	jc.job_code, 
	job_title, 
	sh.shelter_name, 
	sm.staff_id, 
	staff_f_name, 
	staff_s_name,
	job_hourly_rate,
	staff_hours,
	house_number_name,
	first_line,
	ai.postcode,
	pc.town,
	ai.home_tel_number
order by sh.shelter_id, jc.job_code asc
go

/*
	3: Record all animal information e.g. type, name, age, source 
	(where it came from e.g. prosecution / death of owner / stray etc.),
	whether it is suitable for rehoming and, if so, 
	if there are any restrictions e.g. not with
	young children / needs garden etc.
*/

select pet_id as 'Pet ID', 
	pet_name as 'Pet Name', 
	pt.pet_type as 'Pet Type',
	pet_description as 'Description',
	pet_dob as 'Date Of Birth',
	case 
		when pet_deceased is null then 'Yes'
		when pet_deceased is not null then 'No'
	end as 'Alive',
	case 
		when pet_neutered is null then 'No'
		when pet_neutered is not null then convert(varchar(10), pet_neutered)
	end as 'Neutered',
	case 
		when pet_microchip_number is null then 'Not chipped'
		when pet_microchip_number is not null then convert(varchar(15), pet_microchip_number)
	end as 'Microchip #',
	pet_source as 'Source',
	case 
		when pet_suitable_to_rehome = 0 then 'No'
		when pet_suitable_to_rehome = 1 then 'Yes'
	end as 'Can re-home?',
	case 
		when pet_restrictions is null then 'No restrictions'
		when pet_restrictions is not null then pet_restrictions
	end as 'Restrictions'
from t_pets pets
inner join t_pet_type pt
on pets.pet_code = pt.pet_code
order by pets.pet_name
go

/*
	4: list animals adopted in the previous year, 
	as well as their adopters.
*/

select adoption_date as 'Date Adopted',
	ad.pet_id as 'Pet ID',
	adopter_f_name + ' ' + adopter_s_name as 'Adopter',
	pet_name as 'Pet Name',
	pet_description as 'Pet Description',
	pet_type as 'Type',
	pet_dob as 'Pet DOB',
	(
		select top 1 shelter_name 
		from t_pet_shelter_history psh
		inner join t_shelter
		on psh.shelter_id = t_shelter.shelter_id
		where psh.pet_id = tp.pet_id
		order by ps_admitted_date desc
	) as 'Adopted from'
from t_adoptions ad
inner join t_adopter adptr
on ad.adopter_id = adptr.adopter_id
inner join t_pets tp
on ad.pet_id = tp.pet_id
inner join t_pet_type tpt
on tp.pet_code = tpt.pet_code
where (adoption_date > dateadd(day, -365, getdate()))
order by 'Date Adopted' asc
go

/*
	5: Record staff and animals involved in any prosecutions. 
	Note that a single prosecution can involve multiple
	animals and will have one lead staff member. 
	There will be an accused person and an address associated
	with each prosecution.
*/


select t_s_p.prosecution_id as 'Prosecution ID',
	abuser_f_name + ' ' + abuser_s_name as 'Abuser Name',
	staff_f_name + ' ' + staff_s_name as 'Lead Staff Member',
	t_p_a.pet_id as 'Pet ID',
	pet_name as 'Pet Name'
from t_shelter_prosecutions t_s_p
inner join t_staff_member t_s_m
on t_s_p.staff_id = t_s_m.staff_id
inner join t_shelter_abusers t_s_a
on t_s_p.abuser_id = t_s_a.abuser_id
-- group by pets
inner join t_prosecution_animals t_p_a
on t_s_p.prosecution_id = t_p_a.prosecution_id
inner join t_pets
on t_p_a.pet_id = t_pets.pet_id
group by t_p_a.pet_id, 
	t_s_p.prosecution_id,
	abuser_f_name,
	abuser_s_name,
	staff_f_name,
	staff_s_name,
	pet_name
order by 'Prosecution ID'
go

/*
	6: Record the outcome of all prosecutions. 
	Note: this query seems very simple and could be 
	done with a simple 'select * from t_shelter_prosecutions'.

	Maybe I'm missing something, so I'll try to make it more
	interesting

*/

select t_s_p.prosecution_id as 'Prosecution ID',
	abuser_f_name + ' ' + abuser_s_name as 'Abuser Name',
	case 
		when prosecution_result = 0 then 'Not guilty'
		when prosecution_result = 1 then 'Guilty'
	end as 'Prosecution result',
	staff_f_name + ' ' + staff_s_name as 'Lead Staff Member',
	t_p_a.pet_id as 'Pet ID',
	pet_name as 'Pet Name',
	prosecution_started as 'Date Started',
	prosecution_resolved as 'Date Finished',
	datediff(day, prosecution_started, prosecution_resolved) as 'Time taken (days)'
from t_shelter_prosecutions t_s_p
inner join t_staff_member t_s_m
on t_s_p.staff_id = t_s_m.staff_id
inner join t_shelter_abusers t_s_a
on t_s_p.abuser_id = t_s_a.abuser_id
-- group by pets
inner join t_prosecution_animals t_p_a
on t_s_p.prosecution_id = t_p_a.prosecution_id
inner join t_pets
on t_p_a.pet_id = t_pets.pet_id
group by t_p_a.pet_id, 
	t_s_p.prosecution_id,
	abuser_f_name,
	abuser_s_name,
	staff_f_name,
	staff_s_name,
	pet_name,
	prosecution_result,
	prosecution_started,
	prosecution_resolved
order by 'Prosecution ID'
go	

/*
	7: List potential animal adopters who have been approved, but have not yet adopted an animal (so are available).
*/

select 
	adopter_id as 'Adopter ID', 
	adopter_f_name + ' ' + adopter_s_name as 'Adopter Name',
	approved_date as 'Approved Date'
from t_adopter ta 
where (
	(
		select count(*) 
		from t_adoptions 
		where ta.adopter_id = t_adoptions.adopter_id 
		and t_adoptions.surrendered_on is null
	) = 0
	and ta.approved_date is not null
)
go

/*
	8: Identify the manager for each shelter, 
	and line managers for all other members of staff.
*/

select 
	(t.staff_f_name + ' ' + t.staff_s_name) as 'Staff Name',
	(jo.job_title) as 'Job Title',
	(s.staff_f_name + ' ' + s.staff_s_name) as 'Manager',
	(j.job_title) as 'Reports To'
from t_staff_member t
left join t_staff_member s
on s.staff_id = t.staff_manager
left join t_job_type j
on s.job_code = j.job_code
left join t_job_type jo
on t.job_code = jo.job_code
order by 'Manager'
go

/*
	9: Show the total number of each type of animal currently being cared for.
*/

with last_pet_shelter_record_table as (
	select * from (
		select
			ps_admitted_date,
			shelter_id,
			pet_id,
			row_number() over(partition by pet_id order by ps_admitted_date desc) as row_num
		from
			t_pet_shelter_history
	) t
	where t.row_num = 1
)

select  
	count(*) as 'Count Of Animals', 
	pet_code as 'Pet Type'
from t_pets
left outer join last_pet_shelter_record_table
on t_pets.pet_id = last_pet_shelter_record_table.pet_id
inner join t_shelter
on last_pet_shelter_record_table.shelter_id = t_shelter.shelter_id
left outer join t_adoptions
on t_pets.pet_id = t_adoptions.pet_id 
where
	(select count(*) from t_adoptions where t_pets.pet_id = t_adoptions.pet_id
	and t_adoptions.surrendered_on is null) = 0
group by pet_code
order by pet_code asc
go

/*
	10: Calculate the monthly wage bill for each shelter
*/

select 
	sum(jt.job_hourly_rate * st.staff_hours) * (52/12) as monthly_bill, 
	sh.shelter_name  
from t_staff_member st
inner join t_job_type jt
on st.job_code = jt.job_code
inner join t_shelter sh
on st.shelter_id = sh.shelter_id
group by sh.shelter_name
go


/*
	11: Identify animals available for rehoming that have been 
	in the shelter for longer than the average length of stay 
	for animals of their type.
*/

with get_shelter_time_by_pet as (
	select 
		ps.pet_id,
		p.pet_code,
		case
			when (
				select top 1 adoption_date
				from t_adoptions tt
				where tt.pet_id = ps.pet_id
				and tt.adoption_date > ps.ps_admitted_date
			) is null 
			then datediff(day,ps.ps_admitted_date,getdate())
			else 
			datediff(day,ps.ps_admitted_date,(
				select top 1 adoption_date
				from t_adoptions tt
				where tt.pet_id = ps.pet_id
				and tt.adoption_date > ps.ps_admitted_date
			))
		end as days_in_shelter
	from t_pet_shelter_history ps
	inner join t_pets p
	on p.pet_id = ps.pet_id
	-- new where clause to filter animal records that are currently adopted
	where (
		select top 1 adoption_date
		from t_adoptions tt
		where tt.pet_id = ps.pet_id
		and tt.adoption_date > ps.ps_admitted_date
	) is null
),
get_shelter_time_by_type as (
	select pet_code, avg(days_in_shelter) as average_stay from get_shelter_time_by_pet group by pet_code
)
select 
	gstbp.pet_id as 'Pet ID',
	--p.pet_name,
	gstbp.days_in_shelter as 'Days In Shelter',
	--p.pet_code,
	gstbt.average_stay as 'Average Stay'
from get_shelter_time_by_pet gstbp
--inner join t_pets p
--on gstbp.pet_id = p.pet_id
inner join get_shelter_time_by_type gstbt
on gstbp.pet_code = gstbt.pet_code
where gstbp.days_in_shelter > gstbt.average_stay
order by gstbp.pet_id
go