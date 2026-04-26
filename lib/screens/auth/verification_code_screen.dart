import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/widgets/auth/auth_screen_shell.dart';
import 'package:flutter/material.dart';

class VerificationCodeScreen extends StatelessWidget {
  const VerificationCodeScreen({
    super.key,
    this.maskedEmail = 'sha....@gmail.com',
  });

  final String maskedEmail;

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
              l10n.verificationCodeSent(maskedEmail),
              style: const TextStyle(
                color: secondaryText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _CodeBubble(text: '4'),
                SizedBox(width: 12),
                _CodeBubble(text: '3'),
                SizedBox(width: 12),
                _CodeBubble(text: '5'),
                SizedBox(width: 12),
                _CodeBubble(text: '•'),
              ],
            ),
            const SizedBox(height: 18),
            Center(
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: primaryText,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Text(l10n.resendCode),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: primaryButton,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(29),
                  ),
                ),
                child: Text(
                  l10n.confirm,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CodeBubble extends StatelessWidget {
  const _CodeBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFF6F6F6),
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1E2B46),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
