import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isUpdating = false;

  Future<void> _pickAndUpload() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _isUploading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId != null) {
      await _apiService.uploadProfileImage(userId, File(image.path));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto profil diperbarui!")));
    }
    if (mounted) setState(() => _isUploading = false);
  }

  void _showEditDialog(String label, String initialValue, bool isUsername) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ubah $label"),
        content: TextField(controller: controller, decoration: InputDecoration(labelText: label)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final user = auth.user;
              if (user == null) return;
              setState(() => _isUpdating = true);
              final fullName = isUsername ? user.fullName : controller.text;
              final username = isUsername ? controller.text : user.username;
              final success = await _apiService.updateUserProfile(user.id, fullName, username);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil diperbarui! Silakan login kembali.")));
              }
              if (mounted) setState(() => _isUpdating = false);
            },
            child: _isUpdating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final newPwController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ganti Password"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: newPwController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password Baru"),
                validator: (v) => (v == null || v.length < 6) ? "Minimal 6 karakter" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Konfirmasi Password"),
                validator: (v) => v != newPwController.text ? "Password tidak cocok" : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final userId = auth.user?.id;
              if (userId == null) return;
              final success = await _apiService.changePassword(userId, newPwController.text);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password berhasil diubah!")));
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          Container(height: 300, width: double.infinity, decoration: AppTheme.mainGradient),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87)),
                      const Text("Profil Saya", style: TextStyle(color: Colors.black87, fontSize: 26, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    decoration: const BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.primaryColor, width: 4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]),
                                child: CircleAvatar(
                                  radius: 70,
                                  backgroundColor: Colors.white,
                                  backgroundImage: user?.profileImage != null ? NetworkImage("${ApiService.assetBaseUrl}${user!.profileImage}") : null,
                                  child: user?.profileImage == null ? const Icon(Icons.person_rounded, size: 70, color: AppTheme.primaryColor) : null,
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: _isUploading ? null : _pickAndUpload,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                                    child: _isUploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 24),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
                          _buildEditableCard("Nama", user?.fullName ?? "-", () => _showEditDialog("Nama", user?.fullName ?? "", false)),
                          _buildEditableCard("Nama Pengguna", user?.username ?? "-", () => _showEditDialog("Nama Pengguna", user?.username ?? "", true)),
                          _buildLockedCard("Peran", (user?.role ?? "-").toUpperCase()),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: _showChangePasswordDialog,
                              icon: const Icon(Icons.lock_reset_rounded),
                              label: const Text("Ganti Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.redAccent,
                                elevation: 0,
                                side: const BorderSide(color: Colors.redAccent, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              child: const Text("KELUAR AKUN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCard(String label, String value, VoidCallback onEdit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.modernCard,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 18)),
              ],
            ),
          ),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primaryColor, size: 28)),
        ],
      ),
    );
  }

  Widget _buildLockedCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.modernCard,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 22),
        ],
      ),
    );
  }
}
