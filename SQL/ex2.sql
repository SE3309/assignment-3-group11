DROP DATABASE IF EXISTS waypoint_db;
CREATE DATABASE waypoint_db;
USE waypoint_db;

DROP TABLE IF EXISTS Photo;
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS Visits;
DROP TABLE IF EXISTS Event;
DROP TABLE IF EXISTS Place;
DROP TABLE IF EXISTS Friend_Request;
DROP TABLE IF EXISTS User;

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

CREATE TABLE Executive(
execID INT auto_increment PRIMARY KEY,
firstName VARCHAR(50) NOT NULL,
lastName VARCHAR(50) NOT NULL,
DateOfBirth date,
email VARCHAR(50) NOT NULL,
position VARCHAR(50),
phoneNumber int
);

CREATE TABLE Administrator(
AdminID INT auto_increment primary key,
execID INT,
firstName VARCHAR(50) NOT NULL,
lastName VARCHAR(50) NOT NULL,
DateOfBirth date,
email VARCHAR(50) NOT NULL,
salary  DECIMAL(10,2),
foreign key (execID) references Executive(execID)
on update cascade

);
create index idx_admin_email on Administrator(email);

DELIMITER //
CREATE TRIGGER before_admin_insert
BEFORE INSERT ON Administrator
FOR EACH ROW
BEGIN
  SET NEW.salary = ROUND(NEW.salary, 2);
END;
//
DELIMITER ;

CREATE TABLE User (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    AdminID INT,
    firstName VARCHAR(100),
    lastName VARCHAR(100),
    DateOfBirth DATE,
    email VARCHAR(255) UNIQUE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (AdminID) REFERENCES User(UserID)
);


CREATE TABLE Friend_Request (
    requestID INT PRIMARY KEY AUTO_INCREMENT,
    SenderID INT NOT NULL,
    ReceiverID INT NOT NULL,
    DateSent DATE,
    DateResponded DATE,
    Status VARCHAR(50) DEFAULT 'Pending',
    FOREIGN KEY (SenderID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (ReceiverID) REFERENCES User(UserID) ON DELETE CASCADE,
    CHECK (Status IN ('Pending', 'Accepted', 'Rejected', 'Cancelled'))
);

-- Trigger: Prevent self-friend requests
DELIMITER //
CREATE TRIGGER trg_prevent_self_friend_request
BEFORE INSERT ON Friend_Request
FOR EACH ROW
BEGIN
    IF NEW.SenderID = NEW.ReceiverID THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot send friend request to yourself';
    END IF;
END//
DELIMITER ;

CREATE TABLE Event (
    eventID INT PRIMARY KEY AUTO_INCREMENT,
    placeID INT NOT NULL,
    StartTime TIME,
    EventName VARCHAR(255),
    EventInfo TEXT,
    EndTime TIME,
    EndDate DATE,
    StartDate DATE,
    Status VARCHAR(50) DEFAULT 'Upcoming',
    totalVisitors INT DEFAULT 0,
    averageRating DECIMAL(3,2) DEFAULT 0.00,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (placeID) REFERENCES place(placeID) ON DELETE CASCADE,
    CHECK (Status IN ('Upcoming', 'Ongoing', 'Completed', 'Cancelled', 'Postponed'))
);

CREATE INDEX idx_event_name ON Event(EventName);
CREATE INDEX idx_event_rating ON Event(averageRating);
CREATE INDEX idx_event_status ON Event(Status);

-- Trigger: Validate event dates
DELIMITER //
CREATE TRIGGER trg_validate_event_dates
BEFORE INSERT ON Event
FOR EACH ROW
BEGIN
    IF NEW.EndDate < NEW.StartDate THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Event end date cannot be before start date';
    END IF;
    IF NEW.EndTime < NEW.StartTime AND NEW.StartDate = NEW.EndDate THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Event end time cannot be before start time on the same day';
    END IF;
END//
DELIMITER ;

CREATE TABLE Visits (
    eventID INT NOT NULL,
    UserID INT NOT NULL,
    visitDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (eventID, UserID),
    FOREIGN KEY (eventID) REFERENCES Event(eventID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
);

DELIMITER //
CREATE TRIGGER trg_prevent_visit_cancelled_event
BEFORE INSERT ON Visits
FOR EACH ROW
BEGIN
    DECLARE event_status VARCHAR(50);
    
    SELECT Status INTO event_status
    FROM Event
    WHERE EventID = NEW.EventID;
    
    IF event_status IN ('Cancelled', 'Postponed') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot register visit for cancelled or postponed events';
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_increment_visitors
AFTER INSERT ON Visits
FOR EACH ROW
BEGIN
    UPDATE Event
    SET totalVisitors = totalVisitors + 1
    WHERE EventID = NEW.EventID;
END//
DELIMITER ;

CREATE TABLE Review (
    UserID INT NOT NULL,
    EventID INT NOT NULL,
    Comments TEXT,
    Rating DECIMAL(3,2),
    reviewDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (UserID, EventID),
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (EventID) REFERENCES Event(EventID) ON DELETE CASCADE,
    CHECK (Rating >= 0 AND Rating <= 5)
);

-- Review table indexes
CREATE INDEX idx_review_rating ON Review(Rating);


CREATE TABLE Photo (
    PhotoID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    EventID INT NOT NULL,
    ImageURL VARCHAR(500),
    Caption TEXT,
    uploadDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (EventID) REFERENCES Event(EventID) ON DELETE CASCADE
);

-- Display table
DESCRIBE Photo;