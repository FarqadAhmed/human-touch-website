import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileStore extends ChangeNotifier {
  ProfileStore._internal();

  static final ProfileStore instance = ProfileStore._internal();

  String profileImageBase64 = '';

  String name = 'Andrea Davis';
  String email = 'andrea@domainname.com';
  String phoneNumber = '+97330000000';
  String password = '123456';
  bool isActive = true;

  String userRole = 'patient';

  String patientLinkCode = 'PATIENT-HT-1001';
  String linkedPatientCode = '';

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    profileImageBase64 =
        prefs.getString('profile_image_base64') ?? profileImageBase64;
    name = prefs.getString('profile_name') ?? name;
    email = prefs.getString('profile_email') ?? email;
    phoneNumber = prefs.getString('profile_phone') ?? phoneNumber;
    password = prefs.getString('profile_password') ?? password;
    isActive = prefs.getBool('profile_is_active') ?? isActive;
    userRole = prefs.getString('profile_user_role') ?? userRole;
    patientLinkCode =
        prefs.getString('profile_patient_link_code') ?? patientLinkCode;
    linkedPatientCode =
        prefs.getString('profile_linked_patient_code') ?? linkedPatientCode;

    notifyListeners();
  }

  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('profile_image_base64', profileImageBase64);
    await prefs.setString('profile_name', name);
    await prefs.setString('profile_email', email);
    await prefs.setString('profile_phone', phoneNumber);
    await prefs.setString('profile_password', password);
    await prefs.setBool('profile_is_active', isActive);
    await prefs.setString('profile_user_role', userRole);
    await prefs.setString('profile_patient_link_code', patientLinkCode);
    await prefs.setString('profile_linked_patient_code', linkedPatientCode);
  }

  void updateProfileImageBase64(String value) {
    profileImageBase64 = value;
    notifyListeners();
  }

  void updateName(String value) {
    name = value;
    notifyListeners();
  }

  void updateEmail(String value) {
    email = value;
    notifyListeners();
  }

  void updatePhoneNumber(String value) {
    phoneNumber = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    notifyListeners();
  }

  Future<void> updateIsActive(bool value) async {
    isActive = value;
    notifyListeners();
    await saveProfile();
  }

  void updateUserRole(String value) {
    userRole = value;
    notifyListeners();
  }

  void updatePatientLinkCode(String value) {
    patientLinkCode = value;
    notifyListeners();
  }

  Future<void> linkPatientCode(String code) async {
    linkedPatientCode = code;
    notifyListeners();
    await saveProfile();
  }

  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    profileImageBase64 = '';
    name = '';
    email = '';
    phoneNumber = '';
    password = '';
    isActive = false;
    linkedPatientCode = '';

    notifyListeners();
  }
}