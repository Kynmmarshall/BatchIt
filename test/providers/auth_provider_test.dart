// ============================================================================
// Tests for AuthProvider
// ============================================================================
import 'package:batchit/models/user_profile.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

final _testUser = UserProfile(
  id: 'u1',
  username: 'jdoe',
  email: 'j@example.com',
  firstName: 'John',
  lastName: 'Doe',
);

void main() {
  late MockAuthService mockService;
  late AuthProvider provider;

  setUp(() {
    mockService = MockAuthService();
    provider = AuthProvider(mockService);
  });

  group('initial state', () {
    test('user is null', () => expect(provider.user, isNull));
    test('isAuthenticated is false', () => expect(provider.isAuthenticated, false));
    test('isLoading is false', () => expect(provider.isLoading, false));
    test('isInitialized is false', () => expect(provider.isInitialized, false));
  });

  group('initialize', () {
    test('sets isInitialized to true after completion', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isAuthenticated).thenReturn(false);

      await provider.initialize();

      expect(provider.isInitialized, true);
      expect(provider.isLoading, false);
    });

    test('loads user when service reports authenticated', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isAuthenticated).thenReturn(true);
      when(() => mockService.getCurrentUser()).thenAnswer((_) async => _testUser);

      await provider.initialize();

      expect(provider.user, isNotNull);
      expect(provider.user!.email, 'j@example.com');
      expect(provider.isAuthenticated, true);
    });

    test('leaves user null when not authenticated', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isAuthenticated).thenReturn(false);

      await provider.initialize();

      expect(provider.user, isNull);
    });

    test('handles exception gracefully and remains unauthenticated', () async {
      when(() => mockService.initialize()).thenThrow(Exception('init error'));

      await provider.initialize();

      expect(provider.user, isNull);
      expect(provider.isInitialized, true);
      expect(provider.isLoading, false);
    });
  });

  group('loginWithEmail', () {
    test('sets user on success', () async {
      when(
        () => mockService.loginWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _testUser);

      await provider.loginWithEmail(email: 'j@example.com', password: 'pass');

      expect(provider.user, isNotNull);
      expect(provider.user!.id, 'u1');
      expect(provider.isAuthenticated, true);
      expect(provider.isLoading, false);
    });

    test('clears user and rethrows on failure', () async {
      when(
        () => mockService.loginWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('wrong password'));

      expect(
        () => provider.loginWithEmail(email: 'j@example.com', password: 'bad'),
        throwsException,
      );

      await Future.microtask(() {}); // let async complete
      expect(provider.isLoading, false);
    });
  });

  group('loginWithGoogle', () {
    test('sets user on success', () async {
      when(() => mockService.loginWithGoogle()).thenAnswer((_) async => _testUser);

      await provider.loginWithGoogle();

      expect(provider.isAuthenticated, true);
      expect(provider.user!.username, 'jdoe');
    });

    test('clears user and rethrows on failure', () async {
      when(() => mockService.loginWithGoogle()).thenThrow(Exception('cancelled'));

      expect(provider.loginWithGoogle, throwsException);
    });
  });

  group('logout', () {
    test('clears user and notifies', () async {
      // Log in first
      when(
        () => mockService.loginWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _testUser);
      await provider.loginWithEmail(email: 'j@example.com', password: 'p');

      // Now log out
      when(() => mockService.logout()).thenAnswer((_) async {});
      await provider.logout();

      expect(provider.user, isNull);
      expect(provider.isAuthenticated, false);
      expect(provider.isLoading, false);
    });

    test('still clears user even if service throws', () async {
      when(() => mockService.logout()).thenThrow(Exception('network error'));

      await provider.logout(); // should not throw

      expect(provider.user, isNull);
      expect(provider.isLoading, false);
    });
  });
}
