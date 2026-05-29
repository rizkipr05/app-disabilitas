<?php
include_once '../db_config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        $query = "SELECT * FROM math_materials ORDER BY level ASC";
        $stmt = $conn->prepare($query);
        $stmt->execute();
        $materials = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($materials);
        break;
    
    case 'POST':
        $data = json_decode(file_get_contents("php://input"));
        if (!empty($data->operand1) && !empty($data->operand2) && !empty($data->level)) {
            $query = "INSERT INTO math_materials (operand1, operand2, operation, explanation, image_path, level, created_by) VALUES (:operand1, :operand2, '+', :explanation, :image_path, :level, :created_by)";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(":operand1", $data->operand1);
            $stmt->bindParam(":operand2", $data->operand2);
            $stmt->bindParam(":explanation", $data->explanation);
            $stmt->bindParam(":image_path", $data->image_path);
            $stmt->bindParam(":level", $data->level);
            $stmt->bindParam(":created_by", $data->created_by);
            if ($stmt->execute()) {
                http_response_code(201);
                echo json_encode(["message" => "Math material added"]);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Failed to add material"]);
            }
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents("php://input"));
        if (!empty($data->id) && !empty($data->operand1) && !empty($data->operand2)) {
            $query = "UPDATE math_materials SET operand1 = :operand1, operand2 = :operand2, explanation = :explanation, image_path = :image_path, level = :level WHERE id = :id";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(":operand1", $data->operand1);
            $stmt->bindParam(":operand2", $data->operand2);
            $stmt->bindParam(":explanation", $data->explanation);
            $stmt->bindParam(":image_path", $data->image_path);
            $stmt->bindParam(":level", $data->level);
            $stmt->bindParam(":id", $data->id);
            if ($stmt->execute()) {
                echo json_encode(["message" => "Material updated"]);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Failed to update material"]);
            }
        }
        break;

    case 'DELETE':
        if (isset($_GET['id'])) {
            $query = "DELETE FROM math_materials WHERE id = :id";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(":id", $_GET['id']);
            $stmt->execute();
            echo json_encode(["message" => "Material deleted"]);
        }
        break;
}
?>
