import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/voice_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/models/reading_material.dart';

class ReadingScreen extends StatefulWidget {
  final ReadingMaterial material;
  const ReadingScreen({super.key, required this.material});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final ApiService _apiService = ApiService();
  bool _isDone = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _startAudioPrompt();
  }

  void _startAudioPrompt() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await VoiceService().speak("Ayo baca kalimat ini!");
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted && !_isDone) {
      _speak();
    }
  }

  void _speak() async {
    setState(() => _isPlaying = true);
    await VoiceService().speak(widget.material.content);
    setState(() => _isPlaying = false);
  }

  void _finish() async {
    if (_isDone) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await VoiceService().speak("Wah, membacamu sudah lancar!");
    await _apiService.postProgress(auth.user?.id ?? 0, 'reading', widget.material.id, 100);
    setState(() => _isDone = true);

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(children: [Text("📖 "), Text("Hebat!", style: TextStyle(fontWeight: FontWeight.bold))]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Text(widget.material.content, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.deepOrange, letterSpacing: 4)),
            ),
            const SizedBox(height: 12),
            const Text("Kamu berhasil membaca kata ini! 🌟\nTerus semangat belajar ya!", textAlign: TextAlign.center),
          ]),
          actions: [
            ElevatedButton(
              onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Lanjut ➡", style: TextStyle(color: Colors.white)),
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
      appBar: AppBar(
        title: const Text("Belajar Membaca 📖", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Material Image
            if (widget.material.imagePath != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    "${ApiService.materialAssetBaseUrl}${widget.material.imagePath}",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            // Word Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFB300)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 12))],
              ),
              child: Column(
                children: [
                  Text(widget.material.content, style: const TextStyle(fontSize: 68, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 8)),
                  const SizedBox(height: 8),
                  Text("Level ${widget.material.level}", style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Speaker Button
            const Text("Dengarkan cara membacanya 👇", style: TextStyle(color: Colors.blueGrey)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _speak,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _isPlaying ? Colors.orange : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Icon(
                  _isPlaying ? Icons.volume_up_rounded : Icons.play_circle_fill_rounded,
                  size: 64,
                  color: _isPlaying ? Colors.white : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(_isPlaying ? "Sedang membaca..." : "Ketuk untuk mendengar", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const Spacer(),
            // Done Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isDone ? null : _finish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDone ? Colors.grey.shade300 : AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                ),
                child: Text(
                  _isDone ? "✅ Sudah Selesai" : "✅ Selesai!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isDone ? Colors.grey : Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
