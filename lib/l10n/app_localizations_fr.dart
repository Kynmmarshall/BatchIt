// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'BatchIt';

  @override
  String get welcomeTitle => 'Acheter ensemble. Economiser ensemble.';

  @override
  String get welcomeSubtitle =>
      'Creez des batches locaux, atteignez les seuils de gros et recuperez au hub.';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'Inscription';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get continueCta => 'Continuer';

  @override
  String get getStarted => 'Commencer';

  @override
  String get signInCta => 'Se connecter';

  @override
  String get signUpCta => 'S\'inscrire';

  @override
  String get orContinueWith => 'Ou continuer avec';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get savePassword => 'Enregistrer le mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublie ?';

  @override
  String get alreadyHaveAnAccount => 'Vous avez deja un compte ?';

  @override
  String get didntHaveAnAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get loginSubtitle =>
      'Accedez a votre compte en toute securite avec\nvotre e-mail et mot de passe';

  @override
  String get registerNow => 'Inscrivez-vous';

  @override
  String get registerSubtitle =>
      'Inscrivez-vous avec votre e-mail et mot de passe\npour continuer';

  @override
  String get questionnaireTitle => 'Dites-nous ce que vous achetez';

  @override
  String get questionnaireSubtitle =>
      'Aidez BatchIt a recommander de meilleurs batches selon vos habitudes et preferences.';

  @override
  String get productCategories => 'Categories de produits';

  @override
  String get shoppingFrequency => 'Frequence d\'achat';

  @override
  String get preferredRegions => 'Regions preferees';

  @override
  String get budgetRange => 'Budget';

  @override
  String get questionnaireContinue => 'Continuer vers la connexion';

  @override
  String get questionnaireSkip => 'Passer pour le moment';

  @override
  String get questionnaireChipGroceries => 'Courses';

  @override
  String get questionnaireChipHousehold => 'Maison';

  @override
  String get questionnaireChipSnacks => 'Snacks';

  @override
  String get questionnaireChipWeekly => 'Hebdomadaire';

  @override
  String get questionnaireChipBiweekly => 'Toutes les deux semaines';

  @override
  String get questionnaireChipMonthly => 'Mensuel';

  @override
  String get questionnaireChipNearby => 'Proche';

  @override
  String get questionnaireChipCitywide => 'Toute la ville';

  @override
  String get questionnaireChipFlexible => 'Flexible';

  @override
  String get verificationCodeTitle => 'Code de verification';

  @override
  String verificationCodeSent(String email) {
    return 'Nous avons envoye le code a votre adresse e-mail :\n$email';
  }

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get confirm => 'Confirmer';

  @override
  String get onboardingTitle1 => 'Bienvenue sur BatchIt';

  @override
  String get onboardingDesc1 =>
      'Achetez ensemble, economisez ensemble. Rejoignez des acheteurs locaux et atteignez plus vite les seuils de gros.';

  @override
  String get onboardingTitle2 => 'Decouvrez les batches locaux intelligents';

  @override
  String get onboardingDesc2 =>
      'Decouvrez les batches proches de vous et collaborez avec des hubs de confiance.';

  @override
  String get onboardingTitle3 => 'Votre partenaire courses au quotidien';

  @override
  String get onboardingDesc3 =>
      'Suivez la progression en direct, recevez les notifications de seuil atteint et recuperez facilement.';

  @override
  String get open => 'Ouvert';

  @override
  String get dailyDealsHeadline => 'Offres\nBatchIt du jour';

  @override
  String get popularBatches => 'Batches populaires';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get noBatchesForFilter => 'Aucun batch pour ce filtre.';

  @override
  String batchProgressFilled(int percent) {
    return '$percent% rempli';
  }

  @override
  String get perKg => '/kg';

  @override
  String get batchNotFound => 'Batch introuvable';

  @override
  String get routeNotFound => 'Route introuvable';

  @override
  String get profileDefaultName => 'Utilisateur BatchIt';

  @override
  String get profileDefaultEmail => 'user@batchit.app';

  @override
  String get profileSubtitle =>
      'Gerez votre compte, vos commandes et vos preferences au meme endroit.';

  @override
  String get profileOrdersSubtitle =>
      'Consultez l\'historique de vos commandes et revenez aux commandes actives.';

  @override
  String get providerPreferences => 'Preferences des fournisseurs';

  @override
  String get providerPreferencesSubtitle =>
      'Suivez les hubs dont vous voulez recevoir les mises a jour.';

  @override
  String get profileLanguageSubtitle =>
      'Choisissez la langue preferree de l\'application.';

  @override
  String get profileThemeSubtitle =>
      'Basculez entre les apparences claire et sombre.';

  @override
  String get profileNotificationsSubtitle =>
      'Controlez les alertes qui doivent arriver sur cet appareil.';

  @override
  String get notificationsScreenTitle => 'Notifications';

  @override
  String get notificationsScreenSubtitle =>
      'Consultez les alertes, marquez-les comme lues et ajustez les appareils a notifier.';

  @override
  String get notificationsScreenLead =>
      'Suivez en un seul endroit les changements de batch, les mises a jour de commande et l\'activite des fournisseurs.';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get unreadOnly => 'Non lues uniquement';

  @override
  String get noNotificationsTitle => 'Vous êtes a jour';

  @override
  String get noNotificationsSubtitle =>
      'Les nouvelles alertes de batch et de commande apparaitront ici.';

  @override
  String get batchFilledNotification => 'Un batch que vous suivez est complet';

  @override
  String get orderReadyNotification =>
      'Votre commande est prete pour le retrait';

  @override
  String get providerUpdatedNotification =>
      'Un fournisseur que vous suivez a publie une mise a jour';

  @override
  String get batchExpiredNotification => 'Un batch actif a expire';

  @override
  String get profileReminderNotification =>
      'Completez votre profil pour améliorer les recommandations';

  @override
  String get viewDetails => 'Voir les details';

  @override
  String get openBatch => 'Ouvrir le batch';

  @override
  String get openOrder => 'Ouvrir la commande';

  @override
  String get openProfile => 'Ouvrir le profil';

  @override
  String get batchAlerts => 'Alertes de batch';

  @override
  String get batchAlertsSubtitle =>
      'Recevez une notification lorsque le statut d\'un batch change.';

  @override
  String get orderAlerts => 'Alertes de commande';

  @override
  String get orderAlertsSubtitle =>
      'Suivez les mises a jour des commandes prêtes et terminees.';

  @override
  String get providerAlerts => 'Alertes des fournisseurs';

  @override
  String get providerAlertsSubtitle =>
      'Recevez les nouvelles des fournisseurs que vous suivez.';

  @override
  String get dashboardSubtitle =>
      'Trouvez des batches proches et rejoignez-les plus vite.';

  @override
  String get search => 'Recherche';

  @override
  String get searchBatches => 'Rechercher des batches';

  @override
  String get searchHint => 'Rechercher des batches ou fournisseurs';

  @override
  String get searchModeBatches => 'Batches';

  @override
  String get searchModeProviders => 'Fournisseurs';

  @override
  String get noSearchResults => 'Aucun resultat pour votre recherche.';

  @override
  String get home => 'Accueil';

  @override
  String get createBatch => 'Creer un batch';

  @override
  String get createBatchTitle => 'Creer un nouveau batch';

  @override
  String get createBatchSubtitle =>
      'Choisissez un produit, definissez la quantite cible et envoyez-le a un hub.';

  @override
  String get productSelection => 'Choisir un produit';

  @override
  String get bulkSelection => 'Choisir la quantite';

  @override
  String get providerSelection => 'Choisir un hub';

  @override
  String get batchNoteOptional => 'Note facultative';

  @override
  String get batchNoteHint =>
      'Ajoutez une date limite ou un message pour les participants';

  @override
  String get customProduct => 'Produit personnalise';

  @override
  String get providerAuto => 'Hub attribue automatiquement';

  @override
  String get providerAinSebaa => 'Hub Ain Sebaa';

  @override
  String get providerCentre => 'Hub Centre';

  @override
  String get providerEast => 'Hub Est';

  @override
  String get productPotatoes => 'Pommes de terre';

  @override
  String get productTomatoes => 'Tomates';

  @override
  String get productOnions => 'Oignons';

  @override
  String get bulkKg50 => '50 kg';

  @override
  String get bulkKg30 => '30 kg';

  @override
  String get bulkKg40 => '40 kg';

  @override
  String get batchCreated => 'Batch cree avec succes';

  @override
  String get batchDetails => 'Details du batch';

  @override
  String get joinBatch => 'Rejoindre le batch';

  @override
  String get joinBatchTitle => 'Rejoindre ce batch';

  @override
  String get joinBatchSubtitle =>
      'Choisissez la quantite que vous souhaitez prendre et confirmez votre participation.';

  @override
  String get joinQuantityHint => 'Saisir la quantite en kg';

  @override
  String get joinConfirm => 'Confirmer la participation';

  @override
  String get joinSuccess => 'Vous avez rejoint le batch';

  @override
  String get claimedQuantity => 'Quantite demandee';

  @override
  String get batchSnapshot => 'Apercu du batch';

  @override
  String get myOrders => 'Mes batches';

  @override
  String get more => 'Plus';

  @override
  String get mapViewTitle => 'Vue carte';

  @override
  String get mapViewLead =>
      'Parcourez les fournisseurs et batches sur une carte.';

  @override
  String get mapViewPlaceholder =>
      'L\'integration de la carte interactive arrive bientot.';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatLead =>
      'Ouvrez des conversations avec les participants et les fournisseurs.';

  @override
  String get chatProviderSubtitle => 'Conversation support fournisseur';

  @override
  String get chatBatchGroupTitle => 'Groupe du batch';

  @override
  String get chatBatchGroupSubtitle =>
      'Mises a jour avec les participants du batch';

  @override
  String get providerDiscovery => 'Decouverte des fournisseurs';

  @override
  String get providerDiscoverySubtitle =>
      'Trouvez et suivez des fournisseurs pres de vous.';

  @override
  String get moreNotificationsSubtitle =>
      'Consultez l\'historique des alertes et les preferences.';

  @override
  String get moreSettingsSubtitle =>
      'Gerez les preferences de l\'application et du compte.';

  @override
  String get comingSoon => 'Bientot disponible';

  @override
  String get profile => 'Profil';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Theme';

  @override
  String get dark => 'Sombre';

  @override
  String get light => 'Clair';

  @override
  String get nearbyBatches => 'Batches a proximite';

  @override
  String get activeBatches => 'Batches actifs';

  @override
  String get join => 'Rejoindre';

  @override
  String get quantity => 'Quantite';

  @override
  String get bulkSize => 'Quantite en gros';

  @override
  String get progress => 'Progression';

  @override
  String get productName => 'Nom du produit';

  @override
  String get location => 'Localisation';

  @override
  String get submit => 'Valider';

  @override
  String get logout => 'Deconnexion';

  @override
  String get orderStatusPending => 'En attente';

  @override
  String get orderStatusTriggered => 'Declenchee';

  @override
  String get orderStatusDelivered => 'Livree';

  @override
  String get orderStatusCompleted => 'Terminee';

  @override
  String get changeLanguage => 'Changer de langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Francais';

  @override
  String get switchTheme => 'Changer le theme';

  @override
  String get settings => 'Parametres';

  @override
  String get appPreferences => 'Preferences de l\'application';

  @override
  String get accountPreferences => 'Preferences du compte';

  @override
  String get notificationsPreferences => 'Preferences de notifications';

  @override
  String get openSettings => 'Ouvrir les parametres';

  @override
  String get mvpBadge => 'MVP';

  @override
  String get hub => 'Hub';

  @override
  String get full => 'Complet';

  @override
  String get requested => 'Demande';

  @override
  String get joinedBatch => 'Vous avez rejoint le batch';

  @override
  String get orderDetails => 'Détails de la commande';

  @override
  String get createOrder => 'Créer une commande';

  @override
  String get createOrderTitle => 'Créer une nouvelle commande';

  @override
  String get createOrderCta => 'Passer la commande';

  @override
  String get orderEmptyTitle => 'Aucune commande';

  @override
  String get orderEmptySubtitle =>
      'Passez votre première commande pour commencer';

  @override
  String get errorMessage => 'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get errorOccurred => 'Erreur';

  @override
  String get profileEditTitle => 'Modifier le profil';

  @override
  String get profileEditImageHint => 'Appuyez pour modifier la photo de profil';

  @override
  String get profileFirstName => 'Prénom';

  @override
  String get profileFirstNameHint => 'Entrez votre prénom';

  @override
  String get profileLastName => 'Nom de famille';

  @override
  String get profileLastNameHint => 'Entrez votre nom de famille';

  @override
  String get profileEmailReadOnly => 'L\'e-mail ne peut pas être modifié';

  @override
  String get profileEditSave => 'Enregistrer les modifications';

  @override
  String get profileEditValidationRequired =>
      'Veuillez remplir tous les champs';

  @override
  String get successProfileUpdated => 'Profil mis à jour avec succès';

  @override
  String get errorProfileUpdate => 'Impossible de mettre à jour le profil';

  @override
  String get becomeProvider => 'Devenir prestataire';

  @override
  String get createProviderProfile => 'Créer un profil prestataire';

  @override
  String get providerStep1Title => 'Informations commerciales';

  @override
  String get providerStep1Subtitle => 'Parlez-nous de votre entreprise.';

  @override
  String get providerStep2Title => 'Contact & Localisation';

  @override
  String get providerStep2Subtitle =>
      'Comment les clients peuvent vous trouver.';

  @override
  String get providerStep3Title => 'Documents & Description';

  @override
  String get providerStep3Subtitle =>
      'Téléchargez les documents de vérification et décrivez vos services.';

  @override
  String get providerBusinessName => 'Nom de l\'entreprise';

  @override
  String get providerBusinessNameHint => 'ex. Marché Ain Sebaa';

  @override
  String get providerOwnerName => 'Nom complet du propriétaire';

  @override
  String get providerOwnerNameHint =>
      'Entrez le nom légal complet du propriétaire';

  @override
  String get providerCategory => 'Catégorie d\'activité';

  @override
  String get providerRegistrationNumber =>
      'Numéro d\'immatriculation / licence';

  @override
  String get providerRegistrationNumberHint =>
      'Entrez votre numéro d\'immatriculation';

  @override
  String get providerPhone => 'Numéro de téléphone';

  @override
  String get providerPhoneHint => '+212 6XX XXX XXX';

  @override
  String get providerBusinessEmail => 'E-mail professionnel';

  @override
  String get providerAddress => 'Adresse de l\'entreprise';

  @override
  String get providerAddressHint => 'Adresse complète';

  @override
  String get providerGpsTitle => 'Coordonnées GPS';

  @override
  String get providerGpsNote =>
      'Entrez les coordonnées GPS de votre entreprise pour que les clients puissent vous trouver. Les deux champs sont optionnels.';

  @override
  String get providerLatitude => 'Latitude';

  @override
  String get providerLongitude => 'Longitude';

  @override
  String get providerDescription => 'Services & Produits';

  @override
  String get providerDescriptionHint =>
      'Décrivez ce que vous vendez ou proposez aux membres du batch...';

  @override
  String get providerUploadLogo => 'Logo de l\'entreprise (optionnel)';

  @override
  String get providerUploadLogoHint => 'Appuyez pour télécharger le logo';

  @override
  String get providerUploadDocs => 'Documents commerciaux';

  @override
  String get providerAddDoc => 'Ajouter un fichier';

  @override
  String get providerUploadDocsHint =>
      'Certificat d\'immatriculation, licence ou pièce d\'identité — PDF ou image';

  @override
  String get providerNoDocs => 'Aucun document ajouté';

  @override
  String get providerLegalNote =>
      'Toutes les informations et documents soumis sont traités en toute sécurité et examinés uniquement par les administrateurs BatchIt.';

  @override
  String get providerNext => 'Suivant';

  @override
  String get providerBack => 'Retour';

  @override
  String get providerSubmit => 'Soumettre pour vérification';

  @override
  String get providerSubmitSuccess =>
      'Profil soumis ! Notre équipe l\'examinera dans les 48 heures.';

  @override
  String get providerSubmitError =>
      'Échec de la soumission. Veuillez réessayer.';

  @override
  String get providerStatusPending => 'En attente de vérification';

  @override
  String get providerStatusVerified => 'Vérifié';

  @override
  String get providerStatusRejected => 'Rejeté';

  @override
  String get providerPendingNote =>
      'Votre profil prestataire a été soumis et est en attente d\'approbation par un administrateur. Vous serez notifié une fois examiné.';

  @override
  String get providerFieldRequired => 'Ce champ est obligatoire';

  @override
  String get providerCategoryGrocery => 'Épicerie & Alimentation';

  @override
  String get providerCategoryHousehold => 'Maison & Ménage';

  @override
  String get providerCategoryElectronics => 'Électronique';

  @override
  String get providerCategoryClothing => 'Vêtements & Mode';

  @override
  String get providerCategoryRestaurant => 'Restaurant';

  @override
  String get providerCategoryOther => 'Autre';

  @override
  String get providersVerifiedTitle => 'Prestataires Vérifiés';

  @override
  String get providersScreenLead =>
      'Parcourez les hubs vérifiés et connectez-vous avec des prestataires de confiance près de chez vous.';

  @override
  String get providerCardFollow => 'Suivre';

  @override
  String get providerCardFollowing => 'Suivi';

  @override
  String get providerCardContact => 'Contacter';

  @override
  String get providerNoResults =>
      'Aucun prestataire ne correspond à votre recherche';

  @override
  String get providerNoResultsSubtitle =>
      'Essayez un autre mot-clé ou une autre catégorie.';

  @override
  String get providerNoVerified => 'Aucun prestataire vérifié pour le moment';

  @override
  String get providerNoVerifiedSubtitle =>
      'Revenez bientôt — de nouveaux hubs sont en cours d\'intégration.';

  @override
  String get providerDetailTitle => 'Détails du Prestataire';

  @override
  String get providerDetailOwner => 'Propriétaire';

  @override
  String get providerDetailRegistration => 'Immatriculation';

  @override
  String get providerDetailServices => 'Services & Produits';

  @override
  String get providerDetailLocationSection => 'Localisation de l\'entreprise';

  @override
  String get providerDetailViewOnMap => 'Voir sur la carte';

  @override
  String get providerDetailCreateBatch => 'Créer un Batch avec ce Prestataire';

  @override
  String get providerDetailContactProvider => 'Contacter le Prestataire';

  @override
  String get batchSelectProvider => 'Sélectionner un Prestataire';

  @override
  String get batchChangeProvider => 'Modifier';

  @override
  String get batchAutoProviderDesc =>
      'BatchIt assignera le hub disponible le plus proche';
}
