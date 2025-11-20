<?php
header('Content-Type: application/json');

// Make connection to database
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "j.a.n.c.h.a housing";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    echo json_encode(["error" => "Connection failed: " . $conn->connect_error]);
    exit();
}

// Get the enrollment status from the request
$enrollment_status = isset($_GET['status']) ? $_GET['status'] : '';

// Execution of query to show records
// If no status provided, return all students
if (empty($enrollment_status)) {
    $sql = "SELECT * FROM students ORDER BY last_name, first_name";
    $result = $conn->query($sql);
} else {
    // Call the stored procedure
    $stmt = $conn->prepare("CALL List_students_status(?)");
    $stmt->bind_param("s", $enrollment_status);
    $stmt->execute();
    $result = $stmt->get_result();
}

$data = array();

if($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
}

echo json_encode($data);

$conn->close();
?>
