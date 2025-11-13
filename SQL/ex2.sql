DROP DATABASE IF EXISTS waypoint_db;
CREATE DATABASE waypoint_db;
USE waypoint_db;


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

-- Display table
DESCRIBE Event;