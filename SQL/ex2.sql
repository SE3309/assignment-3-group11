DROP DATABASE IF EXISTS waypoint_db;
CREATE DATABASE waypoint_db;
USE waypoint_db;

CREATE TABLE Place (
	placeID INT AUTO_INCREMENT PRIMARY KEY,
    placeName VARCHAR(100) NOT NULL,
    streetNo VARCHAR(10),
    streetName VARCHAR(100),
    city VARCHAR(100),
    province VARCHAR(50),
    country VARCHAR(50),
    postalCode VARCHAR(10),
    description TEXT
);

-- Display table
DESCRIBE Place;