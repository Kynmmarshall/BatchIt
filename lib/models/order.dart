/// ============================================================================
/// [OrderStatus] - Enumeration of possible order states
/// ============================================================================
enum OrderStatus { pending, triggered, delivered, completed }

/// ============================================================================
/// [Order] - Represents a user's order for a specific batch or standalone
/// ============================================================================
/// Encapsulates all immutable order data including product, quantity, status,
/// and optional linkage to a batch. Orders progress through states as they
/// are fulfilled (pending → triggered → delivered → completed).
///
/// Key responsibilities:
/// - Store immutable order state and metadata
/// - Provide comparison basis for order filtering and sorting
/// - Link to parent batch when order fulfills a batch requirement
/// ============================================================================
class Order {
  const Order({
    required this.id,
    required this.productName,
    required this.quantityKg,
    required this.status,
    required this.hubName,
    this.batchId,
  });

  final String id;
  final String productName;
  final double quantityKg;
  final OrderStatus status;
  final String hubName;
  final String? batchId;
}
