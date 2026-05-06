import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  String _selectedMood = 'Happy';
  String _userName = 'User';

  bool _showAllActivities = false;

  final List<HealthMood> _moods = const [
    HealthMood(label: 'Happy', emoji: '😊', color: Color(0xFFFDFFB6)),
    HealthMood(label: 'Calm', emoji: '😌', color: Color(0xFF9BF6FF)),
    HealthMood(label: 'Tired', emoji: '🥱', color: Color(0xFFFFC6FF)),
    HealthMood(label: 'Sad', emoji: '😔', color: Color(0xFFFFADAD)),
    HealthMood(label: 'Stressed', emoji: '😣', color: Color(0xFFCAFFBF)),
    HealthMood(label: 'Anxious', emoji: '😟', color: Color(0xFFD7C0FF)),
    HealthMood(label: 'Angry', emoji: '😡', color: Color(0xFFFFD6A5)),
    HealthMood(label: 'Sick', emoji: '🤒', color: Color(0xFFCDEAC0)),
  ];

  final List<HealthActivity> _activities = const [
    HealthActivity(
      title: 'Heart',
      value: 74,
      goal: 120,
      unit: 'BPM',
      emoji: '❤️',
      color: Color(0xFFFFADAD),
    ),
    HealthActivity(
      title: 'Sleep',
      value: 7,
      goal: 8,
      unit: 'Hours',
      emoji: '😴',
      color: Color(0xFF9BF6FF),
    ),
    HealthActivity(
      title: 'Walk',
      value: 4200,
      goal: 8000,
      unit: 'Steps',
      emoji: '👟',
      color: Color(0xFFFFC6FF),
    ),
    HealthActivity(
      title: 'Exercise',
      value: 35,
      goal: 60,
      unit: 'Minutes',
      emoji: '🏋️',
      color: Color(0xFFFDFFB6),
    ),
    HealthActivity(
      title: 'Water',
      value: 5,
      goal: 8,
      unit: 'Cups',
      emoji: '💧',
      color: Color(0xFFCAFFBF),
    ),
  ];

  final List<HealthTip> _tips = const [
    HealthTip(
      personName: 'Dr. Amal',
      personType: 'Doctor',
      title: '10 tips for better sleep',
      shortTip: 'Sleep at the same time every day.',
      color: Color(0xFFFDFFB6),
      emoji: '😴',
    ),
    HealthTip(
      personName: 'Ali',
      personType: 'Volunteer',
      title: 'Healthy food matters',
      shortTip: 'Try lighter meals and more water.',
      color: Color(0xFFFFC6FF),
      emoji: '🥗',
    ),
    HealthTip(
      personName: 'Sara',
      personType: 'Companion',
      title: 'Relax before sleeping',
      shortTip: 'Take deep breaths and avoid stress.',
      color: Color(0xFFFFADAD),
      emoji: '🧠',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserNameFromFirebase();
  }

  Future<void> _loadUserNameFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final name = data['name'] ?? data['fullName'] ?? data['username'];

        if (name != null && name.toString().trim().isNotEmpty) {
          setState(() {
            _userName = name.toString();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user name: $e');
    }
  }

  String _getGreeting() {
    final int hour = DateTime.now().hour;
    return hour < 12 ? 'Good Morning' : 'Good Evening';
  }

  Future<void> _saveMoodForCompanion(HealthMood mood) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('patient_mood_label', mood.label);
    await prefs.setString('patient_mood_emoji', mood.emoji);
    await prefs.setString('patient_mood_time', DateTime.now().toString());

    setState(() {
      _selectedMood = mood.label;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${mood.emoji} Mood saved and sent to companion')),
    );
  }

  void _openTipDetails(HealthTip tip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HealthTipDetailsPage(tip: tip)),
    );
  }

  void _openAIQuestions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIQuestionsPage()),
    );
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
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

  Widget _buildBottomNavigation() {
    return Container(
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
    );
  }

  Widget _buildHeader() {
    return Column(
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
                color: Color(0xFFF4F4F4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
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
                    'Health',
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
      ],
    );
  }

  Widget _buildProgressActivity(HealthActivity item) {
    final double progress = (item.value / item.goal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 38)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor: Colors.white.withOpacity(0.65),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF87CEEB)),
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.value.toInt()} / ${item.goal.toInt()} ${item.unit}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIButton() {
    return SizedBox(
      width: 82,
      height: 82,
      child: FloatingActionButton(
        onPressed: _openAIQuestions,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: const Color(0xFF87CEEB),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text('🤖', style: TextStyle(fontSize: 38)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activitiesToShow = _showAllActivities
        ? _activities
        : _activities.take(3).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        floatingActionButton: _buildAIButton(),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, $_userName',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 36),
                    const Text(
                      'How are you feeling today?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _moods.map((mood) {
                          final bool isSelected = _selectedMood == mood.label;

                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: GestureDetector(
                              onTap: () => _saveMoodForCompanion(mood),
                              child: Column(
                                children: [
                                  Container(
                                    width: 68,
                                    height: 68,
                                    decoration: BoxDecoration(
                                      color: mood.color,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        mood.emoji,
                                        style: const TextStyle(fontSize: 30),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    mood.label,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Today\'s Activity',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllActivities = !_showAllActivities;
                            });
                          },
                          child: Text(
                            _showAllActivities ? 'See less' : 'See more',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF87CEEB),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...activitiesToShow.map(_buildProgressActivity),
                    const SizedBox(height: 6),
                    const Text(
                      'Health Tips',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._tips.map((tip) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: () => _openTipDetails(tip),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: tip.color,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 34,
                                            height: 34,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${tip.personName} • ${tip.personType}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        tip.title,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        tip.shortTip,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  tip.emoji,
                                  style: const TextStyle(fontSize: 56),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }
}

class HealthMood {
  final String label;
  final String emoji;
  final Color color;

  const HealthMood({
    required this.label,
    required this.emoji,
    required this.color,
  });
}

class HealthActivity {
  final String title;
  final double value;
  final double goal;
  final String unit;
  final String emoji;
  final Color color;

  const HealthActivity({
    required this.title,
    required this.value,
    required this.goal,
    required this.unit,
    required this.emoji,
    required this.color,
  });
}

class HealthTip {
  final String personName;
  final String personType;
  final String title;
  final String shortTip;
  final Color color;
  final String emoji;

  const HealthTip({
    required this.personName,
    required this.personType,
    required this.title,
    required this.shortTip,
    required this.color,
    required this.emoji,
  });
}

class HealthTipDetailsPage extends StatelessWidget {
  final HealthTip tip;

  const HealthTipDetailsPage({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF87CEEB),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
            }
          },
          icon: const Icon(Icons.arrow_back, size: 28),
        ),
        title: const Text('Tip Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: tip.color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tip.personName} • ${tip.personType}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tip.title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tip.shortTip,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              const Text(
                'Here you can show full advice details, doctor notes, or more health information.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AIQuestionsPage extends StatefulWidget {
  const AIQuestionsPage({super.key});

  @override
  State<AIQuestionsPage> createState() => _AIQuestionsPageState();
}

class _AIQuestionsPageState extends State<AIQuestionsPage> {
  int _currentIndex = 0;
  final List<String?> _answers = List.filled(6, null);
  double _moodValue = 2;

  final List<AIQuestion> _questions = const [
    AIQuestion(
      title: 'How is your mood?',
      subtitle: 'On a scale of 1 – 3 how are you feeling today?',
      type: AIQuestionType.sliderMood,
      options: ['😒', '🙂', '😜'],
    ),
    AIQuestion(
      title: 'How was your day?',
      subtitle: 'Did you experience anything out of the ordinary?',
      type: AIQuestionType.options,
      options: [
        'Incredible 😇',
        'Great 😃',
        'Good 🙂',
        'Okay 🙁',
        'Really Bad 😞',
      ],
    ),
    AIQuestion(
      title: 'How is your energy level right now?',
      subtitle: 'Did you notice anything affecting your energy today?',
      type: AIQuestionType.options,
      options: ['High ⚡', 'Medium 🙂', 'Low 😴', 'Exhausted 🛌'],
    ),
    AIQuestion(
      title: 'How are you feeling physically?',
      subtitle: 'Did you experience any unusual physical symptoms?',
      type: AIQuestionType.options,
      options: ['Excellent 💪', 'Good 🙂', 'Okay 😐', 'Not well 🤒'],
    ),
    AIQuestion(
      title: 'Did you sleep well last night?',
      subtitle:
          'Did anything disturb your sleep or make it different than usual?',
      type: AIQuestionType.options,
      options: ['Excellent 🌙', 'Good 🙂', 'Okay 😐', 'Poor 😴'],
    ),
    AIQuestion(
      title: 'Do you need any help or support today?',
      subtitle: 'Is there anything specific you need help with today?',
      type: AIQuestionType.options,
      options: ['Yes ✅', 'Maybe 🤔', 'No ❌'],
    ),
  ];

  String _buildSmartResultMessage() {
    final mood = _answers[0] ?? '';
    final day = _answers[1] ?? '';
    final energy = _answers[2] ?? '';
    final physical = _answers[3] ?? '';
    final sleep = _answers[4] ?? '';
    final help = _answers[5] ?? '';

    if (help.contains('Yes')) {
      return 'Thank you for sharing. Since you selected that you need help today, it is a good idea to contact your companion or ask for support. You are not alone. 💙';
    }

    if (physical.contains('Not well')) {
      return 'Your answers show that you may not be feeling well physically today. Try to rest, drink water, and tell your companion if the feeling continues. 🤒';
    }

    if (sleep.contains('Poor')) {
      return 'It looks like your sleep was not good last night. Try to take things slowly today, rest when you can, and avoid too much stress. 😴';
    }

    if (energy.contains('Exhausted') || energy.contains('Low')) {
      return 'Your energy level seems low today. A short rest, light food, and drinking water may help you feel better. 🌿';
    }

    if (day.contains('Really Bad') || mood.contains('Bad')) {
      return 'It seems today was emotionally difficult. Take a deep breath, do something calming, and talk to someone you trust if you need comfort. 💙';
    }

    if (day.contains('Okay') ||
        physical.contains('Okay') ||
        sleep.contains('Okay')) {
      return 'Your answers show that your day is okay, but your body may still need some care. Try a light activity, drink water, and rest when needed. 🙂';
    }

    if (day.contains('Incredible') ||
        day.contains('Great') ||
        mood.contains('Very Happy')) {
      return 'Great job! Your answers show that you are feeling positive today. Keep taking care of yourself and continue your healthy routine. 🌟';
    }

    return 'Your answers look stable today. Keep monitoring your health, drink water, and take care of your body. 💙';
  }

  void _nextQuestion() {
    final AIQuestion question = _questions[_currentIndex];

    if (question.type == AIQuestionType.sliderMood) {
      if (_moodValue == 1) {
        _answers[_currentIndex] = 'Bad 😒';
      } else if (_moodValue == 2) {
        _answers[_currentIndex] = 'Good 🙂';
      } else {
        _answers[_currentIndex] = 'Very Happy 😜';
      }
    }

    if (question.type == AIQuestionType.options &&
        _answers[_currentIndex] == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please choose an answer')));
      return;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    final resultMessage = _buildSmartResultMessage();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('AI Result')),
          content: Text(
            resultMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _needHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help request sent to companion')),
    );
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HealthPage()),
      );
    }
  }

  Widget _buildHeader() {
    return Column(
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
                color: Color(0xFFF4F4F4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
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
                    'AI Health Check',
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AIQuestion question = _questions[_currentIndex];
    final double progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Question ${_currentIndex + 1}/6',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF5D6D7E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE2E7EC),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF87CEEB),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    const Spacer(),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            question.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            question.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF5D6D7E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (question.type == AIQuestionType.sliderMood)
                      _buildMoodSlider(question)
                    else
                      _buildOptions(question),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: _blueButton(
                            text: 'Need help?',
                            onTap: _needHelp,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _blueButton(
                            text: _currentIndex == _questions.length - 1
                                ? 'Finish'
                                : 'Next Question',
                            onTap: _nextQuestion,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSlider(AIQuestion question) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: question.options.map((emoji) {
            return Text(emoji, style: const TextStyle(fontSize: 42));
          }).toList(),
        ),
        const SizedBox(height: 25),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF87CEEB),
            inactiveTrackColor: const Color(0xFFE2E7EC),
            thumbColor: const Color(0xFF87CEEB),
            overlayColor: const Color(0x3387CEEB),
            trackHeight: 4,
          ),
          child: Slider(
            value: _moodValue,
            min: 1,
            max: 3,
            divisions: 2,
            onChanged: (value) {
              setState(() {
                _moodValue = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(AIQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: question.options.map((option) {
        final bool selected = _answers[_currentIndex] == option;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                _answers[_currentIndex] = option;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFD9F3FF) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF87CEEB)
                      : const Color(0xFFE2E7EC),
                  width: 2,
                ),
              ),
              child: Text(
                option,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  color: Color(0xFF5D6D7E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _blueButton({required String text, required VoidCallback onTap}) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF87CEEB),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

enum AIQuestionType { sliderMood, options }

class AIQuestion {
  final String title;
  final String subtitle;
  final AIQuestionType type;
  final List<String> options;

  const AIQuestion({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.options,
  });
}
