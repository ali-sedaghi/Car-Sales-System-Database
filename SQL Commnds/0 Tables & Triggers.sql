CREATE DATABASE Project;
CREATE SCHEMA Project;
set search_path to Project;

CREATE TABLE Agency (
    id SERIAL PRIMARY KEY,
    agency_name VARCHAR(20) NOT NULL,
    city VARCHAR(255) NOT NULL, 
    agency_address VARCHAR(100) NOT NULL,
    telephone VARCHAR(15) NOT NULL UNIQUE
);

CREATE TABLE Customers (
    id SERIAL PRIMARY KEY,
    national_id VARCHAR(10) NOT NULL CONSTRAINT chknid CHECK (char_length(national_id) = 10),
    first_name VARCHAR(15) NOT NULL CONSTRAINT chkfirst CHECK (char_length(first_name) BETWEEN 2 AND 15),
    last_name VARCHAR(15) NOT NULL CONSTRAINT chklast CHECK (char_length(last_name) BETWEEN 2 AND 15),
    phone_number VARCHAR(15) NOT NULL UNIQUE CONSTRAINT proper_number CHECK (phone_number ~* '^(\+98|0)?9\d{9}$'),
    birthday DATE NOT NULL CHECK (birthday < '2002-01-01'),
    city VARCHAR(255) NOT NULL,
    customer_address VARCHAR(100) NOT NULL,
    postal_code VARCHAR(10) NOT NULL CONSTRAINT chkpc CHECK (char_length(postal_code) = 10),
    agency_id INTEGER,
    FOREIGN KEY (agency_id)
        REFERENCES Agency(id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Vehicle (
    id SERIAL PRIMARY KEY,
    vehicle_name VARCHAR(255) NOT NULL,
    class_code INTEGER NOT NULL,
    color VARCHAR(255) NOT NULL CONSTRAINT proper_color CHECK(color ~* '^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$'),
    options TEXT 
);

CREATE TYPE saletype AS ENUM ('normal', 'presale');

CREATE TABLE SalePlan (
    id SERIAL PRIMARY KEY,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    sale_type saletype NOT NULL,
    description VARCHAR(100)
);

CREATE TABLE VehicleForSale (
    id SERIAL PRIMARY KEY,
    sale_id INTEGER NOT NULL,
    vehicle_id INTEGER NOT NULL,
    UNIQUE (sale_id, vehicle_id),
    available INTEGER DEFAULT 0 CHECK (available >= 0),
    deliver_date DATE NOT NULL,
    FOREIGN KEY (sale_id)
        REFERENCES SalePlan (id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id)
        REFERENCES Vehicle (id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Checks (
    id SERIAL PRIMARY KEY,
    vehicle_for_sale_id INTEGER NOT NULL,
    due_time TIMESTAMP NOT NULL,
    price INTEGER DEFAULT NULL,
    FOREIGN KEY (vehicle_for_sale_id)
        REFERENCES VehicleForSale (id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Contracts (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL UNIQUE,
    vehicle_for_sale_id INTEGER NOT NULL,
    assign_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    insurance VARCHAR(255) DEFAULT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES Customers(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (vehicle_for_sale_id)
        REFERENCES VehicleForSale(id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Transactions (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    check_id INTEGER NOT NULL,
    UNIQUE (customer_id, check_id),
    assign_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id)
        REFERENCES Customers(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (check_id)
        REFERENCES Checks(id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 1. User agency must be in the same city that he/she lives
CREATE OR REPLACE FUNCTION agency_customer_same_city() RETURNS trigger AS $body$
    BEGIN
        IF (SELECT Agency.city From Agency WHERE Agency.id = NEW.agency_id) != NEW.city AND NEW.agency_id IS NOT NULL THEN
            RAISE EXCEPTION 'Customer agency must be in the customer city';
        END IF;
        RETURN NEW;
    END;
$body$ LANGUAGE plpgsql;

CREATE TRIGGER agency_customer_same_city
    BEFORE INSERT OR UPDATE
    ON Customers
    FOR EACH ROW
    EXECUTE PROCEDURE agency_customer_same_city();


-- 2. Sale plan start time must be before the end time
CREATE OR REPLACE FUNCTION is_saleplan_time_valid() RETURNS trigger AS $body$
    BEGIN
        IF NEW.start_time > NEW.end_time THEN
            RAISE EXCEPTION 'Start time should be before end time';
        END IF;
        RETURN NEW;
    END;
$body$ LANGUAGE plpgsql;

CREATE TRIGGER is_saleplan_time_valid
    BEFORE INSERT OR UPDATE
    ON SalePlan
    FOR EACH ROW
    EXECUTE PROCEDURE is_saleplan_time_valid();


-- 3. Vehicle must be available before assigning new contract
CREATE OR REPLACE FUNCTION is_vehicle_available() RETURNS trigger AS $body$
    BEGIN
        IF (SELECT VehicleForSale.available FROM VehicleForSale WHERE VehicleForSale.id = NEW.vehicle_for_sale_id) < 1 THEN
            RAISE EXCEPTION 'The capacity is over';
        END IF;
        RETURN NEW;
    END;
$body$ LANGUAGE plpgsql;

CREATE TRIGGER is_vehicle_available
    BEFORE INSERT
    ON Contracts
    FOR EACH ROW
    EXECUTE PROCEDURE is_vehicle_available();


-- 4. Decrease amount of available cars by 1 after a contract is assigned
CREATE OR REPLACE FUNCTION update_vehicle_available() RETURNS trigger AS $body$
    BEGIN
        UPDATE VehicleForSale SET available = available - 1
        WHERE VehicleForSale.id = NEW.vehicle_for_sale_id;
        RETURN NEW;
    END;
$body$ LANGUAGE plpgsql;

CREATE TRIGGER update_vehicle_available
    AFTER INSERT
    ON Contracts
    FOR EACH ROW
    EXECUTE PROCEDURE update_vehicle_available();

-- 5. Check if contract date is between sale start and end time
CREATE OR REPLACE FUNCTION is_sale_active_on_contract() RETURNS trigger AS $body$
    BEGIN
        IF
            NEW.assign_time < (
                SELECT SalePlan.start_time FROM SalePlan
                JOIN VehicleForSale ON SalePlan.id = VehicleForSale.sale_id
                WHERE NEW.vehicle_for_sale_id = VehicleForSale.id
            )
            OR NEW.assign_time > (
                SELECT SalePlan.end_time FROM SalePlan
                JOIN VehicleForSale ON SalePlan.id = VehicleForSale.sale_id
                WHERE NEW.vehicle_for_sale_id = VehicleForSale.id
            )
        THEN RAISE EXCEPTION 'Sale plan is not active';
        END IF;
        RETURN NEW;
    END;
$body$ LANGUAGE plpgsql;

CREATE TRIGGER is_sale_active_on_contract
    BEFORE INSERT OR UPDATE
    ON Contracts
    FOR EACH ROW
    EXECUTE PROCEDURE is_sale_active_on_contract();