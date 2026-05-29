import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/student_progress.dart';
import '../../../core/models/user.dart';
import '../../../providers/auth_provider.dart';
import '../profile/profile_screen.dart';
import '../teacher/teacher_dashboard.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _api = ApiService();
  List<User> _users = [];
  List<StudentProgress> _progress = [];
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final u = await _api.getUsers();
    final p = await _api.getStudentProgress();
    setState(() { _users = u; _progress = p; _loading = false; });
  }

  Map<String, List<StudentProgress>> _getGroupedProgress() {
    final Map<String, List<StudentProgress>> grouped = {};
    for (var p in _progress) {
      final name = p.fullName ?? "Siswa";
      grouped.putIfAbsent(name, () => []).add(p);
    }
    return grouped;
  }

  void _showAddUserDialog() {
    final fullNameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'siswa';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Tambah Pengguna", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: fullNameController, decoration: const InputDecoration(labelText: "Nama Lengkap", prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 12),
                TextField(controller: usernameController, decoration: const InputDecoration(labelText: "Username", prefixIcon: Icon(Icons.alternate_email))),
                const SizedBox(height: 12),
                TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline)), obscureText: true),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text("Admin")),
                    DropdownMenuItem(value: 'guru_bk', child: Text("Guru BK")),
                    DropdownMenuItem(value: 'siswa', child: Text("Siswa")),
                  ],
                  onChanged: (val) => setDialogState(() => selectedRole = val!),
                  decoration: InputDecoration(
                    labelText: "Peran",
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                if (fullNameController.text.isEmpty || usernameController.text.isEmpty || passwordController.text.isEmpty) return;
                final success = await _api.addUser(fullNameController.text, usernameController.text, passwordController.text, selectedRole);
                if (success) {
                  if (mounted) Navigator.pop(context);
                  _loadAll();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              child: const Text("Simpan", style: TextStyle(color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFC107)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(children: [
                  Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        backgroundImage: user?.profileImage != null ? NetworkImage("${ApiService.assetBaseUrl}${user!.profileImage}") : null,
                        child: user?.profileImage == null ? const Icon(Icons.admin_panel_settings_rounded, color: Colors.black87) : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text("Admin Panel", style: TextStyle(fontSize: 13, color: Colors.black54)),
                        Text(user?.fullName ?? "Admin", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ]),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherDashboard())),
                      icon: const Icon(Icons.school_rounded, color: Colors.black87),
                      tooltip: "Dashboard Guru",
                    ),
                    IconButton(
                      onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  // Stats Row
                  Row(children: [
                    _buildStatCard("👥 Pengguna", _users.length.toString(), Colors.white.withOpacity(0.7)),
                    const SizedBox(width: 12),
                    _buildStatCard("📊 Progres", _progress.length.toString(), Colors.white.withOpacity(0.7)),
                  ]),
                ]),
              ),
            ),
          ),
          // Tab Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              Expanded(child: _tabButton("Pengguna", Icons.people_rounded, 0)),
              const SizedBox(width: 10),
              Expanded(child: _tabButton("Progres Siswa", Icons.trending_up_rounded, 1)),
            ]),
          ),
          // Content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _tab == 0 ? _buildUsersTab() : _buildProgressTab(),
          ),
        ],
      ),
      floatingActionButton: _tab == 0 ? FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.person_add_rounded, color: Colors.black87),
      ) : null,
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ]),
      ),
    );
  }

  Widget _tabButton(String label, IconData icon, int idx) {
    final active = _tab == idx;
    return GestureDetector(
      onTap: () => setState(() => _tab = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: active ? AppTheme.primaryColor.withOpacity(0.3) : Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: active ? Colors.black87 : Colors.grey),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: active ? Colors.black87 : Colors.grey, fontSize: 13)),
        ]),
      ),
    );
  }

  Widget _buildUsersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (ctx, i) {
        final u = _users[i];
        final roleColors = {'admin': Colors.red, 'guru_bk': AppTheme.primaryColor, 'siswa': Colors.blue};
        final color = roleColors[u.role] ?? Colors.grey;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Row(children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(Icons.person_rounded, color: color)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text("@${u.username}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(u.role.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold))),
          ]),
        );
      },
    );
  }

  Widget _buildProgressTab() {
    final grouped = _getGroupedProgress();
    final studentNames = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: studentNames.length,
      itemBuilder: (ctx, i) {
        final studentName = studentNames[i];
        final progresses = grouped[studentName]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(side: BorderSide.none),
            collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: const Icon(Icons.person, color: Colors.blue),
            ),
            title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text("${progresses.length} aktivitas diselesaikan", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            children: progresses.map((p) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              leading: Icon(
                p.module == 'reading' ? Icons.menu_book_rounded : 
                p.module == 'writing' ? Icons.edit_rounded : Icons.calculate_rounded,
                size: 20,
                color: Colors.blueGrey,
              ),
              title: Text(p.module.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(p.completedAt, style: const TextStyle(fontSize: 11)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                child: Text("Skor: ${p.score}", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            )).toList(),
          ),
        );
      },
    );
  }
}
