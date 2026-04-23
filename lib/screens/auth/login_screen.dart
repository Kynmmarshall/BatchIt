import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/themes/app_colors.dart';
import 'package:batchit/themes/app_radius.dart';
import 'package:batchit/themes/app_shadows.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_primary_button.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: AppScreenContainer(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: AppSpacing.md),
              AppStaggeredFade(
                index: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? AppColors.darkHeroGradient
                          : AppColors.lightHeroGradient,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.hero),
                    boxShadow: AppShadows.hero(theme.brightness),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.welcomeTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.welcomeSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppStaggeredFade(
                index: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
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
                        const SizedBox(height: AppSpacing.sm),
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
                        const SizedBox(height: AppSpacing.md),
                        AppPrimaryButton(
                          label: l10n.login,
                          isLoading: auth.isLoading,
                          onPressed: _submit,
                          icon: Icons.login_rounded,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppPrimaryButton(
                          label: l10n.continueWithGoogle,
                          isLoading: auth.isLoading,
                          isSecondary: true,
                          icon: Icons.g_mobiledata_rounded,
                          onPressed: () async {
                            await context.read<AuthProvider>().loginWithGoogle();
                            if (!context.mounted) {
                              return;
                            }
                            Navigator.pushReplacementNamed(context, AppRoutes.shell);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppStaggeredFade(
                index: 2,
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: Text(l10n.register),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
