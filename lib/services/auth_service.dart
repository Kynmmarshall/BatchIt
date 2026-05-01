import 'package:batchit/models/user_profile.dart';

class AuthService {
  Future<UserProfile> loginWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return UserProfile(
      id: 'u_01',
      name: 'BatchIt User',
      email: email,
    );
  }

  Future<UserProfile> loginWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const UserProfile(
      id: 'u_google_01',
      name: 'Google User',
      email: 'google.user@batchit.app',
    );
  }
}
