-- 1- View the menu_items table and write a query to find the no of items on the menu?
select count(*) from menu_items

-- 2- What are the least and most expensive items on the menu?
select *
from menu_items
order by price  

-- 3- How many italian dishes are on the menu? And which are the least and most expensive dishes in them?
select count(*) 
from menu_items
where category like 'italian'
-- least and most expensive
select *
from menu_items
where category like 'italian'
order by price
-- 4- How many dishes are in each category? What is the average dish price in each categoey?
select category, count(menu_item_id) as 'num_of_dishes'
from menu_items
group by category
-- avg dish price in each category
select category, avg(price) as 'avg_price'
from Menu_items
group by category



