import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  static const String _preferredAndroidEngine = 'com.google.android.tts';
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  late final Future<void> _initializationFuture;
  bool _isTtsInitialized = false;

  VoiceService._internal() {
    _initializationFuture = _initTts();
  }

  Future<void> _initTts() async {
    try {
      if (Platform.isLinux) {
        debugPrint(
          "VoiceService: Running on Linux, will use spd-say as fallback.",
        );
        _isTtsInitialized = true;
        return;
      }

      await _flutterTts.awaitSpeakCompletion(true);
      if (Platform.isAndroid) {
        await _configureAndroidVoice();
      }
      await _flutterTts.setLanguage("id-ID");
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.1);
      _isTtsInitialized = true;
    } catch (e) {
      debugPrint("VoiceService: Error initializing TTS: $e");
    }
  }

  Future<void> _configureAndroidVoice() async {
    try {
      final engines = await _flutterTts.getEngines;
      if (engines is List && engines.contains(_preferredAndroidEngine)) {
        await _flutterTts.setEngine(_preferredAndroidEngine);
        debugPrint("VoiceService: Using Google TTS engine.");
      }

      final voices = await _flutterTts.getVoices;
      final preferredVoice = _findPreferredIndonesianVoice(voices);
      if (preferredVoice != null) {
        await _flutterTts.setVoice(preferredVoice);
        debugPrint(
          "VoiceService: Using voice ${preferredVoice['name']} (${preferredVoice['locale']}).",
        );
      }
    } catch (e) {
      debugPrint("VoiceService: Unable to configure Android voice: $e");
    }
  }

  Map<String, String>? _findPreferredIndonesianVoice(dynamic voices) {
    if (voices is! List) return null;

    final List<Map<String, String>> candidates = voices
        .whereType<Map>()
        .map<Map<String, String>>(
          (voice) => voice.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ),
        )
        .where(
          (voice) => voice.containsKey('name') && voice.containsKey('locale'),
        )
        .toList();

    for (final voice in candidates) {
      final locale = voice['locale']?.toLowerCase() ?? '';
      final name = voice['name']?.toLowerCase() ?? '';
      if (locale.startsWith('id') && name.contains('google')) {
        return voice;
      }
    }

    for (final voice in candidates) {
      final locale = voice['locale']?.toLowerCase() ?? '';
      if (locale.startsWith('id')) {
        return voice;
      }
    }

    return null;
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    try {
      if (Platform.isLinux) {
        await Process.run('spd-say', [
          '-l',
          'id',
          '-p',
          '10',
          '-r',
          '-30',
          '-t',
          'female1',
          text,
        ]);
        return;
      }

      await _initializationFuture;
      if (_isTtsInitialized) {
        await _flutterTts.speak(text);
      }
    } catch (e) {
      debugPrint("VoiceService: Error during speak: $e");
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
      debugPrint("VoiceService: Error during stop: $e");
    }
  }
}
