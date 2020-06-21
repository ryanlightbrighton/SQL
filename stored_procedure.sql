/*
	Create a stored procedure to record home visit outcomes, 
	including: 
		- member of staff 
		- date of visit
		- whether they were approved or not
*/

/*
	By visiting the adopter, the staff member will approve them and their home.

	Therefore, the following tables will need to be updated:
	t_address_background_checks
	t_adopter_background_checks
	t_adopter (approved_date field)
	
	Background checks are generated when a potential adopter
	registers.  The background checks are assigned to a member of staff
	and they are completed when the visit is carried out

	This stored procedure uses the Adopter ID.  I didn't want to use 
	first name and surname because potentially there could be two people
	with the same name.

	The Shelter doesn't use NI numbers or dates of birth, so the most
	reliable way to update the correct account is through the adopter_id.

	Usage: 
		exec sp_home_visit_outcome 
			@adopter_id = 999, 
			@approved_date '2020-05-18',
			@staff_id = 56,
			@result = 0
*/

create procedure sp_home_visit_outcome
	@adopter_id int,
	@approved_date date,
	@staff_id int,
	@result int -- 1 = approved, 0 = not approved
as
	-- update t_address_background_checks

	update t_address_background_checks
	set t_address_background_checks.date_validated = @approved_date,
		t_address_background_checks.background_check_result = @result,
		t_address_background_checks.staff_id = @staff_id 
	from t_address_background_checks as bk
	inner join t_address_info as ai
	on bk.address_id = ai.address_id
	where ai.adopter_id = @adopter_id 
		and bk.background_check_result is null

	-- update t_adopter_background_checks

	update t_adopter_background_checks
	set t_adopter_background_checks.check_date = @approved_date,
		t_adopter_background_checks.background_check_result = @result,
		t_adopter_background_checks.staff_id = @staff_id 
	from t_adopter_background_checks as bk
	where bk.adopter_id = @adopter_id 
		and bk.background_check_result is null

	-- update t_adopter with date if approved
	if @result = 1
		update t_adopter
		set approved_date = @approved_date
		where adopter_id = @adopter_id
go
