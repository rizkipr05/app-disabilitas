import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/teacher/teacher_dashboard.dart';
import 'ui/screens/admin/admin_dashboard.dart';
import 'ui/screens/student/student_home.dart';
import 'core/constants/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GrahiEdu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    final role = authProvider.user?.role;
    switch (role) {
      case 'admin':
        return const AdminDashboard();
      case 'guru_bk':
        return const TeacherDashboard();
      case 'siswa':
      default:
        return const StudentHome();
    }
  }
}
