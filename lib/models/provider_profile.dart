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
      documentUrls: (json['document_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      logoUrl: json['logo_url'] as String?,
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
}

/// Mock verified providers for fallback/dev use.
final List<ProviderProfile> kMockVerifiedProviders = [
  ProviderProfile(
    id: 'hub-ain-sebaa',
    ownerId: 'owner-1',
    businessName: 'Hub Ain Sebaa',
    ownerName: 'Ahmed Benali',
    category: BusinessCategory.grocery,
    registrationNumber: 'RC-12345-AIN',
    phone: '+212 661 234 567',
    email: 'hub.ainsebaa@batchit.app',
    address: '12 Rue Hassan II, Ain Sebaa, Casablanca',
    latitude: 33.5891,
    longitude: -7.5098,
    description: 'Fresh vegetables, fruits, and daily grocery items in bulk.',
    status: ProviderStatus.verified,
    createdAt: DateTime(2024, 1, 15),
  ),
  ProviderProfile(
    id: 'hub-centre',
    ownerId: 'owner-2',
    businessName: 'Hub Centre',
    ownerName: 'Fatima Ezzahra',
    category: BusinessCategory.household,
    registrationNumber: 'RC-67890-CTR',
    phone: '+212 662 345 678',
    email: 'hub.centre@batchit.app',
    address: '45 Boulevard Mohammed V, Centre, Casablanca',
    latitude: 33.5731,
    longitude: -7.5898,
    description: 'Household goods and cleaning products at wholesale prices.',
    status: ProviderStatus.verified,
    createdAt: DateTime(2024, 2, 8),
  ),
  ProviderProfile(
    id: 'hub-east',
    ownerId: 'owner-3',
    businessName: 'Hub East',
    ownerName: 'Khalid Moussaoui',
    category: BusinessCategory.grocery,
    registrationNumber: 'RC-11223-EST',
    phone: '+212 663 456 789',
    email: 'hub.east@batchit.app',
    address: '78 Route de Mediouna, Est, Casablanca',
    latitude: 33.5621,
    longitude: -7.5012,
    description: 'Bulk fresh produce and pantry staples. Daily delivery to hub.',
    status: ProviderStatus.verified,
    createdAt: DateTime(2024, 3, 1),
  ),
];
