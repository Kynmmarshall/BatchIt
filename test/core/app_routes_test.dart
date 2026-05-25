// ============================================================================
// Tests for AppRoutes constants
// ============================================================================
import 'package:batchit/core/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRoutes constants', () {
    test('all constants are non-empty strings', () {
      final routes = [
        AppRoutes.splashscreen,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.questionnaire,
        AppRoutes.verification,
        AppRoutes.shell,
        AppRoutes.search,
        AppRoutes.batchDetails,
        AppRoutes.joinBatch,
        AppRoutes.notifications,
        AppRoutes.settings,
        AppRoutes.mapView,
        AppRoutes.chat,
        AppRoutes.providerDiscovery,
        AppRoutes.profileEdit,
        AppRoutes.becomeProvider,
        AppRoutes.providerDetail,
        AppRoutes.createBatch,
        AppRoutes.myBatches,
        AppRoutes.createOrder,
        AppRoutes.batchChat,
        AppRoutes.adminProviders,
        AppRoutes.aboutUs,
      ];
      for (final r in routes) {
        expect(r.isNotEmpty, true, reason: 'Route "$r" should be non-empty');
      }
    });

    test('all routes start with /', () {
      final routes = [
        AppRoutes.splashscreen,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.questionnaire,
        AppRoutes.verification,
        AppRoutes.shell,
        AppRoutes.search,
        AppRoutes.batchDetails,
        AppRoutes.joinBatch,
        AppRoutes.notifications,
        AppRoutes.settings,
        AppRoutes.mapView,
        AppRoutes.chat,
        AppRoutes.providerDiscovery,
        AppRoutes.profileEdit,
        AppRoutes.becomeProvider,
        AppRoutes.providerDetail,
        AppRoutes.createBatch,
        AppRoutes.myBatches,
        AppRoutes.createOrder,
        AppRoutes.batchChat,
        AppRoutes.adminProviders,
        AppRoutes.aboutUs,
      ];
      for (final r in routes) {
        expect(r.startsWith('/'), true, reason: 'Route "$r" should start with /');
      }
    });

    test('all route paths are unique', () {
      final routes = {
        AppRoutes.splashscreen,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.questionnaire,
        AppRoutes.verification,
        AppRoutes.shell,
        AppRoutes.search,
        AppRoutes.batchDetails,
        AppRoutes.joinBatch,
        AppRoutes.notifications,
        AppRoutes.settings,
        AppRoutes.mapView,
        AppRoutes.chat,
        AppRoutes.providerDiscovery,
        AppRoutes.profileEdit,
        AppRoutes.becomeProvider,
        AppRoutes.providerDetail,
        AppRoutes.createBatch,
        AppRoutes.myBatches,
        AppRoutes.createOrder,
        AppRoutes.batchChat,
        AppRoutes.adminProviders,
        AppRoutes.aboutUs,
      };
      // If all 24 are unique the set size matches
      expect(routes.length, 24);
    });

    test('key route values match their expected paths', () {
      expect(AppRoutes.shell, '/');
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.register, '/register');
      expect(AppRoutes.splashscreen, '/splash');
      expect(AppRoutes.settings, '/settings');
      expect(AppRoutes.aboutUs, '/about-us');
      expect(AppRoutes.batchDetails, '/batch-details');
      expect(AppRoutes.mapView, '/map-view');
    });
  });
}
