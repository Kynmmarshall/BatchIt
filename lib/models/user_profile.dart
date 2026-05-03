/// ============================================================================
/// [UserProfile] - Represents authenticated user's identity and profile data
/// ============================================================================
/// Immutable data class holding core user information used across the app.
/// Instance created on successful authentication (login/register).
///
/// Fields:
/// - id: Unique user identifier (UUID or numeric from backend)
/// - name: Display name (shown in profile header, notifications)
/// - email: Email address (used for login, contact, password reset)
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
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
}
