import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsInitialized = false;

  VoiceService._internal() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      if (Platform.isLinux) {
        print("VoiceService: Running on Linux, will use spd-say as fallback.");
        _isTtsInitialized = true;
        return;
      }

      await _flutterTts.setLanguage("id-ID");
      await _flutterTts.setSpeechRate(0.4); // Slower is often clearer and softer
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.1); // Slightly higher pitch for child-friendly tone
      _isTtsInitialized = true;
    } catch (e) {
      print("VoiceService: Error initializing TTS: $e");
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    try {
      if (Platform.isLinux) {
        // -r -20 for slower rate, -p 10 for slightly higher pitch
        // Using 'female1' as it was identified in the voice list
        await Process.run('spd-say', [
          '-l', 'id', 
          '-p', '10', // Pitch
          '-r', '-30', // Rate (slower)
          '-t', 'female1', 
          text
        ]);
        return;
      }

      if (_isTtsInitialized) {
        await _flutterTts.speak(text);
      }
    } catch (e) {
      print("VoiceService: Error during speak: $e");
    }
  }

  Future<void> stop() async {
    try {
      if (Platform.isLinux) {
        await Process.run('spd-say', ['-S']); // Stop spd-say
        return;
      }
      await _flutterTts.stop();
    } catch (e) {
      print("VoiceService: Error during stop: $e");
    }
  }
}
