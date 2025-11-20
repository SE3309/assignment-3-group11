
-- CREATE VIEW statements
CREATE OR REPLACE VIEW vw_event_place_summary AS
SELECT e.eventID, e.EventName, p.placeID, p.placeName, e.StartDate, e.EndDate, e.Status, e.totalVisitors, e.averageRating
FROM Event e
JOIN Place p ON e.placeID = p.placeID;

CREATE OR REPLACE VIEW vw_user_activity AS
SELECT u.UserID, u.firstName, u.lastName, IFNULL(COUNT(v.eventID), 0) AS numVisits, MAX(v.visitDate) AS lastVisit
FROM User u
LEFT JOIN Visits v ON u.UserID = v.UserID
GROUP BY u.UserID, u.firstName, u.lastName;

-- Query involving each view and system response (truncated)
SELECT * FROM vw_event_place_summary LIMIT 3;

SELECT * FROM vw_user_activity LIMIT 3;


-- The attempt to modify each view
INSERT INTO vw_event_place_summary (EventName, placeName, StartDate, EndDate, Status, totalVisitors, averageRating)
VALUES ('Test Insert', 'Some Place', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'Upcoming', 0, 0.0);

INSERT INTO vw_user_activity (UserID, firstName, lastName, numVisits)
VALUES (99999, 'Auto', 'Tester', 1);

-- ---------------------------------------------------------------------------
-- Additional: an updatable single-table view and demo of INSERT/UPDATE
-- This view is defined directly on the `Place` table. It is updatable because it maps exactly to the base table (essentially, no joins, no aggregates).
CREATE OR REPLACE VIEW vw_plain_place AS
SELECT placeID, placeName, streetNo, streetName, city, province, country, postalCode, description
FROM Place;

-- Insert a new place via the view (do not provide placeID; it's auto-incremented)
INSERT INTO vw_plain_place (placeName, streetNo, streetName, city, province, country, postalCode, description)
VALUES ('Inserted via view', '200', 'View Street', 'Sample City', 'Ontario', 'Canada', 'A1A 1A1', 'Inserted through updatable view');

-- Verify the insert (show the most recently added place)
SELECT * FROM Place
ORDER BY placeID DESC
LIMIT 1;

-- Update the row through the view
UPDATE vw_plain_place
SET city = 'Updated City', streetNo = '201'
WHERE placeName = 'Inserted via view';

-- Verifies the update
SELECT * FROM Place
WHERE placeName = 'Inserted via view'
LIMIT 1;
