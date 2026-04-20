import 'package:batchit/core/router/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/widgets/common/app_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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

    final auth = context.read<AuthProvider>();
    await auth.loginWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.shell);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(l10n.welcomeTitle, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(l10n.welcomeSubtitle),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: l10n.email),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.email;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.password),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return l10n.password;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AppPrimaryButton(
                  label: l10n.login,
                  isLoading: auth.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                AppPrimaryButton(
                  label: l10n.continueWithGoogle,
                  isLoading: auth.isLoading,
                  onPressed: () async {
                    await context.read<AuthProvider>().loginWithGoogle();
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.pushReplacementNamed(context, AppRoutes.shell);
                  },
                ),
                const Spacer(),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: Text(l10n.register),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
