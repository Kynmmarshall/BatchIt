enum OrderStatus { pending, triggered, delivered, completed }

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
