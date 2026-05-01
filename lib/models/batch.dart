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

  double get progress =>
      bulkSizeKg == 0 ? 0 : (currentQuantityKg / bulkSizeKg).clamp(0, 1);

  bool get isFull => currentQuantityKg >= bulkSizeKg;

  String get imageAssetPath {
    final name = productName
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9]+"), '_')
        .replaceAll(RegExp(r'^_+|_+\$'), '');
    return 'assets/batches/$name.jpg';
  }
}
