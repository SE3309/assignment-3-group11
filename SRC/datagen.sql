
USE waypoint_db;


-- 1. POPULATE PLACE 

DELIMITER $$
CREATE PROCEDURE sp_populate_place(IN num_rows INT)
BEGIN

    DECLARE i INT DEFAULT 0;
    WHILE i < num_rows DO
        INSERT INTO Place (placeName, streetNo, streetName, city, province, country, postalCode, description)
        VALUES (
            CONCAT('Generated Place ', i), 
            CAST(FLOOR(RAND() * 900 + 100) AS CHAR(10)), 
            'Generated Street',
            'London',
            'Ontario',
            'Canada',
            'N6A 5B8',
            'Auto-generated place description.'
        );
       
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;


-- 2. POPULATE USER 

DELIMITER $$
CREATE PROCEDURE sp_populate_user(IN num_rows INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < num_rows DO
        INSERT INTO User (AdminID, firstName, lastName, DateOfBirth, email)
        VALUES (
            NULL, -- We set AdminID to NULL since it's tricky to self-reference
            CONCAT('FirstName', i),
            CONCAT('LastName', i),
            DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 10000 + 6570) DAY), -- Random birthday
            CONCAT('user', i, '@waypoint.com') -- This ensures every email is unique
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;


-- 3. POPULATE EVENT 

DELIMITER $$
CREATE PROCEDURE sp_populate_event(IN num_rows INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    
    -- Check if Place table is empty
    IF (SELECT COUNT(*) FROM Place) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Place table is empty. Populate Place first.';
    END IF;

    WHILE i < num_rows DO
        INSERT INTO Event (placeID, EventName, StartDate, EndDate, Status)
        VALUES (
            -- This is the new logic:
            -- It selects one REAL placeID at random from the Place table.
            (SELECT placeID FROM Place ORDER BY RAND() LIMIT 1),
            
            CONCAT('Awesome Event ', i),
            DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 30) DAY),
            DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 30) DAY),
            'Upcoming'
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;


-- 4. POPULATE VISITS 

DELIMITER $$
CREATE PROCEDURE sp_populate_visits(IN num_rows INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE min_user INT;
    DECLARE max_user INT;
    DECLARE min_event INT;
    DECLARE max_event INT;
    
    -- Get the valid User and Event ID ranges
    SELECT MIN(UserID), MAX(UserID) INTO min_user, max_user FROM User;
    SELECT MIN(eventID), MAX(eventID) INTO min_event, max_event FROM Event;

    WHILE i < num_rows DO
        -- 'INSERT IGNORE' will skip if it tries to create a duplicate (UserID, eventID) pair
        INSERT IGNORE INTO Visits (eventID, UserID)
        VALUES (
            -- Pick a random, valid EventID
            FLOOR(RAND() * (max_event - min_event + 1)) + min_event,
            -- Pick a random, valid UserID
            FLOOR(RAND() * (max_user - min_user + 1)) + min_user
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;


-- 5. POPULATE REVIEWS (Bonus table for good queries)

DELIMITER $$
CREATE PROCEDURE sp_populate_reviews(IN num_rows INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE min_user INT;
    DECLARE max_user INT;
    DECLARE min_event INT;
    DECLARE max_event INT;
    
    -- Get the valid User and Event ID ranges
    SELECT MIN(UserID), MAX(UserID) INTO min_user, max_user FROM User;
    SELECT MIN(eventID), MAX(eventID) INTO min_event, max_event FROM Event;

    WHILE i < num_rows DO
        -- 'INSERT IGNORE' skips duplicates, since (UserID, EventID) is a Primary Key 
        INSERT IGNORE INTO Review (UserID, EventID, Comments, Rating)
        VALUES (
            FLOOR(RAND() * (max_user - min_user + 1)) + min_user,
            FLOOR(RAND() * (max_event - min_event + 1)) + min_event,
            'This is an auto-generated review.',
            ROUND(RAND() * 4 + 1, 1) -- Random rating between 1.0 and 5.0
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;