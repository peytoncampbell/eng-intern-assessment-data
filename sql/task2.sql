-- Problem 5: Retrieve the products with the highest average rating
-- Write an SQL query to retrieve the products with the highest average rating.
-- The result should include the product ID, product name, and the average rating.
-- Hint: You may need to use subqueries or common table expressions (CTEs) to solve this problem.
WITH AverageRatings AS (
    SELECT product_id, AVG(rating) AS average_rating
    FROM Reviews
    GROUP BY product_id
)
SELECT p.product_id, p.product_name, ar.average_rating
FROM Products p
JOIN AverageRatings ar ON p.product_id = ar.product_id
WHERE ar.average_rating = (SELECT MAX(average_rating) FROM AverageRatings);

-- Problem 6: Retrieve the users who have made at least one order in each category
-- Write an SQL query to retrieve the users who have made at least one order in each category.
-- The result should include the user ID and username.
-- Hint: You may need to use subqueries or joins to solve this problem.
SELECT u.user_id, u.username
FROM Users u
WHERE NOT EXISTS (
    SELECT category_id
    FROM Categories
    WHERE category_id NOT IN (
        SELECT c.category_id
        FROM Orders o
        JOIN Order_Items oi ON o.order_id = oi.order_id
        JOIN Products p ON oi.product_id = p.product_id
        JOIN Categories c ON p.category_id = c.category_id
        WHERE o.user_id = u.user_id
    )
);

-- Problem 7: Retrieve the products that have not received any reviews
-- Write an SQL query to retrieve the products that have not received any reviews.
-- The result should include the product ID and product name.
-- Hint: You may need to use subqueries or left joins to solve this problem.
SELECT p.product_id, p.product_name
FROM Products p
LEFT JOIN Reviews r ON p.product_id = r.product_id
WHERE r.review_id IS NULL;

-- Problem 8: Retrieve the users who have made consecutive orders on consecutive days
-- Write an SQL query to retrieve the users who have made consecutive orders on consecutive days.
-- The result should include the user ID and username.
-- Hint: You may need to use subqueries or window functions to solve this problem.
WITH OrderedDates AS (
    SELECT user_id, order_date,
           LAG(order_date) OVER (PARTITION BY user_id ORDER BY order_date) AS previous_date
    FROM Orders
)
SELECT DISTINCT u.user_id, u.username
FROM Users u
JOIN OrderedDates od ON u.user_id = od.user_id
WHERE od.order_date = od.previous_date + INTERVAL '1 day';
