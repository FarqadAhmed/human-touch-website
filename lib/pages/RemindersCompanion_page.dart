import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Profile_page.dart';
import 'Settings_page.dart';
import 'CompanionDashboard_page.dart';

class CompanionRemindersPage extends StatefulWidget {
  const CompanionRemindersPage({super.key});

  @override
  State<CompanionRemindersPage> createState() => _CompanionRemindersPageState();
}

class _CompanionRemindersPageState extends State<CompanionRemindersPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _emojiController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _otherReminderController =
      TextEditingController();

  String _selectedCategory = 'medicine';
  String? _editingReminderId;

  late String _selectedDateText;

  bool _notification = true;
  bool _sound = true;
  bool _isSaving = false;

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

  final List<String> _categories = const [
    'medicine',
    'meal',
    'appointment',
    'others',
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
    _selectedDateText = _formatDate(_selectedDate);
    _dateController.text = _selectedDateText;
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

  String _dayName(DateTime date) {
    return _weekDays[date.weekday - 1];
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

  Stream<QuerySnapshot<Map<String, dynamic>>> _remindersStream() {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: user?.uid ?? '')
        .snapshots();
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
        _selectedDateText = _formatDate(pickedDate);
        _dateController.text = _selectedDateText;
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

  String _categoryText(String category) {
    switch (category) {
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
    switch (category) {
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

  void _clearForm() {
    setState(() {
      _editingReminderId = null;
      _titleController.clear();
      _timeController.clear();
      _otherReminderController.clear();

      _selectedEmoji = '💊';
      _emojiController.text = _selectedEmoji;

      _selectedCategory = 'medicine';
      _selectedDate = DateTime.now();
      _selectedDateText = _formatDate(_selectedDate);
      _dateController.text = _selectedDateText;

      _notification = true;
      _sound = true;
      _selectedTime = DateTime.now();
    });
  }

  void _fillFormForEdit(String docId, Map<String, dynamic> data) {
    setState(() {
      _editingReminderId = docId;

      _selectedCategory = data['category'] ?? 'medicine';

      _titleController.text = data['title'] ?? '';
      _timeController.text = data['time'] ?? '';

      if (_selectedCategory == 'others') {
        _otherReminderController.text = data['title'] ?? '';
      } else {
        _otherReminderController.clear();
      }

      _selectedEmoji = data['emoji'] ?? '💊';
      _emojiController.text = _selectedEmoji;

      _selectedDateText = data['dateText'] ?? data['day'] ?? '';
      _dateController.text = _selectedDateText;

      _notification = data['notification'] ?? true;
      _sound = data['sound'] ?? true;
    });

    _showReminderForm();
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    final String reminderTitle = _selectedCategory == 'others'
        ? _otherReminderController.text.trim()
        : _titleController.text.trim();

    setState(() {
      _isSaving = true;
    });

    final Map<String, dynamic> reminderData = {
      'userId': user.uid,
      'title': reminderTitle,
      'time': _timeController.text.trim(),
      'day': _dayName(_selectedDate),
      'dateText': _dateController.text.trim(),
      'emoji': _selectedEmoji,
      'category': _selectedCategory,
      'notification': _notification,
      'sound': _sound,
      'status': 'pending',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (_editingReminderId == null) {
        reminderData['createdAt'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection('reminders')
            .add(reminderData);
      } else {
        await FirebaseFirestore.instance
            .collection('reminders')
            .doc(_editingReminderId)
            .update(reminderData);
      }

      if (!mounted) return;

      Navigator.pop(context);
      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder saved successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving reminder: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteReminder(String docId) async {
    await FirebaseFirestore.instance
        .collection('reminders')
        .doc(docId)
        .delete();
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
                        _editingReminderId == null
                            ? 'Add Reminder'
                            : 'Edit Reminder',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 18),

                      if (_selectedCategory != 'others')
                        _buildInput(
                          label: 'Reminder Title',
                          controller: _titleController,
                          icon: Icons.title,
                        ),

                      if (_selectedCategory != 'others')
                        const SizedBox(height: 12),

                      _buildTimeInput(),

                      const SizedBox(height: 12),

                      _buildEmojiInput(modalSetState),

                      const SizedBox(height: 12),

                      _buildDateInput(),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: _inputDecoration(
                          label: 'Category',
                          icon: Icons.category_outlined,
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_categoryText(category)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          modalSetState(() {
                            _selectedCategory = value!;
                            if (_selectedCategory != 'others') {
                              _otherReminderController.clear();
                            }
                          });

                          setState(() {
                            _selectedCategory = value!;
                            if (_selectedCategory != 'others') {
                              _otherReminderController.clear();
                            }
                          });
                        },
                      ),

                      if (_selectedCategory == 'others') ...[
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
                          setState(() {
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
                          setState(() {
                            _sound = value;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveReminder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF69B7E8),
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  _editingReminderId == null ? 'Add' : 'Update',
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

  Widget _buildWeekDayTab(
    DateTime date,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> reminders,
  ) {
    final String dateText = _formatDate(date);
    final bool isSelected = dateText == _selectedDateText;

    final int reminderCount = reminders.where((doc) {
      final data = doc.data();
      return data['dateText'] == dateText;
    }).length;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDate = date;
            _selectedDateText = dateText;
            _dateController.text = _selectedDateText;
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

  Widget _buildWeekSelector(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> reminders,
  ) {
    final weekDates = _currentWeekDates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'This Week',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: weekDates
              .map((date) => _buildWeekDayTab(date, reminders))
              .toList(),
        ),
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
                    _selectedDateText,
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

  Widget _buildReminderCard(String docId, Map<String, dynamic> data) {
    final String title = data['title'] ?? 'Reminder';
    final String time = data['time'] ?? '';
    final String emoji = data['emoji'] ?? '🔔';
    final String category = data['category'] ?? 'others';
    final String dateText = data['dateText'] ?? '';

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
                    Icon(_categoryIcon(category), size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${_categoryText(category)} • $time',
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
                  dateText,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _fillFormForEdit(docId, data),
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF69B7E8)),
          ),
          IconButton(
            onPressed: () => _deleteReminder(docId),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
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
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _remindersStream(),
              builder: (context, snapshot) {
                final reminders = snapshot.data?.docs ?? [];

                final selectedReminders = reminders.where((doc) {
                  final data = doc.data();
                  return data['dateText'] == _selectedDateText;
                }).toList();

                return Expanded(
                  child: Column(
                    children: [
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
                                  final doc = selectedReminders.first;
                                  _fillFormForEdit(doc.id, doc.data());
                                }
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.delete_outline,
                              onTap: () {
                                if (selectedReminders.isNotEmpty) {
                                  _deleteReminder(selectedReminders.first.id);
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
                              _buildWeekSelector(reminders),
                              const SizedBox(height: 24),
                              Expanded(
                                child: user == null
                                    ? const Center(
                                        child: Text(
                                          'Please login first',
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : snapshot.connectionState ==
                                          ConnectionState.waiting
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF69B7E8),
                                        ),
                                      )
                                    : selectedReminders.isEmpty
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
                                          final doc = selectedReminders[index];
                                          return _buildReminderCard(
                                            doc.id,
                                            doc.data(),
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
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}
