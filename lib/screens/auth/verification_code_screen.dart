import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/auth/registration_data.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/services/auth_service.dart';
import 'package:batchit/widgets/auth/auth_screen_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({
    super.key,
    this.maskedEmail = 'sha....@gmail.com',
    this.email,
    this.registrationData,
  });

  final String maskedEmail;
  final String? email;
  final RegistrationData? registrationData;

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  late final List<TextEditingController> _codeControllers;
  late final List<FocusNode> _focusNodes;
  bool _isLoading = false;
  bool _isResending = false;

  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _codeControllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getCode() {
    return _codeControllers.map((c) => c.text).join();
  }

  bool _isCodeComplete() {
    return _getCode().length == 6;
  }

  void _onCodeChanged(int index, String value) {
    if (value.length > 1) {
      _codeControllers[index].text = value[0];
      return;
    }

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {});
  }

  Future<void> _submit() async {
    if (!_isCodeComplete()) {
      _showError('Please enter all 6 digits');
      return;
    }

    // Check if we have registration data (for registration flow)
    if (widget.registrationData == null) {
      _showError('Registration data missing. Please start over.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final code = _getCode();
      final regData = widget.registrationData!;

      // Call register-verify endpoint
      await _authService.registerWithVerification(
        email: regData.email,
        code: code,
        username: regData.username,
        password: regData.password,
        firstName: regData.firstName,
        lastName: regData.lastName,
      );

      if (!mounted) return;

      // Update auth provider to reflect logged-in state
      await context.read<AuthProvider>().loginWithEmail(
        email: regData.email,
        password: regData.password,
      );

      if (!mounted) return;

      // Navigate to main app
      Navigator.pushReplacementNamed(context, AppRoutes.shell);
    } catch (e) {
      _showError(_extractErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      final email = widget.email ?? '';
      if (email.isEmpty) {
        _showError('Email not found');
        return;
      }

      await _authService.sendVerificationCode(email);
      _showSuccess('Code resent to $email');

      // Clear code fields
      for (final controller in _codeControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    } catch (e) {
      _showError(_extractErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: fieldBackground,
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
              l10n.verificationCodeTitle,
              style: TextStyle(
                color: primaryText,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.verificationCodeSent(widget.maskedEmail),
              style: const TextStyle(
                color: secondaryText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            _VerificationDetailsCard(
              email: widget.registrationData?.email ?? widget.email,
              username: widget.registrationData?.username,
              firstName: widget.registrationData?.firstName,
              lastName: widget.registrationData?.lastName,
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => _CodeInput(
                  controller: _codeControllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (value) => _onCodeChanged(index, value),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: TextButton(
                onPressed: _isResending ? null : _resendCode,
                style: TextButton.styleFrom(
                  foregroundColor: primaryText,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: _isResending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.resendCode),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: _isLoading || !_isCodeComplete() ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryButton,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(29),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.confirm,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CodeInput extends StatelessWidget {
  const _CodeInput({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 58,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFBAC6D6),
              width: 1.4,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFBAC6D6),
              width: 1.4,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF1A2745),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          height: 1.0,
          color: Color(0xFF1E2B46),
        ),
      ),
    );
  }
}

class _VerificationDetailsCard extends StatelessWidget {
  const _VerificationDetailsCard({
    this.email,
    this.username,
    this.firstName,
    this.lastName,
  });

  final String? email;
  final String? username;
  final String? firstName;
  final String? lastName;

  String _valueOrPlaceholder(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registration details',
            style: TextStyle(
              color: Color(0xFF1E2B46),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _DetailRow(label: 'Email', value: _valueOrPlaceholder(email)),
          const SizedBox(height: 6),
          _DetailRow(label: 'Username', value: _valueOrPlaceholder(username)),
          const SizedBox(height: 6),
          _DetailRow(label: 'First name', value: _valueOrPlaceholder(firstName)),
          const SizedBox(height: 6),
          _DetailRow(label: 'Last name', value: _valueOrPlaceholder(lastName)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: Color(0xFF1E2B46),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF516178),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
