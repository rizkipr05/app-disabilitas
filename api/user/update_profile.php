<?php
include_once '../db_config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    if (!empty($data->id) && !empty($data->full_name) && !empty($data->username)) {
        $query = "UPDATE users SET full_name = :full_name, username = :username WHERE id = :id";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(":full_name", $data->full_name);
        $stmt->bindParam(":username", $data->username);
        $stmt->bindParam(":id", $data->id);
        if ($stmt->execute()) {
            http_response_code(200);
            echo json_encode(["message" => "Profile updated successfully"]);
        } else {
            http_response_code(500);
            echo json_encode(["message" => "Failed to update profile"]);
        }
    } else {
        http_response_code(400);
        echo json_encode(["message" => "Incomplete data"]);
    }
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
