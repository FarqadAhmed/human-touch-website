import 'dart:convert';

import 'package:flutter/material.dart';
import 'Dashboard_page.dart';
import 'Login_page.dart';
import 'Profile2_page.dart';
import 'Settings_page.dart';
import 'profile_store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileStore profileStore = ProfileStore.instance;

  @override
  void initState() {
    super.initState();
    profileStore.loadProfile();
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required VoidCallback onTap,
    bool isCurrent = false,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: icon == Icons.settings_outlined ? 45 : 50,
        color: isCurrent ? const Color(0xFF87CEEB) : Colors.black,
      ),
      splashColor: Colors.grey.withOpacity(0.20),
      highlightColor: Colors.grey.withOpacity(0.12),
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
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }

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
                value: profileStore.isActive,
                onChanged: (value) {
                  profileStore.updateIsActive(value);
                },
                title: const Text(
                  'Active',
                  style: TextStyle(color: Color(0xFF14181B), fontSize: 14),
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
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF14181B),
                    fontSize: 14,
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
    String roleText = '';

    if (profileStore.userRole == 'patient') {
      roleText = 'Patient Account';
    } else if (profileStore.userRole == 'companion') {
      roleText = 'Companion Account';
    } else {
      roleText = 'Volunteer Account';
    }

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
            Text(
              roleText,
              style: const TextStyle(color: Color(0xFF14181B), fontSize: 14),
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
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        },
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
        child: const Text('Log Out'),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
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
            icon: Icons.home_outlined,
            isCurrent: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
            },
          ),
          _buildBottomNavItem(
            icon: Icons.person_outlined,
            isCurrent: true,
            onTap: () {},
          ),
          _buildBottomNavItem(
            icon: Icons.settings_outlined,
            isCurrent: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: profileStore,
      builder: (context, _) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
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
                          _buildProfileTop(),
                          _buildActiveCard(),
                          _buildActionCard(
                            icon: Icons.account_circle_outlined,
                            title: 'Edit Profile',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Profile2Page(),
                                ),
                              );

                              await profileStore.loadProfile();
                            },
                          ),
                          _buildActionCard(
                            icon: Icons.settings_outlined,
                            title: 'Account Settings',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsPage(),
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
                  _buildBottomNavigation(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
