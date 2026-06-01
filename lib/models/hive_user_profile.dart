// ============================================================================
// [HiveUserProfile] - Hive-persisted user profile model
// ============================================================================
// Extends UserProfile with Hive serialization capabilities.
// Uses @HiveType and @HiveField decorators for automatic code generation
// via build_runner, enabling fast JSON-like serialization to disk.
//
// Usage:
// - Stored in 'user_profile' Hive box
// - Automatically serialized when AuthProvider saves user session
// - Loaded on app restart to restore authentication state
// ============================================================================
import 'package:hive/hive.dart';

part 'hive_user_profile.g.dart';

@HiveType(typeId: 0)
class HiveUserProfile extends HiveObject {
  HiveUserProfile();

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String email;

  @HiveField(3)
  String? avatarUrl;

  /// Converts HiveUserProfile to plain UserProfile.
  /// Used when passing to domain logic layer.
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'avatarUrl': avatarUrl};
  }

  /// Factory constructor to create HiveUserProfile from map.
  /// Useful for converting API responses or domain models to Hive format.
  factory HiveUserProfile.fromMap(Map<String, dynamic> map) {
    final profile = HiveUserProfile();
    profile.id = map['id'] ?? '';
    profile.name = map['name'] ?? '';
    profile.email = map['email'] ?? '';
    profile.avatarUrl = map['avatarUrl'];
    return profile;
  }

  @override
  String toString() =>
      'HiveUserProfile(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl)';
}
