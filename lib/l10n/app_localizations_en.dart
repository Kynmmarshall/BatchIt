// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BatchIt';

  @override
  String get welcomeTitle => 'Buy together. Save together.';

  @override
  String get welcomeSubtitle =>
      'Build local batches, hit bulk targets, and collect from your hub.';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueCta => 'Continue';

  @override
  String get getStarted => 'Get Started';

  @override
  String get signInCta => 'Sign In';

  @override
  String get signUpCta => 'Sign Up';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get savePassword => 'Save password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get didntHaveAnAccount => 'Didn\'t have an account?';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle =>
      'Access your account securely by using your\nemail and password';

  @override
  String get registerNow => 'Register Now';

  @override
  String get registerSubtitle =>
      'Sign up with your email and password to\ncontinue';

  @override
  String get verificationCodeTitle => 'Verification Code';

  @override
  String verificationCodeSent(String email) {
    return 'We\'ve sent the code to your mail address that\nyou include: $email';
  }

  @override
  String get resendCode => 'Resend Code';

  @override
  String get confirm => 'Confirm';

  @override
  String get onboardingTitle1 => 'Welcome to BatchIt';

  @override
  String get onboardingDesc1 =>
      'Buy together, save together. Join local buyers and reach bulk targets faster.';

  @override
  String get onboardingTitle2 => 'Introducing Smart Local Batches';

  @override
  String get onboardingDesc2 =>
      'Discover nearby batches within your area and collaborate with trusted community hubs.';

  @override
  String get onboardingTitle3 => 'Your Daily Grocery Partner';

  @override
  String get onboardingDesc3 =>
      'Track live progress, get notified when thresholds are reached, and collect with ease.';

  @override
  String get open => 'Open';

  @override
  String get dailyDealsHeadline => 'Daily\nBatchIt Deals';

  @override
  String get popularBatches => 'Popular Batches';

  @override
  String get seeAll => 'See all';

  @override
  String get noBatchesForFilter => 'No batches found for this filter.';

  @override
  String batchProgressFilled(int percent) {
    return '$percent% filled';
  }

  @override
  String get perKg => '/kg';

  @override
  String get batchNotFound => 'Batch not found';

  @override
  String get routeNotFound => 'Route not found';

  @override
  String get profileDefaultName => 'BatchIt User';

  @override
  String get profileDefaultEmail => 'user@batchit.app';

  @override
  String get home => 'Home';

  @override
  String get createBatch => 'Create Batch';

  @override
  String get batchDetails => 'Batch Details';

  @override
  String get joinBatch => 'Join Batch';

  @override
  String get myOrders => 'My Orders';

  @override
  String get profile => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get nearbyBatches => 'Nearby Batches';

  @override
  String get activeBatches => 'Active Batches';

  @override
  String get join => 'Join';

  @override
  String get quantity => 'Quantity';

  @override
  String get bulkSize => 'Bulk Size';

  @override
  String get progress => 'Progress';

  @override
  String get productName => 'Product Name';

  @override
  String get location => 'Location';

  @override
  String get submit => 'Submit';

  @override
  String get logout => 'Logout';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusTriggered => 'Triggered';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCompleted => 'Completed';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get switchTheme => 'Switch Theme';

  @override
  String get mvpBadge => 'MVP';

  @override
  String get hub => 'Hub';

  @override
  String get full => 'Full';

  @override
  String get requested => 'Requested';

  @override
  String get batchCreated => 'Batch created successfully';

  @override
  String get joinedBatch => 'You joined the batch';
}
