import 'package:batchit/models/order.dart';
import 'package:batchit/services/order_service.dart';
import 'package:flutter/material.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._orderService);

  final OrderService _orderService;

  List<Order> _orders = const [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    final fetched = await _orderService.fetchOrders();
    _orders = List<Order>.from(fetched);

    _isLoading = false;
    notifyListeners();
  }

  void addOrder(Order order) {
    _orders = [order, ..._orders];
    notifyListeners();
  }

  Order? findById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  void updateOrderStatus(String id, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index == -1) return;
    final old = _orders[index];
    final updated = Order(
      id: old.id,
      productName: old.productName,
      quantityKg: old.quantityKg,
      status: status,
      hubName: old.hubName,
    );
    _orders[index] = updated;
    notifyListeners();
  }
}
