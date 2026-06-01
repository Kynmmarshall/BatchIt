/// ============================================================================
/// [AuthProvider] - Manages authentication state with persistent session
/// ============================================================================
/// Extends ChangeNotifier to provide reactive authentication state management.
/// Persists user session in Hive so users remain logged in after app restart.
/// Delegates actual auth logic to AuthService (email/Google login, etc.).
///
/// Responsibilities:
/// - Maintain current user profile (_user) with null = unauthenticated
/// - Persist user profile to Hive on successful login
/// - Restore user session from Hive on app startup
/// - Expose isAuthenticated boolean derived from user presence
/// - Handle login workflows (email password, Google OAuth)
/// - Manage logout and session termination
/// - Expose loading state for UI feedback during auth operations
///
/// Dependencies:
/// - AuthService: Provides actual authentication backend logic
/// - HiveService: Handles persistent storage of user profile
/// ============================================================================
library;

import 'package:batchit/models/hive_user_profile.dart';
import 'package:batchit/models/user_profile.dart';
import 'package:batchit/services/auth_service.dart';
import 'package:batchit/services/hive_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService, this._hiveService) {
    _restoreSession();
  }

  final AuthService _authService;
  final HiveService _hiveService;

  UserProfile? _user;
  bool _isLoading = false;

  UserProfile? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  /// Restores user session from persistent storage on app startup.
  /// Silently completes if no persisted session found (first login).
  void _restoreSession() {
    try {
      final savedProfile = _hiveService.getUserProfile();
      if (savedProfile != null) {
        // Convert HiveUserProfile to UserProfile domain model
        _user = UserProfile(
          id: savedProfile.id,
          name: savedProfile.name,
          email: savedProfile.email,
          avatarUrl: savedProfile.avatarUrl,
        );
        debugPrint('[AuthProvider] Session restored for: ${_user!.email}');
      }
    } catch (e) {
      debugPrint('[AuthProvider] Error restoring session: $e');
    }
  }

  /// Persists logged-in user profile to Hive.
  /// Called after successful authentication to enable session restoration.
  Future<void> _saveUserProfile(UserProfile profile) async {
    try {
      final hiveProfile = HiveUserProfile.fromMap({
        'id': profile.id,
        'name': profile.name,
        'email': profile.email,
        'avatarUrl': profile.avatarUrl,
      });
      await _hiveService.saveUserProfile(hiveProfile);
      debugPrint('[AuthProvider] User profile persisted: ${profile.email}');
    } catch (e) {
      debugPrint('[AuthProvider] Error saving user profile: $e');
    }
  }

  /// Initiates email+password login flow.
  /// Sets loading state, awaits AuthService result, saves profile, notifies listeners.
  ///
  /// Parameters:
  ///   - email: User's email address for authentication
  ///   - password: User's plaintext password (should be encrypted in transit)
  ///
  /// Side effects: Updates _user, persists to Hive, triggers rebuild of dependent widgets
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      if (_user != null) {
        await _saveUserProfile(_user!);
      }
    } catch (e) {
      debugPrint('[AuthProvider] Email login error: $e');
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Initiates Google OAuth login flow.
  /// Launches Google sign-in dialog, updates user profile on success.
  ///
  /// Side effects: Updates _user, persists to Hive, triggers rebuild of dependent widgets
  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.loginWithGoogle();
      if (_user != null) {
        await _saveUserProfile(_user!);
      }
    } catch (e) {
      debugPrint('[AuthProvider] Google login error: $e');
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clears user session from memory and persistent storage.
  /// Typically called when user taps logout button or session expires.
  ///
  /// Side effects: Sets _user to null, clears Hive storage, triggers navigation to splash
  Future<void> logout() async {
    try {
      _user = null;
      await _hiveService.clearUserProfile();
      debugPrint('[AuthProvider] User logged out and session cleared');
    } catch (e) {
      debugPrint('[AuthProvider] Error during logout: $e');
    }
    notifyListeners();
  }
}
