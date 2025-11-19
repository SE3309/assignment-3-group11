-- 1. Insert the result of a query: Copy an existing place with a modified name
INSERT INTO Place (placeName, streetNo, streetName, city, province, country, postalCode, description)
SELECT CONCAT(placeName, ' - Copy'), streetNo, streetName, city, province, country, postalCode, description
FROM Place
WHERE placeID = (SELECT MIN(placeID) FROM Place);

-- 2. Update several tuples at once: Mark all events as 'Completed' that have already ended
UPDATE Event
SET Status = 'Completed'
WHERE EndDate < CURDATE() AND Status != 'Completed';

-- 3. Delete a set of tuples: Remove reviews with a rating below 2.0
DELETE FROM Friend_Request
WHERE Status = 'Pending' AND DateSent < DATE_SUB(CURDATE(), INTERVAL 30 DAY);
