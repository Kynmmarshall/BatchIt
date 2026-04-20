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

    _orders = await _orderService.fetchOrders();

    _isLoading = false;
    notifyListeners();
  }

  void addOrder(Order order) {
    _orders = [order, ..._orders];
    notifyListeners();
  }
}
