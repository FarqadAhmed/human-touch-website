import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui' as ui;

import 'Reminders_page.dart';
import 'Health_page.dart';
import 'Communication_page.dart';
import 'Emergency_page.dart';
import 'Map_page.dart';
import 'VolunteerHelp_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';

import 'package:humantouch/pages/app_settings_store.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _userName = 'User';

  bool get isArabic => AppSettingsStore.instance.isArabic;
  bool get isDarkMode => AppSettingsStore.instance.isDarkMode;

  Color get backgroundColor =>
      isDarkMode ? Colors.black : const Color(0xFFF4F4F4);

  Color get cardColor => isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

  Color get textColor => isDarkMode ? Colors.white : Colors.black;

  Color get subTextColor => isDarkMode ? Colors.white70 : Colors.black54;

  Color get innerBoxColor =>
      isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF4F4F4);

  String tr(String en, String ar) {
    return isArabic ? ar : en;
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();

    AppSettingsStore.instance.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    AppSettingsStore.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      setState(() {
        _userName = doc.data()?['name'] ?? 'User';
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return tr('Good Morning', 'صباح الخير');
    } else {
      return tr('Good Evening', 'مساء الخير');
    }
  }

  String _getTodayName() {
    return DateFormat('EEEE', 'en').format(DateTime.now());
  }

  ButtonStyle _iconTapStyle() {
    return ButtonStyle(
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.grey.withOpacity(0.20);
        }
        return null;
      }),
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      minimumSize: WidgetStateProperty.all(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _goToPage(int index) {
    if (index == 0) return;

    if (index == 1) {
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

  Widget _buildTopReminderCard() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: _shadow(),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            tr(
              'Please login to see reminders',
              'يرجى تسجيل الدخول لعرض التذكيرات',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
        ),
      );
    }

    final today = _getTodayName();

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: _shadow(),
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.all(18),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('reminders')
            .where('userId', isEqualTo: user.uid)
            .where('day', isEqualTo: today)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                tr('Error loading reminders', 'حدث خطأ في تحميل التذكيرات'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: subTextColor,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF87CEEB)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                tr('No reminders for today', 'لا توجد تذكيرات لهذا اليوم'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: subTextColor,
                ),
              ),
            );
          }

          final reminders = snapshot.data!.docs;

          return Column(
            crossAxisAlignment:
                isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                tr('Today’s Reminders', 'تذكيرات اليوم'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: reminders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final data = reminders[index].data();

                    final String emoji = data['emoji'] ?? '🔔';
                    final String title =
                        data['title'] ?? tr('Reminder', 'تذكير');
                    final String time = data['time'] ?? '';

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: innerBoxColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$emoji $title • $time',
                              textAlign:
                                  isArabic ? TextAlign.right : TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeatureItem({
    required BuildContext context,
    required String label,
    required String imagePath,
    required Widget page,
    double imageWidth = 70,
    double imageHeight = 70,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 90,
          child: TextButton(
            style: _iconTapStyle(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isDarkMode ? _shadow() : null,
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 95,
          child: TextButton(
            style: _iconTapStyle(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            },
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ],
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
        color: isDarkMode
            ? Colors.black.withOpacity(0.35)
            : Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: backgroundColor,
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
                        height: 41,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(70),
                            topRight: Radius.circular(70),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 15),
                  child: Align(
                    alignment:
                        isArabic ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      '${_getGreeting()}, $_userName',
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: _buildTopReminderCard(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 35, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureItem(
                        context: context,
                        label: tr('Reminders', 'التذكيرات'),
                        imagePath: 'assets/Reminder.png',
                        page: const RemindersPage(),
                      ),
                      _buildFeatureItem(
                        context: context,
                        label: tr('Health', 'الصحة'),
                        imagePath: 'assets/Health.png',
                        page: const HealthPage(),
                        imageHeight: 60,
                      ),
                      _buildFeatureItem(
                        context: context,
                        label: tr('Communication', 'التواصل'),
                        imagePath: 'assets/communication.png',
                        page: const CommunicationPage(),
                        imageWidth: 100,
                        imageHeight: 100,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureItem(
                        context: context,
                        label: tr('Emergency', 'الطوارئ'),
                        imagePath: 'assets/Emergency.png',
                        page: const EmergencyPage(),
                      ),
                      _buildFeatureItem(
                        context: context,
                        label: tr('Map', 'الخريطة'),
                        imagePath: 'assets/map.png',
                        page: const MapPage(),
                      ),
                      _buildFeatureItem(
                        context: context,
                        label: tr('Volunteer\nHelp', 'مساعدة\nالمتطوعين'),
                        imagePath: 'assets/volunteer.png',
                        page: const VolunteerHelpPage(),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
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
                _bottomItem(Icons.home_rounded, tr('Home', 'الرئيسية'), 0),
                _bottomItem(Icons.person_rounded, tr('Profile', 'الملف'), 1),
                _bottomItem(
                  Icons.settings_rounded,
                  tr('Settings', 'الإعدادات'),
                  2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
