-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 20, 2025 at 01:53 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.1.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `j.a.n.c.h.a housing`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Fee_paid_status` (IN `p_fee_id` INT, IN `p_new_status` VARCHAR(10))   BEGIN
    UPDATE fees
    SET paid_status = p_new_status
    WHERE fee_id = p_fee_id;
    
    SELECT CONCAT('Fee ID ', p_fee_id, ' status updated to ', p_new_status, '.') 
    AS message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `List_students_status` (IN `p_enrollment_status` VARCHAR(20))   BEGIN
    SELECT 
        student_id,
        first_name,
        last_name,
        email,
        phone,
        enrollment_status
    FROM students 
    WHERE enrollment_status = p_enrollment_status
    ORDER BY last_name, first_name;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `Total_fees_due_per_student` (`p_student_id` INT) RETURNS DECIMAL(10,2) READS SQL DATA BEGIN
DECLARE v_total_due  DECIMAL (10,2) DEFAULT 0.00;
	
 	SELECT COALESCE(SUM(fee_amount), 0.00)	
    INTO v_total_due
    FROM fees
	WHERE student_id = p_student_id
		AND paid_status <> 'paid';
	RETURN v_total_due;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `assignments`
--

CREATE TABLE `assignments` (
  `assignment_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `lease_start` date NOT NULL,
  `lease_end` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `assignments`
--

INSERT INTO `assignments` (`assignment_id`, `student_id`, `room_id`, `lease_start`, `lease_end`) VALUES
(1, 2, 1, '2025-08-16', '2026-05-12'),
(2, 5, 2, '2025-08-16', '2026-05-12'),
(3, 10, 4, '2025-08-16', '2026-05-12'),
(4, 6, 10, '2025-08-16', '2026-05-12'),
(5, 4, 7, '2025-08-16', '2026-05-12'),
(6, 3, 9, '2025-08-16', '2026-05-12'),
(7, 1, 3, '2025-08-16', '2026-05-12'),
(8, 8, 5, '2025-08-16', '2026-05-12'),
(9, 9, 6, '2025-08-16', '2026-05-12'),
(10, 7, 3, '2025-08-16', '2026-05-12');

--
-- Triggers `assignments`
--
DELIMITER $$
CREATE TRIGGER `check_capacity` BEFORE INSERT ON `assignments` FOR EACH ROW BEGIN
	DECLARE Current_occupancy INT;
    DECLARE Max_capacity INT;
    
    SELECT occupancy,capacity 
    INTO Current_occupancy, Max_capacity
    FROM rooms 
    WHERE room_id = New.room_id;
    
    IF (Current_occupancy+1) > Max_capacity THEN
    SIGNAL SQLSTATE '45000'
    	SET MESSAGE_TEXT = 'Room is already at full capacity.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_occupancy` AFTER INSERT ON `assignments` FOR EACH ROW BEGIN
	UPDATE rooms
    SET occupancy = occupancy + 1
    where room_id = NEW.room_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_occupancy_delete` AFTER DELETE ON `assignments` FOR EACH ROW BEGIN
	UPDATE rooms
    set occupancy = occupancy -1
    where room_id = OLD.room_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ca`
--

CREATE TABLE `ca` (
  `ca_id` int(11) NOT NULL,
  `dorm_id` int(11) NOT NULL,
  `ca_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ca`
--

INSERT INTO `ca` (`ca_id`, `dorm_id`, `ca_name`, `email`) VALUES
(1, 1, 'Elijah Brown', 'ejbrown@pvamu.edu'),
(2, 3, 'Isaac Collins', 'icollins@pvamu.edu'),
(3, 5, 'Joyce Harris', 'jharris@pvamu.edu'),
(4, 4, 'Thomas Howard', 'thoward@pvamu.edu'),
(5, 2, 'Jean Ross', 'jross@pvamu.edu'),
(6, 1, 'Kathy Stewart', 'kstewart@pvamu.edu'),
(7, 2, 'Genisis Mitchell', 'gmitchell@pvamu.edu'),
(8, 4, 'Lucas Phillips', 'lphillips@pvamu.edu'),
(9, 5, 'Mark Taylor', 'mtaylor@pvamu.edu'),
(10, 3, 'Judith Haynes', 'jhaynes@pvamu.edu\r\n');

-- --------------------------------------------------------

--
-- Table structure for table `dorms`
--

CREATE TABLE `dorms` (
  `dorm_id` int(11) NOT NULL,
  `dorm_name` varchar(100) NOT NULL,
  `location` varchar(100) NOT NULL,
  `capacity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dorms`
--

INSERT INTO `dorms` (`dorm_id`, `dorm_name`, `location`, `capacity`) VALUES
(1, 'University College', 'Central Campus', 714),
(2, 'University Village III', 'North Campus', 590),
(3, 'University View I ', 'East Campus', 435),
(4, 'University Square', 'Central ', 462),
(5, 'University Village VI', 'North Campus', 486),
(6, 'University Village I', 'West Campus', 486),
(7, 'University Village II', 'West Campus', 486),
(8, 'University View II', 'East Campus', 435);

-- --------------------------------------------------------

--
-- Table structure for table `fees`
--

CREATE TABLE `fees` (
  `fee_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `fee_amount` decimal(10,2) DEFAULT NULL,
  `due_date` date NOT NULL,
  `paid_status` varchar(10) DEFAULT NULL
) ;

--
-- Dumping data for table `fees`
--

INSERT INTO `fees` (`fee_id`, `student_id`, `fee_amount`, `due_date`, `paid_status`) VALUES
(21, 2, 8658.61, '2025-12-11', 'Waived'),
(22, 9, 0.00, '0000-00-00', 'Paid'),
(23, 3, 703.95, '2026-02-24', 'Unpaid'),
(24, 4, 22.54, '2025-12-11', 'Paid'),
(25, 10, 0.00, '0000-00-00', 'Paid'),
(26, 7, 387.42, '2026-04-03', 'Paid'),
(27, 6, 8990.36, '2026-04-23', 'Unpaid'),
(28, 5, 547.05, '2026-01-01', 'Unpaid'),
(29, 8, 0.00, '0000-00-00', 'Paid'),
(30, 10, 83.89, '2025-11-01', 'Late'),
(31, 10, 250.60, '2025-12-10', 'Unpaid');

-- --------------------------------------------------------

--
-- Table structure for table `maintenance`
--

CREATE TABLE `maintenance` (
  `request_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `description` text NOT NULL,
  `status` varchar(20) DEFAULT 'pending',
  `request_date` date DEFAULT curdate(),
  `completed_date` date DEFAULT NULL
) ;

--
-- Dumping data for table `maintenance`
--

INSERT INTO `maintenance` (`request_id`, `room_id`, `description`, `status`, `request_date`, `completed_date`) VALUES
(1, 1, 'The lightbulb in the common area is not working.', 'received', '2025-09-05', NULL),
(2, 3, 'The light bulb in the bathroom is not working.', 'completed', '2025-09-10', '2025-09-13'),
(3, 2, 'The hinges of the side mirror in the bathroom are broken.', 'completed', '2025-09-12', '2025-11-17'),
(4, 5, 'The ceiling fan is not working.', 'pending', '2025-10-01', NULL),
(5, 6, 'The AC is not working.', 'received', '2025-10-05', NULL),
(6, 9, 'The lightbulb in my room is not working.', 'pending', '2025-10-12', NULL),
(7, 4, 'My room chair is broken.', 'completed', '2025-09-15', '2025-11-17'),
(8, 10, 'The shower is not working.', 'pending', '2025-10-18', NULL),
(9, 7, 'Fridge is not working.', 'completed', '2025-10-20', '2025-11-19'),
(10, 8, 'Key fob for the room doesn\'t work.', 'received', '2025-10-22', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `rooms`
--

CREATE TABLE `rooms` (
  `room_id` int(11) NOT NULL,
  `dorm_id` int(11) NOT NULL,
  `room_number` varchar(10) NOT NULL,
  `capacity` int(11) NOT NULL,
  `occupancy` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rooms`
--

INSERT INTO `rooms` (`room_id`, `dorm_id`, `room_number`, `capacity`, `occupancy`) VALUES
(1, 1, '101', 2, 1),
(2, 1, '102', 2, 2),
(3, 4, '204', 4, 2),
(4, 5, '1142', 4, 4),
(5, 6, '2114', 2, 1),
(6, 2, '1144', 4, 0),
(7, 6, '6838', 2, 1),
(8, 4, '142', 2, 0),
(9, 4, '104', 2, 2),
(10, 7, '6832', 4, 1),
(11, 4, '114', 3, 1);

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `student_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `enrollment_status` varchar(20) NOT NULL
) ;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`student_id`, `first_name`, `last_name`, `email`, `phone`, `enrollment_status`) VALUES
(1, 'James', 'Laguerre', 'jlaguerre@pvamu.edu', '832-714-0549', 'Junior'),
(2, 'Edward', 'Johnson', 'ejohnson@pvamu.edu', '281-459-0683', 'Freshman'),
(3, 'John', 'Mccoy', 'jmccoy@pvamu.edu', '918-270-8394', 'Freshman'),
(4, 'Noah', 'Crew', 'ncrew@pvamu.edu', '406-734-4075', 'Junior'),
(5, 'Rebecca ', 'Larsen', 'rlarsen@pvamu.edu', '', 'Freshman'),
(6, 'Malik', 'Cunningham', 'mcunningham@pvamu.edu', '', 'Senior'),
(7, 'Faye ', 'Sheehan', 'fSheehan@pvamu.edu', '305-207-7284', 'Senior'),
(8, 'Sunae', 'Day', 'sday@pvamu.edu', '770-552-5656', 'Sophmore'),
(9, 'Jordan', 'Lewis', 'jlewis@pvamu.edu', '', 'Junior'),
(10, 'James', 'Johnson', 'jjohnson@pvamu.edu', '838-704-9830', 'Freshman'),
(19, 'Jane', 'Doe', 'jdoe@pvamu.edu', NULL, 'Sophmore');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `assignments`
--
ALTER TABLE `assignments`
  ADD PRIMARY KEY (`assignment_id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `room_id` (`room_id`);

--
-- Indexes for table `ca`
--
ALTER TABLE `ca`
  ADD PRIMARY KEY (`ca_id`),
  ADD KEY `dorm_id` (`dorm_id`);

--
-- Indexes for table `dorms`
--
ALTER TABLE `dorms`
  ADD PRIMARY KEY (`dorm_id`);

--
-- Indexes for table `fees`
--
ALTER TABLE `fees`
  ADD PRIMARY KEY (`fee_id`),
  ADD KEY `student_id` (`student_id`);

--
-- Indexes for table `maintenance`
--
ALTER TABLE `maintenance`
  ADD PRIMARY KEY (`request_id`),
  ADD KEY `room_id` (`room_id`);

--
-- Indexes for table `rooms`
--
ALTER TABLE `rooms`
  ADD PRIMARY KEY (`room_id`),
  ADD KEY `dorm_id` (`dorm_id`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`student_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `assignments`
--
ALTER TABLE `assignments`
  MODIFY `assignment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `ca`
--
ALTER TABLE `ca`
  MODIFY `ca_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `dorms`
--
ALTER TABLE `dorms`
  MODIFY `dorm_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `fees`
--
ALTER TABLE `fees`
  MODIFY `fee_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `maintenance`
--
ALTER TABLE `maintenance`
  MODIFY `request_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rooms`
--
ALTER TABLE `rooms`
  MODIFY `room_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=114;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `student_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `assignments`
--
ALTER TABLE `assignments`
  ADD CONSTRAINT `assignments_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  ADD CONSTRAINT `assignments_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`);

--
-- Constraints for table `ca`
--
ALTER TABLE `ca`
  ADD CONSTRAINT `ca_ibfk_1` FOREIGN KEY (`dorm_id`) REFERENCES `dorms` (`dorm_id`);

--
-- Constraints for table `fees`
--
ALTER TABLE `fees`
  ADD CONSTRAINT `fees_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`);

--
-- Constraints for table `maintenance`
--
ALTER TABLE `maintenance`
  ADD CONSTRAINT `maintenance_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`);

--
-- Constraints for table `rooms`
--
ALTER TABLE `rooms`
  ADD CONSTRAINT `rooms_ibfk_1` FOREIGN KEY (`dorm_id`) REFERENCES `dorms` (`dorm_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
