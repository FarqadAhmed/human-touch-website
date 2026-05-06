import 'package:flutter/material.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';
import 'CompanionDashboard_page.dart';
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
  final TextEditingController _emojiController = TextEditingController();

  ReminderCategory _selectedCategory = ReminderCategory.medicine;
  ReminderItem? _editingReminder;

  String _selectedDay = 'Wednesday';

  bool _notification = true;
  bool _sound = true;

  final List<String> _days = const [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CompanionDashboardPage()),
      );
    }
  }

  void _goToPage(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CompanionDashboardPage()),
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

  IconData _categoryIcon(ReminderCategory category) {
    switch (category) {
      case ReminderCategory.medicine:
        return Icons.medication_outlined;
      case ReminderCategory.meal:
        return Icons.restaurant_outlined;
      case ReminderCategory.appointment:
        return Icons.calendar_month_outlined;
    }
  }

  void _clearForm() {
    setState(() {
      _editingReminder = null;
      _titleController.clear();
      _timeController.clear();
      _emojiController.clear();
      _selectedCategory = ReminderCategory.medicine;
      _selectedDay = 'Wednesday';
      _notification = true;
      _sound = true;
    });
  }

  void _fillFormForEdit(ReminderItem item) {
    setState(() {
      _editingReminder = item;
      _titleController.text = item.title;
      _timeController.text = item.time;
      _emojiController.text = item.emoji;
      _selectedCategory = item.category;
      _selectedDay = item.day;
      _notification = item.notification;
      _sound = item.sound;
    });

    _showReminderForm();
  }

  void _saveReminder() {
    if (!_formKey.currentState!.validate()) return;

    if (_editingReminder == null) {
      final item = ReminderItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        time: _timeController.text.trim(),
        day: _selectedDay,
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
        day: _selectedDay,
        emoji: _emojiController.text.trim(),
        category: _selectedCategory,
        notification: _notification,
        sound: _sound,
        status: _editingReminder!.status,
      );

      store.updateReminder(updatedItem);
    }

    Navigator.pop(context);
    _clearForm();
    setState(() {});
  }

  void _deleteReminder(ReminderItem item) {
    store.deleteReminder(item.id);
    setState(() {});
  }

  void _showReminderForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 22,
                bottom: MediaQuery.of(context).viewInsets.bottom + 22,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _editingReminder == null
                            ? 'Add Reminder'
                            : 'Edit Reminder',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildInput(
                        label: 'Reminder Title',
                        controller: _titleController,
                        icon: Icons.title,
                      ),
                      const SizedBox(height: 12),
                      _buildInput(
                        label: 'Time',
                        controller: _timeController,
                        icon: Icons.access_time,
                      ),
                      const SizedBox(height: 12),
                      _buildInput(
                        label: 'Emoji',
                        controller: _emojiController,
                        icon: Icons.emoji_emotions_outlined,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedDay,
                        decoration: _inputDecoration(
                          label: 'Day',
                          icon: Icons.calendar_today_outlined,
                        ),
                        items: _days.map((day) {
                          return DropdownMenuItem(value: day, child: Text(day));
                        }).toList(),
                        onChanged: (value) {
                          modalSetState(() {
                            _selectedDay = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<ReminderCategory>(
                        value: _selectedCategory,
                        decoration: _inputDecoration(
                          label: 'Category',
                          icon: Icons.category_outlined,
                        ),
                        items: ReminderCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_categoryText(category)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          modalSetState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        value: _notification,
                        activeColor: const Color(0xFF69B7E8),
                        title: const Text('Notification'),
                        onChanged: (value) {
                          modalSetState(() {
                            _notification = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        value: _sound,
                        activeColor: const Color(0xFF69B7E8),
                        title: const Text('Sound'),
                        onChanged: (value) {
                          modalSetState(() {
                            _sound = value;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _saveReminder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF69B7E8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            _editingReminder == null ? 'Add' : 'Update',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF69B7E8)),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label: label, icon: icon),
      validator: (value) {
        if ((value ?? '').trim().isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
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
            color: isSelected
                ? const Color(0xFF69B7E8)
                : const Color(0xFFE9E9E9),
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

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 55,
      height: 55,
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF69B7E8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildReminderCard(ReminderItem item) {
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: const Color(0xFFEAF7FD),
            child: Text(item.emoji, style: const TextStyle(fontSize: 25)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
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
                      _categoryIcon(item.category),
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${_categoryText(item.category)} • ${item.time}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _fillFormForEdit(item),
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF69B7E8)),
          ),
          IconButton(
            onPressed: () => _deleteReminder(item),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final selectedReminders = store.reminders.where((item) {
          return item.day.toLowerCase() == _selectedDay.toLowerCase();
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF4F4F4),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(
                        icon: Icons.add,
                        onTap: () {
                          _clearForm();
                          _showReminderForm();
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.edit_note,
                        onTap: () {
                          if (selectedReminders.isNotEmpty) {
                            _fillFormForEdit(selectedReminders.first);
                          }
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        onTap: () {
                          if (selectedReminders.isNotEmpty) {
                            _deleteReminder(selectedReminders.first);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                    color: const Color(0xFFF4F4F4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: _days.map(_buildDayTab).toList()),
                        const SizedBox(height: 24),
                        Expanded(
                          child: selectedReminders.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No reminders for this day',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: selectedReminders.length,
                                  itemBuilder: (context, index) {
                                    return _buildReminderCard(
                                      selectedReminders[index],
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
      },
    );
  }
}
