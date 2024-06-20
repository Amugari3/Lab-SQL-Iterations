USE SAKILA;

-- Write a query to find what is the total business done by each store.
SELECT 
    s.store_id,
    CONCAT(a.address, ', ', c.city) AS store_location,
    SUM(p.amount) AS total_business
FROM 
    payment p
JOIN 
    rental r ON p.rental_id = r.rental_id
JOIN 
    inventory i ON r.inventory_id = i.inventory_id
JOIN 
    store s ON i.store_id = s.store_id
JOIN 
    address a ON s.address_id = a.address_id
JOIN 
    city c ON a.city_id = c.city_id
GROUP BY 
    s.store_id, store_location
ORDER BY 
    total_business DESC;
    
-- Convert the previous query into a stored procedure.
DELIMITER //
CREATE PROCEDURE negocioTotalPorTienda()
BEGIN
    SELECT 
        s.store_id,
        CONCAT(a.address, ', ', c.city) AS store_location,
        SUM(p.amount) AS total_business
    FROM 
        payment p
    JOIN 
        rental r ON p.rental_id = r.rental_id
    JOIN 
        inventory i ON r.inventory_id = i.inventory_id
    JOIN 
        store s ON i.store_id = s.store_id
    JOIN 
        address a ON s.address_id = a.address_id
    JOIN 
        city c ON a.city_id = c.city_id
    GROUP BY 
        s.store_id, store_location
    ORDER BY 
        total_business DESC;
END //

DELIMITER ;

CALL negocioTotalPorTienda();

-- Convert the previous query into a stored procedure that takes the input for store_id and displays the total sales for that store.
DELIMITER //

CREATE PROCEDURE negocioTotalXTienda(IN input_store_id INT)
BEGIN
    SELECT 
        s.store_id,
        CONCAT(a.address, ', ', c.city) AS store_location,
        SUM(p.amount) AS total_business
    FROM 
        payment p
    JOIN 
        rental r ON p.rental_id = r.rental_id
    JOIN 
        inventory i ON r.inventory_id = i.inventory_id
    JOIN 
        store s ON i.store_id = s.store_id
    JOIN 
        address a ON s.address_id = a.address_id
    JOIN 
        city c ON a.city_id = c.city_id
    WHERE 
        s.store_id = input_store_id
    GROUP BY 
        s.store_id, store_location;
END //

DELIMITER ;

CALL negocioTotalXTienda(2);

-- Update the previous query. Declare a variable total_sales_value of float type, that will store the returned result (of the total sales amount for the store). Call the stored procedure and print the results.

DELIMITER //

CREATE PROCEDURE negocioTotalPorTienda2(IN input_store_id INT, OUT total_sales_value FLOAT)
BEGIN
    DECLARE total_sales FLOAT;

    SELECT 
        SUM(p.amount) 
    INTO 
        total_sales
    FROM 
        payment p
    JOIN 
        rental r ON p.rental_id = r.rental_id
    JOIN 
        inventory i ON r.inventory_id = i.inventory_id
    JOIN 
        store s ON i.store_id = s.store_id
    WHERE 
        s.store_id = input_store_id;

    SET total_sales_value = total_sales;
END //

DELIMITER ;

-- Declarar la variable para almacenar el resultado
SET @store_id = 1;
SET @total_sales_value = 0.0;

-- Llamar al procedimiento almacenado
CALL negocioTotalPorTienda2(@store_id, @total_sales_value);

-- Seleccionar la variable para imprimir el resultado
SELECT @total_sales_value AS total_sales;

-- In the previous query, add another variable flag. If the total sales value for the store is over 30.000, then label it as green_flag, otherwise label is as red_flag. Update the stored procedure that takes an input as the store_id and returns total sales value for that store and flag value.
DELIMITER //

CREATE PROCEDURE negocioTotalPorTienda3(
    IN input_store_id INT, 
    OUT total_sales_value FLOAT, 
    OUT flag VARCHAR(10)
)
BEGIN
    DECLARE total_sales FLOAT;

    SELECT 
        SUM(p.amount) 
    INTO 
        total_sales
    FROM 
        payment p
    JOIN 
        rental r ON p.rental_id = r.rental_id
    JOIN 
        inventory i ON r.inventory_id = i.inventory_id
    JOIN 
        store s ON i.store_id = s.store_id
    WHERE 
        s.store_id = input_store_id;

    SET total_sales_value = total_sales;

    IF total_sales > 30000 THEN
        SET flag = 'green_flag';
    ELSE
        SET flag = 'red_flag';
    END IF;
END //

DELIMITER ;

-- Declarar las variables para almacenar el resultado
SET @store_id = 2;
SET @total_sales_value = 0.0;
SET @flag = '';

-- Llamar al procedimiento almacenado
CALL negocioTotalPorTienda3(@store_id, @total_sales_value, @flag);

-- Seleccionar las variables para imprimir los resultados
SELECT @total_sales_value AS total_sales, @flag AS flag;

