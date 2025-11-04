select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;

--1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books (isbn,book_title,category,rental_price,status,author,publisher) 
values ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

--2. Update an Existing Member's Address
update members
set member_address='456 Park St'
where member_id='C101';

--3. Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_status
where issued_id = 'IS121';

--4. Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select emp_id,emp_name,issued_book_name
from employees e
join issued_status i
on e.emp_id=i.issued_emp_id	
where emp_id='E101';

--5. List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
select member_name,member_id,count(issued_id)as total_books_issued
from members m
join issued_status i
on m.member_id=i.issued_member_id
group by member_id
having count(issued_id)>1
order by count(issued_id) desc;

--6. Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
create table books_count as
select book_title ,count(issued_book_isbn)
from books b
join issued_status i
on b.isbn=i.issued_book_isbn
group by(book_title);

select * from books_count
order by 2 desc,1;

--7. Retrieve All Books in a Specific Category:
select * from books
where category='Mystery';

--8. Find Total Rental Income by Category:
select category,sum(rental_price)
from books
group by category
order by 2 des;

--9. List Members Who Registered in the Last 2 yaers:
select * from members
where reg_date>=current_date-interval'2 years';

--10. List Employees with Their Branch Manager's Name and their branch details:
select e.emp_id,e.emp_name,e.branch_id,e2.emp_name,b.branch_address,b.contact_no
from employees e
join branch b
on e.branch_id=b.branch_id
join employees e2
on b.manager_id=e2.emp_id;

--11. Create a Table of Books with Rental Price Above a Certain Threshold:
create table premium_books as
select * from books
where rental_price>=6.5;

select * from premium_books;

--12. Retrieve the List of Books Not Yet Returned
select i.* --i.issued_id,issued_book_name,issued_member_id,issued_date
from issued_status i
left join return_status r
on i.issued_id=r.issued_id
where return_id is null;

--13. Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
select m.member_id,
		m.member_name,
		d.issued_book_name,
		d.issued_date,
		'13-05-2024'::date-d.issued_date::date as days_overdue
from
(
	select i.*
	from issued_status i
	left join return_status r
	on i.issued_id=r.issued_id
	where return_id is null
) as d
join members m
on d.issued_member_id=m.member_id
where '13-05-2024'::date-d.issued_date::date>30
order by 5 desc;

--14. Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
create or replace procedure return_book(p_issued_id varchar(20),p_return_id varchar(10))
language plpgsql
as $$

declare
	v_book_isbn varchar(20);
begin
	select issued_book_isbn
	from issued_status
	where issued_id=p_issued_id
	into v_book_isbn;

	update books
	set status='yes'
	where isbn=v_book_isbn;

	insert into return_status(return_id,issued_id,return_date,return_book_isbn)
	values(p_return_id,p_issued_id,current_date,v_book_isbn);

	raise notice 'The book with isbn(%) is succesfully returned', v_book_isbn;

end;
$$
--calling function
call return_book('IS134','RS119');


--15: Branch Performance Report
--Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
drop table if exists branch_performance;
create table branch_performance as
select e.branch_id, 
		count(i.issued_id)as books_issued,
		count(r.return_id) as books_returned,
		sum(case
			when r.return_id is not null then b.rental_price
			else 0
			end) as revenue_generated

from employees e
join issued_status i
	on e.emp_id=i.issued_emp_id
left join return_status r
	on i.issued_id=r.issued_id
join books b
	on i.issued_book_isbn=b.isbn
group by branch_id;

select * from branch_performance
order by 1;

--16: CTAS: Create a Table of Active Members
--Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
drop table if exists active_members;
create table active_members as
select distinct m.member_id,
		m.member_name,
		m.member_address,
		m.reg_date
from members m
join issued_status i
	on m.member_id=i.issued_member_id
where issued_date >= current_date - interval '2 m';

select * from active_members;

--17: Find Employees with the Most Book Issues Processed
--Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

select e.emp_name,b.*,count(i.issued_id)
from issued_status i
join employees e
	on i.issued_emp_id=e.emp_id
join branch b
	on b.branch_id=e.branch_id
group by e.emp_name,b.branch_id
order by count(i.issued_id) desc
limit 3;

--18: Identify Members with the Most Diverse Reading Interests
--Goal: Find members who have issued books from the largest number of distinct categories.
select m.member_id,m.member_name,count(distinct category) as no_of_categories
from issued_status i
join members m
	on i.issued_member_id=m.member_id
join books b
	on i.issued_book_isbn=b.isbn
group by 1
order by 3 desc;

--19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
--Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
--The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
--The procedure should first check if the book is available (status = 'yes'). 
--If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
--If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

create or replace procedure issue_book(p_book_isbn varchar(20),p_issued_id varchar(10),p_issued_member_id varchar(10),p_issued_emp_id varchar(10))
language plpgsql
as $$

declare

	v_status varchar(10);
	v_book_name varchar(60);
	
begin

	select status 
	from books
	where isbn=p_book_isbn
	into v_status;

	if v_status='yes'
	then
		update books
		set status='no'
		where isbn=p_book_isbn;

		select book_title
		from books
		where isbn=p_book_isbn
		into v_book_name;

		insert into issued_status(issued_id,issued_member_id,issued_book_name,issued_date,issued_book_isbn,issued_emp_id)
		values(p_issued_id,p_issued_member_id,v_book_name,current_date,p_book_isbn,p_issued_emp_id);

		raise notice 'Thank You for issuing book with isbn %',p_book_isbn;
		
	else
		raise notice 'Sorry, I am afraid your book with isbn % is currently unavailable',p_book_isbn;
	
	end if;
end;
$$

--calling isssue_book

call issue_book('978-0-553-29698-2','IS141','C110','E105');


--20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
--Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
--The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. 
--The resulting table should show: Member ID Number of overdue books Total fines
drop table if exists overdue_books;
create table overdue_books as
select m.member_id,
    	count(
	        case
	            when(r.return_date is null and current_date - i.issued_date>30)
	              or(r.return_date is not null and r.return_date - i.issued_date>30)
	            then 1 
	        end
    		)as no_overdue_books,
    	
	    sum(
	        case 
	            when(r.return_date is null and current_date - i.issued_date>30)
	                then(current_date - i.issued_date-30)*0.5
	            when(r.return_date is not null and r.return_date - i.issued_date>30)
	                then(r.return_date - i.issued_date-30)*0.5
	            else 0
	        end
	    )as total_fines,
	    
	    count(i.issued_id) as total_books_issued

from members m
join issued_status i
    on m.member_id=i.issued_member_id
left join return_status r
    on i.issued_id=r.issued_id
group by m.member_id
order by total_fines desc;

select * from overdue_books;



