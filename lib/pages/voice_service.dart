import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  VoiceService._();
  static final VoiceService instance = VoiceService._();

  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();

  bool _speechReady = false;

  Future<void> init() async {
    _speechReady = await _speech.initialize();

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  Future<void> listen({
    required Function(String text) onResult,
  }) async {
    if (!_speechReady) {
      _speechReady = await _speech.initialize();
    }

    if (!_speechReady) {
      await speak('Voice recognition is not available.');
      return;
    }

    await _speech.listen(
      listenFor: const Duration(seconds: 5),
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}
