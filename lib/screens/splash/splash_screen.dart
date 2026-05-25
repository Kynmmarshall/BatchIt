import 'package:batchit/core/app_routes.dart';
import 'package:batchit/providers/app_settings_provider.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('[BatchIt][splash] initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndNavigate();
    });
  }

  /// Initializes auth state, loads persisted settings, then navigates.
  Future<void> _initializeAndNavigate() async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.initialize();

      if (!mounted) return;

      final isAuthenticated = authProvider.isAuthenticated;

      // Load persisted theme/language from backend so user never has to re-set them.
      if (isAuthenticated) {
        try {
          final settings = await SettingsService().fetchSettings();
          if (mounted) {
            final appSettings = context.read<AppSettingsProvider>();
            appSettings.setLocale(Locale(settings.language));
            appSettings.applyTheme(
              settings.theme == 'dark'
                  ? ThemeMode.dark
                  : settings.theme == 'light'
                      ? ThemeMode.light
                      : ThemeMode.system,
            );
          }
        } catch (_) {}
      }

      debugPrint('[BatchIt][splash] init complete isAuthenticated=$isAuthenticated');
      if (!mounted) return;

      if (isAuthenticated) {
        debugPrint('[BatchIt][splash] navigating -> ${AppRoutes.shell}');
        Navigator.pushReplacementNamed(context, AppRoutes.shell);
      } else {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        debugPrint('[BatchIt][splash] navigating -> ${AppRoutes.onboarding}');
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    } catch (e) {
      debugPrint('[BatchIt][splash] init error: $e');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[BatchIt][splash] build');

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/logo.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('[BatchIt][splash] logo load failed: $error');
                return const Icon(Icons.image_not_supported_outlined, size: 56);
              },
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
