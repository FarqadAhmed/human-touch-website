import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceAccessibilityService {
  static final VoiceAccessibilityService instance =
      VoiceAccessibilityService._internal();

  VoiceAccessibilityService._internal();

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<void> init() async {
    await _tts.setLanguage('ar-SA');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stopAll() async {
    await _tts.stop();
    await _speech.stop();
  }

  Future<void> readPageAndListen({
    required BuildContext context,
    required String pageText,
    required Map<String, WidgetBuilder> routes,
  }) async {
    await init();

    await speak(
      '$pageText. قل اسم الصفحة التي تريد الذهاب إليها. مثل الرئيسية، الصحة، التذكيرات، الطوارئ، التواصل، الخريطة، الإعدادات.',
    );

    await Future.delayed(const Duration(seconds: 8));

    bool available = await _speech.initialize();

    if (!available) {
      await speak('عذرًا، لم أتمكن من تشغيل الميكروفون.');
      return;
    }

    await speak('أنا أسمعك الآن. قل اسم الصفحة.');

    await Future.delayed(const Duration(seconds: 2));

    _speech.listen(
      localeId: 'ar_SA',
      listenFor: const Duration(seconds: 6),
      onResult: (result) async {
        if (!result.finalResult) return;

        final text = result.recognizedWords.toLowerCase();

        await _handleCommand(
          context: context,
          command: text,
          routes: routes,
        );
      },
    );
  }

  Future<void> _handleCommand({
    required BuildContext context,
    required String command,
    required Map<String, WidgetBuilder> routes,
  }) async {
    await _speech.stop();

    String? routeKey;

    if (command.contains('الرئيسية') || command.contains('الرئيسيه')) {
      routeKey = 'dashboard';
    } else if (command.contains('الصحة') || command.contains('الصحه')) {
      routeKey = 'health';
    } else if (command.contains('التذكيرات') || command.contains('تذكيرات')) {
      routeKey = 'reminders';
    } else if (command.contains('الطوارئ') || command.contains('طوارئ')) {
      routeKey = 'emergency';
    } else if (command.contains('التواصل') || command.contains('اتواصل')) {
      routeKey = 'communication';
    } else if (command.contains('الخريطة') || command.contains('خريطة')) {
      routeKey = 'map';
    } else if (command.contains('الإعدادات') ||
        command.contains('الاعدادات') ||
        command.contains('اعدادات')) {
      routeKey = 'settings';
    }

    if (routeKey != null && routes.containsKey(routeKey)) {
      await speak('جارٍ فتح الصفحة.');

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: routes[routeKey]!,
        ),
      );
    } else {
      await speak('لم أفهم اسم الصفحة. حاول مرة أخرى.');
    }
  }
}
