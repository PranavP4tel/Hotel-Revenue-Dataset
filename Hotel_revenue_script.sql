create database sql_project1;
use sql_project1;

#Obtaining data from all tables
create table hotels as (
select * from data_2018
union
select * from data_2019
union
select * from data_2020
);

#Revenue by year and hotel type without discount
select 
arrival_date_year, hotel,
round(sum((stays_in_weekend_nights + stays_in_week_nights)*adr)) as 'revenue by year'  
from hotels
group by arrival_date_year, hotel
order by arrival_date_year;

#Total check ins at hotels based on month (Not using 2018 due to incomplete data)
select arrival_date_month, count(arrival_date_month) as 'Total_Check_Ins'
from hotels
where arrival_date_year!=2018
group by arrival_date_month;

#Total check ins at hotels based on day of the month
select arrival_date_day_of_month, count(arrival_date_day_of_month) as 'Total_Check_Ins'
from hotels
group by arrival_date_day_of_month
order by Total_Check_Ins desc;

#Reservation distribution for countries
select country, count(country) as Count from hotels 
group by country
order by Count desc;

#Checking market segment for online travel agent booking percentage
select market_segment, count(market_segment) as Count, (count(market_segment)/100748)*100 as Percentage
from hotels 
group by market_segment;

#Reserved room type distribution for hotels
select hotel, reserved_room_type, count(reserved_room_type) as Count
from hotels
group by hotel, reserved_room_type
order by hotel, Count desc;

#Count of reserved room equal to assigned room
select count(*) as Room_Match, (count(*)/100748)*100 as Percent from hotels
where reserved_room_type = assigned_room_type;

#Creating a combined table for further evaluation
create table hotels_merged as 
select hotels.*, market_segment.Discount, meal_cost.Cost from hotels
left join market_segment on 
hotels.market_segment = market_segment.market_segment
left join meal_cost on
hotels.meal = meal_cost.meal;

#Total Revenue after discount
select sum(stays_in_weekend_nights+stays_in_week_nights*adr*(1-Discount)) as Total_Revenue from hotels_merged;

#Total Revenue after discount for hotels
select hotel, sum(stays_in_weekend_nights+stays_in_week_nights*adr*(1-Discount)) as Total_Revenue 
from hotels_merged
group by hotel;

#Total Revenue based on country and hotel
select country, hotel, round(sum(stays_in_weekend_nights+stays_in_week_nights*adr*(1-Discount)),2) as Total_Revenue 
from hotels_merged
where country is not null
group by country, hotel
order by country, hotel;

#Popularity of Meals
select meal, count(meal) as Count from hotels_merged
group by meal
order by Count desc;

#Popular Room Types
select reserved_room_type, count(reserved_room_type) as Count from hotels_merged
group by reserved_room_type
order by Count desc;

#Combination of meal and room type preferred
select reserved_room_type, meal, count(*) as Count
from hotels_merged
group by reserved_room_type, meal
order by Count desc
limit 20;

#Total revenue calculated with meal cost
select sum(stays_in_weekend_nights+stays_in_week_nights*(adr+Cost)*(1-Discount)) as Total_Revenue 
from hotels_merged;

#Total revenue calculated with meal cost by hotels
select hotel, sum(stays_in_weekend_nights+stays_in_week_nights*(adr+Cost)*(1-Discount)) as Total_Revenue 
from hotels_merged
group by hotel;

#Query to import data in PowerBI
select * from hotels
left join market_segment on 
hotels.market_segment = market_segment.market_segment
left join meal_cost on
hotels.meal = meal_cost.meal;