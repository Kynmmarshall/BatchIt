/// ============================================================================
/// [AppRoutes] - Central route name constants
/// ============================================================================
/// Defines all named routes used throughout the app. Route names are used with
/// Navigator.pushNamed() and onGenerateRoute() dispatcher to navigate between screens.
///
/// Route inventory (14 total):
/// Onboarding flows:
///   - splashscreen: Initial app load screen
///   - onboarding: First-time user introduction
///   - questionnaire: User profile & preference form
///
/// Authentication:
///   - login: Email/password signin
///   - register: Account creation
///   - verification-code: 2FA confirmation
///
/// Main app navigation:
///   - /: Shell (root tab navigator, MainNavigationShell)
///   - search: Search results screen
///   - notifications: Alert feed
///   - settings: App preferences
///
/// Feature screens:
///   - batch-details: Batch detail view (requires batchId argument)
///   - join-batch: Batch join form (requires batchId argument)
///   - map-view: Map-based batch/provider browser
///   - chat: Conversation threads
///   - provider-discovery: Provider browsing & subscription
///
/// To add a new route:
/// 1. Add constant here (e.g., static const String newScreen = '/new-screen')
/// 2. Add case in onGenerateRoute() switch in app.dart
/// 3. Import the corresponding screen widget
/// ============================================================================
class AppRoutes {
  static const String splashscreen = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String questionnaire = '/questionnaire';
  static const String verification = '/verification-code';
  static const String shell = '/';
  static const String search = '/search';
  static const String batchDetails = '/batch-details';
  static const String joinBatch = '/join-batch';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String mapView = '/map-view';
  static const String chat = '/chat';
  static const String providerDiscovery = '/provider-discovery';
}

