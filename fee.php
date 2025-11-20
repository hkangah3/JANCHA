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
    s.email,
    f.fee_amount,
    f.due_date,
    f.paid_status
FROM
    students s
JOIN
    fees f ON s.student_id = f.student_id
WHERE
    f.paid_status IN ('Unpaid', 'Late')
ORDER BY
    f.due_date";

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