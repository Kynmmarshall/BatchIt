/// Holds registration form data during the email verification flow.
/// Passed from RegisterScreen → VerificationCodeScreen.
class RegistrationData {
  const RegistrationData({
    required this.email,
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  final String email;
  final String username;
  final String password;
  final String firstName;
  final String lastName;
}
