// ============================================================================
// Tests for ApiClient — HTTP methods, token management, error handling
// ============================================================================
import 'dart:convert';
import 'package:batchit/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;
  late ApiClient apiClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost'));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockClient = MockHttpClient();
    apiClient = ApiClient();
    apiClient.setHttpClientForTest(mockClient);
    // Reset token between tests
    await apiClient.clearAuthToken();
  });

  // ── Token management ────────────────────────────────────────────────────────

  group('token management', () {
    test('isAuthenticated is false after clearAuthToken', () async {
      expect(apiClient.isAuthenticated, isFalse);
    });

    test('setAuthToken makes isAuthenticated true', () async {
      await apiClient.setAuthToken('tok-abc');
      expect(apiClient.isAuthenticated, isTrue);
    });

    test('clearAuthToken sets isAuthenticated back to false', () async {
      await apiClient.setAuthToken('tok-xyz');
      await apiClient.clearAuthToken();
      expect(apiClient.isAuthenticated, isFalse);
    });

    test('restoreAuthToken returns false when nothing stored', () async {
      final restored = await apiClient.restoreAuthToken();
      expect(restored, isFalse);
      expect(apiClient.isAuthenticated, isFalse);
    });

    test('restoreAuthToken returns true when token is stored', () async {
      SharedPreferences.setMockInitialValues({'auth_token': 'stored-token'});
      final restored = await apiClient.restoreAuthToken();
      expect(restored, isTrue);
      expect(apiClient.isAuthenticated, isTrue);
    });

    test('restoreAuthToken returns false for empty string token', () async {
      SharedPreferences.setMockInitialValues({'auth_token': ''});
      final restored = await apiClient.restoreAuthToken();
      expect(restored, isFalse);
    });

    test('setRefreshCallback stores the callback', () {
      // Just verify it does not throw
      apiClient.setRefreshCallback(() async => true);
    });
  });

  // ── GET ─────────────────────────────────────────────────────────────────────

  group('get()', () {
    test('returns decoded JSON on 200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{"result": 42}', 200));

      final data = await apiClient.get('/test/');
      expect(data['result'], 42);
    });

    test('returns null when body is empty (204)', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('', 204));

      final data = await apiClient.get('/test/');
      expect(data, isNull);
    });

    test('appends query parameters to the URL', () async {
      Uri? capturedUri;
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((invocation) async {
        capturedUri = invocation.positionalArguments.first as Uri;
        return http.Response('[]', 200);
      });

      await apiClient.get('/items/', params: {'status': 'open'});
      expect(capturedUri?.queryParameters['status'], 'open');
    });

    test('throws ApiException on 400 with detail', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"detail": "Bad request"}', 400));

      expect(
        () => apiClient.get('/test/'),
        throwsA(isA<ApiException>()),
      );
    });

    test('throws ApiException on 401', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"detail": "Unauthorized"}', 401));

      expect(
        () => apiClient.get('/test/'),
        throwsA(isA<ApiException>()),
      );
    });

    test('throws ApiException on 500', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      expect(
        () => apiClient.get('/test/'),
        throwsA(isA<ApiException>()),
      );
    });

    test('includes Authorization header when token is set', () async {
      await apiClient.setAuthToken('my-token');
      Map<String, String>? capturedHeaders;

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((invocation) async {
        capturedHeaders = invocation.namedArguments[#headers]
            as Map<String, String>?;
        return http.Response('{}', 200);
      });

      await apiClient.get('/secure/');
      expect(capturedHeaders?['Authorization'], 'Token my-token');
    });

    test('no Authorization header when no token', () async {
      Map<String, String>? capturedHeaders;

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((invocation) async {
        capturedHeaders = invocation.namedArguments[#headers]
            as Map<String, String>?;
        return http.Response('{}', 200);
      });

      await apiClient.get('/public/');
      expect(capturedHeaders?.containsKey('Authorization'), isFalse);
    });
  });

  // ── POST ────────────────────────────────────────────────────────────────────

  group('post()', () {
    test('returns decoded JSON on 201', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('{"id": "99"}', 201));

      final data = await apiClient.post('/items/', body: {'name': 'Rice'});
      expect(data['id'], '99');
    });

    test('throws ApiException on 400', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async =>
              http.Response('{"detail": "Invalid data"}', 400));

      expect(
        () => apiClient.post('/items/', body: {}),
        throwsA(isA<ApiException>()),
      );
    });

    test('sends JSON body', () async {
      String? capturedBody;
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((invocation) async {
        capturedBody = invocation.namedArguments[#body] as String?;
        return http.Response('{}', 200);
      });

      await apiClient.post('/items/', body: {'key': 'value'});
      expect(capturedBody, jsonEncode({'key': 'value'}));
    });
  });

  // ── PATCH ───────────────────────────────────────────────────────────────────

  group('patch()', () {
    test('returns decoded JSON on 200', () async {
      when(() => mockClient.patch(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
              (_) async => http.Response('{"updated": true}', 200));

      final data = await apiClient.patch('/items/1/', body: {'name': 'New'});
      expect(data['updated'], isTrue);
    });

    test('throws ApiException on 404', () async {
      when(() => mockClient.patch(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async =>
              http.Response('{"detail": "Not found"}', 404));

      expect(
        () => apiClient.patch('/items/999/', body: {}),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ── DELETE ──────────────────────────────────────────────────────────────────

  group('delete()', () {
    test('returns null on 204 empty body', () async {
      when(() => mockClient.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('', 204));

      final result = await apiClient.delete('/items/1/');
      expect(result, isNull);
    });

    test('throws ApiException on 404', () async {
      when(() => mockClient.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"detail": "Not found"}', 404));

      expect(
        () => apiClient.delete('/items/99/'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ── Error body parsing ───────────────────────────────────────────────────────

  group('error body parsing', () {
    test('extracts detail field as message', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"detail": "Permission denied"}', 403));

      try {
        await apiClient.get('/protected/');
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.statusCode, 403);
        expect(e.message, 'Permission denied');
      }
    });

    test('extracts list field error as message', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"email": ["Enter a valid email."]}', 400));

      try {
        await apiClient.get('/register/');
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.message, 'Enter a valid email.');
      }
    });

    test('extracts string field error as message', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"non_field_errors": "Wrong credentials"}', 400));

      try {
        await apiClient.get('/login/');
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.message, 'Wrong credentials');
      }
    });

    test('falls back to message field', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"message": "Something went wrong"}', 500));

      try {
        await apiClient.get('/test/');
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.message, 'Something went wrong');
      }
    });

    test('body of ApiException includes parsed map', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"detail": "Forbidden"}', 403));

      try {
        await apiClient.get('/test/');
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.body, isA<Map<String, dynamic>>());
        expect(e.body?['detail'], 'Forbidden');
      }
    });

    test('non-JSON error body uses reasonPhrase fallback', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('plain text error', 500));

      try {
        await apiClient.get('/test/');
        fail('expected ApiException');
      } on ApiException catch (e) {
        // reasonPhrase is null on manually constructed Response → 'Unknown error'
        // or the raw text lands in message field
        expect(e.statusCode, 500);
      }
    });
  });

  // ── Network errors ───────────────────────────────────────────────────────────

  group('network errors', () {
    test('ClientException becomes ApiException with statusCode 0', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(http.ClientException('Connection refused'));

      try {
        await apiClient.get('/test/');
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.statusCode, 0);
        expect(e.message, contains('Network error'));
      }
    });

    test('generic exception becomes ApiException', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('Something unexpected'));

      try {
        await apiClient.get('/test/');
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.statusCode, 0);
      }
    });
  });

  // ── ApiException ─────────────────────────────────────────────────────────────

  group('ApiException', () {
    test('toString includes statusCode and message', () {
      final e = ApiException(statusCode: 404, message: 'Not found');
      expect(e.toString(), contains('404'));
      expect(e.toString(), contains('Not found'));
    });

    test('body is null when not provided', () {
      final e = ApiException(statusCode: 500, message: 'Error');
      expect(e.body, isNull);
    });
  });

  // ── Token refresh retry ──────────────────────────────────────────────────────

  group('_withRefresh 401 retry', () {
    test('retries request after successful token refresh', () async {
      int callCount = 0;
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return http.Response('{"detail": "token expired"}', 401);
        }
        return http.Response('{"data": "secret"}', 200);
      });

      apiClient.setRefreshCallback(() async {
        await apiClient.setAuthToken('new-fresh-token');
        return true;
      });

      final result = await apiClient.get('/protected/');
      expect(result['data'], 'secret');
      expect(callCount, 2);
    });

    test('rethrows 401 when refresh callback returns false', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"detail": "Unauthorized"}', 401));

      apiClient.setRefreshCallback(() async => false);

      expect(
        () => apiClient.get('/protected/'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });
  });
}
