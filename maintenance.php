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

// Execution of query to show records
$sql = "SELECT
    d.dorm_name,
    r.room_number,
    m.request_id,
    m.description,
    m.status,
    m.request_date
FROM maintenance m
JOIN rooms r ON m.room_id = r.room_id
JOIN dorms d ON r.dorm_id = d.dorm_id
WHERE m.status IN ('pending', 'received')";

$result = $conn->query($sql);

$data = array();

if($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
}

echo json_encode($data);

$conn->close();
?>