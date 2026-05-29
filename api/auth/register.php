<?php
include_once '../db_config.php';
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents("php://input"));

    if (empty($data->full_name) || empty($data->username) || empty($data->password)) {
        http_response_code(400);
        echo json_encode(["message" => "Data tidak lengkap"]);
        exit;
    }

    // Cek username sudah ada
    $check = $conn->prepare("SELECT id FROM users WHERE username = :username");
    $check->bindParam(":username", $data->username);
    $check->execute();
    if ($check->rowCount() > 0) {
        http_response_code(409);
        echo json_encode(["message" => "Nama pengguna sudah digunakan"]);
        exit;
    }

    $hashed = password_hash($data->password, PASSWORD_BCRYPT);
    $role = 'siswa';
    $stmt = $conn->prepare("INSERT INTO users (full_name, username, password, role) VALUES (:full_name, :username, :password, :role)");
    $stmt->bindParam(":full_name", $data->full_name);
    $stmt->bindParam(":username", $data->username);
    $stmt->bindParam(":password", $hashed);
    $stmt->bindParam(":role", $role);

    if ($stmt->execute()) {
        http_response_code(201);
        echo json_encode(["message" => "Registrasi berhasil"]);
    } else {
        http_response_code(500);
        echo json_encode(["message" => "Gagal mendaftar"]);
    }
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
