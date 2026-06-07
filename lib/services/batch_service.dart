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
/// - GET /api/batches/`<id>`/              (retrieve)
/// - PATCH /api/batches/`<id>`/            (update)
/// - POST /api/batches/`<id>`/join/        (join batch - custom action)
/// ============================================================================

// Top-level functions required by compute() — must not be closures or instance methods.
List<Batch> _parseBatchList(List<dynamic> raw) =>
    raw.map((e) => _batchFromJson(e as Map<String, dynamic>)).toList();

Batch _batchFromJson(Map<String, dynamic> json) => Batch(
      id: json['id'] as String? ?? json['batch_id'] as String? ?? 'unknown',
      providerId: json['provider_id'] as String?,
      creatorId: json['creator_id'] as String?,
      status: json['status'] as String? ?? 'open',
      productName: json['product_name'] as String? ?? 'Unknown Product',
      bulkSizeKg: (json['bulk_size_kg'] as num?)?.toDouble() ??
          (json['total_quantity'] as num?)?.toDouble() ?? 0.0,
      currentQuantityKg: (json['current_quantity_kg'] as num?)?.toDouble() ??
          (json['filled_quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'kg',
      locationName: json['location_name'] as String? ??
          json['location'] as String? ?? '',
      hubName: json['hub_name'] as String? ??
          json['provider_name'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      notes: json['notes'] as String?,
    );

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

      return compute(_parseBatchList, batchList);
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
    String unit = 'kg',
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
        'unit': unit,
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
          'unit': unit,
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
      return compute(_parseBatchList, batchList);
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
      return compute(_parseBatchList, batchList);
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
    String? productName,
    double? bulkSizeKg,
    String? location,
    String? status,
    String? notes,
    File? image,
  }) async {
    final dynamic response;
    if (image != null) {
      final fields = <String, String>{};
      if (productName != null) fields['product_name'] = productName;
      if (bulkSizeKg != null) fields['total_quantity'] = bulkSizeKg.toString();
      if (location != null) fields['location_name'] = location;
      if (status != null) fields['status'] = status;
      if (notes != null) fields['notes'] = notes;
      response = await _apiClient.patchMultipart(
        '/batches/$batchId/edit/',
        fields: fields,
        file: image,
        fileField: 'image',
      );
    } else {
      final body = <String, dynamic>{};
      if (productName != null) body['product_name'] = productName;
      if (bulkSizeKg != null) body['total_quantity'] = bulkSizeKg;
      if (location != null) body['location_name'] = location;
      if (status != null) body['status'] = status;
      if (notes != null) body['notes'] = notes;
      response = await _apiClient.patch('/batches/$batchId/edit/', body: body);
    }
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
    await _apiClient.delete('/batches/$batchId/edit/');
  }

  Batch _mapBatchFromJson(Map<String, dynamic> json) => _batchFromJson(json);

}
