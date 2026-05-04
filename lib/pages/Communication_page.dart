import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'services/communication_ai_service.dart';

class CommunicationPage extends StatefulWidget {
  const CommunicationPage({super.key});

  static const String routeName = '/communication';

  @override
  State<CommunicationPage> createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _needController = TextEditingController();

  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isGeneratingMessage = false;
  bool _isGeneratingActivities = false;

  final List<String> _categories = [
    'Daily Needs',
    'Medical',
    'Emergency',
    'Public Places',
    'Transport',
  ];

  final List<String> _moods = [
    'Happy',
    'Sad',
    'Stressed',
    'Bored',
    'Angry',
    'Tired',
    'Anxious',
    'Calm',
  ];

  final Map<String, List<String>> _categoryPrompts = {
    'Daily Needs': [
      'I need water',
      'I need food',
      'I need the bathroom',
      'I need a place to sit',
    ],
    'Medical': [
      'I feel pain',
      'I need my medicine',
      'I feel very tired',
      'I need medical help',
    ],
    'Emergency': [
      'I need urgent help',
      'I cannot speak, but I need help now',
      'Please stay with me',
      'Call emergency services',
    ],
    'Public Places': [
      'Where is the accessible entrance?',
      'I need wheelchair access',
      'Can you speak more slowly?',
      'I need assistance please',
    ],
    'Transport': [
      'I need accessible transportation',
      'Please help me reach my destination',
      'I need help getting in',
      'Where is the nearest accessible place?',
    ],
  };

  String _selectedCategory = 'Daily Needs';
  String _selectedMood = 'Calm';
  String _generatedMessage = '';
  List<String> _suggestedActivities = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final activities = await CommunicationAiService.getMoodActivities(
        _selectedMood,
      );

      if (mounted) {
        setState(() {
          _suggestedActivities = activities;
        });
      }
    });
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = true);
      }
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    });

    _flutterTts.setCancelHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    });

    _flutterTts.setErrorHandler((message) {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    });
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      _showSnackBar('Speech recognition is not available on this device.');
      return;
    }

    setState(() {
      _isListening = true;
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _needController.text = result.recognizedWords;
        });
      },
      listenMode: stt.ListenMode.confirmation,
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _speakMessage() async {
    if (_generatedMessage.trim().isEmpty) {
      _showSnackBar('Generate a message first.');
      return;
    }

    await _flutterTts.stop();
    await _flutterTts.speak(_generatedMessage);
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    if (mounted) {
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  Future<void> _generateMessage() async {
    if (_needController.text.trim().isEmpty) {
      _showSnackBar('Please type or say what you need first.');
      return;
    }

    setState(() {
      _isGeneratingMessage = true;
    });

    final result = await CommunicationAiService.generateCommunicationMessage(
      input: _needController.text.trim(),
      category: _selectedCategory,
      mood: _selectedMood,
    );

    if (mounted) {
      setState(() {
        _generatedMessage = result;
        _isGeneratingMessage = false;
      });
    }
  }

  Future<void> _loadMoodActivities(String mood) async {
    setState(() {
      _selectedMood = mood;
      _isGeneratingActivities = true;
    });

    final activities = await CommunicationAiService.getMoodActivities(mood);

    if (mounted) {
      setState(() {
        _suggestedActivities = activities;
        _isGeneratingActivities = false;
      });
    }
  }

  void _fillPrompt(String text) {
    setState(() {
      _needController.text = text;
    });
  }

  void _copyMessage() async {
    if (_generatedMessage.trim().isEmpty) {
      _showSnackBar('No generated message to copy.');
      return;
    }

    await Clipboard.setData(ClipboardData(text: _generatedMessage));
    _showSnackBar('Message copied successfully.');
  }

  void _clearAll() {
    setState(() {
      _needController.clear();
      _generatedMessage = '';
    });
  }

  void _showLargeTextDialog() {
    if (_generatedMessage.trim().isEmpty) {
      _showSnackBar('Generate a message first.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Large Text',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              _generatedMessage,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _speakMessage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87CEEB),
              ),
              child: const Text('Speak', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  TextStyle _titleStyle() {
    return GoogleFonts.outfit(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    );
  }

  TextStyle _bodyStyle({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = Colors.black87,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: const AlignmentDirectional(0, -1),
      children: [
        Container(
          width: double.infinity,
          height: 130,
          decoration: const BoxDecoration(color: Color(0xFF87CEEB)),
        ),
        Align(
          alignment: const AlignmentDirectional(0, -1),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 100, 0, 0),
            child: Container(
              width: double.infinity,
              height: 41.08,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F4),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(70),
                  topRight: Radius.circular(70),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 42, 0, 0),
          child: Column(
            children: [
              Text(
                'Communication',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Express your needs clearly with AI',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x14000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCommunicationCategorySection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Communication Category', style: _titleStyle()),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF87CEEB)
                        : const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    category,
                    style: _bodyStyle(
                      weight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTellAiSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell AI what you need', style: _titleStyle()),
          const SizedBox(height: 12),
          TextFormField(
            controller: _needController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Example: I need help finding an accessible bathroom',
              hintStyle: _bodyStyle(
                color: const Color(0xFF8A8A8A),
                weight: FontWeight.w500,
              ),
              filled: true,
              fillColor: const Color(0xFFF4F4F4),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            style: _bodyStyle(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isListening ? _stopListening : _startListening,
                  style: _buttonStyle(const Color(0xFF87CEEB)),
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  label: Text(
                    _isListening ? 'Stop Listening' : 'Listen',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _clearAll,
                  style: _buttonStyle(const Color(0xFF9E9E9E)),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(
                    'Clear',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Suggested Prompts', style: _bodyStyle(weight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_categoryPrompts[_selectedCategory] ?? []).map((prompt) {
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _fillPrompt(prompt),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    prompt,
                    style: _bodyStyle(
                      size: 12,
                      color: const Color(0xFF2F2F2F),
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGeneratingMessage ? null : _generateMessage,
              style: _buttonStyle(const Color(0xFF87CEEB)),
              icon: const Icon(Icons.auto_awesome),
              label: Text(
                _isGeneratingMessage ? 'Generating...' : 'Generate AI Message',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiResultSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Message Result', style: _titleStyle()),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 110),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _generatedMessage.isEmpty
                  ? 'The generated message will appear here.'
                  : _generatedMessage,
              style: _bodyStyle(
                size: _generatedMessage.isEmpty ? 15 : 16,
                weight: _generatedMessage.isEmpty
                    ? FontWeight.w400
                    : FontWeight.w600,
                color: _generatedMessage.isEmpty
                    ? const Color(0xFF8A8A8A)
                    : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _copyMessage,
                  style: _buttonStyle(const Color(0xFF5AB2FF)),
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(
                    'Copy',
                    style: GoogleFonts.outfit(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _speakMessage,
                  style: _buttonStyle(const Color(0xFF4CAF50)),
                  icon: const Icon(Icons.volume_up),
                  label: Text(
                    _isSpeaking ? 'Speaking...' : 'Speak',
                    style: GoogleFonts.outfit(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showLargeTextDialog,
                  style: _buttonStyle(const Color(0xFFFFA726)),
                  icon: const Icon(Icons.zoom_out_map),
                  label: Text(
                    'Large Text',
                    style: GoogleFonts.outfit(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _stopSpeaking,
                  style: _buttonStyle(const Color(0xFFE53935)),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(
                    'Stop',
                    style: GoogleFonts.outfit(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How do you feel today?', style: _titleStyle()),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood;
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _loadMoodActivities(mood),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF87CEEB)
                        : const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    mood,
                    style: _bodyStyle(
                      weight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodActivitiesSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Games & Activities for your mood', style: _titleStyle()),
          const SizedBox(height: 6),
          Text(
            'Selected mood: $_selectedMood',
            style: _bodyStyle(size: 12, color: const Color(0xFF6F6F6F)),
          ),
          const SizedBox(height: 14),
          if (_isGeneratingActivities)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(color: Color(0xFF87CEEB)),
              ),
            )
          else if (_suggestedActivities.isEmpty)
            Text('No activities found yet.', style: _bodyStyle())
          else
            Column(
              children: _suggestedActivities.map((activity) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.emoji_emotions_outlined,
                          color: Color(0xFF87CEEB),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          activity,
                          style: _bodyStyle(size: 14, weight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmergencySection() {
    final List<String> emergencyPhrases = [
      'I need urgent help',
      'I cannot speak, but I need help now',
      'Please stay with me',
      'Call emergency services',
    ];

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Quick Phrases',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          ...emergencyPhrases.map(
            (phrase) => InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                setState(() {
                  _selectedCategory = 'Emergency';
                  _needController.text = phrase;
                });
                await _generateMessage();
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEFEF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        phrase,
                        style: _bodyStyle(weight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      color: const Color(0xFFF4F4F4),
      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/dashboard');
            },
            child: const Icon(
              Icons.home_outlined,
              color: Colors.black87,
              size: 42,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/communication');
            },
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFF87CEEB),
              size: 42,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
            child: const Icon(
              Icons.settings_outlined,
              color: Colors.black87,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _needController.dispose();
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF4F4F4),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 10),
                child: Column(
                  children: [
                    _buildCommunicationCategorySection(),
                    const SizedBox(height: 14),
                    _buildTellAiSection(),
                    const SizedBox(height: 14),
                    _buildAiResultSection(),
                    const SizedBox(height: 14),
                    _buildMoodSection(),
                    const SizedBox(height: 14),
                    _buildMoodActivitiesSection(),
                    const SizedBox(height: 14),
                    _buildEmergencySection(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }
}
