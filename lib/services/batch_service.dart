import 'dart:io';
import 'package:batchit/models/batch.dart';
import 'package:flutter/foundation.dart';
import 'package:batchit/services/api_client.dart';

/// ============================================================================
/// [BatchService] - Handles batch operations with Django backend
/// ============================================================================
/// Provides CRUD operations for batches including fetching nearby batches,
/// creating new batches, fetching batch details, and joining batches.
/// All requests are made through ApiClient to the /api/batches/ endpoints.
///
/// Endpoints (backend):
/// - GET /api/batches/                   (list with filters)
/// - POST /api/batches/                  (create)
/// - GET /api/batches/<id>/              (retrieve)
/// - PATCH /api/batches/<id>/            (update)
/// - POST /api/batches/<id>/join/        (join batch - custom action)
/// ============================================================================

class BatchService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches nearby open batches that the user can join.
  Future<List<Batch>> fetchNearbyBatches({
    String status = 'open',
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    try {
      final params = {
        'status': status,
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
        if (radiusKm != null) 'radius_km': radiusKm.toString(),
      };

      final response = await _apiClient.get(
        '/batches/',
        params: params,
      );

      // Expected response: { 'results': [...] } or [...]
      final List<dynamic> batchList = response is List ? response : response['results'] ?? [];

      return batchList
          .map((batchJson) => _mapBatchFromJson(batchJson as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      debugPrint('Failed to fetch batches: $e');
      return [];
    }
  }

  /// Creates a new batch with the provided details.
  /// Uses multipart upload when [image] is provided, JSON otherwise.
  Future<Batch> createBatch({
    required String productName,
    required double bulkSizeKg,
    required String location,
    String? providerId,
    String? notes,
    DateTime? expiresAt,
    File? image,
  }) async {
    final expires = (expiresAt ?? DateTime.now().toUtc().add(const Duration(days: 7)))
        .toUtc()
        .toIso8601String();

    final dynamic response;
    if (image != null) {
      final fields = <String, String>{
        'product_name': productName,
        'total_quantity': bulkSizeKg.toString(),
        'location': location,
        if (providerId != null) 'provider_id': providerId,
        'notes': notes ?? '',
        'expires_at': expires,
        'status': 'open',
      };
      response = await _apiClient.postMultipart(
        '/batches/',
        fields: fields,
        files: [MapEntry('image', image)],
      );
    } else {
      response = await _apiClient.post(
        '/batches/',
        body: {
          'product_name': productName,
          'total_quantity': bulkSizeKg,
          'location': location,
          if (providerId != null) 'provider_id': providerId,
          'notes': notes ?? '',
          'expires_at': expires,
          'status': 'open',
        },
      );
    }

    return _mapBatchFromJson(response as Map<String, dynamic>);
  }

  /// Fetches batches created by the authenticated user.
  Future<List<Batch>> fetchMyCreatedBatches() async {
    try {
      final response = await _apiClient.get('/batches/', params: {'creator': 'me'});
      final List<dynamic> batchList = response is List ? response : response['results'] ?? [];
      return batchList
          .map((json) => _mapBatchFromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      debugPrint('[BatchService] fetchMyCreatedBatches failed: $e');
      return [];
    }
  }

  /// Fetches batches the authenticated user has joined as a participant.
  Future<List<Batch>> fetchMyJoinedBatches() async {
    try {
      final response = await _apiClient.get('/batches/', params: {'participant': 'me'});
      final List<dynamic> batchList = response is List ? response : response['results'] ?? [];
      return batchList
          .map((json) => _mapBatchFromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      debugPrint('[BatchService] fetchMyJoinedBatches failed: $e');
      return [];
    }
  }

  /// Fetches a specific batch by ID.
  Future<Batch> fetchBatchById(String batchId) async {
    final response = await _apiClient.get('/batches/$batchId/');
    return _mapBatchFromJson(response as Map<String, dynamic>);
  }

  /// Updates a batch (requires ownership or admin).
  Future<Batch> updateBatch(
    String batchId, {
    String? status,
    double? currentQuantityKg,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (currentQuantityKg != null) body['filled_quantity'] = currentQuantityKg;
    if (notes != null) body['notes'] = notes;

    final response = await _apiClient.patch('/batches/$batchId/', body: body);
    return _mapBatchFromJson(response as Map<String, dynamic>);
  }

  /// Joins a batch (creates a batch participant entry).
  Future<void> joinBatch(String batchId, double quantityRequested) async {
    await _apiClient.post(
      '/batches/$batchId/join/',
      body: {'quantity_requested': quantityRequested},
    );
  }

  /// Deletes a batch (requires ownership).
  Future<void> deleteBatch(String batchId) async {
    await _apiClient.delete('/batches/$batchId/');
  }

  /// Maps backend batch JSON to frontend Batch model.
  Batch _mapBatchFromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] as String? ?? json['batch_id'] as String? ?? 'unknown',
      providerId: json['provider_id'] as String?,
      productName: json['product_name'] as String? ?? 'Unknown Product',
      bulkSizeKg: (json['bulk_size_kg'] as num?)?.toDouble() ??
          (json['total_quantity'] as num?)?.toDouble() ?? 0.0,
      currentQuantityKg: (json['current_quantity_kg'] as num?)?.toDouble() ??
          (json['filled_quantity'] as num?)?.toDouble() ?? 0.0,
      locationName: json['location_name'] as String? ??
          json['location'] as String? ?? '',
      hubName: json['hub_name'] as String? ??
          json['provider_name'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
    );
  }

}
