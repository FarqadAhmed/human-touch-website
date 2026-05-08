import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';
import 'HealthSupportChat_page.dart';

class HealthAssessmentPage extends StatefulWidget {
  const HealthAssessmentPage({super.key});

  @override
  State<HealthAssessmentPage> createState() => _HealthAssessmentPageState();
}

class _HealthAssessmentPageState extends State<HealthAssessmentPage> {
  int _currentQuestionIndex = 0;
  double _moodValue = 2;
  bool _isSaving = false;

  final Map<int, dynamic> _answers = {};

  final List<AssessmentQuestion> _questions = [
    AssessmentQuestion(
      title: 'How is your mood?',
      subtitle: 'On a scale of 1 - 3 how are you feeling today?',
      type: QuestionType.slider,
      options: ['Low', 'Medium', 'High'],
    ),
    AssessmentQuestion(
      title: 'How was your day?',
      subtitle: 'Did you experience anything out of the ordinary?',
      type: QuestionType.singleChoice,
      options: [
        'Incredible 😇',
        'Great 😃',
        'Good 🙂',
        'Okay 😕',
        'Really Bad 😞',
      ],
    ),
    AssessmentQuestion(
      title: 'How is your energy level right now?',
      subtitle: 'Did you notice anything affecting your energy today?',
      type: QuestionType.singleChoice,
      options: ['High ⚡', 'Medium 🙂', 'Low 😴', 'Exhausted 🛌'],
    ),
    AssessmentQuestion(
      title: 'How are you feeling physically?',
      subtitle: 'Did you experience any unusual physical symptoms?',
      type: QuestionType.singleChoice,
      options: ['Excellent 💪', 'Good 🙂', 'Okay 😐', 'Not well 🤕'],
    ),
    AssessmentQuestion(
      title: 'Did you sleep well last night?',
      subtitle:
          'Did anything disturb your sleep or make it different than usual?',
      type: QuestionType.singleChoice,
      options: ['Excellent 🌙', 'Good 🙂', 'Okay 😐', 'Poor 😴'],
    ),
    AssessmentQuestion(
      title: 'Do you need any help or support today?',
      subtitle: 'Is there anything specific you need help with today?',
      type: QuestionType.singleChoice,
      options: ['Yes ✅', 'Maybe 🤔', 'No ❌'],
    ),
  ];

  AssessmentQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  double get _progress => (_currentQuestionIndex + 1) / _questions.length;

  void _saveCurrentAnswer() {
    if (_currentQuestion.type == QuestionType.slider) {
      _answers[_currentQuestionIndex] = _moodValue;
    }
  }

  String _moodTextFromValue(double value) {
    if (value <= 1) return 'Low';
    if (value <= 2) return 'Medium';
    return 'High';
  }

  String _moodEmojiFromValue(double value) {
    if (value <= 1) return '😞';
    if (value <= 2) return '🙂';
    return '😃';
  }

  bool _calculateNeedsHelp() {
    final dynamic q6 = _answers[5];

    return q6 == 'Yes ✅' ||
        q6 == 'Maybe 🤔' ||
        (_moodValue <= 1.5) ||
        _answers[1] == 'Really Bad 😞' ||
        _answers[2] == 'Exhausted 🛌' ||
        _answers[3] == 'Not well 🤕' ||
        _answers[4] == 'Poor 😴';
  }

  Future<void> _saveAssessmentToFirebase(bool needsHelp) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    final String result = needsHelp
        ? 'The patient may need support today.'
        : 'The patient seems okay today.';

    await FirebaseFirestore.instance.collection('health_assessments').add({
      'userId': user.uid,
      'moodValue': _moodValue,
      'mood': _moodTextFromValue(_moodValue),
      'moodEmoji': _moodEmojiFromValue(_moodValue),
      'dayStatus': _answers[1] ?? '',
      'energy': _answers[2] ?? '',
      'physical': _answers[3] ?? '',
      'sleep': _answers[4] ?? '',
      'supportNeeded': _answers[5] ?? '',
      'needsHelp': needsHelp,
      'result': result,
      'answers': {
        'mood': _moodTextFromValue(_moodValue),
        'dayStatus': _answers[1] ?? '',
        'energy': _answers[2] ?? '',
        'physical': _answers[3] ?? '',
        'sleep': _answers[4] ?? '',
        'supportNeeded': _answers[5] ?? '',
      },
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'lastAssessmentResult': result,
      'lastAssessmentNeedsHelp': needsHelp,
      'lastAssessmentMood': _moodTextFromValue(_moodValue),
      'lastAssessmentMoodEmoji': _moodEmojiFromValue(_moodValue),
      'lastAssessmentTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _goNext() async {
    if (_currentQuestion.type == QuestionType.slider) {
      _saveCurrentAnswer();
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      await _showFinalResult();
    }
  }

  void _selectOption(String value) {
    setState(() {
      _answers[_currentQuestionIndex] = value;
    });
  }

  bool get _canContinue {
    if (_currentQuestion.type == QuestionType.slider) {
      return true;
    }
    return _answers[_currentQuestionIndex] != null;
  }

  Future<void> _showFinalResult() async {
    final bool needsHelp = _calculateNeedsHelp();

    setState(() {
      _isSaving = true;
    });

    try {
      await _saveAssessmentToFirebase(needsHelp);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Assessment Result'),
            content: Text(
              needsHelp
                  ? 'The patient may need support today.'
                  : 'The patient seems okay today.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  if (needsHelp) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HealthSupportChatPage(),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text(needsHelp ? 'Open Help' : 'Done'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving assessment: $e')));
    }
  }

  Widget _buildQuestionContent() {
    if (_currentQuestion.type == QuestionType.slider) {
      final String moodText = _moodTextFromValue(_moodValue);
      final String emoji = _moodEmojiFromValue(_moodValue);

      return Column(
        children: [
          const SizedBox(height: 30),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('😞', style: TextStyle(fontSize: 42)),
              Text('🙂', style: TextStyle(fontSize: 42)),
              Text('😃', style: TextStyle(fontSize: 42)),
            ],
          ),
          const SizedBox(height: 24),
          Slider(
            activeColor: const Color(0xFF87CEEB),
            inactiveColor: const Color(0xFFE0E3E7),
            min: 1,
            max: 3,
            divisions: 2,
            value: _moodValue,
            onChanged: (value) {
              setState(() {
                _moodValue = value;
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            '$emoji  $moodText',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    final selectedValue = _answers[_currentQuestionIndex];

    return Column(
      children: _currentQuestion.options.map((option) {
        final bool isSelected = selectedValue == option;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _selectOption(option),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF87CEEB).withOpacity(0.20)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF87CEEB)
                      : const Color(0xFFE0E3E7),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF57636C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: const Color(0xFF87CEEB),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: Colors.black,
        size: icon == Icons.settings_outlined ? 45 : 50,
      ),
      splashColor: Colors.grey.withOpacity(0.20),
      highlightColor: Colors.grey.withOpacity(0.12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int questionNumber = _currentQuestionIndex + 1;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: SafeArea(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: double.infinity,
                    height: 130,
                    color: const Color(0xFF87CEEB),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Container(
                      width: double.infinity,
                      height: 41.1,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(70),
                          topRight: Radius.circular(70),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question $questionNumber/6',
                        style: const TextStyle(
                          color: Color(0xFF57636C),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 12,
                          backgroundColor: const Color(0xFFE0E3E7),
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF87CEEB),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),

                      Center(
                        child: Text(
                          _currentQuestion.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F1113),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _currentQuestion.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF57636C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      _buildQuestionContent(),

                      const SizedBox(height: 50),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isSaving
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HealthSupportChatPage(),
                                          ),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF87CEEB),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                child: const Text(
                                  'Need help?',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _canContinue && !_isSaving
                                    ? _goNext
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF87CEEB),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        questionNumber == 6
                                            ? 'Finish'
                                            : 'Next Question',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                height: 60,
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomNavItem(
                      icon: Icons.home_outlined,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardPage(),
                          ),
                        );
                      },
                    ),
                    _buildBottomNavItem(
                      icon: Icons.person_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
                    ),
                    _buildBottomNavItem(
                      icon: Icons.settings_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum QuestionType { slider, singleChoice }

class AssessmentQuestion {
  final String title;
  final String subtitle;
  final QuestionType type;
  final List<String> options;

  const AssessmentQuestion({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.options,
  });
}
