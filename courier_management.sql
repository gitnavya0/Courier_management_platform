SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `courier_management`
--

-- --------------------------------------------------------

--
-- Table structure for table `branch`
--

CREATE TABLE manager_login_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL
);
INSERT INTO manager_login_details VALUES(1,"Manager1", "M1PASS");

CREATE TABLE `branch` (
  `branch_id` int NOT NULL AUTO_INCREMENT,
  `branch_addr` varchar(50) DEFAULT NULL,
  `branch_city` varchar(30) DEFAULT NULL,
  `branch_phone` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `branch` VALUES ('12A Gandhi Road', 'Mumbai', 9123456789),
('34B Nehru Street', 'Delhi', 9898765432),
('56C Tagore Avenue', 'Kolkata', 3344556677),
('78D Patel Lane', 'Ahmedabad', 7878787878),
('90E Rajendra Path', 'Chennai', 7676767676),
('11F Malleshwaram', 'Bengaluru', 6767676767),
('23G Indira Place', 'Hyderabad', 2323232323),
('45H Bose Road', 'Pune', 8787878787),
('67I Sardar Marg', 'Jaipur', 5656565656),
('89J Jawahar Square', 'Lucknow', 9898989898);
-- --------------------------------------------------------

DELIMITER //
CREATE PROCEDURE UpdateParcelStatus(IN parcelId INT)
BEGIN
  DECLARE currentStatus VARCHAR(20);

  SELECT status INTO currentStatus FROM parcels WHERE parcel_id = parcelId;

  IF currentStatus = 'accepted' THEN
    UPDATE parcels SET status = 'shipped' WHERE parcel_id = parcelId;
  ELSEIF currentStatus = 'shipped' THEN
    UPDATE parcels SET status = 'intransit' WHERE parcel_id = parcelId;
  ELSEIF currentStatus = 'intransit' THEN
    UPDATE parcels SET status = 'out for delivery' WHERE parcel_id = parcelId;
  ELSEIF currentStatus = 'out for delivery' THEN
    UPDATE parcels SET status = 'delivered' WHERE parcel_id = parcelId;
  ELSE
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid parcel status';
  END IF;
END //
DELIMITER ;

SELECT staff.emp_id, staff.emp_name, staff.emp_phone, staff.emp_branch_id, branch.branch_addr
FROM staff
INNER JOIN branch ON staff.emp_branch_id = branch.branch_id;
--
-- Table structure for table `parcels`
--
CREATE TABLE `parcels` (
  `parcel_id` int NOT NULL AUTO_INCREMENT,
  `cost` int(11) DEFAULT NULL,
  `sender_id` int(11) DEFAULT NULL,
  `recv_name` varchar(20) DEFAULT NULL,
  `recv_addr` varchar(50) DEFAULT NULL,
  `date_accepted` datetime DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `emp_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
insert into parcels values(1, 345, 1, 'Naitik', '1232 Prestige Falcon', '2023-11-11 00:00:00', 'in-transit', 4);
-- --------------------------------------------------------

--using a function to calculate the cost of the parcel 
DELIMITER //

CREATE FUNCTION calculateParcelCost(
    p_weight DECIMAL(10,2),
    p_length DECIMAL(10,2),
    p_width DECIMAL(10,2),
    p_type VARCHAR(255),
    p_height DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE cost DECIMAL(10,2);

    SET cost = p_weight * 10 + p_length * 12 + p_width * 17 + p_height * 15;

    IF p_type = 'fragile' THEN
        SET cost = cost + 200;
    ELSE
        SET cost = cost + 100;
    END IF;

    RETURN cost;
END //

DELIMITER ;

--view of table that the customer sees 
CREATE VIEW customer_parcel_view AS
SELECT
    p.parcel_id,
    pd.type,
    p.recv_name,
    p.date_accepted,
    p.cost,
    p.status
FROM parcels p
JOIN parcels_details pd ON p.parcel_id = pd.parcel_id;

--displaying parcel table in list_parcels.ejs
SELECT
    p.parcel_id,
    pd.type,
    p.cost,
    s.sender_name AS sender_name,
    r.recv_name AS receiver_name,
    p.date_accepted,
    p.status
FROM
    parcels AS p
INNER JOIN
    parcels_details AS pd ON p.cost = pd.cost
INNER JOIN
    sender AS s ON p.sender_id = s.sender_id
INNER JOIN
    receiver AS r ON p.recv_name = r.recv_name;

--
-- Table structure for table `parcels_details`
--

CREATE TABLE `parcels_details` (
  `parcel_id` int NOT NULL AUTO_INCREMENT,
  `cost` int(11) DEFAULT NULL,
  `weight` float DEFAULT NULL,
  `length` float DEFAULT NULL,
  `width` float DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `height` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `receiver`
--

CREATE TABLE `receiver` (
  `recv_name` varchar(20) NOT NULL,
  `recv_addr` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
insert into receiver values('Naitik', '1232 Prestige Falcon');
-- --------------------------------------------------------

--
-- Table structure for table `sender`
--

CREATE TABLE `sender` (
  `sender_id` int NOT NULL AUTO_INCREMENT,
  `sender_name` varchar(20) DEFAULT NULL,
  `sender_addr` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
insert into sender values (1, 'Navya', 'aqua 2 grande exotica indore');
-- --------------------------------------------------------

--
-- Table structure for table `sends`
--

CREATE TABLE `sends` (
  `sender_id` int NOT NULL AUTO_INCREMENT,
  `recv_addr` varchar(50) NOT NULL,
  `recv_name` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

insert into sends values(1,'1232 Prestige Falcon', 'Naitik');
-- --------------------------------------------------------

--
-- Table structure for table `staff`
--

CREATE TABLE `staff` (
  `emp_id` int NOT NULL AUTO_INCREMENT,
  `emp_name` varchar(20) DEFAULT NULL,
  `emp_phone` int(10) DEFAULT NULL,
  `emp_branch_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE count_table (
    entity_name VARCHAR(50) PRIMARY KEY,
    count_value INT
); ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--new table to keep count of each table  
INSERT INTO count_table (entity_name, count_value) VALUES
    ('branch', 0),
    ('staff', 0),
    ('parcels', 0);

--setting initial value to count of each table 
UPDATE count_table
SET count_value = (SELECT COUNT(*) FROM branch)
WHERE entity_name = 'branch';

UPDATE count_table
SET count_value = (SELECT COUNT(*) FROM staff)
WHERE entity_name = 'staff';

UPDATE count_table
SET count_value = (SELECT COUNT(*) FROM parcels)
WHERE entity_name = 'parcels';

--triggers to update count value in count_table when a new entry is added 
DELIMITER //
CREATE TRIGGER after_insert_branch
AFTER INSERT ON branch
FOR EACH ROW
BEGIN
    UPDATE count_table SET count_value = (SELECT COUNT(*) FROM branch) WHERE entity_name = 'branch';
END;
//

CREATE TRIGGER after_insert_staff
AFTER INSERT ON staff
FOR EACH ROW
BEGIN
    UPDATE count_table SET count_value = (SELECT COUNT(*) FROM staff) WHERE entity_name = 'staff';
END;
//

CREATE TRIGGER after_insert_parcels
AFTER INSERT ON parcels
FOR EACH ROW
BEGIN
    UPDATE count_table SET count_value = (SELECT COUNT(*) FROM parcels) WHERE entity_name = 'parcels';
END;
//
DELIMITER ;

--created table to log activity 
CREATE TABLE activity_log (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activity_type VARCHAR(255),
    details TEXT
);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `branch`
--
ALTER TABLE `branch`
  ADD PRIMARY KEY (`branch_id`);

--
-- Indexes for table `parcels`
--
ALTER TABLE `parcels`
  ADD PRIMARY KEY (`parcel_id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `recv_name` (`recv_name`),
  ADD KEY `emp_id` (`emp_id`);

--
-- Indexes for table `parcels_details`
--
ALTER TABLE `parcels_details`
  ADD PRIMARY KEY (`parcel_id`);

--
-- Indexes for table `receiver`
--
ALTER TABLE `receiver`
  ADD PRIMARY KEY (`recv_name`,`recv_addr`);

ALTER TABLE `receiver`
  ADD INDEX idx_recv_addr (recv_addr);
  
ALTER TABLE `parcels_details`
  ADD INDEX idx_cost (cost);
  
--
-- Indexes for table `sender`
--
ALTER TABLE `sender`
  ADD PRIMARY KEY (`sender_id`);

--
-- Indexes for table `sends`
--
ALTER TABLE `sends`
  ADD PRIMARY KEY (`sender_id`,`recv_addr`,`recv_name`),
  ADD KEY `recv_addr` (`recv_addr`),
  ADD KEY `sends_recv_name` (`recv_name`);

--
-- Indexes for table `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`emp_id`),
  ADD KEY `emp_branch_id` (`emp_branch_id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `parcels`
--
ALTER TABLE `parcels`
  ADD CONSTRAINT `parcels_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `sender` (`sender_id`),
  ADD CONSTRAINT `parcels_ibfk_2` FOREIGN KEY (`recv_name`) REFERENCES `receiver` (`recv_name`),
  ADD CONSTRAINT `parcels_ibfk_3` FOREIGN KEY (`emp_id`) REFERENCES `staff` (`emp_id`),
  ADD CONSTRAINT `parcels_ibfk_4` FOREIGN KEY (`recv_addr`) REFERENCES `receiver` (`recv_addr`);
  
--
-- Constraints for table `parcels_details`
--
ALTER TABLE `parcels_details`
  ADD CONSTRAINT `parcels_details_ibfk_1` FOREIGN KEY (`parcel_id`) REFERENCES `parcels` (`parcel_id`);

--
-- Constraints for table `sends`
--
ALTER TABLE `sends`
  ADD CONSTRAINT `sends_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `sender` (`sender_id`),
  ADD CONSTRAINT `sends_recv_name` FOREIGN KEY (`recv_name`) REFERENCES `receiver` (`recv_name`),
  ADD CONSTRAINT `sends_ibfk_2` FOREIGN KEY (`recv_addr`) REFERENCES `receiver` (`recv_addr`);
--
-- Constraints for table `staff`
--
ALTER TABLE `staff`
  ADD CONSTRAINT `staff_ibfk_1` FOREIGN KEY (`emp_branch_id`) REFERENCES `branch` (`branch_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
