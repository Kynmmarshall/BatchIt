import 'dart:io';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/services/api_client.dart';
import 'package:flutter/foundation.dart';

class ProviderService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches all verified providers from backend.
  Future<List<ProviderProfile>> fetchVerifiedProviders() async {
    try {
      final response = await _apiClient.get('/providers/');
      debugPrint('[ProviderService] fetchVerifiedProviders response: $response');
      final items = response is List
          ? response
          : (response as Map<String, dynamic>?)?['results'] as List<dynamic>? ?? [];
      debugPrint('[ProviderService] Total items from API: ${items.length}');
      final verified = items
          .map((e) => ProviderProfile.fromJson(e as Map<String, dynamic>))
          .where((p) => p.isVerified)
          .toList();
      debugPrint('[ProviderService] Verified providers: ${verified.length}');
      return verified;
    } catch (e) {
      debugPrint('[ProviderService] fetchVerifiedProviders error: $e');
      return [];
    }
  }

  /// Fetches ALL providers (verified and pending) — used by the map view.
  Future<List<ProviderProfile>> fetchAllProviders() async {
    try {
      final response = await _apiClient.get('/providers/');
      final items = response is List
          ? response
          : (response as Map<String, dynamic>?)?['results'] as List<dynamic>? ?? [];
      return items
          .map((e) => ProviderProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ProviderService] fetchAllProviders error: $e');
      return [];
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

  /// Fetches a single provider by ID.
  Future<ProviderProfile> fetchProviderById(String id) async {
    try {
      final response = await _apiClient.get('/providers/$id/');
      return ProviderProfile.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[ProviderService] fetchProviderById error: $e');
      rethrow;
    }
  }

  /// Fetches providers the current user follows.
  Future<List<ProviderProfile>> fetchFollowedProviders() async {
    try {
      final response = await _apiClient.get('/providers/followed/');
      final items = response is List
          ? response
          : (response as Map<String, dynamic>?)?['results'] as List<dynamic>? ?? [];
      return items
          .map((e) => ProviderProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ProviderService] fetchFollowedProviders error: $e');
      return [];
    }
  }

  /// Follow a provider. Returns true if newly followed, false if already followed.
  Future<bool> followProvider(String providerId) async {
    try {
      final response = await _apiClient.post('/providers/$providerId/follow/', body: {});
      final detail = (response as Map<String, dynamic>?)?['detail'] as String? ?? '';
      return detail.contains('Following');
    } catch (e) {
      debugPrint('[ProviderService] followProvider error: $e');
      rethrow;
    }
  }

  /// Unfollow a provider.
  Future<void> unfollowProvider(String providerId) async {
    try {
      await _apiClient.delete('/providers/$providerId/follow/');
    } catch (e) {
      debugPrint('[ProviderService] unfollowProvider error: $e');
      rethrow;
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
      debugPrint('[ProviderService] submitProviderProfile error: $e');
      rethrow;
    }
  }

  /// Updates the current authenticated provider profile.
  Future<ProviderProfile> updateMyProviderProfile({
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
    final hasFiles = (documents != null && documents.isNotEmpty) || logo != null;

    final dynamic response;
    if (hasFiles) {
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

      final fileEntries = <MapEntry<String, File>>[];
      if (logo != null) fileEntries.add(MapEntry('logo', logo));
      for (final doc in documents ?? <File>[]) {
        fileEntries.add(MapEntry('documents', doc));
      }

      response = await _apiClient.patchMultipartFiles(
        '/providers/my-profile/',
        fields: fields,
        files: fileEntries,
      );
    } else {
      final body = <String, dynamic>{
        'business_name': businessName,
        'owner_name': ownerName,
        'category': category.name,
        'registration_number': registrationNumber,
        'phone': phone,
        'email': email,
        'address': address,
        'description': description,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

      response = await _apiClient.patch('/providers/my-profile/', body: body);
    }

    return ProviderProfile.fromJson(response as Map<String, dynamic>);
  }
}
