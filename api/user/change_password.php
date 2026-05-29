<?php
include_once '../db_config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    if (!empty($data->id) && !empty($data->new_password)) {
        $hashed = password_hash($data->new_password, PASSWORD_BCRYPT);
        $query = "UPDATE users SET password = :password WHERE id = :id";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(":password", $hashed);
        $stmt->bindParam(":id", $data->id);
        if ($stmt->execute()) {
            echo json_encode(["message" => "Password updated successfully"]);
        } else {
            http_response_code(500);
            echo json_encode(["message" => "Failed to update password"]);
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
