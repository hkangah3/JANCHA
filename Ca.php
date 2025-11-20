<?php
header('Content-Type: application/json');

// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "j.a.n.c.h.a housing";

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    echo json_encode(["error" => "Connection failed: " . $conn->connect_error]);
    exit();
}

// Get optional filter parameter
$dorm_name = isset($_GET['dorm_name']) ? $_GET['dorm_name'] : '';

// Build query with optional filter
if (!empty($dorm_name)) {
    // Filter by specific dorm
    $sql = "SELECT
        d.dorm_name,
        c.ca_name,
        c.email
    FROM ca c
    JOIN dorms d ON c.dorm_id = d.dorm_id
    WHERE d.dorm_name = ?
    ORDER BY d.dorm_name, c.ca_name";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $dorm_name);
    $stmt->execute();
    $result = $stmt->get_result();
} else {
    // Get all CAs
    $sql = "SELECT
        d.dorm_name,
        c.ca_name,
        c.email
    FROM ca c
    JOIN dorms d ON c.dorm_id = d.dorm_id
    ORDER BY d.dorm_name, c.ca_name";
    
    $result = $conn->query($sql);
}

$data = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
}

echo json_encode($data);

if (isset($stmt)) {
    $stmt->close();
}
$conn->close();
?>