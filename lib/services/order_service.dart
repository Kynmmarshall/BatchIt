import 'package:batchit/models/order.dart';

class OrderService {
  Future<List<Order>> fetchOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const [
      Order(
        id: 'o_001',
        productName: 'Potatoes',
        quantityKg: 5,
        status: OrderStatus.pending,
        hubName: 'Hub Ain Sebaa',
      ),
      Order(
        id: 'o_002',
        productName: 'Tomatoes',
        quantityKg: 3,
        status: OrderStatus.triggered,
        hubName: 'Hub Centre',
      ),
      Order(
        id: 'o_003',
        productName: 'Onions',
        quantityKg: 4,
        status: OrderStatus.completed,
        hubName: 'Hub East',
      ),
    ];
  }
}
