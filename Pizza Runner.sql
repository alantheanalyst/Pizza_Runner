-- Pizza Metrics
--1
select count(pizza_id) pizza_count
from customer_orders

--2
select count(distinct order_id) order_count
from customer_orders

--3
update runner_orders
set cancellation = ''
where cancellation in (null,'null')

select runner_id ,count(*) succesful_orders
from runner_orders
where cancellation is null
group by runner_id

--4 
alter table pizza_names
alter column pizza_name varchar(10)

select pizza_name, count(c.order_id) pizza_count
from customer_orders c
join pizza_names n
on c.pizza_id = n.pizza_id
join runner_orders r
on c.order_id = r.order_id
where cancellation is null
group by pizza_name

--5
select customer_id, pizza_name, count(order_id) pizza_count
from customer_orders c
join pizza_names n
on c.pizza_id = n.pizza_id
group by customer_id, pizza_name

--6 
select top 1 c.order_id, count(c.order_id) pizza_count
from customer_orders c
join runner_orders r
on c.order_id = r.order_id
where cancellation is null
group by c.order_id
having count(c.order_id) > 1
order by pizza_count desc

--7 
select customer_id,
sum(case
when extras is not null or exclusions is not null then 1
else 0
end) at_least_1_change,
sum(case
when extras is null and exclusions is null then 1
else 0
end) no_changes
from customer_orders c
join runner_orders r
on c.order_id = r.order_id
where cancellation is null
group by customer_id

--8
select count(*) order_count
from customer_orders c
join runner_orders r
on c.order_id = r.order_id
where extras is not null and exclusions is not null and cancellation is null

--9
select count(*) order_count, datepart(hour from order_time) hour
from customer_orders
group by order_id, order_time
order by hour

--10
select format(dateadd(day, 2, order_time), 'dddd') day_of_week, count(*) order_count
from  customer_orders
group by format(dateadd(day, 2, order_time), 'dddd')
order by day_of_week desc

--Runner and customer experience
--1
select count(runner_id) runner_registration, datepart(week, registration_date) registration_week
from runners
group by datepart(week, registration_date)
order by registration_week
-- this was taken from https: //medium.com/analytics-vidhya/8-week-sql-challenge-case-study-2-pizza-runner-ba32f0a6f9fb
-- Most runners registed on the second week.

--2
select [distance km]
from runner_orders

update runner_orders
set [distance km] = '20' where [distance km] = '20km'

update runner_orders
set [distance km] = '13.4' where [distance km] = '13.4km'

update runner_orders
set [distance km] = '25' where [distance km] = '25km'

update runner_orders
set [distance km] = '23.4' where [distance km] = '23.4 km'

update runner_orders
set [distance km] = '10' where [distance km] = '10km'

alter table runner_orders
alter column [distance km] float

select [duration minutes]
from runner_orders

update runner_orders
set [duration minutes] = '32' where [duration minutes] = '32 minutes'

update runner_orders
set [duration minutes] = '27' where [duration minutes] = '27 minutes'

update runner_orders
set [duration minutes] = '20' where [duration minutes] = '20 mins'

update runner_orders
set [duration minutes] = '25' where [duration minutes] = '25mins'

update runner_orders
set [duration minutes] = '15' where [duration minutes] = '15 minute'

update runner_orders
set [duration minutes] = '10' where [duration minutes] = '10minutes'

alter table runner_orders
alter column duration int

-- I changed distance to [distance km] and duration to [duration minutes]

alter table runner_orders
alter column pickup_time datetime

select runner_id, abs(avg(datepart(minute from order_time) - datepart(minute from pickup_time))) avg_time
from runner_orders r
join customer_orders c
	on r.order_id = c.order_id
group by runner_id

--3
select count(pizza_id) pizza_count, abs(datepart(minute from order_time) - datepart(minute from pickup_time)) time
from customer_orders c
join runner_orders r
	on c.order_id = r.order_id
where pickup_time is not null
group by c.order_id, pizza_id, order_time, pickup_time
order by time
-- Their were instances were the someone ordered more than one pizza the time between order and pickupt took longer.

--4. 
select customer_id, avg([distance km]) avg_distance
from runner_orders r
join customer_orders c
	on r.order_id = c.order_id
group by customer_id
-- customer 101, 103, and 105 seem to be far away or make a lot of orders.

--5.
select max([duration minutes]) - min([duration minutes]) difference_between_longest_and_shortest_orders
from runner_orders r
join customer_orders c
	on r.order_id = c.order_id

--6 
select runner_id, order_id, avg([distance km]/[duration minutes]) avg_speed
from runner_orders
where cancellation is null
group by runner_id, order_id

--7 
select runner_id,
round(100* sum(
case
	when cancellation is not null then 0
	else 1
end)/count(*), 0) successful_orders
from runner_orders
group by runner_id

-- runner 1 had an 100% successful delivery rate, runner 2 had a 75% successful delivery rate, and runner 3 had a 50% successful delivery rate.

--Ingredient optimization 
--1 
select *
from pizza_toppings

select order_id, c.pizza_id, pizza_name, exclusions, extras, toppings,
case
	when exclusions is null and extras is null and pizza_name = 'Meatlovers' then 'Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami'
	when order_id in (4, 9) then 'Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami'
	when order_id = 10 then 'Bacon, Beef, Cheese, Chicken, Pepperoni, Salami'
	else 'Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce'
end Topping_Names
from pizza_names n
join customer_orders c
	on n.pizza_id = c.pizza_id
join pizza_recipes r
	on c.pizza_id = r.pizza_id

--2 
select order_id, c.pizza_id, pizza_name, extras
from customer_orders c
join pizza_names n
	on c.pizza_id = n.pizza_id
join pizza_recipes r
	on n.pizza_id = r.pizza_id
where extras is not null

select *
from pizza_toppings


create table #temp1 (
order_id int,
pizza_id int,
extras int
)

insert into #temp1 values 
(5, 1, 1),
(7, 2, 1),
(9, 1, 1),
(9, 1, 5),
(10, 1, 1),
(10, 1, 4)

select top 1 count(extras) topping_count,
case
	when extras = 1 then 'Bacon'
	when extras = 4 then 'Cheese'
	else 'Chicken'
end topping
from #temp1
group by extras
-- Bacon is the most commonly added extra topping.

--3
select order_id, c.pizza_id, exclusions
from customer_orders c
join pizza_names n
	on c.pizza_id = n.pizza_id
join pizza_recipes r
	on n.pizza_id = r.pizza_id
where exclusions is not null

select *
from pizza_toppings

create table #temp2 (
order_id int,
pizza_id int,
exclusions int
)

insert into #temp2 values
(4, 1, 4),
(4, 1, 4),
(4, 2, 4),
(9, 1, 4),
(10, 1, 2),
(10, 1, 6)

select top 1 count(exclusions) topping_count,
case
	when exclusions = 4 then 'Cheese'
	when exclusions = 2 then 'BBQ Sauce'
	else 'Mushrooms'
end topping
from #temp2
group by exclusions
order by topping_count desc
-- Cheese is the most excluded topping.

--4
select *
from pizza_toppings

select *
from pizza_recipes

select order_id, c.pizza_id, exclusions, extras,
case
	when order_id in (1, 2, 8) then 'Meat Lovers - Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami'
	when order_id = 3 and c.pizza_id = 1 then 'Meat Lovers - Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami'
	when order_id = 3 and c.pizza_id = 2 then 'Vegetarian - Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce'
	when order_id = 4 and c.pizza_id = 1 and exclusions = '4' then 'Meat Lovers - Excludes Cheese, Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami'
	when order_id = 4 and c.pizza_id = 2 and exclusions = '4' then 'Vegetarian - Excludes Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce'
	when order_id = 5 and c.pizza_id = 1 and extras = '1' then 'Meat Lovers - Extra Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami'
	when order_id = 6 and c.pizza_id = 2 then 'Vegetarian - Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce'
	when order_id = 7 then 'Vegetarian - Extra Bacon, Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce'
	when order_id = 9 then 'Meat Lovers - Excludes Cheese, Extra Bacon, Extra Chicken, BBQ Sauce, Beef, Mushrooms, Pepperoni, Salami'
	when order_id = 10 and c.pizza_id = 1 and exclusions is null then 'Meat Lovers - Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami'
	else 'Meat Lovers - Excludes BBQ Sauce, Excludes Mushrooms, Extra Bacon, Extra Cheese, Beef, Chicken, Mushrooms, Pepperoni, Salami'
end order_item
from customer_orders c
join pizza_names n
	on c.pizza_id = n.pizza_id

-- 5
select order_id, c.pizza_id, exclusions, extras,
case
	when order_id in (1, 2, 8) then 'Meat Lovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami'
	when order_id = 3 and c.pizza_id = 1 then 'Meat Lovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami'
	when order_id = 3 and c.pizza_id = 2 then 'Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce'
	when order_id = 4 and c.pizza_id = 1 and exclusions = '4' then 'Meat Lovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami'
	when order_id = 4 and c.pizza_id = 2 and exclusions = '4' then 'Vegetarian: Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce'
	when order_id = 5 and c.pizza_id = 1 and extras = '1' then 'Meat Lovers: 2xBacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami'
	when order_id = 6 and c.pizza_id = 2 then 'Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce'
	when order_id = 7 then 'Vegetarian: 	2xBacon, Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce'
	when order_id = 9 then 'Meat Lovers: 2xBacon, 2xChicken, BBQ Sauce, Beef, Mushrooms, Pepperoni, Salami'
	when order_id = 10 and c.pizza_id = 1 and exclusions is null then 'Meat Lovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami'
	else 'Meat Lovers: 2xBacon, 2xCheese, Beef, Chicken, Mushrooms, Pepperoni, Salami'
end order_item
from customer_orders c
join pizza_names n
	on c.pizza_id = n.pizza_id

-- 6
select c.order_id, customer_id, c.pizza_id, exclusions, extras, pizza_name
from customer_orders c
join runner_orders r
	on c.order_id = r.order_id
join pizza_names n
	on c.pizza_id = n.pizza_id
where cancellation is null

select *
from pizza_recipes

select * 
from pizza_toppings


;with ingredient_cte as ( select c.order_id, customer_id, c.pizza_id, exclusions, extras,
case
	when extras = '1' then 2
	when extras = '1, 4' then 2
	when c.pizza_id = 1 then 1
	else 0 
end bacon,
case
	when exclusions = '2, 6' then 0
	when c.pizza_id = 1 then 1
	else 0 
end bbq_sauce,
case
	when c.pizza_id = 1 then 1
	else 0 
end beef,
case
	when exclusions = '4' then 0
	when extras = '1, 4' then 2
	when c.pizza_id in (1, 2) then 1
end cheese,
case
	when c.pizza_id = 1 then 1
	else 0 
end chicken,
case
	when exclusions = '2, 6' then 0
	when c.pizza_id = 2 then 1
	else 0
end mushrooms,
case
	when c.pizza_id = 2 then 1
	else 0 
end onions,
case
	when c.pizza_id = 1 then 1
	else 0
end pepperoni,
case
	when c.pizza_id = 2 then 1
	else 0
end peppers,
case
	when c.pizza_id = 1 then 1
	else 0 
end salami,
case
	when c.pizza_id = 2 then 1
	else 0
end tomatoes,
case
	when  c.pizza_id = 2 then 1
	else 0
end tomato_sauce
from customer_orders c
join runner_orders r
	on c.order_id = r.order_id
join pizza_names n
	on c.pizza_id = n.pizza_id
where cancellation is null
)
select sum(bacon) bacon, sum(cheese) cheese, sum(beef) beef, sum(chicken) chicken, sum(pepperoni) pepperoni, 
sum(salami) salami, sum(bbq_sauce) bbq_sauce, sum(mushrooms) mushrooms, sum(onions) onions, sum(peppers) peppers, 
sum(tomatoes) tomatoes, sum(tomato_sauce) tomato_sauce
from ingredient_cte
-- Bacon and cheese are the most frequntley added toppings.

-- Pricing and Ratings
--1.
select
sum(case
	when pizza_id = 1 then 12
	else 10
end) total_price
from customer_orders c
join runner_orders r
	on c.order_id = r.order_id
where cancellation is null
-- Pizza runner made a total of $108

--2 
select
sum(case
	when pizza_id = 1 and extras is null then 12
	when pizza_id = 2 and extras is null then 10
	when extras = '1, 4' then 14
	when pizza_id = 1 and extras is not null then 13
	when pizza_id = 2 and extras is not null then 11
end) total_price
from customer_orders c
join runner_orders r
	on c.order_id = r.order_id
where cancellation is null
-- If extra toppings cost $1 Piza runner's total revenue would have been $142

--3 & 4. 
select customer_id, c.order_id, runner_id,
case
	when [duration minutes] <= 15 then 5
	when [duration minutes] between 20 and 27 then 4
	when [duration minutes] = 40 then 2
	else 3
end rating,
order_time, pickup_time, 
abs(datepart(minute from pickup_time) - datepart(minute from order_time)) time_between_order_and_pickup_minutes, [duration minutes],
avg([distance km]/[duration minutes]) avg_speed, count(pizza_id) total_pizzas
from customer_orders c
join runner_orders r
	on c.order_id = r.order_id
where cancellation is null
group by customer_id, c.order_id, runner_id, order_time, pickup_time, [duration minutes]

--5.
;with price_cte as (
select [distance km], runner_id,
case
	when pizza_id = 1 then 12
	else 10
end price,
case
	when runner_id in (1, 2, 3) then ([distance km] * .30)
end runner_paycheck
from customer_orders c
join runner_orders r
	on c.order_id = r.order_id
where cancellation is null)
select 
sum(case
	when price in (12, 10) then (price - runner_paycheck)
end) total_price
from price_cte
-- If runners made 0.30 per km then Pizza Runner would have $73.38 left.

-- Bonus
insert into pizza_names values 
(3, 'Supreme')

insert into pizza_recipes values 
(3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12')
