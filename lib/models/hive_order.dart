// ============================================================================
// [OrderStatusHive] - Hive-compatible order status enum
// ============================================================================
// Mirror of OrderStatus enum with Hive type annotations for persistence.
// Using separate enum ensures clean separation between domain and persistence layers.
import 'package:hive/hive.dart';

part 'hive_order.g.dart';

@HiveType(typeId: 2)
enum OrderStatusHive {
  @HiveField(0)
  pending,
  @HiveField(1)
  triggered,
  @HiveField(2)
  delivered,
  @HiveField(3)
  completed,
}

/// ============================================================================
/// [HiveOrder] - Hive-persisted order model
/// ============================================================================
/// Stores user orders in local cache for offline access and quick retrieval.
/// Links to parent batch when applicable for relationship tracking.
///
/// Usage:
/// - Stored in 'orders' Hive box with order ID as key
/// - Cached from OrderService API responses
/// - Used for offline display in OrderProvider
/// ============================================================================
@HiveType(typeId: 3)
class HiveOrder extends HiveObject {
  HiveOrder();

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String productName;

  @HiveField(2)
  late double quantityKg;

  @HiveField(3)
  late OrderStatusHive status;

  @HiveField(4)
  late String hubName;

  @HiveField(5)
  String? batchId;

  /// Converts HiveOrder to map for API or serialization.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'quantityKg': quantityKg,
      'status': status.toString().split('.').last,
      'hubName': hubName,
      'batchId': batchId,
    };
  }

  /// Factory constructor to create HiveOrder from map.
  factory HiveOrder.fromMap(Map<String, dynamic> map) {
    final order = HiveOrder();
    order.id = map['id'] ?? '';
    order.productName = map['productName'] ?? '';
    order.quantityKg = (map['quantityKg'] ?? 0).toDouble();
    order.hubName = map['hubName'] ?? '';
    order.batchId = map['batchId'];

    // Parse status string to enum
    final statusStr = (map['status'] ?? 'pending').toString().toLowerCase();
    order.status = OrderStatusHive.values.firstWhere(
      (e) => e.toString().split('.').last == statusStr,
      orElse: () => OrderStatusHive.pending,
    );

    return order;
  }

  @override
  String toString() =>
      'HiveOrder(id: $id, productName: $productName, quantityKg: $quantityKg, status: $status)';
}
