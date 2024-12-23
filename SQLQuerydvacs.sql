CREATE DATABASE SQLDVACS
USE SQLDVACS
select top 5* from ['Customer Data$']
select top 1 * from ['Orders Data$']
select count(*) from ['Customer Data$']
select count(*) from ['Orders Data$']



--Q1. Total Revenue (order value) 

SELECT ROUND(SUM(ORDER_TOTAL),2) AS TOTAL_REVENUE FROM ['Orders Data$'] 


--Q2. Total Revenue (order value) by top 25 Customers 

select top 25 CUSTOMER_KEY , sum(ORDER_TOTAL) AS TOTAL_REVENUE from ['Orders Data$']
group by CUSTOMER_KEY
order by TOTAL_REVENUE desc

--Q3. Total number of orders - 3 Marks

SELECT COUNT(ORDER_NUMBER) AS ORDER_COUNT FROM ['Orders Data$'] 


--Q4. Total orders by top 10 customers - 3 Marks

SELECT TOP 10 CUSTOMER_KEY, COUNT(ORDER_NUMBER) AS TOTAL_ORDER_10 FROM ['Orders Data$']
GROUP BY CUSTOMER_KEY 
ORDER BY CUSTOMER_KEY



--Q6. Number of customers ordered once - 3 Marks

SELECT COUNT(CNT) AS TOTAL FROM(SELECT CUSTOMER_KEY,COUNT(CUSTOMER_KEY) AS CNT FROM ['Orders Data$']
                          GROUP BY CUSTOMER_KEY
                           HAVING COUNT(CUSTOMER_KEY) = 1) AS CN_




--Q7. Number of customers ordered multiple times - 3 Marks


SELECT COUNT(CUSTOMER_ORDER_MONCE) AS TOTAL_ FROM(SELECT CUSTOMER_KEY,COUNT(ORDER_NUMBER) AS CUSTOMER_ORDER_MONCE 
FROM ['Orders Data$']
 GROUP BY CUSTOMER_KEY
 HAVING COUNT(ORDER_NUMBER) > 1) AS CNS_



--Q8. Number of customers referred to other customers  - 3 Marks


SELECT COUNT(CUSTOMER_ID) AS CUST_CNT FROM ['Customer Data$']
WHERE [Referred Other customers]= 'Y'



--Q9. Which Month have maximum Revenue?  - 3 Marks

select TOP 1 FORMAT(order_date,'MMMM') AS MONTH_ from ['Orders Data$']
group by FORMAT(order_date,'MMMM')
order by round(sum(order_total),2) DESC


--Q10. Number of customers are inactive (that haven't ordered in the last 60 days)  - 3 Marks


SELECT count(*) as IA_CUST FROM (SELECT *,DATEADD(DAY,-60,'2016-7-30') AS DATE_ FROM ['Orders Data$']) AS T
                     WHERE T.ORDER_DATE> '2016-05-31' AND  ORDER_TOTAL =0 OR ORDER_TOTAL IS NULL


--Q11. Growth Rate  (%) in Orders (from Nov’15 to July’16)  - 6 Marks

WITH CTE
AS
 (SELECT MONTH(order_date) as month_,year(order_date) as year,COUNT(ORDER_NUMBER) AS CNT FROM ['Orders Data$']
  GROUP BY MONTH(order_date),YEAR(order_date))
 
 select *,((cnt-lag_)*100)/lag_ as change_ from(SELECT *,lag(cnt,1) over(order by year,month_) as lag_ FROM CTE) as t
 


 --Q12. Growth Rate (%) in Revenue (from Nov'15 to July'16)

 WITH CTE
AS
 (SELECT MONTH(order_date) as month_,year(order_date) as year,SUM(ORDER_TOTAL) AS CNT FROM ['Orders Data$']
 WHERE ORDER_STATUS <> 'cancelled'
  GROUP BY MONTH(order_date),YEAR(order_date))
 
 select *,Round(((cnt-lag_)*100)/lag_,2) as change_ from(SELECT *,lag(cnt,1) over(order by year,month_) as lag_ FROM CTE) as S



 --Q13. What is the percentage of Male customers exists?

 SELECT ((SELECT COUNT(CUSTOMER_ID) FROM ['Customer Data$']
 WHERE GENDER = 'M')*100)/COUNT(CUSTOMER_ID) AS PERC FROM ['Customer Data$']
 

 --Q14. Which location have maximum customers?

SELECT COUNT(CUSTOMER_ID) AS CNT_CUST,LOCATION AS LOC FROM ['Customer Data$']
 GROUP BY Location
 ORDER BY CNT_CUST DESC


--Q15. How many orders are returned? (Returns can be found if the order total value is negative value)

select count(order_number) as return_count from ['Orders Data$']
where ORDER_TOTAL < 0



--Q16. Which Acquisition channel is more efficient in terms of customer acquisition?


 SELECT TOP 1 COUNT(CUSTOMER_ID) AS CNT_CUST, [Acquired Channel] FROM ['Customer Data$']
 GROUP BY [Acquired Channel]
 ORDER BY CNT_CUST DESC



--Q17. Which location having more orders with discount amount?

with cte1_ as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1)

select a.location as loc,count(order_number) as cnt,sum(discount) as total_discount from cte1_ as a
inner join ['Orders Data$'] as b
on a.CUSTOMER_KEY=b.CUSTOMER_KEY
where DISCOUNT >0 and DISCOUNT is not null
group by a.location
order by cnt desc, total_discount desc


--Q18. Which location having maximum orders delivered in delay?


 with cte2_ as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1)


 SELECT TOP 1  COUNT(ORDER_NUMBER) AS CNT,B.LOCATION AS LOC FROM ['Orders Data$'] AS A
 INNER JOIN cte2_ AS B
 ON A.CUSTOMER_KEY=B.CUSTOMER_KEY
 WHERE DELIVERY_STATUS='LATE'
 GROUP BY B.Location
 ORDER BY CNT DESC


 --Q19. What is the percentage of customers who are males acquired by APP channel?

 SELECT ((SELECT COUNT(CUSTOMER_ID) FROM ['Customer Data$']
 WHERE GENDER = 'M' AND [Acquired Channel] = 'APP')*100)/COUNT(CUSTOMER_ID) AS PER FROM ['Customer Data$']


  
 --Q20. What is the percentage of orders got canceled?

SELECT round(((SELECT cast(COUNT(ORDER_STATUS) as float) FROM ['Orders Data$']
WHERE ORDER_STATUS = 'cancelled')*100)/cast(COUNT(ORDER_NUMBER)as float),2) AS PER FROM ['Orders Data$']




--Q21. What is the percentage of orders done by happy customers (Note: Happy customers mean customer who 
--referred other customers)?

SELECT(SELECT COUNT(B.ORDER_NUMBER) FROM ['Customer Data$'] AS A
JOIN 
['Orders Data$'] AS B
ON A.CUSTOMER_KEY= B.CUSTOMER_KEY
WHERE A.[Referred Other customers]= 'Y') 
*100 /CAST(COUNT(ORDER_NUMBER) AS FLOAT) FROM ['Orders Data$'] AS PER

--OR--

 with cte_ as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1),

cte_1 as(select COUNT(Order_number) as cnt from cte_ as a 
inner join ['Orders Data$'] as b
on a.customer_key=b.CUSTOMER_KEY),

cte_2 as(select COUNT(Order_number) as cnt1 from cte_ as a 
inner join ['Orders Data$'] as b
on a.customer_key=b.CUSTOMER_KEY
where [Referred Other customers]= 'Y')

select   round(cast(cnt1 as float)*100/cast(cnt as float),2) as perc
from cte_1
cross join cte_2







 with cte_ as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B)
select * from cte_



--Q22. Which Location having maximum customers through reference?  - 3 Marks

select top 1 location,count(customer_id) as count from ['Customer Data$']
where [Referred Other customers]='y'
group by location
order by count desc


--Q23. What is order_total value of male customers who are belongs to Chennai and Happy customers 
--(Happy customer definition is same in question 21)?  - 3 Marks

with cte_ as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1)

select sum(order_total) as total from cte_ as a
inner join ['Orders Data$'] as b
on a.CUSTOMER_KEY=b.CUSTOMER_KEY
where Location='chennai' and [Referred Other customers]='Y' and Gender='M'




--Q24. Which month having maximum order value from male customers belongs to Chennai?  - 5 Marks


with cte20_ as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1)

select top 1 format(ORDER_DATE,'MMMM') AS Month_,sum(order_total) as total_  from cte20_ as a
inner join ['Orders Data$'] as b
on a.CUSTOMER_KEY=b.CUSTOMER_KEY
where Location='chennai' and Gender='m'
group by format(ORDER_DATE,'MMMM')
order by total_ desc

with cte20_ as (select * from 
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_number = 1
select * from cte20_


WITH cte20_ AS (
    SELECT * 
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_key ORDER BY customer_key) AS row_number 
        FROM ['Customer Data$']
    ) AS T
)
SELECT * 
FROM cte20_;







--Q25. What are number of discounted orders ordered by female customers who were acquired by 
--website from Bangalore delivered on time?  - 3 Marks


with cte12_ as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1)


select count(ORDER_NUMBER) as cnt_do from cte12_ as a
inner join ['Orders Data$'] as b
on a.CUSTOMER_KEY=b.CUSTOMER_KEY
where Location='Bangalore' and [Acquired Channel]='website' and Gender='F' and discount >0 and DELIVERY_STATUS='on-time'



--Q26. Number of orders by month based on order status (Delivered vs. canceled vs. etc.) - Split of order 
--status by month  - 3 Marks

select count(order_number) as cnt,format(order_date,'MMMM') AS MONTH_,ORDER_STATUS from ['Orders Data$']
GROUP BY format(order_date,'MMMM') ,ORDER_STATUS
ORDER BY ORDER_STATUS,MONTH_


--Q27. Number of orders by month based on delivery status  - 3 Marks

select count(order_number) as order_cnt,format(order_date,'MMMM') AS MONTH_,DELIVERY_STATUS from ['Orders Data$']
GROUP BY format(order_date,'MMMM') ,DELIVERY_STATUS
ORDER BY DELIVERY_STATUS DESC,MONTH_ 



--Q28. Month-on-month growth in OrderCount and Revenue (from Nov’15 to July’16)  - 4 Marks

WITH CTE
AS
 (SELECT MONTH(order_date) as month_,year(order_date) as year,SUM(ORDER_TOTAL) AS TOTAL,COUNT(ORDER_NUMBER) AS ORDER_CNT FROM ['Orders Data$']
  GROUP BY MONTH(order_date),YEAR(order_date))
 
select *,Round(((total-lag1_)*100)/lag1_,2) as change_ from (SELECT *,lag(total,1) over(order by year,month_) as lag1_ FROM
 (select *,Round(((ORDER_CNT-lag_)*100)/lag_,2) as change_ from(SELECT *,lag(ORDER_CNT,1) over(order by year,month_) as lag_ FROM CTE) as t)AS s) as p




--Q29. Month-wise split of total order value of the top 50 customers (The top 50 customers need to identified based 
--on their total order value)  - 6 Marks

select round(sum(order_total),2) as total_ORDERS,format(order_date,'MMMM') as month_ FROM ['Orders Data$']
where CUSTOMER_KEY IN (select top 50 CUSTOMER_KEY from ['Orders Data$']
                       group by CUSTOMER_KEY
                        order by sum(ORDER_TOTAL) desc)
Group by format(order_date,'MMMM')
ORDER BY total_ORDERS desc,month_





--Q30. Month-wise split of new and repeat customers. New customers mean, new unique customer additions in any given month  - 6 Marks

with cte as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1),
cte2 as(select a.CUSTOMER_ID,a.CONTACT_NUMBER,a.[Referred Other customers],a.Gender,a.Location,a.[Acquired Channel],b.* from cte as a
         inner join ['Orders Data$'] as b
		 on a.CUSTOMER_KEY=b.CUSTOMER_KEY)

		
select format(order_date,'MMMM') AS MONTH_,CUSTOMER_KEY,COUNT(CUSTOMER_KEY) AS CNT from cte2
		                               GROUP BY format(order_date,'MMMM'),CUSTOMER_KEY
		                                 ORDER BY CNT DESC



--Q31. Write stored procedure code which take inputs as location & month, and the output is total_order value and number
--of orders by Gender, Delivered Status for given location & month. Test the code with different options (12 Marks)

CREATE PROCEDURE lnm @abc varchar(50),@def int
as
with cte as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1),
cte2 as(select a.CUSTOMER_ID,a.CONTACT_NUMBER,a.[Referred Other customers],a.Gender,a.Location,a.[Acquired Channel],b.* from cte as a
         inner join ['Orders Data$'] as b
		 on a.CUSTOMER_KEY=b.CUSTOMER_KEY)

		 select sum(order_total) as total,count(order_number) as cnt,gender,delivery_status from cte2
		 where Location=@abc and month(order_date)=@def
		 group by gender,DELIVERY_STATUS

		 EXEC lnm @abc='bangalore',@def=1




--Q32. Create Customer 360 File with Below Columns using Orders Data & Customer Data (20 Marks)

 with cte as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1),
cte1 as(select a.CUSTOMER_ID,a.CONTACT_NUMBER,a.[Referred Other customers],a.Gender,a.Location,a.[Acquired Channel],b.* from cte as a
         inner join ['Orders Data$'] as b
		 on a.CUSTOMER_KEY=b.CUSTOMER_KEY)
select CUSTOMER_ID,CONTACT_NUMBER,[Referred Other customers],Gender,Location,[Acquired Channel],count(order_number) as [No.of Orders],
SUM(order_total) as [Total Order_vallue],SUM(CASE WHEN DISCOUNT>0 THEN 1 ELSE 0 END) as [Total orders with discount],
SUM(CASE WHEN DELIVERY_STATUS='late' THEN 1 ELSE 0 END) as [Total Orders received late],
SUM(CASE WHEN ORDER_STATUS='returned' THEN 1 ELSE 0 END) as [Total Orders returned], Max(order_total) as [Maximum Order value],
Min(order_date) as [First Transaction Date],max(order_date) as [Last Transaction Date],
datediff(month,min(order_date),max(order_date)) as Tenure_Months,
count(CASE WHEN order_total=0 THEN 1 ELSE 0 END) as [No_of_orders_with_Zero_value]
from cte1
group by CUSTOMER_ID,CONTACT_NUMBER,[Referred Other customers],Gender,Location,[Acquired Channel]



--Q33. Total Revenue, total orders by each location (2 Marks)


with cte22 as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1),
cte1 as(select a.CUSTOMER_ID,a.CONTACT_NUMBER,a.[Referred Other customers],a.Gender,a.Location,a.[Acquired Channel],b.* from cte22 as a
         inner join ['Orders Data$'] as b
		 on a.CUSTOMER_KEY=b.CUSTOMER_KEY)

select location,sum(order_total) as total,count(order_number) as total_ from cte1
group by location




--Q34. Total revenue, total orders by customer gender (2 Marks)


with cte as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1),
cte2 as(select a.CUSTOMER_ID,a.CONTACT_NUMBER,a.[Referred Other customers],a.Gender,a.Location,a.[Acquired Channel],b.* from cte as a
         inner join ['Orders Data$'] as b
		 on a.CUSTOMER_KEY=b.CUSTOMER_KEY)
select GENDER,SUM(ORDER_TOTAL) AS TOTAL,COUNT(ORDER_NUMBER) AS CNT from cte2
GROUP BY GENDER




--Q35. Which location of customers cancelling orders maximum? (3 Marks)


with cte55 as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1),
cte25 as(select a.CUSTOMER_ID,a.CONTACT_NUMBER,a.[Referred Other customers],a.Gender,a.Location,a.[Acquired Channel],b.* from cte55 as a
         inner join ['Orders Data$'] as b
		 on a.CUSTOMER_KEY=b.CUSTOMER_KEY)
SELECT LOCATION,COUNT(ORDER_NUMBER) AS CNT FROM cte25
where order_status = 'cancelled'
group by location
order by cnt desc


--Q36. Total customers, Revenue, Orders by each Acquisition channel (3 Marks)

with cte1_ as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1),
cte2_ as(select a.CUSTOMER_ID,a.CONTACT_NUMBER,a.[Referred Other customers],a.Gender,a.Location,a.[Acquired Channel],b.* from cte1_ as a
         inner join ['Orders Data$'] as b
		 on a.CUSTOMER_KEY=b.CUSTOMER_KEY)

		 select [Acquired Channel],count(customer_key) as cnt,sum(order_total) as total, count(order_number) as cnt_2 from cte2_
		 group by [Acquired Channel]



--Q37. Which acquisition channel is good in terms of revenue generation, maximum orders, repeat purchasers? (5 marks)

with cte as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1),
cte2 as(select a.CUSTOMER_ID,a.CONTACT_NUMBER,a.[Referred Other customers],a.Gender,a.Location,a.[Acquired Channel],b.* from cte as a
         inner join ['Orders Data$'] as b
		 on a.CUSTOMER_KEY=b.CUSTOMER_KEY)

		 select top 1  [Acquired Channel] from cte2
		 group by [Acquired Channel]
		 having count(customer_key)>1
		 order by sum(order_total) desc, count(order_number) desc


--Q38. Write User Defined Function (stored procedure) which can take input table which create two tables with numerical variables and categorical variables separately (10 Marks)


CREATE PROCEDURE abc @abc varchar(40)
  AS
   SELECT ORDER_STATUS,DELIVERY_STATUS,ORDER_NUMBER,CUSTOMER_KEY,ORDER_DATE FROM ['Orders Data$']
   where DELIVERY_STATUS=@abc
   

  CREATE PROCEDURE def @abc1 int
  AS
   SELECT DISCOUNT,ORDER_TOTAL FROM ['Orders Data$']
   where order_total>=@abc1

   Exec abc @abc='Late'
   Exec def @abc1=0




--Q39. Prepare at least 10 additional analysis on your own? (40 Marks)  - Mandatory


--Top 5 customers with their monthly total orders

SELECT top 5 CUSTOMER_KEY,FORMAT(ORDER_DATE,'MMMM')AS month_ FROM ['Orders Data$']
GROUP BY CUSTOMER_KEY,FORMAT(ORDER_DATE,'MMMM')
ORDER BY count(order_number) desc


--Maximum female customers are being acquired through 'website' channel

select top 1 [Acquired Channel] from ['Customer Data$']
where gender ='f'
group by [Acquired Channel]
order by count(gender) desc


--November had minimum revenue

select TOP 1 format(order_date,'MMMM') AS Month_ from ['Orders Data$']
GROUP BY format(order_date,'MMMM')
ORDER BY SUM(ORDER_TOTAL)


--Others location had minimum returned orders 

with cte as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1),
cte2 as(select a.CUSTOMER_ID,a.CONTACT_NUMBER,a.[Referred Other customers],a.Gender,a.Location,a.[Acquired Channel],b.* from cte as a
         inner join ['Orders Data$'] as b
		 on a.CUSTOMER_KEY=b.CUSTOMER_KEY)

		 select Top 1 location from cte2
		 where order_total<0
		 group by location
		 order by count(customer_key)


-- Average order value through App is greater than Website


with cte as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1),
cte2 as(select a.CUSTOMER_ID,a.CONTACT_NUMBER,a.[Referred Other customers],a.Gender,a.Location,a.[Acquired Channel],b.* from cte as a
         inner join ['Orders Data$'] as b
		 on a.CUSTOMER_KEY=b.CUSTOMER_KEY)

		 select [Acquired Channel],avg(order_total) as avg_ from cte2 
		 group by [Acquired Channel]



--Maximum orders returned from Chennai

with cte_ as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1),
cte1_ as(select a.CUSTOMER_ID,a.CONTACT_NUMBER,a.[Referred Other customers],a.Gender,a.Location,a.[Acquired Channel],b.* from cte_ as a
         inner join ['Orders Data$'] as b
		 on a.CUSTOMER_KEY=b.CUSTOMER_KEY)

		 select Top 1 location from cte1_
		 where order_total<0
		 group by location
		 order by count(customer_key)  desc


--Location with the minimum on-time delivery


with cte as (select * from 
(select *, row_number() over (partition by customer_key order by row_number desc) as row_ from
(select *, row_number() over (partition by customer_key order by customer_key ) as row_number from ['Customer Data$']) as T) as B
where row_ = 1),
cte2 as(select a.CUSTOMER_ID,a.CONTACT_NUMBER,a.[Referred Other customers],a.Gender,a.Location,a.[Acquired Channel],b.* from cte as a
         inner join ['Orders Data$'] as b
		 on a.CUSTOMER_KEY=b.CUSTOMER_KEY)

		 select top 1 location from cte2
		 where order_status ='delivered'
		 group by location
		 order by count(order_number) 


--Average revenue per order 

select avg(order_total) as avg_,ORDER_NUMBER from ['Orders Data$']
group by ORDER_NUMBER
order by avg_ desc


--number of customers who didn't refer others

select count([Referred Other customers]) as count_nr from ['Customer Data$']
where [Referred Other customers]='n'


--details by order_status and delivery_status

CREATE PROCEDURE ord @abc varchar(50),@def varchar(40)
as
select * from ['Orders Data$']
where ORDER_STATUS = @abc and DELIVERY_STATUS =@def


EXEC ord @abc='delivered' , @def='late'

--end--