import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/drawing_validation_service.dart';
import '../../../core/services/voice_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/models/writing_material.dart';

class WritingScreen extends StatefulWidget {
  final WritingMaterial material;
  const WritingScreen({super.key, required this.material});

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  final ApiService _apiService = ApiService();
  final List<List<Offset?>> _strokes = [];
  List<Offset?> _currentStroke = [];
  bool _isDone = false;
  bool _isSaving = false;
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _startAudioPrompt();
  }

  void _startAudioPrompt() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await VoiceService().speak("Ayo tulis huruf ini!");
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted && !_isDone) {
      await VoiceService().speak(widget.material.content);
    }
  }

  void _onPanStart(DragStartDetails d) => setState(() { _currentStroke = [d.localPosition]; });
  void _onPanUpdate(DragUpdateDetails d) => setState(() { _currentStroke.add(d.localPosition); });
  void _onPanEnd(DragEndDetails d) => setState(() { _strokes.add(List.from(_currentStroke)); _currentStroke = []; });

  void _clearCanvas() => setState(() { _strokes.clear(); _currentStroke.clear(); });

  Future<bool> _validateDrawing() async {
    final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;
    final result = await DrawingValidationService.compareDrawingToText(
      canvasSize: renderBox.size,
      targetText: widget.material.content,
      targetStyle: const TextStyle(
        fontSize: 150,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      strokes: _strokes,
      userStrokeWidth: 15,
    );

    if (result == null) return false;
    debugPrint(
      "WRITING VALIDATION: Coverage=${(result.coverage * 100).toStringAsFixed(1)}%, Precision=${(result.precision * 100).toStringAsFixed(1)}%",
    );

    return result.coverage > 0.44 && result.precision > 0.40;
  }

  Future<void> _submit() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gambar hurufnya dulu ya! ✏️")));
      return;
    }
    setState(() => _isSaving = true);
    
    final isValid = await _validateDrawing();
    if (!isValid) {
      setState(() => _isSaving = false);
      await VoiceService().speak("Wah, hurufnya belum sesuai. Coba tulis lagi ya!");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Hurufnya belum sesuai, coba tulis lagi ya!"), backgroundColor: Colors.orange));
      }
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    await VoiceService().speak("Bagus sekali! Tulisanmu keren!");
    await _apiService.postProgress(auth.user?.id ?? 0, 'writing', widget.material.id, 100);
    setState(() { _isDone = true; _isSaving = false; });

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(children: [Text("✏️ "), Text("Tulisanmu Keren!", style: TextStyle(fontWeight: FontWeight.bold))]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
              child: Text(widget.material.content, style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 6)),
            ),
            const SizedBox(height: 12),
            const Text("Kamu berhasil menulis! Terus berlatih ya 🌟", textAlign: TextAlign.center),
          ]),
          actions: [
            ElevatedButton(
              onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Lanjut ➡", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text("Belajar Menulis ✏️", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 12),
          // Material Image
          if (widget.material.imagePath != null)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  "${ApiService.materialAssetBaseUrl}${widget.material.imagePath}",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFA000)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))]),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(widget.material.content, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 8)),
              const SizedBox(width: 16),
              GestureDetector(onTap: () => VoiceService().speak(widget.material.content), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle), child: const Icon(Icons.volume_up_rounded, color: Colors.black87, size: 30))),
            ]),
          ),
          const SizedBox(height: 10),
          const Text("Tulis hurufnya di bawah ini. Tidak harus pas di posisi contoh. 👇", style: TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            key: _canvasKey, height: 270, width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.primaryColor, width: 2.5), boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 8))]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(children: [
                Center(child: Text(widget.material.content, style: TextStyle(fontSize: 150, fontWeight: FontWeight.bold, color: Colors.amber.withOpacity(0.12), letterSpacing: 4))),
                GestureDetector(onPanStart: _isDone ? null : _onPanStart, onPanUpdate: _isDone ? null : _onPanUpdate, onPanEnd: _isDone ? null : _onPanEnd, child: CustomPaint(painter: _DrawingPainter(_strokes, _currentStroke), child: const SizedBox.expand())),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: _isDone ? null : _clearCanvas, icon: const Icon(Icons.refresh_rounded), label: const Text("Hapus", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: AppTheme.primaryColor, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: ElevatedButton.icon(onPressed: (_isDone || _isSaving) ? null : _submit, icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87)) : const Icon(Icons.check_circle_rounded), label: const Text("Cek Hasil!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.black87, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4))),
          ]),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<List<Offset?>> strokes;
  final List<Offset?> currentStroke;
  _DrawingPainter(this.strokes, this.currentStroke);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFF57F17)..strokeWidth = 12..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
    void drawStroke(List<Offset?> stroke) {
      final path = Path();
      bool started = false;
      for (final point in stroke) {
        if (point == null) { started = false; continue; }
        if (!started) { path.moveTo(point.dx, point.dy); started = true; }
        else { path.lineTo(point.dx, point.dy); }
      }
      canvas.drawPath(path, paint);
    }
    for (final s in strokes) drawStroke(s);
    if (currentStroke.isNotEmpty) drawStroke(currentStroke);
  }
  @override
  bool shouldRepaint(_DrawingPainter old) => true;
}
