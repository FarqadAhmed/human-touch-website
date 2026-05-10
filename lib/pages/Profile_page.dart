import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Dashboard_page.dart';
import 'Login_page.dart';
import 'Profile2_page.dart';
import 'Settings_page.dart';

import 'package:humantouch/pages/app_settings_store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'No Name';
  String _email = 'No Email';
  String _role = 'patient';
  String _profileImageBase64 = '';
  bool _isActive = true;
  bool _isLoading = true;

  bool get isArabic => AppSettingsStore.instance.isArabic;

  String tr(String en, String ar) => isArabic ? ar : en;

  @override
  void initState() {
    super.initState();
    _loadProfileFromFirebase();
    AppSettingsStore.instance.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppSettingsStore.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  Future<void> _loadProfileFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();

      if (!mounted) return;

      setState(() {
        _name = (data?['name'] ??
                data?['fullName'] ??
                data?['username'] ??
                'No Name')
            .toString();

        _email = (data?['email'] ?? user.email ?? 'No Email').toString();

        _role = (data?['role'] ?? 'patient').toString();

        _profileImageBase64 =
            (data?['profileImageBase64'] ?? data?['image'] ?? '').toString();

        _isActive = data?['isActive'] ?? true;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('Error loading profile: $e', 'حدث خطأ أثناء تحميل الملف: $e'),
          ),
        ),
      );
    }
  }

  Future<void> _updateActiveStatus(bool value) async {
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      _isActive = value;
    });

    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'isActive': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
      return;
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      );
    }
  }

  String _translatedRole() {
    if (_role == 'patient') {
      return tr('Patient Account', 'حساب مريض');
    } else if (_role == 'companion') {
      return tr('Companion Account', 'حساب مرافق');
    } else if (_role == 'volunteer') {
      return tr('Volunteer Account', 'حساب متطوع');
    } else {
      return tr('User Account', 'حساب مستخدم');
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
          _bottomItem(Icons.home_rounded, tr('Home', 'الرئيسية'), 0),
          _bottomItem(Icons.person_rounded, tr('Profile', 'الملف'), 1),
          _bottomItem(Icons.settings_rounded, tr('Settings', 'الإعدادات'), 2),
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
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      } catch (_) {
        return _defaultProfileIcon();
      }
    }

    return _defaultProfileIcon();
  }

  Widget _defaultProfileIcon() {
    return Container(
      width: 100,
      height: 100,
      color: const Color(0xFF87CEEB),
      child: const Icon(Icons.person, size: 55, color: Colors.white),
    );
  }

  Widget _buildProfileTop() {
    return Column(
      children: [
        Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: const Color(0xFF87CEEB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: _profileImageWidget(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _name.isEmpty ? tr('No Name', 'لا يوجد اسم') : _name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF14181B),
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _email.isEmpty ? tr('No Email', 'لا يوجد بريد إلكتروني') : _email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF87CEEB),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Divider(
          height: 44,
          thickness: 1,
          indent: 24,
          endIndent: 24,
          color: Color(0xFFE0E3E7),
        ),
      ],
    );
  }

  Widget _buildActiveCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E3E7), width: 2),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
              child: Icon(
                Icons.power_settings_new_rounded,
                color: Color(0xFF14181B),
                size: 24,
              ),
            ),
            Expanded(
              child: SwitchListTile.adaptive(
                value: _isActive,
                onChanged: _updateActiveStatus,
                title: Text(
                  tr('Active', 'نشط'),
                  style: const TextStyle(
                    color: Color(0xFF14181B),
                    fontSize: 14,
                  ),
                ),
                activeColor: const Color(0xFF39D2C0),
                activeTrackColor: const Color(0x3439D2C0),
                contentPadding: const EdgeInsetsDirectional.fromSTEB(
                  12,
                  0,
                  4,
                  0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E3E7), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF14181B), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      color: Color(0xFF14181B),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleInfoCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E3E7), width: 2),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.badge_outlined,
              color: Color(0xFF14181B),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _translatedRole(),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: const TextStyle(
                  color: Color(0xFF14181B),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF1F4F8),
          foregroundColor: const Color(0xFF14181B),
          elevation: 0,
          minimumSize: const Size(150, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(38),
            side: const BorderSide(color: Color(0xFFE0E3E7)),
          ),
        ),
        child: Text(tr('Log Out', 'تسجيل الخروج')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F4F4),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF87CEEB),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildProfileTop(),
                              _buildActiveCard(),
                              _buildActionCard(
                                icon: Icons.account_circle_outlined,
                                title: tr('Edit Profile', 'تعديل الملف'),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const Profile2Page(),
                                    ),
                                  );

                                  await _loadProfileFromFirebase();
                                },
                              ),
                              _buildActionCard(
                                icon: Icons.settings_outlined,
                                title: tr(
                                  'Account Settings',
                                  'إعدادات الحساب',
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildRoleInfoCard(),
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
      ),
    );
  }
}
