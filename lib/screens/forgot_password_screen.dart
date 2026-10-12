import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import '../utils/validators.dart';
import '../state/user_profile_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 0; // 0: Enter email/phone, 1: Enter OTP, 2: Reset Password, 3: Success
  final _emailCtrl = TextEditingController(text: 'sarawut.t@bangkokmap.th');
  final _phoneCtrl = TextEditingController(text: '+66 81 892 3456');
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  bool _isPhoneMode = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  int _resendCountdown = 59;
  Timer? _timer;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendCountdown = 59);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendCode() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _currentStep = 1;
    });
    _startTimer();
    _otpFocusNodes[0].requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isPhoneMode
              ? 'Verification code sent to ${_phoneCtrl.text}'
              : 'Reset code sent to ${_emailCtrl.text}',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the complete 4-digit code (e.g. 1 2 3 4)'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _currentStep = 2;
    });
  }

  Future<void> _resetPassword() async {
    final pass = _newPassCtrl.text;
    final conf = _confirmPassCtrl.text;
    final passErr = Validators.password(pass);
    if (passErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(passErr),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (pass != conf) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    UserProfileScope.of(context).updatePassword(pass);
    setState(() {
      _isLoading = false;
      _currentStep = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_currentStep > 0 && _currentStep < 3) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: mq.size.width > 600 ? mq.size.width * 0.2 : 24,
              vertical: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Top Icon Badge ─────────────────────────────────────
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    _currentStep == 3
                        ? Icons.check_circle_rounded
                        : _currentStep == 2
                            ? Icons.lock_reset_rounded
                            : _currentStep == 1
                                ? Icons.mark_email_read_rounded
                                : Icons.lock_person_rounded,
                    size: 38,
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Stepper Indicator ──────────────────────────────────
                if (_currentStep < 3) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = index <= _currentStep;
                      return Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? cs.primary
                                  : cs.surfaceContainerHigh,
                              border: Border.all(
                                color: isActive
                                    ? cs.primary
                                    : cs.outlineVariant.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? cs.onPrimary
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          if (index < 2)
                            Container(
                              width: 36,
                              height: 3,
                              color: index < _currentStep
                                  ? cs.primary
                                  : cs.surfaceContainerHigh,
                            ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Dynamic Step Content ───────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStepView(cs),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepView(ColorScheme cs) {
    switch (_currentStep) {
      case 0:
        return _buildStep0(cs);
      case 1:
        return _buildStep1(cs);
      case 2:
        return _buildStep2(cs);
      case 3:
      default:
        return _buildStep3(cs);
    }
  }

  // STEP 0: Enter email / phone
  Widget _buildStep0(ColorScheme cs) {
    return Column(
      key: const ValueKey(0),
      children: [
        Text(
          'Forgot Password?',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Select how you would like to receive your security code to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Method Toggle
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isPhoneMode = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_isPhoneMode ? cs.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.email_rounded,
                          size: 18,
                          color: !_isPhoneMode
                              ? cs.onPrimary
                              : cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Email Address',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: !_isPhoneMode
                                ? cs.onPrimary
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isPhoneMode = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _isPhoneMode ? cs.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_iphone_rounded,
                          size: 18,
                          color: _isPhoneMode
                              ? cs.onPrimary
                              : cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SMS Phone',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _isPhoneMode
                                ? cs.onPrimary
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (!_isPhoneMode)
          AppTextField(
            controller: _emailCtrl,
            label: 'Registered Email',
            hint: 'sarawut.t@bangkokmap.th',
            prefixIcon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
          )
        else
          AppTextField(
            controller: _phoneCtrl,
            label: 'Mobile Phone Number',
            hint: '+66 81 892 3456',
            prefixIcon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),

        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Send Recovery Code',
          isLoading: _isLoading,
          onPressed: _sendCode,
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: const Text('Back to Sign In'),
        ),
      ],
    );
  }

  // STEP 1: Enter 4-digit OTP
  Widget _buildStep1(ColorScheme cs) {
    final destination = _isPhoneMode ? _phoneCtrl.text : _emailCtrl.text;
    return Column(
      key: const ValueKey(1),
      children: [
        Text(
          'Verify Security Code',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Please enter the 4-digit code sent to\n$destination',
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(height: 28),

        // 4 OTP Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Container(
              width: 58,
              height: 64,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  fillColor: cs.surfaceContainerHigh,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: cs.primary, width: 2),
                  ),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && index < 3) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (val.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                  if (_otpControllers.every((c) => c.text.isNotEmpty)) {
                    _verifyOtp();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 18),

        // Quick Auto-fill Hint
        GestureDetector(
          onTap: () {
            _otpControllers[0].text = '1';
            _otpControllers[1].text = '2';
            _otpControllers[2].text = '3';
            _otpControllers[3].text = '4';
            _verifyOtp();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  'Tap to auto-fill code: 1234',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Verify Code',
          isLoading: _isLoading,
          onPressed: _verifyOtp,
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive code? ",
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            _resendCountdown > 0
                ? Text(
                    'Resend in ${_resendCountdown}s',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : TextButton(
                    onPressed: _sendCode,
                    child: const Text('Resend Now'),
                  ),
          ],
        ),
      ],
    );
  }

  // STEP 2: Create new password
  Widget _buildStep2(ColorScheme cs) {
    return Column(
      key: const ValueKey(2),
      children: [
        Text(
          'Create New Password',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Your new password must be different from previous passwords.',
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(height: 24),

        AppTextField(
          controller: _newPassCtrl,
          label: 'New Password',
          hint: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureNew,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureNew
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () => setState(() => _obscureNew = !_obscureNew),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),

        AppTextField(
          controller: _confirmPassCtrl,
          label: 'Confirm Password',
          hint: '••••••••',
          prefixIcon: Icons.lock_reset_rounded,
          obscureText: _obscureConfirm,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 18),

        // Live Password Checklist
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _buildRuleRow(
                'At least 8 characters',
                _newPassCtrl.text.length >= 8,
                cs,
              ),
              const SizedBox(height: 8),
              _buildRuleRow(
                'Contains uppercase letter (A-Z)',
                RegExp(r'[A-Z]').hasMatch(_newPassCtrl.text),
                cs,
              ),
              const SizedBox(height: 8),
              _buildRuleRow(
                'Contains at least one number (0-9)',
                RegExp(r'[0-9]').hasMatch(_newPassCtrl.text),
                cs,
              ),
              const SizedBox(height: 8),
              _buildRuleRow(
                'Passwords match',
                _newPassCtrl.text.isNotEmpty &&
                    _newPassCtrl.text == _confirmPassCtrl.text,
                cs,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Reset Password',
          isLoading: _isLoading,
          onPressed: _resetPassword,
        ),
      ],
    );
  }

  Widget _buildRuleRow(String text, bool met, ColorScheme cs) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 18,
          color: met ? const Color(0xFF10B981) : cs.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: met ? cs.onSurface : cs.onSurfaceVariant,
            fontWeight: met ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // STEP 3: Success!
  Widget _buildStep3(ColorScheme cs) {
    return Column(
      key: const ValueKey(3),
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.verified_rounded,
              color: Color(0xFF10B981),
              size: 54,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Password Changed!',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Your account security has been updated successfully. You can now log in with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Sign In Now',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
