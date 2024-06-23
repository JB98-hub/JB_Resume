/*Rishab Mishra Interview Questions*/

/* Dataset for questions

create schema int_prep

CREATING EMPLOYEE TABLE (make sure 'int_prep' schema is highlighted and appearing in bold text in the navigator)

CREATE TABLE Employee (
EmpID int NOT NULL,
EmpName Varchar(90),
Gender Char, 
Salary int,
City Char(20) )


INSERT INTO Employee
VALUES (1, 'Arjun', 'M', 75000, 'Pune'),
(2, 'Ekadanta', 'M', 125000, 'Bangalore'),
(3, 'Lalita', 'F', 150000 , 'Mathura'),
(4, 'Madhav', 'M', 250000 , 'Delhi'),
(5, 'Visakha', 'F', 120000 , 'Mathura')



EMPLOYEE DETAIL TABLE

CREATE TABLE EmployeeDetail (
EmpID int NOT NULL,
Project Varchar(90),
EmpPosition Char(20),
DOJ date 
)


INSERT INTO EmployeeDetail
VALUES (1, 'P1', 'Executive', '2019-01-26'),
(2, 'P2', 'Executive', '2020-05-04'),
(3, 'P1', 'Lead', '2021-10-21'),
(4, 'P3', 'Manager', '2019-11-29'),
(5, 'P2', 'Manager', '2020-08-01')


*/



/*Q1(a): Find the list of employees whose salary ranges between 2L to 3L.*/

select * from employee where salary >=200000 and salary <300000;



/*Q1(b): Write a query to retrieve the list of employees from the same city.*/

select * from employee as e1, employee as e2
where e1.city = e2.city
and
e1.empid != e2.empid;



/* Q1(c): Query to find the null values in the Employee table. */

select * from employee where empid is null;



/* Q2(a): Query to find the cumulative sum of employee’s salary. */

select empid, salary, sum(salary) over (order by empid) from employee;



/* Q2(b): What’s the male and female employees ratio. */

select count(if(gender = 'M',1,null)) as malecount,
		count(if(gender = 'F',1,null)) as femalecount,
			count(if(gender = 'M',1,null))/count(if(gender = 'F',1,null)) as maletofemaleratio 
				from employee 
;




/* Q2(c): Write a query to fetch 50% records from the Employee table. */

select * from employee
where empid <= (select count(empid)/2 from employee);



/* Q3: Query to fetch the employee’s salary but replace the LAST 2 digits with ‘XX’ 
i.e 12345 will be 123XX */

select salary,
concat(left(salary, length(salary) - 2), 'XX')
from employee;




/* Q4: Write a query to fetch even and odd rows from Employee table. */

select * from (
			   select *, row_number() over (order by empid) from employee
			  )
where empid % 2 = 0   ;   /* Even rows */


select * from (
			   select *, row_number() over (order by empid) from employee
			  )
where empid % 2 = 1   ;   /* Odd rows */



/*
  
  Q5(a): Write a query to find all the Employee names whose name:
• Begin with ‘A’
• Contains ‘A’ alphabet at second place
• Contains ‘Y’ alphabet at second last place
• Ends with ‘L’ and contains 4 alphabets 
• Begins with ‘V’ and ends with ‘A   

*/


select * from employee where empname like "A%";
select * from employee where empname like "_A%";
select * from employee where empname like "%Y_";
select * from employee where empname like "____L";
select * from employee where empname like "V%A";




/* Q5(b): Write a query to find the list of Employee names which is:
• starting with vowels (a, e, i, o, or u), without duplicates
• ending with vowels (a, e, i, o, or u), without duplicates
• starting & ending with vowels (a, e, i, o, or u), without duplicates */

select * from employee where empname regexp '^[a,i,o,e,u]';

select * from employee where empname regexp '[a,i,o,e,u]$';

select * from employee where empname regexp '^[a,e,i,o,u].*[a,e,i,o,u]$';




/* Q6: Find Nth highest salary from employee table with and without using the TOP/LIMIT keywords. */

/* without TOP/LIMIT keyword */

with cte as(
select *, row_number() over (order by salary desc) as salrank from employee
)
select * from cte where salrank = 1;




/* Q7(a): Write a query to find and remove duplicate records from a table. */

select empid, empname, gender, salary, city, count(*) from employee group by 1,2,3,4,5 having count(*) > 1;

delete from employee
where empid in (
		select empid from
						(select empid, row_number() over (partition by empid, empname) as rownum from employee) as sub
																												   where rownum > 1
                    );
                    
/* ALTERNATE APPROACH */

create table TempEmp like employee;

insert into TempEmp
select distinct* from employee;

drop table employee;

alter table TempEmp
rename to employee;




/* Q7(b): Query to retrieve the list of employees working in same project.   */

with cte as (
				select e.empid, empname, project from employee as e
				left join employeedetail as ed
				on e.empid = ed.empid
                )

select ct1.empid, ct2.empid, ct1.empname, ct2.empname, ct1.project from cte as ct1, cte as ct2
where ct1.empid > ct2.empid and ct1.project = ct2.project and ct1.empid != ct2.empid
;




/* Q8: Show the employee with the highest salary for each project  */

with cte as (
			select e.empid, empname, salary, project,
            row_number() over (partition by project order by salary desc) as rnk from employee as e
			left join employeedetail as ed
			on e.empid = ed.empid
            )
select * from cte where rnk = 1;





/* Q9: Query to find the total count of employees joined each year  */

select count(e.empid), year(doj) from employee as e
left join employeedetail as ed
on e.empid = ed.empid
group by 2;




/* Q10: Create 3 groups based on salary col, salary less than 1L is low, between 1 - 2L is medium and above 2L is High */

select *,
		case when salary < 100000 then "Low"
			 when salary >= 100000 and salary <= 200000 then "Medium"
             else "High"
             end as salary_group
from employee;





/* BONUS: Query to pivot the data in the Employee table and retrieve the total salary for each city.
			The result should display the EmpID, EmpName, and separate columns for each city 
			(Mathura, Pune, Delhi), containing the corresponding total salary. */

select
	empid,
    empname,
	sum(case when city = 'pune' then salary end) as "Pune",
    sum(case when city = 'Delhi' then salary end) as "Delhi",
    sum(case when city = 'Bangalore' then salary end) as "Bangalore",
    sum(case when city = 'Mathura' then salary end) as "Mathura"
		from employee
        group by 1,2;