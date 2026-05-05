import 'dart:math';
import 'package:flutter/material.dart';
import 'location_picker_page.dart';
import 'CompanionDashboard_page.dart';
import 'Login_page.dart';
import 'SignUp_page.dart';
import 'profile_store.dart';

class SignUpCompanionPage extends StatefulWidget {
  const SignUpCompanionPage({super.key});

  @override
  State<SignUpCompanionPage> createState() => _SignUpCompanionPageState();
}

class _SignUpCompanionPageState extends State<SignUpCompanionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final ProfileStore profileStore = ProfileStore.instance;

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _relationshipFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String _passwordText = '';

  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordText);
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordText);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordText);
  bool get _hasSymbol => RegExp(r'[@#$!]').hasMatch(_passwordText);
  bool get _hasMinLength => _passwordText.length >= 8;

  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _relationshipController.dispose();
    _locationController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _relationshipFocusNode.dispose();
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
      setState(() {
        _locationController.text = result['address'] ?? '';
        _selectedLatitude = result['latitude'];
        _selectedLongitude = result['longitude'];
      });
    }
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_locationController.text.trim().isEmpty ||
        _selectedLatitude == null ||
        _selectedLongitude == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select location')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    profileStore.updateName(_nameController.text.trim());
    profileStore.updateEmail(_emailController.text.trim());
    profileStore.updatePhoneNumber(_phoneController.text.trim());
    profileStore.updatePassword(_passwordController.text.trim());
    profileStore.updateUserRole('companion');

    await profileStore.saveProfile();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CompanionDashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back,
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
                        const SizedBox(height: 40),

                        const Center(
                          child: Text(
                            'Sign Up Companion',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        _buildFieldContainer(
                          child: TextFormField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(label: 'Name'),
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_emailFocusNode);
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
                            decoration: _inputDecoration(label: 'Email'),
                            validator: (value) {
                              final text = (value ?? '').trim();

                              if (text.isEmpty) {
                                return 'Please enter your email';
                              }

                              if (!text.contains('@') || !text.contains('.')) {
                                return 'Please enter a valid email';
                              }

                              return null;
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_phoneFocusNode);
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
                            decoration: _inputDecoration(label: 'Phone Number'),
                            validator: (value) {
                              final text = (value ?? '').trim();

                              if (text.isEmpty) {
                                return 'Please enter your phone number';
                              }

                              if (text.length < 8 || text.length > 8) {
                                return 'Please enter a valid phone number';
                              }

                              return null;
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_passwordFocusNode);
                            },
                          ),
                        ),

                        const SizedBox(height: 10),

                        _buildFieldContainer(
                          child: TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              label: 'Password',
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
                                return 'Please enter password';
                              }

                              if (!RegExp(r'[a-z]').hasMatch(text)) {
                                return 'Password must contain at least one lowercase letter';
                              }

                              if (!RegExp(r'[A-Z]').hasMatch(text)) {
                                return 'Password must contain at least one uppercase letter';
                              }

                              if (!RegExp(r'[0-9]').hasMatch(text)) {
                                return 'Password must contain at least one number';
                              }

                              if (!RegExp(r'[@#$!]').hasMatch(text)) {
                                return 'Password must contain at least one symbol (@#\$!)';
                              }

                              if (text.length < 8) {
                                return 'Password must be at least 8 characters';
                              }

                              return null;
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_confirmPasswordFocusNode);
                            },
                          ),
                        ),

                        if (_passwordText.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _passwordRequirement(
                                'At least one lowercase letter (a-z)',
                                _hasLowercase,
                              ),
                              _passwordRequirement(
                                'At least one uppercase letter (A-Z)',
                                _hasUppercase,
                              ),
                              _passwordRequirement(
                                'At least one number (0-9)',
                                _hasNumber,
                              ),
                              _passwordRequirement(
                                'At least one symbol (@#\$!)',
                                _hasSymbol,
                              ),
                              _passwordRequirement(
                                'At least 8 characters',
                                _hasMinLength,
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 6),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            style: _linkButtonStyle(),
                            onPressed: _generateStrongPassword,
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: const Text(
                              'Generate strong password',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        _buildFieldContainer(
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocusNode,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              label: 'Confirm Password',
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
                                ),
                              ),
                            ),
                            validator: (value) {
                              final text = value ?? '';

                              if (text.isEmpty) {
                                return 'Please confirm password';
                              }

                              if (text != _passwordController.text) {
                                return 'Passwords do not match';
                              }

                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 10),

                        _buildFieldContainer(
                          child: TextFormField(
                            controller: _relationshipController,
                            focusNode: _relationshipFocusNode,
                            decoration: _inputDecoration(
                              label: 'Relationship with the patient',
                            ),
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Please enter relationship';
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
                              alignment: Alignment.centerLeft,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.place),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _locationController.text.isEmpty
                                        ? 'Select Location'
                                        : _locationController.text,
                                    overflow: TextOverflow.ellipsis,
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
                                : const Text(
                                    'Sign Up',
                                    style: TextStyle(
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
                            const Text('Have an account?'),
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
                              child: const Text('Login'),
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
      ),
    );
  }
}
