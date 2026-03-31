
-- 1. Create a database named AirCargo and import ticket_details.csv,
-- routes.csv, passengers_on_flights.csv, and customer.csv from the given
-- resources into it

CREATE DATABASE AirCargo;
USE AirCargo;

CREATE TABLE IF NOT EXISTS Customer(
customer_id INT(20)PRIMARY KEY NOT NULL,
first_name  VARCHAR(100),
last_name VARCHAR(100),
date_of_birth DATE,
gender CHAR(1)
 );
 

 
 
CREATE TABLE IF NOT EXISTS passengers_on_flights(
pof_id INT auto_increment PRIMARY KEY,
customer_id INT NOT NULL,
aircraft_id VARCHAR(100),
route_id INT (20),
depart CHAR(3),
arrival CHAR(3),
seat_num CHAR(4),
class_id VARCHAR(100),
travel_date DATE,
flight_num INT(20),
constraint fk_pof_ foreign key(customer_id) references Customer(customer_id)
);



CREATE TABLE IF NOT EXISTS ticket_details(
tkt_id INT auto_increment PRIMARY KEY,
 p_date DATE,
 customer_id INT(20),
 aircraft_id VARCHAR(100),
 class_id  VARCHAR(100),
 no_of_tickets INT(20),
 a_code CHAR(3),
 price_per_ticket INT(20),
 brand VARCHAR(100),
 constraint fk_tkt_dts foreign key (customer_id ) references Customer(customer_id )
 );


CREATE TABLE IF NOT EXISTS routes(
Route_id INT PRIMARY KEY,
Flight_num INT constraint chk_1 check(Flight_num is not null),
Origin_airport CHAR(3),
Destination_airport CHAR(3),
Aircraft_id VARCHAR(100),
Distance_miles INT constraint chk_2 check(Distance_miles>0)
);


SELECT * FROM aircargo.routes;

SELECT * FROM aircargo.customer;

SELECT * FROM aircargo.passengers_on_flights;

SELECT * FROM aircargo.ticket_details;



-- 2. Create an ER diagram for the given airlines' database.



-- 3. Write a query to display all the passengers who have traveled on routes 01
-- to 25 from the passengers_on_flights table.


SELECT * 
FROM passengers_on_flights
WHERE route_id BETWEEN 01 AND 25;




-- 4. Write a query to identify the number of passengers and total revenue in
-- business class from the ticket_details table.

SELECT COUNT(distinct customer_id) AS no_of_passengers,
SUM(price_per_ticket*no_of_tickets) AS total_revenue
FROM ticket_details
WHERE class_id = "Bussiness";


-- 5. Write a query to display the full name of the customer by extracting the
-- first name and last name from the customer table.

SELECT CONCAT(first_name," ",last_name) AS fullname 
FROM customer;


-- 6. Write a query to extract the customers who have registered and booked a
-- ticket from the customer and ticket_details tables.

SELECT customer_id, first_name,last_name  FROM 
customer WHERE customer_id IN (SELECT customer_id FROM ticket_details);


-- 7.Write a query to identify the customer’s first name and last name based
-- on their customer ID and brand (Emirates) from the ticket_details table.

SELECT   c.first_name, c.last_name
FROM customer c
JOIN ticket_details t
ON c.customer_id = t.customer_id
WHERE t.brand = "Emirates";

-- OR
SELECT first_name, last_name
FROM customer
WHERE customer_id IN(SELECT  customer_id from ticket_details WHERE brand = "Emirates");


-- 8. Write a query to identify the customers who have traveled by Economy
-- Plus class using the sub-query on the passengers_on_flights table.

SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id IN(SELECT DISTINCT customer_id from passengers_on_flights where class_id = "Economy Plus");




-- 9. Write a query to determine whether the revenue has crossed 10000 using
-- the IF clause on the ticket_details table.

SELECT
    IF(SUM(price_per_ticket*no_of_tickets)>10000 ," Crossed 10k mark!", "Not Cross 10k mark")AS Revenue_Status
From ticket_details;




--  10. Write a query to create and grant access to a new user to perform
-- database operations.

CREATE user if not exists 'vaishnavi'@'localhost' identified by 'vaishu@123#';

GRANT select, insert, update, delete on aircargo.* to 'vaishnavi'@'localhost';

SHOW GRANTS FOR 'vaishnavi'@'localhost';


-- 11. Write a query to find the maximum ticket price for each class using
-- window functions on the ticket_details table.


SELECT DISTINCT class_id,
MAX(price_per_ticket)OVER (PARTITION BY class_id) AS Max_ticket_price
FROM ticket_details;


-- 12. Write a query to extract the passengers whose route ID is 4 by improving
-- the speed and performance of the passengers_on_flights table using the
-- index.


CREATE INDEX idx_pof_route_id ON passengers_on_flights(route_id);
SELECT * FROM passengers_on_flights
WHERE route_id = 4;

-- 13. For route ID 4, write a query to view the execution plan of the
-- passengers_on_flights table.

EXPLAIN ANALYZE SELECT * FROM passengers_on_flights
WHERE route_id = 4;



-- 14. Write a query to calculate the total price of all tickets booked by a
-- customer across different aircraft IDs using the rollup function.

SELECT  customer_id,aircraft_id, SUM(price_per_ticket*no_of_tickets) AS Total_Price
FROM ticket_details
GROUP BY customer_id, aircraft_id WITH ROLLUP;



-- 15. Write a query to create a view with only business class customers and the
-- airline brand.

Create View Business_Class_Customers_View AS
SELECT
   c.*,
   t.class_id,
   t.brand
FROM customer c
INNER JOIN (SELECT distinct customer_id , brand , class_id from ticket_details
WHERE class_id = "Bussiness" ) t
ON c.customer_id  = t.customer_id
ORDER BY t.customer_id;

SELECT * FROM Business_Class_Customers_View;


-- 16. Write a query to create a stored procedure that extracts all the details
-- from the routes table where the traveled distance is more than 2000
-- miles

DELIMITER //
CREATE PROCEDURE Check_travel_distance()
BEGIN
	DECLARE Min_Distance_miles INT;
	SET Min_Distance_miles = 2000;
     
     SELECT * 
     FROM routes
     WHERE Distance_miles > Min_Distance_miles;

END//

DELIMITER ;

CALL Check_travel_distance();


-- 17. Using GROUP BY, determine the total number of tickets purchased by
-- each customer and the total price paid.

SELECT distinct t.customer_id, c.first_name,c.last_name, COUNT( t.no_of_tickets)as Total_Tickets, SUM(t.no_of_tickets * t.price_per_ticket) as Total_Price
FROM customer c
INNER JOIN ticket_details t
ON c.customer_id= t.customer_id
GROUP BY t.customer_id
ORDER BY Total_Price DESC;



-- 18.  Calculate the average number of passengers per flight route.

SELECT
distinct route_id,
flight_num,
depart,
arrival,
ROUND(AVG(customer_id)OVER (PARTITION BY route_id)) AS Avg_passngr_per_flight_route
FROM passengers_on_flights
Order by Avg_passngr_per_flight_route desc;



----------------------------------------------------------------------------------------------------------























