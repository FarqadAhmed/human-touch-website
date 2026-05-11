import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'location_picker_page.dart';
import 'Dashboard_page.dart';
import 'Login_page.dart';
import 'SignUp_page.dart';
import 'app_settings_store.dart';

class SignUpPatientPage extends StatefulWidget {
  const SignUpPatientPage({super.key});

  @override
  State<SignUpPatientPage> createState() => _SignUpPatientPageState();
}

class _SignUpPatientPageState extends State<SignUpPatientPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _multipleDisabilitiesController =
      TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _ageFocusNode = FocusNode();
  final FocusNode _multipleDisabilitiesFocusNode = FocusNode();

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

  String? _selectedDisability;
  String? _selectedGender;

  double? _selectedLatitude;
  double? _selectedLongitude;

  final List<String> _disabilityOptions = const [
    'Physical Disability',
    'Hearing Disability',
    'Visual Disability',
    'Intellectual Disability',
    'Multiple Disabilities',
  ];

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

  String _disabilityText(String value) {
    switch (value) {
      case 'Physical Disability':
        return tr('Physical Disability', 'إعاقة حركية');
      case 'Hearing Disability':
        return tr('Hearing Disability', 'إعاقة سمعية');
      case 'Visual Disability':
        return tr('Visual Disability', 'إعاقة بصرية');
      case 'Intellectual Disability':
        return tr('Intellectual Disability', 'إعاقة ذهنية');
      case 'Multiple Disabilities':
        return tr('Multiple Disabilities', 'إعاقات متعددة');
      default:
        return value;
    }
  }

  @override
  void dispose() {
    AppSettingsStore.instance.removeListener(_onLanguageChanged);

    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _multipleDisabilitiesController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _ageFocusNode.dispose();
    _multipleDisabilitiesFocusNode.dispose();

    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
      ),
    );
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
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 14,
        color: Color(0xFF025590),
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

    if (_selectedDisability == null || _selectedDisability!.isEmpty) {
      _showMessage(
        tr('Please select type of disability', 'يرجى اختيار نوع الإعاقة'),
      );
      return;
    }

    if (_selectedDisability == 'Multiple Disabilities' &&
        _multipleDisabilitiesController.text.trim().isEmpty) {
      _showMessage(
        tr('Please enter the disabilities', 'يرجى إدخال الإعاقات'),
      );
      return;
    }

    if (_selectedGender == null || _selectedGender!.isEmpty) {
      _showMessage(tr('Please select gender', 'يرجى اختيار الجنس'));
      return;
    }

    if (_locationController.text.trim().isEmpty ||
        _selectedLatitude == null ||
        _selectedLongitude == null) {
      _showMessage(tr('Please select location', 'يرجى اختيار الموقع'));
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
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
    final bool showMultipleDisabilitiesField =
        _selectedDisability == 'Multiple Disabilities';

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
                Align(
                  alignment:
                      isArabic ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
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
                                const SizedBox(height: 20),
                                Center(
                                  child: Text(
                                    tr('Sign Up Patient', 'تسجيل المريض'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
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
                                const SizedBox(height: 8),
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
                                const SizedBox(height: 8),
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
                                      label: tr('Phone Number', 'رقم الهاتف'),
                                    ),
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
                                const SizedBox(height: 8),
                                Align(
                                  alignment: isArabic
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: TextButton.icon(
                                    style: _linkButtonStyle(),
                                    onPressed: _generateStrongPassword,
                                    icon: const Icon(Icons.auto_awesome,
                                        size: 18),
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
                                            _obscurePassword =
                                                !_obscurePassword;
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
                                const SizedBox(height: 6),
                                if (_passwordText.isNotEmpty)
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
                                const SizedBox(height: 8),
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
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context)
                                          .requestFocus(_ageFocusNode);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildFieldContainer(
                                  child: TextFormField(
                                    controller: _ageController,
                                    focusNode: _ageFocusNode,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    textAlign: isArabic
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    decoration: _inputDecoration(
                                      label: tr('Age', 'العمر'),
                                    ),
                                    validator: (value) {
                                      final text = (value ?? '').trim();
                                      if (text.isEmpty) {
                                        return tr(
                                          'Please enter age',
                                          'يرجى إدخال العمر',
                                        );
                                      }

                                      final int? age = int.tryParse(text);
                                      if (age == null) {
                                        return tr(
                                          'Please enter a valid age',
                                          'يرجى إدخال عمر صحيح',
                                        );
                                      }
                                      if (age <= 0) {
                                        return tr(
                                          'Age must be greater than 0',
                                          'يجب أن يكون العمر أكبر من صفر',
                                        );
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildFieldContainer(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedDisability,
                                    decoration: _inputDecoration(
                                      label: tr(
                                        'Type of Disability',
                                        'نوع الإعاقة',
                                      ),
                                    ),
                                    items: _disabilityOptions
                                        .map(
                                          (option) => DropdownMenuItem<String>(
                                            value: option,
                                            child:
                                                Text(_disabilityText(option)),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDisability = value;
                                        if (_selectedDisability !=
                                            'Multiple Disabilities') {
                                          _multipleDisabilitiesController
                                              .clear();
                                        }
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                    ),
                                  ),
                                ),
                                if (showMultipleDisabilitiesField) ...[
                                  const SizedBox(height: 8),
                                  _buildFieldContainer(
                                    height: 78,
                                    child: TextFormField(
                                      controller:
                                          _multipleDisabilitiesController,
                                      focusNode: _multipleDisabilitiesFocusNode,
                                      maxLines: 2,
                                      textAlign: isArabic
                                          ? TextAlign.right
                                          : TextAlign.left,
                                      decoration: _inputDecoration(
                                        label: tr(
                                          'Write the disabilities',
                                          'اكتب الإعاقات',
                                        ),
                                      ),
                                      validator: (value) {
                                        if (showMultipleDisabilitiesField &&
                                            (value ?? '').trim().isEmpty) {
                                          return tr(
                                            'Please enter the disabilities',
                                            'يرجى إدخال الإعاقات',
                                          );
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                _buildFieldContainer(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedGender,
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
                                const SizedBox(height: 8),
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
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _handleSignUp,
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
