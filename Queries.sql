--This are the questions we gonna answer along with the sql queries--
  
Basic:
--1.Retrieve the total number of orders placed.
      select count(*) total_orders 
      from pizzahut.orders ;

--2.Calculate the total revenue generated from pizza sales.
      select round(sum(order_details.quantity * pizzas.price),2)
      as total_sales
      from pizzahut.order_details 
      join pizzahut.pizzas
      on order_details.pizza_id = pizzas.pizza_id ;

--3.Identify the highest-priced pizza.
      select pizza_types.name, pizzas.price
      from pizzahut.pizzas
      join pizzahut.pizza_types
      on pizzas.pizza_type_id = pizza_types.pizza_type_id 
      order by pizzas.price desc limit 1;

--4.Identify the most common pizza size ordered.
      select pizzas.size, count(order_details.order_details_id)
      as size_count
      from pizzahut.pizzas
      join pizzahut.order_details
      on pizzas.pizza_id = order_details.pizza_id
      group by pizzas.size
      order by size_count desc;  
--5.List the top 5 most ordered pizza types along with their quantities.
      select pizza_types.name, sum(order_details.quantity) 
      as quantity
      from pizzahut.pizza_types
      join pizzahut.pizzas
      on pizza_types.pizza_type_id = pizzas.pizza_type_id
      join pizzahut.order_details
      on pizzas.pizza_id = order_details.pizza_id 
      group by pizza_types.name 
      order by quantity desc
      limit 5;

Intermediate:
--1.Join the necessary tables to find the total quantity of each pizza category ordered.
      select pizza_types.category, sum(order_details.quantity) 
      as quantity
      from pizzahut.pizza_types join pizzahut.pizzas
      on pizza_types.pizza_type_id = pizzas.pizza_type_id
      join pizzahut.order_details
      on order_details.pizza_id = pizzas.pizza_id
      group by pizza_types.category
      order by quantity desc ;  

--2.Determine the distribution of orders by hour of the day.
      select hour(order_time) as hour, 
      count(order_id) as order_count
      from pizzahut.orders
      group by hour(order_time) ;

--3.Join relevant tables to find the category-wise distribution of pizzas.
      select category, count(name) 
      from pizzahut.pizza_types
      group by category ;

--4.Group the orders by date and calculate the average number of pizzas ordered per day.
      select round(avg(quantity),0) as avg_pizza_order_per_day from 
      (select orders.order_date, sum(order_details.quantity) as quantity
      from pizzahut.orders
      join pizzahut.order_details
      on orders.order_id = order_details.order_id
      group by orders.order_date) as order_quantity;  

--5.Determine the top 3 most ordered pizza types based on revenue.
      select pizza_types.name, 
      sum(order_details.quantity*pizzas.price) as revenue
      from pizzahut.pizza_types join pizzahut.pizzas
      on pizza_types.pizza_type_id = pizzas.pizza_type_id
      join pizzahut.order_details
      on order_details.pizza_id = pizzas.pizza_id
      group by pizza_types.name
      order by revenue desc
      limit 3 ;

Advanced:
--1.Calculate the percentage contribution of each pizza type to total revenue.
      select pizza_types.category, 
      round(sum(order_details.quantity*pizzas.price)/
      	(select round(sum(order_details.quantity * pizzas.price),2) as total_sales
      	from pizzahut.order_details 
      	join pizzahut.pizzas
      	on order_details.pizza_id = pizzas.pizza_id)*100,2) 
          as percentage_contribution 
      from pizzahut.pizza_types join pizzahut.pizzas
      on pizza_types.pizza_type_id = pizzas.pizza_type_id
      join pizzahut.order_details
      on order_details.pizza_id = pizzas.pizza_id
      group by pizza_types.category
      order by percentage_contribution desc ;  

--2.Analyze the cumulative revenue generated over time.
      select order_date,
      sum(revenue) over (order by order_date) as cum_revenue
      from
      	(select orders.order_date, 
      	sum(order_details.quantity*pizzas.price) as revenue
      	from pizzahut.orders
      	join pizzahut.order_details
      		on orders.order_id = order_details.order_id
      	join pizzahut.pizzas
      	on pizzas.pizza_id = order_details.pizza_id
      	group by orders.order_date) as sales ;

--3.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
      select category, name, revenue, ranking
      from
      (select category, name, revenue,
      rank() over(partition by category order by revenue desc) as ranking
      from
      (select pizza_types.category, pizza_types.name,
      sum((order_details.quantity) * pizzas.price) as revenue
      from pizzahut.pizza_types join pizzahut.pizzas
      on pizza_types.pizza_type_id = pizzas.pizza_type_id
      join pizzahut.order_details
      on order_details.pizza_id = pizzas.pizza_id
      group by pizza_types.category, pizza_types.name) as a) as b 
      where ranking <= 3;  

-- Thank You! --
