import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/student_progress.dart';
import '../../../core/models/reading_material.dart';
import '../../../core/models/math_material.dart';
import '../../../core/models/writing_material.dart';
import '../profile/profile_screen.dart';
import '../modules/reading_screen.dart';
import '../modules/writing_screen.dart';
import '../modules/math_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final ApiService _apiService = ApiService();
  String? _activeCategory; // 'reading', 'writing', 'math', 'progress', null
  List<dynamic> _materials = [];
  bool _isLoading = false;

  void _setActiveCategory(String? category) async {
    setState(() {
      _activeCategory = category;
      _materials = [];
    });
    if (category != null) {
      await _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (_activeCategory == 'reading') {
        _materials = await _apiService.getReadingMaterials();
      } else if (_activeCategory == 'writing') {
        _materials = await _apiService.getWritingMaterials();
      } else if (_activeCategory == 'math') {
        _materials = await _apiService.getMathMaterials();
      } else if (_activeCategory == 'progress') {
        _materials = await _apiService.getStudentProgress();
      }
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddEditDialog([dynamic material]) {
    final isEdit = material != null;
    // Safely get content only for non-math categories
    final String initialContent = (isEdit && _activeCategory != 'math') ? ((material as dynamic).content ?? "") : "";
    final contentController = TextEditingController(text: initialContent);
    final levelController = TextEditingController(text: isEdit ? material.level.toString() : "1");
    
    final op1Controller = TextEditingController(text: (isEdit && _activeCategory == 'math') ? (material as MathMaterial).operand1.toString() : "");
    final op2Controller = TextEditingController(text: (isEdit && _activeCategory == 'math') ? (material as MathMaterial).operand2.toString() : "");
    final explanationController = TextEditingController(text: (isEdit && _activeCategory == 'math') ? (material as MathMaterial).explanation ?? "" : "");

    File? localImage;
    String? existingImagePath = isEdit ? material.imagePath : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(isEdit ? "Ubah Materi" : "Tambah Materi", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Picker Section
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setDialogState(() => localImage = File(image.path));
                    }
                  },
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
                    child: localImage != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(localImage!, fit: BoxFit.cover))
                        : existingImagePath != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network("${ApiService.materialAssetBaseUrl}$existingImagePath", fit: BoxFit.cover))
                            : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.grey), SizedBox(height: 8), Text("Tambah Gambar", style: TextStyle(color: Colors.grey, fontSize: 13))]),
                  ),
                ),
                const SizedBox(height: 20),
                if (_activeCategory != 'math')
                  TextField(controller: contentController, decoration: const InputDecoration(labelText: "Konten", border: OutlineInputBorder())),
                if (_activeCategory == 'math') ...[
                  Row(children: [
                    Expanded(child: TextField(controller: op1Controller, decoration: const InputDecoration(labelText: "Angka 1", border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("+", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                    Expanded(child: TextField(controller: op2Controller, decoration: const InputDecoration(labelText: "Angka 2", border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: 12),
                  TextField(controller: explanationController, decoration: const InputDecoration(labelText: "Penjelasan (Opsional)", border: OutlineInputBorder())),
                ],
                const SizedBox(height: 12),
                TextField(controller: levelController, decoration: const InputDecoration(labelText: "Level", border: OutlineInputBorder()), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                
                String? finalImagePath = existingImagePath;
                if (localImage != null) {
                  final uploadedPath = await _apiService.uploadMaterialImage(localImage!);
                  if (uploadedPath != null) finalImagePath = uploadedPath;
                }

                bool success = false;
                if (_activeCategory == 'reading') {
                  final data = {
                    "id": material?.id,
                    "type": "word",
                    "content": contentController.text,
                    "image_path": finalImagePath,
                    "level": int.tryParse(levelController.text) ?? 1,
                    "created_by": auth.user?.id
                  };
                  success = isEdit ? await _apiService.updateReadingMaterial(data) : await _apiService.addReadingMaterial(data);
                } else if (_activeCategory == 'writing') {
                  final data = {
                    "id": material?.id,
                    "content": contentController.text,
                    "image_path": finalImagePath,
                    "level": int.tryParse(levelController.text) ?? 1,
                    "created_by": auth.user?.id
                  };
                  success = isEdit ? await _apiService.updateWritingMaterial(data) : await _apiService.addWritingMaterial(data);
                } else if (_activeCategory == 'math') {
                  final data = {
                    "id": material?.id,
                    "operand1": int.tryParse(op1Controller.text) ?? 0,
                    "operand2": int.tryParse(op2Controller.text) ?? 0,
                    "explanation": explanationController.text,
                    "image_path": finalImagePath,
                    "level": int.tryParse(levelController.text) ?? 1,
                    "created_by": auth.user?.id
                  };
                  success = isEdit ? await _apiService.updateMathMaterial(data) : await _apiService.addMathMaterial(data);
                }
                
                if (success) {
                  if (mounted) Navigator.pop(context);
                  _loadData();
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

  void _deleteMaterial(int id) async {
    bool success = false;
    if (_activeCategory == 'reading') success = await _apiService.deleteReadingMaterial(id);
    if (_activeCategory == 'writing') success = await _apiService.deleteWritingMaterial(id);
    if (_activeCategory == 'math') success = await _apiService.deleteMathMaterial(id);
    if (success) _loadData();
  }

  Map<String, List<StudentProgress>> _getGroupedProgress() {
    final Map<String, List<StudentProgress>> grouped = {};
    for (var m in _materials) {
      if (m is StudentProgress) {
        final name = m.fullName ?? "Siswa";
        grouped.putIfAbsent(name, () => []).add(m);
      }
    }
    return grouped;
  }

  void _launchModule(dynamic material) {

    Widget screen;
    if (_activeCategory == 'reading') {
      screen = ReadingScreen(material: material as ReadingMaterial);
    } else if (_activeCategory == 'writing') {
      screen = WritingScreen(material: material as WritingMaterial);
    } else {
      screen = MathScreen(material: material as MathMaterial);
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

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
                      IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87), onPressed: () => _setActiveCategory(null))
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
                          const Text("Dashboard Guru BK", style: TextStyle(fontSize: 13, color: Colors.black54)),
                          Text(user?.fullName ?? "Guru", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => auth.logout(), icon: const Icon(Icons.logout_rounded, color: Colors.redAccent)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _activeCategory == null ? _buildMainDashboard(user?.fullName) : _buildCategoryManager(),
            ),
          ),
        ],
      ),
      floatingActionButton: (_activeCategory != null && _activeCategory != 'progress') ? FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.black87),
      ) : null,
    );
  }

  Widget _buildMainDashboard(String? name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Kelola Materi", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const Text("Pilih kategori untuk dikelola", style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard("Materi Membaca", Icons.menu_book_rounded, Colors.orange, () => _setActiveCategory('reading')),
                _buildMenuCard("Materi Menulis", Icons.edit_rounded, Colors.amber.shade700, () => _setActiveCategory('writing')),
                _buildMenuCard("Materi Berhitung", Icons.calculate_rounded, Colors.deepOrange, () => _setActiveCategory('math')),
                _buildMenuCard("Progres Siswa", Icons.trending_up_rounded, Colors.blue, () => _setActiveCategory('progress')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryManager() {
    String title = "";
    if (_activeCategory == 'reading') title = "Kelola Membaca";
    if (_activeCategory == 'writing') title = "Kelola Menulis";
    if (_activeCategory == 'math') title = "Kelola Berhitung";
    if (_activeCategory == 'progress') title = "Daftar Progres Siswa";

    return Column(
      key: ValueKey(_activeCategory),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const Spacer(), if (_isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))],
          ),
        ),
        Expanded(
          child: _isLoading && _materials.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _materials.isEmpty 
              ? const Center(child: Text("Belum ada data."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _activeCategory == 'progress' ? _getGroupedProgress().length : _materials.length,
                  itemBuilder: (context, index) {
                    if (_activeCategory == 'progress') {
                      final grouped = _getGroupedProgress();
                      if (index >= grouped.length) return const SizedBox();
                      
                      final studentName = grouped.keys.elementAt(index);
                      final progresses = grouped[studentName]!;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ExpansionTile(
                          shape: const RoundedRectangleBorder(side: BorderSide.none),
                          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                            child: const Icon(Icons.person, color: Colors.amber),
                          ),
                          title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text("${progresses.length} aktivitas diselesaikan", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
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
                    }

                    final m = _materials[index];
                    String subtitle = "Level: ${m.level}";
                    String contentText = (_activeCategory == 'math') ? "${m.operand1} + ${m.operand2} = ?" : (m.content ?? "");

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: Text(contentText, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(subtitle),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.green), onPressed: () => _launchModule(m)),
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddEditDialog(m)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteMaterial(m.id)),
                          ],
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
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, size: 40, color: color)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2),
            ),
          ],
        ),
      ),
    );
  }
}
