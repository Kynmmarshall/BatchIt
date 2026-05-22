/// ============================================================================
/// [OrderProvider] - Manages user orders and their lifecycle
/// ============================================================================
/// Extends ChangeNotifier to provide reactive state management for orders.
/// Coordinates with OrderService for data fetching and persistence.
///
/// Responsibilities:
/// - Maintain cached list of user orders (_orders)
/// - Expose loading state during async operations
/// - Load orders from service (My Batches screen on mount)
/// - Find individual order by ID (detail views)
/// - Add new orders (from batch join or manual creation)
/// - Update order status as fulfillment progresses
/// - Notify listeners of order state changes for UI rebuild
///
/// Dependencies:
/// - OrderService: Provides backend API calls for order operations
/// ============================================================================
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

  /// Fetches user orders from service and updates _orders list.
  /// Sets loading state before and after fetch for UI feedback.
  /// Called on My Batches screen mount and during manual refresh.
  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    final fetched = await _orderService.fetchOrders();
    _orders = List<Order>.from(fetched);

    _isLoading = false;
    notifyListeners();
  }

  /// Adds a new order to the front of _orders list and notifies listeners.
  void addOrder(Order order) {
    _orders = [order, ..._orders];
    notifyListeners();
  }

  /// Persists a new order to the backend then prepends it to the local list.
  /// Falls back to a local optimistic order if the API call fails.
  Future<void> createOrder({
    required String batchId,
    required double quantityKg,
  }) async {
    try {
      final order = await _orderService.createOrder(
        batchId: batchId,
        quantityKg: quantityKg,
      );
      _orders = [order, ..._orders];
      notifyListeners();
    } catch (e) {
      debugPrint('[OrderProvider] API createOrder failed: $e — adding local fallback');
      final fallback = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: 'Batch #$batchId',
        quantityKg: quantityKg,
        status: OrderStatus.pending,
        hubName: 'Unknown Hub',
        batchId: batchId,
      );
      _orders = [fallback, ..._orders];
      notifyListeners();
    }
  }

  /// Returns order with matching ID or null if not found.
  /// Uses firstWhere with exception handling for safe lookup.
  Order? findById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Updates order status locally.
  void updateOrderStatus(String id, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index == -1) return;
    final old = _orders[index];
    _orders[index] = Order(
      id: old.id,
      productName: old.productName,
      quantityKg: old.quantityKg,
      status: status,
      hubName: old.hubName,
      batchId: old.batchId,
    );
    notifyListeners();
  }

  /// Sends a quantity update to the backend and refreshes the local order.
  Future<void> updateQuantity(String orderId, double newQuantityKg) async {
    final updated = await _orderService.updateOrderQuantity(orderId, newQuantityKg);
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = updated;
    } else {
      _orders = [updated, ..._orders];
    }
    notifyListeners();
  }
}
