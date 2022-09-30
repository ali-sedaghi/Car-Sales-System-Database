-- .1 Number of each city agencies
SELECT city, COUNT(*)
FROM Agency
GROUP BY city
ORDER BY count DESC;

-- .2 Number of each city customers
SELECT city, COUNT(*)
FROM customers
GROUP BY city
ORDER BY count DESC;

-- .3 Number of each agency's customers
SELECT Agency.*, COUNT(Customers.*)
FROM Agency
JOIN Customers ON Agency.id = Customers.agency_id
GROUP BY Agency.id
ORDER BY COUNT DESC;

-- .4 List of customers born between 2000-01-01 and 1990-01-01
SELECT * FROM Customers
WHERE birthday BETWEEN '1990-01-01' AND '2000-01-01';

-- .5 List of agencies located in the city where customer 7 lives
SELECT * FROM Agency
WHERE Agency.city IN (
    SELECT city FROM Customers WHERE Customers.id = 7
);

-- .6 List of city's that there is a customer but there isn't any agency + number of customers in that city
SELECT city, COUNT(*)
FROM Customers
WHERE city NOT IN (
    SELECT  DISTINCT city FROM Agency
)
GROUP BY city;

-- .7 List of all checks vehicle for sale 6
SELECT
    Checks.id, Checks.price, Checks.due_time
FROM Checks
JOIN VehicleForSale ON Checks.vehicle_for_sale_id = VehicleForSale.id
WHERE VehicleForSale.id = 6;

-- .8 List of all available cars and their details on sale plan 4
SELECT
    Vehicle.vehicle_name,
    Vehicle.class_code,
    Vehicle.color,
    VehicleForSale.available
FROM SalePlan
JOIN VehicleForSale ON SalePlan.id = VehicleForSale.sale_id
JOIN Vehicle ON VehicleForSale.vehicle_id = Vehicle.id
WHERE SalePlan.id = 4

-- .9 List of all vehicle 4 buyers in sale plan 1
SELECT
    Customers.national_id, CONCAT(Customers.first_name, ' ', Customers.last_name) AS full_name
FROM Contracts
JOIN Customers ON Contracts.customer_id = Customers.id
JOIN VehicleForSale ON Contracts.vehicle_for_sale_id = VehicleForSale.id
JOIN SalePlan ON VehicleForSale.sale_id = SalePlan.id
WHERE SalePlan.id = 1 AND VehicleForSale.id = 4;

-- .10 List of all buyers and what they bought in sale plan 2 
SELECT
    Customers.national_id, CONCAT(Customers.first_name, ' ', Customers.last_name) AS full_name,
    Vehicle.vehicle_name, Vehicle.class_code, Vehicle.color,
    VehicleForSale.deliver_date
FROM Contracts
JOIN Customers ON Contracts.customer_id = Customers.id
JOIN VehicleForSale ON Contracts.vehicle_for_sale_id = VehicleForSale.id
JOIN Vehicle ON VehicleForSale.vehicle_id = Vehicle.id
JOIN SalePlan ON VehicleForSale.sale_id = SalePlan.id
WHERE SalePlan.id = 2;

-- .11 List of all checks that pay time is over but not paid
SELECT
    CONCAT(Customers.first_name, ' ', Customers.last_name) AS full_name,
    Customers.national_id,
    Checks.id AS check_id,
    Checks.price,
    Checks.due_time
FROM Contracts
JOIN Customers ON Contracts.customer_id = Customers.id
JOIN VehicleForSale ON Contracts.vehicle_for_Sale_id = VehicleForSale.id
JOIN Checks ON VehicleForSale.id = Checks.vehicle_for_sale_id
WHERE NOT EXISTS (
    SELECT * FROM Transactions WHERE Customers.id = Transactions.customer_id
    AND Checks.id = Transactions.check_id
)
    AND due_time < CURRENT_TIMESTAMP
ORDER BY due_time

-- .12 List of contracts that all their checks are paid
SELECT
    Contracts.id,
    Customers.national_id, CONCAT(Customers.first_name, ' ', Customers.last_name) AS full_name,
    Vehicle.vehicle_name, Vehicle.class_code, Vehicle.color,
    VehicleForSale.deliver_date
FROM Contracts
JOIN Checks ON Contracts.vehicle_for_sale_id = Checks.vehicle_for_sale_id
JOIN Customers ON Contracts.customer_id = Customers.id
JOIN VehicleForSale ON Contracts.vehicle_for_sale_id = VehicleForSale.id
JOIN Vehicle ON VehicleForSale.vehicle_id = Vehicle.id
GROUP BY
    Contracts.id,
    Customers.national_id,
    full_name,
    Vehicle.vehicle_name,
    Vehicle.class_code,
    Vehicle.color,
    VehicleForSale.deliver_date
HAVING
    COUNT(Checks.id) = (
        SELECT COUNT(Transactions.check_id) FROM Transactions WHERE Contracts.customer_id = Transactions.customer_id
    )
ORDER BY Contracts.customer_id;

-- .13 Total amount money that company got in each sale plan
SELECT
    SalePlan.description, SalePlan.sale_type, SUM(checks.price) AS recieved FROM Contracts
JOIN VehicleForSale ON Contracts.vehicle_for_sale_id = VehicleForSale.id
JOIN Transactions ON Contracts.customer_id = Transactions.customer_id
JOIN SalePlan ON VehicleForSale.sale_id = SalePlan.id
JOIN Checks ON Transactions.check_id = Checks.id
GROUP BY SalePlan.description, SalePlan.sale_type

-- .14 Number of sold car and company should deliver
SELECT
    Vehicle.vehicle_name,
    Vehicle.class_code,
    Vehicle.color,
    VehicleForSale.deliver_date,
    COUNT(Vehicle.id) AS amount
FROM Contracts
JOIN VehicleForSale ON Contracts.vehicle_for_sale_id = VehicleForSale.id
JOIN Vehicle ON VehicleForSale.vehicle_id = Vehicle.id
GROUP BY
    Vehicle.vehicle_name,
    Vehicle.class_code,
    Vehicle.color,
    VehicleForSale.deliver_date
;

-- .15 Agency that customer 4 must deliver his car
SELECT
    Agency.agency_name,
    Agency.agency_address,
    Agency.telephone,
    Vehicle.vehicle_name,
    Vehicle.class_code,
    Vehicle.color,
    VehicleForSale.deliver_date
FROM Customers
JOIN Contracts ON Customers.id = Contracts.customer_id
JOIN VehicleForSale ON Contracts.vehicle_for_sale_id = VehicleForSale.id
JOIN Vehicle ON VehicleForSale.vehicle_id = Vehicle.id
JOIN Agency ON Customers.agency_id = Agency.id
WHERE Customers.id = 4;

-- .16 List of all cars with amount that agency 10 must deliver
SELECT
    Vehicle.vehicle_name, Vehicle.class_code, Vehicle.color,
    VehicleForSale.deliver_date,
    COUNT(VehicleForSale.id) AS amount
FROM Contracts
JOIN Customers ON Contracts.customer_id = Customers.id
JOIN Agency ON Customers.agency_id = Agency.id
JOIN VehicleForSale ON Contracts.vehicle_for_sale_id = VehicleForSale.id
JOIN Vehicle ON VehicleForSale.vehicle_id = Vehicle.id
WHERE Agency.id = 10
GROUP BY
    Vehicle.vehicle_name,
    Vehicle.class_code,
    Vehicle.color,
    VehicleForSale.deliver_date
ORDER BY VehicleForSale.deliver_date; 

-- .17 List of all cars that agency 10 should deliver to each person before time 2022-01-01
SELECT
    Customers.national_id,
    CONCAT(Customers.first_name, ' ', Customers.last_name) AS full_name,
    VehicleForSale.deliver_date,
    Vehicle.vehicle_name,
    Vehicle.class_code,
    Vehicle.color
FROM Contracts
JOIN Customers ON Contracts.customer_id = Customers.id
JOIN Agency ON Customers.agency_id = Agency.id
JOIN VehicleForSale ON Contracts.vehicle_for_sale_id = VehicleForSale.id
JOIN Vehicle ON VehicleForSale.vehicle_id = Vehicle.id
WHERE Agency.id = 10
AND deliver_date < '2022-01-01';

-- .18 Total amount recieved by company by selling each vehicle
SELECT
   Vehicle.vehicle_name, Vehicle.class_code, SUM(checks.price) AS recieved FROM Contracts
JOIN VehicleForSale ON Contracts.vehicle_for_sale_id = VehicleForSale.id
JOIN Transactions ON Contracts.customer_id = Transactions.customer_id
JOIN SalePlan ON VehicleForSale.sale_id = SalePlan.id
JOIN Checks ON Transactions.check_id = Checks.id
JOIN Vehicle ON VehicleForSale.vehicle_id = Vehicle.id
GROUP BY Vehicle.vehicle_name, Vehicle.class_code