-- Problem 9: Retrieve the top 3 categories with the highest total sales amount
-- Write an SQL query to retrieve the top 3 categories with the highest total sales amount.
-- The result should include the category ID, category name, and the total sales amount.
-- Hint: You may need to use subqueries, joins, and aggregate functions to solve this problem.
SELECT c.category_id, c.category_name, SUM(oi.quantity * oi.unit_price) AS total_sales
FROM Categories c
JOIN Products p ON c.category_id = p.category_id
JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY c.category_id
ORDER BY total_sales DESC
LIMIT 3;

-- Problem 10: Retrieve the users who have placed orders for all products in the Toys & Games
-- Write an SQL query to retrieve the users who have placed orders for all products in the Toys & Games
-- The result should include the user ID and username.
-- Hint: You may need to use subqueries, joins, and aggregate functions to solve this problem.
SELECT u.user_id, u.username
FROM Users u
WHERE NOT EXISTS (
    SELECT p.product_id
    FROM Products p
    JOIN Categories c ON p.category_id = c.category_id
    WHERE c.category_name = 'Toys & Games' AND p.product_id NOT IN (
        SELECT oi.product_id
        FROM Orders o
        JOIN Order_Items oi ON o.order_id = oi.order_id
        WHERE o.user_id = u.user_id
    )
);

-- Problem 11: Retrieve the products that have the highest price within each category
-- Write an SQL query to retrieve the products that have the highest price within each category.
-- The result should include the product ID, product name, category ID, and price.
-- Hint: You may need to use subqueries, joins, and window functions to solve this problem.
WITH CategoryMaxPrices AS (
    SELECT category_id, MAX(price) AS max_price
    FROM Products
    GROUP BY category_id
)
SELECT p.product_id, p.product_name, p.category_id, p.price
FROM Products p
JOIN CategoryMaxPrices cmp ON p.category_id = cmp.category_id AND p.price = cmp.max_price;

-- Problem 12: Retrieve the users who have placed orders on consecutive days for at least 3 days
-- Write an SQL query to retrieve the users who have placed orders on consecutive days for at least 3 days.
-- The result should include the user ID and username.
-- Hint: You may need to use subqueries, joins, and window functions to solve this problem.
WITH ConsecutiveOrders AS (
    SELECT user_id, order_date,
           LAG(order_date, 1) OVER (PARTITION BY user_id ORDER BY order_date) AS prev_date,
           LAG(order_date, 2) OVER (PARTITION BY user_id ORDER BY order_date) AS prev_date2
    FROM Orders
)
SELECT DISTINCT u.user_id, u.username
FROM Users u
JOIN ConsecutiveOrders co ON u.user_id = co.user_id
WHERE co.order_date = co.prev_date + INTERVAL '1 day' AND co.prev_date = co.prev_date2 + INTERVAL '1 day';
