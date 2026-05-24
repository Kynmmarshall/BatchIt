/// ============================================================================
/// [Batch] - Represents a bulk purchasing batch in the marketplace
/// ============================================================================
class Batch {
  const Batch({
    required this.id,
    this.providerId,
    this.creatorId,
    this.status = 'open',
    required this.productName,
    required this.bulkSizeKg,
    required this.currentQuantityKg,
    required this.locationName,
    required this.hubName,
    this.unit = 'kg',
    this.imageUrl,
    this.notes,
  });

  final String id;
  final String? providerId;
  final String? creatorId;
  final String status;
  final String productName;
  final double bulkSizeKg;
  final double currentQuantityKg;
  final String locationName;
  final String hubName;

  /// Measurement unit: 'kg', 'g', 'L', 'mL', 'units', 'boxes'
  final String unit;
  final String? imageUrl;
  final String? notes;

  double get progress =>
      bulkSizeKg == 0 ? 0 : (currentQuantityKg / bulkSizeKg).clamp(0, 1);

  bool get isFull => currentQuantityKg >= bulkSizeKg;

  bool get isOpen => status == 'open';

  bool get canJoin => isOpen && !isFull;

  String get imageAssetPath {
    final name = productName
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9]+"), '_')
        .replaceAll(RegExp(r'^_+|_+\$'), '');
    return 'assets/batches/$name.jpg';
  }
}
