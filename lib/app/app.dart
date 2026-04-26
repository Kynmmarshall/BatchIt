import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/auth/verification_code_args.dart';
import 'package:batchit/providers/app_settings_provider.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/providers/order_provider.dart';
import 'package:batchit/screens/auth/login_screen.dart';
import 'package:batchit/screens/auth/register_screen.dart';
import 'package:batchit/screens/auth/verification_code_screen.dart';
import 'package:batchit/screens/batch/batch_details_screen.dart';
import 'package:batchit/screens/batch/join_batch_screen.dart';
import 'package:batchit/screens/splash/onboarding_screen.dart';
import 'package:batchit/screens/splash/splash_screen.dart';
import 'package:batchit/themes/app_motion.dart';
import 'package:batchit/themes/app_theme.dart';
import 'package:batchit/widgets/main_navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

class BatchItApp extends StatelessWidget {
  const BatchItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer4<
      AppSettingsProvider,
      AuthProvider,
      BatchProvider,
      OrderProvider
    >(
      builder: (context, settings, auth, _, __, child) {
        final startupRoute = auth.isAuthenticated
            ? AppRoutes.shell
            : AppRoutes.splashscreen;
        debugPrint(
          '[BatchIt][app] build auth.isAuthenticated=${auth.isAuthenticated} locale=${settings.locale.languageCode} themeMode=${settings.themeMode} initialRoute=$startupRoute',
        );

        return MaterialApp(
          title: 'BatchIt',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            if (child == null) {
              return const SizedBox.shrink();
            }

            return Stack(
              children: [
                child,
                Positioned(
                  top: 10,
                  right: 10,
                  child: SafeArea(
                    child: _LanguageSwitcherButton(
                      onPressed: () {
                        final provider = context.read<AppSettingsProvider>();
                        final nextLocale = provider.locale.languageCode == 'en'
                            ? const Locale('fr')
                            : const Locale('en');
                        provider.setLocale(nextLocale);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
          initialRoute: startupRoute,
          onGenerateRoute: (settingsRoute) {
            debugPrint(
              '[BatchIt][routes] onGenerateRoute name=${settingsRoute.name} args=${settingsRoute.arguments}',
            );
            switch (settingsRoute.name) {
              case AppRoutes.splashscreen:
                return _buildRoute(const SplashScreen());
              case AppRoutes.onboarding:
                return _buildRoute(const OnboardingScreen());
              case AppRoutes.login:
                return _buildRoute(const LoginScreen());
              case AppRoutes.register:
                return _buildRoute(const RegisterScreen());
              case AppRoutes.verification:
                final args = settingsRoute.arguments as VerificationCodeArgs?;
                return _buildRoute(
                  VerificationCodeScreen(
                    maskedEmail: args?.maskedEmail ?? 'sha....@gmail.com',
                  ),
                );
              case AppRoutes.shell:
                return _buildRoute(const MainNavigationShell(), isRoot: true);
              case AppRoutes.batchDetails:
                final id = settingsRoute.arguments as String?;
                if (id == null) {
                  return _fallbackRoute();
                }
                return _buildRoute(BatchDetailsScreen(batchId: id));
              case AppRoutes.joinBatch:
                final id = settingsRoute.arguments as String?;
                if (id == null) {
                  return _fallbackRoute();
                }
                return _buildRoute(JoinBatchScreen(batchId: id));
              default:
                return _fallbackRoute();
            }
          },
        );
      },
    );
  }

  PageRoute<T> _buildRoute<T>(Widget child, {bool isRoot = false}) {
    if (isRoot) {
      return PageRouteBuilder<T>(
        pageBuilder: (_, __, ___) => child,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );
    }

    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => child,
      transitionDuration: AppMotion.medium,
      reverseTransitionDuration: AppMotion.fast,
      transitionsBuilder: (context, animation, secondaryAnimation, page) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.emphasized,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: page,
          ),
        );
      },
    );
  }

  MaterialPageRoute<void> _fallbackRoute() {
    return MaterialPageRoute(
      builder: (_) =>
          const Scaffold(body: Center(child: Text('Route not found'))),
    );
  }
}

class _LanguageSwitcherButton extends StatelessWidget {
  const _LanguageSwitcherButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.94),
          shape: BoxShape.circle,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(Icons.language_rounded, color: scheme.onSurface),
        ),
      ),
    );
  }
}
