-- Q1: List all users with a non-null email (simple single-table query)
SELECT UserID,
       firstName,
       lastName,
       email,
       createdAt
FROM user
WHERE email IS NOT NULL;
-- spacing
-- Q2: Events visited by each user
SELECT u.UserID,
       u.firstName,
       u.lastName,
       e.eventID,
       e.EventName,
       e.StartDate,
       e.Status
FROM user AS u
JOIN visits AS v
  ON u.UserID = v.UserID
JOIN event AS e
  ON v.eventID = e.eventID
WHERE e.Status IS NOT NULL
LIMIT 50;
-- spacing
-- Q3: Distinct pairs of different users (self-join on UserID)
SELECT u1.UserID      AS user1ID,
       u1.firstName   AS user1FirstName,
       u1.lastName    AS user1LastName,
       u2.UserID      AS user2ID,
       u2.firstName   AS user2FirstName,
       u2.lastName    AS user2LastName
FROM user AS u1
JOIN user AS u2
  ON u1.UserID < u2.UserID   -- ensures different users and avoids duplicates
WHERE u1.UserID IS NOT NULL
  AND u2.UserID IS NOT NULL
LIMIT 50;

-- spacing
-- Q4: Number of events each user has visited
SELECT u.UserID,
       u.firstName,
       u.lastName,
       COUNT(*) AS numEventsVisited
FROM user AS u
JOIN visits AS v
  ON u.UserID = v.UserID
WHERE v.eventID IS NOT NULL
GROUP BY u.UserID, u.firstName, u.lastName
LIMIT 50;
-- spacing
-- Q5: Events with at least 2 recorded visitors
SELECT e.eventID,
       e.EventName,
       COUNT(v.UserID) AS visitorCount
FROM event AS e
JOIN visits AS v
  ON e.eventID = v.eventID
WHERE v.UserID IS NOT NULL
GROUP BY e.eventID, e.EventName
HAVING COUNT(v.UserID) >= 2
LIMIT 50;
-- spacing
-- Q6: Users created after or on the average creation date (uses a scalar subquery)
SELECT u.UserID,
       u.firstName,
       u.lastName,
       u.email,
       u.createdAt
FROM user AS u
WHERE u.createdAt >= (
    SELECT AVG(createdAt)
    FROM user
);
-- spacing
-- Q7: Demonstrate EXISTS with a correlated subquery on the user table
SELECT u.UserID,
       u.firstName,
       u.lastName,
       u.email
FROM user AS u
WHERE EXISTS (
    SELECT 1
    FROM user AS u2
    WHERE u2.UserID = u.UserID
);
