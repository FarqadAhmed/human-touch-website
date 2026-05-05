import 'dart:math';
import 'package:flutter/material.dart';
import 'Login_page.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _codeController1 = TextEditingController();
  final TextEditingController _codeController2 = TextEditingController();
  final TextEditingController _codeController3 = TextEditingController();
  final TextEditingController _codeController4 = TextEditingController();
  final TextEditingController _codeController5 = TextEditingController();

  final FocusNode _codeFocus1 = FocusNode();
  final FocusNode _codeFocus2 = FocusNode();
  final FocusNode _codeFocus3 = FocusNode();
  final FocusNode _codeFocus4 = FocusNode();
  final FocusNode _codeFocus5 = FocusNode();

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;
  bool _isLoading = false;

  int _currentStep = 0;
  String _generatedCode = '';

  String _passwordText = '';

  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordText);
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordText);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordText);
  bool get _hasSymbol => RegExp(r'[@#$!]').hasMatch(_passwordText);
  bool get _hasMinLength => _passwordText.length >= 8;

  @override
  void dispose() {
    _emailController.dispose();

    _codeController1.dispose();
    _codeController2.dispose();
    _codeController3.dispose();
    _codeController4.dispose();
    _codeController5.dispose();

    _codeFocus1.dispose();
    _codeFocus2.dispose();
    _codeFocus3.dispose();
    _codeFocus4.dispose();
    _codeFocus5.dispose();

    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
      _newPasswordController.text = _passwordText;
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
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      isDense: true,
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 18,
        color: Colors.black87,
        fontWeight: FontWeight.normal,
      ),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
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
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.fromLTRB(12, 5, 12, 0),
      child: child,
    );
  }

  String _createVerificationCode() {
    final random = Random();
    return List.generate(5, (_) => random.nextInt(10)).join();
  }

  String _enteredCode() {
    return _codeController1.text +
        _codeController2.text +
        _codeController3.text +
        _codeController4.text +
        _codeController5.text;
  }

  void _goBack() {
    if (_currentStep == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _continueFromEmail() async {
    FocusScope.of(context).unfocus();

    if (!_emailFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    _generatedCode = _createVerificationCode();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _currentStep = 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Verification code sent to ${_emailController.text.trim()}',
        ),
      ),
    );

    debugPrint('Generated verification code: $_generatedCode');
  }

  void _clearCodeFields() {
    _codeController1.clear();
    _codeController2.clear();
    _codeController3.clear();
    _codeController4.clear();
    _codeController5.clear();
  }

  Future<void> _continueFromCode() async {
    FocusScope.of(context).unfocus();

    final enteredCode = _enteredCode();

    if (enteredCode.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the full verification code'),
        ),
      );
      return;
    }

    setState(() {
      _currentStep = 2;
    });
  }

  Future<void> _continueFromPassword() async {
    FocusScope.of(context).unfocus();

    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _currentStep = 3;
    });
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Widget _buildStepHeader({
    required String title,
    String? subtitle,
    bool showLogo = true,
  }) {
    return Column(
      children: [
        if (showLogo)
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
        Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ],
    );
  }

  Widget _buildContinueButton({
    required VoidCallback? onPressed,
    String text = 'Continue',
    double height = 49,
    double radius = 100,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey.shade400;
            }
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
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
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

  Widget _buildCodeBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required FocusNode? nextFocus,
    required FocusNode? previousFocus,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        autofocus: false,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        onChanged: (value) {
          if (value.length == 1 && nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          } else if (value.isEmpty && previousFocus != null) {
            FocusScope.of(context).requestFocus(previousFocus);
          }
        },
      ),
    );
  }

  Widget _buildStepEmail() {
    return Form(
      key: _emailFormKey,
      child: Column(
        children: [
          _buildStepHeader(
            title: 'Forgot Password',
            subtitle: 'Enter your email to reset your password.',
          ),
          const SizedBox(height: 30),
          _buildFieldContainer(
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                label: 'Enter your email',
                prefixIcon: Icons.mail_outline_rounded,
              ),
              style: const TextStyle(fontSize: 16),
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
            ),
          ),
          const SizedBox(height: 30),
          _buildContinueButton(
            onPressed: _isLoading ? null : _continueFromEmail,
          ),
        ],
      ),
    );
  }

  Widget _buildStepCode() {
    return Column(
      children: [
        _buildStepHeader(
          title: 'Enter Verification Code',
          subtitle: 'We have sent the verification code to your email',
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCodeBox(
              controller: _codeController1,
              focusNode: _codeFocus1,
              nextFocus: _codeFocus2,
              previousFocus: null,
            ),
            const SizedBox(width: 10),
            _buildCodeBox(
              controller: _codeController2,
              focusNode: _codeFocus2,
              nextFocus: _codeFocus3,
              previousFocus: _codeFocus1,
            ),
            const SizedBox(width: 10),
            _buildCodeBox(
              controller: _codeController3,
              focusNode: _codeFocus3,
              nextFocus: _codeFocus4,
              previousFocus: _codeFocus2,
            ),
            const SizedBox(width: 10),
            _buildCodeBox(
              controller: _codeController4,
              focusNode: _codeFocus4,
              nextFocus: _codeFocus5,
              previousFocus: _codeFocus3,
            ),
            const SizedBox(width: 10),
            _buildCodeBox(
              controller: _codeController5,
              focusNode: _codeFocus5,
              nextFocus: null,
              previousFocus: _codeFocus4,
            ),
          ],
        ),
        const SizedBox(height: 30),
        _buildContinueButton(
          onPressed: _continueFromCode,
          height: 56,
          radius: 4,
        ),
      ],
    );
  }

  Widget _buildStepNewPassword() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildStepHeader(title: 'Enter New Password'),
          const SizedBox(height: 10),
          _buildFieldContainer(
            child: TextFormField(
              controller: _newPasswordController,
              focusNode: _newPasswordFocusNode,
              obscureText: _obscurePassword1,
              decoration: _inputDecoration(
                label: 'New Password',
                prefixIcon: Icons.lock_outlined,
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      _obscurePassword1 = !_obscurePassword1;
                    });
                  },
                  child: Icon(
                    _obscurePassword1
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
                  return 'Please enter new password';
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
            ),
          ),

          if (_passwordText.isNotEmpty) ...[
            const SizedBox(height: 8),
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
                _passwordRequirement('At least one number (0-9)', _hasNumber),
                _passwordRequirement('At least one symbol (@#\$!)', _hasSymbol),
                _passwordRequirement('At least 8 characters', _hasMinLength),
              ],
            ),
          ],

          const SizedBox(height: 6),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _generateStrongPassword,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text(
                'Generate strong password',
                style: TextStyle(fontSize: 13),
              ),
              style: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                minimumSize: WidgetStateProperty.all(Size.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: WidgetStateProperty.all(
                  const Color(0xFF025590),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          _buildFieldContainer(
            child: TextFormField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              obscureText: _obscurePassword2,
              decoration: _inputDecoration(
                label: 'Confirm Password',
                prefixIcon: Icons.lock_outlined,
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      _obscurePassword2 = !_obscurePassword2;
                    });
                  },
                  child: Icon(
                    _obscurePassword2
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
                  return 'Please confirm password';
                }
                if (text != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 30),
          _buildContinueButton(onPressed: _continueFromPassword),
        ],
      ),
    );
  }

  Widget _buildStepSuccess() {
    return Column(
      children: [
        const SizedBox(height: 110),
        const Icon(
          Icons.check_circle_outlined,
          color: Color(0xFF46DE2D),
          size: 150,
        ),
        const SizedBox(height: 10),
        const Text(
          'Password reset successfully',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 30),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            'You have successfully reset your password. Please use your new password when you\'re logging in.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _goToLogin,
            style: ButtonStyle(
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
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStepEmail();
      case 1:
        return _buildStepCode();
      case 2:
        return _buildStepNewPassword();
      case 3:
        return _buildStepSuccess();
      default:
        return _buildStepEmail();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showBackArrow = _currentStep != 3;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              if (showBackArrow)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: IconButton(
                      onPressed: _goBack,
                      style: ButtonStyle(
                        overlayColor: WidgetStateProperty.resolveWith<Color?>((
                          states,
                        ) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.grey.withOpacity(0.30);
                          }
                          return null;
                        }),
                      ),
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
                  child: _buildCurrentStep(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
