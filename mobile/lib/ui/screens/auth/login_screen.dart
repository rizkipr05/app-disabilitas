import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      final success = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).login(_usernameController.text, _passwordController.text);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login gagal. Periksa username dan password."),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.mainGradient,
        child: Stack(
          children: [
            // Decorative background circles
            Positioned(
              top: -100,
              right: -100,
              child: _buildDecorativeCircle(250, Colors.white.withOpacity(0.2)),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: _buildDecorativeCircle(
                200,
                Colors.white.withOpacity(0.15),
              ),
            ),
            Positioned(
              top: 200,
              left: -80,
              child: _buildDecorativeCircle(150, Colors.white.withOpacity(0.1)),
            ),

            // Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "GrahiEdu",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Text(
                      "Belajar Menyenangkan",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 48),
                    AppTheme.glassCard(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _usernameController,
                            label: "username",
                            icon: Icons.alternate_email_rounded,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _passwordController,
                            label: "password",
                            icon: Icons.lock_rounded,
                            obscure: true,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.black87,
                                elevation: 8,
                                shadowColor: AppTheme.primaryColor.withOpacity(
                                  0.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.black87,
                                    )
                                  : const Text(
                                      "MASUK",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }
}
