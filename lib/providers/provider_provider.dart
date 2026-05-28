import 'dart:io';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/services/provider_service.dart';
import 'package:flutter/foundation.dart';

class ProviderProvider extends ChangeNotifier {
  ProviderProvider(this._service);

  final ProviderService _service;

  List<ProviderProfile> _verifiedProviders = [];
  ProviderProfile? _myProfile;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<ProviderProfile> get verifiedProviders =>
      List.unmodifiable(_verifiedProviders);
  ProviderProfile? get myProfile => _myProfile;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  bool get hasProfile => _myProfile != null;
  bool get isVerified => _myProfile?.isVerified ?? false;
  bool get isPending => _myProfile?.isPending ?? false;

  Future<void> loadVerifiedProviders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _verifiedProviders = await _service.fetchVerifiedProviders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _myProfile = await _service.fetchMyProviderProfile();
    } catch (e) {
      debugPrint('[ProviderProvider] loadMyProfile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitProviderProfile({
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
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      _myProfile = await _service.submitProviderProfile(
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
        documents: documents,
        logo: logo,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> updateMyProviderProfile({
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
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      _myProfile = await _service.updateMyProviderProfile(
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
        documents: documents,
        logo: logo,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  ProviderProfile? findById(String id) {
    try {
      return _verifiedProviders.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
