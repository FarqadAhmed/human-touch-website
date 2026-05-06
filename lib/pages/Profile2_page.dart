import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Dashboard_page.dart';
import 'Login_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';
import 'profile_store.dart';

class Profile2Page extends StatefulWidget {
  const Profile2Page({super.key});

  @override
  State<Profile2Page> createState() => _Profile2PageState();
}

class _Profile2PageState extends State<Profile2Page> {
  final ProfileStore profileStore = ProfileStore.instance;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  late TextEditingController _volunteerSpecialtyController;
  late TextEditingController _volunteerSkillController;
  late TextEditingController _volunteerBioController;
  late TextEditingController _volunteerWorkController;

  bool _isScanning = false;

  String _selectedVolunteerType = 'Medical';

  final List<String> _volunteerTypes = [
    'Medical',
    'Shopping',
    'Transportation',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    profileStore.loadProfile();

    _nameController = TextEditingController(text: profileStore.name);
    _phoneController = TextEditingController(text: profileStore.phoneNumber);
    _emailController = TextEditingController(text: profileStore.email);
    _passwordController = TextEditingController(text: profileStore.password);

    _volunteerSpecialtyController = TextEditingController();
    _volunteerSkillController = TextEditingController();
    _volunteerBioController = TextEditingController();
    _volunteerWorkController = TextEditingController();

    _loadVolunteerInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    _volunteerSpecialtyController.dispose();
    _volunteerSkillController.dispose();
    _volunteerBioController.dispose();
    _volunteerWorkController.dispose();

    super.dispose();
  }

  Future<void> _loadVolunteerInfo() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _volunteerSpecialtyController.text =
          prefs.getString('volunteerSpecialty') ?? '';
      _volunteerSkillController.text = prefs.getString('volunteerSkill') ?? '';
      _volunteerBioController.text = prefs.getString('volunteerBio') ?? '';
      _volunteerWorkController.text = prefs.getString('volunteerWork') ?? '';
      _selectedVolunteerType = prefs.getString('volunteerType') ?? 'Medical';
    });
  }

  Future<void> _saveVolunteerInfo() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'volunteerSpecialty',
      _volunteerSpecialtyController.text.trim(),
    );

    await prefs.setString(
      'volunteerSkill',
      _volunteerSkillController.text.trim(),
    );

    await prefs.setString('volunteerBio', _volunteerBioController.text.trim());

    await prefs.setString(
      'volunteerWork',
      _volunteerWorkController.text.trim(),
    );

    await prefs.setString('volunteerType', _selectedVolunteerType);
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

  Future<void> _pickProfileImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedImage = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedImage == null) return;

    final Uint8List imageBytes = await pickedImage.readAsBytes();
    final String base64Image = base64Encode(imageBytes);

    profileStore.updateProfileImageBase64(base64Image);
    await profileStore.saveProfile();

    setState(() {});
  }

  Future<void> _saveProfile() async {
    profileStore.updateName(_nameController.text.trim());
    profileStore.updatePhoneNumber(_phoneController.text.trim());
    profileStore.updateEmail(_emailController.text.trim());
    profileStore.updatePassword(_passwordController.text.trim());

    await profileStore.saveProfile();

    if (profileStore.userRole == 'volunteer') {
      await _saveVolunteerInfo();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  Future<void> _openScanner() async {
    setState(() {
      _isScanning = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ScanPatientQrPage(
          onScanned: (code) {
            profileStore.linkPatientCode(code);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Patient linked successfully: $code')),
            );
          },
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      _isScanning = false;
    });
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

  Widget _buildTopProfileInfo() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF4F4F4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        child: Row(
          children: [
            InkWell(
              onTap: () => _pickProfileImage(ImageSource.gallery),
              child: Stack(
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Color(0xFF87CEEB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nameController.text.isEmpty
                        ? 'No Name'
                        : _nameController.text,
                    style: const TextStyle(
                      color: Color(0xFF14181B),
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _emailController.text.isEmpty
                        ? 'No Email'
                        : _emailController.text,
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

  Widget _buildSectionTitleCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 5,
              color: Color(0x3416202A),
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(15, 12, 15, 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Edit Profile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 5,
              color: Color(0x3416202A),
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : maxLines,
          onChanged: (_) {
            setState(() {});
          },
          decoration: InputDecoration(
            icon: Icon(icon, color: const Color(0xFF57636C)),
            border: InputBorder.none,
            labelText: label,
          ),
        ),
      ),
    );
  }

  Widget _buildUploadImageButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _pickProfileImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87CEEB),
                foregroundColor: Colors.white,
                elevation: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _pickProfileImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87CEEB),
                foregroundColor: Colors.white,
                elevation: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    Color backgroundColor = Colors.white,
    Color foregroundColor = const Color(0xFF14181B),
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
          label: Text(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            elevation: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildVolunteerInfoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 5,
              color: Color(0x3416202A),
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Volunteer Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _volunteerSpecialtyController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Specialty',
                hintText: 'Example: Nursing, First Aid, Physical Therapy',
                prefixIcon: Icon(Icons.work_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _volunteerSkillController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Skill',
                hintText: 'Example: Communication, Driving, Patient Care',
                prefixIcon: Icon(Icons.star_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedVolunteerType,
              decoration: const InputDecoration(
                labelText: 'Volunteer Type',
                prefixIcon: Icon(Icons.volunteer_activism_outlined),
                border: OutlineInputBorder(),
              ),
              items: _volunteerTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedVolunteerType = value;
                });
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _volunteerBioController,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'About Me',
                hintText: 'Write a short bio about yourself',
                prefixIcon: Icon(Icons.info_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _volunteerWorkController,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'What do you volunteer in?',
                hintText:
                    'Example: Helping patients with shopping or transport',
                prefixIcon: Icon(Icons.favorite_outline),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientQrSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 5,
              color: Color(0x3416202A),
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Patient QR Code',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 14),
            QrImageView(
              data: profileStore.patientLinkCode,
              version: QrVersions.auto,
              size: 200,
            ),
            const SizedBox(height: 12),
            Text(
              profileStore.patientLinkCode,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              'Let your companion scan this code to link the accounts.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanionScanSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 5,
              color: Color(0x3416202A),
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Patient Linking',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 14),
            _buildActionButton(
              text: _isScanning ? 'Opening Camera...' : 'Scan Patient QR',
              icon: Icons.qr_code_scanner,
              onPressed: _isScanning ? () {} : _openScanner,
              backgroundColor: const Color(0xFF87CEEB),
              foregroundColor: Colors.white,
            ),
            if (profileStore.linkedPatientCode.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Linked Patient Code: ${profileStore.linkedPatientCode}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ],
        ),
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
                          _buildTopProfileInfo(),
                          _buildSectionTitleCard(),
                          _buildUploadImageButton(),

                          _buildField(
                            icon: Icons.person_outlined,
                            label: 'Name',
                            controller: _nameController,
                          ),

                          _buildField(
                            icon: Icons.phone_in_talk,
                            label: 'Phone Number',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                          ),

                          _buildField(
                            icon: Icons.mail_outline_rounded,
                            label: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          _buildField(
                            icon: Icons.lock_open,
                            label: 'Password',
                            controller: _passwordController,
                            obscureText: true,
                          ),

                          if (profileStore.userRole == 'volunteer')
                            _buildVolunteerInfoSection(),

                          if (profileStore.userRole == 'patient')
                            _buildPatientQrSection(),

                          if (profileStore.userRole == 'companion')
                            _buildCompanionScanSection(),

                          _buildActionButton(
                            text: 'Save Changes',
                            icon: Icons.save_outlined,
                            onPressed: _saveProfile,
                            backgroundColor: const Color(0xFF87CEEB),
                            foregroundColor: Colors.white,
                          ),

                          _buildActionButton(
                            text: 'Delete Account',
                            icon: Icons.delete_outlined,
                            onPressed: () async {
                              await profileStore.deleteAccount();

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Account deleted'),
                                ),
                              );
                            },
                          ),

                          _buildActionButton(
                            text: 'Log Out',
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            },
                          ),

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

class _ScanPatientQrPage extends StatelessWidget {
  final void Function(String code) onScanned;

  const _ScanPatientQrPage({required this.onScanned});

  @override
  Widget build(BuildContext context) {
    bool scanned = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Patient QR'),
        backgroundColor: const Color(0xFF87CEEB),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (scanned) return;

          final barcodes = capture.barcodes;

          for (final barcode in barcodes) {
            final code = barcode.rawValue;

            if (code != null && code.isNotEmpty) {
              scanned = true;
              onScanned(code);
              Navigator.pop(context);
              break;
            }
          }
        },
      ),
    );
  }
}
