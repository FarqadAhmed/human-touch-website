import 'dart:convert';

import 'package:flutter/material.dart';

import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Login_page.dart';
import 'EmergencySettings_store.dart';
import 'AppSettings_store.dart';
import 'profile_store.dart';

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
    } else if (index == 2) {
      return;
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
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
      content: '''About Human Touch

Human Touch is a smart companion designed to improve daily life and independence for people with disabilities. From managing medications, meals, appointments, and health routines to providing quick emergency support, the app helps users stay safe, organized, and connected. It also offers useful tools such as voice and sign communication assistance, accessible location guidance, health monitoring, and volunteer support services to ensure users receive the help they need anytime. With an intuitive interface and a seamless experience, Human Touch is your trusted support partner, making everyday life easier, safer, and more empowering!''',
    );
  }

  void _showContactUs() {
    _showInfoCard(
      title: 'Contact Us',
      icon: Icons.phone_paused_rounded,
      content: '''Contact Us

We are here to support you. If you have any questions, feedback, technical issues, or suggestions about the Human Touch app, please feel free to contact our team.

📧 Email: humantouchapp@gmail.com

🏢 Service Provider: Human Touch Team''',
    );
  }

  void _showPrivacyPolicy() {
    _showInfoCard(
      title: 'Privacy Policy',
      icon: Icons.privacy_tip_outlined,
      content: '''Privacy Policy
Effective Date: April 27, 2026

This Privacy Policy applies to the Human Touch app (hereafter referred to as the “Application”), developed and provided as a free service by the Human Touch Team (hereafter referred to as the “Service Provider”). The Application is provided “AS IS”, and this Privacy Policy explains how user data is collected, used, and protected.

1. Information Collection and Use

1.1 User-Provided Information

The Application may collect certain personally identifiable information (e.g., name, email address, phone number) when:

Users create an account or sign in.
Users contact the Service Provider for support or inquiries.
Users use specific features such as volunteer assistance, emergency contacts, or reminders.

This information is securely stored and used only as outlined in this Privacy Policy.

1.2 Automatically Collected Information

The Application may automatically collect certain data to improve user experience and service quality. This may include:

Operation Logs: Basic records of feature usage for analytics and performance improvements.
Last Login Time: The date and time of the user’s most recent login.
Device Information: Device type, operating system version, and app version.
Push Notification Identifiers: Device identifiers used to send reminders, alerts, and updates.

🚫 What the Application Does NOT Collect Automatically:

No tracking of browsing activity outside the app.
No access to photos, files, or contacts without user permission.
No collection of sensitive personal data unless required for specific features and approved by the user.

2. Use of Information

The Service Provider uses collected information solely for the following purposes:

To provide and improve Application functionality.
To manage reminders for medications, meals, appointments, and tasks.
To enable emergency support features and volunteer assistance.
To improve communication tools such as voice and sign support.
To analyze engagement and enhance user experience.
To send important notifications, reminders, or updates.
To prevent fraudulent activity and ensure security.

3. Third-Party Services

The Application may integrate third-party services which may collect limited data as part of their functionality. These may include:

Google Play Services
Firebase Authentication / Database
OneSignal or similar Push Notification Services

These providers have their own Privacy Policies, which users are encouraged to review.

🚨 Important: The Service Provider does not sell, rent, or share user data with advertisers or third-party marketing platforms.

4. Data Sharing and Disclosure

The Service Provider may disclose collected information only in the following circumstances:

Legal Compliance: If required by law or government request.
User Protection: If necessary to protect user safety or investigate fraud/security issues.
Trusted Service Providers: For secure backend support under strict confidentiality agreements.
Emergency Situations: If the user activates emergency assistance features requiring contact with selected companions or responders.

🚫 No user data is shared for advertising purposes.

5. Opt-Out Rights

Users may opt-out of certain data collection by:

Disabling notifications in device settings.
Disabling optional permissions such as location or microphone access.
Uninstalling the Application.
Requesting account or data deletion by contacting the Service Provider.

6. Data Retention Policy

The Service Provider retains user data only as long as necessary to provide services.

Reminder and account data are retained while the account remains active.
Emergency contacts remain stored until edited or deleted by the user.
Notification identifiers remain while notifications are enabled.

📌 Users may request deletion of their personal data at any time.

7. Children’s Privacy

The Application is not intended for children under the age of 13 without parental supervision.

The Service Provider does not knowingly collect personal data from children under 13. If discovered, such data will be deleted promptly.

8. Security Measures

The Service Provider takes reasonable precautions to protect user data, including:

Encryption and secure storage of sensitive information.
Restricted access controls.
Regular security monitoring and updates.

📌 However, no online method is 100% secure, and users should take care when sharing personal information.

9. Privacy Policy Updates

This Privacy Policy may be updated periodically to reflect:

Changes in Application features.
Security improvements.
Compliance with new laws or regulations.

📌 Users will be notified of significant updates through the app or email.

Continued use of the Application after updates means acceptance of the revised policy.

10. Your Consent

By using the Application, you consent to the collection and processing of your information as described in this Privacy Policy.

11. Contact Us

For privacy-related questions or concerns, you may contact:

📧 Email: humantouchapp@gmail.com

🏢 Service Provider: Human Touch Team''',
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
    if (profileStore.profileImageBase64.isNotEmpty) {
      return Image.memory(
        base64Decode(profileStore.profileImageBase64),
        fit: BoxFit.cover,
      );
    }

    return const Icon(Icons.person, size: 40, color: Colors.white);
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
                    profileStore.email.isEmpty
                        ? 'No Email'
                        : profileStore.email,
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
      },
    );
  }
}
