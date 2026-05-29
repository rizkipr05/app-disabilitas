<?php
include_once '../db_config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        $query = "SELECT * FROM reading_materials ORDER BY level ASC";
        $stmt = $conn->prepare($query);
        $stmt->execute();
        $materials = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($materials);
        break;
    
    case 'POST':
        $data = json_decode(file_get_contents("php://input"));
        if (!empty($data->type) && !empty($data->content) && !empty($data->level)) {
            $query = "INSERT INTO reading_materials (type, content, audio_path, image_path, level, created_by) VALUES (:type, :content, :audio_path, :image_path, :level, :created_by)";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(":type", $data->type);
            $stmt->bindParam(":content", $data->content);
            $stmt->bindParam(":audio_path", $data->audio_path);
            $stmt->bindParam(":image_path", $data->image_path);
            $stmt->bindParam(":level", $data->level);
            $stmt->bindParam(":created_by", $data->created_by);
            if ($stmt->execute()) {
                http_response_code(201);
                echo json_encode(["message" => "Reading material added"]);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Failed to add material"]);
            }
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents("php://input"));
        if (!empty($data->id) && !empty($data->content)) {
            $query = "UPDATE reading_materials SET type = :type, content = :content, level = :level, image_path = :image_path WHERE id = :id";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(":type", $data->type);
            $stmt->bindParam(":content", $data->content);
            $stmt->bindParam(":level", $data->level);
            $stmt->bindParam(":image_path", $data->image_path);
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
            $query = "DELETE FROM reading_materials WHERE id = :id";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(":id", $_GET['id']);
            $stmt->execute();
            echo json_encode(["message" => "Material deleted"]);
        }
        break;
}
?>
