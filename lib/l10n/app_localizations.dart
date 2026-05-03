import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BatchIt'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy together. Save together.'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build local batches, hit bulk targets, and collect from your hub.'**
  String get welcomeSubtitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueCta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueCta;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @signInCta.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInCta;

  /// No description provided for @signUpCta.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpCta;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @savePassword.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get savePassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @didntHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t have an account?'**
  String get didntHaveAnAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your account securely by using your\nemail and password'**
  String get loginSubtitle;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get registerNow;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with your email and password to\ncontinue'**
  String get registerSubtitle;

  /// No description provided for @questionnaireTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you buy'**
  String get questionnaireTitle;

  /// No description provided for @questionnaireSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help BatchIt recommend better batches based on your habits and preferences.'**
  String get questionnaireSubtitle;

  /// No description provided for @productCategories.
  ///
  /// In en, this message translates to:
  /// **'Product categories'**
  String get productCategories;

  /// No description provided for @shoppingFrequency.
  ///
  /// In en, this message translates to:
  /// **'Shopping frequency'**
  String get shoppingFrequency;

  /// No description provided for @preferredRegions.
  ///
  /// In en, this message translates to:
  /// **'Preferred regions'**
  String get preferredRegions;

  /// No description provided for @budgetRange.
  ///
  /// In en, this message translates to:
  /// **'Budget range'**
  String get budgetRange;

  /// No description provided for @questionnaireContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to Login'**
  String get questionnaireContinue;

  /// No description provided for @questionnaireSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get questionnaireSkip;

  /// No description provided for @questionnaireChipGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get questionnaireChipGroceries;

  /// No description provided for @questionnaireChipHousehold.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get questionnaireChipHousehold;

  /// No description provided for @questionnaireChipSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get questionnaireChipSnacks;

  /// No description provided for @questionnaireChipWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get questionnaireChipWeekly;

  /// No description provided for @questionnaireChipBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Bi-weekly'**
  String get questionnaireChipBiweekly;

  /// No description provided for @questionnaireChipMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get questionnaireChipMonthly;

  /// No description provided for @questionnaireChipNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get questionnaireChipNearby;

  /// No description provided for @questionnaireChipCitywide.
  ///
  /// In en, this message translates to:
  /// **'Citywide'**
  String get questionnaireChipCitywide;

  /// No description provided for @questionnaireChipFlexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get questionnaireChipFlexible;

  /// No description provided for @verificationCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCodeTitle;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent the code to your mail address that\nyou include: {email}'**
  String verificationCodeSent(String email);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BatchIt'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Buy together, save together. Join local buyers and reach bulk targets faster.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Introducing Smart Local Batches'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Discover nearby batches within your area and collaborate with trusted community hubs.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Your Daily Grocery Partner'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Track live progress, get notified when thresholds are reached, and collect with ease.'**
  String get onboardingDesc3;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @dailyDealsHeadline.
  ///
  /// In en, this message translates to:
  /// **'Daily\nBatchIt Deals'**
  String get dailyDealsHeadline;

  /// No description provided for @popularBatches.
  ///
  /// In en, this message translates to:
  /// **'Popular Batches'**
  String get popularBatches;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noBatchesForFilter.
  ///
  /// In en, this message translates to:
  /// **'No batches found for this filter.'**
  String get noBatchesForFilter;

  /// No description provided for @batchProgressFilled.
  ///
  /// In en, this message translates to:
  /// **'{percent}% filled'**
  String batchProgressFilled(int percent);

  /// No description provided for @perKg.
  ///
  /// In en, this message translates to:
  /// **'/kg'**
  String get perKg;

  /// No description provided for @batchNotFound.
  ///
  /// In en, this message translates to:
  /// **'Batch not found'**
  String get batchNotFound;

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route not found'**
  String get routeNotFound;

  /// No description provided for @profileDefaultName.
  ///
  /// In en, this message translates to:
  /// **'BatchIt User'**
  String get profileDefaultName;

  /// No description provided for @profileDefaultEmail.
  ///
  /// In en, this message translates to:
  /// **'user@batchit.app'**
  String get profileDefaultEmail;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your account, orders, and preferences in one place.'**
  String get profileSubtitle;

  /// No description provided for @profileOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your order history and jump back into active orders.'**
  String get profileOrdersSubtitle;

  /// No description provided for @providerPreferences.
  ///
  /// In en, this message translates to:
  /// **'Provider Preferences'**
  String get providerPreferences;

  /// No description provided for @providerPreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow the hubs you want to receive updates from.'**
  String get providerPreferencesSubtitle;

  /// No description provided for @profileLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language for the app.'**
  String get profileLanguageSubtitle;

  /// No description provided for @profileThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark appearances.'**
  String get profileThemeSubtitle;

  /// No description provided for @profileNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control which alerts should reach this device.'**
  String get profileNotificationsSubtitle;

  /// No description provided for @notificationsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsScreenTitle;

  /// No description provided for @notificationsScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review alerts, mark them read, and tune the devices you want to hear from.'**
  String get notificationsScreenSubtitle;

  /// No description provided for @notificationsScreenLead.
  ///
  /// In en, this message translates to:
  /// **'Keep track of batch changes, order updates, and provider activity in one place.'**
  String get notificationsScreenLead;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @unreadOnly.
  ///
  /// In en, this message translates to:
  /// **'Unread only'**
  String get unreadOnly;

  /// No description provided for @noNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get noNotificationsTitle;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'New batch and order alerts will appear here.'**
  String get noNotificationsSubtitle;

  /// No description provided for @batchFilledNotification.
  ///
  /// In en, this message translates to:
  /// **'A batch you follow was filled'**
  String get batchFilledNotification;

  /// No description provided for @orderReadyNotification.
  ///
  /// In en, this message translates to:
  /// **'Your order is ready for pickup'**
  String get orderReadyNotification;

  /// No description provided for @providerUpdatedNotification.
  ///
  /// In en, this message translates to:
  /// **'A provider you follow posted an update'**
  String get providerUpdatedNotification;

  /// No description provided for @batchExpiredNotification.
  ///
  /// In en, this message translates to:
  /// **'An active batch expired'**
  String get batchExpiredNotification;

  /// No description provided for @profileReminderNotification.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to improve recommendations'**
  String get profileReminderNotification;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @openBatch.
  ///
  /// In en, this message translates to:
  /// **'Open batch'**
  String get openBatch;

  /// No description provided for @openOrder.
  ///
  /// In en, this message translates to:
  /// **'Open order'**
  String get openOrder;

  /// No description provided for @openProfile.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get openProfile;

  /// No description provided for @batchAlerts.
  ///
  /// In en, this message translates to:
  /// **'Batch alerts'**
  String get batchAlerts;

  /// No description provided for @batchAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when batch status changes.'**
  String get batchAlertsSubtitle;

  /// No description provided for @orderAlerts.
  ///
  /// In en, this message translates to:
  /// **'Order alerts'**
  String get orderAlerts;

  /// No description provided for @orderAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track ready and completed order updates.'**
  String get orderAlertsSubtitle;

  /// No description provided for @providerAlerts.
  ///
  /// In en, this message translates to:
  /// **'Provider alerts'**
  String get providerAlerts;

  /// No description provided for @providerAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive news from the providers you follow.'**
  String get providerAlertsSubtitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find nearby batches and join faster.'**
  String get dashboardSubtitle;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchBatches.
  ///
  /// In en, this message translates to:
  /// **'Search batches'**
  String get searchBatches;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search batches or providers'**
  String get searchHint;

  /// No description provided for @searchModeBatches.
  ///
  /// In en, this message translates to:
  /// **'Batches'**
  String get searchModeBatches;

  /// No description provided for @searchModeProviders.
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get searchModeProviders;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results found for your search.'**
  String get noSearchResults;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @createBatch.
  ///
  /// In en, this message translates to:
  /// **'Create Batch'**
  String get createBatch;

  /// No description provided for @createBatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new batch'**
  String get createBatchTitle;

  /// No description provided for @createBatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a product, set the target quantity, and send it to a provider.'**
  String get createBatchSubtitle;

  /// No description provided for @productSelection.
  ///
  /// In en, this message translates to:
  /// **'Choose product'**
  String get productSelection;

  /// No description provided for @bulkSelection.
  ///
  /// In en, this message translates to:
  /// **'Choose bulk size'**
  String get bulkSelection;

  /// No description provided for @providerSelection.
  ///
  /// In en, this message translates to:
  /// **'Choose provider'**
  String get providerSelection;

  /// No description provided for @batchNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional note'**
  String get batchNoteOptional;

  /// No description provided for @batchNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a deadline or message for participants'**
  String get batchNoteHint;

  /// No description provided for @customProduct.
  ///
  /// In en, this message translates to:
  /// **'Custom product'**
  String get customProduct;

  /// No description provided for @providerAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto assigned hub'**
  String get providerAuto;

  /// No description provided for @providerAinSebaa.
  ///
  /// In en, this message translates to:
  /// **'Hub Ain Sebaa'**
  String get providerAinSebaa;

  /// No description provided for @providerCentre.
  ///
  /// In en, this message translates to:
  /// **'Hub Centre'**
  String get providerCentre;

  /// No description provided for @providerEast.
  ///
  /// In en, this message translates to:
  /// **'Hub East'**
  String get providerEast;

  /// No description provided for @productPotatoes.
  ///
  /// In en, this message translates to:
  /// **'Potatoes'**
  String get productPotatoes;

  /// No description provided for @productTomatoes.
  ///
  /// In en, this message translates to:
  /// **'Tomatoes'**
  String get productTomatoes;

  /// No description provided for @productOnions.
  ///
  /// In en, this message translates to:
  /// **'Onions'**
  String get productOnions;

  /// No description provided for @bulkKg50.
  ///
  /// In en, this message translates to:
  /// **'50 kg'**
  String get bulkKg50;

  /// No description provided for @bulkKg30.
  ///
  /// In en, this message translates to:
  /// **'30 kg'**
  String get bulkKg30;

  /// No description provided for @bulkKg40.
  ///
  /// In en, this message translates to:
  /// **'40 kg'**
  String get bulkKg40;

  /// No description provided for @batchCreated.
  ///
  /// In en, this message translates to:
  /// **'Batch created successfully'**
  String get batchCreated;

  /// No description provided for @batchDetails.
  ///
  /// In en, this message translates to:
  /// **'Batch Details'**
  String get batchDetails;

  /// No description provided for @joinBatch.
  ///
  /// In en, this message translates to:
  /// **'Join Batch'**
  String get joinBatch;

  /// No description provided for @joinBatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Join this batch'**
  String get joinBatchTitle;

  /// No description provided for @joinBatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how much you want to claim and confirm your participation.'**
  String get joinBatchSubtitle;

  /// No description provided for @joinQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity in kg'**
  String get joinQuantityHint;

  /// No description provided for @joinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Join'**
  String get joinConfirm;

  /// No description provided for @joinSuccess.
  ///
  /// In en, this message translates to:
  /// **'You joined the batch'**
  String get joinSuccess;

  /// No description provided for @claimedQuantity.
  ///
  /// In en, this message translates to:
  /// **'Claimed quantity'**
  String get claimedQuantity;

  /// No description provided for @batchSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Batch snapshot'**
  String get batchSnapshot;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Batches'**
  String get myOrders;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @mapViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Map View'**
  String get mapViewTitle;

  /// No description provided for @mapViewLead.
  ///
  /// In en, this message translates to:
  /// **'Browse providers and batches on a map.'**
  String get mapViewLead;

  /// No description provided for @mapViewPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Interactive map integration is next.'**
  String get mapViewPlaceholder;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @chatLead.
  ///
  /// In en, this message translates to:
  /// **'Open conversations with participants and providers.'**
  String get chatLead;

  /// No description provided for @chatProviderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provider support conversation'**
  String get chatProviderSubtitle;

  /// No description provided for @chatBatchGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch Group'**
  String get chatBatchGroupTitle;

  /// No description provided for @chatBatchGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Updates with batch participants'**
  String get chatBatchGroupSubtitle;

  /// No description provided for @providerDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Provider Discovery'**
  String get providerDiscovery;

  /// No description provided for @providerDiscoverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find and follow providers near you.'**
  String get providerDiscoverySubtitle;

  /// No description provided for @moreNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review alert history and preferences.'**
  String get moreNotificationsSubtitle;

  /// No description provided for @moreSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage app preferences and account options.'**
  String get moreSettingsSubtitle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @nearbyBatches.
  ///
  /// In en, this message translates to:
  /// **'Nearby Batches'**
  String get nearbyBatches;

  /// No description provided for @activeBatches.
  ///
  /// In en, this message translates to:
  /// **'Active Batches'**
  String get activeBatches;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @bulkSize.
  ///
  /// In en, this message translates to:
  /// **'Bulk Size'**
  String get bulkSize;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusTriggered.
  ///
  /// In en, this message translates to:
  /// **'Triggered'**
  String get orderStatusTriggered;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get orderStatusCompleted;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @switchTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch Theme'**
  String get switchTheme;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// No description provided for @accountPreferences.
  ///
  /// In en, this message translates to:
  /// **'Account Preferences'**
  String get accountPreferences;

  /// No description provided for @notificationsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationsPreferences;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @mvpBadge.
  ///
  /// In en, this message translates to:
  /// **'MVP'**
  String get mvpBadge;

  /// No description provided for @hub.
  ///
  /// In en, this message translates to:
  /// **'Hub'**
  String get hub;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// No description provided for @joinedBatch.
  ///
  /// In en, this message translates to:
  /// **'You joined the batch'**
  String get joinedBatch;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @createOrder.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get createOrder;

  /// No description provided for @createOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new order'**
  String get createOrderTitle;

  /// No description provided for @createOrderCta.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get createOrderCta;

  /// No description provided for @orderEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get orderEmptyTitle;

  /// No description provided for @orderEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Place your first order to get started'**
  String get orderEmptySubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
