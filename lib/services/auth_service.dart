import 'dart:io';
import 'package:batchit/models/user_profile.dart';
import 'package:batchit/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// ============================================================================
/// [AuthService] - Handles user authentication with Django backend
/// ============================================================================
/// Provides login, registration, logout, and token refresh functionality.
/// Integrates with ApiClient to make HTTP requests and manages auth state
/// including token storage and injection.
///
/// Endpoints (backend):
/// - POST /api/auth/login/
/// - POST /api/auth/register/
/// - POST /api/auth/logout/
/// - POST /api/auth/refresh/
/// - GET /api/auth/me/
/// ============================================================================

class AuthService {
  final ApiClient _apiClient = ApiClient();
  static const String _googleWebClientId = '569929198452-v57ct3srgu0pc5k7rtpnpsq3a4rf1mhk.apps.googleusercontent.com';

  /// Logs in with email and password, returns user profile and stores auth token.
  /// Throws ApiException on network or validation error.
  Future<UserProfile> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login/',
        body: {
          'email': email,
          'password': password,
        },
      );

      // Extract token and user data from response
      // Expected response: { 'token': '...', 'user': { 'id': '...', 'name': '...', 'email': '...' } }
      final token = response['token'] as String?;
      if (token != null) {
        await _apiClient.setAuthToken(token);
        _apiClient.setRefreshCallback(refreshToken);
      }

      final userData = response['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw ApiException(statusCode: 0, message: 'Invalid response: missing user data');
      }

      return UserProfile(
        id: userData['customer_id'] as String? ?? userData['id'] as String? ?? 'unknown',
        username: userData['username'] as String? ?? '',
        email: userData['email'] as String? ?? '',
        firstName: userData['first_name'] as String?,
        lastName: userData['last_name'] as String?,
        avatarUrl: userData['profile_photo_url'] as String?,
        isStaff: userData['is_staff'] as bool? ?? false,
      );
    } on ApiException catch (_) {
      rethrow;
    }
  }

  /// Registers a new user with email and password.
  /// Returns user profile and stores auth token on success.
  Future<UserProfile> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register/',
        body: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      final token = response['token'] as String?;
      if (token != null) {
        await _apiClient.setAuthToken(token);
        _apiClient.setRefreshCallback(refreshToken);
      }

      final userData = response['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw ApiException(statusCode: 0, message: 'Invalid response: missing user data');
      }

      return UserProfile(
        id: userData['customer_id'] as String? ?? userData['id'] as String? ?? 'unknown',
        username: userData['username'] as String? ?? '',
        email: userData['email'] as String? ?? '',
        firstName: userData['first_name'] as String?,
        lastName: userData['last_name'] as String?,
        avatarUrl: userData['profile_photo_url'] as String?,
        isStaff: userData['is_staff'] as bool? ?? false,
      );
    } on ApiException catch (_) {
      rethrow;
    }
  }

  /// Logs in or registers with Google OAuth.
  /// Uses google_sign_in to open Google login dialog, gets ID token,
  /// and sends it to backend for authentication/registration.
  /// Returns user profile and stores auth token on success.
  Future<UserProfile> loginWithGoogle() async {
    try {
      debugPrint('[BatchIt][auth] Google login started');
      final googleSignIn = GoogleSignIn(
        serverClientId: _googleWebClientId,
        scopes: [
          'email',
          'profile',
        ],
      );

      // Sign in with Google
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('[BatchIt][auth] Google login cancelled by user');
        throw ApiException(statusCode: 0, message: 'Google sign-in cancelled by user');
      }

      debugPrint('[BatchIt][auth] Google account selected: ${googleUser.email}');

      // Get authentication object and ID token
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint('[BatchIt][auth] Google login failed: idToken was null');
        throw ApiException(
          statusCode: 0,
          message: 'Failed to get Google ID token. Check Android Google Sign-In configuration.',
        );
      }

      debugPrint('[BatchIt][auth] Google ID token received, sending to backend');

      // Send ID token to backend
      final response = await _apiClient.post(
        '/auth/google-login/',
        body: {
          'id_token': idToken,
        },
      );

      debugPrint('[BatchIt][auth] Google backend login succeeded');

      // Extract token and user data from response
      final token = response['token'] as String?;
      if (token != null) {
        await _apiClient.setAuthToken(token);
        _apiClient.setRefreshCallback(refreshToken);
      }

      final userData = response['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw ApiException(statusCode: 0, message: 'Invalid response: missing user data');
      }

      return UserProfile(
        id: userData['customer_id'] as String? ?? userData['id'] as String? ?? 'unknown',
        username: userData['username'] as String? ?? '',
        email: userData['email'] as String? ?? '',
        firstName: userData['first_name'] as String?,
        lastName: userData['last_name'] as String?,
        avatarUrl: userData['profile_photo_url'] as String?,
        isStaff: userData['is_staff'] as bool? ?? false,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[BatchIt][auth] Google login error: $e');
      final errorMsg = e.toString();
      if (errorMsg.contains('ApiException: 10') || errorMsg.contains('sign_in_failed')) {
        throw ApiException(
          statusCode: 0,
          message: 'Google sign-in is not configured for this Android package. Verify the OAuth Android client in Google Cloud Console uses package com.example.batchit and the correct SHA-1 fingerprint.',
        );
      }
      // Better error messages for common issues
      if (errorMsg.contains('channel-error') || errorMsg.contains('PlatformException')) {
        throw ApiException(
          statusCode: 0,
          message: 'Google Play Services not available. Please use a device with Google Play Services or try logging in with email instead.',
        );
      }
      throw ApiException(
        statusCode: 0,
        message: 'Google login failed: ${e.toString()}',
      );
    }
  }

  /// Fetches the currently authenticated user's profile.
  /// Requires a valid auth token.
  Future<UserProfile> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me/');

      final userData = response as Map<String, dynamic>?;
      if (userData == null) {
        throw ApiException(statusCode: 0, message: 'Invalid response: missing user data');
      }

      return UserProfile(
        id: userData['customer_id'] as String? ?? userData['id'] as String? ?? 'unknown',
        username: userData['username'] as String? ?? '',
        email: userData['email'] as String? ?? '',
        firstName: userData['first_name'] as String?,
        lastName: userData['last_name'] as String?,
        avatarUrl: userData['profile_photo_url'] as String?,
        isStaff: userData['is_staff'] as bool? ?? false,
      );
    } on ApiException catch (_) {
      rethrow;
    }
  }

  /// Logs out and clears the auth token.
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout/', body: {});
    } catch (_) {
      // Ignore errors during logout; clear token anyway
      debugPrint('Logout request failed, clearing token anyway');
    } finally {
      await _apiClient.clearAuthToken();
    }
  }

  /// Initializes auth service by restoring persisted token from storage.
  /// Fetches current user profile if token is valid.
  /// Call this once on app startup (in main.dart or splash screen).
  Future<void> initialize() async {
    try {
      final tokenRestored = await _apiClient.restoreAuthToken();
      if (tokenRestored && _apiClient.isAuthenticated) {
        // Try to fetch current user to validate token
        await getCurrentUser();
      }
    } catch (e) {
      debugPrint('Auth initialization failed: $e');
      // Token was invalid, clear it
      await _apiClient.clearAuthToken();
    }
  }

  /// Sends verification code to email address.
  /// Used during registration workflow.
  Future<void> sendVerificationCode(String email) async {
    try {
      await _apiClient.post(
        '/auth/send-verification-code/',
        body: {'email': email},
      );
    } on ApiException catch (_) {
      rethrow;
    }
  }

  /// Registers new user with email verification code.
  /// Verifies code, creates account, returns token and user profile.
  Future<UserProfile> registerWithVerification({
    required String email,
    required String code,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register-verify/',
        body: {
          'email': email,
          'code': code,
          'username': username,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      final token = response['token'] as String?;
      if (token != null) {
        await _apiClient.setAuthToken(token);
        _apiClient.setRefreshCallback(refreshToken);
      }

      final userData = response['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw ApiException(statusCode: 0, message: 'Invalid response: missing user data');
      }

      return UserProfile(
        id: userData['customer_id'] as String? ?? userData['id'] as String? ?? 'unknown',
        username: userData['username'] as String? ?? '',
        email: userData['email'] as String? ?? '',
        firstName: userData['first_name'] as String?,
        lastName: userData['last_name'] as String?,
        avatarUrl: userData['profile_photo_url'] as String?,
        isStaff: userData['is_staff'] as bool? ?? false,
      );
    } on ApiException catch (_) {
      rethrow;
    }
  }

  /// Updates the authenticated user's profile (name and optional photo).
  /// Returns the updated UserProfile on success.
  Future<UserProfile> updateProfile({
    required String firstName,
    required String lastName,
    File? profileImage,
  }) async {
    try {
      final dynamic response;
      if (profileImage != null) {
        response = await _apiClient.patchMultipart(
          '/auth/update-profile/',
          fields: {'first_name': firstName, 'last_name': lastName},
          file: profileImage,
        );
      } else {
        response = await _apiClient.patch(
          '/auth/update-profile/',
          body: {'first_name': firstName, 'last_name': lastName},
        );
      }

      final userData = response as Map<String, dynamic>?;
      if (userData == null) {
        throw ApiException(statusCode: 0, message: 'Invalid response from server');
      }

      return UserProfile(
        id: userData['customer_id'] as String? ?? userData['id'] as String? ?? 'unknown',
        username: userData['username'] as String? ?? '',
        email: userData['email'] as String? ?? '',
        firstName: userData['first_name'] as String?,
        lastName: userData['last_name'] as String?,
        avatarUrl: userData['profile_photo_url'] as String?,
        isStaff: userData['is_staff'] as bool? ?? false,
      );
    } on ApiException {
      rethrow;
    }
  }

  /// Refreshes the auth token using the /auth/refresh/ endpoint.
  /// Returns true if a new token was obtained and stored.
  Future<bool> refreshToken() async {
    try {
      final response = await _apiClient.post('/auth/refresh/', body: {});
      final token = response['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await _apiClient.setAuthToken(token);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if user is currently authenticated.
  bool get isAuthenticated => _apiClient.isAuthenticated;
}