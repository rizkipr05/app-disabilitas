import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final ApiService _api = ApiService();
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final error = await _api.register(
      _nameController.text.trim(),
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        // Berhasil
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(children: [Text("🎉 "), Text("Berhasil!")]),
            content: const Text("Akunmu sudah dibuat! Sekarang kamu bisa masuk dengan nama pengguna dan password yang tadi."),
            actions: [
              ElevatedButton(
                onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Masuk Sekarang ➡", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ $error"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFFC107), Color(0xFFFFFDE7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.4, 1],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: const Icon(Icons.person_add_rounded, size: 60, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 20),
                const Text("Daftar Akun Baru", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                const Text("Isi data di bawah untuk bergabung", style: TextStyle(color: Colors.black54, fontSize: 15)),
                const SizedBox(height: 32),
                // Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 12))],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _field(_nameController, "Nama Lengkap", Icons.badge_rounded, validator: (v) => (v == null || v.trim().isEmpty) ? "Nama tidak boleh kosong" : null),
                        const SizedBox(height: 16),
                        _field(_usernameController, "Nama Pengguna", Icons.person_rounded, validator: (v) {
                          if (v == null || v.trim().isEmpty) return "Nama pengguna tidak boleh kosong";
                          if (v.contains(' ')) return "Nama pengguna tidak boleh ada spasi";
                          return null;
                        }),
                        const SizedBox(height: 16),
                        _field(_passwordController, "Password", Icons.lock_rounded, obscure: _obscurePass, toggleObscure: () => setState(() => _obscurePass = !_obscurePass), validator: (v) => (v == null || v.length < 6) ? "Minimal 6 karakter" : null),
                        const SizedBox(height: 16),
                        _field(_confirmController, "Konfirmasi Password", Icons.lock_outline_rounded, obscure: _obscureConfirm, toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm), validator: (v) => v != _passwordController.text ? "Password tidak cocok" : null),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 6,
                              shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.black87)
                                : const Text("DAFTAR SEKARANG", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Sudah punya akun? ", style: TextStyle(color: Colors.black54)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text("Masuk", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {bool obscure = false, VoidCallback? toggleObscure, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        suffixIcon: toggleObscure != null
            ? IconButton(icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey), onPressed: toggleObscure)
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}
