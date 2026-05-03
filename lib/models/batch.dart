/// ============================================================================
/// [Batch] - Represents a bulk purchasing batch in the marketplace
/// ============================================================================
/// Encapsulates all data related to a batch including product details,
/// quantity tracking, location, and progress metrics.
/// 
/// Key responsibilities:
/// - Store immutable batch state (id, productName, bulkSizeKg, etc.)
/// - Compute derived properties (progress %, isFull status, image path)
/// - Provide comparison basis for filtering and sorting batches
/// ============================================================================
class Batch {
  const Batch({
    required this.id,
    required this.productName,
    required this.bulkSizeKg,
    required this.currentQuantityKg,
    required this.locationName,
    required this.hubName,
  });

  final String id;
  final String productName;
  final double bulkSizeKg;
  final double currentQuantityKg;
  final String locationName;
  final String hubName;

  /// Calculates the fill progress of this batch (0.0 to 1.0).
  /// Returns 0 if bulkSizeKg is 0 to avoid division by zero.
  /// Clamped to [0, 1] range to ensure valid progress percentage.
  double get progress =>
      bulkSizeKg == 0 ? 0 : (currentQuantityKg / bulkSizeKg).clamp(0, 1);

  /// Indicates whether this batch has reached its target quantity.
  bool get isFull => currentQuantityKg >= bulkSizeKg;

  /// Derives the asset image path from the product name.
  /// Converts to lowercase and replaces non-alphanumeric chars with underscores.
  /// Example: "Olive Oil" → "assets/batches/olive_oil.jpg"
  String get imageAssetPath {
    final name = productName
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9]+"), '_')
        .replaceAll(RegExp(r'^_+|_+\$'), '');
    return 'assets/batches/$name.jpg';
  }
}
