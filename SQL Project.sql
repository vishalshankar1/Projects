create database assesment_1

select*from transactions
select * from cust_id
---------------------------------------------------Data Prep------------------------------------------------------------------------------------------------
--b.
delete  from transactions
where mcn is null or store_id is null or cash_memo_no is null

--c
select * from transactions t left join cust_id c
on t.mcn = c.custid1

select * into final_data
from transactions t left join cust_id c
on t.mcn = c.custid1


select * from final_data


alter table transactions
alter column saleamount float



alter table final_data
add discount float 
-- d
update final_data
set discount = ((totalamount - saleamount)


--Q1. Count the number of observations having any of the variables having null value/missing values?

select count(*)
from final_data 
where itemcount is null
or transactiondate is null
or totalamount is null
or saleamount is null
or salepercent is null
or cash_memo_no is null
or dep1amount is null
or Dep2Amount is null
or Dep3Amount is null
or Dep4Amount is null
or Store_ID  is null
or MCN  is null
or Gender is null
or [Location] is null
or Age is null
or Cust_seg is null
or Sample_flag is null
or custid is null 


-- Q2 How many customers have shopped? (Hint: Distinct Customers)

select  count (distinct custid1)
from final_data

--Q3.  How many shoppers (customers) visiting more than 1 store?
 
 select count(distinct custid1) as new

 from ( 
        select custid1
		from final_data
		group by custid1
		having count(distinct store_id) >1
		)  as x


-- Q4.   What is the distribution of shoppers by day of the week? How the customer shopping behavior on each day of week? 
--(Hint: You are required to calculate number of customers, 
--number of transactions, total sale amount, total quantity etc.. by each week day)

SELECT 
    format(transactiondate, 'dddd') as days,
   
    COUNT(DISTINCT custid1) as Number_of_Customers,
    COUNT(*) as no_of_transactions ,
    SUM(saleamount) as Total_Sale_Amount,
    SUM(itemcount) as Total_quantity
   FROM 
    final_data
GROUP BY 
format(transactiondate,'dddd')
order by format (transactiondate,'dddd')asc


--Q5 What is the average revenue per customer/average revenue per customer by each location?
select distinct(custid1),avg(totalamount) as average_rev_per_cust 
from final_data
group by (custid1)      /


select distinct(custid1),[location],avg(totalamount) as average_rev_per_cust 
from final_data
group by (custid1),[location]
order by [location]


--Q6  Average revenue per customer by each store etc?


select distinct(custid1),store_id,avg(totalamount) as average_rev_per_cust 
from final_data
group by (custid1),store_id
order by store_id

--q7 Find the department spend by store wise?

select store_id , round(sum (dep1amount),2) as dep1, round(sum(dep2amount),2) as dep2 , round(sum(cast(dep3amount as float)),2) as dep3,
round(sum(cast(dep4amount as float)),2) as dep4 
from final_data 
group by store_id
order by store_id

--Q8 What is the Latest transaction date and Oldest Transaction date? (Finding the minimum and maximum transaction dates)
select max(convert(date,transactiondate,105))as max_date,min(convert(date,transactiondate,105)) as min_date
from final_data

--Q9 How many months of data provided for the analysis?

select count( format(transactiondate,'mmmm'))as months from final_data

--Q10  Find the top 3 locations interms of spend and total contribution of sales out of total sales?

select top 3 [location] ,sum(saleamount)as spend_on_each_location ,
sum(saleamount)/ (select sum(saleamount) from final_data)*100 as contribution

from final_data
group by [location]
order by spend_on_each_location desc


--Q11  Find the customer count and Total Sales by Gender?
select * from final_data
 select  gender, count(distinct custid1) AS CUST_COUNT , round(sum(totalamount),2) AS total_sales 
 from final_data
 where gender IS NOT NULL
 group by gender

 --Q12 What is total  discount and percentage of discount given by each location?

 select [location], round(sum(discount),2)as total_discount,
 sum(discount)/(select sum(discount) from final_data)*100 as perc_of_disc
 from final_data
 where [location] is not null
 group by [location]
 order by [location]

 --13 Which segment of customers contributing maximum sales?

select top 1 cust_seg , sum(saleamount)as totalsales
from final_data
group by cust_seg 
order by totalsales desc

--14  What is the average transaction value by location, gender, segment?
 select [location],gender, cust_seg, round(avg(saleamount),2) as average
 from final_data
 where [location] is not null
 group by [location],gender, cust_seg


 --15  Create Customer_360 Table with below columns.

/* Customer_id,
Gender,
Location,
Age,
Cust_seg,
No_of_transactions,
No_of_items,
Total_sale_amount,
Average_transaction_value,
TotalSpend_Dep1,
TotalSpend_Dep2,
TotalSpend_Dep3,
TotalSpend_Dep4,
No_Transactions_Dep1,
No_Transactions_Dep2,
No_Transactions_Dep3,
No_Transactions_Dep4,
No_Transactions_Weekdays,
No_Transactions_Weekends,
Rank_based_on_Spend,
Decile 
*/ 

create table Customer_360 ( Customer_id varchar(50),Gender char(1),[Location] varchar(50) ,Age int , Cust_seg int ,No_of_transactions float,
No_of_items float,Total_sale_amount float,Average_transaction_value float,TotalSpend_Dep1 float,TotalSpend_Dep2 float,TotalSpend_Dep3 float,
TotalSpend_Dep4 float,No_Transactions_Dep1 int,No_Transactions_Dep2 int,No_Transactions_Dep3 int,No_Transactions_Dep4 int,
No_Transactions_Weekdays int,No_Transactions_Weekends int,Rank_based_on_Spend float,Decile float  )

select * from Customer_360
-- to insert data from from final_data to customer_360
insert into customer_360 ( Customer_id,Gender,[Location],Age,Cust_seg)
select  custid1, gender, [location],age ,cust_seg
from final_data

update customer_360 
set No_of_transactions = (select count (saleamount) from final_data
where customer_360. customer_id = final_data .custid1)

update customer_360 
set No_of_items = (select count (itemcount) from final_data
where customer_360. Customer_id = final_data .custid1)


update customer_360 
set Total_sale_amount = (select sum (saleamount) from final_data
where customer_360. customer_id= final_data .custid1)

update customer_360 
set Average_transaction_value = (select avg(saleamount) from final_data
where customer_360. customer_id= final_data .custid1)

update customer_360 
set TotalSpend_Dep1 = (select sum(dep1amount) from final_data
where customer_360. customer_id= final_data .custid1)


update customer_360 
set TotalSpend_Dep2 = (select sum(dep2amount) from final_data
where customer_360. customer_id= final_data .custid1)

update customer_360 
set TotalSpend_Dep3 = (select sum(cast(dep3amount as float)) from final_data
where customer_360. customer_id= final_data .custid1)

update customer_360 
set TotalSpend_Dep4 = (select sum(cast(dep4amount as float)) from final_data
where customer_360. customer_id= final_data .custid1)

update customer_360 
set No_Transactions_Dep1 = (select count(dep1amount) from final_data
where customer_360. customer_id= final_data .custid1)

update customer_360 
set No_Transactions_Dep2 = (select count(dep2amount) from final_data
where customer_360. customer_id= final_data .custid1)

update customer_360 
set No_Transactions_Dep3 = (select count(cast(dep3amount as float)) from final_data
where customer_360. customer_id= final_data .custid1)

update customer_360 
set  No_Transactions_Dep4 = (select count(cast(dep4amount as float)) from final_data
where customer_360. customer_id= final_data .custid1)

update customer_360 
set No_Transactions_Weekdays = (select sum(case when format(convert (date,transactiondate, 105),'dddd')
not in ( 'saturday','sunday') then 1 else 0 end ) from final_data 	
where customer_360. customer_id= final_data .custid1)

update customer_360 
set No_Transactions_Weekends = (select sum(case when format(convert (date,transactiondate, 105),'dddd')
 in ( 'saturday','sunday') then 1 else 0 end ) from final_data 	
where customer_360. customer_id= final_data .custid1)

update customer_360 
set Rank_based_on_spend = (select row_number() over(order by sum(saleamount)desc)  from final_data
where customer_360. customer_id= final_data .custid1)

update customer_360 
set Rank_based_on_spend = (select row_number() over(order by sum(saleamount)desc)  from final_data
where customer_360. customer_id= final_data .custid1)

update customer_360 
set Decile= (select ntile(10) over(order by sum(saleamount) desc)  from final_data
where customer_360. customer_id= final_data .custid1)
alter table customer_360
add   rank_based_on_spend float
select*from customer_360 