import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';

class CommunicationPage extends StatefulWidget {
  const CommunicationPage({super.key});

  @override
  State<CommunicationPage> createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _aiChatController = TextEditingController();

  final FlutterTts _flutterTts = FlutterTts();

  String _selectedPlace = 'Transport';
  String _selectedMood = 'Calm';
  String _detectedSituation = 'General';
  String _generatedMessage = '';
  bool _isEmergency = false;

  final List<Map<String, String>> _aiMessages = [
    {
      'sender': 'ai',
      'text':
          'Hi, I am your AI companion. You can talk to me if you feel lonely or need help.',
    },
  ];

  final List<Map<String, dynamic>> _places = const [
    {
      'name': 'Hospital',
      'emoji': '🏥',
      'phrases': [
        'I am not feeling well.',
        'I need medical assistance.',
        'Please call a nurse.',
        'I feel dizzy.',
      ],
    },
    {
      'name': 'Restaurant',
      'emoji': '🍽️',
      'phrases': [
        'I need water please.',
        'I want to order food.',
        'Can you help me read the menu?',
        'I have food allergies.',
      ],
    },
    {
      'name': 'Street',
      'emoji': '🚶',
      'phrases': [
        'Can you help me cross the street?',
        'I need directions.',
        'I am lost.',
        'Please help me find a safe place.',
      ],
    },
    {
      'name': 'Transport',
      'emoji': '🚌',
      'phrases': [
        'Is this the right bus?',
        'Please tell me when we arrive.',
        'I need help getting in.',
        'Can you help me find my seat?',
      ],
    },
    {
      'name': 'Shopping',
      'emoji': '🛒',
      'phrases': [
        'I need help finding this item.',
        'How much does this cost?',
        'Can you help me carry this?',
        'I want to pay.',
      ],
    },
  ];

  final List<Map<String, String>> _moods = const [
    {'label': 'Calm', 'emoji': '😌'},
    {'label': 'Happy', 'emoji': '😊'},
    {'label': 'Sad', 'emoji': '😢'},
    {'label': 'Anxious', 'emoji': '😰'},
    {'label': 'Tired', 'emoji': '😴'},
    {'label': 'Angry', 'emoji': '😡'},
  ];

  final Map<String, List<String>> _moodActivities = const {
    'Calm': [
      'Take a short walk for 5 minutes.',
      'Listen to soft music.',
      'Drink water and relax.',
    ],
    'Happy': [
      'Share your feeling with someone.',
      'Do a small creative activity.',
      'Write one good thing about today.',
    ],
    'Sad': [
      'Talk to your companion or AI friend.',
      'Take slow deep breaths.',
      'Watch something comforting.',
    ],
    'Anxious': [
      'Try 4 deep breaths slowly.',
      'Hold something soft or comforting.',
      'Sit in a quiet place for 2 minutes.',
    ],
    'Tired': [
      'Rest for a few minutes.',
      'Drink water.',
      'Do gentle stretching.',
    ],
    'Angry': [
      'Pause and count to 10.',
      'Move to a calm place.',
      'Tell someone: I need a moment.',
    ],
  };

  Map<String, dynamic> get selectedPlaceData {
    return _places.firstWhere((place) => place['name'] == _selectedPlace);
  }

  Future<void> _speakMessage() async {
    if (_generatedMessage.isEmpty) return;

    await _flutterTts.stop();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(_generatedMessage);
  }

  void _analyzeSituation() {
    final text = _messageController.text.toLowerCase().trim();

    String situation = 'General';
    bool emergency = false;
    String result = '';

    if (text.contains('تعبان') ||
        text.contains('مريض') ||
        text.contains('دوخة') ||
        text.contains('dizzy') ||
        text.contains('sick') ||
        text.contains('pain') ||
        text.contains('tired')) {
      situation = 'Medical';
      result =
          'Hello, I am at the $_selectedPlace. I am not feeling well and I need medical assistance please.';
    } else if (text.contains('طوارئ') ||
        text.contains('ساعدوني') ||
        text.contains('اختنق') ||
        text.contains('emergency') ||
        text.contains('help now') ||
        text.contains('can’t breathe')) {
      situation = 'Emergency';
      emergency = true;
      result =
          'This is an emergency. I need help immediately. Please call my companion or emergency services.';
    } else if (text.contains('ضايع') ||
        text.contains('lost') ||
        text.contains('direction') ||
        text.contains('مكان')) {
      situation = 'Lost / Direction';
      result =
          'Hello, I am at the $_selectedPlace and I need help with directions. Can you guide me please?';
    } else if (text.contains('اكل') ||
        text.contains('ماي') ||
        text.contains('hungry') ||
        text.contains('water') ||
        text.contains('food')) {
      situation = 'Daily Need';
      result =
          'Hello, I am at the $_selectedPlace. I need help with food or water please.';
    } else {
      result =
          'Hello, I am at the $_selectedPlace. ${_messageController.text.trim().isEmpty ? 'I need assistance' : _messageController.text.trim()}. Can you help me please?';
    }

    if (_selectedMood == 'Anxious') {
      result += ' I feel anxious, so please speak slowly and calmly.';
    } else if (_selectedMood == 'Sad') {
      result += ' I feel sad and I may need extra support.';
    } else if (_selectedMood == 'Tired') {
      result += ' I feel tired and I may need time to respond.';
    } else if (_selectedMood == 'Angry') {
      result += ' I feel upset, please give me a moment.';
    }

    setState(() {
      _detectedSituation = situation;
      _isEmergency = emergency;
      _generatedMessage = result;
    });
  }

  void _talkForMe() {
    setState(() {
      _detectedSituation = 'Talk For Me';
      _isEmergency = false;
      _generatedMessage =
          'Hello, I need assistance. I may not be able to speak clearly. Please be patient and help me communicate.';
    });
  }

  void _emergencyMessage() {
    setState(() {
      _detectedSituation = 'Emergency';
      _isEmergency = true;
      _generatedMessage =
          'This is an emergency. I need help immediately. Please call my companion or emergency services.';
    });
  }

  void _copyMessage() {
    if (_generatedMessage.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _generatedMessage));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied'),
        backgroundColor: Color(0xFF87CEEB),
      ),
    );
  }

  void _showLargeText() {
    if (_generatedMessage.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Show Message',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                Text(
                  _generatedMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF87CEEB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAiCompanion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void sendMessage() {
              final text = _aiChatController.text.trim();
              if (text.isEmpty) return;

              setModalState(() {
                _aiMessages.add({'sender': 'user', 'text': text});
                _aiMessages.add({'sender': 'ai', 'text': _getAiReply(text)});
                _aiChatController.clear();
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.78,
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF7FBFD),
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 55,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '🤖 AI Companion',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Talk to me anytime you feel lonely or need help',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF777777)),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _aiMessages.length,
                      itemBuilder: (context, index) {
                        final msg = _aiMessages[index];
                        final isUser = msg['sender'] == 'user';

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.72,
                            ),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFF87CEEB)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: _shadow(),
                            ),
                            child: Text(
                              msg['text']!,
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.4,
                                color: isUser
                                    ? Colors.white
                                    : const Color(0xFF333333),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _aiChatController,
                          decoration: InputDecoration(
                            hintText: 'Type here...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 27,
                        backgroundColor: const Color(0xFF87CEEB),
                        child: IconButton(
                          onPressed: sendMessage,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getAiReply(String text) {
    final msg = text.toLowerCase();

    if (msg.contains('alone') ||
        msg.contains('lonely') ||
        msg.contains('وحيد') ||
        msg.contains('وحدي')) {
      return 'I am here with you. You are not alone. Do you want to talk about how you feel?';
    }

    if (msg.contains('sad') || msg.contains('حزين') || msg.contains('زعلان')) {
      return 'I am sorry you feel sad. Try taking a deep breath. I can stay with you and listen.';
    }

    if (msg.contains('help') ||
        msg.contains('مساعدة') ||
        msg.contains('ساعدني')) {
      return 'Of course. Tell me what you need, and I will help you prepare a clear message.';
    }

    if (msg.contains('pain') ||
        msg.contains('تعب') ||
        msg.contains('الم') ||
        msg.contains('تعبان')) {
      return 'It sounds like you may need medical support. Do you want me to prepare a medical assistance message?';
    }

    if (msg.contains('emergency') ||
        msg.contains('طوارئ') ||
        msg.contains('خطر')) {
      return 'This sounds urgent. Please press the Emergency button or call your companion immediately.';
    }

    return 'I understand. Tell me more, I am listening and I will try to support you.';
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    }
  }

  void _goToPage(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _aiChatController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phrases = selectedPlaceData['phrases'] as List<String>;
    final activities = _moodActivities[_selectedMood] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFD),

      floatingActionButton: FloatingActionButton.large(
        backgroundColor: const Color(0xFF87CEEB),
        elevation: 8,
        onPressed: _openAiCompanion,
        child: const Text('🤖', style: TextStyle(fontSize: 38)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: SafeArea(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  color: const Color(0xFF87CEEB),
                ),
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7FBFD),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 28,
                      color: Color(0xFF263238),
                    ),
                  ),

                  const Expanded(
                    child: Center(
                      child: Text(
                        'Communication',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Where are you now?'),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 115,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _places.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final place = _places[index];
                          final isSelected = place['name'] == _selectedPlace;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPlace = place['name'];
                                _generatedMessage = '';
                                _detectedSituation = 'General';
                                _isEmergency = false;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 105,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF87CEEB)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: _shadow(),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    place['emoji'],
                                    style: const TextStyle(fontSize: 34),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    place['name'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    _sectionTitle('Suggested phrases for $_selectedPlace'),
                    const SizedBox(height: 12),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: phrases.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.65,
                          ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _messageController.text = phrases[index];
                              _generatedMessage = phrases[index];
                              _detectedSituation = 'Quick Phrase';
                              _isEmergency = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: _shadow(),
                            ),
                            child: Center(
                              child: Text(
                                phrases[index],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    _sectionTitle('How do you feel?'),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 82,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _moods.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final mood = _moods[index];
                          final selected = mood['label'] == _selectedMood;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMood = mood['label']!;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 82,
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF87CEEB)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: _shadow(),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    mood['emoji']!,
                                    style: const TextStyle(fontSize: 27),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    mood['label']!,
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : const Color(0xFF333333),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: _shadow(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activities for $_selectedMood mood',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...activities.map(
                            (activity) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('✨ '),
                                  Expanded(
                                    child: Text(
                                      activity,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        color: Color(0xFF555555),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _sectionTitle('Quick Talk For Me'),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _quickModeCard(
                            emoji: '👤',
                            title: 'Talk For Me',
                            subtitle: 'One tap help',
                            color: const Color(0xFFE8F6FF),
                            onTap: _talkForMe,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _quickModeCard(
                            emoji: '🚨',
                            title: 'Emergency',
                            subtitle: 'Need help now',
                            color: const Color(0xFFFFE7E7),
                            onTap: _emergencyMessage,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _sectionTitle('Smart Situation Mode'),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: _shadow(),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _messageController,
                            minLines: 3,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText:
                                  'Example: I feel dizzy / تعبان / I need water...',
                              filled: true,
                              fillColor: const Color(0xFFF3F7FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton.icon(
                              onPressed: _analyzeSituation,
                              icon: const Text(
                                '🧠',
                                style: TextStyle(fontSize: 22),
                              ),
                              label: const Text(
                                'Analyze & Generate Message',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF87CEEB),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_generatedMessage.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _sectionTitle('AI Message Result'),
                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: _isEmergency
                              ? const Color(0xFFFFF0F0)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: _isEmergency
                                ? Colors.redAccent
                                : Colors.transparent,
                            width: 1.5,
                          ),
                          boxShadow: _shadow(),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _isEmergency
                                    ? Colors.redAccent
                                    : const Color(0xFFE8F6FF),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                'Detected: $_detectedSituation',
                                style: TextStyle(
                                  color: _isEmergency
                                      ? Colors.white
                                      : const Color(0xFF2B8DBD),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _generatedMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: _actionButton(
                                    icon: Icons.volume_up_rounded,
                                    text: 'Read',
                                    onTap: _speakMessage,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _actionButton(
                                    icon: Icons.copy_rounded,
                                    text: 'Copy',
                                    onTap: _copyMessage,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _actionButton(
                                    icon: Icons.open_in_full_rounded,
                                    text: 'Large',
                                    onTap: _showLargeText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF87CEEB),
          borderRadius: BorderRadius.circular(30),
          boxShadow: _shadow(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomItem(Icons.home_rounded, 'Home', 0),
            _bottomItem(Icons.person_rounded, 'Profile', 1),
            _bottomItem(Icons.settings_rounded, 'Settings', 2),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _quickModeCard({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(26),
          boxShadow: _shadow(),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 17),
      label: Text(text, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE8F6FF),
        foregroundColor: const Color(0xFF2B8DBD),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _bottomItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => _goToPage(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 27),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<BoxShadow> _shadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ];
  }
}
