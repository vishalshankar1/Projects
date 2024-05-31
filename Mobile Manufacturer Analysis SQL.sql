use db_SQLCaseStudies
--SQL Advance Case Study
Select*From [dbo].[DIM_CUSTOMER]
Select*From[dbo].[DIM_DATE]
Select*From[dbo].[DIM_LOCATION]
Select*From[dbo].[DIM_MANUFACTURER]
Select*From[dbo].[DIM_MODEL]
Select*From[dbo].[FACT_TRANSACTIONS]
--1. List all the states in which we have customers who have bought cellphones from 2005 till today.
--Q1--BEGIN 

	Select Distinct [State]
	From DIM_LOCATION
	Inner Join FACT_TRANSACTIONS
	On FACT_TRANSACTIONS.IDLocation=DIM_LOCATION.IDLocation
	Where Year(FACT_TRANSACTIONS.Date)>=2005

--Q1--END

--2. What state in the US is buying the most 'Samsung' cell phones? 

--Q2--BEGIN
   Select top 1 [State],SUM(FACT_TRANSACTIONS.Quantity)   As TOT_Quantity
   From DIM_LOCATION
	      inner join 
		FACT_TRANSACTIONS
    On  FACT_TRANSACTIONS.IDLocation=DIM_LOCATION.IDLocation
	         Inner join 
	    DIM_MODEL
	On  FACT_TRANSACTIONS.IDModel=DIM_MODEL.IDModel
	         Inner join 
	    DIM_MANUFACTURER
	On  DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer
	Where Country='Us' And Manufacturer_Name='Samsung'
	Group By [State]
	Order by TOT_Quantity Desc
--Q2--END

--3. Show the number of transactions for each model per zip code per state.
--Q3--BEGIN      
	Select Count(Date) As Num_TRASACTION,IDMOdel,ZipCode,[State]
	From FACT_TRANSACTIONS
	Inner join
	     DIM_LOCATION
     On FACT_TRANSACTIONS.IDLocation=DIM_LOCATION.IDLocation
	 Group By IDModel,ZipCode,[State]
	 Order by IDModel
--Q3--END


--4. Show the cheapest cellphone (Output should contain the price also)

--Q4--BEGIN

Select *From(Select *,Dense_Rank() Over(Order by Unit_price ) As Cheapest_Price
From DIM_MODEL) As X
Where Cheapest_Price=1

--Q4--END

--5. Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.
--Q5--BEGIN


Select FACT_TRANSACTIONS.IdModel,DIM_MANUFACTURER.Manufacturer_Name ,Sum(TotalPrice)/Sum(Quantity) as Avg_Price
 From DIM_LOCATION
 inner join FACT_TRANSACTIONS
    On  FACT_TRANSACTIONS.IDLocation=DIM_LOCATION.IDLocation
 Inner join  DIM_MODEL
	On  FACT_TRANSACTIONS.IDModel=DIM_MODEL.IDModel
 Inner join DIM_MANUFACTURER
	On  DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer
	where Manufacturer_Name in ( Select Top 5 Manufacturer_Name from DIM_MANUFACTURER
	 inner join DIM_MODEL On DIM_MODEL.IDManufacturer=DIM_MANUFACTURER.IDManufacturer
	 Inner Join FACT_TRANSACTIONS On FACT_TRANSACTIONS.IDModel=DIM_MODEL.IDModel
	 Group By Manufacturer_Name 
	 Order by Sum(Quantity)  Desc)
	Group By FACT_TRANSACTIONS.IdModel,DIM_MANUFACTURER.Manufacturer_Name
	Order by Avg_Price

--Q5--END

--6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500

--Q6--BEGIN
Select*from DIM_CUSTOMER
Select*from FACT_TRANSACTIONS
Select Customer_Name,Avg(TotalPrice) As TotalAmountSpent
From DIM_CUSTOMER
inner join FACT_TRANSACTIONS
On DIM_CUSTOMER.IDCustomer=FACT_TRANSACTIONS.IDCustomer
where YEAR(FACT_TRANSACTIONS.[Date])=2009
Group By Customer_Name
Having Avg(TotalPrice) >500

--Q6--END


--7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010	
--Q7--BEGIN  

Select Idmodel 
from(
       select Top 5 idmodel
       from FACT_TRANSACTIONS
	   Where YEAR([date])=2008
	   Group by IDModel
	   order by sum(quantity) desc
	) AS X
	       Intersect
Select Idmodel 
from(
       select Top 5 idmodel
       from FACT_TRANSACTIONS
	   Where YEAR([date])=2009
	   Group by IDModel
	   order by sum(quantity) desc
	) As Y
	       Intersect
Select Idmodel 
from(
	   select Top 5 idmodel
       from FACT_TRANSACTIONS
	   Where YEAR([date])=2010
	   Group by IDModel
	   order by sum(quantity) desc
	)As Z


--Q7--END	


--8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.


--Q8--BEGIN


Select*from(Select top 1*From 
(Select Top 2 Manufacturer_Name,Year([Date])as years,sum(Quantity) as sales
from DIM_MANUFACTURER
inner join DIM_MODEL
on DIM_MODEL.IDManufacturer=DIM_MANUFACTURER.IDManufacturer
inner join FACT_TRANSACTIONS
on FACT_TRANSACTIONS.IDModel=DIM_MODEL.IDModel
Where YEAR([Date])=2009 
group by Manufacturer_Name,Year([Date])
order by sales desc)As X
order by sales asc
Union All
Select top 1*From (Select Top 2 Manufacturer_Name,Year([Date]) As Years,sum(Quantity) as sales
from DIM_MANUFACTURER
inner join DIM_MODEL
on DIM_MODEL.IDManufacturer=DIM_MANUFACTURER.IDManufacturer
inner join FACT_TRANSACTIONS
on FACT_TRANSACTIONS.IDModel=DIM_MODEL.IDModel
Where YEAR([Date])=2010
group by Manufacturer_Name,Year([Date])
order by sales desc)As Z
order by sales asc) As Y









--Q8--END


--9. Show the manufacturers that sold cellphones in 2010 but did not in 2009. 


--Q9--BEGIN

Select Distinct DIM_MANUFACTURER.IDManufacturer,Manufacturer_Name 
from DIM_MANUFACTURER
inner join DIM_MODEL
On DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer
inner join FACT_TRANSACTIONS
On DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
Where Year([Date])=2010 
except
Select Distinct DIM_MANUFACTURER.IDManufacturer,Manufacturer_Name 
from DIM_MANUFACTURER
inner join DIM_MODEL
On DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer
inner join FACT_TRANSACTIONS
On DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
Where Year([Date])=2009



--Q9--END


--10. Find top 10 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.

--Q10--BEGIN

Select *,((Avg_Spend-Previous_Spend)/Avg_Spend)*100 as YoY_Diff 
From (
       Select *, Lag(Avg_Spend,1) Over (partition by Idcustomer order by years) as Previous_spend 
	   From (
               Select Idcustomer,AVG(totalPrice) As Avg_Spend, Avg(Quantity) As Avg_Quan,Year([Date])as years
               From FACT_TRANSACTIONS
               Where IDCustomer In
                          (Select Top 10 IdCustomer
                          From FACT_TRANSACTIONS
                          Group By IDCustomer
                          Order By Sum(totalPrice) Desc)
                Group by year([Date]),IDCustomer
				)As X
		)as Y



















--Q10--END
	