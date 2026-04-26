import 'package:batchit/models/batch.dart';

class BatchService {
  Future<List<Batch>> fetchNearbyBatches() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const [
      Batch(
        id: 'b_001',
        productName: 'Potatoes',
        bulkSizeKg: 50,
        currentQuantityKg: 23,
        locationName: 'Hay Salam',
        hubName: 'Hub Ain Sebaa',
      ),
      Batch(
        id: 'b_002',
        productName: 'Tomatoes',
        bulkSizeKg: 30,
        currentQuantityKg: 30,
        locationName: 'Maarif',
        hubName: 'Hub Centre',
      ),
      Batch(
        id: 'b_003',
        productName: 'Onions',
        bulkSizeKg: 40,
        currentQuantityKg: 17,
        locationName: 'Sidi Moumen',
        hubName: 'Hub East',
      ),
    ];
  }

  Future<Batch> createBatch({
    required String productName,
    required double bulkSizeKg,
    required String location,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return Batch(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productName: productName,
      bulkSizeKg: bulkSizeKg,
      currentQuantityKg: 0,
      locationName: location,
      hubName: 'Hub Auto',
    );
  }
}
