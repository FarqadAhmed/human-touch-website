class CommunicationAiService {
  static Future<String> generateCommunicationMessage({
    required String input,
    required String category,
    required String mood,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final text = input.toLowerCase();

    if (category == 'Emergency') {
      if (text.contains('cannot speak') || text.contains('can\'t speak')) {
        return 'I cannot speak right now, but I need urgent help. Please assist me immediately.';
      }
      if (text.contains('danger') || text.contains('help')) {
        return 'I am in danger and I need immediate help. Please stay with me and contact emergency support now.';
      }
      return 'I need urgent help right now. Please assist me immediately.';
    }

    if (category == 'Medical') {
      if (text.contains('pain')) {
        return 'I am feeling pain and I need medical assistance, please.';
      }
      if (text.contains('medicine') || text.contains('medication')) {
        return 'I need my medication, please help me get it.';
      }
      if (text.contains('tired') || text.contains('weak')) {
        return 'I feel very tired and I need help or a place to rest.';
      }
      return 'I need medical support, please help me.';
    }

    if (category == 'Public Places') {
      if (text.contains('bathroom') || text.contains('toilet')) {
        return 'Could you please guide me to the nearest accessible bathroom?';
      }
      if (text.contains('entrance')) {
        return 'Could you please show me the accessible entrance?';
      }
      if (text.contains('slow')) {
        return 'Please speak more slowly so I can understand clearly.';
      }
      return 'I need assistance in this public place, please.';
    }

    if (category == 'Transport') {
      if (text.contains('destination')) {
        return 'I need help reaching my destination safely.';
      }
      if (text.contains('car') ||
          text.contains('taxi') ||
          text.contains('transport')) {
        return 'I need accessible transportation, please.';
      }
      return 'Please help me with transportation.';
    }

    if (text.contains('water')) {
      return 'I need water, please.';
    }
    if (text.contains('food') ||
        text.contains('hungry') ||
        text.contains('eat')) {
      return 'I need food, please help me.';
    }
    if (text.contains('bathroom') || text.contains('toilet')) {
      return 'I need the bathroom, please guide me.';
    }
    if (text.contains('sit') ||
        text.contains('rest') ||
        text.contains('chair')) {
      return 'I need a place to sit and rest, please.';
    }

    if (mood == 'Sad') {
      return 'I am not feeling well emotionally, and I may need support or comfort right now.';
    }

    if (mood == 'Anxious') {
      return 'I feel anxious and I need calm support and clear guidance, please.';
    }

    return 'Please help me with: $input';
  }

  static Future<List<String>> getMoodActivities(String mood) async {
    await Future.delayed(const Duration(milliseconds: 500));

    switch (mood) {
      case 'Happy':
        return [
          'Play a quick memory card game.',
          'Try a fun drawing activity with colors.',
          'Listen to cheerful music and clap with the rhythm.',
          'Write three happy things about your day.',
          'Play a simple word puzzle game.',
        ];

      case 'Sad':
        return [
          'Listen to calming music for 5 minutes.',
          'Try a gentle breathing activity: inhale 4, exhale 4.',
          'Color a simple relaxing picture.',
          'Watch a short comforting animation.',
          'Write one good thing you want to do today.',
        ];

      case 'Stressed':
        return [
          'Play a slow matching game with soft colors.',
          'Do a 2-minute breathing exercise.',
          'Try a guided relaxation activity.',
          'Squeeze and release your hands slowly 10 times.',
          'Listen to nature sounds and focus on one sound.',
        ];

      case 'Bored':
        return [
          'Play a quiz game with easy questions.',
          'Try a puzzle or shape-matching game.',
          'Draw your favorite place.',
          'Do a mini challenge: name 5 animals, 5 foods, 5 colors.',
          'Play a short storytelling game.',
        ];

      case 'Angry':
        return [
          'Do a calming tap activity on the screen.',
          'Take deep breaths and count from 1 to 10 slowly.',
          'Try a color-filling game with relaxing shapes.',
          'Listen to peaceful sounds for 3 minutes.',
          'Write or tap what is bothering you.',
        ];

      case 'Tired':
        return [
          'Try a very light stretching activity.',
          'Listen to soft music while resting.',
          'Do a simple breathing exercise.',
          'Watch a short gentle animation.',
          'Choose a low-energy game like matching pairs.',
        ];

      case 'Anxious':
        return [
          'Follow a guided breathing game.',
          'Try a simple focus activity: find 5 things around you.',
          'Listen to reassurance audio.',
          'Play a gentle color-tap game.',
          'Read short calming phrases one by one.',
        ];

      case 'Calm':
      default:
        return [
          'Play a relaxing puzzle game.',
          'Try a gratitude activity and write 3 nice things.',
          'Read a short positive story.',
          'Do a light memory challenge.',
          'Listen to quiet background music.',
        ];
    }
  }
}
