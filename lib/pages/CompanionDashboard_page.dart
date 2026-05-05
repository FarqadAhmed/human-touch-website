import 'package:flutter/material.dart';

import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';

class CompanionDashboardPage extends StatefulWidget {
  const CompanionDashboardPage({super.key});

  @override
  State<CompanionDashboardPage> createState() => _CompanionDashboardPageState();
}

class _CompanionDashboardPageState extends State<CompanionDashboardPage> {
  final String patientName = 'Abdulla';
  final String lastUpdate = '10:45 AM';

  final bool patientActiveToday = false;
  final bool medicineTaken = false;
  final bool mealRecorded = false;
  final bool activityDone = false;
  final bool emergencyPressed = false;

  final List<Map<String, dynamic>> liveUpdates = [
    {
      'title': 'Mood Updated',
      'subtitle': 'Patient mood: Calm',
      'time': '10:30 AM',
      'icon': Icons.mood_rounded,
      'color': Color(0xFF87CEEB),
    },
    {
      'title': 'Location Updated',
      'subtitle': 'Patient is at Home',
      'time': '10:10 AM',
      'icon': Icons.location_on_rounded,
      'color': Color(0xFF81C784),
    },
    {
      'title': 'No Medicine Taken',
      'subtitle': 'Morning medicine is still pending',
      'time': '09:00 AM',
      'icon': Icons.medication_rounded,
      'color': Color(0xFFFFB74D),
    },
  ];

  int _selectedIndex = 0;

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

  void _onBottomTap(int index) {
    if (index == _selectedIndex) return;

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

  String get patientStatus {
    if (emergencyPressed) return 'Emergency';
    if (!patientActiveToday) return 'Inactive';
    return 'Active';
  }

  Color get patientStatusColor {
    if (emergencyPressed) return const Color(0xFFE57373);
    if (!patientActiveToday) return const Color(0xFFFFB74D);
    return const Color(0xFF81C784);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _patientStatusCard(),
                  const SizedBox(height: 18),

                  if (!patientActiveToday) _warningCard(),

                  const SizedBox(height: 18),
                  _sectionTitle('Live Updates'),
                  const SizedBox(height: 12),

                  ...liveUpdates.map((update) {
                    return _updateCard(
                      title: update['title'],
                      subtitle: update['subtitle'],
                      time: update['time'],
                      icon: update['icon'],
                      color: update['color'],
                    );
                  }),

                  const SizedBox(height: 18),
                  _sectionTitle('Health Summary'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _summarySmallCard(
                          icon: Icons.favorite_rounded,
                          title: 'Heart Rate',
                          value: '82 bpm',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summarySmallCard(
                          icon: Icons.directions_walk_rounded,
                          title: 'Steps',
                          value: '350',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _summarySmallCard(
                          icon: Icons.water_drop_rounded,
                          title: 'Water',
                          value: '2 Cups',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summarySmallCard(
                          icon: Icons.bedtime_rounded,
                          title: 'Rest',
                          value: '3 Hours',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  _sectionTitle('End of Day Report'),
                  const SizedBox(height: 12),

                  _dailyReportCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomTap,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF87CEEB),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 165,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF87CEEB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(70),
          bottomRight: Radius.circular(70),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: _goBack,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Companion Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Center(
              child: Text(
                'Patient live status and daily report',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _patientStatusCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF8FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF4BAFD8),
              size: 36,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Last update: $lastUpdate',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: patientStatusColor.withOpacity(0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              patientStatus,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: patientStatusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _warningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9800), size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Warning: The patient has not done any activity today. Please check on them.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7A5200),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _updateCard({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 27),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _summarySmallCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF4BAFD8), size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 3),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _dailyReportCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.assignment_rounded,
                color: Color(0xFF4BAFD8),
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                'Today Report',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _reportRow('Medicine Taken', medicineTaken ? 'Yes' : 'No'),
          _reportRow('Meal Recorded', mealRecorded ? 'Yes' : 'No'),
          _reportRow('Activity Completed', activityDone ? 'Yes' : 'No'),
          _reportRow('Emergency Alert', emergencyPressed ? 'Yes' : 'No'),
          const Divider(height: 25),
          Text(
            patientActiveToday
                ? 'Patient completed some activities today.'
                : 'Patient was inactive today. A warning alert should be sent to the companion.',
            style: TextStyle(
              fontSize: 14,
              color: patientActiveToday
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFC62828),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportRow(String title, String value) {
    final bool isNo = value == 'No';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isNo ? const Color(0xFFE57373) : const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D2D2D),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
