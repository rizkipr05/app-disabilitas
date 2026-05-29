<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
include_once '../db_config.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method == 'POST') {
    if (isset($_FILES['image']) && isset($_POST['user_id'])) {
        $user_id = $_POST['user_id'];
        $target_dir = "../../uploads/profiles/";
        $file_extension = pathinfo($_FILES["image"]["name"], PATHINFO_EXTENSION);
        $file_name = "profile_" . $user_id . "_" . time() . "." . $file_extension;
        $target_file = $target_dir . $file_name;

        if (move_uploaded_file($_FILES["image"]["tmp_name"], $target_file)) {
            // Update database
            $query = "UPDATE users SET profile_image = :image WHERE id = :id";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(":image", $file_name);
            $stmt->bindParam(":id", $user_id);

            if ($stmt->execute()) {
                echo json_encode(["message" => "Profile image updated", "image_url" => $file_name]);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Database update failed"]);
            }
        } else {
            http_response_code(500);
            echo json_encode(["message" => "File upload failed"]);
        }
    } else {
        http_response_code(400);
        echo json_encode(["message" => "Incomplete request"]);
    }
}
?>
