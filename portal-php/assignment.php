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
    s.student_id,
    s.first_name,
    s.last_name,
    r.room_number,
    d.dorm_name,
    GROUP_CONCAT(CONCAT(s2.first_name, ' ', s2.last_name) SEPARATOR ', ') AS roommates
FROM
    assignments a
JOIN
    rooms r ON a.room_id = r.room_id
JOIN
    dorms d ON r.dorm_id = d.dorm_id
JOIN
    students s ON a.student_id = s.student_id
LEFT JOIN
    assignments a2
    ON a.room_id = a2.room_id
    AND a.student_id <> a2.student_id
LEFT JOIN
    students s2 ON a2.student_id = s2.student_id
GROUP BY
    s.student_id,
    s.first_name,
    s.last_name,
    r.room_number,
    d.dorm_name
ORDER BY
    d.dorm_name, r.room_number;";

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
