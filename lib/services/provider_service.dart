import 'dart:io';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/services/api_client.dart';
import 'package:flutter/foundation.dart';

class ProviderService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches all verified providers. Falls back to mock data on failure.
  Future<List<ProviderProfile>> fetchVerifiedProviders() async {
    try {
      final response = await _apiClient.get('/providers/');
      debugPrint('[ProviderService] fetchVerifiedProviders response: $response');
      final items = response as List<dynamic>? ?? [];
      debugPrint('[ProviderService] Total items from API: ${items.length}');
      final verified = items
          .map((e) => ProviderProfile.fromJson(e as Map<String, dynamic>))
          .where((p) => p.isVerified)
          .toList();
      debugPrint('[ProviderService] Verified providers: ${verified.length}');

      // If API returns empty, use mock data for dev
      if (verified.isEmpty) {
        debugPrint('[ProviderService] Empty response, using mock data');
        return List.of(kMockVerifiedProviders);
      }
      return verified;
    } catch (e) {
      debugPrint('[ProviderService] fetchVerifiedProviders fallback: $e');
      return List.of(kMockVerifiedProviders);
    }
  }

  /// Returns the current user's provider profile, or null if not yet submitted.
  Future<ProviderProfile?> fetchMyProviderProfile() async {
    try {
      final response = await _apiClient.get('/providers/my-profile/');
      if (response == null) return null;
      return ProviderProfile.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[ProviderService] fetchMyProviderProfile error: $e');
      return null;
    }
  }

  /// Fetches a single provider by ID. Falls back to mock data.
  Future<ProviderProfile> fetchProviderById(String id) async {
    try {
      final response = await _apiClient.get('/providers/$id/');
      return ProviderProfile.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[ProviderService] fetchProviderById fallback: $e');
      return kMockVerifiedProviders.firstWhere(
        (p) => p.id == id,
        orElse: () => kMockVerifiedProviders.first,
      );
    }
  }

  /// Submits a new provider profile for admin review.
  /// Uses multipart when documents/logo are included, JSON otherwise.
  Future<ProviderProfile> submitProviderProfile({
    required String businessName,
    required String ownerName,
    required BusinessCategory category,
    required String registrationNumber,
    required String phone,
    required String email,
    required String address,
    double? latitude,
    double? longitude,
    required String description,
    List<File>? documents,
    File? logo,
  }) async {
    try {
      final fields = <String, String>{
        'business_name': businessName,
        'owner_name': ownerName,
        'category': category.name,
        'registration_number': registrationNumber,
        'phone': phone,
        'email': email,
        'address': address,
        'description': description,
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
      };

      final hasFiles = (documents != null && documents.isNotEmpty) || logo != null;

      dynamic response;
      if (hasFiles) {
        final fileEntries = <MapEntry<String, File>>[];
        if (logo != null) fileEntries.add(MapEntry('logo', logo));
        for (final doc in documents ?? <File>[]) {
          fileEntries.add(MapEntry('documents', doc));
        }
        response = await _apiClient.postMultipart(
          '/providers/register/',
          fields: fields,
          files: fileEntries,
        );
      } else {
        response = await _apiClient.post(
          '/providers/register/',
          body: Map<String, dynamic>.from(fields),
        );
      }

      return ProviderProfile.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[ProviderService] submitProviderProfile fallback: $e');
      // Dev fallback: return a pending profile locally so the UI flows
      return ProviderProfile(
        id: 'local-pending-${DateTime.now().millisecondsSinceEpoch}',
        ownerId: 'current-user',
        businessName: businessName,
        ownerName: ownerName,
        category: category,
        registrationNumber: registrationNumber,
        phone: phone,
        email: email,
        address: address,
        latitude: latitude,
        longitude: longitude,
        description: description,
        status: ProviderStatus.pending,
        createdAt: DateTime.now(),
      );
    }
  }
}
