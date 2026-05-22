import 'package:batchit/models/order.dart';
import 'package:flutter/foundation.dart';
import 'package:batchit/services/api_client.dart';

/// ============================================================================
/// [OrderService] - Handles order operations with Django backend
/// ============================================================================
/// Provides CRUD operations for orders including fetching user's orders,
/// creating new orders, fetching order details, and updating order status.
/// All requests are made through ApiClient to the /api/orders/ endpoints.
///
/// Endpoints (backend):
/// - GET /api/orders/                    (list user's orders)
/// - POST /api/orders/                   (create)
/// - GET /api/orders/<id>/               (retrieve)
/// - PATCH /api/orders/<id>/             (update)
/// - DELETE /api/orders/<id>/            (delete - for user's own orders)
/// ============================================================================

class OrderService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches the current user's orders with optional status filter.
  /// Falls back to mock data if API call fails (for dev/testing).
  Future<List<Order>> fetchOrders({OrderStatus? status}) async {
    try {
      final params = {
        if (status != null) 'status': status.name,
      };

      final response = await _apiClient.get(
        '/orders/',
        params: params,
      );

      // Expected response: { 'results': [...] } or [...]
      final List<dynamic> orderList = response is List ? response : response['results'] ?? [];

      return orderList
          .map((orderJson) => _mapOrderFromJson(orderJson as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      debugPrint('Failed to fetch orders: $e, using mock data');
      // Fall back to mock data for development
      return _getMockOrders();
    }
  }

  /// Creates a new order.
  /// Backend will create a BatchParticipant entry linking customer to batch.
  Future<Order> createOrder({
    required String batchId,
    required double quantityKg,
  }) async {
    try {
      final response = await _apiClient.post(
        '/orders/',
        body: {
          'batch_id': batchId,
          'quantity_requested': quantityKg,
        },
      );

      return _mapOrderFromJson(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      rethrow;
    }
  }

  /// Fetches a specific order by ID.
  Future<Order> fetchOrderById(String orderId) async {
    try {
      final response = await _apiClient.get('/orders/$orderId/');
      return _mapOrderFromJson(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      rethrow;
    }
  }

  /// Updates an order's status (e.g., mark as delivered or completed).
  /// Typically called by provider to trigger or fulfill.
  Future<Order> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  ) async {
    try {
      final response = await _apiClient.patch(
        '/orders/$orderId/',
        body: {
          'status': newStatus.name,
        },
      );

      return _mapOrderFromJson(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      rethrow;
    }
  }

  /// Deletes an order (typically only by order owner or admin).
  Future<void> deleteOrder(String orderId) async {
    try {
      await _apiClient.delete('/orders/$orderId/');
    } on ApiException catch (e) {
      rethrow;
    }
  }

  /// Maps backend order JSON to frontend Order model.
  Order _mapOrderFromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'pending';
    final status = OrderStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => OrderStatus.pending,
    );

    return Order(
      id: json['id'] as String? ?? json['order_id'] as String? ?? 'unknown',
      productName: json['product_name'] as String? ?? 'Unknown Product',
      quantityKg: (json['quantity_kg'] as num?)?.toDouble() ??
          (json['quantity_requested'] as num?)?.toDouble() ?? 0.0,
      status: status,
      hubName: json['hub_name'] as String? ??
          json['provider_name'] as String? ?? '',
      batchId: json['batch_id'] as String?,
    );
  }

  /// Returns mock order data for development/testing when API is unavailable.
  List<Order> _getMockOrders() {
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
