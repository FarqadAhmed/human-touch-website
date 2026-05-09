import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _companionPhoneController;

  String _name = '';
  String _email = '';
  String _profileImageBase64 = '';

  bool _darkMode = false;
  bool _notifications = true;
  bool _locationSharing = true;
  bool _callCompanion = true;
  bool _sendSmsToCompanion = true;
  bool _alertNearbyVolunteers = true;

  String _language = 'en';
  double _textScale = 1.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _companionPhoneController = TextEditingController();
    _loadUserSettings();
  }

  @override
  void dispose() {
    _companionPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserSettings() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};

      if (!mounted) return;

      setState(() {
        _name = (data['name'] ?? data['fullName'] ?? data['username'] ?? '')
            .toString();
        _email = (data['email'] ?? user.email ?? '').toString();
        _profileImageBase64 =
            (data['profileImageBase64'] ?? data['image'] ?? '').toString();

        _darkMode = data['darkMode'] ?? false;
        _notifications = data['notifications'] ?? true;
        _locationSharing = data['locationSharing'] ?? true;
        _callCompanion = data['callCompanion'] ?? true;
        _sendSmsToCompanion = data['sendSmsToCompanion'] ?? true;
        _alertNearbyVolunteers = data['alertNearbyVolunteers'] ?? true;

        _language = (data['language'] ?? 'en').toString();

        final textScaleValue = data['textScale'];
        if (textScaleValue is num) {
          _textScale = textScaleValue.toDouble();
        } else {
          _textScale = 1.0;
        }

        _companionPhoneController.text =
            (data['companionPhone'] ?? '').toString();

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');

      if (!mounted) return;

      setState(() {
        _name = user.displayName ?? '';
        _email = user.email ?? '';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading settings: $e')),
      );
    }
  }

  Future<void> _updateSetting(String field, dynamic value) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating setting $field: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving setting: $e')),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
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
    }
  }

  void _showInfoCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 650, minHeight: 120),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                  decoration: const BoxDecoration(
                    color: Color(0xFF87CEEB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      content,
                      style: const TextStyle(
                        color: Color(0xFF14181B),
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAboutHumanTouch() {
    _showInfoCard(
      title: 'About Human Touch',
      icon: Icons.supervisor_account,
      content:
          '''Human Touch is a smart companion designed to improve daily life and independence for people with disabilities.''',
    );
  }

  void _showContactUs() {
    _showInfoCard(
      title: 'Contact Us',
      icon: Icons.phone_paused_rounded,
      content: '''We are here to support you.

Email: humantouchapp@gmail.com

Service Provider: Human Touch Team''',
    );
  }

  void _showPrivacyPolicy() {
    _showInfoCard(
      title: 'Privacy Policy',
      icon: Icons.privacy_tip_outlined,
      content: '''Privacy Policy
Effective Date: April 27, 2026

This Privacy Policy applies to the Human Touch app.''',
    );
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
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          height: 130,
          color: const Color(0xFF87CEEB),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Container(
            width: double.infinity,
            height: 41,
            decoration: const BoxDecoration(
              color: Color(0xFFF4F4F4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(70),
                topRight: Radius.circular(70),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileImageWidget() {
    if (_profileImageBase64.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(_profileImageBase64),
          fit: BoxFit.cover,
        );
      } catch (_) {
        return const Icon(Icons.person, size: 40, color: Colors.white);
      }
    }

    return const Icon(Icons.person, size: 40, color: Colors.white);
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFFF4F4F4)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _profileImageWidget(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name.isEmpty ? 'No Name' : _name,
                    style: const TextStyle(
                      color: Color(0xFF14181B),
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email.isEmpty ? 'No Email' : _email,
                    style: const TextStyle(
                      color: Color(0xFF87CEEB),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 0, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 5,
              color: Color(0x3416202A),
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      thickness: 1,
      indent: 15,
      endIndent: 15,
      color: Color(0xFFE0E0E0),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: const Color(0xFF57636C), size: 22),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Color(0xFF14181B), fontSize: 14),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF87CEEB),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleRow({
    required IconData icon,
    required String title,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF57636C), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Color(0xFF14181B), fontSize: 14),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(color: Color(0xFF57636C), fontSize: 14),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF57636C),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompanionPhoneRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Companion Phone Number',
            style: TextStyle(
              color: Color(0xFF14181B),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _companionPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter companion phone number',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final phone = _companionPhoneController.text.trim();

                    await _updateSetting('companionPhone', phone);

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Companion phone saved successfully'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF87CEEB),
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Center(
        child: ElevatedButton(
          onPressed: _logout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 1,
            foregroundColor: const Color(0xFF14181B),
            minimumSize: const Size(90, 40),
          ),
          child: const Text('Log Out', style: TextStyle(fontSize: 14)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF87CEEB)),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileCard(),
                      _buildCard(
                        children: [
                          _buildSectionTitle('Account Settings'),
                          _buildDivider(),
                          _buildSwitchRow(
                            title: 'Switch to Dark Mode',
                            value: _darkMode,
                            onChanged: (value) async {
                              setState(() => _darkMode = value);
                              await _updateSetting('darkMode', value);
                            },
                          ),
                          _buildDivider(),
                          _buildSwitchRow(
                            title: 'Notifications',
                            value: _notifications,
                            onChanged: (value) async {
                              setState(() => _notifications = value);
                              await _updateSetting('notifications', value);
                            },
                          ),
                          _buildDivider(),
                          _buildSwitchRow(
                            title: 'Location Sharing',
                            value: _locationSharing,
                            onChanged: (value) async {
                              setState(() => _locationSharing = value);
                              await _updateSetting('locationSharing', value);
                            },
                          ),
                          _buildDivider(),
                          _buildSimpleRow(
                            icon: Icons.g_translate_sharp,
                            title: 'Language',
                            trailingText:
                                _language == 'ar' ? 'Arabic' : 'English',
                            onTap: () async {
                              final newLang = _language == 'ar' ? 'en' : 'ar';
                              setState(() => _language = newLang);
                              await _updateSetting('language', newLang);
                            },
                          ),
                          _buildDivider(),
                          _buildSwitchRow(
                            title: 'Increase font size',
                            value: _textScale > 1.0,
                            onChanged: (value) async {
                              final newScale = value ? 1.15 : 1.0;
                              setState(() => _textScale = newScale);
                              await _updateSetting('textScale', newScale);
                            },
                            icon: Icons.format_size_rounded,
                          ),
                          _buildDivider(),
                          _buildCompanionPhoneRow(),
                          _buildDivider(),
                          _buildSwitchRow(
                            title: 'Call Companion in Emergency',
                            value: _callCompanion,
                            onChanged: (value) async {
                              setState(() => _callCompanion = value);
                              await _updateSetting('callCompanion', value);
                            },
                            icon: Icons.phone_rounded,
                          ),
                          _buildDivider(),
                          _buildSwitchRow(
                            title: 'Send SMS to Companion',
                            value: _sendSmsToCompanion,
                            onChanged: (value) async {
                              setState(() => _sendSmsToCompanion = value);
                              await _updateSetting('sendSmsToCompanion', value);
                            },
                            icon: Icons.sms_outlined,
                          ),
                          _buildDivider(),
                          _buildSwitchRow(
                            title: 'Alert Nearby Volunteers',
                            value: _alertNearbyVolunteers,
                            onChanged: (value) async {
                              setState(() => _alertNearbyVolunteers = value);
                              await _updateSetting(
                                'alertNearbyVolunteers',
                                value,
                              );
                            },
                            icon: Icons.location_on_outlined,
                          ),
                        ],
                      ),
                      _buildCard(
                        children: [
                          _buildSectionTitle('Human Touch'),
                          _buildDivider(),
                          _buildSimpleRow(
                            icon: Icons.supervisor_account,
                            title: 'About Human Touch',
                            onTap: _showAboutHumanTouch,
                          ),
                          _buildDivider(),
                          _buildSimpleRow(
                            icon: Icons.phone_paused_rounded,
                            title: 'Contact Us',
                            onTap: _showContactUs,
                          ),
                          _buildDivider(),
                          _buildSimpleRow(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: _showPrivacyPolicy,
                          ),
                        ],
                      ),
                      _buildLogoutButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }
}
