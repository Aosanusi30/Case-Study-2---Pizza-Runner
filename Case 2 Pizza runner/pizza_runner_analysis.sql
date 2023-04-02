-- Running from my pizza_runner 
Use pizza_runner 

--A. Pizza Metrics
--How many pizzas were ordered?
--How many unique customer orders were made?
--How many successful orders were delivered by each runner?
--How many of each type of pizza was delivered?
--How many Vegetarian and Meatlovers were ordered by each customer?
--What was the maximum number of pizzas delivered in a single order?
--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
--How many pizzas were delivered that had both exclusions and extras?
--What was the total volume of pizzas ordered for each hour of the day?
--What was the volume of orders for each day of the week?

-- Opening all tables in the db
-- Cleaning the dataset 
SELECT *
FROM [dbo].[customer_orders]
-- using update to fill the empty exclusion column
update [dbo].[customer_orders]
set exclusions = CASE WHEN exclusions = '' THEN Null 
					  WHEN exclusions = 'null' THEN Null 
					  Else exclusions End; 

-- using update to fill the empty extra column 
Update [dbo].[customer_orders]
Set extras = CASE WHEN extras = '' THEN Null
				  WHEN extras = null THEN Null 
				  ELSE extras END; 



-- Cleaning the Pickup_time, distance, duration and cancellation column 
SELECT * 
FROM [dbo].[runner_orders]

Update runner_orders
set pickup_time = CASE	WHEN pickup_time = '' THEN Null 
						WHEN pickup_time = ' ' THEN Null 
						WHEN pickup_time = 'null' THEN Null 
						ELSE pickup_time 
						END; 

Update runner_orders
SET duration = CASE	WHEN duration = '' THEN Null 
						WHEN duration = ' ' THEN Null 
						WHEN duration = 'null' THEN Null 
						ELSE duration 
						END; 

Update runner_orders
SET distance = CASE	WHEN distance = '' THEN Null 
						WHEN distance = ' ' THEN Null 
						WHEN distance = 'Null' THEN Null 
						ELSE distance 
						END; 

Update runner_orders
SET cancellation = CASE	WHEN cancellation = '' THEN Null 
						WHEN cancellation = ' ' THEN Null 
						WHEN cancellation = 'Null' THEN Null 
						ELSE cancellation 
						END; 

-- Removing the units in all the figures in distance
update runner_orders 
SET distance = REPLACE(distance, 'km', '')
where distance like '%km'

-- Renaming distance to distance (km)
Exec sp_rename 'runner_orders.distance', 'distance (km)', 'COLUMN'

-- Removing the units in all the figures in duration 
UPDATE runner_orders
SET duration = replace(duration,'minutes', '')
where duration like '%minutes'

UPDATE runner_orders
SET duration = replace(duration,'minute', '')
where duration like '% minute'

UPDATE runner_orders
SET duration = replace(duration,'mins', '')
where duration like '% mins'

UPDATE runner_orders
SET duration = replace(duration,'mins', '')
where duration like '%mins';

-- Changing all data type to varchar
-- pizza_names 
alter table pizza_names 
alter column pizza_name varchar(60)


-- Question One
--How many pizzas were ordered?
SELECT count(pizza_id) as Number_of_pizza_ordered
FROM customer_orders

-- Question Two
--How many unique customer orders were made?
SELECT count(DISTINCT order_id) as unique_order
FROM customer_orders


-- Question Three
--How many successful orders were delivered by each runner?
SELECT runner_id, count(runner_id) as Successful_order_runner
FROM runner_orders

where cancellation is null 

group by runner_id;


-- Question Four
--How many of each type of pizza was delivered?
WITH typeofpizzadelivered AS (
SELECT r.order_id, c.pizza_id, p.pizza_name, 
rank () OVER (PARTITION BY COUNT(Cancellation) order by pizza_name) as deliver
from customer_orders c

JOIN pizza_names P
ON C.pizza_id = P.pizza_id

JOIN runner_orders r
on c.order_id = r.order_id

where cancellation is null

group by cancellation, pizza_name, c.pizza_id, r.order_id

)

select count(pizza_id) as Delivered, pizza_name 
from typeofpizzadelivered

group by pizza_id, pizza_name

order by Delivered


-- Question Five
--How many Vegetarian and Meatlovers were ordered by each customer?
SELECT C.customer_id,
	COUNT(CASE WHEN p.pizza_name = 'Meatlover' THEN 1
		ELSE 0 
		END) as a,
	COUNT(CASE WHEN p.pizza_name = 'Vegetarian'  THEN 1
			ELSE 0 
		END) as a
FROM customer_orders c

JOIN pizza_names p 
ON c.pizza_id = p.pizza_id

GROUP BY 

-- Question Six
--What was the maximum number of pizzas delivered in a single order?
SELECT top 1 customer_id, count(order_id) as Maximum_single_order
FROM customer_orders

group by customer_id, order_id

order by Maximum_single_order desc;

-- Question Seven
--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer_id, count(r.order_id) as deliveredpizza, sum(
case when (exclusions is not null or extras is not null) then 1
		else 0
		end) as cha,

		sum(case
		when (exclusions is null and extras is null) then 1
		else 1
		end) as change
FROM customer_orders c

join runner_orders r
on c.order_id = r.order_id

group by customer_id

-- Question Eight
--How many pizzas were delivered that had both exclusions and extras?
-- 1 pizzas that had both exclusions and extras?
SELECT count(*) as orders_with_both_exclusions_and_extras
FROM customer_orders

where exclusions is not null and extras is not null


-- Question Nine
--What was the total volume of pizzas ordered for each hour of the day?
WITH Volume_per_hour (Order_id, Customer_id, Pizza_id, Exclusions, Extras, order_time, hours) 

AS
(
SELECT *, Datepart(hour, order_time) as Hours 
FROM customer_orders
) 

select count(*) as Volumn_order_per_hour, hours
from Volume_per_hour

group by hours;



-- Question Ten
--What was the volume of orders for each day of the week?
 --
WITH Weekdays ( Order_id, Customer_id, Pizza_id, Exclusions, Extras, Order_time, days_of_week)
AS
(
SELECT *,  
datename(dw, order_time) as days_of_week
FROM customer_orders
)

select days_of_week, Count (days_of_week) As count_of_days_of_week_orders
from weekdays wd

group by days_of_week


