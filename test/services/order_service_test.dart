// ============================================================================
// Tests for OrderService — all public methods + JSON mapping
// ============================================================================
import 'dart:convert';
import 'package:batchit/models/order.dart';
import 'package:batchit/services/api_client.dart';
import 'package:batchit/services/order_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockHttpClient extends Mock implements http.Client {}

// ── Helpers ──────────────────────────────────────────────────────────────────

Map<String, dynamic> _orderJson({
  String id = 'o1',
  String productName = 'Rice',
  double quantityKg = 10,
  String status = 'pending',
  String hubName = 'Hub A',
  String? batchId,
  String? orderId,
}) =>
    {
      if (orderId != null) 'order_id': orderId else 'id': id,
      'product_name': productName,
      'quantity_kg': quantityKg,
      'status': status,
      'hub_name': hubName,
      if (batchId != null) 'batch_id': batchId,
    };

void main() {
  late MockHttpClient mockClient;
  late OrderService service;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost'));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockClient = MockHttpClient();
    ApiClient().setHttpClientForTest(mockClient);
    await ApiClient().clearAuthToken();
    service = OrderService();
  });

  // ── fetchOrders ──────────────────────────────────────────────────────────

  group('fetchOrders', () {
    test('returns list when response is a JSON array', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([_orderJson(productName: 'Sugar')]),
                200,
              ));

      final orders = await service.fetchOrders();
      expect(orders, hasLength(1));
      expect(orders.first.productName, 'Sugar');
    });

    test('returns list when response is {results: [...]}', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({
                  'results': [_orderJson(), _orderJson(id: 'o2')]
                }),
                200,
              ));

      final orders = await service.fetchOrders();
      expect(orders, hasLength(2));
    });

    test('passes status filter in query params', () async {
      Uri? capturedUri;
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((inv) async {
        capturedUri = inv.positionalArguments.first as Uri;
        return http.Response('[]', 200);
      });

      await service.fetchOrders(status: OrderStatus.delivered);
      expect(capturedUri?.queryParameters['status'], 'delivered');
    });

    test('returns empty list on ApiException', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"detail": "Forbidden"}', 403));

      final orders = await service.fetchOrders();
      expect(orders, isEmpty);
    });

    test('no status param when status is null', () async {
      Uri? capturedUri;
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((inv) async {
        capturedUri = inv.positionalArguments.first as Uri;
        return http.Response('[]', 200);
      });

      await service.fetchOrders();
      expect(capturedUri?.queryParameters.containsKey('status'), isFalse);
    });
  });

  // ── createOrder ──────────────────────────────────────────────────────────

  group('createOrder', () {
    test('returns created order on success', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
              jsonEncode(_orderJson(id: 'new1', productName: 'Corn')),
              201));

      final order = await service.createOrder(
        batchId: 'b1',
        quantityKg: 5,
      );

      expect(order.productName, 'Corn');
    });

    test('throws ApiException on failure', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async =>
          http.Response('{"detail": "Batch full"}', 400));

      expect(
        () => service.createOrder(batchId: 'b1', quantityKg: 9999),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ── fetchOrderById ───────────────────────────────────────────────────────

  group('fetchOrderById', () {
    test('returns order with correct id', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response(jsonEncode(_orderJson(id: 'ox7')), 200));

      final order = await service.fetchOrderById('ox7');
      expect(order.id, 'ox7');
    });

    test('throws ApiException on 404', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"detail": "Not found"}', 404));

      expect(
        () => service.fetchOrderById('missing'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ── updateOrderStatus ────────────────────────────────────────────────────

  group('updateOrderStatus', () {
    test('returns updated order with new status', () async {
      when(() => mockClient.patch(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
              jsonEncode(_orderJson(status: 'delivered')),
              200));

      final order = await service.updateOrderStatus(
        'o1',
        OrderStatus.delivered,
      );

      expect(order.status, OrderStatus.delivered);
    });
  });

  // ── updateOrderQuantity ──────────────────────────────────────────────────

  group('updateOrderQuantity', () {
    test('returns updated order with new quantity', () async {
      when(() => mockClient.patch(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
              jsonEncode(_orderJson(quantityKg: 25)),
              200));

      final order = await service.updateOrderQuantity('o1', 25);
      expect(order.quantityKg, 25);
    });
  });

  // ── deleteOrder ──────────────────────────────────────────────────────────

  group('deleteOrder', () {
    test('completes without error on success', () async {
      when(() => mockClient.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('', 204));

      await expectLater(service.deleteOrder('o1'), completes);
    });

    test('throws ApiException on failure', () async {
      when(() => mockClient.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"detail": "Forbidden"}', 403));

      expect(
        () => service.deleteOrder('o1'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ── _mapOrderFromJson field aliases (tested through fetchOrders) ──────────

  group('_mapOrderFromJson field aliases', () {
    test('uses order_id when id is absent', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([_orderJson(orderId: 'alias-o1')]),
                200,
              ));

      final orders = await service.fetchOrders();
      expect(orders.first.id, 'alias-o1');
    });

    test('uses quantity_requested alias when quantity_kg absent', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([
                  {
                    'id': 'o1',
                    'product_name': 'Beans',
                    'quantity_requested': 30.0,
                    'status': 'pending',
                    'hub_name': 'Hub C',
                  }
                ]),
                200,
              ));

      final orders = await service.fetchOrders();
      expect(orders.first.quantityKg, 30.0);
    });

    test('uses provider_name alias when hub_name absent', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([
                  {
                    'id': 'o1',
                    'product_name': 'Oil',
                    'quantity_kg': 5.0,
                    'status': 'pending',
                    'provider_name': 'Provider X',
                  }
                ]),
                200,
              ));

      final orders = await service.fetchOrders();
      expect(orders.first.hubName, 'Provider X');
    });

    test('maps unknown status to pending', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([_orderJson(status: 'unknown_status')]),
                200,
              ));

      final orders = await service.fetchOrders();
      expect(orders.first.status, OrderStatus.pending);
    });

    test('maps triggered status string', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([_orderJson(status: 'triggered')]),
                200,
              ));
      final orders = await service.fetchOrders();
      expect(orders.first.status, OrderStatus.triggered);
    });

    test('maps delivered status string', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([_orderJson(status: 'delivered')]),
                200,
              ));
      final orders = await service.fetchOrders();
      expect(orders.first.status, OrderStatus.delivered);
    });

    test('maps completed status string', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([_orderJson(status: 'completed')]),
                200,
              ));
      final orders = await service.fetchOrders();
      expect(orders.first.status, OrderStatus.completed);
    });

    test('batch_id is populated when present', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([_orderJson(batchId: 'b99')]),
                200,
              ));

      final orders = await service.fetchOrders();
      expect(orders.first.batchId, 'b99');
    });
  });
}
