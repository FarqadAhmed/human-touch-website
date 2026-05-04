import 'package:flutter/material.dart';

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
  final String _userName = 'Abdulla';

  final List<HealthMood> _moods = const [
    HealthMood(label: 'Happy', emoji: '😊', color: Color(0xFFFDFFB6)),
    HealthMood(label: 'Calm', emoji: '😌', color: Color(0xFF9BF6FF)),
    HealthMood(label: 'Tired', emoji: '🥱', color: Color(0xFFFFC6FF)),
    HealthMood(label: 'Sad', emoji: '😔', color: Color(0xFFFFADAD)),
    HealthMood(label: 'Stressed', emoji: '😣', color: Color(0xFFCAFFBF)),
  ];

  final List<HealthActivity> _activities = const [
    HealthActivity(
      title: 'Walking',
      value: '1036',
      unit: 'Steps',
      emoji: '👟',
      color: Color(0xFFFFC6FF),
    ),
    HealthActivity(
      title: 'Exercise',
      value: '65',
      unit: 'Minutes',
      emoji: '🏋️',
      color: Color(0xFFFDFFB6),
    ),
    HealthActivity(
      title: 'Heart Rate',
      value: '74',
      unit: 'BPM',
      emoji: '❤️',
      color: Color(0xFF9BF6FF),
    ),
    HealthActivity(
      title: 'Water',
      value: '9',
      unit: 'Cups',
      emoji: '💧',
      color: Color(0xFFFFADAD),
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

  String _getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour >= 0 && hour < 12) {
      return 'Good Morning';
    }
    return 'Good Evening';
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

  void _showComingSoon(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required VoidCallback onTap,
    bool isCurrent = false,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: icon == Icons.settings_outlined ? 45 : 50,
        color: isCurrent ? const Color(0xFF87CEEB) : Colors.black,
      ),
      splashColor: Colors.grey.withOpacity(0.20),
      highlightColor: Colors.grey.withOpacity(0.12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAIQuestions,
          backgroundColor: const Color(0xFF87CEEB),
          child: const Text(
            'AI',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 36),
                          const Text(
                            'How are you feeling today?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _moods.map((mood) {
                                final bool isSelected =
                                    _selectedMood == mood.label;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedMood = mood.label;
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 68,
                                          height: 68,
                                          decoration: BoxDecoration(
                                            color: mood.color,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
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
                                              style: const TextStyle(
                                                fontSize: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          mood.label,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
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
                                  color: Colors.black,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _showComingSoon(
                                    'Today\'s Activity details coming soon',
                                  );
                                },
                                child: const Text(
                                  'See more',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF87CEEB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            itemCount: _activities.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.82,
                                ),
                            itemBuilder: (context, index) {
                              final item = _activities[index];

                              return Container(
                                decoration: BoxDecoration(
                                  color: item.color,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      item.emoji,
                                      style: const TextStyle(fontSize: 56),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          item.value,
                                          style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w800,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            item.unit,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Doctors Tips / Health Tips',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _showComingSoon('Add Tip page goes here');
                                },
                                child: const Text(
                                  'Add Tip',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF00C9A7),
                                  ),
                                ),
                              ),
                            ],
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
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 20,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    '${tip.personName} • ${tip.personType}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomNavItem(
                      icon: Icons.home_outlined,
                      isCurrent: false,
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
                      isCurrent: false,
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
                      isCurrent: false,
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
  final String value;
  final String unit;
  final String emoji;
  final Color color;

  const HealthActivity({
    required this.title,
    required this.value,
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
  final List<String> _questions = const [
    'Are you feeling pain today?',
    'Did you sleep well last night?',
    'Did you drink enough water today?',
    'Do you feel very tired today?',
    'Are you feeling stressed or anxious?',
    'Do you think you need help today?',
  ];

  int _currentIndex = 0;
  final List<String> _answers = [];

  void _answerQuestion(String answer) {
    _answers.add(answer);

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      final bool needsHelp = _answers.where((e) => e == 'Yes').length >= 2;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('AI Result'),
            content: Text(
              needsHelp
                  ? 'The patient may need support today.'
                  : 'The patient seems okay today.',
            ),
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
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF87CEEB),
        elevation: 0,
        title: const Text('AI Questions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF87CEEB)),
              ),
              const SizedBox(height: 24),
              Text(
                'Question ${_currentIndex + 1} of ${_questions.length}',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Text(
                    _questions[_currentIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _answerQuestion('Yes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF87CEEB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Yes'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => _answerQuestion('No'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Color(0xFF87CEEB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('No'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
