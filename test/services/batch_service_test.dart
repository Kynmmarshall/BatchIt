// ============================================================================
// Tests for BatchService — all public methods + JSON mapping
// ============================================================================
import 'dart:convert';
import 'package:batchit/services/api_client.dart';
import 'package:batchit/services/batch_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockHttpClient extends Mock implements http.Client {}

// ── Helpers ──────────────────────────────────────────────────────────────────

Map<String, dynamic> _batchJson({
  String id = 'b1',
  String productName = 'Rice',
  double totalQuantity = 100,
  double filledQuantity = 20,
  String status = 'open',
  String? locationName,
  String? location,
  String? hubName,
  String? providerName,
  String? imageUrl,
  String? batchId,
}) =>
    {
      if (batchId != null) 'batch_id': batchId else 'id': id,
      'product_name': productName,
      'total_quantity': totalQuantity,
      'filled_quantity': filledQuantity,
      'status': status,
      if (locationName != null) 'location_name': locationName,
      if (location != null) 'location': location,
      if (hubName != null) 'hub_name': hubName,
      if (providerName != null) 'provider_name': providerName,
      if (imageUrl != null) 'image_url': imageUrl,
    };

void main() {
  late MockHttpClient mockClient;
  late BatchService service;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost'));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockClient = MockHttpClient();
    ApiClient().setHttpClientForTest(mockClient);
    await ApiClient().clearAuthToken();
    service = BatchService();
  });

  // ── fetchNearbyBatches ────────────────────────────────────────────────────

  group('fetchNearbyBatches', () {
    test('returns list when response is a JSON array', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([_batchJson(productName: 'Sugar')]),
                200,
              ));

      final batches = await service.fetchNearbyBatches();
      expect(batches, hasLength(1));
      expect(batches.first.productName, 'Sugar');
    });

    test('returns list when response is {results: [...]}', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({
                  'results': [_batchJson(), _batchJson(id: 'b2')]
                }),
                200,
              ));

      final batches = await service.fetchNearbyBatches();
      expect(batches, hasLength(2));
    });

    test('returns empty list on ApiException', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"detail": "Unauthorized"}', 401));

      final batches = await service.fetchNearbyBatches();
      expect(batches, isEmpty);
    });

    test('passes status/location params in request', () async {
      Uri? capturedUri;
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((inv) async {
        capturedUri = inv.positionalArguments.first as Uri;
        return http.Response('[]', 200);
      });

      await service.fetchNearbyBatches(
        status: 'filled',
        latitude: 3.86,
        longitude: 11.5,
        radiusKm: 5,
      );

      expect(capturedUri?.queryParameters['status'], 'filled');
      expect(capturedUri?.queryParameters['latitude'], '3.86');
      expect(capturedUri?.queryParameters['longitude'], '11.5');
      expect(capturedUri?.queryParameters['radius_km'], '5.0');
    });
  });

  // ── fetchMyCreatedBatches ────────────────────────────────────────────────

  group('fetchMyCreatedBatches', () {
    test('returns list of user-created batches', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([_batchJson(productName: 'Corn')]),
                200,
              ));

      final batches = await service.fetchMyCreatedBatches();
      expect(batches.first.productName, 'Corn');
    });

    test('returns empty on ApiException', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{"detail": "Error"}', 500));

      expect(await service.fetchMyCreatedBatches(), isEmpty);
    });
  });

  // ── fetchMyJoinedBatches ─────────────────────────────────────────────────

  group('fetchMyJoinedBatches', () {
    test('returns joined batches list', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'results': [_batchJson(id: 'j1')]}),
                200,
              ));

      final batches = await service.fetchMyJoinedBatches();
      expect(batches, hasLength(1));
    });

    test('returns empty on error', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{"detail": "Error"}', 500));

      expect(await service.fetchMyJoinedBatches(), isEmpty);
    });
  });

  // ── fetchBatchById ───────────────────────────────────────────────────────

  group('fetchBatchById', () {
    test('returns batch with correct id', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response(jsonEncode(_batchJson(id: 'x9')), 200));

      final batch = await service.fetchBatchById('x9');
      expect(batch.id, 'x9');
    });

    test('throws on error response', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"detail": "Not found"}', 404));

      expect(
        () => service.fetchBatchById('no-such-id'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ── joinBatch ────────────────────────────────────────────────────────────

  group('joinBatch', () {
    test('completes without error on success', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
              (_) async => http.Response('{"detail": "Joined"}', 200));

      await expectLater(service.joinBatch('b1', 5.0), completes);
    });

    test('propagates ApiException on failure', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async =>
              http.Response('{"detail": "Batch full"}', 400));

      expect(
        () => service.joinBatch('b1', 500),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ── deleteBatch ──────────────────────────────────────────────────────────

  group('deleteBatch', () {
    test('completes without error on success', () async {
      when(() => mockClient.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('', 204));

      await expectLater(service.deleteBatch('b1'), completes);
    });
  });

  // ── createBatch (no image) ───────────────────────────────────────────────

  group('createBatch', () {
    test('creates and returns batch from JSON response', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
              jsonEncode(_batchJson(id: 'new1', productName: 'Beans')),
              201));

      final batch = await service.createBatch(
        productName: 'Beans',
        bulkSizeKg: 50,
        location: 'Mokolo',
      );

      expect(batch.productName, 'Beans');
    });

    test('creates batch with optional fields', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async =>
          http.Response(jsonEncode(_batchJson(id: 'n2')), 201));

      final batch = await service.createBatch(
        productName: 'Oil',
        bulkSizeKg: 100,
        location: 'Hub X',
        unit: 'L',
        providerId: 'prov1',
        notes: 'Handle with care',
        expiresAt: DateTime.now().add(const Duration(days: 14)),
      );

      expect(batch.id, 'n2');
    });
  });

  // ── updateBatch ───────────────────────────────────────────────────────────

  group('updateBatch', () {
    test('returns updated batch', () async {
      when(() => mockClient.patch(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
              jsonEncode(_batchJson(id: 'b1', productName: 'Maize')),
              200));

      final batch = await service.updateBatch(
        'b1',
        productName: 'Maize',
        status: 'open',
      );

      expect(batch.productName, 'Maize');
    });
  });

  // ── _mapBatchFromJson (tested through fetchNearbyBatches) ─────────────────

  group('_mapBatchFromJson field aliases', () {
    test('uses batch_id when id is absent', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([_batchJson(batchId: 'alias1')]),
                200,
              ));

      final batches = await service.fetchNearbyBatches();
      expect(batches.first.id, 'alias1');
    });

    test('uses total_quantity alias for bulkSizeKg', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([
                  {
                    'id': 'b1',
                    'product_name': 'Rice',
                    'total_quantity': 75.0,
                    'status': 'open',
                  }
                ]),
                200,
              ));

      final batches = await service.fetchNearbyBatches();
      expect(batches.first.bulkSizeKg, 75.0);
    });

    test('uses location alias when location_name absent', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([_batchJson(location: 'Market A')]),
                200,
              ));

      final batches = await service.fetchNearbyBatches();
      expect(batches.first.locationName, 'Market A');
    });

    test('uses provider_name alias when hub_name absent', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([_batchJson(providerName: 'Shop B')]),
                200,
              ));

      final batches = await service.fetchNearbyBatches();
      expect(batches.first.hubName, 'Shop B');
    });

    test('maps bulk_size_kg field directly', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([
                  {
                    'id': 'b1',
                    'product_name': 'Flour',
                    'bulk_size_kg': 200.0,
                    'current_quantity_kg': 80.0,
                    'status': 'open',
                  }
                ]),
                200,
              ));

      final batches = await service.fetchNearbyBatches();
      expect(batches.first.bulkSizeKg, 200.0);
      expect(batches.first.currentQuantityKg, 80.0);
    });

    test('defaults to open status when missing', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([
                  {'id': 'b1', 'product_name': 'P'}
                ]),
                200,
              ));

      final batches = await service.fetchNearbyBatches();
      expect(batches.first.status, 'open');
    });
  });
}
