import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Dashboard_page.dart';
import 'Login_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';
import 'ForgetPassword_page.dart';

class Profile2Page extends StatefulWidget {
  const Profile2Page({super.key});

  @override
  State<Profile2Page> createState() => _Profile2PageState();
}

class _Profile2PageState extends State<Profile2Page> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  late TextEditingController _volunteerSpecialtyController;
  late TextEditingController _volunteerSkillController;
  late TextEditingController _volunteerBioController;
  late TextEditingController _volunteerWorkController;

  bool _isScanning = false;
  bool _isLoading = true;
  bool _isSaving = false;

  String _userRole = 'patient';
  String _profileImageBase64 = '';
  String _patientLinkCode = '';
  String _linkedPatientCode = '';

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

    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();

    _volunteerSpecialtyController = TextEditingController();
    _volunteerSkillController = TextEditingController();
    _volunteerBioController = TextEditingController();
    _volunteerWorkController = TextEditingController();

    _loadProfileFromFirebase();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    _volunteerSpecialtyController.dispose();
    _volunteerSkillController.dispose();
    _volunteerBioController.dispose();
    _volunteerWorkController.dispose();

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

      final data = doc.data() ?? {};

      if (!mounted) return;

      setState(() {
        _nameController.text =
            (data['name'] ?? data['fullName'] ?? data['username'] ?? '')
                .toString();

        _phoneController.text =
            (data['phone'] ?? data['phoneNumber'] ?? '').toString();

        _emailController.text = (data['email'] ?? user.email ?? '').toString();

        _userRole = (data['role'] ?? 'patient').toString();

        _profileImageBase64 =
            (data['profileImageBase64'] ?? data['image'] ?? '').toString();

        _patientLinkCode =
            (data['patientLinkCode'] ?? 'PATIENT-${user.uid}').toString();

        _linkedPatientCode = (data['linkedPatientCode'] ?? '').toString();

        _volunteerSpecialtyController.text =
            (data['volunteerSpecialty'] ?? '').toString();

        _volunteerSkillController.text =
            (data['volunteerSkill'] ?? '').toString();

        _volunteerBioController.text = (data['volunteerBio'] ?? '').toString();

        _volunteerWorkController.text =
            (data['volunteerWork'] ?? '').toString();

        _selectedVolunteerType =
            (data['volunteerType'] ?? 'Medical').toString();

        if (!_volunteerTypes.contains(_selectedVolunteerType)) {
          _selectedVolunteerType = 'Medical';
        }

        _isLoading = false;
      });

      if (!data.containsKey('patientLinkCode')) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'patientLinkCode': 'PATIENT-${user.uid}',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    }
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
      imageQuality: 60,
    );

    if (pickedImage == null) return;

    final Uint8List imageBytes = await pickedImage.readAsBytes();
    final String base64Image = base64Encode(imageBytes);

    setState(() {
      _profileImageBase64 = base64Image;
    });
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final Map<String, dynamic> updatedData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'profileImageBase64': _profileImageBase64,
        'role': _userRole,
        'patientLinkCode': _patientLinkCode,
        'linkedPatientCode': _linkedPatientCode,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_userRole == 'volunteer') {
        updatedData.addAll({
          'volunteerSpecialty': _volunteerSpecialtyController.text.trim(),
          'volunteerSkill': _volunteerSkillController.text.trim(),
          'volunteerBio': _volunteerBioController.text.trim(),
          'volunteerWork': _volunteerWorkController.text.trim(),
          'volunteerType': _selectedVolunteerType,
        });
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(updatedData, SetOptions(merge: true));

      if (_emailController.text.trim().isNotEmpty &&
          _emailController.text.trim() != user.email) {
        await user.verifyBeforeUpdateEmail(_emailController.text.trim());
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Authentication error';

      if (e.code == 'requires-recent-login') {
        message = 'Please log out and log in again before changing email.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      await user.delete();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Could not delete account';

      if (e.code == 'requires-recent-login') {
        message = 'Please log out and log in again before deleting account.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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

  Future<void> _openScanner() async {
    setState(() {
      _isScanning = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ScanPatientQrPage(
          onScanned: (code) async {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return;

            final patientQuery = await FirebaseFirestore.instance
                .collection('users')
                .where('patientLinkCode', isEqualTo: code)
                .where('role', isEqualTo: 'patient')
                .limit(1)
                .get();

            if (patientQuery.docs.isEmpty) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invalid patient QR code')),
              );
              return;
            }

            setState(() {
              _linkedPatientCode = code;
            });

            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'linkedPatientCode': code,
              'patientUid': patientQuery.docs.first.id,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            if (!mounted) return;

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
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (_) => setState(() {}),
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
              data: _patientLinkCode,
              version: QrVersions.auto,
              size: 200,
            ),
            const SizedBox(height: 12),
            Text(
              _patientLinkCode,
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
            if (_linkedPatientCode.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Linked Patient Code: $_linkedPatientCode',
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF87CEEB)),
        ),
      );
    }

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
                      _buildActionButton(
                        text: 'Change / Forgot Password',
                        icon: Icons.lock_reset,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgetPasswordPage(),
                            ),
                          );
                        },
                      ),
                      if (_userRole == 'volunteer')
                        _buildVolunteerInfoSection(),
                      if (_userRole == 'patient') _buildPatientQrSection(),
                      if (_userRole == 'companion')
                        _buildCompanionScanSection(),
                      _buildActionButton(
                        text: _isSaving ? 'Saving...' : 'Save Changes',
                        icon: Icons.save_outlined,
                        onPressed: _isSaving ? () {} : _saveProfile,
                        backgroundColor: const Color(0xFF87CEEB),
                        foregroundColor: Colors.white,
                      ),
                      _buildActionButton(
                        text: 'Delete Account',
                        icon: Icons.delete_outlined,
                        onPressed: _confirmDeleteAccount,
                      ),
                      _buildActionButton(text: 'Log Out', onPressed: _logout),
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
