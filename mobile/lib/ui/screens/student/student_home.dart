import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../modules/reading_screen.dart';
import '../modules/writing_screen.dart';
import '../modules/math_screen.dart';
import '../profile/profile_screen.dart';
import '../../../core/models/reading_material.dart';
import '../../../core/models/writing_material.dart';
import '../../../core/models/math_material.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final ApiService _api = ApiService();
  List<ReadingMaterial> _reading = [];
  List<WritingMaterial> _writing = [];
  List<MathMaterial> _math = [];
  bool _loading = true;
  String? _activeCategory;
  List<dynamic> _materials = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final r = await _api.getReadingMaterials();
    final w = await _api.getWritingMaterials();
    final m = await _api.getMathMaterials();
    if (mounted) {
      setState(() {
        _reading = r;
        _writing = w;
        _math = m;
        _loading = false;
      });
    }
  }

  void _setCategory(String category) {
    setState(() {
      _activeCategory = category;
      if (category == 'reading') _materials = _reading;
      if (category == 'writing') _materials = _writing;
      if (category == 'math') _materials = _math;
    });
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Yellow gradient header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFC107)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Row(
                  children: [
                    if (_activeCategory != null)
                      IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87), onPressed: () => setState(() { _activeCategory = null; _materials = []; }))
                    else
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white.withOpacity(0.5),
                          backgroundImage: user?.profileImage != null ? NetworkImage("${ApiService.assetBaseUrl}${user!.profileImage}") : null,
                          child: user?.profileImage == null ? const Icon(Icons.person_rounded, color: Colors.black87) : null,
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Halo, ${user?.fullName ?? 'Siswa'}! 👋", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const Text("Ayo belajar hari ini! 🌟", style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(), icon: const Icon(Icons.logout_rounded, color: Colors.redAccent)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _activeCategory == null ? _buildHome(user?.fullName) : _buildMaterialList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHome(String? name) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Halo,\n${name ?? 'Siswa'}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          const Text("Siswa GrahiEdu", style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard("Membaca", Icons.menu_book_rounded, Colors.orange, () => _setCategory('reading')),
                _buildMenuCard("Menulis", Icons.edit_rounded, Colors.teal, () => _setCategory('writing')),
                _buildMenuCard("Berhitung", Icons.calculate_rounded, Colors.purple, () => _setCategory('math')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialList() {
    String title = "";
    IconData icon = Icons.book;
    Color color = Colors.orange;

    if (_activeCategory == 'reading') { title = "Pilih Bacaan"; icon = Icons.menu_book_rounded; color = Colors.orange; }
    if (_activeCategory == 'writing') { title = "Pilih Latihan"; icon = Icons.edit_rounded; color = Colors.teal; }
    if (_activeCategory == 'math') { title = "Pilih Soal"; icon = Icons.calculate_rounded; color = Colors.purple; }

    return Column(
      key: ValueKey(_activeCategory),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(children: [Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _materials.isEmpty
                  ? const Center(child: Text("Belum ada materi tersedia."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _materials.length,
                      itemBuilder: (context, index) {
                        final m = _materials[index];
                        String contentText = "";
                        Widget screen;

                        if (_activeCategory == 'reading') {
                          final r = m as ReadingMaterial;
                          contentText = r.content;
                          screen = ReadingScreen(material: r);
                        } else if (_activeCategory == 'writing') {
                          final w = m as WritingMaterial;
                          contentText = w.content;
                          screen = WritingScreen(material: w);
                        } else {
                          final mat = m as MathMaterial;
                          contentText = "${mat.operand1} + ${mat.operand2} = ?";
                          screen = MathScreen(material: mat);
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            onTap: () => _open(screen),
                            leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
                            title: Text(contentText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Text("Level ${m.level}", style: const TextStyle(color: Colors.grey)),
                            trailing: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(Icons.play_arrow_rounded, color: color),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, size: 40, color: color)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
