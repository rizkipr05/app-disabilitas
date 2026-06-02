<?php
include_once '../db_config.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->username) && !empty($data->password)) {
    $query = "SELECT id, username, password, role, full_name FROM users WHERE username = :username LIMIT 1";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(":username", $data->username);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (password_verify($data->password, $row['password'])) {
            http_response_code(200);
            echo json_encode([
                "message" => "Login successful",
                "user" => [
                    "id" => $row['id'],
                    "username" => $row['username'],
                    "role" => $row['role'],
                    "full_name" => $row['full_name']
                ]
            ]);
        } else {
            http_response_code(401);
            echo json_encode(["message" => "Invalid password"]);
        }
    } else {
        http_response_code(404);
        echo json_encode(["message" => "User not found"]);
    }
} else {
    http_response_code(400);
    echo json_encode(["message" => "Incomplete data"]);
}
?>
