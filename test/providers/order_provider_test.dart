// ============================================================================
// Tests for OrderProvider
// ============================================================================
import 'package:batchit/models/order.dart';
import 'package:batchit/providers/order_provider.dart';
import 'package:batchit/services/order_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderService extends Mock implements OrderService {}

Order makeOrder({
  String id = 'o1',
  String productName = 'Rice',
  double quantityKg = 10,
  OrderStatus status = OrderStatus.pending,
  String hubName = 'Hub A',
  String? batchId,
}) =>
    Order(
      id: id,
      productName: productName,
      quantityKg: quantityKg,
      status: status,
      hubName: hubName,
      batchId: batchId,
    );

void main() {
  late MockOrderService mockService;
  late OrderProvider provider;

  setUp(() {
    mockService = MockOrderService();
    provider = OrderProvider(mockService);
  });

  group('initial state', () {
    test('orders is empty', () => expect(provider.orders, isEmpty));
    test('isLoading is false', () => expect(provider.isLoading, false));
  });

  group('loadOrders', () {
    test('populates orders from service', () async {
      final orders = [makeOrder(id: 'o1'), makeOrder(id: 'o2')];
      when(() => mockService.fetchOrders(status: any(named: 'status')))
          .thenAnswer((_) async => orders);

      await provider.loadOrders();

      expect(provider.orders.length, 2);
      expect(provider.isLoading, false);
    });

    test('sets isLoading to false after completion', () async {
      when(() => mockService.fetchOrders(status: any(named: 'status')))
          .thenAnswer((_) async => []);

      await provider.loadOrders();

      expect(provider.isLoading, false);
    });

    test('replaces previous orders on reload', () async {
      when(() => mockService.fetchOrders(status: any(named: 'status')))
          .thenAnswer((_) async => [makeOrder(id: 'first')]);
      await provider.loadOrders();

      when(() => mockService.fetchOrders(status: any(named: 'status')))
          .thenAnswer((_) async => [makeOrder(id: 'second'), makeOrder(id: 'third')]);
      await provider.loadOrders();

      expect(provider.orders.length, 2);
      expect(provider.orders.first.id, 'second');
    });
  });

  group('addOrder', () {
    test('prepends order to list', () {
      provider.addOrder(makeOrder(id: 'new'));
      expect(provider.orders.first.id, 'new');
    });

    test('accumulates multiple added orders', () {
      provider.addOrder(makeOrder(id: 'a'));
      provider.addOrder(makeOrder(id: 'b'));
      expect(provider.orders.length, 2);
      expect(provider.orders.first.id, 'b'); // most recent first
    });
  });

  group('findById', () {
    setUp(() {
      provider.addOrder(makeOrder(id: 'target'));
      provider.addOrder(makeOrder(id: 'other'));
    });

    test('returns order when found', () {
      expect(provider.findById('target'), isNotNull);
      expect(provider.findById('target')!.id, 'target');
    });

    test('returns null when not found', () {
      expect(provider.findById('missing'), isNull);
    });
  });

  group('updateOrderStatus', () {
    test('changes status of existing order', () {
      provider.addOrder(makeOrder(id: 'o1', status: OrderStatus.pending));

      provider.updateOrderStatus('o1', OrderStatus.completed);

      expect(provider.findById('o1')!.status, OrderStatus.completed);
    });

    test('does nothing when order not found', () {
      provider.addOrder(makeOrder(id: 'o1'));
      provider.updateOrderStatus('nonexistent', OrderStatus.delivered);
      // no exception — order list unchanged
      expect(provider.orders.length, 1);
    });
  });

  group('createOrder', () {
    test('prepends new order on success', () async {
      final created = makeOrder(id: 'created-1', productName: 'Corn', batchId: 'b1');
      when(
        () => mockService.createOrder(
          batchId: any(named: 'batchId'),
          quantityKg: any(named: 'quantityKg'),
        ),
      ).thenAnswer((_) async => created);

      await provider.createOrder(batchId: 'b1', quantityKg: 5);

      expect(provider.orders.first.id, 'created-1');
    });

    test('adds fallback order on service failure', () async {
      when(
        () => mockService.createOrder(
          batchId: any(named: 'batchId'),
          quantityKg: any(named: 'quantityKg'),
        ),
      ).thenThrow(Exception('network error'));

      await provider.createOrder(batchId: 'bx', quantityKg: 10);

      // Fallback order added with pending status
      expect(provider.orders.length, 1);
      expect(provider.orders.first.status, OrderStatus.pending);
    });
  });

  group('updateQuantity', () {
    test('replaces order in list when found', () async {
      provider.addOrder(makeOrder(id: 'o5', quantityKg: 10));
      final updated = makeOrder(id: 'o5', quantityKg: 20);
      when(
        () => mockService.updateOrderQuantity(any(), any()),
      ).thenAnswer((_) async => updated);

      await provider.updateQuantity('o5', 20);

      expect(provider.findById('o5')!.quantityKg, 20);
    });

    test('inserts at front when order not already in list', () async {
      final updated = makeOrder(id: 'oNew', quantityKg: 15);
      when(
        () => mockService.updateOrderQuantity(any(), any()),
      ).thenAnswer((_) async => updated);

      await provider.updateQuantity('oNew', 15);

      expect(provider.orders.first.id, 'oNew');
    });
  });
}
