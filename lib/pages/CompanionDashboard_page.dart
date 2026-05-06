import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Profile_page.dart';
import 'Settings_page.dart';
import 'RemindersCompanion_page.dart';
import 'reminder_store.dart';

class CompanionDashboardPage extends StatefulWidget {
  const CompanionDashboardPage({super.key});

  @override
  State<CompanionDashboardPage> createState() => _CompanionDashboardPageState();
}

class _CompanionDashboardPageState extends State<CompanionDashboardPage> {
  final ReminderStore store = ReminderStore.instance;

  Timer? _timer;
  String _lastUpdated = '';

  String companionName = 'Companion';
  String patientName = 'Patient';

  String patientStatus = 'Stable';
  String mood = 'Calm 😊';
  String location = 'Manama';
  int heartRate = 78;
  int sleepHours = 7;

  String _selectedReport = 'Daily';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _loadNamesFromFirebase();

    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      setState(_updateTime);
    });
  }

  Future<void> _loadNamesFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) return;

      final data = doc.data();

      setState(() {
        companionName = data?['name'] ?? 'Companion';
        patientName = data?['patientName'] ?? 'Patient';
      });
    } catch (e) {
      debugPrint('Error loading companion/patient names: $e');
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    _lastUpdated =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _reminderStatusText(dynamic status) {
    final text = status.toString().toLowerCase();
    if (text.contains('done')) return 'Done';
    if (text.contains('missed')) return 'Missed';
    return 'Pending';
  }

  int _doneCount(List reminders) {
    return reminders
        .where((item) => _reminderStatusText(item.status) == 'Done')
        .length;
  }

  int _missedCount(List reminders) {
    return reminders
        .where((item) => _reminderStatusText(item.status) == 'Missed')
        .length;
  }

  double _careProgress(List reminders) {
    if (reminders.isEmpty) return 0;
    return _doneCount(reminders) / reminders.length;
  }

  Color _progressColor(double progress) {
    final percent = progress * 100;

    if (percent >= 80) return Colors.green;
    if (percent >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _statusColor(String status) {
    if (status == 'Stable') return Colors.green;
    if (status == 'Needs Attention') return Colors.orange;
    return Colors.red;
  }

  Color _reminderStatusColor(dynamic status) {
    final text = _reminderStatusText(status);
    if (text == 'Done') return Colors.green;
    if (text == 'Missed') return Colors.red;
    return Colors.orange;
  }

  List<Map<String, dynamic>> _generateAiInsights(List reminders) {
    final missed = _missedCount(reminders);
    final progress = _careProgress(reminders);

    if (missed >= 2) {
      return [
        {
          'icon': Icons.warning_amber_rounded,
          'color': Colors.red,
          'title': 'High Attention Needed',
          'message':
              '$patientName missed multiple reminders today. Please check in with the patient.',
        },
        {
          'icon': Icons.medication_liquid,
          'color': Colors.red,
          'title': 'Medication Follow-up',
          'message':
              'Medication compliance may be low today. Review missed medicines from reminders.',
        },
      ];
    }

    if (heartRate > 110) {
      return [
        {
          'icon': Icons.favorite,
          'color': Colors.red,
          'title': 'Health Risk Detected',
          'message':
              'Heart rate is higher than normal. Monitor $patientName closely.',
        },
      ];
    }

    if (sleepHours < 5) {
      return [
        {
          'icon': Icons.bedtime,
          'color': Colors.orange,
          'title': 'Low Sleep',
          'message':
              '$patientName may feel tired today because sleep hours are low.',
        },
      ];
    }

    if (mood.toLowerCase().contains('sad') ||
        mood.toLowerCase().contains('stressed') ||
        mood.toLowerCase().contains('angry')) {
      return [
        {
          'icon': Icons.psychology_alt,
          'color': Colors.orange,
          'title': 'Emotional Support',
          'message':
              '$patientName may need emotional support today. Consider sending a message.',
        },
      ];
    }

    if (progress < 0.5 && reminders.isNotEmpty) {
      return [
        {
          'icon': Icons.trending_down,
          'color': Colors.orange,
          'title': 'Low Daily Progress',
          'message':
              'Daily care progress is low. The patient may need extra support today.',
        },
      ];
    }

    return [
      {
        'icon': Icons.check_circle,
        'color': Colors.green,
        'title': 'Stable Condition',
        'message':
            '$patientName looks stable today. Continue monitoring reminders and health updates.',
      },
    ];
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

  Widget _buildTopHeader() {
    return Stack(
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

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _shadow(),
      ),
      child: child,
    );
  }

  Widget _healthItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF87CEEB), size: 30),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF8FD),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF2D9CDB), size: 30),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTab(String title) {
    final selected = _selectedReport == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedReport = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF87CEEB) : const Color(0xFFEAF8FD),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleBarChart(List<int> values, List<String> labels) {
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(values.length, (index) {
          final value = values[index];
          final double barHeight = value.toDouble().clamp(8.0, 100.0);

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$value%',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const SizedBox(height: 5),
              Container(
                width: 24,
                height: barHeight,
                decoration: BoxDecoration(
                  color: _progressColor(value / 100),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[index],
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDailyReport(List reminders) {
    final progress = _careProgress(reminders);
    final done = _doneCount(reminders);
    final missed = _missedCount(reminders);
    final pending = reminders.length - done - missed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today Summary',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text('Total Reminders: ${reminders.length}'),
        Text('Completed Reminders: $done'),
        Text('Pending Reminders: $pending'),
        Text('Missed Reminders: $missed'),
        Text('Daily Progress: ${(progress * 100).round()}%'),
        const SizedBox(height: 16),
        _buildSimpleBarChart(
          [
            reminders.isEmpty ? 0 : ((done / reminders.length) * 100).round(),
            reminders.isEmpty
                ? 0
                : ((pending / reminders.length) * 100).round(),
            reminders.isEmpty ? 0 : ((missed / reminders.length) * 100).round(),
          ],
          ['Done', 'Pend', 'Miss'],
        ),
      ],
    );
  }

  Widget _buildWeeklyReport(double progress) {
    final today = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Summary',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text('This chart shows care progress during the week.'),
        const SizedBox(height: 16),
        _buildSimpleBarChart(
          [70, 65, 80, 75, 90, 60, today],
          ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Today'],
        ),
      ],
    );
  }

  Widget _buildMonthlyReport(double progress) {
    final current = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Summary',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text('This chart shows monthly care progress overview.'),
        const SizedBox(height: 16),
        _buildSimpleBarChart([62, 74, 81, current], ['W1', 'W2', 'W3', 'Now']),
      ],
    );
  }

  Widget _buildReportContent(List reminders) {
    final progress = _careProgress(reminders);

    if (_selectedReport == 'Weekly') {
      return _buildWeeklyReport(progress);
    }

    if (_selectedReport == 'Monthly') {
      return _buildMonthlyReport(progress);
    }

    return _buildDailyReport(reminders);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final reminders = store.reminders;
        final missedReminders = reminders.where((item) {
          return _reminderStatusText(item.status) == 'Missed';
        }).toList();

        final progress = _careProgress(reminders);
        final progressPercent = (progress * 100).round();
        final progressColor = _progressColor(progress);
        final aiInsights = _generateAiInsights(reminders);

        return Scaffold(
          backgroundColor: const Color(0xFFF4F4F4),
          body: SafeArea(
            child: Column(
              children: [
                _buildTopHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${getGreeting()}, $companionName 👋',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Here is $patientName\'s latest update',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),

                        _card(
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 32,
                                backgroundColor: Color(0xFFEAF8FD),
                                child: Icon(
                                  Icons.person,
                                  size: 38,
                                  color: Color(0xFF2D9CDB),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      patientName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 12,
                                          color: _statusColor(patientStatus),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(patientStatus),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Last update: $_lastUpdated',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        _sectionTitle('Alerts'),

                        if (missedReminders.isEmpty)
                          _card(
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'No urgent alerts. Patient is doing well today.',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          _card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: missedReminders.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '${item.title} was missed at ${item.time}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        const SizedBox(height: 18),
                        _sectionTitle('Health Summary'),

                        _card(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _healthItem(
                                Icons.favorite,
                                'Heart Rate',
                                '$heartRate BPM',
                              ),
                              _healthItem(Icons.mood, 'Mood', mood),
                              _healthItem(
                                Icons.bedtime,
                                'Sleep',
                                '$sleepHours Hours',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        _sectionTitle('Daily Care Progress'),

                        _card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$progressPercent% completed today',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: progressColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                progressPercent >= 80
                                    ? 'Great progress. Patient is following the daily routine well.'
                                    : progressPercent >= 50
                                    ? 'Moderate progress. Patient may need some follow-up.'
                                    : 'Low progress. Patient needs attention today.',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: progress,
                                minHeight: 11,
                                borderRadius: BorderRadius.circular(20),
                                backgroundColor: Colors.grey.shade300,
                                color: progressColor,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        _sectionTitle('Today Reminders'),

                        if (reminders.isEmpty)
                          _card(
                            child: const Text(
                              'No reminders added yet.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          Column(
                            children: reminders.take(3).map((item) {
                              return _card(
                                child: Row(
                                  children: [
                                    Text(
                                      item.emoji,
                                      style: const TextStyle(fontSize: 30),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${item.day} - ${item.time}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _reminderStatusColor(
                                          item.status,
                                        ).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _reminderStatusText(item.status),
                                        style: TextStyle(
                                          color: _reminderStatusColor(
                                            item.status,
                                          ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const CompanionRemindersPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit_calendar),
                            label: const Text('Manage Reminders'),
                          ),
                        ),

                        const SizedBox(height: 18),
                        _sectionTitle('Location'),

                        _card(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '$patientName is currently near $location',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        _sectionTitle('AI Insights'),

                        Column(
                          children: aiInsights.map((insight) {
                            return _card(
                              child: Row(
                                children: [
                                  Icon(
                                    insight['icon'],
                                    color: insight['color'],
                                    size: 34,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          insight['title'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: insight['color'],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          insight['message'],
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 18),
                        _sectionTitle('Quick Actions'),

                        const SizedBox(height: 12),

                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.7,
                          children: [
                            _quickAction(
                              icon: Icons.phone,
                              title: 'Call Patient',
                              onTap: () {},
                            ),
                            _quickAction(
                              icon: Icons.message,
                              title: 'Message',
                              onTap: () {},
                            ),
                            _quickAction(
                              icon: Icons.warning_rounded,
                              title: 'Emergency',
                              onTap: () {},
                            ),
                            _quickAction(
                              icon: Icons.add_alert,
                              title: 'Add Reminder',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const CompanionRemindersPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        _sectionTitle('Daily Report'),

                        _card(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _buildReportTab('Daily'),
                                  const SizedBox(width: 8),
                                  _buildReportTab('Weekly'),
                                  const SizedBox(width: 8),
                                  _buildReportTab('Monthly'),
                                ],
                              ),
                              const SizedBox(height: 18),
                              _buildReportContent(reminders),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigation(),
        );
      },
    );
  }
}
