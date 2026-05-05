import 'package:flutter/material.dart';
import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';
import 'reminder_store.dart';

class CompanionRemindersPage extends StatefulWidget {
  const CompanionRemindersPage({super.key});

  @override
  State<CompanionRemindersPage> createState() => _CompanionRemindersPageState();
}

class _CompanionRemindersPageState extends State<CompanionRemindersPage> {
  final ReminderStore store = ReminderStore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _emojiController = TextEditingController();

  ReminderCategory _selectedCategory = ReminderCategory.medicine;
  bool _notification = true;
  bool _sound = true;

  ReminderItem? _editingReminder;

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _dayController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  String _categoryText(ReminderCategory category) {
    switch (category) {
      case ReminderCategory.medicine:
        return 'Medicine';
      case ReminderCategory.meal:
        return 'Meal';
      case ReminderCategory.appointment:
        return 'Appointment';
    }
  }

  void _fillFormForEdit(ReminderItem item) {
    setState(() {
      _editingReminder = item;
      _titleController.text = item.title;
      _timeController.text = item.time;
      _dayController.text = item.day;
      _emojiController.text = item.emoji;
      _selectedCategory = item.category;
      _notification = item.notification;
      _sound = item.sound;
    });
  }

  void _clearForm() {
    setState(() {
      _editingReminder = null;
      _titleController.clear();
      _timeController.clear();
      _dayController.clear();
      _emojiController.clear();
      _selectedCategory = ReminderCategory.medicine;
      _notification = true;
      _sound = true;
    });
  }

  void _saveReminder() {
    if (!_formKey.currentState!.validate()) return;

    if (_editingReminder == null) {
      final item = ReminderItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        time: _timeController.text.trim(),
        day: _dayController.text.trim(),
        emoji: _emojiController.text.trim(),
        category: _selectedCategory,
        notification: _notification,
        sound: _sound,
      );
      store.addReminder(item);
    } else {
      final updatedItem = ReminderItem(
        id: _editingReminder!.id,
        title: _titleController.text.trim(),
        time: _timeController.text.trim(),
        day: _dayController.text.trim(),
        emoji: _emojiController.text.trim(),
        category: _selectedCategory,
        notification: _notification,
        sound: _sound,
        status: _editingReminder!.status,
      );
      store.updateReminder(updatedItem);
    }

    _clearForm();
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if ((value ?? '').trim().isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }

  Widget _buildReminderTile(ReminderItem item) {
    return ListTile(
      leading: Text(item.emoji),
      title: Text(item.title),
      subtitle: Text('${item.day} - ${item.time}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _fillFormForEdit(item),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => store.deleteReminder(item.id),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  Widget _bottomIcon({required IconData icon, required Widget page}) {
    return IconButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      icon: Icon(icon, size: 38, color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F4F4),
          appBar: AppBar(
            backgroundColor: const Color(0xFF87CEEB),
            title: const Text('Companion Reminders'),
            leading: IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardPage(),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.arrow_back, size: 28),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInput(label: 'Title', controller: _titleController),
                      _buildInput(label: 'Time', controller: _timeController),
                      _buildInput(label: 'Day', controller: _dayController),
                      _buildInput(label: 'Emoji', controller: _emojiController),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _saveReminder,
                        child: Text(
                          _editingReminder == null ? 'Add' : 'Update',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ...store.reminders.map(_buildReminderTile),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            height: 65,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _bottomIcon(
                  icon: Icons.home_outlined,
                  page: const DashboardPage(),
                ),
                _bottomIcon(
                  icon: Icons.person_outline,
                  page: const ProfilePage(),
                ),
                _bottomIcon(
                  icon: Icons.settings_outlined,
                  page: const SettingsPage(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
