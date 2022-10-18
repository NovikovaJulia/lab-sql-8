-- lab-sql-8
USE sakila;

-- 1. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, city.city, country.country FROM sakila.store AS s
JOIN sakila.address AS a
ON s.address_id = a.address_id
JOIN sakila.city AS city
ON a.city_id = city.city_id
JOIN sakila.country AS country
ON city.country_id = country.country_id;


-- 2. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(p.amount) AS money_total_in_dollars FROM sakila.store AS store
JOIN sakila.staff AS staff
ON store.store_id = staff.store_id
JOIN sakila.payment as p
ON p.staff_id = staff.staff_id
GROUP BY store.store_id;

-- 3. Which film categories are longest?
-- (I will return top-5)
SELECT c.category_id, c.name as category_name, AVG(f.length) as avg_length FROM sakila.category as c
JOIN sakila.film_category as fc
ON c.category_id = fc.category_id
JOIN sakila.film as f
ON f.film_id = fc.film_id
GROUP BY c.category_id
ORDER BY avg_length DESC
LIMIT 5;

-- 4. Display the most frequently rented movies in descending order.
SELECT f.film_id, f.title, COUNT(r.rental_id) AS rent_frequency
FROM sakila.film AS f
JOIN sakila.inventory AS i
ON f.film_id = i.film_id
JOIN sakila.rental AS r
ON i.inventory_id = r.inventory_id
GROUP BY f.film_id
ORDER BY rent_frequency DESC;

-- 5. List the top five genres in gross revenue in descending order.
SELECT c.category_id, SUM(p.amount) as gross_revenue FROM sakila.category AS c
JOIN sakila.film_category AS fc
ON c.category_id = fc.category_id
JOIN sakila.film AS f
ON fc.film_id = f.film_id 
JOIN sakila.inventory AS i
ON f.film_id = i.film_id
JOIN sakila.rental AS r
ON i.inventory_id = r.inventory_id
JOIN sakila.payment AS p
ON r.rental_id = p.rental_id
GROUP BY fc.category_id
ORDER BY SUM(p.amount) DESC
LIMIT 5;


-- 6. Is "Academy Dinosaur" available for rent from Store 1?
SELECT s.store_id AS store_id, f.title AS film_title, COUNT(f.title) as availability FROM sakila.store as s
JOIN inventory AS i
ON s.store_id = i.store_id
JOIN film AS f
ON i.film_id = f.film_id
WHERE f.title = 'Academy Dinosaur' AND s.store_id = 1
GROUP BY store_id;

-- yes, it is avaliable :) 

-- 7. Get all pairs of actors that worked together.
SELECT
CONCAT(a1.first_name," ", a1.last_name) AS actor_1,
CONCAT(a2.first_name," ", a2.last_name) AS actor_2
FROM sakila.film AS f
JOIN film_actor AS fa1
ON f.film_id=fa1.film_id
JOIN sakila.actor AS a1
ON fa1.actor_id=a1.actor_id
JOIN sakila.film_actor AS fa2
ON f.film_id=fa2.film_id
JOIN sakila.actor AS a2
ON fa2.actor_id=a2.actor_id
WHERE fa1.actor_id != fa2.actor_id
ORDER BY actor_1;
    
    
-- 8. ? Get all pairs of customers that have rented the same film more than 3 times.

-- SELECT * FROM rental;

SELECT c.customer_id, f.film_id, COUNT(r.rental_id) AS number_of_rents
FROM sakila.customer AS c
JOIN sakila.rental AS r
ON r.customer_id = c.customer_id
JOIN sakila.inventory AS i
ON i.inventory_id = r.inventory_id
JOIN sakila.film AS f
ON i.film_id = f.film_id
GROUP BY c.customer_id, f.film_id
HAVING COUNT(r.rental_id) > 3
ORDER BY c.customer_id;

-- it seems like nobody rented the same film more than 3 times :)

-- 9. For each film, list actor that has acted in more films.

-- it gives number of films for each actor
SELECT 
a.actor_id AS actor_id,
a.first_name AS first_name,
a.last_name AS last_name,
COUNT(f.film_id) AS number_of_films
FROM film AS f
JOIN film_actor AS fa
ON f.film_id = fa.film_id
JOIN actor AS a
ON fa.actor_id = a.actor_id
GROUP BY actor_id

-- it gives us all the films, all the actors and number of films for each actor

SELECT film.film_id, film.title, sub_1.first_name, sub_1.last_name, sub_1.number_of_films FROM film
JOIN film_actor
ON film.film_id = film_actor.film_id
JOIN (SELECT 
a.actor_id AS actor_id,
a.first_name AS first_name,
a.last_name AS last_name,
COUNT(f.film_id) AS number_of_films
FROM film AS f
JOIN film_actor AS fa
ON f.film_id = fa.film_id
JOIN actor AS a
ON fa.actor_id = a.actor_id
GROUP BY actor_id) AS sub_1
ON film_actor.actor_id = sub_1.actor_id

-- this query gives us film_id and the number of films, but without information about the actor 

SELECT film.film_id, MAX(sub_1.number_of_films) AS number_of_films FROM sakila.film
JOIN film_actor
ON film.film_id = film_actor.film_id
JOIN (SELECT 
a.actor_id AS actor_id,
a.first_name AS first_name,
a.last_name AS last_name,
COUNT(f.film_id) AS number_of_films
FROM film AS f
JOIN film_actor AS fa
ON f.film_id = fa.film_id
JOIN actor AS a
ON fa.actor_id = a.actor_id
GROUP BY actor_id) AS sub_1
ON film_actor.actor_id = sub_1.actor_id
JOIN actor 
ON actor.actor_id = sub_1.actor_id
GROUP BY film.film_id

-- Finally, let's use them both:
SELECT sub_2.film_id, sub_2.title, sub_2.first_name, sub_2.last_name, sub_2.number_of_films
FROM
(SELECT film.film_id, film.title, sub_1.first_name, sub_1.last_name, sub_1.number_of_films FROM film
JOIN film_actor
ON film.film_id = film_actor.film_id
JOIN (SELECT 
a.actor_id AS actor_id,
a.first_name AS first_name,
a.last_name AS last_name,
COUNT(f.film_id) AS number_of_films
FROM film AS f
JOIN film_actor AS fa
ON f.film_id = fa.film_id
JOIN actor AS a
ON fa.actor_id = a.actor_id
GROUP BY actor_id) AS sub_1
ON film_actor.actor_id = sub_1.actor_id) AS sub_2
JOIN (SELECT film.film_id, MAX(sub_1.number_of_films) AS number_of_films FROM sakila.film
JOIN film_actor
ON film.film_id = film_actor.film_id
JOIN (SELECT 
a.actor_id AS actor_id,
a.first_name AS first_name,
a.last_name AS last_name,
COUNT(f.film_id) AS number_of_films
FROM film AS f
JOIN film_actor AS fa
ON f.film_id = fa.film_id
JOIN actor AS a
ON fa.actor_id = a.actor_id
GROUP BY actor_id) AS sub_1
ON film_actor.actor_id = sub_1.actor_id
JOIN actor 
ON actor.actor_id = sub_1.actor_id
GROUP BY film.film_id) AS sub_3
ON sub_2.film_id = sub_3.film_id AND sub_2.number_of_films = sub_3.number_of_films
ORDER BY sub_2.film_id ASC;

-- This link was very helpful: https://database.guide/5-ways-to-select-rows-with-the-maximum-value-for-their-group-in-sql/ 

