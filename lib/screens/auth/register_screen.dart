import 'package:batchit/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.register)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '${l10n.register} screen starter is ready.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
