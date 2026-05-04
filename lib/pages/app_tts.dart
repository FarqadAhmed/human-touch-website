import 'package:flutter_tts/flutter_tts.dart';

class AppTts {
  AppTts._();
  static final AppTts instance = AppTts._();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    if (_isInitialized) return;

    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      _isSpeaking = true;
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _tts.setCancelHandler(() {
      _isSpeaking = false;
    });

    _tts.setErrorHandler((message) {
      _isSpeaking = false;
    });

    _isInitialized = true;
  }

  bool _isArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  Future<void> speakPage(String text) async {
    await init();

    final cleaned = text.trim();
    if (cleaned.isEmpty) return;

    await _tts.stop();

    if (_isArabic(cleaned)) {
      await _tts.setLanguage('ar-SA');
    } else {
      await _tts.setLanguage('en-US');
    }

    await _tts.speak(cleaned);
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }
}
