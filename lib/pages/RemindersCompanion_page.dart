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
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _otherReminderController =
      TextEditingController();

  ReminderCategory _selectedCategory = ReminderCategory.medicine;
  ReminderItem? _editingReminder;

  late String _selectedDay;

  bool _notification = true;
  bool _sound = true;

  DateTime _selectedTime = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  String _selectedEmoji = '💊';

  final List<String> _emojiList = const [
    '💊',
    '🍽️',
    '📅',
    '❤️',
    '😊',
    '😴',
    '🏃‍♀️',
    '🧘‍♀️',
    '🚰',
    '🩺',
    '🌞',
    '⭐',
    '✅',
    '⏰',
    '📝',
    '🧠',
    '🍎',
    '🚶‍♀️',
  ];

  final List<String> _weekDays = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> _shortWeekDays = const [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  final List<String> _months = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _formatDate(_selectedDate);
    _dateController.text = _selectedDay;
    _emojiController.text = _selectedEmoji;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _emojiController.dispose();
    _dateController.dispose();
    _otherReminderController.dispose();
    super.dispose();
  }

  List<DateTime> _currentWeekDates() {
    final DateTime monday = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );

    return List.generate(7, (index) {
      return DateTime(monday.year, monday.month, monday.day + index);
    });
  }

  String _formatDate(DateTime date) {
    final String dayName = _weekDays[date.weekday - 1];
    final String monthName = _months[date.month - 1];
    final String dayNumber = date.day.toString().padLeft(2, '0');

    return '$dayName, $dayNumber $monthName ${date.year}';
  }

  void _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF69B7E8),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedDay = _formatDate(pickedDate);
        _dateController.text = _selectedDay;
      });
    }
  }

  void _pickTime() async {
    final TimeOfDay initialTime = TimeOfDay(
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
    );

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF69B7E8),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Colors.black,
              dayPeriodTextColor: Colors.black,
              dialHandColor: Color(0xFF69B7E8),
              dialBackgroundColor: Color(0xFFF4F4F4),
              entryModeIconColor: Color(0xFF69B7E8),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final now = DateTime.now();

      setState(() {
        _selectedTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        _timeController.text = MaterialLocalizations.of(
          context,
        ).formatTimeOfDay(pickedTime, alwaysUse24HourFormat: false);
      });
    }
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
      case ReminderCategory.others:
        return 'Others';
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
      case ReminderCategory.others:
        return Icons.more_horiz_rounded;
    }
  }

  void _clearForm() {
    setState(() {
      _editingReminder = null;
      _titleController.clear();
      _timeController.clear();
      _otherReminderController.clear();

      _selectedEmoji = '💊';
      _emojiController.text = _selectedEmoji;

      _selectedCategory = ReminderCategory.medicine;
      _selectedDate = DateTime.now();
      _selectedDay = _formatDate(_selectedDate);
      _dateController.text = _selectedDay;

      _notification = true;
      _sound = true;
      _selectedTime = DateTime.now();
    });
  }

  void _fillFormForEdit(ReminderItem item) {
    setState(() {
      _editingReminder = item;
      _titleController.text = item.title;
      _timeController.text = item.time;

      if (item.category == ReminderCategory.others) {
        _otherReminderController.text = item.title;
      } else {
        _otherReminderController.clear();
      }

      _selectedEmoji = item.emoji;
      _emojiController.text = item.emoji;

      _selectedCategory = item.category;
      _selectedDay = item.day;
      _dateController.text = item.day;
      _notification = item.notification;
      _sound = item.sound;
    });

    _showReminderForm();
  }

  void _saveReminder() {
    if (!_formKey.currentState!.validate()) return;

    final String reminderTitle = _selectedCategory == ReminderCategory.others
        ? _otherReminderController.text.trim()
        : _titleController.text.trim();

    if (_editingReminder == null) {
      final item = ReminderItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: reminderTitle,
        time: _timeController.text.trim(),
        day: _dateController.text.trim(),
        emoji: _selectedEmoji,
        category: _selectedCategory,
        notification: _notification,
        sound: _sound,
      );

      store.addReminder(item);
    } else {
      final updatedItem = ReminderItem(
        id: _editingReminder!.id,
        title: reminderTitle,
        time: _timeController.text.trim(),
        day: _dateController.text.trim(),
        emoji: _selectedEmoji,
        category: _selectedCategory,
        notification: _notification,
        sound: _sound,
        status: _editingReminder!.status,
      );

      store.updateReminder(updatedItem);
    }

    setState(() {
      _selectedDay = _dateController.text.trim();
    });

    Navigator.pop(context);
    _clearForm();
    setState(() {});
  }

  void _deleteReminder(ReminderItem item) {
    store.deleteReminder(item.id);
    setState(() {});
  }

  void _showEmojiPicker(StateSetter modalSetState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          height: 310,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Emoji',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: _emojiList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final emoji = _emojiList[index];

                    return GestureDetector(
                      onTap: () {
                        modalSetState(() {
                          _selectedEmoji = emoji;
                          _emojiController.text = emoji;
                        });
                        setState(() {
                          _selectedEmoji = emoji;
                          _emojiController.text = emoji;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedEmoji == emoji
                              ? const Color(0xFFEAF7FD)
                              : const Color(0xFFF4F4F4),
                          border: Border.all(
                            color: _selectedEmoji == emoji
                                ? const Color(0xFF69B7E8)
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
                      _buildTimeInput(),
                      const SizedBox(height: 12),
                      _buildEmojiInput(modalSetState),
                      const SizedBox(height: 12),
                      _buildDateInput(),
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
                            if (_selectedCategory != ReminderCategory.others) {
                              _otherReminderController.clear();
                            }
                          });

                          setState(() {
                            _selectedCategory = value!;
                            if (_selectedCategory != ReminderCategory.others) {
                              _otherReminderController.clear();
                            }
                          });
                        },
                      ),
                      if (_selectedCategory == ReminderCategory.others) ...[
                        const SizedBox(height: 12),
                        _buildInput(
                          label: 'Write your reminder',
                          controller: _otherReminderController,
                          icon: Icons.edit_note_rounded,
                        ),
                      ],
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

  Widget _buildEmojiInput(StateSetter modalSetState) {
    return TextFormField(
      controller: _emojiController,
      readOnly: true,
      onTap: () => _showEmojiPicker(modalSetState),
      decoration:
          _inputDecoration(
            label: 'Emoji',
            icon: Icons.emoji_emotions_outlined,
          ).copyWith(
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF69B7E8),
            ),
          ),
      validator: (value) {
        if ((value ?? '').trim().isEmpty) {
          return 'Please select emoji';
        }
        return null;
      },
    );
  }

  Widget _buildTimeInput() {
    return TextFormField(
      controller: _timeController,
      readOnly: true,
      onTap: _pickTime,
      decoration: _inputDecoration(label: 'Time', icon: Icons.access_time)
          .copyWith(
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF69B7E8),
            ),
          ),
      validator: (value) {
        if ((value ?? '').trim().isEmpty) {
          return 'Please select time';
        }
        return null;
      },
    );
  }

  Widget _buildDateInput() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: _pickDate,
      decoration:
          _inputDecoration(
            label: 'Day / Date',
            icon: Icons.calendar_month_outlined,
          ).copyWith(
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF69B7E8),
            ),
          ),
      validator: (value) {
        if ((value ?? '').trim().isEmpty) {
          return 'Please select day';
        }
        return null;
      },
    );
  }

  Widget _buildWeekDayTab(DateTime date) {
    final bool isSelected = _formatDate(date) == _selectedDay;

    final int reminderCount = store.reminders.where((item) {
      return item.day == _formatDate(date);
    }).length;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDate = date;
            _selectedDay = _formatDate(date);
            _dateController.text = _selectedDay;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF69B7E8)
                : const Color(0xFFE9E9E9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                _shortWeekDays[date.weekday - 1],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              CircleAvatar(
                radius: 9,
                backgroundColor: isSelected ? Colors.white : Colors.transparent,
                child: Text(
                  '$reminderCount',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? const Color(0xFF69B7E8)
                        : const Color(0xFF777777),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekSelector() {
    final weekDates = _currentWeekDates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Week',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: weekDates.map(_buildWeekDayTab).toList()),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: _shadow(),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFF69B7E8),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedDay,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF69B7E8),
                ),
              ],
            ),
          ),
        ),
      ],
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
                    Expanded(
                      child: Text(
                        '${_categoryText(item.category)} • ${item.time}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.day,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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
          return item.day == _selectedDay;
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
                        _buildWeekSelector(),
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
