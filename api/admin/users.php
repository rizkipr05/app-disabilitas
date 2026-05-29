<?php
include_once '../db_config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        if (isset($_GET['id'])) {
            $query = "SELECT id, username, role, full_name, created_at FROM users WHERE id = :id";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(":id", $_GET['id']);
            $stmt->execute();
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            echo json_encode($user);
        } else {
            $query = "SELECT id, username, role, full_name, created_at FROM users ORDER BY id DESC";
            $stmt = $conn->prepare($query);
            $stmt->execute();
            $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($users);
        }
        break;
    
    case 'POST':
        $data = json_decode(file_get_contents("php://input"));
        if (!empty($data->username) && !empty($data->password) && !empty($data->role) && !empty($data->full_name)) {
            $hashed = password_hash($data->password, PASSWORD_BCRYPT);
            $query = "INSERT INTO users (username, password, role, full_name) VALUES (:username, :password, :role, :full_name)";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(":username", $data->username);
            $stmt->bindParam(":password", $hashed);
            $stmt->bindParam(":role", $data->role);
            $stmt->bindParam(":full_name", $data->full_name);
            if ($stmt->execute()) {
                http_response_code(201);
                echo json_encode(["message" => "User created successfully"]);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Failed to create user"]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "Incomplete data"]);
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents("php://input"));
        if (!empty($data->id)) {
            $update_fields = [];
            if (!empty($data->username)) $update_fields[] = "username = :username";
            if (!empty($data->password)) $update_fields[] = "password = :password";
            if (!empty($data->role)) $update_fields[] = "role = :role";
            if (!empty($data->full_name)) $update_fields[] = "full_name = :full_name";
            
            if (empty($update_fields)) {
                http_response_code(400);
                echo json_encode(["message" => "Nothing to update"]);
                break;
            }

            $query = "UPDATE users SET " . implode(", ", $update_fields) . " WHERE id = :id";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(":id", $data->id);
            if (!empty($data->username)) $stmt->bindParam(":username", $data->username);
            if (!empty($data->password)) $stmt->bindParam(":password", $data->password);
            if (!empty($data->role)) $stmt->bindParam(":role", $data->role);
            if (!empty($data->full_name)) $stmt->bindParam(":full_name", $data->full_name);

            if ($stmt->execute()) {
                echo json_encode(["message" => "User updated successfully"]);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Failed to update user"]);
            }
        }
        break;

    case 'DELETE':
        if (isset($_GET['id'])) {
            $query = "DELETE FROM users WHERE id = :id";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(":id", $_GET['id']);
            if ($stmt->execute()) {
                echo json_encode(["message" => "User deleted successfully"]);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Failed to delete user"]);
            }
        }
        break;
}
?>
