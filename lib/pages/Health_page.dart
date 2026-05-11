import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';

import 'package:humantouch/pages/app_settings_store.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  String _selectedMood = 'Happy';
  String _userName = 'User';
  bool _showAllActivities = false;

  bool get isArabic => AppSettingsStore.instance.isArabic;
  bool get isDarkMode => AppSettingsStore.instance.isDarkMode;

  Color get backgroundColor =>
      isDarkMode ? const Color(0xFF121212) : const Color(0xFFF4F4F4);

  Color get cardColor => isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

  Color get textColor => isDarkMode ? Colors.white : Colors.black;

  Color get subTextColor => isDarkMode ? Colors.white70 : Colors.black87;

  Color get lightCardColor =>
      isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFD9F3FF);

  String tr(String en, String ar) => isArabic ? ar : en;

  String moodName(String mood) {
    switch (mood) {
      case 'Happy':
        return tr('Happy', 'سعيد');
      case 'Calm':
        return tr('Calm', 'هادئ');
      case 'Tired':
        return tr('Tired', 'متعب');
      case 'Sad':
        return tr('Sad', 'حزين');
      case 'Stressed':
        return tr('Stressed', 'متوتر');
      case 'Anxious':
        return tr('Anxious', 'قلق');
      case 'Angry':
        return tr('Angry', 'غاضب');
      case 'Sick':
        return tr('Sick', 'مريض');
      default:
        return mood;
    }
  }

  String activityTitle(String title) {
    switch (title) {
      case 'Heart':
        return tr('Heart', 'القلب');
      case 'Sleep':
        return tr('Sleep', 'النوم');
      case 'Walk':
        return tr('Walk', 'المشي');
      case 'Exercise':
        return tr('Exercise', 'الرياضة');
      case 'Water':
        return tr('Water', 'الماء');
      default:
        return title;
    }
  }

  String unitName(String unit) {
    switch (unit) {
      case 'BPM':
        return tr('BPM', 'نبضة/دقيقة');
      case 'Hours':
        return tr('Hours', 'ساعات');
      case 'Steps':
        return tr('Steps', 'خطوة');
      case 'Minutes':
        return tr('Minutes', 'دقائق');
      case 'Cups':
        return tr('Cups', 'أكواب');
      default:
        return unit;
    }
  }

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

  @override
  void initState() {
    super.initState();
    _loadUserDataFromFirebase();
    AppSettingsStore.instance.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppSettingsStore.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  Future<void> _loadUserDataFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        final name = data['name'] ?? data['fullName'] ?? data['username'];
        final mood = data['patientMoodLabel'];

        setState(() {
          if (name != null && name.toString().trim().isNotEmpty) {
            _userName = name.toString();
          }

          if (mood != null && mood.toString().trim().isNotEmpty) {
            _selectedMood = mood.toString();
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  String _getGreeting() {
    final int hour = DateTime.now().hour;
    return hour < 12
        ? tr('Good Morning', 'صباح الخير')
        : tr('Good Evening', 'مساء الخير');
  }

  Future<void> _saveMoodForCompanion(HealthMood mood) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('Please login first', 'يرجى تسجيل الدخول أولاً')),
          ),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'patientMoodLabel': mood.label,
        'patientMoodEmoji': mood.emoji,
        'patientMoodTime': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _selectedMood = mood.label;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              '${mood.emoji} Mood saved and sent to companion',
              '${mood.emoji} تم حفظ المزاج وإرساله للمرافق',
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('Error saving mood: $e', 'حدث خطأ أثناء حفظ المزاج: $e'),
          ),
        ),
      );
    }
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
        color: isDarkMode
            ? Colors.black.withOpacity(0.35)
            : Colors.black.withOpacity(0.08),
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
          _bottomItem(Icons.home_rounded, tr('Home', 'الرئيسية'), 0),
          _bottomItem(Icons.person_rounded, tr('Profile', 'الملف'), 1),
          _bottomItem(Icons.settings_rounded, tr('Settings', 'الإعدادات'), 2),
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
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(40)),
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
                icon: Icon(
                  isArabic ? Icons.arrow_forward : Icons.arrow_back,
                  size: 28,
                  color: textColor,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    tr('Health', 'الصحة'),
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: textColor,
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
        boxShadow: isDarkMode ? _shadow() : null,
      ),
      child: Row(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 38)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  activityTitle(item.title),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
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
                  '${item.value.toInt()} / ${item.goal.toInt()} ${unitName(item.unit)}',
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
                color: Colors.black.withOpacity(isDarkMode ? 0.35 : 0.18),
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

  Widget _buildHealthTipsFromFirebase() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('healthTips')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: _shadow(),
            ),
            child: Text(
              tr('Could not load health tips.', 'تعذر تحميل النصائح الصحية.'),
              style: TextStyle(fontSize: 15, color: textColor),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFF87CEEB)),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: _shadow(),
            ),
            child: Text(
              tr(
                'No health tips yet. When a volunteer writes a tip, it will appear here.',
                'لا توجد نصائح صحية بعد. عندما يكتب المتطوع نصيحة، ستظهر هنا.',
              ),
              style: TextStyle(
                fontSize: 15,
                color: subTextColor,
                height: 1.4,
              ),
            ),
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data();

            final tip = HealthTip(
              id: doc.id,
              personName: (data['volunteerName'] ??
                      data['personName'] ??
                      data['name'] ??
                      'Volunteer')
                  .toString(),
              personType: (data['personType'] ?? 'Volunteer').toString(),
              title: (data['title'] ?? 'Health Tip').toString(),
              shortTip: (data['shortTip'] ??
                      data['description'] ??
                      data['tip'] ??
                      'No details available.')
                  .toString(),
              fullTip: (data['fullTip'] ??
                      data['description'] ??
                      data['tip'] ??
                      data['shortTip'] ??
                      'No details available.')
                  .toString(),
              category: (data['category'] ?? 'Health').toString(),
              emoji: (data['emoji'] ?? '💙').toString(),
              createdAt: data['createdAt'],
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => _openTipDetails(tip),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: lightCardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _shadow(),
                    border: isDarkMode
                        ? Border.all(color: Colors.white12, width: 1)
                        : null,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: isArabic
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? const Color(0xFF2A2A2A)
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.volunteer_activism,
                                    size: 20,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${tip.personName} • ${isArabic && tip.personType == 'Volunteer' ? 'متطوع' : tip.personType}',
                                    textAlign: isArabic
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              tip.title,
                              textAlign:
                                  isArabic ? TextAlign.right : TextAlign.left,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tip.shortTip,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign:
                                  isArabic ? TextAlign.right : TextAlign.left,
                              style: TextStyle(
                                fontSize: 15,
                                color: subTextColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tip.category,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDarkMode
                                    ? Colors.white60
                                    : const Color(0xFF5D6D7E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(tip.emoji, style: const TextStyle(fontSize: 52)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activitiesToShow =
        _showAllActivities ? _activities : _activities.take(3).toList();

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: backgroundColor,
          floatingActionButton: _buildAIButton(),
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()}, $_userName',
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Text(
                        tr(
                          'How are you feeling today?',
                          'كيف تشعر اليوم؟',
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
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
                                              ? const Color(0xFF87CEEB)
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
                                      moodName(mood.label),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textColor,
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
                          Text(
                            tr('Today\'s Activity', 'نشاط اليوم'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showAllActivities = !_showAllActivities;
                              });
                            },
                            child: Text(
                              _showAllActivities
                                  ? tr('See less', 'عرض أقل')
                                  : tr('See more', 'عرض المزيد'),
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
                      Text(
                        tr('Health Tips', 'نصائح صحية'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildHealthTipsFromFirebase(),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigation(),
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
  final String id;
  final String personName;
  final String personType;
  final String title;
  final String shortTip;
  final String fullTip;
  final String category;
  final String emoji;
  final dynamic createdAt;

  const HealthTip({
    required this.id,
    required this.personName,
    required this.personType,
    required this.title,
    required this.shortTip,
    required this.fullTip,
    required this.category,
    required this.emoji,
    required this.createdAt,
  });
}

class HealthTipDetailsPage extends StatelessWidget {
  final HealthTip tip;

  const HealthTipDetailsPage({super.key, required this.tip});

  bool get isArabic => AppSettingsStore.instance.isArabic;
  bool get isDarkMode => AppSettingsStore.instance.isDarkMode;

  Color get backgroundColor =>
      isDarkMode ? const Color(0xFF121212) : const Color(0xFFF4F4F4);

  Color get cardColor =>
      isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFD9F3FF);

  Color get textColor => isDarkMode ? Colors.white : Colors.black;

  Color get subTextColor =>
      isDarkMode ? Colors.white70 : const Color(0xFF5D6D7E);

  String tr(String en, String ar) => isArabic ? ar : en;

  String _formatDate(dynamic createdAt) {
    try {
      if (createdAt is Timestamp) {
        final date = createdAt.toDate();
        return '${date.day}/${date.month}/${date.year}';
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  void _goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HealthPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _formatDate(tip.createdAt);

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: const Color(0xFF87CEEB),
          elevation: 0,
          foregroundColor: Colors.white,
          leading: IconButton(
            onPressed: () => _goBack(context),
            icon: Icon(
              isArabic ? Icons.arrow_forward : Icons.arrow_back,
              size: 28,
              color: Colors.white,
            ),
          ),
          title: Text(tr('Tip Details', 'تفاصيل النصيحة')),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: isDarkMode
                  ? Border.all(color: Colors.white12, width: 1)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.35 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(tip.emoji, style: const TextStyle(fontSize: 54)),
                const SizedBox(height: 12),
                Text(
                  '${tip.personName} • ${isArabic && tip.personType == 'Volunteer' ? 'متطوع' : tip.personType}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (dateText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 13,
                      color: subTextColor,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  tip.title,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tip.category,
                  style: TextStyle(
                    fontSize: 15,
                    color: subTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  tip.fullTip,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: 17,
                    color: subTextColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
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

  bool get isArabic => AppSettingsStore.instance.isArabic;
  bool get isDarkMode => AppSettingsStore.instance.isDarkMode;

  Color get backgroundColor =>
      isDarkMode ? const Color(0xFF121212) : const Color(0xFFF4F4F4);

  Color get cardColor => isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

  Color get textColor => isDarkMode ? Colors.white : Colors.black;

  Color get subTextColor =>
      isDarkMode ? Colors.white70 : const Color(0xFF5D6D7E);

  String tr(String en, String ar) => isArabic ? ar : en;

  late final List<AIQuestion> _questions = [
    AIQuestion(
      title: tr('How is your mood?', 'كيف مزاجك؟'),
      subtitle: tr(
        'On a scale of 1 – 3 how are you feeling today?',
        'على مقياس من 1 إلى 3 كيف تشعر اليوم؟',
      ),
      type: AIQuestionType.sliderMood,
      options: const ['😒', '🙂', '😜'],
    ),
    AIQuestion(
      title: tr('How was your day?', 'كيف كان يومك؟'),
      subtitle: tr(
        'Did you experience anything out of the ordinary?',
        'هل حدث معك شيء غير معتاد؟',
      ),
      type: AIQuestionType.options,
      options: [
        tr('Incredible 😇', 'رائع جداً 😇'),
        tr('Great 😃', 'ممتاز 😃'),
        tr('Good 🙂', 'جيد 🙂'),
        tr('Okay 🙁', 'عادي 🙁'),
        tr('Really Bad 😞', 'سيء جداً 😞'),
      ],
    ),
    AIQuestion(
      title: tr('How is your energy level right now?', 'كيف مستوى طاقتك الآن؟'),
      subtitle: tr(
        'Did you notice anything affecting your energy today?',
        'هل لاحظت شيئاً أثر على طاقتك اليوم؟',
      ),
      type: AIQuestionType.options,
      options: [
        tr('High ⚡', 'عالية ⚡'),
        tr('Medium 🙂', 'متوسطة 🙂'),
        tr('Low 😴', 'منخفضة 😴'),
        tr('Exhausted 🛌', 'مرهق 🛌'),
      ],
    ),
    AIQuestion(
      title: tr('How are you feeling physically?', 'كيف تشعر جسدياً؟'),
      subtitle: tr(
        'Did you experience any unusual physical symptoms?',
        'هل شعرت بأي أعراض جسدية غير معتادة؟',
      ),
      type: AIQuestionType.options,
      options: [
        tr('Excellent 💪', 'ممتاز 💪'),
        tr('Good 🙂', 'جيد 🙂'),
        tr('Okay 😐', 'عادي 😐'),
        tr('Not well 🤒', 'لست بخير 🤒'),
      ],
    ),
    AIQuestion(
      title:
          tr('Did you sleep well last night?', 'هل نمت جيداً الليلة الماضية؟'),
      subtitle: tr(
        'Did anything disturb your sleep or make it different than usual?',
        'هل كان هناك شيء أزعج نومك أو جعله مختلفاً عن المعتاد؟',
      ),
      type: AIQuestionType.options,
      options: [
        tr('Excellent 🌙', 'ممتاز 🌙'),
        tr('Good 🙂', 'جيد 🙂'),
        tr('Okay 😐', 'عادي 😐'),
        tr('Poor 😴', 'ضعيف 😴'),
      ],
    ),
    AIQuestion(
      title: tr(
        'Do you need any help or support today?',
        'هل تحتاج إلى مساعدة أو دعم اليوم؟',
      ),
      subtitle: tr(
        'Is there anything specific you need help with today?',
        'هل يوجد شيء محدد تحتاج مساعدة فيه اليوم؟',
      ),
      type: AIQuestionType.options,
      options: [
        tr('Yes ✅', 'نعم ✅'),
        tr('Maybe 🤔', 'ربما 🤔'),
        tr('No ❌', 'لا ❌'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    AppSettingsStore.instance.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppSettingsStore.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  String _buildSmartResultMessage() {
    final mood = _answers[0] ?? '';
    final day = _answers[1] ?? '';
    final energy = _answers[2] ?? '';
    final physical = _answers[3] ?? '';
    final sleep = _answers[4] ?? '';
    final help = _answers[5] ?? '';

    if (help.contains('Yes') || help.contains('نعم')) {
      return tr(
        'Thank you for sharing. Since you selected that you need help today, it is a good idea to contact your companion or ask for support. You are not alone. 💙',
        'شكراً لمشاركتك. بما أنك اخترت أنك تحتاج إلى مساعدة اليوم، من الأفضل التواصل مع المرافق أو طلب الدعم. أنت لست وحدك. 💙',
      );
    }

    if (physical.contains('Not well') || physical.contains('لست بخير')) {
      return tr(
        'Your answers show that you may not be feeling well physically today. Try to rest, drink water, and tell your companion if the feeling continues. 🤒',
        'إجاباتك تشير إلى أنك قد لا تشعر بأنك بخير جسدياً اليوم. حاول أن ترتاح، اشرب الماء، وأخبر المرافق إذا استمر الشعور. 🤒',
      );
    }

    if (sleep.contains('Poor') || sleep.contains('ضعيف')) {
      return tr(
        'It looks like your sleep was not good last night. Try to take things slowly today, rest when you can, and avoid too much stress. 😴',
        'يبدو أن نومك لم يكن جيداً الليلة الماضية. حاول أن تأخذ يومك بهدوء، واسترح عندما تستطيع، وتجنب التوتر الزائد. 😴',
      );
    }

    if (energy.contains('Exhausted') ||
        energy.contains('Low') ||
        energy.contains('مرهق') ||
        energy.contains('منخفضة')) {
      return tr(
        'Your energy level seems low today. A short rest, light food, and drinking water may help you feel better. 🌿',
        'يبدو أن مستوى طاقتك منخفض اليوم. الراحة القصيرة، الطعام الخفيف، وشرب الماء قد يساعدونك على الشعور بشكل أفضل. 🌿',
      );
    }

    if (day.contains('Really Bad') ||
        mood.contains('Bad') ||
        day.contains('سيء')) {
      return tr(
        'It seems today was emotionally difficult. Take a deep breath, do something calming, and talk to someone you trust if you need comfort. 💙',
        'يبدو أن اليوم كان صعباً عاطفياً. خذ نفساً عميقاً، افعل شيئاً يهدئك، وتحدث مع شخص تثق به إذا احتجت للراحة. 💙',
      );
    }

    if (day.contains('Okay') ||
        physical.contains('Okay') ||
        sleep.contains('Okay') ||
        day.contains('عادي') ||
        physical.contains('عادي') ||
        sleep.contains('عادي')) {
      return tr(
        'Your answers show that your day is okay, but your body may still need some care. Try a light activity, drink water, and rest when needed. 🙂',
        'إجاباتك تبين أن يومك عادي، لكن جسمك قد يحتاج لبعض العناية. جرّب نشاطاً خفيفاً، اشرب الماء، واسترح عند الحاجة. 🙂',
      );
    }

    if (day.contains('Incredible') ||
        day.contains('Great') ||
        mood.contains('Very Happy') ||
        day.contains('رائع') ||
        day.contains('ممتاز')) {
      return tr(
        'Great job! Your answers show that you are feeling positive today. Keep taking care of yourself and continue your healthy routine. 🌟',
        'رائع! إجاباتك تبين أنك تشعر بإيجابية اليوم. استمر في الاهتمام بنفسك ومتابعة روتينك الصحي. 🌟',
      );
    }

    return tr(
      'Your answers look stable today. Keep monitoring your health, drink water, and take care of your body. 💙',
      'إجاباتك تبدو مستقرة اليوم. استمر في متابعة صحتك، اشرب الماء، واعتنِ بجسمك. 💙',
    );
  }

  void _nextQuestion() {
    final AIQuestion question = _questions[_currentIndex];

    if (question.type == AIQuestionType.sliderMood) {
      if (_moodValue == 1) {
        _answers[_currentIndex] = tr('Bad 😒', 'سيء 😒');
      } else if (_moodValue == 2) {
        _answers[_currentIndex] = tr('Good 🙂', 'جيد 🙂');
      } else {
        _answers[_currentIndex] = tr('Very Happy 😜', 'سعيد جداً 😜');
      }
    }

    if (question.type == AIQuestionType.options &&
        _answers[_currentIndex] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Please choose an answer', 'يرجى اختيار إجابة')),
        ),
      );
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

  Future<void> _saveAIReport(String resultMessage) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      await FirebaseFirestore.instance.collection('health_ai_reports').add({
        'userId': user.uid,
        'moodAnswer': _answers[0] ?? '',
        'dayAnswer': _answers[1] ?? '',
        'energyAnswer': _answers[2] ?? '',
        'physicalAnswer': _answers[3] ?? '',
        'sleepAnswer': _answers[4] ?? '',
        'helpAnswer': _answers[5] ?? '',
        'resultMessage': resultMessage,
        'createdAt': FieldValue.serverTimestamp(),
        'reportType': 'daily',
      });
    } catch (e) {
      debugPrint('Error saving AI report: $e');
    }
  }

  void _showResult() async {
    final resultMessage = _buildSmartResultMessage();

    await _saveAIReport(resultMessage);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: AlertDialog(
            backgroundColor: cardColor,
            title: Center(
              child: Text(
                tr('AI Result', 'نتيجة الذكاء الاصطناعي'),
                style: TextStyle(color: textColor),
              ),
            ),
            content: Text(
              resultMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: subTextColor,
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(tr('Done', 'تم')),
              ),
            ],
          ),
        );
      },
    );
  }

  void _needHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(
            'Help request sent to companion',
            'تم إرسال طلب المساعدة إلى المرافق',
          ),
        ),
      ),
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
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(40)),
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
                icon: Icon(
                  isArabic ? Icons.arrow_forward : Icons.arrow_back,
                  size: 28,
                  color: textColor,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    tr('AI Health Check', 'الفحص الصحي الذكي'),
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: textColor,
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

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: backgroundColor,
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
                        tr(
                          'Question ${_currentIndex + 1}/6',
                          'السؤال ${_currentIndex + 1}/6',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: subTextColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: isDarkMode
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFE2E7EC),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF87CEEB),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      const Spacer(),
                      Text(
                        question.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        question.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: subTextColor,
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
                              text: tr('Need help?', 'تحتاج مساعدة؟'),
                              onTap: _needHelp,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _blueButton(
                              text: _currentIndex == _questions.length - 1
                                  ? tr('Finish', 'إنهاء')
                                  : tr('Next Question', 'السؤال التالي'),
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
            inactiveTrackColor:
                isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFE2E7EC),
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
                color: selected ? const Color(0xFFD9F3FF) : cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF87CEEB)
                      : isDarkMode
                          ? Colors.white12
                          : const Color(0xFFE2E7EC),
                  width: 2,
                ),
              ),
              child: Text(
                option,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: selected ? const Color(0xFF5D6D7E) : subTextColor,
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
          minimumSize: const Size(0, 50),
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
