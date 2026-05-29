import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/user.dart';
import '../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  final ApiService _apiService = ApiService();

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    loadUser();
  }

  Future<bool> login(String username, String password) async {
    final result = await _apiService.login(username, password);
    if (result != null) {
      _user = result;
      await saveUser(result);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _user = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }

  Future<void> saveUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userStr = prefs.getString('user');
    if (userStr != null) {
      _user = User.fromJson(jsonDecode(userStr));
      notifyListeners();
    }
  }
}
