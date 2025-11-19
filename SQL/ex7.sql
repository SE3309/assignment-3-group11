
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
-- Mock response would be:
-- | eventID | EventName   | placeID |      placeName      | StartDate  | EndDate    | Status   | totalVisitors | averageRating |
-- |   1     | The Event  |   3     | Generated Place 2   | 2025-10-20 | 2025-10-21 | Completed|      25       |     4.20      |
-- |   2     | Le Event  |   5     | Weldon Library      | 2025-11-01 | 2025-11-01 | Upcoming |      3        |     3.50      |

SELECT * FROM vw_user_activity LIMIT 3;
-- Mock response would be:
-- | UserID | firstName | lastName | numVisits | lastVisit           |
-- | 123    |   John   |   Doe    |    42     | 2025-11-15 18:03:00 |
-- | 456    |   Jane   |   Smith  |    28     | 2025-11-14 12:12:00 |

-- The attempt to modify each view
INSERT INTO vw_event_place_summary (EventName, placeName, StartDate, EndDate, Status, totalVisitors, averageRating)
VALUES ('Test Insert', 'Some Place', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'Upcoming', 0, 0.0);

INSERT INTO vw_user_activity (UserID, firstName, lastName, numVisits)
VALUES (99999, 'Auto', 'Tester', 1);

-- 4. Are your views updatable? Explain why or why not.
-- Neither view is updatable:
-- vw_event_place_summary is not updatable because it is defined over a JOIN of two base tables (Event and Place).
-- vw_user_activity is not updatable because it contains aggregation (COUNT, MAX) and GROUP BY, so it does not map directly to base table rows.

-- ---------------------------------------------------------------------------
-- Additional: an updatable single-table view and demo of INSERT/UPDATE
-- This view is defined directly on the `Place` table. It is updatable because it maps exactly to the base table (no joins, no aggregates).
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

-- Explanation: `vw_plain_place` is updatable because it selects directly from a single base table without aggregation or joins
