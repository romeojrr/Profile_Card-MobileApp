import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/glass_theme.dart';
import '../models/auth_service.dart';
import '../widgets/glass_card.dart';
import 'main_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Current accent
  Color get _accent => _isSignUp ? Palette.secondary : Palette.primary;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = AuthService();
    String? error;

    try {
      if (_isSignUp) {
        error = await auth.signUp(
          _emailController.text,
          _passwordController.text,
          _nameController.text.trim(),
        );
      } else {
        error = await auth.signIn(
          _emailController.text,
          _passwordController.text,
        );
      }
    } catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    if (error != null) {
      _showErrorDialog(error);
    } else {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text);
      } else {
        await prefs.remove('saved_email');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Palette.border, width: 2.5),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Palette.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Palette.border,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Palette.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Palette.error, width: 2),
                ),
                child: const Icon(Icons.error_outline,
                    color: Palette.error, size: 32),
              ),
              const SizedBox(height: 16),
              Text('Oops!',
                  style: GoogleFonts.lexend(
                    fontSize: 20, fontWeight: FontWeight.w800,
                  )),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 14, color: Palette.textSecondary,
                  )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: BrutalButton(
                  text: 'OK',
                  onPressed: () => Navigator.pop(context),
                  color: Palette.error,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;

    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 42),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // ── Form Card (logo + form inside) ──
                BrutalCard(
                  padding: const EdgeInsets.all(22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // ── Logo (inside card, no shadow) ──
                        Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutBack,
                              width: _isSignUp ? 100 : 120,
                              height: _isSignUp ? 100 : 120,
                              child: ClipOval(
                                child: Image.asset(
                                  'lib/assets/CAPYHUB.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _LoopingTypewriter(
                              text: _isSignUp ? 'Create Account' : 'Welcome Back',
                              style: GoogleFonts.lexend(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Palette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Stay Cozy. Stay Connected.',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Palette.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),

                        // ── Toggle tabs ──
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Palette.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Palette.border, width: 2.5),
                          ),
                          child: Row(
                            children: [
                              _tabButton('SIGN IN', !_isSignUp, Palette.primary),
                              _tabButton('SIGN UP', _isSignUp, Palette.secondary),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // ── Full Name (sign up) ──
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _isSignUp
                              ? Column(
                                  children: [
                                    BrutalTextField(
                                      controller: _nameController,
                                      label: 'Full Name',
                                      prefixIcon: Icons.badge_outlined,
                                      focusColor: accent,
                                      validator: (v) {
                                        if (_isSignUp &&
                                            (v == null || v.trim().isEmpty)) {
                                          return 'Name is required';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        // ── Email ──
                        BrutalTextField(
                          controller: _emailController,
                          label: 'Email',
                          prefixIcon: Icons.email_outlined,
                          focusColor: accent,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!v.contains('@') || !v.contains('.')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // ── Password ──
                        BrutalTextField(
                          controller: _passwordController,
                          label: 'Password',
                          prefixIcon: Icons.lock_outline,
                          focusColor: accent,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Palette.textSecondary,
                              size: 20,
                            ),
                            onPressed: () => setState(() =>
                                _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Password is required';
                            }
                            if (_isSignUp && v.length < 8) {
                              return 'Minimum 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: accent,
                                side: const BorderSide(color: Palette.border, width: 2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v ?? false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Remember Me',
                                style: GoogleFonts.dmSans(
                                    fontSize: 13, color: Palette.textSecondary, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // ── Submit ──
                        SizedBox(
                          width: double.infinity,
                          child: BrutalButton(
                            text: _isSignUp ? 'CREATE ACCOUNT' : 'SIGN IN',
                            icon: _isSignUp
                                ? Icons.person_add
                                : Icons.login_rounded,
                            onPressed: () => _submit(),
                            color: accent,
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: () => setState(() => _isSignUp = !_isSignUp),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Palette.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: _isSignUp
                              ? 'Already have an account? '
                              : "Don't have an account? ",
                        ),
                        TextSpan(
                          text: _isSignUp ? 'Sign In' : 'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String label, bool active, Color activeColor) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isSignUp = label == 'SIGN UP'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? activeColor.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: active ? activeColor : Palette.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoopingTypewriter extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const _LoopingTypewriter({required this.text, this.style});

  @override
  State<_LoopingTypewriter> createState() => _LoopingTypewriterState();
}

class _LoopingTypewriterState extends State<_LoopingTypewriter> {
  String _displayedString = "";
  int _currentIndex = 0;
  Timer? _typingTimer;
  Timer? _cursorTimer;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _startCursorBlink();
  }

  @override
  void didUpdateWidget(_LoopingTypewriter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _typingTimer?.cancel();
      _currentIndex = 0;
      _displayedString = "";
      _startTyping();
    }
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _currentIndex++;
          _displayedString = widget.text.substring(0, _currentIndex);
        });
      } else {
        _typingTimer?.cancel();
        _cursorTimer?.cancel();
        if (mounted) setState(() => _showCursor = false);
      }
    });
  }

  void _startCursorBlink() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedString + (_showCursor ? "|" : " "),
      style: widget.style,
    );
  }
}
