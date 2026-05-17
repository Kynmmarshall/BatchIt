import 'package:batchit/models/user_profile.dart';
import 'package:batchit/services/api_client.dart';
import 'package:flutter/material.dart';

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
        _apiClient.setAuthToken(token);
      }

      final userData = response['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw ApiException(statusCode: 0, message: 'Invalid response: missing user data');
      }

      return UserProfile(
        id: userData['id'] as String? ?? 'unknown',
        name: userData['name'] as String? ?? userData['email'] ?? 'User',
        email: userData['email'] as String? ?? '',
      );
    } on ApiException catch (e) {
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
        _apiClient.setAuthToken(token);
      }

      final userData = response['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw ApiException(statusCode: 0, message: 'Invalid response: missing user data');
      }

      return UserProfile(
        id: userData['id'] as String? ?? 'unknown',
        name: '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim(),
        email: userData['email'] as String? ?? '',
      );
    } on ApiException catch (e) {
      rethrow;
    }
  }

  /// Logs in with Google OAuth (TODO: implement with Firebase or similar).
  /// For now, this is a placeholder.
  Future<UserProfile> loginWithGoogle() async {
    throw UnimplementedError('Google login not yet implemented');
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
        id: userData['id'] as String? ?? 'unknown',
        name: '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim(),
        email: userData['email'] as String? ?? '',
      );
    } on ApiException catch (e) {
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
      _apiClient.clearAuthToken();
    }
  }

  /// Refreshes the auth token using a refresh token (if available).
  /// Returns new auth token.
  Future<String?> refreshToken() async {
    try {
      final response = await _apiClient.post('/auth/refresh/', body: {});
      final newToken = response['token'] as String?;
      if (newToken != null) {
        _apiClient.setAuthToken(newToken);
      }
      return newToken;
    } on ApiException catch (e) {
      debugPrint('Token refresh failed: $e');
      return null;
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
    } on ApiException catch (e) {
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
        _apiClient.setAuthToken(token);
      }

      final userData = response['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw ApiException(statusCode: 0, message: 'Invalid response: missing user data');
      }

      return UserProfile(
        id: userData['customer_id'] as String? ?? userData['id'] as String? ?? 'unknown',
        name: '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim(),
        email: userData['email'] as String? ?? '',
      );
    } on ApiException catch (e) {
      rethrow;
    }
  }

  /// Returns true if user is currently authenticated.
  bool get isAuthenticated => _apiClient.isAuthenticated;
}