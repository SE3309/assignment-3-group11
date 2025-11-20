-- Inserts the result of a query: Copies an existing place with a modified name
INSERT INTO Place (placeName, streetNo, streetName, city, province, country, postalCode, description)
SELECT CONCAT(placeName, ' - Copy'), streetNo, streetName, city, province, country, postalCode, description
FROM Place
WHERE placeID = (SELECT MIN(placeID) FROM Place);

-- Updates several tuples at once: Marks all events as 'Completed' that have already ended
UPDATE Event
SET Status = 'Completed'
WHERE EndDate < CURDATE() AND Status != 'Completed';

-- Deletes a set of tuples: Removes friend requests that are pending and are also older than 30 days
DELETE FROM Friend_Request
WHERE Status = 'Pending' AND DateSent < DATE_SUB(CURDATE(), INTERVAL 30 DAY);
