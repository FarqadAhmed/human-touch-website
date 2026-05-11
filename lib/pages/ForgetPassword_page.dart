import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Login_page.dart';
import 'app_settings_store.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;

  bool get isArabic => AppSettingsStore.instance.isArabic;
  bool get isDarkMode => AppSettingsStore.instance.isDarkMode;

  Color get backgroundColor => isDarkMode ? Colors.black : Colors.white;

  Color get fieldColor =>
      isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F4);

  Color get textColor => isDarkMode ? Colors.white : Colors.black;

  Color get subTextColor => isDarkMode ? Colors.white70 : Colors.black87;

  String tr(String en, String ar) => isArabic ? ar : en;

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
    _emailController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      isDense: true,
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 18,
        color: subTextColor,
        fontWeight: FontWeight.normal,
      ),
      prefixIcon:
          prefixIcon != null ? Icon(prefixIcon, color: subTextColor) : null,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Widget _buildFieldContainer({required Widget child, double height = 56}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(4),
        border: isDarkMode ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      padding: const EdgeInsets.fromLTRB(12, 5, 12, 0),
      child: child,
    );
  }

  Future<void> _sendResetEmail() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _emailSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Password reset link sent to your email',
              'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
            ),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = tr(
        'Failed to send reset email.',
        'فشل إرسال بريد إعادة التعيين.',
      );

      if (e.code == 'invalid-email') {
        message = tr(
          'Please enter a valid email.',
          'يرجى إدخال بريد إلكتروني صحيح.',
        );
      } else if (e.code == 'user-not-found') {
        message = tr(
          'No account found with this email.',
          'لا يوجد حساب بهذا البريد الإلكتروني.',
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
        SnackBar(
          content: Text(
            tr('Error: $e', 'حدث خطأ: $e'),
          ),
        ),
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
                color: Colors.black.withOpacity(isDarkMode ? 0.35 : 0.15),
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

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo.png',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            tr('Forgot Password', 'نسيت كلمة المرور'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w300,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tr(
              'Enter your email and we will send you a password reset link.',
              'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: subTextColor),
          ),
          const SizedBox(height: 30),
          _buildFieldContainer(
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              decoration: _inputDecoration(
                label: tr('Enter your email', 'أدخل بريدك الإلكتروني'),
                prefixIcon: Icons.mail_outline_rounded,
              ),
              style: TextStyle(fontSize: 16, color: textColor),
              validator: (value) {
                final text = (value ?? '').trim();

                if (text.isEmpty) {
                  return tr(
                    'Please enter your email',
                    'يرجى إدخال بريدك الإلكتروني',
                  );
                }

                if (!text.contains('@') || !text.contains('.')) {
                  return tr(
                    'Please enter a valid email',
                    'يرجى إدخال بريد إلكتروني صحيح',
                  );
                }

                return null;
              },
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 49,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87CEEB),
                disabledBackgroundColor: Colors.grey.shade400,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
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
                      tr('Send Reset Link', 'إرسال رابط إعادة التعيين'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    final email = _emailController.text.trim();

    return Column(
      children: [
        const SizedBox(height: 110),
        const Icon(
          Icons.mark_email_read_outlined,
          color: Color(0xFF46DE2D),
          size: 140,
        ),
        const SizedBox(height: 20),
        Text(
          tr('Check your email', 'تحقق من بريدك الإلكتروني'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            tr(
              'We sent a password reset link to:\n$email\n\nOpen your email and follow the link to create a new password.',
              'أرسلنا رابط إعادة تعيين كلمة المرور إلى:\n$email\n\nافتح بريدك الإلكتروني واتبع الرابط لإنشاء كلمة مرور جديدة.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _goToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF87CEEB),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              tr('Back to Login', 'الرجوع إلى تسجيل الدخول'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isLoading ? null : _sendResetEmail,
          child: const Text(
            'Resend Email',
            style: TextStyle(
              color: Color(0xFF025590),
              fontSize: 14,
            ),
          ),
        ),
      ],
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
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    if (!_emailSent)
                      Align(
                        alignment: isArabic
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: IconButton(
                            onPressed: _goToLogin,
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
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                        child: _emailSent
                            ? _buildSuccessMessage()
                            : _buildEmailForm(),
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
