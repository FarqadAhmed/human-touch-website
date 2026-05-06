import 'package:flutter/material.dart';
import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';
import 'reminder_store.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final ReminderStore store = ReminderStore.instance;

  Color _statusColor(String status) {
    if (status == 'done') return const Color(0xFFDFF5E1);
    if (status == 'missed') return const Color(0xFFFDE2E2);
    return const Color(0xFFF4F4F4);
  }

  String _statusText(String status) {
    if (status == 'done') return 'Done';
    if (status == 'missed') return 'Not Done';
    return 'Pending';
  }

  void _updateStatus(ReminderItem item, String status) {
    store.updateReminderStatus(item.id, status);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 'done'
              ? '${item.title} marked as done'
              : '${item.title} marked as not done',
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

  Widget _buildTopCard() {
    return Container(
      width: double.infinity,
      height: 135,
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Reminders',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'You can only view reminders and mark them as done or not done.',
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(ReminderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _statusColor(item.status),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${item.day} - ${item.time}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(_statusText(item.status)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _updateStatus(item, 'done'),
                child: const Text('✅'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _updateStatus(item, 'missed'),
                child: const Text('❌'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<ReminderItem> items) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const Text(
              'No reminders here',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            )
          else
            ...items.map(_buildReminderCard),
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final medicines = store.remindersByCategory(ReminderCategory.medicine);
        final meals = store.remindersByCategory(ReminderCategory.meal);
        final appointments = store.remindersByCategory(
          ReminderCategory.appointment,
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF4F4F4),

          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: [
                        _buildTopCard(),
                        _buildSection('Medicines', medicines),
                        _buildSection('Meals', meals),
                        _buildSection('Appointments', appointments),
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
