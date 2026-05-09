/// ============================================================================
/// [BatchItApp] - Main application widget and routing dispatcher
/// ============================================================================
/// Stateless widget that builds the MaterialApp root and configures routing,
/// theming, localization, and global UI overlays.
///
/// Key responsibilities:
/// - Consume 4 core providers: AppSettings (theme/locale), Auth, Batch, Order
/// - Determine initial route based on auth state (authenticated → shell, else → splash)
/// - Configure MaterialApp with theme, dark theme, supported locales
/// - Route all 14 named routes via onGenerateRoute switch statement
/// - Apply consistent page transitions (fade + slide)
/// - Overlay language switcher button (top-right corner)
/// - Log all route transitions for debugging
///
/// Routing table (14 routes):
/// - splashscreen → SplashScreen (initial for unauthenticated)
/// - onboarding → OnboardingScreen (first-time users)
/// - login → LoginScreen (email/password auth)
/// - register → RegisterScreen (new account)
/// - questionnaire → QuestionnaireScreen (user profile form)
/// - verification → VerificationCodeScreen (2FA confirmation)
/// - shell → MainNavigationShell (post-auth tab navigator)
/// - search → SearchResultsScreen (unified search)
/// - batchDetails → BatchDetailsScreen (requires batchId arg)
/// - joinBatch → JoinBatchScreen (requires batchId arg)
/// - notifications → NotificationsScreen
/// - settings → SettingsScreen
/// - mapView → MapViewScreen
/// - chat → ChatScreen
/// - providerDiscovery → ProviderDiscoveryScreen
/// ============================================================================
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
import 'package:batchit/screens/more/chat_screen.dart';
import 'package:batchit/screens/more/map_view_screen.dart';
import 'package:batchit/screens/notifications/notifications_screen.dart';
import 'package:batchit/screens/providers/provider_discovery_screen.dart';
import 'package:batchit/screens/search/search_results_screen.dart';
import 'package:batchit/screens/splash/questionnaire_screen.dart';
import 'package:batchit/screens/splash/onboarding_screen.dart';
import 'package:batchit/screens/splash/splash_screen.dart';
import 'package:batchit/screens/profile/settings_screen.dart';
import 'package:batchit/services/auto_update_service.dart';
import 'package:batchit/themes/app_motion.dart';
import 'package:batchit/themes/app_theme.dart';
import 'package:batchit/widgets/main_navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

class BatchItApp extends StatelessWidget {
  const BatchItApp({super.key});

  // Flag to ensure the update check runs only once per app lifecycle.
  static bool _updateCheckScheduled = false;

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

            // Schedule auto-update check after first frame (once only).
            if (!BatchItApp._updateCheckScheduled) {
              BatchItApp._updateCheckScheduled = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _checkForUpdates(context);
              });
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
              case AppRoutes.questionnaire:
                return _buildRoute(const QuestionnaireScreen());
              case AppRoutes.verification:
                final args = settingsRoute.arguments as VerificationCodeArgs?;
                return _buildRoute(
                  VerificationCodeScreen(
                    maskedEmail: args?.maskedEmail ?? 'sha....@gmail.com',
                  ),
                );
              case AppRoutes.shell:
                return _buildRoute(const MainNavigationShell(), isRoot: true);
              case AppRoutes.search:
                return _buildRoute(const SearchResultsScreen());
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
              case AppRoutes.notifications:
                return _buildRoute(const NotificationsScreen());
              case AppRoutes.settings:
                return _buildRoute(const SettingsScreen());
              case AppRoutes.mapView:
                return _buildRoute(const MapViewScreen());
              case AppRoutes.chat:
                return _buildRoute(const ChatScreen());
              case AppRoutes.providerDiscovery:
                return _buildRoute(const ProviderDiscoveryScreen());
              default:
                return _fallbackRoute();
            }
          },
        );
      },
    );
  }

  /// Triggers the auto-update check on the current [BuildContext].
  void _checkForUpdates(BuildContext context) {
    final updateService = AutoUpdateService();
    updateService.checkForUpdates(context);
  }

  /// Constructs PageRoute with custom transitions for non-root screens.
  /// Root screens (shell) use zero-duration transitions to avoid jank.
  /// Non-root screens use fade + slide-up with emphasized timing curve.
  ///
  /// Parameters:
  ///   - child: Widget to wrap in page route
  ///   - isRoot: If true, use instant (zero-duration) transition
  ///
  /// Returns: PageRoute<T> with custom animation or instant navigation
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

  /// Builds fallback 404 page when route not found.
  /// Shows localized "Route not found" message.
  MaterialPageRoute<void> _fallbackRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(child: Text(AppLocalizations.of(context)!.routeNotFound)),
      ),
    );
  }
}

/// ============================================================================
/// [_LanguageSwitcherButton] - Floating action button for locale switching
/// ============================================================================
/// Overlay button positioned at top-right corner for EN ↔ FR switching.
/// Provides quick access to language change without navigating to settings.
/// ============================================================================
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
