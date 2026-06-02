<?php
include_once '../db_config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        if (isset($_GET['student_id'])) {
            $query = "SELECT p.*, u.full_name
                      FROM student_progress p
                      JOIN users u ON p.student_id = u.id
                      WHERE p.student_id = :student_id AND u.role = 'siswa'
                      ORDER BY p.completed_at DESC";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(":student_id", $_GET['student_id']);
            $stmt->execute();
            $progress = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($progress);
        } else {
            $query = "SELECT p.*, u.full_name
                      FROM student_progress p
                      JOIN users u ON p.student_id = u.id
                      WHERE u.role = 'siswa'
                      ORDER BY p.completed_at DESC";
            $stmt = $conn->prepare($query);
            $stmt->execute();
            $progress = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($progress);
        }
        break;
    
    case 'POST':
        $data = json_decode(file_get_contents("php://input"));
        if (!empty($data->student_id) && !empty($data->module) && !empty($data->material_id)) {
            $checkUser = $conn->prepare("SELECT id FROM users WHERE id = :student_id AND role = 'siswa' LIMIT 1");
            $checkUser->bindParam(":student_id", $data->student_id);
            $checkUser->execute();

            if (!$checkUser->fetch(PDO::FETCH_ASSOC)) {
                http_response_code(400);
                echo json_encode(["message" => "Progress hanya dapat disimpan untuk pengguna dengan role siswa"]);
                exit;
            }

            $query = "INSERT INTO student_progress (student_id, module, material_id, score) VALUES (:student_id, :module, :material_id, :score)";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(":student_id", $data->student_id);
            $stmt->bindParam(":module", $data->module);
            $stmt->bindParam(":material_id", $data->material_id);
            $stmt->bindParam(":score", $data->score);
            if ($stmt->execute()) {
                http_response_code(201);
                echo json_encode(["message" => "Progress recorded"]);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Failed to record progress"]);
            }
        }
        break;
}
?>
