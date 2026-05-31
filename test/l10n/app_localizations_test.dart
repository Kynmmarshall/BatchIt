// ============================================================================
// Tests for AppLocalizations — exercises every EN and FR string to maximise
// l10n coverage without needing a running app widget.
// ============================================================================
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/l10n/app_localizations_en.dart';
import 'package:batchit/l10n/app_localizations_fr.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void _exerciseAll(dynamic l) {
  // Core / auth
  expect(l.appTitle, isNotEmpty);
  expect(l.welcomeTitle, isNotEmpty);
  expect(l.welcomeSubtitle, isNotEmpty);
  expect(l.login, isNotEmpty);
  expect(l.register, isNotEmpty);
  expect(l.email, isNotEmpty);
  expect(l.password, isNotEmpty);
  expect(l.continueWithGoogle, isNotEmpty);
  expect(l.continueCta, isNotEmpty);
  expect(l.getStarted, isNotEmpty);
  expect(l.signInCta, isNotEmpty);
  expect(l.signUpCta, isNotEmpty);
  expect(l.orContinueWith, isNotEmpty);
  expect(l.emailAddress, isNotEmpty);
  expect(l.confirmPassword, isNotEmpty);
  expect(l.savePassword, isNotEmpty);
  expect(l.forgotPassword, isNotEmpty);
  expect(l.alreadyHaveAnAccount, isNotEmpty);
  expect(l.didntHaveAnAccount, isNotEmpty);
  expect(l.welcomeBack, isNotEmpty);
  expect(l.loginSubtitle, isNotEmpty);
  expect(l.guestLogin, isNotEmpty);
  expect(l.registerNow, isNotEmpty);
  expect(l.registerSubtitle, isNotEmpty);

  // Questionnaire
  expect(l.questionnaireTitle, isNotEmpty);
  expect(l.questionnaireSubtitle, isNotEmpty);
  expect(l.productCategories, isNotEmpty);
  expect(l.shoppingFrequency, isNotEmpty);
  expect(l.preferredRegions, isNotEmpty);
  expect(l.budgetRange, isNotEmpty);
  expect(l.questionnaireContinue, isNotEmpty);
  expect(l.questionnaireSkip, isNotEmpty);
  expect(l.questionnaireChipGroceries, isNotEmpty);
  expect(l.questionnaireChipHousehold, isNotEmpty);
  expect(l.questionnaireChipSnacks, isNotEmpty);
  expect(l.questionnaireChipWeekly, isNotEmpty);
  expect(l.questionnaireChipBiweekly, isNotEmpty);
  expect(l.questionnaireChipMonthly, isNotEmpty);
  expect(l.questionnaireChipNearby, isNotEmpty);
  expect(l.questionnaireChipCitywide, isNotEmpty);
  expect(l.questionnaireChipFlexible, isNotEmpty);

  // Verification
  expect(l.verificationCodeTitle, isNotEmpty);
  expect(l.verificationCodeSent('test@example.com'), isNotEmpty);
  expect(l.resendCode, isNotEmpty);
  expect(l.confirm, isNotEmpty);

  // Onboarding
  expect(l.onboardingTitle1, isNotEmpty);
  expect(l.onboardingDesc1, isNotEmpty);
  expect(l.onboardingTitle2, isNotEmpty);
  expect(l.onboardingDesc2, isNotEmpty);
  expect(l.onboardingTitle3, isNotEmpty);
  expect(l.onboardingDesc3, isNotEmpty);

  // Home
  expect(l.open, isNotEmpty);
  expect(l.dailyDealsHeadline, isNotEmpty);
  expect(l.popularBatches, isNotEmpty);
  expect(l.seeAll, isNotEmpty);
  expect(l.noBatchesForFilter, isNotEmpty);
  expect(l.batchProgressFilled(50), isNotEmpty);
  expect(l.perKg, isNotEmpty);

  // Routes / not found
  expect(l.batchNotFound, isNotEmpty);
  expect(l.providerNotFound, isNotEmpty);
  expect(l.routeNotFound, isNotEmpty);

  // Profile
  expect(l.profileDefaultName, isNotEmpty);
  expect(l.profileDefaultEmail, isNotEmpty);
  expect(l.profileSubtitle, isNotEmpty);
  expect(l.profileOrdersSubtitle, isNotEmpty);
  expect(l.providerPreferences, isNotEmpty);
  expect(l.providerPreferencesSubtitle, isNotEmpty);
  expect(l.profileLanguageSubtitle, isNotEmpty);
  expect(l.profileThemeSubtitle, isNotEmpty);
  expect(l.profileNotificationsSubtitle, isNotEmpty);

  // Notifications
  expect(l.notificationsScreenTitle, isNotEmpty);
  expect(l.notificationsScreenSubtitle, isNotEmpty);
  expect(l.notificationsScreenLead, isNotEmpty);
  expect(l.markAllRead, isNotEmpty);
  expect(l.today, isNotEmpty);
  expect(l.yesterday, isNotEmpty);
  expect(l.thisWeek, isNotEmpty);
  expect(l.unreadOnly, isNotEmpty);
  expect(l.noNotificationsTitle, isNotEmpty);
  expect(l.noNotificationsSubtitle, isNotEmpty);
  expect(l.batchFilledNotification, isNotEmpty);
  expect(l.orderReadyNotification, isNotEmpty);
  expect(l.providerUpdatedNotification, isNotEmpty);
  expect(l.batchExpiredNotification, isNotEmpty);
  expect(l.profileReminderNotification, isNotEmpty);
  expect(l.viewDetails, isNotEmpty);
  expect(l.openBatch, isNotEmpty);
  expect(l.openOrder, isNotEmpty);
  expect(l.openProfile, isNotEmpty);
  expect(l.batchAlerts, isNotEmpty);
  expect(l.batchAlertsSubtitle, isNotEmpty);
  expect(l.orderAlerts, isNotEmpty);
  expect(l.orderAlertsSubtitle, isNotEmpty);
  expect(l.providerAlerts, isNotEmpty);
  expect(l.providerAlertsSubtitle, isNotEmpty);

  // Navigation / misc
  expect(l.dashboardSubtitle, isNotEmpty);
  expect(l.search, isNotEmpty);
  expect(l.searchBatches, isNotEmpty);
  expect(l.searchHint, isNotEmpty);
  expect(l.searchModeBatches, isNotEmpty);
  expect(l.searchModeProviders, isNotEmpty);
  expect(l.noSearchResults, isNotEmpty);
  expect(l.home, isNotEmpty);

  // Create batch
  expect(l.createBatch, isNotEmpty);
  expect(l.createBatchTitle, isNotEmpty);
  expect(l.createBatchSubtitle, isNotEmpty);
  expect(l.productSelection, isNotEmpty);
  expect(l.bulkSelection, isNotEmpty);
  expect(l.providerSelection, isNotEmpty);
  expect(l.batchNoteOptional, isNotEmpty);
  expect(l.batchNoteHint, isNotEmpty);
  expect(l.customProduct, isNotEmpty);
  expect(l.providerAuto, isNotEmpty);
  expect(l.providerAinSebaa, isNotEmpty);
  expect(l.providerCentre, isNotEmpty);
  expect(l.providerEast, isNotEmpty);
  expect(l.productPotatoes, isNotEmpty);
  expect(l.productTomatoes, isNotEmpty);
  expect(l.productOnions, isNotEmpty);
  expect(l.bulkKg50, isNotEmpty);
  expect(l.bulkKg30, isNotEmpty);
  expect(l.bulkKg40, isNotEmpty);
  expect(l.batchCreated, isNotEmpty);

  // Batch details
  expect(l.batchDetails, isNotEmpty);
  expect(l.editBatch, isNotEmpty);
  expect(l.deleteBatch, isNotEmpty);
  expect(l.deleteBatchDialogTitle, isNotEmpty);
  expect(l.deleteBatchDialogMessage, isNotEmpty);
  expect(l.cancelDeleteBatch, isNotEmpty);
  expect(l.confirmDeleteBatch, isNotEmpty);
  expect(l.batchDeleted, isNotEmpty);

  // Join batch
  expect(l.joinBatch, isNotEmpty);
  expect(l.joinBatchTitle, isNotEmpty);
  expect(l.joinBatchSubtitle, isNotEmpty);
  expect(l.joinQuantityHint, isNotEmpty);
  expect(l.joinConfirm, isNotEmpty);
  expect(l.joinSuccess, isNotEmpty);
  expect(l.claimedQuantity, isNotEmpty);
  expect(l.batchSnapshot, isNotEmpty);

  // Orders
  expect(l.myOrders, isNotEmpty);
  expect(l.more, isNotEmpty);

  // Map / chat
  expect(l.mapViewTitle, isNotEmpty);
  expect(l.mapViewLead, isNotEmpty);
  expect(l.mapViewPlaceholder, isNotEmpty);
  expect(l.chatTitle, isNotEmpty);
  expect(l.chatLead, isNotEmpty);
  expect(l.chatProviderSubtitle, isNotEmpty);
  expect(l.chatBatchGroupTitle, isNotEmpty);
  expect(l.chatBatchGroupSubtitle, isNotEmpty);

  // Provider discovery
  expect(l.providerDiscovery, isNotEmpty);
  expect(l.providerDiscoverySubtitle, isNotEmpty);
  expect(l.moreNotificationsSubtitle, isNotEmpty);
  expect(l.moreSettingsSubtitle, isNotEmpty);
  expect(l.comingSoon, isNotEmpty);

  // Settings
  expect(l.profile, isNotEmpty);
  expect(l.language, isNotEmpty);
  expect(l.theme, isNotEmpty);
  expect(l.dark, isNotEmpty);
  expect(l.light, isNotEmpty);
  expect(l.nearbyBatches, isNotEmpty);
  expect(l.activeBatches, isNotEmpty);
  expect(l.join, isNotEmpty);
  expect(l.quantity, isNotEmpty);
  expect(l.bulkSize, isNotEmpty);
  expect(l.progress, isNotEmpty);
  expect(l.productName, isNotEmpty);
  expect(l.location, isNotEmpty);
  expect(l.submit, isNotEmpty);
  expect(l.logout, isNotEmpty);

  // Order statuses
  expect(l.orderStatusPending, isNotEmpty);
  expect(l.orderStatusTriggered, isNotEmpty);
  expect(l.orderStatusDelivered, isNotEmpty);
  expect(l.orderStatusCompleted, isNotEmpty);

  // Language / theme settings
  expect(l.changeLanguage, isNotEmpty);
  expect(l.english, isNotEmpty);
  expect(l.french, isNotEmpty);
  expect(l.switchTheme, isNotEmpty);
  expect(l.settings, isNotEmpty);
  expect(l.appPreferences, isNotEmpty);
  expect(l.accountPreferences, isNotEmpty);
  expect(l.notificationsPreferences, isNotEmpty);
  expect(l.openSettings, isNotEmpty);

  // Misc
  expect(l.mvpBadge, isNotEmpty);
  expect(l.hub, isNotEmpty);
  expect(l.full, isNotEmpty);
  expect(l.requested, isNotEmpty);
  expect(l.joinedBatch, isNotEmpty);
  expect(l.orderDetails, isNotEmpty);
  expect(l.createOrder, isNotEmpty);
  expect(l.createOrderTitle, isNotEmpty);
  expect(l.createOrderCta, isNotEmpty);
  expect(l.orderEmptyTitle, isNotEmpty);
  expect(l.orderEmptySubtitle, isNotEmpty);
  expect(l.errorMessage, isNotEmpty);
  expect(l.errorOccurred, isNotEmpty);

  // Profile edit
  expect(l.profileEditTitle, isNotEmpty);
  expect(l.profileEditImageHint, isNotEmpty);
  expect(l.profileFirstName, isNotEmpty);
  expect(l.profileFirstNameHint, isNotEmpty);
  expect(l.profileLastName, isNotEmpty);
  expect(l.profileLastNameHint, isNotEmpty);
  expect(l.profileEmailReadOnly, isNotEmpty);
  expect(l.profileEditSave, isNotEmpty);
  expect(l.profileEditValidationRequired, isNotEmpty);
  expect(l.successProfileUpdated, isNotEmpty);
  expect(l.errorProfileUpdate, isNotEmpty);

  // Become provider
  expect(l.becomeProvider, isNotEmpty);
  expect(l.createProviderProfile, isNotEmpty);
  expect(l.providerStep1Title, isNotEmpty);
  expect(l.providerStep1Subtitle, isNotEmpty);
  expect(l.providerStep2Title, isNotEmpty);
  expect(l.providerStep2Subtitle, isNotEmpty);
  expect(l.providerStep3Title, isNotEmpty);
  expect(l.providerStep3Subtitle, isNotEmpty);
  expect(l.providerBusinessName, isNotEmpty);
  expect(l.providerBusinessNameHint, isNotEmpty);
  expect(l.providerOwnerName, isNotEmpty);
  expect(l.providerOwnerNameHint, isNotEmpty);
  expect(l.providerCategory, isNotEmpty);
  expect(l.providerRegistrationNumber, isNotEmpty);
  expect(l.providerRegistrationNumberHint, isNotEmpty);
  expect(l.providerPhone, isNotEmpty);
  expect(l.providerPhoneHint, isNotEmpty);
  expect(l.providerBusinessEmail, isNotEmpty);
  expect(l.providerAddress, isNotEmpty);
  expect(l.providerAddressHint, isNotEmpty);
  expect(l.providerGpsTitle, isNotEmpty);
  expect(l.providerGpsNote, isNotEmpty);
  expect(l.providerLatitude, isNotEmpty);
  expect(l.providerLongitude, isNotEmpty);
  expect(l.providerDescription, isNotEmpty);
  expect(l.providerDescriptionHint, isNotEmpty);
  expect(l.providerUploadLogo, isNotEmpty);
  expect(l.providerUploadLogoHint, isNotEmpty);
  expect(l.providerUploadDocs, isNotEmpty);
  expect(l.providerAddDoc, isNotEmpty);
  expect(l.providerUploadDocsHint, isNotEmpty);
  expect(l.providerNoDocs, isNotEmpty);
  expect(l.providerLegalNote, isNotEmpty);
  expect(l.providerNext, isNotEmpty);
  expect(l.providerBack, isNotEmpty);
  expect(l.providerSubmit, isNotEmpty);
  expect(l.providerSubmitSuccess, isNotEmpty);
  expect(l.providerSubmitError, isNotEmpty);
  expect(l.providerStatusPending, isNotEmpty);
  expect(l.providerStatusVerified, isNotEmpty);
  expect(l.providerStatusRejected, isNotEmpty);
  expect(l.providerPendingNote, isNotEmpty);
  expect(l.providerFieldRequired, isNotEmpty);
  expect(l.providerCategoryGrocery, isNotEmpty);
  expect(l.providerCategoryHousehold, isNotEmpty);
  expect(l.providerCategoryElectronics, isNotEmpty);
  expect(l.providerCategoryClothing, isNotEmpty);
  expect(l.providerCategoryRestaurant, isNotEmpty);
  expect(l.providerCategoryOther, isNotEmpty);

  // Provider discovery & detail
  expect(l.providersVerifiedTitle, isNotEmpty);
  expect(l.providersScreenLead, isNotEmpty);
  expect(l.providerCardFollow, isNotEmpty);
  expect(l.providerCardFollowing, isNotEmpty);
  expect(l.providerCardContact, isNotEmpty);
  expect(l.providerNoResults, isNotEmpty);
  expect(l.providerNoResultsSubtitle, isNotEmpty);
  expect(l.providerNoVerified, isNotEmpty);
  expect(l.providerNoVerifiedSubtitle, isNotEmpty);
  expect(l.providerDetailTitle, isNotEmpty);
  expect(l.providerDetailOwner, isNotEmpty);
  expect(l.providerDetailRegistration, isNotEmpty);
  expect(l.providerDetailServices, isNotEmpty);
  expect(l.providerDetailLocationSection, isNotEmpty);
  expect(l.providerDetailViewOnMap, isNotEmpty);
  expect(l.providerDetailCreateBatch, isNotEmpty);
  expect(l.providerDetailContactProvider, isNotEmpty);

  // Batch / provider selectors
  expect(l.batchSelectProvider, isNotEmpty);
  expect(l.batchChangeProvider, isNotEmpty);
  expect(l.batchAutoProviderDesc, isNotEmpty);
  expect(l.getDirections, isNotEmpty);
  expect(l.mapOpenError, isNotEmpty);
  expect(l.batchImageLabel, isNotEmpty);
  expect(l.batchImageHint, isNotEmpty);
  expect(l.batchImageChange, isNotEmpty);

  // My batches
  expect(l.myBatchesSectionCreated, isNotEmpty);
  expect(l.myBatchesSectionJoined, isNotEmpty);
  expect(l.myBatchesEmpty, isNotEmpty);
  expect(l.myBatchesEmptySubtitle, isNotEmpty);
  expect(l.myBatchesCreatedBadge, isNotEmpty);
  expect(l.myBatchesFilled('25', '100'), isNotEmpty);
  expect(l.myBatchesJoinBtn, isNotEmpty);
  expect(l.myBatchesEditQuantity, isNotEmpty);
  expect(l.myBatchesUpdateQuantity, isNotEmpty);
  expect(l.myBatchesNewQuantityHint, isNotEmpty);
  expect(l.myBatchesQuantityUpdated, isNotEmpty);
  expect(l.myBatchesQuantityError, isNotEmpty);
}

void main() {
  group('AppLocalizationsEn', () {
    late AppLocalizationsEn l;
    setUpAll(() => l = AppLocalizationsEn());

    test('localeName is en', () => expect(l.localeName, 'en'));

    test('all strings are non-empty', () => _exerciseAll(l));

    test('batchProgressFilled includes percent', () {
      expect(l.batchProgressFilled(75), contains('75'));
    });

    test('verificationCodeSent includes email', () {
      expect(l.verificationCodeSent('test@x.com'), contains('test@x.com'));
    });

    test('myBatchesFilled includes values', () {
      expect(l.myBatchesFilled('25', '100'), contains('25'));
    });
  });

  group('AppLocalizationsFr', () {
    late AppLocalizationsFr l;
    setUpAll(() => l = AppLocalizationsFr());

    test('localeName is fr', () => expect(l.localeName, 'fr'));

    test('all strings are non-empty', () => _exerciseAll(l));

    test('batchProgressFilled includes percent', () {
      expect(l.batchProgressFilled(30), contains('30'));
    });

    test('myBatchesFilled includes values', () {
      expect(l.myBatchesFilled('10', '50'), contains('10'));
    });
  });

  group('AppLocalizations delegate', () {
    const delegate = AppLocalizations.delegate;

    test('isSupported returns true for en', () {
      expect(delegate.isSupported(const Locale('en')), isTrue);
    });

    test('isSupported returns true for fr', () {
      expect(delegate.isSupported(const Locale('fr')), isTrue);
    });

    test('isSupported returns false for unsupported locale', () {
      expect(delegate.isSupported(const Locale('es')), isFalse);
    });

    test('shouldReload returns false', () {
      expect(delegate.shouldReload(delegate), isFalse);
    });

    test('load returns AppLocalizationsEn for en', () async {
      final l = await delegate.load(const Locale('en'));
      expect(l.localeName, 'en');
    });

    test('load returns AppLocalizationsFr for fr', () async {
      final l = await delegate.load(const Locale('fr'));
      expect(l.localeName, 'fr');
    });

    test('lookupAppLocalizations throws for unsupported locale', () {
      expect(
        () => lookupAppLocalizations(const Locale('es')),
        throwsA(isA<FlutterError>()),
      );
    });
  });
}
