USE sakila;

-- Lab | SQL Join (Part II)


-- 1. Write a query to display for each store its store ID, city, and country.
SELECT * FROM sakila.store;
SELECT * FROM sakila.city;
SELECT * FROM sakila.address;
SELECT * FROM sakila.country;


SELECT 
    s.store_id, c.city, co.country
FROM
    sakila.store s
        INNER JOIN
    sakila.address a ON s.address_id = a.address_id
        INNER JOIN
    sakila.city c ON a.city_id = c.city_id
        INNER JOIN
    sakila.country co ON c.country_id = co.country_id;


-- 2. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM sakila.store;
SELECT * FROM sakila.payment;
SELECT * FROM sakila.staff;

SELECT 
    s.store_id, SUM(p.amount) AS 'Amount in USD'
FROM
    sakila.store s
        INNER JOIN
    sakila.staff st ON s.store_id = st.store_id
        INNER JOIN
    sakila.payment p ON st.staff_id = p.staff_id
GROUP BY s.store_id;



-- 3. Which film categories are longest?
SELECT * FROM sakila.film;
SELECT * FROM sakila.film_category;
SELECT * FROM sakila.category;


 -- Assuming that the longest films are the ones with an average lenght greater than the average of all films
SELECT 
    AVG(length) AS 'Avg length all films'
FROM
    sakila.film;



SELECT 
    c.name, AVG(f.length) AS 'Average length of longest movies'
FROM
    sakila.film f
        INNER JOIN
    sakila.film_category f_c ON f.film_id = f_c.film_id
        LEFT JOIN
    sakila.category c ON f_c.category_id = c.category_id
GROUP BY c.name
HAVING AVG(f.length) > (SELECT 
        AVG(length)
    FROM
        sakila.film)
ORDER BY AVG(f.length) DESC;


-- 4. Display the most frequently rented movies in descending order.
 SELECT * FROM sakila.film;
 SELECT * FROM sakila.rental;
 SELECT * FROM sakila.inventory;
 
 SELECT 
    f.film_id,
    f.title,
    COUNT(f.film_id) AS 'Total Nr. rentals',
    COUNT(DISTINCT WEEK(r.rental_date)) AS 'Nr weeks/year a movie was rented'
FROM
    sakila.film f
        INNER JOIN
    sakila.inventory i ON f.film_id = i.film_id
        INNER JOIN
    sakila.rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id , f.title
ORDER BY COUNT(f.film_id) DESC , COUNT(DISTINCT WEEK(r.rental_date)) DESC;

-- 5. List the top five genres in gross revenue in descending order.
SELECT * FROM sakila.film_category;
SELECT * FROM sakila.payment;
SELECT * FROM sakila.category;
SELECT * FROM sakila.inventory;
SELECT * FROM sakila.rental;

SELECT 
    c.name, ROUND(SUM(p.amount), 0) AS 'Gross Revenue'
FROM
    sakila.category c
        INNER JOIN
    sakila.film_category f_c USING (category_id)
        INNER JOIN
    sakila.inventory i USING (film_id)
        INNER JOIN
    sakila.rental r USING (inventory_id)
        INNER JOIN
    sakila.payment p USING (rental_id)
GROUP BY c.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 6. Is "Academy Dinosaur" available for rent from Store 1?
SELECT * FROM sakila.rental;
SELECT * FROM sakila.film;
SELECT * FROM sakila.inventory;

	-- Step 1: Check whether store 1 has the film in its inventory
SELECT i.store_id, f.title, i.inventory_id
FROM sakila.film f
INNER JOIN sakila.inventory i USING (film_id)
INNER JOIN sakila.rental r USING (inventory_id)
WHERE f.title = 'Academy Dinosaur' AND i.store_id = 1
GROUP BY i.store_id , f.title, i.inventory_id;

	-- Step 2: Check whether the film has been rented
SELECT i.inventory_id, r.rental_date, r.return_date
FROM sakila.rental r
LEFT JOIN sakila.inventory i USING (inventory_id)
INNER JOIN sakila.film f USING (film_id)
WHERE f.title = 'Academy Dinosaur' AND i.store_id = 1 AND r.return_date IS NULL;
		
        -- All 4 are available for rent. 

-- 7. Get all pairs of actors that worked together.
SELECT * FROM sakila.film_actor;

SELECT 
    fa1.actor_id, fa2.actor_id
FROM
    sakila.film_actor fa1
        JOIN
    sakila.film_actor fa2 ON (fa1.film_id = fa2.film_id)
        AND (fa1.actor_id <> fa2.actor_id);

-- 8. Get all pairs of customers that have rented the same film more than 3 times.
SELECT * FROM sakila.film;
SELECT * FROM sakila.inventory;
SELECT * FROM sakila.rental;
 

SELECT 
    r1.customer_id, r2.customer_id, count(i.film_id)
FROM sakila.rental r1
JOIN sakila.rental r2 ON (r1.inventory_id = r2.inventory_id) AND (r1.customer_id <> r2.customer_id)
INNER JOIN sakila.inventory i ON r1.inventory_id = i.inventory_id
GROUP BY r1.customer_id, r2.customer_id
HAVING COUNT(i.film_id)>= 3;

SELECT r.customer_id, i.film_id, COUNT(i.film_id) AS 'Nr rentals'
FROM sakila.rental r
INNER JOIN sakila.inventory i
ON r.inventory_id = i.inventory_id
GROUP BY r.customer_id, i.film_id
HAVING COUNT(i.film_id) >=3;

SELECT r1.customer_id, r2.customer_id, COUNT(i.film_id) AS 'Nr rentals'
FROM sakila.rental r1
INNER JOIN sakila.rental r2 ON r1.inventory_id = r2.inventory_id AND r1.customer_id <> r2.customer_id
INNER JOIN sakila.inventory i
ON r1.inventory_id = i.inventory_id
GROUP BY r1.customer_id, r2.customer_id
HAVING COUNT(i.film_id) >=3;

SELECT r.customer_id, i.film_id, count(i.film_id)
FROM sakila.rental r
INNER JOIN sakila.inventory i
ON r.inventory_id = i.inventory_id
GROUP BY r.customer_id, i.film_id;


-- 9. For each film, list actor that has acted in more films.

SELECT a.actor_id, a.first_name, a.last_name, count(a.actor_id) as 'Nr.films'
FROM sakila.actor a
INNER JOIN sakila.film_actor f_a using (actor_id)
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY count(a.actor_id) DESC;

SELECT film, (SELECT a.actor_id, a.first_name, a.last_name, count(a.actor_id) as 'Nr.films'
FROM sakila.actor a
GROUP BY a.actor_id, a.first_name, a.last_name)
FROM sakila.film_actor;