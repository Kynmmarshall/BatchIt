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
  String get questionnaireTitle => 'Tell us what you buy';

  @override
  String get questionnaireSubtitle =>
      'Help BatchIt recommend better batches based on your habits and preferences.';

  @override
  String get productCategories => 'Product categories';

  @override
  String get shoppingFrequency => 'Shopping frequency';

  @override
  String get preferredRegions => 'Preferred regions';

  @override
  String get budgetRange => 'Budget range';

  @override
  String get questionnaireContinue => 'Continue to Login';

  @override
  String get questionnaireSkip => 'Skip for now';

  @override
  String get questionnaireChipGroceries => 'Groceries';

  @override
  String get questionnaireChipHousehold => 'Household';

  @override
  String get questionnaireChipSnacks => 'Snacks';

  @override
  String get questionnaireChipWeekly => 'Weekly';

  @override
  String get questionnaireChipBiweekly => 'Bi-weekly';

  @override
  String get questionnaireChipMonthly => 'Monthly';

  @override
  String get questionnaireChipNearby => 'Nearby';

  @override
  String get questionnaireChipCitywide => 'Citywide';

  @override
  String get questionnaireChipFlexible => 'Flexible';

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
  String get profileSubtitle =>
      'Manage your account, orders, and preferences in one place.';

  @override
  String get profileOrdersSubtitle =>
      'Review your order history and jump back into active orders.';

  @override
  String get providerPreferences => 'Provider Preferences';

  @override
  String get providerPreferencesSubtitle =>
      'Follow the hubs you want to receive updates from.';

  @override
  String get profileLanguageSubtitle =>
      'Choose your preferred language for the app.';

  @override
  String get profileThemeSubtitle =>
      'Switch between light and dark appearances.';

  @override
  String get profileNotificationsSubtitle =>
      'Control which alerts should reach this device.';

  @override
  String get notificationsScreenTitle => 'Notifications';

  @override
  String get notificationsScreenSubtitle =>
      'Review alerts, mark them read, and tune the devices you want to hear from.';

  @override
  String get notificationsScreenLead =>
      'Keep track of batch changes, order updates, and provider activity in one place.';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get unreadOnly => 'Unread only';

  @override
  String get noNotificationsTitle => 'You\'re all caught up';

  @override
  String get noNotificationsSubtitle =>
      'New batch and order alerts will appear here.';

  @override
  String get batchFilledNotification => 'A batch you follow was filled';

  @override
  String get orderReadyNotification => 'Your order is ready for pickup';

  @override
  String get providerUpdatedNotification =>
      'A provider you follow posted an update';

  @override
  String get batchExpiredNotification => 'An active batch expired';

  @override
  String get profileReminderNotification =>
      'Complete your profile to improve recommendations';

  @override
  String get viewDetails => 'View details';

  @override
  String get openBatch => 'Open batch';

  @override
  String get openOrder => 'Open order';

  @override
  String get openProfile => 'Open profile';

  @override
  String get batchAlerts => 'Batch alerts';

  @override
  String get batchAlertsSubtitle => 'Get notified when batch status changes.';

  @override
  String get orderAlerts => 'Order alerts';

  @override
  String get orderAlertsSubtitle => 'Track ready and completed order updates.';

  @override
  String get providerAlerts => 'Provider alerts';

  @override
  String get providerAlertsSubtitle =>
      'Receive news from the providers you follow.';

  @override
  String get dashboardSubtitle => 'Find nearby batches and join faster.';

  @override
  String get searchBatches => 'Search batches';

  @override
  String get home => 'Home';

  @override
  String get createBatch => 'Create Batch';

  @override
  String get createBatchTitle => 'Create a new batch';

  @override
  String get createBatchSubtitle =>
      'Choose a product, set the target quantity, and send it to a provider.';

  @override
  String get productSelection => 'Choose product';

  @override
  String get bulkSelection => 'Choose bulk size';

  @override
  String get providerSelection => 'Choose provider';

  @override
  String get batchNoteOptional => 'Optional note';

  @override
  String get batchNoteHint => 'Add a deadline or message for participants';

  @override
  String get customProduct => 'Custom product';

  @override
  String get providerAuto => 'Auto assigned hub';

  @override
  String get providerAinSebaa => 'Hub Ain Sebaa';

  @override
  String get providerCentre => 'Hub Centre';

  @override
  String get providerEast => 'Hub East';

  @override
  String get productPotatoes => 'Potatoes';

  @override
  String get productTomatoes => 'Tomatoes';

  @override
  String get productOnions => 'Onions';

  @override
  String get bulkKg50 => '50 kg';

  @override
  String get bulkKg30 => '30 kg';

  @override
  String get bulkKg40 => '40 kg';

  @override
  String get batchCreated => 'Batch created successfully';

  @override
  String get batchDetails => 'Batch Details';

  @override
  String get joinBatch => 'Join Batch';

  @override
  String get joinBatchTitle => 'Join this batch';

  @override
  String get joinBatchSubtitle =>
      'Choose how much you want to claim and confirm your participation.';

  @override
  String get joinQuantityHint => 'Enter quantity in kg';

  @override
  String get joinConfirm => 'Confirm Join';

  @override
  String get joinSuccess => 'You joined the batch';

  @override
  String get claimedQuantity => 'Claimed quantity';

  @override
  String get batchSnapshot => 'Batch snapshot';

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
  String get settings => 'Settings';

  @override
  String get appPreferences => 'App Preferences';

  @override
  String get accountPreferences => 'Account Preferences';

  @override
  String get notificationsPreferences => 'Notification Preferences';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get mvpBadge => 'MVP';

  @override
  String get hub => 'Hub';

  @override
  String get full => 'Full';

  @override
  String get requested => 'Requested';

  @override
  String get joinedBatch => 'You joined the batch';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get createOrder => 'Create Order';

  @override
  String get createOrderTitle => 'Create a new order';

  @override
  String get createOrderCta => 'Place order';

  @override
  String get orderEmptyTitle => 'No orders yet';

  @override
  String get orderEmptySubtitle => 'Place your first order to get started';
}
