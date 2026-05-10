import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'location_picker_page.dart';
import 'VolunteerDashboard_page.dart';
import 'Login_page.dart';
import 'SignUp_page.dart';
import 'app_settings_store.dart';

class SignUpVolunteerPage extends StatefulWidget {
  const SignUpVolunteerPage({super.key});

  @override
  State<SignUpVolunteerPage> createState() => _SignUpVolunteerPageState();
}

class _SignUpVolunteerPageState extends State<SignUpVolunteerPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _assistanceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _assistanceFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String _passwordText = '';

  bool get isArabic => AppSettingsStore.instance.isArabic;

  String tr(String en, String ar) => isArabic ? ar : en;

  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordText);
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordText);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordText);
  bool get _hasSymbol => RegExp(r'[@#$!]').hasMatch(_passwordText);
  bool get _hasMinLength => _passwordText.length >= 8;

  String? _selectedGender;
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void initState() {
    super.initState();
    AppSettingsStore.instance.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  void _toggleLanguage() {
    AppSettingsStore.instance.toggleLanguage();
    setState(() {});
  }

  @override
  void dispose() {
    AppSettingsStore.instance.removeListener(_onLanguageChanged);

    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _assistanceController.dispose();
    _locationController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _assistanceFocusNode.dispose();

    super.dispose();
  }

  void _generateStrongPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$!';
    final random = Random();

    String password = '';
    password += 'a';
    password += 'A';
    password += '1';
    password += '@';

    for (int i = 0; i < 6; i++) {
      password += chars[random.nextInt(chars.length)];
    }

    final shuffled = password.split('')..shuffle();

    setState(() {
      _passwordText = shuffled.join();
      _passwordController.text = _passwordText;
      _confirmPasswordController.text = _passwordText;
    });
  }

  Widget _passwordRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontSize: 12,
                color: isValid ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _mainButtonStyle() {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.grey;
        }
        return const Color(0xFF87CEEB);
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.grey.withOpacity(0.25);
        }
        return null;
      }),
      elevation: WidgetStateProperty.all(0),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  ButtonStyle _linkButtonStyle() {
    return ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      minimumSize: WidgetStateProperty.all(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.grey.withOpacity(0.30);
        }
        return null;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.grey.shade700;
        }
        return const Color(0xFF025590);
      }),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        fontWeight: FontWeight.normal,
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 14,
        color: Color(0xFF025590),
        fontWeight: FontWeight.normal,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFF025590), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildFieldContainer({required Widget child, double height = 64}) {
    return SizedBox(width: double.infinity, height: height, child: child);
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerPage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      final latValue = result['latitude'];
      final lngValue = result['longitude'];

      setState(() {
        _locationController.text = result['address'] ?? '';
        _selectedLatitude = latValue is num ? latValue.toDouble() : null;
        _selectedLongitude = lngValue is num ? lngValue.toDouble() : null;
      });
    }
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_selectedGender == null || _selectedGender!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Please select gender', 'يرجى اختيار الجنس')),
        ),
      );
      return;
    }

    if (_locationController.text.trim().isEmpty ||
        _selectedLatitude == null ||
        _selectedLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Please select location', 'يرجى اختيار الموقع')),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to create account');
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'gender': _selectedGender,
        'assistanceType': _assistanceController.text.trim(),
        'helpType': _assistanceController.text.trim(),
        'volunteerType': _assistanceController.text.trim(),
        'location': _locationController.text.trim(),
        'latitude': _selectedLatitude,
        'longitude': _selectedLongitude,
        'role': 'volunteer',
        'isAvailable': true,
        'rating': 5.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Volunteer account created successfully',
              'تم إنشاء حساب المتطوع بنجاح',
            ),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VolunteerDashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      String message = tr(
        'Failed to create account.',
        'فشل إنشاء الحساب.',
      );

      if (e.code == 'email-already-in-use') {
        message = tr(
          'This email is already used.',
          'هذا البريد مستخدم مسبقاً.',
        );
      } else if (e.code == 'invalid-email') {
        message = tr(
          'Please enter a valid email.',
          'يرجى إدخال بريد إلكتروني صحيح.',
        );
      } else if (e.code == 'weak-password') {
        message = tr(
          'Password is too weak.',
          'كلمة المرور ضعيفة.',
        );
      } else if (e.message != null && e.message!.trim().isNotEmpty) {
        message = e.message!;
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Error: $e', 'حدث خطأ: $e'))),
      );
    }
  }

  Widget _languageButton() {
    return Positioned(
      top: 8,
      right: isArabic ? null : 16,
      left: isArabic ? 16 : null,
      child: GestureDetector(
        onTap: _toggleLanguage,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF87CEEB),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              isArabic ? 'EN' : 'AR',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Align(
                      alignment: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpPage(),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            overlayColor:
                                WidgetStateProperty.resolveWith<Color?>(
                              (states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return Colors.grey.withOpacity(0.30);
                                }
                                return null;
                              },
                            ),
                          ),
                          icon: Icon(
                            isArabic ? Icons.arrow_forward : Icons.arrow_back,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Center(
                                child: Text(
                                  tr('Sign Up Volunteer', 'تسجيل المتطوع'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              _buildFieldContainer(
                                child: TextFormField(
                                  controller: _nameController,
                                  focusNode: _nameFocusNode,
                                  textInputAction: TextInputAction.next,
                                  textAlign: isArabic
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  decoration: _inputDecoration(
                                    label: tr('Name', 'الاسم'),
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                  validator: (value) {
                                    if ((value ?? '').trim().isEmpty) {
                                      return tr(
                                        'Please enter your name',
                                        'يرجى إدخال الاسم',
                                      );
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context)
                                        .requestFocus(_emailFocusNode);
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildFieldContainer(
                                child: TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  textAlign: isArabic
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  decoration: _inputDecoration(
                                    label: tr(
                                      'Email',
                                      'البريد الإلكتروني',
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                  validator: (value) {
                                    final text = (value ?? '').trim();
                                    if (text.isEmpty) {
                                      return tr(
                                        'Please enter your email',
                                        'يرجى إدخال البريد الإلكتروني',
                                      );
                                    }
                                    if (!text.contains('@') ||
                                        !text.contains('.')) {
                                      return tr(
                                        'Please enter a valid email',
                                        'يرجى إدخال بريد إلكتروني صحيح',
                                      );
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context)
                                        .requestFocus(_phoneFocusNode);
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildFieldContainer(
                                child: TextFormField(
                                  controller: _phoneController,
                                  focusNode: _phoneFocusNode,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  textAlign: isArabic
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  decoration: _inputDecoration(
                                    label: tr(
                                      'Phone Number',
                                      'رقم الهاتف',
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                  validator: (value) {
                                    final text = (value ?? '').trim();
                                    if (text.isEmpty) {
                                      return tr(
                                        'Please enter your phone number',
                                        'يرجى إدخال رقم الهاتف',
                                      );
                                    }
                                    if (text.length != 8) {
                                      return tr(
                                        'Please enter a valid phone number',
                                        'يرجى إدخال رقم هاتف صحيح',
                                      );
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context)
                                        .requestFocus(_passwordFocusNode);
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: isArabic
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: TextButton.icon(
                                  style: _linkButtonStyle(),
                                  onPressed: _generateStrongPassword,
                                  icon:
                                      const Icon(Icons.auto_awesome, size: 18),
                                  label: Text(
                                    tr(
                                      'Generate strong password',
                                      'إنشاء كلمة مرور قوية',
                                    ),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildFieldContainer(
                                child: TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.next,
                                  textAlign: isArabic
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  decoration: _inputDecoration(
                                    label: tr('Password', 'كلمة المرور'),
                                    suffixIcon: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      child: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                  onChanged: (value) {
                                    setState(() {
                                      _passwordText = value;
                                    });
                                  },
                                  validator: (value) {
                                    final text = value ?? '';

                                    if (text.isEmpty) {
                                      return tr(
                                        'Please enter password',
                                        'يرجى إدخال كلمة المرور',
                                      );
                                    }
                                    if (!RegExp(r'[a-z]').hasMatch(text)) {
                                      return tr(
                                        'Password must contain at least one lowercase letter',
                                        'يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل',
                                      );
                                    }
                                    if (!RegExp(r'[A-Z]').hasMatch(text)) {
                                      return tr(
                                        'Password must contain at least one uppercase letter',
                                        'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل',
                                      );
                                    }
                                    if (!RegExp(r'[0-9]').hasMatch(text)) {
                                      return tr(
                                        'Password must contain at least one number',
                                        'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل',
                                      );
                                    }
                                    if (!RegExp(r'[@#$!]').hasMatch(text)) {
                                      return tr(
                                        'Password must contain at least one symbol (@#\$!)',
                                        'يجب أن تحتوي كلمة المرور على رمز واحد على الأقل (@#\$!)',
                                      );
                                    }
                                    if (text.length < 8) {
                                      return tr(
                                        'Password must be at least 8 characters',
                                        'يجب أن تكون كلمة المرور 8 أحرف على الأقل',
                                      );
                                    }

                                    return null;
                                  },
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(
                                      _confirmPasswordFocusNode,
                                    );
                                  },
                                ),
                              ),
                              if (_passwordText.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Column(
                                  crossAxisAlignment: isArabic
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    _passwordRequirement(
                                      tr(
                                        'At least one lowercase letter (a-z)',
                                        'حرف صغير واحد على الأقل (a-z)',
                                      ),
                                      _hasLowercase,
                                    ),
                                    _passwordRequirement(
                                      tr(
                                        'At least one uppercase letter (A-Z)',
                                        'حرف كبير واحد على الأقل (A-Z)',
                                      ),
                                      _hasUppercase,
                                    ),
                                    _passwordRequirement(
                                      tr(
                                        'At least one number (0-9)',
                                        'رقم واحد على الأقل (0-9)',
                                      ),
                                      _hasNumber,
                                    ),
                                    _passwordRequirement(
                                      tr(
                                        'At least one symbol (@#\$!)',
                                        'رمز واحد على الأقل (@#\$!)',
                                      ),
                                      _hasSymbol,
                                    ),
                                    _passwordRequirement(
                                      tr(
                                        'At least 8 characters',
                                        '8 أحرف على الأقل',
                                      ),
                                      _hasMinLength,
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 10),
                              _buildFieldContainer(
                                child: TextFormField(
                                  controller: _confirmPasswordController,
                                  focusNode: _confirmPasswordFocusNode,
                                  obscureText: _obscureConfirmPassword,
                                  textInputAction: TextInputAction.next,
                                  textAlign: isArabic
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  decoration: _inputDecoration(
                                    label: tr(
                                      'Confirm Password',
                                      'تأكيد كلمة المرور',
                                    ),
                                    suffixIcon: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                      child: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                  validator: (value) {
                                    final text = value ?? '';
                                    if (text.isEmpty) {
                                      return tr(
                                        'Please confirm password',
                                        'يرجى تأكيد كلمة المرور',
                                      );
                                    }
                                    if (text != _passwordController.text) {
                                      return tr(
                                        'Passwords do not match',
                                        'كلمتا المرور غير متطابقتين',
                                      );
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildFieldContainer(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedGender,
                                  decoration: _inputDecoration(
                                    label: tr('Gender', 'الجنس'),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'Female',
                                      child: Text(tr('Female', 'أنثى')),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Male',
                                      child: Text(tr('Male', 'ذكر')),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildFieldContainer(
                                child: TextFormField(
                                  controller: _assistanceController,
                                  focusNode: _assistanceFocusNode,
                                  textInputAction: TextInputAction.done,
                                  textAlign: isArabic
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  decoration: _inputDecoration(
                                    label: tr(
                                      'Type of Assistance',
                                      'نوع المساعدة',
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                  validator: (value) {
                                    if ((value ?? '').trim().isEmpty) {
                                      return tr(
                                        'Please enter type of assistance',
                                        'يرجى إدخال نوع المساعدة',
                                      );
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _selectLocation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF4F4F4),
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    alignment: isArabic
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.place, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _locationController.text.isEmpty
                                              ? tr(
                                                  'Select Location',
                                                  'اختيار الموقع',
                                                )
                                              : _locationController.text,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: isArabic
                                              ? TextAlign.right
                                              : TextAlign.left,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSignUp,
                                  style: _mainButtonStyle(),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          tr('Sign Up', 'تسجيل'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    tr('Have an account?', 'لديك حساب؟'),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  TextButton(
                                    style: _linkButtonStyle(),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      tr('Login', 'تسجيل الدخول'),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _languageButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
