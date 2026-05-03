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
///
/// Dependencies:
/// - AuthService: Provides actual authentication backend logic
/// ============================================================================
import 'package:batchit/models/user_profile.dart';
import 'package:batchit/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  UserProfile? _user;
  bool _isLoading = false;

  UserProfile? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  /// Initiates email+password login flow.
  /// Sets loading state, awaits AuthService result, updates user, notifies listeners.
  /// 
  /// Parameters:
  ///   - email: User's email address for authentication
  ///   - password: User's plaintext password (should be encrypted in transit)
  ///
  /// Side effects: Updates _user, triggers rebuild of dependent widgets
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    _user = await _authService.loginWithEmail(email: email, password: password);

    _isLoading = false;
    notifyListeners();
  }

  /// Initiates Google OAuth login flow.
  /// Launches Google sign-in dialog, updates user profile on success.
  ///
  /// Side effects: Updates _user, triggers rebuild of dependent widgets
  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    _user = await _authService.loginWithGoogle();

    _isLoading = false;
    notifyListeners();
  }

  /// Clears user session and notifies listeners to rebuild UI.
  /// Typically called when user taps logout button or session expires.
  ///
  /// Side effects: Sets _user to null, triggers navigation to splash screen
  void logout() {
    _user = null;
    notifyListeners();
  }
}
