import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/auth/verification_code_args.dart';
import 'package:batchit/widgets/auth/auth_screen_shell.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
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
            const SizedBox(height: 28),
            _RegisterField(
              hintText: l10n.emailAddress,
              prefixIcon: Icons.mail_outline_rounded,
              backgroundColor: fieldBackground,
            ),
            const SizedBox(height: 14),
            _RegisterField(
              hintText: l10n.password,
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: Icons.visibility_off_outlined,
              backgroundColor: fieldBackground,
            ),
            const SizedBox(height: 14),
            _RegisterField(
              hintText: l10n.confirmPassword,
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: Icons.visibility_off_outlined,
              backgroundColor: fieldBackground,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.verification,
                    arguments: const VerificationCodeArgs(
                      maskedEmail: 'sha....@gmail.com',
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: primaryButton,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(29),
                  ),
                ),
                child: Text(
                  l10n.signUpCta,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
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
            ),
            const SizedBox(height: 12),
            const Spacer(),
            const SizedBox(height: 22),
            Center(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(text: '${l10n.alreadyHaveAnAccount} '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        child: Text(
                          '${l10n.signInCta}.',
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
        );
      },
    );
  }
}

class _RegisterField extends StatelessWidget {
  const _RegisterField({
    required this.hintText,
    required this.prefixIcon,
    required this.backgroundColor,
    this.suffixIcon,
  });

  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: TextField(
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
              : Icon(suffixIcon, color: const Color(0xFF93A2B4)),
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
  });

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
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: TextButton.icon(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF93A2B4),
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
