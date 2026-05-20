/// ============================================================================
/// [UserProfile] - Represents authenticated user's identity and profile data
/// ============================================================================
/// Immutable data class holding core user information used across the app.
/// Instance created on successful authentication (login/register).
///
/// Fields:
/// - id: Unique user identifier (UUID from backend)
/// - username: Unique username for display
/// - email: Email address (used for login, contact, password reset)
/// - firstName: User's first name
/// - lastName: User's last name
/// - avatarUrl: Optional profile picture URL (displayed as CircleAvatar)
///
/// Usage:
/// - AuthProvider.user holds current UserProfile or null if unauthenticated
/// - Displayed in ProfileScreen header and settings
/// - Passed to backend API calls for user context
/// - Serialized/deserialized for session persistence (TODO)
/// ============================================================================
class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatarUrl,
  });

  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;

  /// Returns display name: firstName lastName, or username if names not available
  String get displayName {
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName!;
    }
    if (lastName != null && lastName!.isNotEmpty) {
      return lastName!;
    }
    return username;
  }
}
