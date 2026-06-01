// ============================================================================
// [HiveBatch] - Hive-persisted batch model
// ============================================================================
// Extends Batch with Hive serialization capabilities for local caching.
// Enables offline access to batch listings and reduces network requests.
//
// Usage:
// - Stored in 'batches' Hive box with batch ID as key
// - Cached from BatchService API responses
// - Used for offline display in BatchProvider
// ============================================================================
import 'package:hive/hive.dart';

part 'hive_batch.g.dart';

@HiveType(typeId: 1)
class HiveBatch extends HiveObject {
  HiveBatch();

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String productName;

  @HiveField(2)
  late double bulkSizeKg;

  @HiveField(3)
  late double currentQuantityKg;

  @HiveField(4)
  late String locationName;

  @HiveField(5)
  late String hubName;

  /// Calculates the fill progress of this batch (0.0 to 1.0).
  /// Returns 0 if bulkSizeKg is 0 to avoid division by zero.
  double get progress =>
      bulkSizeKg == 0 ? 0 : (currentQuantityKg / bulkSizeKg).clamp(0, 1);

  /// Indicates whether this batch has reached its target quantity.
  bool get isFull => currentQuantityKg >= bulkSizeKg;

  /// Derives the asset image path from the product name.
  String get imageAssetPath {
    final name = productName
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9]+"), '_')
        .replaceAll(RegExp(r'^_+|_+\$'), '');
    return 'assets/batches/$name.jpg';
  }

  /// Converts HiveBatch to map for API or serialization.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'bulkSizeKg': bulkSizeKg,
      'currentQuantityKg': currentQuantityKg,
      'locationName': locationName,
      'hubName': hubName,
    };
  }

  /// Factory constructor to create HiveBatch from map.
  factory HiveBatch.fromMap(Map<String, dynamic> map) {
    final batch = HiveBatch();
    batch.id = map['id'] ?? '';
    batch.productName = map['productName'] ?? '';
    batch.bulkSizeKg = (map['bulkSizeKg'] ?? 0).toDouble();
    batch.currentQuantityKg = (map['currentQuantityKg'] ?? 0).toDouble();
    batch.locationName = map['locationName'] ?? '';
    batch.hubName = map['hubName'] ?? '';
    return batch;
  }

  @override
  String toString() =>
      'HiveBatch(id: $id, productName: $productName, bulkSizeKg: $bulkSizeKg, currentQuantityKg: $currentQuantityKg)';
}
