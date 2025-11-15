nsert into Place(placeName, streetNo, streetName, city, province, country, postalCode, description)
values( 'University Community Centre (UCC) Western',
    '1151',
    'Richmond Street',
    'London',
    'Ontario',
    'Canada',
    'N6A 3K7',
    'Central hub of Western University featuring food services, bookstore, study spaces, student organizations, and various campus services.');
    
    INSERT INTO Place (
    placeName,
    streetNo,
    streetName,
    city,
    province,
    country,
    postalCode,
    description
)
VALUES (
    CONCAT('Temporary Location ', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')),
    '0',
    'a Street',
    'a City',
    'Ontario',
    'Canada',
    'N0N 0N0',
    'This location was created dynamically using SQL functions for the assignment.'
);

INSERT INTO Place (placeName, streetNo, streetName, city, province, country, postalCode, description)
SELECT 'Weldon Library', '1151', 'Western Road', 'London', 'Ontario', 'Canada', 'N6A 3K7', 'Main library of Western University.'
UNION ALL
SELECT 'Alumni Hall', '1111', 'Western Road', 'London', 'Ontario', 'Canada', 'N6A 3K7', 'Event and conference hall at Western University.';

select * from Place;
