import 'package:batchit/core/app_routes.dart';
import 'package:batchit/providers/auth_provider.dart';
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

  /// Initializes auth state and navigates to appropriate screen.
  Future<void> _initializeAndNavigate() async {
    try {
      // Initialize auth by checking for persisted token
      final authProvider = context.read<AuthProvider>();
      await authProvider.initialize();

      // After init completes, check if user is authenticated
      if (!mounted) {
        debugPrint('[BatchIt][splash] widget unmounted during init');
        return;
      }

      final isAuthenticated = authProvider.isAuthenticated;
      debugPrint('[BatchIt][splash] init complete isAuthenticated=$isAuthenticated');

      // Navigate to appropriate route
      if (isAuthenticated) {
        debugPrint('[BatchIt][splash] navigating -> ${AppRoutes.shell}');
        Navigator.pushReplacementNamed(context, AppRoutes.shell);
      } else {
        // Small delay for visual feedback
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        debugPrint('[BatchIt][splash] navigating -> ${AppRoutes.onboarding}');
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    } catch (e) {
      debugPrint('[BatchIt][splash] init error: $e');
      if (!mounted) return;
      // On error, navigate to onboarding
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
