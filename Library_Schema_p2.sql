
--Library Management System

--creating branch table
drop table if exists branch;
create table branch
		(
			branch_id varchar(10) primary key,
			manager_id varchar(10),
			branch_address	varchar(50),
			contact_no bigint
		);

--creating employees table
drop table if exists employees;
create table employees
		(
			emp_id varchar(10) primary key,
			emp_name varchar(20),
			position varchar(10),
			salary float,
			branch_id varchar(10)
		);

--creating books table
drop table if exists books;
create table books
		(
			isbn varchar(20) primary key,
			book_title varchar(60),
			category varchar(20),
			rental_price float,
			status varchar(5),
			author varchar(25),
			publisher varchar(30)
		);

--creating issued_status table
drop table if exists issued_status;
create table issued_status
		(
			issued_id varchar(10) primary key,
			issued_member_id varchar(10),
			issued_book_name varchar(60),
			issued_date date,
			issued_book_isbn varchar(20),
			issued_emp_id varchar(10)
		);

--creating members table
drop table if exists members;
create table members
		(
			member_id varchar(10) primary key,
			member_name varchar(15),
			member_address varchar(15),
			reg_date date
		);

--creating return_status table
drop table if exists return_status;
create table return_status
		(
			return_id varchar(10) primary key,
			issued_id varchar(10),
			return_book_name varchar(60),
			return_date date,
			return_book_isbn varchar(20)
		);

alter table employees
add constraint fk_branch_id
foreign key (branch_id)
references branch(branch_id);

alter table issued_status
add constraint fk_emp_id
foreign key (issued_emp_id)
references employees(emp_id);

alter table issued_status
add constraint fk_member_id
foreign key (issued_member_id)
references members(member_id);

alter table issued_status
add constraint fk_book_isbn
foreign key (issued_book_isbn)
references books(isbn);

alter table return_status
add constraint fk__return_book_isbn
foreign key (return_book_isbn)
references books(isbn);


--manually inserting in return_status table
INSERT INTO return_status(return_id, issued_id, return_date) 
VALUES
('RS101', 'IS101', '2023-06-06'),
('RS102', 'IS105', '2023-06-07'),
('RS103', 'IS103', '2023-08-07'),
('RS104', 'IS106', '2024-05-01'),
('RS105', 'IS107', '2024-05-03'),
('RS106', 'IS108', '2024-05-05'),
('RS107', 'IS109', '2024-05-07'),
('RS108', 'IS110', '2024-05-09'),
('RS109', 'IS111', '2024-05-11'),
('RS110', 'IS112', '2024-05-13'),
('RS111', 'IS113', '2024-05-15'),
('RS112', 'IS114', '2024-05-17'),
('RS113', 'IS115', '2024-05-19'),
('RS114', 'IS116', '2024-05-21'),
('RS115', 'IS117', '2024-05-23'),
('RS116', 'IS118', '2024-05-25'),
('RS117', 'IS119', '2024-05-27'),
('RS118', 'IS120', '2024-05-29');