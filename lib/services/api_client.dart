import 'package:batchit/core/app_constants.dart';
import 'package:http/http.dart' as http;
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
  }

  /// Sets the authentication token for subsequent requests.
  /// Called after successful login or token refresh.
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clears the authentication token (e.g., on logout).
  void clearAuthToken() {
    _authToken = null;
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

    try {
      final response = await _httpClient
          .get(uriWithParams, headers: _buildHeaders())
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a POST request with JSON body.
  /// Returns parsed JSON response or throws an exception on error.
  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');

    try {
      final response = await _httpClient
          .post(
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
    final errorMessage = errorBody['detail'] ?? errorBody['message'] ?? response.reasonPhrase ?? 'Unknown error';

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
