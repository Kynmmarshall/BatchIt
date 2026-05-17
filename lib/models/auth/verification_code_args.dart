import 'package:batchit/models/auth/registration_data.dart';

class VerificationCodeArgs {
  const VerificationCodeArgs({
    required this.maskedEmail,
    this.email,
    this.registrationData,
  });

  final String maskedEmail;
  final String? email;
  final RegistrationData? registrationData;
}