import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Reminders_page.dart';
import 'Health_page.dart';
import 'Communication_page.dart';
import 'Emergency_page.dart';
import 'Map_page.dart';
import 'VolunteerHelp_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';
import 'reminder_store.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        _userName = doc['name'] ?? 'User';
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else {
      return 'Good Evening';
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

  Widget _buildTopReminderCard(ReminderStore store) {
    final reminders = store.todayReminders(_getTodayName());

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x9257636C),
            offset: Offset(0, 0),
            spreadRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.all(18),
      child: reminders.isEmpty
          ? const Center(
              child: Text(
                'No reminders for today',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today’s Reminders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: reminders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final reminder = reminders[index];

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              reminder.emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${reminder.day} - ${reminder.title} (${reminder.time})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ReminderStore store = ReminderStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
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
                          height: 41,
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
                    padding: const EdgeInsets.fromLTRB(30, 10, 30, 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${_getGreeting()}, $_userName',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                    child: _buildTopReminderCard(store),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 35, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeatureItem(
                          context: context,
                          label: 'Reminders',
                          imagePath: 'assets/Reminder.png',
                          page: const RemindersPage(),
                        ),
                        _buildFeatureItem(
                          context: context,
                          label: 'Health',
                          imagePath: 'assets/Health.png',
                          page: const HealthPage(),
                          imageHeight: 60,
                        ),
                        _buildFeatureItem(
                          context: context,
                          label: 'Communication',
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
                          label: 'Emergency',
                          imagePath: 'assets/Emergency.png',
                          page: const EmergencyPage(),
                        ),
                        _buildFeatureItem(
                          context: context,
                          label: 'Map',
                          imagePath: 'assets/map.png',
                          page: const MapPage(),
                        ),
                        _buildFeatureItem(
                          context: context,
                          label: 'Volunteer\nHelp',
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
                  _bottomItem(Icons.home_rounded, 'Home', 0),
                  _bottomItem(Icons.person_rounded, 'Profile', 1),
                  _bottomItem(Icons.settings_rounded, 'Settings', 2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
