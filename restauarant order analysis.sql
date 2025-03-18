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

select * from order_details
-- 1- Combine the menu_items table and order_details table into a single table.
select *
from menu_items m join order_details d
     on m.menu_item_id = d.item_id;
     
-- 2- What were the least and most ordered items? What category were they in? 
select item_name, category, count(order_details_id) as num_of_purchases
from order_details d left join menu_items m
     on d.item_id = m.menu_item_id 
group by item_name, category
order by num_of_purchases;

-- 3- What were the top 5 orders that spent the most money
select order_id, sum(price) as 'total_spend'
from order_details d left join menu_items m
     on d.item_id = m.menu_item_id
group by order_id
order by total_spend desc
limit 5;

     
-- 4- View the details of the highest spent order. What insights can you gather from the results?
select category, count(item_id) as 'num_of_items'
from order_details d left join menu_items m
     on d.item_id = m.menu_item_id
where order_id = 440     
group by category;
-- the highest spend order bought a lot of items from the italian category


-- 5- View the details of the top 5 highest spent order. What insights can you gather
select category, count(item_id) as 'num_of_items'
from order_details d left join menu_items m
     on d.item_id = m.menu_item_id
where order_id in (440, 275, 1957, 330, 2675)     
group by category;
-- italian food is purchased the most in the top 5 highest spend orders






