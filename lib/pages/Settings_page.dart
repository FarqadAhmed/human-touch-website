import 'dart:convert';

import 'package:flutter/material.dart';

import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Login_page.dart';
import 'EmergencySettings_store.dart';
import 'AppSettings_store.dart';
import 'profile_store.dart';
// import 'l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final EmergencySettingsStore settingsStore = EmergencySettingsStore.instance;
  final AppSettingsStore appSettingsStore = AppSettingsStore.instance;
  final ProfileStore profileStore = ProfileStore.instance;

  late TextEditingController _companionPhoneController;

  bool _notifications = true;
  bool _locationSharing = true;

  @override
  void initState() {
    super.initState();

    profileStore.loadProfile();

    _companionPhoneController = TextEditingController(
      text: settingsStore.companionPhone,
    );
  }

  @override
  void dispose() {
    _companionPhoneController.dispose();
    super.dispose();
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
    if (profileStore.profileImageBase64.isNotEmpty) {
      return Image.memory(
        base64Decode(profileStore.profileImageBase64),
        fit: BoxFit.cover,
      );
    }

    return const Icon(
      Icons.person,
      size: 40,
      color: Colors.white,
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F4),
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            color: Color(0xFFF1F4F8),
            offset: Offset(0, 0),
          ),
        ],
      ),
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
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _profileImageWidget(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profileStore.name.isEmpty ? 'No Name' : profileStore.name,
                    style: const TextStyle(
                      color: Color(0xFF14181B),
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profileStore.email.isEmpty ? 'No Email' : profileStore.email,
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
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
              style: const TextStyle(
                color: Color(0xFF14181B),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
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
      splashColor: Colors.grey.withOpacity(0.15),
      highlightColor: Colors.grey.withOpacity(0.08),
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
            style: TextStyle(color: Color(0xFF14181B), fontSize: 14),
          ),
          const SizedBox(height: 10),
          Container(
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
              onChanged: (value) {
                settingsStore.updateCompanionPhone(value.trim());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required BuildContext context,
    required IconData icon,
    required Widget page,
    required bool isCurrent,
  }) {
    return IconButton(
      onPressed: () {
        if (isCurrent) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      icon: Icon(
        icon,
        size: icon == Icons.settings_outlined ? 45 : 50,
        color: Colors.black,
      ),
      splashColor: Colors.grey.withOpacity(0.25),
      highlightColor: Colors.grey.withOpacity(0.18),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          },
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
    return AnimatedBuilder(
      animation: Listenable.merge([
        settingsStore,
        appSettingsStore,
        profileStore,
      ]),
      builder: (context, _) {
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
                                value: appSettingsStore.isDarkMode,
                                onChanged: (value) {
                                  appSettingsStore.updateThemeMode(value);
                                },
                              ),
                              _buildDivider(),

                              _buildSwitchRow(
                                title: 'Notifications',
                                value: _notifications,
                                onChanged: (value) {
                                  setState(() {
                                    _notifications = value;
                                  });
                                },
                              ),
                              _buildDivider(),

                              _buildSwitchRow(
                                title: 'Location Sharing',
                                value: _locationSharing,
                                onChanged: (value) {
                                  setState(() {
                                    _locationSharing = value;
                                  });
                                },
                              ),
                              _buildDivider(),

                              _buildSimpleRow(
                                icon: Icons.g_translate_sharp,
                                title: 'Language',
                                trailingText: appSettingsStore.isArabic
                                    ? 'Arabic'
                                    : 'English',
                                onTap: () {
                                  if (appSettingsStore.isArabic) {
                                    appSettingsStore.updateLocale('en');
                                  } else {
                                    appSettingsStore.updateLocale('ar');
                                  }
                                },
                              ),
                              _buildDivider(),

                              _buildSwitchRow(
                                title: 'Increase font size',
                                value: appSettingsStore.textScale > 1.0,
                                onChanged: (value) {
                                  appSettingsStore.updateTextScale(
                                    value ? 1.15 : 1.0,
                                  );
                                },
                                icon: Icons.format_size_rounded,
                              ),
                              _buildDivider(),

                              _buildCompanionPhoneRow(),
                              _buildDivider(),

                              _buildSwitchRow(
                                title: 'Call Companion in Emergency',
                                value: settingsStore.callCompanion,
                                onChanged: (value) {
                                  settingsStore.updateCallCompanion(value);
                                },
                                icon: Icons.phone_rounded,
                              ),
                              _buildDivider(),

                              _buildSwitchRow(
                                title: 'Send SMS to Companion',
                                value: settingsStore.sendSmsToCompanion,
                                onChanged: (value) {
                                  settingsStore.updateSendSmsToCompanion(value);
                                },
                                icon: Icons.sms_outlined,
                              ),
                              _buildDivider(),

                              _buildSwitchRow(
                                title: 'Alert Nearby Volunteers',
                                value: settingsStore.alertNearbyVolunteers,
                                onChanged: (value) {
                                  settingsStore.updateAlertNearbyVolunteers(
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
                              ),
                              _buildDivider(),
                              _buildSimpleRow(
                                icon: Icons.phone_paused_rounded,
                                title: 'Contact Us',
                              ),
                              _buildDivider(),
                              _buildSimpleRow(
                                icon: Icons.privacy_tip_outlined,
                                title: 'Privacy Policy',
                              ),
                            ],
                          ),

                          _buildLogoutButton(),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBottomNavItem(
                          context: context,
                          icon: Icons.home_outlined,
                          page: const DashboardPage(),
                          isCurrent: false,
                        ),
                        _buildBottomNavItem(
                          context: context,
                          icon: Icons.person_outlined,
                          page: const ProfilePage(),
                          isCurrent: false,
                        ),
                        _buildBottomNavItem(
                          context: context,
                          icon: Icons.settings_outlined,
                          page: const SettingsPage(),
                          isCurrent: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}