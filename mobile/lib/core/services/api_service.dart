import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/user.dart';
import '../models/reading_material.dart';
import '../models/math_material.dart';
import '../models/writing_material.dart';
import '../models/student_progress.dart';

class ApiService {
  static const Map<String, String> _jsonHeaders = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  static String get _host {
    if (Platform.isAndroid) {
      return "10.0.2.2:8080";
    }
    return "localhost:8080";
  }

  static String get baseUrl => "http://$_host/app-disabilitas/api";
  static String get assetBaseUrl =>
      "http://$_host/app-disabilitas/uploads/profiles/";
  static String get materialAssetBaseUrl =>
      "http://$_host/app-disabilitas/uploads/materials/";

  Future<User?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login.php"),
        headers: _jsonHeaders,
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      }
    } catch (e) {
      print("Login error: $e");
    }
    return null;
  }

  /// Returns null on success, or error message string on failure.
  Future<String?> register(
    String fullName,
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register.php"),
        headers: _jsonHeaders,
        body: jsonEncode({
          "full_name": fullName,
          "username": username,
          "password": password,
        }),
      );
      if (response.statusCode == 201) return null; // success
      final data = jsonDecode(response.body);
      return data['message'] ?? "Registrasi gagal";
    } catch (e) {
      print("Register error: $e");
      return "Koneksi gagal";
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/admin/users.php"));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((u) => User.fromJson(u)).toList();
      }
    } catch (e) {
      print("Get users error: $e");
    }
    return [];
  }

  Future<bool> addUser(
    String fullName,
    String username,
    String password,
    String role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/users.php"),
        headers: _jsonHeaders,
        body: jsonEncode({
          "full_name": fullName,
          "username": username,
          "password": password,
          "role": role,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Add user error: $e");
      return false;
    }
  }

  Future<bool> updateUser({
    required int id,
    required String fullName,
    required String username,
    required String role,
    String? password,
  }) async {
    try {
      final body = <String, dynamic>{
        "id": id,
        "full_name": fullName,
        "username": username,
        "role": role,
      };
      if (password != null && password.isNotEmpty) {
        body["password"] = password;
      }

      final response = await http.put(
        Uri.parse("$baseUrl/admin/users.php"),
        headers: _jsonHeaders,
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Update user error: $e");
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/admin/users.php?id=$id"),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Delete user error: $e");
      return false;
    }
  }

  Future<List<ReadingMaterial>> getReadingMaterials() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/teacher/reading.php"),
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((m) => ReadingMaterial.fromJson(m)).toList();
      }
    } catch (e) {
      print("Get reading materials error: $e");
    }
    return [];
  }

  Future<List<MathMaterial>> getMathMaterials() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/teacher/math.php"));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((m) => MathMaterial.fromJson(m)).toList();
      }
    } catch (e) {
      print("Get math materials error: $e");
    }
    return [];
  }

  Future<List<WritingMaterial>> getWritingMaterials() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/teacher/writing.php"),
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((m) => WritingMaterial.fromJson(m)).toList();
      }
    } catch (e) {
      print("Get writing materials error: $e");
    }
    return [];
  }

  // --- READING MATERIALS ---

  Future<bool> addReadingMaterial(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/teacher/reading.php"),
        body: jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateReadingMaterial(Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/teacher/reading.php"),
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteReadingMaterial(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/teacher/reading.php?id=$id"),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- MATH MATERIALS ---

  Future<bool> addMathMaterial(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/teacher/math.php"),
        body: jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMathMaterial(Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/teacher/math.php"),
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMathMaterial(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/teacher/math.php?id=$id"),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- WRITING MATERIALS ---

  Future<bool> addWritingMaterial(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/teacher/writing.php"),
        body: jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateWritingMaterial(Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/teacher/writing.php"),
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteWritingMaterial(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/teacher/writing.php?id=$id"),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- STUDENT PROGRESS ---

  Future<List<StudentProgress>> getStudentProgress() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/student/progress.php"),
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((p) => StudentProgress.fromJson(p)).toList();
      }
    } catch (e) {
      print("Get progress error: $e");
    }
    return [];
  }

  Future<bool> postProgress(
    int studentId,
    String module,
    int materialId,
    int score,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/student/progress.php"),
        headers: _jsonHeaders,
        body: jsonEncode({
          "student_id": studentId,
          "module": module,
          "material_id": materialId,
          "score": score,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Post progress error: $e");
      return false;
    }
  }

  Future<User?> getUserProfile(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/profile.php?id=$id"),
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Get profile error: $e");
    }
    return null;
  }

  Future<bool> updateUserProfile(
    int id,
    String fullName,
    String username,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/user/update_profile.php"),
        body: jsonEncode({
          "id": id,
          "full_name": fullName,
          "username": username,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Update profile error: $e");
      return false;
    }
  }

  Future<String?> uploadProfileImage(int userId, File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/user/upload_profile.php"),
      );
      request.fields['user_id'] = userId.toString();
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['image_url'];
      }
    } catch (e) {
      print("Upload error: $e");
    }
    return null;
  }

  Future<String?> uploadMaterialImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/teacher/upload_material_image.php"),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['image_url'];
      }
    } catch (e) {
      print("Material upload error: $e");
    }
    return null;
  }

  Future<bool> changePassword(int id, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/user/change_password.php"),
        body: jsonEncode({"id": id, "new_password": newPassword}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Change password error: $e");
      return false;
    }
  }
}
