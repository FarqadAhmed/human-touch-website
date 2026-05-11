import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'Login_page.dart';
import 'SignUpPatient_page.dart';
import 'SignUpCompanion_page.dart';
import 'SignUpVolunteer_page.dart';
import 'app_settings_store.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool get isArabic => AppSettingsStore.instance.isArabic;

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
    super.dispose();
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

  Widget _buildRoleButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: _mainButtonStyle(),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _languageButton() {
    return Positioned(
      top: 10,
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
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
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
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          tr('Sign Up', 'إنشاء حساب'),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildRoleButton(
                        text: tr('Patient', 'مريض'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPatientPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildRoleButton(
                        text: tr('Companion', 'مرافق'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpCompanionPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildRoleButton(
                        text: tr('Volunteer', 'متطوع'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpVolunteerPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
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
                                  builder: (context) => const LoginPage(),
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
                _languageButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
