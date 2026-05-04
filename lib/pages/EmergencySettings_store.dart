import 'package:flutter/material.dart';

class EmergencySettingsStore extends ChangeNotifier {
  EmergencySettingsStore._internal();

  static final EmergencySettingsStore instance =
      EmergencySettingsStore._internal();

  String companionPhone = '+97330000000';
  bool callCompanion = true;
  bool sendSmsToCompanion = true;
  bool alertNearbyVolunteers = true;

  void updateCompanionPhone(String value) {
    companionPhone = value;
    notifyListeners();
  }

  void updateCallCompanion(bool value) {
    callCompanion = value;
    notifyListeners();
  }

  void updateSendSmsToCompanion(bool value) {
    sendSmsToCompanion = value;
    notifyListeners();
  }

  void updateAlertNearbyVolunteers(bool value) {
    alertNearbyVolunteers = value;
    notifyListeners();
  }
}
