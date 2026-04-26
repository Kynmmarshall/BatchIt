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
  String get home => 'Accueil';

  @override
  String get createBatch => 'Creer un batch';

  @override
  String get batchDetails => 'Details du batch';

  @override
  String get joinBatch => 'Rejoindre le batch';

  @override
  String get myOrders => 'Mes commandes';

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
  String get mvpBadge => 'MVP';

  @override
  String get hub => 'Hub';

  @override
  String get full => 'Complet';

  @override
  String get requested => 'Demande';

  @override
  String get batchCreated => 'Batch cree avec succes';

  @override
  String get joinedBatch => 'Vous avez rejoint le batch';
}
