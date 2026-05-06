import 'package:flutter/material.dart';

enum ReminderCategory { medicine, meal, appointment, others }

class ReminderItem {
  final String id;
  String title;
  String time;
  String day;
  String emoji;
  ReminderCategory category;
  bool notification;
  bool sound;
  String status; // pending, done, missed

  ReminderItem({
    required this.id,
    required this.title,
    required this.time,
    required this.day,
    required this.emoji,
    required this.category,
    required this.notification,
    required this.sound,
    this.status = 'pending',
  });
}

class ReminderStore extends ChangeNotifier {
  ReminderStore._internal();

  static final ReminderStore instance = ReminderStore._internal();

  final List<ReminderItem> _reminders = [];

  List<ReminderItem> get reminders => List.unmodifiable(_reminders);

  List<ReminderItem> remindersByCategory(ReminderCategory category) {
    return _reminders.where((item) => item.category == category).toList();
  }

  List<ReminderItem> todayReminders([String today = 'Sunday']) {
    return _reminders.where((item) => item.day == today).toList();
  }

  void addReminder(ReminderItem item) {
    _reminders.add(item);
    notifyListeners();
  }

  void updateReminder(ReminderItem updatedItem) {
    final index = _reminders.indexWhere((item) => item.id == updatedItem.id);

    if (index != -1) {
      _reminders[index] = updatedItem;
      notifyListeners();
    }
  }

  void deleteReminder(String id) {
    _reminders.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateReminderStatus(String id, String status) {
    final index = _reminders.indexWhere((item) => item.id == id);

    if (index != -1) {
      _reminders[index].status = status;
      notifyListeners();
    }
  }
}
