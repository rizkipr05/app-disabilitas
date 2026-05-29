<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
include_once '../db_config.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method == 'POST') {
    if (isset($_FILES['image'])) {
        $target_dir = "../../uploads/materials/";
        if (!file_exists($target_dir)) {
            mkdir($target_dir, 0777, true);
        }
        
        $file_extension = pathinfo($_FILES["image"]["name"], PATHINFO_EXTENSION);
        $file_name = "material_" . time() . "_" . rand(1000, 9999) . "." . $file_extension;
        $target_file = $target_dir . $file_name;

        if (move_uploaded_file($_FILES["image"]["tmp_name"], $target_file)) {
            echo json_encode(["message" => "Image uploaded successfully", "image_url" => $file_name]);
        } else {
            http_response_code(500);
            echo json_encode(["message" => "File upload failed"]);
        }
    } else {
        http_response_code(400);
        echo json_encode(["message" => "No image uploaded"]);
    }
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
