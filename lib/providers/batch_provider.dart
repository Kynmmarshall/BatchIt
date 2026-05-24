// ============================================================================
// [BatchProvider] - Manages batch listings and batch-related operations
// ============================================================================
// Extends ChangeNotifier to provide reactive state management for batches.
//
// Responsibilities:
// - Maintain cached list of available batches (_batches)
// - Expose loading state during async operations
// - Load nearby batches from service (home screen on mount)
// - Find individual batch by ID (detail views)
// - Create new batches (form submission)
// - Update batch quantities when users join (joinBatch)
//
// Note: joining a batch via /batches/<id>/join/ is the single source of
// truth. Do NOT also call /orders/ - that would double-count the quantity.
// ============================================================================
import 'dart:io';
import 'package:batchit/models/batch.dart';
import 'package:batchit/services/api_client.dart';
import 'package:batchit/services/provider_service.dart';
import 'package:batchit/services/batch_service.dart';
import 'package:flutter/material.dart';

class BatchProvider extends ChangeNotifier {
  BatchProvider(this._batchService, this._providerService);

  final BatchService _batchService;
  final ProviderService _providerService;

  List<Batch> _batches = const [];
  List<Batch> _myCreatedBatches = const [];
  List<Batch> _myJoinedBatches = const [];
  List<Batch> _cachedBatches = const [];
  bool _isLoading = false;

  List<Batch> get batches => _batches;
  List<Batch> get myCreatedBatches => _myCreatedBatches;
  List<Batch> get myJoinedBatches => _myJoinedBatches;
  bool get isLoading => _isLoading;

  Future<void> loadNearbyBatches() async {
    _isLoading = true;
    notifyListeners();

    final openBatches = await _batchService.fetchNearbyBatches(status: 'open');
    final filledBatches = await _batchService.fetchNearbyBatches(
      status: 'filled',
    );
    final merged = <String, Batch>{};
    for (final b in openBatches) {
      merged[b.id] = b;
    }
    for (final b in filledBatches) {
      merged[b.id] = b;
    }
    _batches = merged.values.toList(growable: false);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyCreatedBatches() async {
    _isLoading = true;
    notifyListeners();
    _myCreatedBatches = await _batchService.fetchMyCreatedBatches();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyJoinedBatches() async {
    _isLoading = true;
    notifyListeners();
    _myJoinedBatches = await _batchService.fetchMyJoinedBatches();
    _isLoading = false;
    notifyListeners();
  }

  Batch? findById(String id) {
    for (final batch in [
      ..._batches,
      ..._myCreatedBatches,
      ..._myJoinedBatches,
      ..._cachedBatches,
    ]) {
      if (batch.id == id) return batch;
    }
    return null;
  }

  Future<Batch> refreshBatch(String batchId) async {
    final refreshed = await _batchService.fetchBatchById(batchId);
    _cacheBatch(refreshed);
    notifyListeners();
    return refreshed;
  }

  Future<Batch> createBatch({
    required String productName,
    required double bulkSizeKg,
    required String location,
    String unit = 'kg',
    String? providerId,
    String? notes,
    File? image,
  }) async {
    final batch = await _batchService.createBatch(
      productName: productName,
      bulkSizeKg: bulkSizeKg,
      location: location,
      unit: unit,
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

  Future<Batch> updateBatch(
    String batchId, {
    String? productName,
    double? bulkSizeKg,
    String? location,
    String? status,
    String? notes,
  }) async {
    final updated = await _batchService.updateBatch(
      batchId,
      productName: productName,
      bulkSizeKg: bulkSizeKg,
      location: location,
      status: status,
      notes: notes,
    );
    _batches = _batches
        .map((b) => b.id == batchId ? updated : b)
        .toList(growable: false);
    _myCreatedBatches = _myCreatedBatches
        .map((b) => b.id == batchId ? updated : b)
        .toList(growable: false);
    _myJoinedBatches = _myJoinedBatches
        .map((b) => b.id == batchId ? updated : b)
        .toList(growable: false);
    _cachedBatches = _upsertBatch(_cachedBatches, updated);
    notifyListeners();
    return updated;
  }

  Future<void> deleteBatch(String batchId) async {
    await _batchService.deleteBatch(batchId);
    _batches = _batches.where((b) => b.id != batchId).toList(growable: false);
    _myCreatedBatches = _myCreatedBatches
        .where((b) => b.id != batchId)
        .toList(growable: false);
    _myJoinedBatches = _myJoinedBatches
        .where((b) => b.id != batchId)
        .toList(growable: false);
    _cachedBatches = _cachedBatches
        .where((b) => b.id != batchId)
        .toList(growable: false);
    notifyListeners();
  }

  /// Joins a batch.
  ///
  /// Only calls `/batches/<id>/join/` - that endpoint is the single source
  /// of truth for quantity tracking. Do NOT call /orders/ afterwards; doing
  /// so would double the recorded quantity for every join.
  Future<void> joinBatch({
    required String batchId,
    required double quantityKg,
  }) async {
    try {
      final batch = await refreshBatch(batchId);

      if (!batch.isOpen || batch.isFull) {
        throw ApiException(
          statusCode: 400,
          message: batch.isFull
              ? 'This batch is already full.'
              : 'This batch is not open for joining.',
        );
      }

      // Single backend call — /batches/<id>/join/ handles everything:
      // participant record, filled_quantity update, full-batch notification.
      final remainingQuantity = batch.bulkSizeKg - batch.currentQuantityKg;
      if (quantityKg > remainingQuantity) {
        throw ApiException(
          statusCode: 400,
          message:
              'Only ${remainingQuantity.toStringAsFixed(2)} ${batch.unit} remaining in this batch.',
        );
      }

      await _batchService.joinBatch(batchId, quantityKg);

      if (batch.providerId != null && batch.providerId!.isNotEmpty) {
        try {
          await _providerService.followProvider(batch.providerId!);
        } catch (e) {
          debugPrint('[BatchProvider] auto-follow on join failed: $e');
        }
      }

      final updatedQuantity = (batch.currentQuantityKg + quantityKg)
          .clamp(0, batch.bulkSizeKg)
          .toDouble();

      // Optimistic local update so the home screen reflects the change immediately.
      final updatedBatch = Batch(
        id: batch.id,
        creatorId: batch.creatorId,
        providerId: batch.providerId,
        status: updatedQuantity >= batch.bulkSizeKg ? 'filled' : batch.status,
        productName: batch.productName,
        bulkSizeKg: batch.bulkSizeKg,
        currentQuantityKg: updatedQuantity,
        unit: batch.unit,
        locationName: batch.locationName,
        hubName: batch.hubName,
        imageUrl: batch.imageUrl,
        notes: batch.notes,
      );

      _cacheBatch(updatedBatch, addToJoined: true);

      notifyListeners();
    } on ApiException catch (e) {
      if (e.statusCode == 400) {
        try {
          await refreshBatch(batchId);
        } catch (_) {
          // Keep the original join failure; refresh is only for cache repair.
        }
      } else {
        debugPrint('Failed to join batch: $e');
      }
      rethrow;
    } catch (e) {
      debugPrint('Failed to join batch: $e');
      rethrow;
    }
  }

  void _cacheBatch(
    Batch batch, {
    bool addToAvailable = false,
    bool addToJoined = false,
  }) {
    _batches = _upsertBatch(_batches, batch, insertIfMissing: addToAvailable);
    _myCreatedBatches = _upsertBatch(_myCreatedBatches, batch);
    _myJoinedBatches = _upsertBatch(
      _myJoinedBatches,
      batch,
      insertIfMissing: addToJoined,
    );
    _cachedBatches = _upsertBatch(_cachedBatches, batch, insertIfMissing: true);
  }

  List<Batch> _upsertBatch(
    List<Batch> batches,
    Batch batch, {
    bool insertIfMissing = false,
  }) {
    var found = false;
    final updated = batches
        .map((item) {
          if (item.id != batch.id) return item;
          found = true;
          return batch;
        })
        .toList(growable: false);

    if (found || !insertIfMissing) return updated;
    return [batch, ...updated];
  }
}
