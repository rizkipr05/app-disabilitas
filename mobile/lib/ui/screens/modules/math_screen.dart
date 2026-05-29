import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../../../core/constants/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/voice_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/models/math_material.dart';

class MathScreen extends StatefulWidget {
  final MathMaterial material;
  const MathScreen({super.key, required this.material});

  @override
  State<MathScreen> createState() => _MathScreenState();
}

class _MathScreenState extends State<MathScreen> {
  final ApiService _apiService = ApiService();
  final List<List<Offset?>> _strokes = [];
  List<Offset?> _currentStroke = [];
  bool _isDone = false;
  bool _isSaving = false;
  bool _showGuide = false;
  final GlobalKey _canvasKey = GlobalKey();

  // Animation states
  bool _showOperand1 = false;
  bool _showOperand2 = false;

  int get _correctAnswer => widget.material.operand1 + widget.material.operand2;

  @override
  void initState() {
    super.initState();
    _startVisualLesson();
  }

  void _startVisualLesson() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _showOperand1 = true);
    await VoiceService().speak("${widget.material.operand1} apel");
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _showOperand2 = true);
    await VoiceService().speak("ditambah ${widget.material.operand2} apel");
    await Future.delayed(const Duration(milliseconds: 1200));
    await VoiceService().speak("sama dengan berapa apel?");
  }

  void _onPanStart(DragStartDetails d) => setState(() { _currentStroke = [d.localPosition]; });
  void _onPanUpdate(DragUpdateDetails d) => setState(() { _currentStroke.add(d.localPosition); });
  void _onPanEnd(DragEndDetails d) => setState(() { _strokes.add(List.from(_currentStroke)); _currentStroke = []; });

  void _clearCanvas() => setState(() { _strokes.clear(); _currentStroke.clear(); });

  /// Advanced Raster-based validation using Intersection over Union (IoU)
  Future<bool> _validateDrawing() async {
    final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;
    final size = renderBox.size;
    final int width = size.width.toInt();
    final int height = size.height.toInt();

    // 1. Rasterize Target Text
    final targetRecorder = ui.PictureRecorder();
    final targetCanvas = Canvas(targetRecorder);
    final textPainter = TextPainter(
      text: TextSpan(text: "$_correctAnswer", style: const TextStyle(fontSize: 160, fontWeight: FontWeight.bold, color: Colors.black)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textOffset = Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2);
    textPainter.paint(targetCanvas, textOffset);
    final targetImg = await targetRecorder.endRecording().toImage(width, height);
    final targetData = await targetImg.toByteData(format: ui.ImageByteFormat.rawRgba);

    // 2. Rasterize User Strokes
    final userRecorder = ui.PictureRecorder();
    final userCanvas = Canvas(userRecorder);
    final paint = Paint()..color = Colors.black..strokeWidth = 15..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
    for (var stroke in _strokes) {
      final path = Path();
      bool started = false;
      for (var p in stroke) {
        if (p == null) { started = false; continue; }
        if (!started) { path.moveTo(p.dx, p.dy); started = true; }
        else { path.lineTo(p.dx, p.dy); }
      }
      userCanvas.drawPath(path, paint);
    }
    final userImg = await userRecorder.endRecording().toImage(width, height);
    final userData = await userImg.toByteData(format: ui.ImageByteFormat.rawRgba);

    if (targetData == null || userData == null) return false;

    int intersectionCount = 0;
    int targetCount = 0;
    int userCount = 0;
    
    // Sampling pixels for performance
    const int step = 4;
    for (int y = 0; y < height; y += step) {
      for (int x = 0; x < width; x += step) {
        final index = (y * width + x) * 4;
        final targetAlpha = targetData.getUint8(index + 3);
        final userAlpha = userData.getUint8(index + 3);

        final bool isTarget = targetAlpha > 50;
        final bool isUser = userAlpha > 50;

        if (isTarget) targetCount++;
        if (isUser) userCount++;
        if (isTarget && isUser) intersectionCount++;
      }
    }

    if (targetCount == 0) return true;
    
    final coverage = intersectionCount / targetCount; // How much of the target did the user cover
    final precision = intersectionCount / userCount;  // How much of the user's drawing is actually on the target

    print("MATH VALIDATION: Coverage=${(coverage*100).toStringAsFixed(1)}%, Precision=${(precision*100).toStringAsFixed(1)}%");

    // Extremely Strict: Must cover at least 60% of the target AND at least 55% of user drawing must be on target
    // This makes it much harder for a '1' to pass for a '5' because '1' only covers ~20% of '5'.
    return coverage > 0.6 && precision > 0.55;
  }

  Future<void> _submit() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gambar jawabannya dulu ya! ✏️")));
      return;
    }
    setState(() => _isSaving = true);
    
    final isValid = await _validateDrawing();
    if (!isValid) {
      setState(() => _isSaving = false);
      await VoiceService().speak("Wah, sepertinya hitungannya belum tepat atau tulisannya kurang pas. Coba lagi ya!");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Jawaban belum tepat, coba jiplak bantuan atau hitung lagi ya!"), backgroundColor: Colors.orange));
      }
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    await VoiceService().speak("Wah, hitunganmu tepat sekali! Hebat!");
    await _apiService.postProgress(auth.user?.id ?? 0, 'math', widget.material.id, 100);
    setState(() { _isDone = true; _isSaving = false; });

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(children: [Text("🌟 "), Text("Kamu Hebat!", style: TextStyle(fontWeight: FontWeight.bold))]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(24)),
              child: Column(children: [
                Text("${widget.material.operand1} + ${widget.material.operand2} = $_correctAnswer", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                const Text("Semua jawabanmu benar! 🎉", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.black54)),
              ]),
            ),
          ]),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text("Lanjut ➡", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
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
      appBar: AppBar(title: const Text("Belajar Berhitung 🔢", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(children: [
          const SizedBox(height: 16),
          // Material Image
          if (widget.material.imagePath != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)], border: Border.all(color: Colors.amber.shade100, width: 2)),
            child: Column(children: [
              AnimatedOpacity(opacity: _showOperand1 ? 1.0 : 0.0, duration: const Duration(milliseconds: 500), child: Wrap(spacing: 4, runSpacing: 4, alignment: WrapAlignment.center, children: List.generate(widget.material.operand1, (i) => const Text("🍎", style: TextStyle(fontSize: 26))))),
              if (_showOperand2) Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Icon(Icons.add_circle_rounded, color: Colors.amber.shade700, size: 24)),
              AnimatedOpacity(opacity: _showOperand2 ? 1.0 : 0.0, duration: const Duration(milliseconds: 500), child: Wrap(spacing: 4, runSpacing: 4, alignment: WrapAlignment.center, children: List.generate(widget.material.operand2, (i) => const Text("🍏", style: TextStyle(fontSize: 26))))),
            ]),
          ),
          const SizedBox(height: 12),
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFA000)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)), child: Center(child: Text("${widget.material.operand1} + ${widget.material.operand2} = ?", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)))),
          const SizedBox(height: 12),
          Container(
            key: _canvasKey, height: 250, width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.primaryColor, width: 2.5), boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 8))]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(children: [
                if (_showGuide) Center(child: Text("$_correctAnswer", style: TextStyle(fontSize: 160, fontWeight: FontWeight.bold, color: Colors.amber.withOpacity(0.15), letterSpacing: 4))),
                GestureDetector(onPanStart: _isDone ? null : _onPanStart, onPanUpdate: _isDone ? null : _onPanUpdate, onPanEnd: _isDone ? null : _onPanEnd, child: CustomPaint(painter: _DrawingPainter(_strokes, _currentStroke), child: const SizedBox.expand())),
                Positioned(top: 12, right: 12, child: IconButton.filled(onPressed: () => setState(() => _showGuide = !_showGuide), icon: Icon(_showGuide ? Icons.visibility_off_rounded : Icons.lightbulb_rounded), style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor.withOpacity(0.8), foregroundColor: Colors.black87), tooltip: "Tampilkan Bantuan")),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: _isDone ? null : _clearCanvas, icon: const Icon(Icons.refresh_rounded), label: const Text("Hapus"), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: AppTheme.primaryColor, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
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
