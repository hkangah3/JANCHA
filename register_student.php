<?php

// Make connection to database
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "j.a.n.c.h.a housing";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

if (!$conn){
   die("Connection failed: " .mysqli_connect_error());
}
echo "Connected Successfully";

// Get form data
$first_name = isset($_POST['first_name']) ? trim($_POST['first_name']) : '';
$last_name = isset($_POST['last_name']) ? trim($_POST['last_name']) : '';
$student_id = isset($_POST['student_id']) ? trim($_POST['student_id']) : '';
$email = isset($_POST['email']) ? trim($_POST['email']) : '';
$phone = isset($_POST['phone']) ? trim($_POST['phone']) : '';
$enrollment_status = isset($_POST['classification']) ? trim($_POST['classification']) : '';
$room_id = isset($_POST['room']) ? trim($_POST['room']) : ''; // This is actually room_id from JS

// Validate required fields
if (empty($first_name) || empty($last_name) || empty($student_id) || empty($email) || empty($enrollment_status) || empty($room_id)) {
    die("Error: All required fields must be filled out. Missing: " . 
    (empty($room_id) ? "room " : "") . 
    (empty($enrollment_status) ? "classification " : ""));
}

// Start transaction
$conn->begin_transaction();

try {
    //Check if student already exists
    $check_student = $conn->prepare("SELECT student_id FROM students WHERE student_id = ?");
    $check_student->bind_param("i", $student_id);
    $check_student->execute();
    $result = $check_student->get_result();
    
    if ($result->num_rows == 0) {
        //Insert new student since student doesn't exist
        $insert_student = $conn->prepare("INSERT INTO students (student_id, first_name, last_name, email, phone, enrollment_status) VALUES (?, ?, ?, ?, ?, ?)");
        $insert_student->bind_param("isssss", $student_id, $first_name, $last_name, $email, $phone, $enrollment_status);
        
        if (!$insert_student->execute()) {
            throw new Exception("Error inserting student: " . $insert_student->error);
        }
        $insert_student->close();
    }
    $check_student->close();
    
    //Get room details using room_id
    $get_room = $conn->prepare("SELECT r.room_id, r.capacity, r.occupancy, r.room_number, d.dorm_name FROM rooms r JOIN dorms d ON r.dorm_id = d.dorm_id WHERE r.room_id = ?");
    $get_room->bind_param("i", $room_id);
    $get_room->execute();
    $room_result = $get_room->get_result();
    
    if ($room_result->num_rows == 0) {
        throw new Exception("Error: Selected room not found in database. Please refresh the page and try again.");
    }
    
    $room = $room_result->fetch_assoc();
    $capacity = $room['capacity'];
    $occupancy = $room['occupancy'];
    
    // Check if room is full
    if ($occupancy >= $capacity) {
        throw new Exception("Error: Room " . htmlspecialchars($room['room_number']) . " in " . htmlspecialchars($room['dorm_name']) . " is already at full capacity (" . $occupancy . "/" . $capacity . "). Please choose another room.");
    }
    
    $get_room->close();
    
    //Check if student already has an active assignment
    $check_assignment = $conn->prepare("SELECT assignment_id FROM assignments WHERE student_id = ? AND (lease_end IS NULL OR lease_end >= CURDATE())");
    $check_assignment->bind_param("i", $student_id);
    $check_assignment->execute();
    $assignment_result = $check_assignment->get_result();
    
    if ($assignment_result->num_rows > 0) {
        throw new Exception("Error: Student is already assigned to a room. Please contact housing administration.");
    }
    $check_assignment->close();
    
    //Insert into assignments table
    $lease_start = date('Y-m-d');
    $lease_end = date('Y-m-d', strtotime('+9 months'));
    
    $insert_assignment = $conn->prepare("INSERT INTO assignments (student_id, room_id, lease_start, lease_end) VALUES (?, ?, ?, ?)");
    $insert_assignment->bind_param("iiss", $student_id, $room_id, $lease_start, $lease_end);
    
    if (!$insert_assignment->execute()) {
        throw new Exception("Error assigning room: " . $insert_assignment->error);
    }
    $insert_assignment->close();
    
    $conn->commit();
    
    // Redirect to thank you page
    header("Location: ty.html");
    exit();

} catch (Exception $e) {
    // Rollback on error
    $conn->rollback();
    
    // Display error message
    echo "<!DOCTYPE html>
<html>
<head>
    <title>Registration Error</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            border-radius: 5px;
        }
        h2 { 
            color: #721c24; 
        }
        p { 
            color: #721c24; 
            line-height: 1.6;
        }
        a {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        a:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <h2>Registration Error</h2>
    <p>" . $e->getMessage() . "</p>
    <a href='apply.html'>Go Back to Registration Form</a>
</body>
</html>";
}

$conn->close();
?>