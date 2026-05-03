import 'package:batchit/models/batch.dart';
import 'package:batchit/models/order.dart';
import 'package:batchit/providers/order_provider.dart';
import 'package:batchit/services/batch_service.dart';
import 'package:flutter/material.dart';

class BatchProvider extends ChangeNotifier {
  BatchProvider(this._batchService, this._orderProvider);

  final BatchService _batchService;
  final OrderProvider _orderProvider;

  List<Batch> _batches = const [];
  bool _isLoading = false;

  List<Batch> get batches => _batches;
  bool get isLoading => _isLoading;

  Future<void> loadNearbyBatches() async {
    _isLoading = true;
    notifyListeners();

    _batches = await _batchService.fetchNearbyBatches();

    _isLoading = false;
    notifyListeners();
  }

  Batch? findById(String id) {
    for (final batch in _batches) {
      if (batch.id == id) {
        return batch;
      }
    }
    return null;
  }

  Future<Batch> createBatch({
    required String productName,
    required double bulkSizeKg,
    required String location,
  }) async {
    final batch = await _batchService.createBatch(
      productName: productName,
      bulkSizeKg: bulkSizeKg,
      location: location,
    );
    _batches = [batch, ..._batches];
    notifyListeners();
    return batch;
  }

  void joinBatch({required String batchId, required double quantityKg}) {
    Batch? updatedBatch;
    _batches = _batches
        .map(
          (batch) => batch.id == batchId
              ? Batch(
                  id: batch.id,
                  productName: batch.productName,
                  bulkSizeKg: batch.bulkSizeKg,
                  currentQuantityKg: batch.currentQuantityKg + quantityKg,
                  locationName: batch.locationName,
                  hubName: batch.hubName,
                )
              : batch,
        )
        .toList(growable: false);
    updatedBatch = findById(batchId);
    
    if (updatedBatch != null && updatedBatch.isFull) {
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: updatedBatch.productName,
        quantityKg: updatedBatch.currentQuantityKg,
        status: OrderStatus.triggered,
        hubName: updatedBatch.hubName,
        batchId: updatedBatch.id,
      );
      _orderProvider.addOrder(order);
    }
    
    notifyListeners();
  }
}
