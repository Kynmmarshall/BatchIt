import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/auth/verification_code_args.dart';
import 'package:batchit/models/auth/registration_data.dart';
import 'package:batchit/services/auth_service.dart';
import 'package:batchit/widgets/auth/auth_screen_shell.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      await _authService.sendVerificationCode(email);

      if (!mounted) return;

      final regData = RegistrationData(
        email: email,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      Navigator.pushNamed(
        context,
        AppRoutes.verification,
        arguments: VerificationCodeArgs(
          maskedEmail: _maskEmail(email),
          email: email,
          registrationData: regData,
        ),
      );
    } catch (e) {
      _showError(_extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final local = parts[0];
    final domain = parts[1];
    if (local.length <= 2) return '*@$domain';
    return '${local.substring(0, 2)}${'*' * (local.length - 2)}@$domain';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  String _extractErrorMessage(Object error) {
    final errorStr = error.toString();
    if (errorStr.contains('ApiException:')) {
      final parts = errorStr.split('] ');
      if (parts.length > 1) {
        var message = parts[1];
        if (message.startsWith('{')) {
          try {
            final decoded = jsonDecode(message) as Map<String, dynamic>;
            for (final key in decoded.keys) {
              if (decoded[key] is List && (decoded[key] as List).isNotEmpty) {
                return decoded[key][0].toString();
              }
            }
          } catch (_) {
            return message;
          }
        }
        return message;
      }
    }
    return errorStr.isNotEmpty ? errorStr : 'An error occurred. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const fieldBackground = Color(0xFFF1F1F1);
    const primaryText = Color(0xFF1E2B46);
    const secondaryText = Color(0xFF91A0B2);
    const primaryButton = Color(0xFF1A2745);

    return AuthScreenShell(
      childBuilder: (context, constraints) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.registerNow,
                style: TextStyle(
                  color: primaryText,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1.06,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.registerSubtitle,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              _RegisterField(
                controller: _emailController,
                hintText: l10n.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
                backgroundColor: fieldBackground,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Email is required';
                  if (!value.contains('@')) return 'Please enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _RegisterField(
                controller: _usernameController,
                hintText: 'Username',
                prefixIcon: Icons.person_outline_rounded,
                backgroundColor: fieldBackground,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Username is required';
                  if (value.length < 3) return 'Username must be at least 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RegisterField(
                      controller: _firstNameController,
                      hintText: 'First Name',
                      prefixIcon: Icons.person_outline_rounded,
                      backgroundColor: fieldBackground,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Required';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RegisterField(
                      controller: _lastNameController,
                      hintText: 'Last Name',
                      prefixIcon: Icons.person_outline_rounded,
                      backgroundColor: fieldBackground,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Required';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _RegisterField(
                controller: _passwordController,
                hintText: l10n.password,
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                obscureText: _obscurePassword,
                backgroundColor: fieldBackground,
                onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Password is required';
                  if (value.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _RegisterField(
                controller: _confirmPasswordController,
                hintText: l10n.confirmPassword,
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                obscureText: _obscureConfirm,
                backgroundColor: fieldBackground,
                onSuffixTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please confirm your password';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryButton,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l10n.signUpCta, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE0E4EA))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(l10n.orContinueWith, style: const TextStyle(color: primaryText, fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE0E4EA))),
                ],
              ),
              const SizedBox(height: 16),
              _SocialButton(label: l10n.continueWithGoogle, backgroundColor: fieldBackground, icon: const _GoogleMark()),
              const SizedBox(height: 12),
              const Spacer(),
              const SizedBox(height: 16),
              Center(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(color: secondaryText, fontSize: 14, fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(text: '${l10n.alreadyHaveAnAccount} '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                          child: Text('${l10n.signInCta}.', style: TextStyle(color: primaryText, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RegisterField extends StatelessWidget {
  const _RegisterField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.backgroundColor,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.onSuffixTap,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Color backgroundColor;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.68),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF93A2B4), fontSize: 16, fontWeight: FontWeight.w500),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF93A2B4)),
          suffixIcon: suffixIcon == null
              ? null
              : IconButton(onPressed: onSuffixTap, icon: Icon(suffixIcon, color: const Color(0xFF93A2B4))),
          errorStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon, required this.backgroundColor});

  final String label;
  final Widget icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.35)),
        ),
        child: TextButton.icon(
          onPressed: () {},
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF93A2B4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          icon: icon,
          label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const Text('G', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF4285F4)));
  }
}
