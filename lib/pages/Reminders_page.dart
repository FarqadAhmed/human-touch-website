import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_tts.dart';
import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  String _selectedDay = 'Wednesday';

  final List<String> _days = const [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

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

  List<BoxShadow> _shadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ];
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
                    'Reminders',
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

  String _categoryText(String category) {
    switch (category.toLowerCase()) {
      case 'medicine':
        return 'Medicine';
      case 'meal':
        return 'Meal';
      case 'appointment':
        return 'Appointment';
      case 'others':
        return 'Others';
      default:
        return 'Others';
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'medicine':
        return Icons.medication_outlined;
      case 'meal':
        return Icons.restaurant_outlined;
      case 'appointment':
        return Icons.calendar_month_outlined;
      case 'others':
        return Icons.more_horiz_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  Widget _buildDayTab(String day) {
    final bool isSelected = _selectedDay == day;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDay = day;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 50,
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF69B7E8) : const Color(0xFFE9E9E9),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(
            child: Text(
              day,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF333333),
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _changeReminderStatus(String docId, String status) async {
    await FirebaseFirestore.instance.collection('reminders').doc(docId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Widget _statusChip(String status) {
    Color color;
    String text;

    if (status == 'accepted') {
      color = Colors.green;
      text = 'Accepted';
    } else if (status == 'none') {
      color = Colors.orange;
      text = 'None';
    } else {
      color = Colors.grey;
      text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _smallButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 38,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard({
    required String docId,
    required Map<String, dynamic> data,
  }) {
    final String title = data['title'] ?? 'Reminder';
    final String time = data['time'] ?? '';
    final String emoji = data['emoji'] ?? '🔔';
    final String category = data['category'] ?? 'others';
    final String status = data['status'] ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: const Color(0xFFEAF7FD),
                child: Text(emoji, style: const TextStyle(fontSize: 25)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          _categoryIcon(category),
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${_categoryText(category)} • $time',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _statusChip(status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _smallButton(
                text: 'Accept',
                color: const Color(0xFF69B7E8),
                onTap: () => _changeReminderStatus(docId, 'accepted'),
              ),
              const SizedBox(width: 10),
              _smallButton(
                text: 'None',
                color: Colors.orange,
                onTap: () => _changeReminderStatus(docId, 'none'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _remindersStream() {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: user?.uid ?? '')
        .where('day', isEqualTo: _selectedDay)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                color: const Color(0xFFF4F4F4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: _days.map(_buildDayTab).toList()),
                    const SizedBox(height: 24),
                    Expanded(
                      child: user == null
                          ? const Center(
                              child: Text(
                                'Please login to see reminders',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: _remindersStream(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Center(
                                    child: Text(
                                      'Error loading reminders',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF87CEEB),
                                    ),
                                  );
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'No reminders for this day',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                }

                                final reminders = snapshot.data!.docs;

                                return ListView.builder(
                                  itemCount: reminders.length,
                                  itemBuilder: (context, index) {
                                    final doc = reminders[index];

                                    return _buildReminderCard(
                                      docId: doc.id,
                                      data: doc.data(),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}
