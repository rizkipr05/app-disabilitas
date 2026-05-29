<?php
include_once '../db_config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        if (isset($_GET['student_id'])) {
            $query = "SELECT * FROM student_progress WHERE student_id = :student_id ORDER BY completed_at DESC";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(":student_id", $_GET['student_id']);
            $stmt->execute();
            $progress = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($progress);
        } else {
            $query = "SELECT p.*, u.full_name FROM student_progress p JOIN users u ON p.student_id = u.id ORDER BY p.completed_at DESC";
            $stmt = $conn->prepare($query);
            $stmt->execute();
            $progress = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($progress);
        }
        break;
    
    case 'POST':
        $data = json_decode(file_get_contents("php://input"));
        if (!empty($data->student_id) && !empty($data->module) && !empty($data->material_id)) {
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
