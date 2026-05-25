// ============================================================================
// Tests for OrderCard widget
// ============================================================================
import 'package:batchit/models/order.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/providers/order_provider.dart';
import 'package:batchit/services/auth_service.dart';
import 'package:batchit/services/batch_service.dart';
import 'package:batchit/services/order_service.dart';
import 'package:batchit/services/provider_service.dart';
import 'package:batchit/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthService extends Mock implements AuthService {}
class MockOrderService extends Mock implements OrderService {}
class MockBatchService extends Mock implements BatchService {}
class MockProviderService extends Mock implements ProviderService {}

Order makeOrder({
  String id = 'o1',
  String productName = 'Rice',
  double quantityKg = 10,
  OrderStatus status = OrderStatus.pending,
  String hubName = 'Hub A',
}) =>
    Order(
      id: id,
      productName: productName,
      quantityKg: quantityKg,
      status: status,
      hubName: hubName,
    );

Widget buildCard(Order order, {String statusLabel = 'Pending'}) {
  final mockOrderService = MockOrderService();
  final mockBatchService = MockBatchService();
  final mockProviderService = MockProviderService();

  when(() => mockOrderService.fetchOrders(status: any(named: 'status')))
      .thenAnswer((_) async => []);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(MockAuthService()),
      ),
      ChangeNotifierProvider<OrderProvider>(
        create: (_) => OrderProvider(mockOrderService),
      ),
      ChangeNotifierProvider<BatchProvider>(
        create: (_) => BatchProvider(mockBatchService, mockProviderService),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          child: OrderCard(order: order, statusLabel: statusLabel),
        ),
      ),
    ),
  );
}

void main() {
  group('OrderCard renders core content', () {
    testWidgets('shows product name', (tester) async {
      await tester.pumpWidget(buildCard(makeOrder(productName: 'Sugar')));
      await tester.pump();
      expect(find.text('Sugar'), findsOneWidget);
    });

    testWidgets('shows quantity and hub text', (tester) async {
      await tester.pumpWidget(
        buildCard(makeOrder(quantityKg: 25, hubName: 'Hub B')),
      );
      await tester.pump();
      expect(find.textContaining('25'), findsOneWidget);
      expect(find.textContaining('Hub B'), findsOneWidget);
    });

    testWidgets('shows status label chip', (tester) async {
      await tester.pumpWidget(
        buildCard(makeOrder(), statusLabel: 'In Transit'),
      );
      await tester.pump();
      expect(find.text('In Transit'), findsOneWidget);
    });

    testWidgets('shows shipping icon', (tester) async {
      await tester.pumpWidget(buildCard(makeOrder()));
      await tester.pump();
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    });
  });
}
