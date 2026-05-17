/// ============================================================================
/// [AuthProvider] - Manages authentication state and user identity
/// ============================================================================
/// Extends ChangeNotifier to provide reactive authentication state management.
/// Delegates actual auth logic to AuthService (email/Google login, etc.).
/// Notifies listeners of auth state changes to rebuild UI accordingly.
///
/// Responsibilities:
/// - Maintain current user profile (_user) with null = unauthenticated
/// - Expose isAuthenticated boolean derived from user presence
/// - Handle login workflows (email password, Google OAuth)
/// - Manage logout and session termination
/// - Expose loading state for UI feedback during auth operations
/// - Inject auth token into ApiClient for authenticated requests
///
/// Dependencies:
/// - AuthService: Provides actual authentication backend logic
/// - ApiClient: Singleton for HTTP requests (token injection)
/// ============================================================================
import 'package:batchit/models/user_profile.dart';
import 'package:batchit/services/api_client.dart';
import 'package:batchit/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService) {
    _apiClient = ApiClient();
  }

  final AuthService _authService;
  late ApiClient _apiClient;

  UserProfile? _user;
  bool _isLoading = false;

  UserProfile? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  /// Initiates email+password login flow.
  /// Sets loading state, awaits AuthService result, updates user, injects token
  /// into ApiClient, and notifies listeners.
  /// 
  /// Parameters:
  ///   - email: User's email address for authentication
  ///   - password: User's plaintext password (should be encrypted in transit)
  ///
  /// Side effects: Updates _user, injects token into ApiClient, triggers rebuild
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.loginWithEmail(email: email, password: password);
      // Token is already set in ApiClient by AuthService
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _user = null;
      notifyListeners();
      rethrow;
    }
  }

  /// Initiates Google OAuth login flow.
  /// Launches Google sign-in dialog, updates user profile on success,
  /// injects token into ApiClient.
  ///
  /// Side effects: Updates _user, injects token into ApiClient, triggers rebuild
  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.loginWithGoogle();
      // Token is already set in ApiClient by AuthService
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _user = null;
      notifyListeners();
      rethrow;
    }
  }

  /// Clears user session, calls backend logout, clears token from ApiClient,
  /// and notifies listeners to rebuild UI.
  /// Typically called when user taps logout button or session expires.
  ///
  /// Side effects: Sets _user to null, clears ApiClient token, triggers navigation to splash screen
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _user = null;
      notifyListeners();
    }
  }
}
