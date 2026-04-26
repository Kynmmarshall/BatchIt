import 'package:batchit/core/app_routes.dart';
import 'package:flutter/material.dart';

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

    Future.delayed(const Duration(seconds: 3), () {
      debugPrint('[BatchIt][splash] delay complete mounted=$mounted');
      if (!mounted) {
        debugPrint('[BatchIt][splash] navigation skipped because widget is unmounted');
        return;
      }
      debugPrint('[BatchIt][splash] navigating -> ${AppRoutes.onboarding}');
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    });
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
