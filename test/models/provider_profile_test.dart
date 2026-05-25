// ============================================================================
// Tests for ProviderProfile model
// ============================================================================
import 'package:batchit/models/provider_profile.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> baseJson({
  String id = 'p1',
  String status = 'verified',
  String category = 'grocery',
}) =>
    {
      'id': id,
      'owner_id': 'u1',
      'business_name': 'Super Marché',
      'owner_name': 'Jean Paul',
      'category': category,
      'registration_number': 'RN001',
      'phone': '+237600000000',
      'email': 'marche@example.com',
      'address': '123 Rue de Commerce, Yaoundé',
      'latitude': 3.848,
      'longitude': 11.502,
      'description': 'Best grocery store',
      'status': status,
      'created_at': '2024-01-15T10:00:00Z',
    };

void main() {
  group('ProviderProfile.fromJson', () {
    test('parses all fields correctly', () {
      final p = ProviderProfile.fromJson(baseJson());
      expect(p.id, 'p1');
      expect(p.ownerId, 'u1');
      expect(p.businessName, 'Super Marché');
      expect(p.ownerName, 'Jean Paul');
      expect(p.category, BusinessCategory.grocery);
      expect(p.registrationNumber, 'RN001');
      expect(p.phone, '+237600000000');
      expect(p.email, 'marche@example.com');
      expect(p.address, '123 Rue de Commerce, Yaoundé');
      expect(p.latitude, 3.848);
      expect(p.longitude, 11.502);
      expect(p.description, 'Best grocery store');
      expect(p.status, ProviderStatus.verified);
      expect(p.createdAt, DateTime.parse('2024-01-15T10:00:00Z'));
    });

    test('uses provider_id field when id is absent', () {
      final json = baseJson()..remove('id');
      json['provider_id'] = 'alt-id';
      final p = ProviderProfile.fromJson(json);
      expect(p.id, 'alt-id');
    });

    test('falls back to empty string when both id fields absent', () {
      final json = baseJson()..remove('id');
      final p = ProviderProfile.fromJson(json);
      expect(p.id, '');
    });

    test('handles null latitude/longitude', () {
      final json = baseJson();
      json.remove('latitude');
      json.remove('longitude');
      final p = ProviderProfile.fromJson(json);
      expect(p.latitude, isNull);
      expect(p.longitude, isNull);
    });

    test('parses logo_url as absolute when already https', () {
      final json = baseJson();
      json['logo_url'] = 'https://cdn.example.com/logo.png';
      final p = ProviderProfile.fromJson(json);
      expect(p.logoUrl, 'https://cdn.example.com/logo.png');
    });

    test('normalizes relative logo_url by prepending base', () {
      final json = baseJson();
      json['logo_url'] = '/media/logos/logo.png';
      final p = ProviderProfile.fromJson(json);
      expect(p.logoUrl, contains('/media/logos/logo.png'));
      expect(p.logoUrl!.startsWith('http'), true);
    });

    test('logoUrl is null when field is null', () {
      final json = baseJson();
      json['logo_url'] = null;
      final p = ProviderProfile.fromJson(json);
      expect(p.logoUrl, isNull);
    });

    test('logoUrl is null when field is empty string', () {
      final json = baseJson();
      json['logo_url'] = '';
      final p = ProviderProfile.fromJson(json);
      expect(p.logoUrl, isNull);
    });

    test('parses document_urls list', () {
      final json = baseJson();
      json['document_urls'] = [
        'https://cdn.example.com/doc1.pdf',
        'https://cdn.example.com/doc2.pdf',
      ];
      final p = ProviderProfile.fromJson(json);
      expect(p.documentUrls.length, 2);
    });

    test('document_urls defaults to empty list when absent', () {
      final p = ProviderProfile.fromJson(baseJson());
      expect(p.documentUrls, isEmpty);
    });

    test('createdAt falls back to DateTime.now() on invalid date', () {
      final json = baseJson();
      json['created_at'] = 'not-a-date';
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final p = ProviderProfile.fromJson(json);
      expect(p.createdAt.isAfter(before), true);
    });
  });

  group('ProviderStatus helpers', () {
    test('isVerified when status is verified', () {
      final p = ProviderProfile.fromJson(baseJson(status: 'verified'));
      expect(p.isVerified, true);
      expect(p.isPending, false);
      expect(p.isRejected, false);
    });

    test('isPending when status is pending', () {
      final p = ProviderProfile.fromJson(baseJson(status: 'pending'));
      expect(p.isPending, true);
      expect(p.isVerified, false);
      expect(p.isRejected, false);
    });

    test('isRejected when status is rejected', () {
      final p = ProviderProfile.fromJson(baseJson(status: 'rejected'));
      expect(p.isRejected, true);
      expect(p.isPending, false);
      expect(p.isVerified, false);
    });

    test('unknown status maps to pending', () {
      final p = ProviderProfile.fromJson(baseJson(status: 'unknown'));
      expect(p.isPending, true);
    });
  });

  group('BusinessCategory mapping', () {
    final categories = {
      'grocery': BusinessCategory.grocery,
      'household': BusinessCategory.household,
      'electronics': BusinessCategory.electronics,
      'clothing': BusinessCategory.clothing,
      'restaurant': BusinessCategory.restaurant,
      'unknown': BusinessCategory.other,
      '': BusinessCategory.other,
    };

    categories.forEach((str, expected) {
      test('maps "$str" → $expected', () {
        final p = ProviderProfile.fromJson(baseJson(category: str));
        expect(p.category, expected);
      });
    });
  });

  group('ProviderProfile.toFormFields', () {
    test('includes all required string fields', () {
      final p = ProviderProfile.fromJson(baseJson());
      final fields = p.toFormFields();
      expect(fields.containsKey('business_name'), true);
      expect(fields.containsKey('owner_name'), true);
      expect(fields.containsKey('category'), true);
      expect(fields.containsKey('registration_number'), true);
      expect(fields.containsKey('phone'), true);
      expect(fields.containsKey('email'), true);
      expect(fields.containsKey('address'), true);
      expect(fields.containsKey('description'), true);
    });

    test('includes latitude/longitude when present', () {
      final p = ProviderProfile.fromJson(baseJson());
      final fields = p.toFormFields();
      expect(fields.containsKey('latitude'), true);
      expect(fields.containsKey('longitude'), true);
    });

    test('omits latitude/longitude when null', () {
      final json = baseJson()..remove('latitude')..remove('longitude');
      final p = ProviderProfile.fromJson(json);
      final fields = p.toFormFields();
      expect(fields.containsKey('latitude'), false);
      expect(fields.containsKey('longitude'), false);
    });
  });
}
