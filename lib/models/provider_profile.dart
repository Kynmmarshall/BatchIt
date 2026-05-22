import 'package:batchit/core/app_constants.dart';

enum ProviderStatus { pending, verified, rejected }

enum BusinessCategory {
  grocery,
  household,
  electronics,
  clothing,
  restaurant,
  other,
}

class ProviderProfile {
  const ProviderProfile({
    required this.id,
    required this.ownerId,
    required this.businessName,
    required this.ownerName,
    required this.category,
    required this.registrationNumber,
    required this.phone,
    required this.email,
    required this.address,
    this.latitude,
    this.longitude,
    this.documentUrls = const [],
    this.logoUrl,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String businessName;
  final String ownerName;
  final BusinessCategory category;
  final String registrationNumber;
  final String phone;
  final String email;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<String> documentUrls;
  final String? logoUrl;
  final String description;
  final ProviderStatus status;
  final DateTime createdAt;

  bool get isVerified => status == ProviderStatus.verified;
  bool get isPending => status == ProviderStatus.pending;
  bool get isRejected => status == ProviderStatus.rejected;

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    final normalizedDocuments = (json['document_urls'] as List<dynamic>?)
            ?.map((e) => _normalizeUrl(e.toString()))
            .whereType<String>()
            .toList() ??
        const <String>[];

    return ProviderProfile(
      id: json['id'] as String? ?? json['provider_id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      businessName: json['business_name'] as String? ?? '',
      ownerName: json['owner_name'] as String? ?? '',
      category: _categoryFromString(json['category'] as String? ?? ''),
      registrationNumber: json['registration_number'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      documentUrls: normalizedDocuments,
      logoUrl: _normalizeUrl(json['logo_url'] as String?),
      description: json['description'] as String? ?? '',
      status: _statusFromString(json['status'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, String> toFormFields() {
    return {
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
  }

  static ProviderStatus _statusFromString(String s) {
    switch (s) {
      case 'verified':
        return ProviderStatus.verified;
      case 'rejected':
        return ProviderStatus.rejected;
      default:
        return ProviderStatus.pending;
    }
  }

  static BusinessCategory _categoryFromString(String s) {
    switch (s) {
      case 'grocery':
        return BusinessCategory.grocery;
      case 'household':
        return BusinessCategory.household;
      case 'electronics':
        return BusinessCategory.electronics;
      case 'clothing':
        return BusinessCategory.clothing;
      case 'restaurant':
        return BusinessCategory.restaurant;
      default:
        return BusinessCategory.other;
    }
  }
  static String? _normalizeUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

    final apiUri = Uri.parse(AppConstants.apiBaseUrl);
    final origin =
        '${apiUri.scheme}://${apiUri.host}${apiUri.hasPort ? ':${apiUri.port}' : ''}';
    final path = raw.startsWith('/') ? raw : '/$raw';
    return '$origin$path';
  }
}
