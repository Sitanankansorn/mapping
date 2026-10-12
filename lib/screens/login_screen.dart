import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import '../utils/validators.dart';
import '../state/user_profile_provider.dart';
import '../services/firebase_service.dart';

/// Login screen with real credential verification, denial on incorrect password,
/// shake animation on authentication failure, and quick password recovery.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl =
      TextEditingController(text: 's6707012660077@email.kmutnb.ac.th');
  final _passCtrl = TextEditingController(text: 'Bangkok2026!');
  bool _obscure = true;
  bool _loading = false;
  String? _authError;
  int _failedAttempts = 0;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _shakeCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _authError = null;
    });

    // Simulate authentic network handshake latency
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    final userScope = UserProfileScope.of(context);
    bool isValid = false;

    // 1. Try Firebase Authentication
    try {
      final credential = await FirebaseService.instance.signIn(
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
      if (credential != null && credential.user != null) {
        isValid = true;
        await userScope.syncFromFirebase();
      }
    } catch (_) {
      // Continue to local verification fallback
    }

    // 2. Local verification fallback for KMUTNB account
    if (!isValid) {
      isValid = userScope.verifyCredentials(_emailCtrl.text, _passCtrl.text);
    }

    if (!mounted) return;

    if (!isValid) {
      // ── ACCESS DENIED: WRONG PASSWORD OR EMAIL ───────────────────
      setState(() {
        _loading = false;
        _failedAttempts++;
        _authError =
            'Access Denied: The password entered is incorrect for this account.';
      });
      _shakeCtrl.forward(from: 0.0);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Access Denied: Wrong Password (Attempt $_failedAttempts)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return; // Stop execution! Denied!
    }

    // ── ACCESS GRANTED ───────────────────────────────────────────
    setState(() {
      _loading = false;
      _authError = null;
      _failedAttempts = 0;
    });

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    final userProfile = UserProfileScope.of(context).profile;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: mq.size.width > 600 ? mq.size.width * 0.22 : 24,
                vertical: 24,
              ),
              child: AnimatedBuilder(
                animation: _shakeAnim,
                builder: (ctx, child) {
                  final offset =
                      math.sin(_shakeCtrl.value * math.pi * 4) * 8.0;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Brand Logo / Thailand Emblem ────────────
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [cs.primary, cs.tertiary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.35),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.map_rounded,
                          size: 46,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Thailand Mapping',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Thailand Explorer & Navigation 🇹🇭',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFF59E0B).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.32),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department_rounded,
                                size: 14, color: Color(0xFFF59E0B)),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Firebase: s6707012660077@email.kmutnb.ac.th',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF59E0B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Access Denied Error Banner ───────────────
                      if (_authError != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cs.errorContainer.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cs.error.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.gpp_bad_rounded,
                                      color: cs.error, size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Access Denied',
                                    style: TextStyle(
                                      color: cs.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Attempt $_failedAttempts',
                                    style: TextStyle(
                                      color: cs.error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _authError!,
                                style: TextStyle(
                                  color: cs.onErrorContainer,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                spacing: 8,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      _passCtrl.text =
                                          userProfile.registeredPassword;
                                      setState(() => _authError = null);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: cs.primary,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 30),
                                    ),
                                    child: const Text('Autofill Valid Password'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                        context, '/forgot-password'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: cs.error,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 30),
                                    ),
                                    child: const Text('Reset Password'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      // ── Email Field ──────────────────────────────
                      AppTextField(
                        controller: _emailCtrl,
                        label: 'Email Address',
                        hint: 'sarawut.t@bangkokmap.th',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: Validators.email,
                        onChanged: (_) {
                          if (_authError != null) {
                            setState(() => _authError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Password Field ───────────────────────────
                      AppTextField(
                        controller: _passCtrl,
                        label: 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: Validators.password,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                        onChanged: (_) {
                          if (_authError != null) {
                            setState(() => _authError = null);
                          }
                        },
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 6),

                      // ── Forgot Password Button ───────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.help_outline_rounded,
                              size: 16),
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          label: const Text(
                            'Forgot password?',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Sign-in Button ───────────────────────────
                      PrimaryButton(
                        label: 'Sign In to Explorer',
                        isLoading: _loading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 16),

                      // ── Registered Credentials Demo Hint ─────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.key_rounded,
                                size: 16, color: cs.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Password: ${userProfile.registeredPassword}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurfaceVariant,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _passCtrl.text =
                                    userProfile.registeredPassword;
                                setState(() => _authError = null);
                              },
                              child: Text(
                                'Tap to paste',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Divider ──────────────────────────────────
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or continue with',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // ── Social buttons ───────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _SocialButton(
                              icon: Icons.g_mobiledata_rounded,
                              label: 'Google',
                              onTap: () {
                                _emailCtrl.text = userProfile.email;
                                _passCtrl.text =
                                    userProfile.registeredPassword;
                                _submit();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SocialButton(
                              icon: Icons.apple_rounded,
                              label: 'Apple',
                              onTap: () {
                                _emailCtrl.text = userProfile.email;
                                _passCtrl.text =
                                    userProfile.registeredPassword;
                                _submit();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Go to sign-up ────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/signup'),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      icon: Icon(icon, size: 22),
      label: Text(label),
    );
  }
}
