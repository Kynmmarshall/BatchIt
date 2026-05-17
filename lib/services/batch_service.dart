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
  /// Falls back to mock data if API call fails (for dev/testing).
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
      debugPrint('Failed to fetch batches: $e, using mock data');
      // Fall back to mock data for development
      return _getMockBatches();
    }
  }

  /// Creates a new batch with the provided details.
  /// Requires authentication token.
  Future<Batch> createBatch({
    required String productName,
    required double bulkSizeKg,
    required String location,
    String? notes,
    DateTime? expiresAt,
  }) async {
    try {
      final response = await _apiClient.post(
        '/batches/',
        body: {
          'product_name': productName,
          'total_quantity': bulkSizeKg,
          'location': location,
          'notes': notes ?? '',
          'expires_at': expiresAt?.toIso8601String() ?? 
              DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'status': 'open',
        },
      );

      return _mapBatchFromJson(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      rethrow;
    }
  }

  /// Fetches a specific batch by ID.
  Future<Batch> fetchBatchById(String batchId) async {
    try {
      final response = await _apiClient.get('/batches/$batchId/');
      return _mapBatchFromJson(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      rethrow;
    }
  }

  /// Updates a batch (requires ownership or admin).
  Future<Batch> updateBatch(
    String batchId, {
    String? status,
    double? currentQuantityKg,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (status != null) body['status'] = status;
      if (currentQuantityKg != null) body['filled_quantity'] = currentQuantityKg;
      if (notes != null) body['notes'] = notes;

      final response = await _apiClient.patch(
        '/batches/$batchId/',
        body: body,
      );

      return _mapBatchFromJson(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      rethrow;
    }
  }

  /// Joins a batch (creates a batch participant entry).
  /// This is a custom action endpoint that handles the join logic.
  Future<void> joinBatch(String batchId, double quantityRequested) async {
    try {
      await _apiClient.post(
        '/batches/$batchId/join/',
        body: {
          'quantity_requested': quantityRequested,
        },
      );
    } on ApiException catch (e) {
      rethrow;
    }
  }

  /// Deletes a batch (requires ownership).
  Future<void> deleteBatch(String batchId) async {
    try {
      await _apiClient.delete('/batches/$batchId/');
    } on ApiException catch (e) {
      rethrow;
    }
  }

  /// Maps backend batch JSON to frontend Batch model.
  /// Handles field name differences between backend and frontend.
  Batch _mapBatchFromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['batch_id'] as String? ?? json['id'] as String? ?? 'unknown',
      productName: json['product_name'] as String? ?? 'Unknown Product',
      bulkSizeKg: (json['total_quantity'] as num?)?.toDouble() ?? 0.0,
      currentQuantityKg: (json['filled_quantity'] as num?)?.toDouble() ?? 0.0,
      locationName: json['location'] as String? ?? 'Unknown Location',
      hubName: json['provider_name'] as String? ?? 'Unknown Hub',
    );
  }

  /// Returns mock batch data for development/testing when API is unavailable.
  List<Batch> _getMockBatches() {
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
}
