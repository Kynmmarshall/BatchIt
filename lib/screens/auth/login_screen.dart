import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/widgets/auth/auth_screen_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _savePassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final auth = context.read<AuthProvider>();
      await auth.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(context, AppRoutes.shell);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final errorText = _extractErrorMessage(e, l10n.errorMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorText),
          behavior: SnackBarBehavior.fixed,
        ),
      );
    }
  }

  /// Extract specific error message from exception, falling back to generic.
  /// Handles both simple string errors and field-specific error objects.
  String _extractErrorMessage(Object error, String fallback) {
    final errorStr = error.toString();
    
    // Handle ApiException with detailed error body
    if (errorStr.contains('ApiException:')) {
      // Try to extract message from "ApiException: [statusCode] message"
      final parts = errorStr.split('] ');
      if (parts.length > 1) {
        var message = parts[1];
        // If it looks like JSON, try to parse it for field errors
        if (message.startsWith('{')) {
          try {
            final decoded = jsonDecode(message) as Map<String, dynamic>;
            // Check for field-specific errors
            if (decoded.containsKey('email') && decoded['email'] is List) {
              return (decoded['email'] as List).first.toString();
            }
            if (decoded.containsKey('password') && decoded['password'] is List) {
              return (decoded['password'] as List).first.toString();
            }
            if (decoded.containsKey('non_field_errors') && decoded['non_field_errors'] is List) {
              return (decoded['non_field_errors'] as List).first.toString();
            }
            // Fallback: return first available error
            for (final key in decoded.keys) {
              if (decoded[key] is List && (decoded[key] as List).isNotEmpty) {
                return decoded[key][0].toString();
              }
            }
          } catch (_) {
            // If parsing fails, use the raw message
            return message;
          }
        }
        return message;
      }
    }
    
    if (errorStr.isNotEmpty && errorStr != 'Exception') {
      return errorStr;
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();

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
              TextButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.shell);
                },
                style: TextButton.styleFrom(
                  foregroundColor: primaryText,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: const BorderSide(color: Color(0xFFD7DDE5)),
                  ),
                ),
                icon: const Icon(Icons.person_outline_rounded, size: 18),
                label: Text(l10n.guestLogin),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.welcomeBack,
                style: TextStyle(
                  color: primaryText,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  height: 1.06,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.loginSubtitle,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 28),
              _LoginField(
                controller: _emailController,
                hintText: l10n.emailAddress,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
                backgroundColor: fieldBackground,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.email;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _LoginField(
                controller: _passwordController,
                hintText: l10n.password,
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                backgroundColor: fieldBackground,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return l10n.password;
                  }
                  return null;
                },
                onSuffixTap: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: _savePassword,
                          onChanged: (value) {
                            setState(() {
                              _savePassword = value ?? false;
                            });
                          },
                          side: const BorderSide(color: Color(0xFFD7DDE5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.savePassword,
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: const Color(0xFFFF6A00),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(l10n.forgotPassword),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: auth.isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryButton,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(29),
                    ),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          l10n.signInCta,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE0E4EA))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      l10n.orContinueWith,
                      style: const TextStyle(
                        color: primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE0E4EA))),
                ],
              ),
              const SizedBox(height: 22),
              _SocialButton(
                label: l10n.continueWithGoogle,
                backgroundColor: fieldBackground,
                icon: const _GoogleMark(),
                textColor: secondaryText,
                onPressed: () async {
                  debugPrint('[BatchIt][login] Google button pressed');
                  try {
                    await context.read<AuthProvider>().loginWithGoogle();
                    if (!context.mounted) {
                      return;
                    }
                    debugPrint('[BatchIt][login] Google login completed, navigating to shell');
                    Navigator.pushReplacementNamed(context, AppRoutes.shell);
                  } catch (e) {
                    debugPrint('[BatchIt][login] Google login failed: $e');
                    if (!context.mounted) return;
                    final l10n = AppLocalizations.of(context)!;
                    final errorText = _extractErrorMessage(e, l10n.errorMessage);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorText),
                        behavior: SnackBarBehavior.fixed,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 18),
              Center(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      color: secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(text: '${l10n.didntHaveAnAccount} '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: Text(
                            '${l10n.signUpCta}.',
                            style: TextStyle(
                              color: primaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.backgroundColor,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Color backgroundColor;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF93A2B4),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF93A2B4)),
          suffixIcon: suffixIcon == null
              ? null
              : IconButton(
                  onPressed: onSuffixTap,
                  icon: Icon(suffixIcon, color: const Color(0xFF93A2B4)),
                ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.onPressed,
  });

  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: TextButton.icon(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          icon: icon,
          label: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4285F4),
      ),
    );
  }
}
