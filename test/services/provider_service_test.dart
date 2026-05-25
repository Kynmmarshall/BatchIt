// ============================================================================
// Tests for ProviderService — all public methods
// ============================================================================
import 'dart:convert';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/services/api_client.dart';
import 'package:batchit/services/provider_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockHttpClient extends Mock implements http.Client {}

// ── Helpers ──────────────────────────────────────────────────────────────────

Map<String, dynamic> _providerJson({
  String id = 'p1',
  String businessName = 'Test Store',
  String verificationStatus = 'verified',
  double? latitude,
  double? longitude,
}) =>
    {
      'provider_id': id,
      'owner_id': 'u1',
      'business_name': businessName,
      'owner_name': 'Test Owner',
      'category': 'grocery',
      'registration_number': 'REG-001',
      'phone': '+237600000000',
      'email': 'store@test.com',
      'address': '1 Market St',
      'description': 'A test store',
      'status': verificationStatus,
      'created_at': '2024-01-15T10:00:00Z',
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

void main() {
  late MockHttpClient mockClient;
  late ProviderService service;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost'));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockClient = MockHttpClient();
    ApiClient().setHttpClientForTest(mockClient);
    await ApiClient().clearAuthToken();
    service = ProviderService();
  });

  // ── fetchVerifiedProviders ───────────────────────────────────────────────

  group('fetchVerifiedProviders', () {
    test('returns only verified providers', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([
                  _providerJson(id: 'p1', verificationStatus: 'verified'),
                  _providerJson(id: 'p2', verificationStatus: 'pending'),
                ]),
                200,
              ));

      final providers = await service.fetchVerifiedProviders();
      expect(providers, hasLength(1));
      expect(providers.first.id, 'p1');
      expect(providers.first.isVerified, isTrue);
    });

    test('handles {results:[...]} response format', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({
                  'results': [_providerJson(verificationStatus: 'verified')]
                }),
                200,
              ));

      final providers = await service.fetchVerifiedProviders();
      expect(providers, hasLength(1));
    });

    test('returns empty list on error', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('network error'));

      final providers = await service.fetchVerifiedProviders();
      expect(providers, isEmpty);
    });
  });

  // ── fetchAllProviders ────────────────────────────────────────────────────

  group('fetchAllProviders', () {
    test('returns all providers regardless of status', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([
                  _providerJson(id: 'p1', verificationStatus: 'verified'),
                  _providerJson(id: 'p2', verificationStatus: 'pending'),
                  _providerJson(id: 'p3', verificationStatus: 'rejected'),
                ]),
                200,
              ));

      final providers = await service.fetchAllProviders();
      expect(providers, hasLength(3));
    });

    test('returns empty list on error', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('network error'));

      expect(await service.fetchAllProviders(), isEmpty);
    });
  });

  // ── fetchMyProviderProfile ───────────────────────────────────────────────

  group('fetchMyProviderProfile', () {
    test('returns profile when response has data', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode(_providerJson(id: 'me1')),
                200,
              ));

      final profile = await service.fetchMyProviderProfile();
      expect(profile, isNotNull);
      expect(profile!.id, 'me1');
    });

    test('returns null when response body is empty (204)', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('', 204));

      final profile = await service.fetchMyProviderProfile();
      expect(profile, isNull);
    });

    test('returns null on error', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('not found'));

      final profile = await service.fetchMyProviderProfile();
      expect(profile, isNull);
    });
  });

  // ── fetchProviderById ────────────────────────────────────────────────────

  group('fetchProviderById', () {
    test('returns provider with correct id', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode(_providerJson(id: 'abc')),
                200,
              ));

      final provider = await service.fetchProviderById('abc');
      expect(provider.id, 'abc');
    });

    test('rethrows on error', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"detail": "Not found"}', 404));

      expect(
        () => service.fetchProviderById('missing'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ── fetchFollowedProviders ───────────────────────────────────────────────

  group('fetchFollowedProviders', () {
    test('returns list of followed providers', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([
                  _providerJson(id: 'f1'),
                  _providerJson(id: 'f2'),
                ]),
                200,
              ));

      final providers = await service.fetchFollowedProviders();
      expect(providers, hasLength(2));
    });

    test('returns empty list on error', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('network fail'));

      expect(await service.fetchFollowedProviders(), isEmpty);
    });
  });

  // ── followProvider ───────────────────────────────────────────────────────

  group('followProvider', () {
    test('returns true when response contains "Following"', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
              '{"detail": "Following provider"}',
              200));

      final result = await service.followProvider('p1');
      expect(result, isTrue);
    });

    test('returns false when response does not contain "Following"', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
              '{"detail": "Already following"}',
              200));

      final result = await service.followProvider('p1');
      expect(result, isFalse);
    });

    test('rethrows on ApiException', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async =>
          http.Response('{"detail": "Not found"}', 404));

      expect(
        () => service.followProvider('unknown'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ── unfollowProvider ─────────────────────────────────────────────────────

  group('unfollowProvider', () {
    test('completes without error on success', () async {
      when(() => mockClient.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('', 204));

      await expectLater(service.unfollowProvider('p1'), completes);
    });

    test('rethrows on ApiException', () async {
      when(() => mockClient.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"detail": "Not found"}', 404));

      expect(
        () => service.unfollowProvider('p1'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ── submitProviderProfile (JSON path, no files) ──────────────────────────

  group('submitProviderProfile', () {
    test('returns ProviderProfile on success', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
              jsonEncode(_providerJson(id: 'new-p', verificationStatus: 'pending')),
              201));

      final profile = await service.submitProviderProfile(
        businessName: 'My Shop',
        ownerName: 'Jane Doe',
        category: BusinessCategory.grocery,
        registrationNumber: 'REG-XYZ',
        phone: '+237600000001',
        email: 'jane@shop.com',
        address: '5 Main Ave',
        description: 'Groceries',
        latitude: 3.85,
        longitude: 11.5,
      );

      expect(profile.id, 'new-p');
      expect(profile.isPending, isTrue);
    });

    test('rethrows ApiException on failure', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async =>
          http.Response('{"detail": "Duplicate registration"}', 400));

      expect(
        () => service.submitProviderProfile(
          businessName: 'Shop',
          ownerName: 'Owner',
          category: BusinessCategory.other,
          registrationNumber: 'DUP',
          phone: '000',
          email: 'a@b.com',
          address: 'x',
          description: 'y',
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ── updateMyProviderProfile ───────────────────────────────────────────────

  group('updateMyProviderProfile', () {
    test('returns updated profile', () async {
      when(() => mockClient.patch(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
              jsonEncode(
                  _providerJson(businessName: 'Updated Shop')),
              200));

      final profile = await service.updateMyProviderProfile(
        businessName: 'Updated Shop',
        ownerName: 'Owner',
        category: BusinessCategory.grocery,
        registrationNumber: 'REG-001',
        phone: '+237600000000',
        email: 'store@test.com',
        address: '1 Market St',
        description: 'Updated description',
      );

      expect(profile.businessName, 'Updated Shop');
    });
  });
}
