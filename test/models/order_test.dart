// ============================================================================
// Tests for Order model and OrderStatus enum
// ============================================================================
import 'package:batchit/models/order.dart';
import 'package:flutter_test/flutter_test.dart';

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
  group('Order construction', () {
    test('stores all required fields', () {
      final o = makeOrder(
        id: 'abc',
        productName: 'Sugar',
        quantityKg: 25.5,
        status: OrderStatus.delivered,
        hubName: 'Hub B',
      );
      expect(o.id, 'abc');
      expect(o.productName, 'Sugar');
      expect(o.quantityKg, 25.5);
      expect(o.status, OrderStatus.delivered);
      expect(o.hubName, 'Hub B');
      expect(o.batchId, isNull);
    });

    test('stores optional batchId', () {
      final o = makeOrder(batchId: 'batch-99');
      expect(o.batchId, 'batch-99');
    });

    test('batchId defaults to null', () {
      expect(makeOrder().batchId, isNull);
    });
  });

  group('OrderStatus enum', () {
    test('has four values', () {
      expect(OrderStatus.values.length, 4);
    });

    test('values are pending, triggered, delivered, completed', () {
      expect(OrderStatus.values, containsAll([
        OrderStatus.pending,
        OrderStatus.triggered,
        OrderStatus.delivered,
        OrderStatus.completed,
      ]));
    });

    test('each status has unique index', () {
      final indices = OrderStatus.values.map((s) => s.index).toSet();
      expect(indices.length, OrderStatus.values.length);
    });

    test('name property matches field name', () {
      expect(OrderStatus.pending.name, 'pending');
      expect(OrderStatus.triggered.name, 'triggered');
      expect(OrderStatus.delivered.name, 'delivered');
      expect(OrderStatus.completed.name, 'completed');
    });
  });

  group('Order equality', () {
    test('two orders with same values are distinct objects', () {
      final o1 = makeOrder(id: 'x');
      final o2 = makeOrder(id: 'x');
      // Dart data classes don't auto-implement ==, so they are different objects
      expect(identical(o1, o2), false);
      expect(o1.id, o2.id);
    });
  });
}
