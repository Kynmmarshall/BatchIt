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
import 'dart:io';
import 'package:batchit/models/batch.dart';
import 'package:batchit/providers/order_provider.dart';
import 'package:batchit/services/provider_service.dart';
import 'package:batchit/services/batch_service.dart';
import 'package:flutter/material.dart';

class BatchProvider extends ChangeNotifier {
  BatchProvider(this._batchService, this._orderProvider, this._providerService);

  final BatchService _batchService;
  final OrderProvider _orderProvider;
  final ProviderService _providerService;

  List<Batch> _batches = const [];
  List<Batch> _myCreatedBatches = const [];
  List<Batch> _myJoinedBatches = const [];
  bool _isLoading = false;

  List<Batch> get batches => _batches;
  List<Batch> get myCreatedBatches => _myCreatedBatches;
  List<Batch> get myJoinedBatches => _myJoinedBatches;
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

  /// Fetches batches created by the authenticated user.
  Future<void> loadMyCreatedBatches() async {
    _isLoading = true;
    notifyListeners();
    _myCreatedBatches = await _batchService.fetchMyCreatedBatches();
    _isLoading = false;
    notifyListeners();
  }

  /// Fetches batches the authenticated user has joined as a participant.
  Future<void> loadMyJoinedBatches() async {
    _isLoading = true;
    notifyListeners();
    _myJoinedBatches = await _batchService.fetchMyJoinedBatches();
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
    String? providerId,
    String? notes,
    File? image,
  }) async {
    final batch = await _batchService.createBatch(
      productName: productName,
      bulkSizeKg: bulkSizeKg,
      location: location,
      providerId: providerId,
      notes: notes,
      image: image,
    );

    if (providerId != null && providerId.isNotEmpty) {
      try {
        await _providerService.followProvider(providerId);
      } catch (e) {
        debugPrint('[BatchProvider] auto-follow on create failed: $e');
      }
    }

    _batches = [batch, ..._batches];
    _myCreatedBatches = [batch, ..._myCreatedBatches];
    notifyListeners();
    return batch;
  }

  /// Joins a batch by calling the backend service and updating local state.
  /// If batch reaches full threshold after join, creates Order and notifies OrderProvider.
  /// This implements the business logic: batch full → auto-trigger order.
  ///
  /// Parameters:
  ///   - batchId: ID of batch to update
  ///   - quantityKg: Amount user is committing to this batch
  Future<void> joinBatch({required String batchId, required double quantityKg}) async {
    try {
      Batch? batch;
      try {
        batch = _batches.firstWhere((batch) => batch.id == batchId);
      } catch (_) {
        batch = await _batchService.fetchBatchById(batchId);
      }

      // Call backend API to join batch
      await _batchService.joinBatch(batchId, quantityKg);

      if (batch.providerId != null && batch.providerId!.isNotEmpty) {
        try {
          await _providerService.followProvider(batch.providerId!);
        } catch (e) {
          debugPrint('[BatchProvider] auto-follow on join failed: $e');
        }
      }

      // Add to joined list immediately so ChatScreen shows it without a reload.
      if (!_myJoinedBatches.any((b) => b.id == batchId)) {
        _myJoinedBatches = [batch, ..._myJoinedBatches];
      }

      // Update local state
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
      notifyListeners();

      // Persist the participation as an order via the backend.
      await _orderProvider.createOrder(batchId: batchId, quantityKg: quantityKg);
    } catch (e) {
      debugPrint('Failed to join batch: $e');
      rethrow;
    }
  }
}
