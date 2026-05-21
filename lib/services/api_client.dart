import 'dart:io';
import 'package:batchit/core/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

/// ============================================================================
/// [ApiClient] - Base HTTP client for communicating with Django backend
/// ============================================================================
/// Singleton service that handles all HTTP requests, token management, and
/// error handling for the BatchIt API. Provides get, post, patch, and delete
/// methods with automatic token injection and response parsing.
///
/// Responsibilities:
/// - Maintain base URL and timeout configuration
/// - Store and inject authentication token in request headers
/// - Serialize/deserialize JSON request and response bodies
/// - Handle HTTP errors and provide meaningful error messages
/// - Refresh authentication token when needed (TODO)
/// ============================================================================

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  late http.Client _httpClient;
  String? _authToken;
  String _baseUrl = AppConstants.apiBaseUrl;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _httpClient = http.Client();
    debugPrint('[BatchIt][api] ApiClient initialized — baseUrl: $_baseUrl');
  }

  /// Sets the authentication token for subsequent requests.
  /// Called after successful login or token refresh.
  /// Persists token to local storage.
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } catch (e) {
      debugPrint('Failed to save auth token to storage: $e');
    }
  }

  /// Clears the authentication token (e.g., on logout).
  /// Removes token from local storage.
  Future<void> clearAuthToken() async {
    _authToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } catch (e) {
      debugPrint('Failed to clear auth token from storage: $e');
    }
  }

  /// Loads persisted auth token from local storage (called on app startup).
  /// Returns true if token was restored, false otherwise.
  Future<bool> restoreAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        _authToken = token;
        return true;
      }
    } catch (e) {
      debugPrint('Failed to restore auth token from storage: $e');
    }
    return false;
  }

  /// Returns true if an auth token is currently set.
  bool get isAuthenticated => _authToken != null;

  /// Builds common headers including Content-Type and Authorization.
  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Token $_authToken';
    }
    return headers;
  }

  /// Performs a GET request to the specified endpoint.
  /// Returns parsed JSON response or throws an exception on error.
  ///
  /// Parameters:
  ///   - endpoint: Path relative to base URL (e.g., '/batches/')
  ///   - params: Optional query parameters map
  Future<dynamic> get(String endpoint, {Map<String, String>? params}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final uriWithParams = params != null ? uri.replace(queryParameters: params) : uri;
    debugPrint('[BatchIt][api] GET $uriWithParams');

    try {
      final response = await _httpClient
          .get(uriWithParams, headers: _buildHeaders())
          .timeout(AppConstants.apiTimeout);

      debugPrint('[BatchIt][api] GET $endpoint → ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[BatchIt][api] GET $endpoint error: ${e.runtimeType}: $e');
      throw _handleError(e);
    }
  }

  /// Performs a POST request with JSON body.
  /// Returns parsed JSON response or throws an exception on error.
  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    debugPrint('[BatchIt][api] POST $uri');

    try {
      final response = await _httpClient
          .post(
            uri,
            headers: _buildHeaders(),
            body: jsonEncode(body),
          )
          .timeout(AppConstants.apiTimeout);

      debugPrint('[BatchIt][api] POST $endpoint → ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[BatchIt][api] POST $endpoint error: ${e.runtimeType}: $e');
      throw _handleError(e);
    }
  }

  /// Performs a PATCH request with JSON body.
  /// Used for partial updates.
  Future<dynamic> patch(String endpoint, {required Map<String, dynamic> body}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');

    try {
      final response = await _httpClient
          .patch(
            uri,
            headers: _buildHeaders(),
            body: jsonEncode(body),
          )
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a POST multipart/form-data request.
  /// Used for creating resources that include file uploads (e.g. provider profile).
  Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    List<MapEntry<String, File>>? files,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    if (_authToken != null) {
      request.headers['Authorization'] = 'Token $_authToken';
    }
    request.headers['Accept'] = 'application/json';
    request.fields.addAll(fields);

    if (files != null) {
      for (final entry in files) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value.path),
        );
      }
    }

    try {
      final streamed = await request.send().timeout(AppConstants.apiTimeout);
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a PATCH multipart/form-data request.
  /// Used for updates that include file uploads (e.g. profile picture).
  Future<dynamic> patchMultipart(
    String endpoint, {
    required Map<String, String> fields,
    File? file,
    String fileField = 'profile_photo',
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final request = http.MultipartRequest('PATCH', uri);

    if (_authToken != null) {
      request.headers['Authorization'] = 'Token $_authToken';
    }
    request.headers['Accept'] = 'application/json';
    request.fields.addAll(fields);

    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath(fileField, file.path));
    }

    try {
      final streamed = await request.send().timeout(AppConstants.apiTimeout);
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a DELETE request.
  /// Returns parsed JSON response or null on success.
  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');

    try {
      final response = await _httpClient
          .delete(uri, headers: _buildHeaders())
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handles HTTP response and returns parsed JSON or error message.
  /// Status codes:
  ///   - 200-299: Success, return parsed JSON
  ///   - 400: Bad request, throw with error details
  ///   - 401: Unauthorized, throw and trigger auth refresh (TODO)
  ///   - 404: Not found, throw with message
  ///   - 500+: Server error, throw with message
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    }

    final errorBody = _tryParseErrorBody(response.body);
    
    // Try to extract a meaningful error message
    String errorMessage = 'Unknown error';
    
    // First, check for 'detail' field (generic error message)
    if (errorBody['detail'] != null) {
      errorMessage = errorBody['detail'].toString();
    }
    // Otherwise, look for field-specific errors (e.g., {'email': '...', 'password': '...'})
    else {
      final fieldErrors = <String>[];
      errorBody.forEach((key, value) {
        if (key != 'message' && value != null) {
          // Handle both list and string error formats
          if (value is List && value.isNotEmpty) {
            fieldErrors.add(value.first.toString());
          } else if (value is String) {
            fieldErrors.add(value);
          }
        }
      });
      if (fieldErrors.isNotEmpty) {
        errorMessage = fieldErrors.join(' ');
      } else if (errorBody['message'] != null) {
        errorMessage = errorBody['message'].toString();
      } else {
        errorMessage = response.reasonPhrase ?? 'Unknown error';
      }
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: errorMessage,
      body: errorBody,
    );
  }

  /// Attempts to parse error response body as JSON.
  Map<String, dynamic> _tryParseErrorBody(String body) {
    if (body.isEmpty) return {};
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {'message': body};
    }
  }

  /// Converts caught exceptions to meaningful API exceptions.
  ApiException _handleError(Object error) {
    if (error is ApiException) {
      return error;
    }
    if (error is http.ClientException) {
      return ApiException(
        statusCode: 0,
        message: 'Network error: ${error.message}',
      );
    }
    return ApiException(
      statusCode: 0,
      message: 'Unexpected error: ${error.toString()}',
    );
  }
}

/// ============================================================================
/// [ApiException] - Custom exception for API errors
/// ============================================================================
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? body;

  ApiException({
    required this.statusCode,
    required this.message,
    this.body,
  });

  @override
  String toString() => 'ApiException: [$statusCode] $message';
}
