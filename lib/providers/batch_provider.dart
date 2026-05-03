/// ============================================================================
/// [BatchProvider] - Manages batch listings and batch-related operations
/// ============================================================================
/// Extends ChangeNotifier to provide reactive state management for batches.
/// Coordinates with BatchService for data fetching and with OrderProvider for
/// order creation when batches become full.
///
/// Responsibilities:
/// - Maintain cached list of available batches (_batches)
/// - Expose loading state during async operations
/// - Load nearby batches from service (home screen on mount)
/// - Find individual batch by ID (detail views)
/// - Create new batches (form submission)
/// - Update batch quantities when users join (joinBatch)
/// - Trigger Order creation when batch reaches fill threshold
///
/// Dependencies:
/// - BatchService: Provides backend API calls for batch operations
/// - OrderProvider: Receives notification to create orders when batch fills
/// ============================================================================
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

  /// Fetches nearby batches from service and updates _batches list.
  /// Sets loading state before and after fetch for UI feedback.
  /// Called on HomeScreen mount and during manual refresh.
  Future<void> loadNearbyBatches() async {
    _isLoading = true;
    notifyListeners();

    _batches = await _batchService.fetchNearbyBatches();

    _isLoading = false;
    notifyListeners();
  }

  /// Returns batch with matching ID or null if not found.
  /// Linear search through cached _batches list.
  Batch? findById(String id) {
    for (final batch in _batches) {
      if (batch.id == id) {
        return batch;
      }
    }
    return null;
  }

  /// Creates a new batch via service and prepends to _batches list.
  /// Notifies listeners to update UI with new batch in feed.
  /// Returns the created batch for caller to display confirmation.
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

  /// Updates a batch's currentQuantityKg when user joins.
  /// If batch reaches full threshold after join, creates Order and notifies OrderProvider.
  /// This implements the business logic: batch full → auto-trigger order.
  ///
  /// Parameters:
  ///   - batchId: ID of batch to update
  ///   - quantityKg: Amount user is committing to this batch
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
