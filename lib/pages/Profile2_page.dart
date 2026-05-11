import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

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

import 'package:humantouch/pages/app_settings_store.dart';

class Profile2Page extends StatefulWidget {
  const Profile2Page({super.key});

  @override
  State<Profile2Page> createState() => _Profile2PageState();
}

class _Profile2PageState extends State<Profile2Page> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _manualPatientCodeController;

  late TextEditingController _volunteerSpecialtyController;
  late TextEditingController _volunteerSkillController;
  late TextEditingController _volunteerBioController;
  late TextEditingController _volunteerWorkController;

  bool _isScanning = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLinkingPatient = false;

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

  bool get isArabic => AppSettingsStore.instance.isArabic;

  String tr(String en, String ar) => isArabic ? ar : en;

  String _generatePatientCode() {
    final random = Random();
    final randomNumber = 100000 + random.nextInt(900000);
    return 'HT-$randomNumber';
  }

  String volunteerTypeText(String type) {
    switch (type) {
      case 'Medical':
        return tr('Medical', 'طبي');
      case 'Shopping':
        return tr('Shopping', 'تسوق');
      case 'Transportation':
        return tr('Transportation', 'مواصلات');
      case 'Other':
        return tr('Other', 'أخرى');
      default:
        return type;
    }
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _manualPatientCodeController = TextEditingController();

    _volunteerSpecialtyController = TextEditingController();
    _volunteerSkillController = TextEditingController();
    _volunteerBioController = TextEditingController();
    _volunteerWorkController = TextEditingController();

    AppSettingsStore.instance.addListener(_onLanguageChanged);

    _loadProfileFromFirebase();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppSettingsStore.instance.removeListener(_onLanguageChanged);

    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _manualPatientCodeController.dispose();

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

        _patientLinkCode = (data['patientLinkCode'] ?? '').toString();

        _linkedPatientCode = (data['linkedPatientCode'] ?? '').toString();

        _manualPatientCodeController.text = _linkedPatientCode;

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

      if (_userRole == 'patient') {
        await _refreshPatientCode();
      }
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

  Future<void> _refreshPatientCode() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final newCode = _generatePatientCode();

    if (mounted) {
      setState(() {
        _patientLinkCode = newCode;
      });
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'patientLinkCode': newCode,
      'patientLinkCodeUpdatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _linkPatientByCode(String code) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Please login first', 'يرجى تسجيل الدخول أولاً')),
        ),
      );
      return;
    }

    final cleanCode = code.trim().toUpperCase();

    if (cleanCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('Please enter patient code', 'يرجى إدخال كود المريض'),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLinkingPatient = true;
    });

    try {
      final patientQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('patientLinkCode', isEqualTo: cleanCode)
          .where('role', isEqualTo: 'patient')
          .limit(1)
          .get();

      if (patientQuery.docs.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr('Invalid patient code', 'كود المريض غير صحيح'),
            ),
          ),
        );
        return;
      }

      setState(() {
        _linkedPatientCode = cleanCode;
        _manualPatientCodeController.text = cleanCode;
      });

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'linkedPatientCode': cleanCode,
        'patientUid': patientQuery.docs.first.id,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Patient linked successfully: $cleanCode',
              'تم ربط المريض بنجاح: $cleanCode',
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Error linking patient: $e',
              'حدث خطأ أثناء ربط المريض: $e',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLinkingPatient = false;
        });
      }
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
          _bottomItem(Icons.home_rounded, tr('Home', 'الرئيسية'), 0),
          _bottomItem(Icons.person_rounded, tr('Profile', 'الملف'), 1),
          _bottomItem(Icons.settings_rounded, tr('Settings', 'الإعدادات'), 2),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Please login first', 'يرجى تسجيل الدخول أولاً')),
        ),
      );
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
        SnackBar(
          content: Text(
            tr('Profile updated successfully', 'تم تحديث الملف بنجاح'),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message =
          e.message ?? tr('Authentication error', 'خطأ في المصادقة');

      if (e.code == 'requires-recent-login') {
        message = tr(
          'Please log out and log in again before changing email.',
          'يرجى تسجيل الخروج ثم الدخول مرة أخرى قبل تغيير البريد الإلكتروني.',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('Error saving profile: $e', 'حدث خطأ أثناء حفظ الملف: $e'),
          ),
        ),
      );
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
        return Directionality(
          textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: AlertDialog(
            title: Text(tr('Delete Account', 'حذف الحساب')),
            content: Text(
              tr(
                'Are you sure you want to delete your account? This action cannot be undone.',
                'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(tr('Cancel', 'إلغاء')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  tr('Delete', 'حذف'),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
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
      String message =
          e.message ?? tr('Could not delete account', 'تعذر حذف الحساب');

      if (e.code == 'requires-recent-login') {
        message = tr(
          'Please log out and log in again before deleting account.',
          'يرجى تسجيل الخروج ثم الدخول مرة أخرى قبل حذف الحساب.',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
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

  Future<void> _openScanner() async {
    setState(() {
      _isScanning = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ScanPatientQrPage(
          onScanned: (code) async {
            await _linkPatientByCode(code);
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
                  PositionedDirectional(
                    bottom: 0,
                    end: 0,
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
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    _nameController.text.isEmpty
                        ? tr('No Name', 'لا يوجد اسم')
                        : _nameController.text,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      color: Color(0xFF14181B),
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _emailController.text.isEmpty
                        ? tr('No Email', 'لا يوجد بريد إلكتروني')
                        : _emailController.text,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
          child: Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              tr('Edit Profile', 'تعديل الملف الشخصي'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
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
              label: Text(tr('Gallery', 'المعرض')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87CEEB),
                foregroundColor: Colors.white,
                elevation: 1,
                minimumSize: const Size(0, 48),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _pickProfileImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: Text(tr('Camera', 'الكاميرا')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87CEEB),
                foregroundColor: Colors.white,
                elevation: 1,
                minimumSize: const Size(0, 48),
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
            minimumSize: const Size(0, 44),
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
          crossAxisAlignment:
              isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              tr('Volunteer Information', 'معلومات المتطوع'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _volunteerSpecialtyController,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: tr('Specialty', 'التخصص'),
                hintText: tr(
                  'Example: Nursing, First Aid, Physical Therapy',
                  'مثال: تمريض، إسعافات أولية، علاج طبيعي',
                ),
                prefixIcon: const Icon(Icons.work_outline),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _volunteerSkillController,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: tr('Skill', 'المهارة'),
                hintText: tr(
                  'Example: Communication, Driving, Patient Care',
                  'مثال: التواصل، القيادة، رعاية المرضى',
                ),
                prefixIcon: const Icon(Icons.star_outline),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedVolunteerType,
              decoration: InputDecoration(
                labelText: tr('Volunteer Type', 'نوع التطوع'),
                prefixIcon: const Icon(Icons.volunteer_activism_outlined),
                border: const OutlineInputBorder(),
              ),
              items: _volunteerTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(volunteerTypeText(type)),
                );
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
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: tr('About Me', 'نبذة عني'),
                hintText: tr(
                  'Write a short bio about yourself',
                  'اكتب نبذة قصيرة عن نفسك',
                ),
                prefixIcon: const Icon(Icons.info_outline),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _volunteerWorkController,
              maxLines: 3,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: tr(
                  'What do you volunteer in?',
                  'في ماذا تتطوع؟',
                ),
                hintText: tr(
                  'Example: Helping patients with shopping or transport',
                  'مثال: مساعدة المرضى في التسوق أو المواصلات',
                ),
                prefixIcon: const Icon(Icons.favorite_outline),
                border: const OutlineInputBorder(),
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
            Align(
              alignment:
                  isArabic ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                tr('Patient QR Code', 'رمز QR للمريض'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 14),
            if (_patientLinkCode.isNotEmpty)
              QrImageView(
                data: _patientLinkCode,
                version: QrVersions.auto,
                size: 200,
              )
            else
              Column(
                children: [
                  const CircularProgressIndicator(color: Color(0xFF87CEEB)),
                  const SizedBox(height: 10),
                  Text(
                    tr('Generating code...', 'جاري توليد الكود...'),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            SelectableText(
              _patientLinkCode.isEmpty
                  ? tr('Code is loading...', 'الكود قيد التحميل...')
                  : _patientLinkCode,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF14181B),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr(
                'Your companion can scan or manually enter this code.',
                'يمكن للمرافق مسح الرمز أو كتابة الكود يدويًا.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _refreshPatientCode,
              icon: const Icon(Icons.refresh),
              label: Text(
                tr('Generate New Code', 'توليد كود جديد'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87CEEB),
                foregroundColor: Colors.white,
              ),
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
            Align(
              alignment:
                  isArabic ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                tr('Patient Linking', 'ربط المريض'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 14),
            _buildActionButton(
              text: _isScanning
                  ? tr('Opening Camera...', 'جاري فتح الكاميرا...')
                  : tr('Scan Patient QR', 'مسح رمز QR للمريض'),
              icon: Icons.qr_code_scanner,
              onPressed: _isScanning ? () {} : _openScanner,
              backgroundColor: const Color(0xFF87CEEB),
              foregroundColor: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              tr(
                'Or enter patient code manually',
                'أو أدخل كود المريض يدويًا',
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _manualPatientCodeController,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: tr(
                  'Enter Patient Code',
                  'أدخل كود المريض',
                ),
                hintText: 'HT-123456',
                prefixIcon: const Icon(Icons.password),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _isLinkingPatient
                    ? null
                    : () {
                        _linkPatientByCode(_manualPatientCodeController.text);
                      },
                icon: const Icon(Icons.link),
                label: Text(
                  _isLinkingPatient
                      ? tr('Linking...', 'جاري الربط...')
                      : tr('Link Patient', 'ربط المريض'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF87CEEB),
                  foregroundColor: Colors.white,
                ),
              ),
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
                  '${tr('Linked Patient Code', 'رمز المريض المرتبط')}: $_linkedPatientCode',
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTopProfileInfo(),
                        _buildSectionTitleCard(),
                        _buildUploadImageButton(),
                        _buildField(
                          icon: Icons.person_outlined,
                          label: tr('Name', 'الاسم'),
                          controller: _nameController,
                        ),
                        _buildField(
                          icon: Icons.phone_in_talk,
                          label: tr('Phone Number', 'رقم الهاتف'),
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildField(
                          icon: Icons.mail_outline_rounded,
                          label: tr('Email', 'البريد الإلكتروني'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildActionButton(
                          text: tr(
                            'Change Password',
                            'تغيير كلمة المرور',
                          ),
                          icon: Icons.lock_reset,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgetPasswordPage(),
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
                          text: _isSaving
                              ? tr('Saving...', 'جاري الحفظ...')
                              : tr('Save Changes', 'حفظ التغييرات'),
                          icon: Icons.save_outlined,
                          onPressed: _isSaving ? () {} : _saveProfile,
                          backgroundColor: const Color(0xFF87CEEB),
                          foregroundColor: Colors.white,
                        ),
                        _buildActionButton(
                          text: tr('Delete Account', 'حذف الحساب'),
                          icon: Icons.delete_outlined,
                          onPressed: _confirmDeleteAccount,
                        ),
                        _buildActionButton(
                          text: tr('Log Out', 'تسجيل الخروج'),
                          onPressed: _logout,
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
      ),
    );
  }
}

class _ScanPatientQrPage extends StatelessWidget {
  final void Function(String code) onScanned;

  const _ScanPatientQrPage({required this.onScanned});

  bool get isArabic => AppSettingsStore.instance.isArabic;

  String tr(String en, String ar) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    bool scanned = false;

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('Scan Patient QR', 'مسح رمز QR للمريض')),
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
      ),
    );
  }
}
