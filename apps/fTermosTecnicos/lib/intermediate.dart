import 'package:firebase_core/firebase_core.dart';

import 'app-termus/const/config_const.dart';
import 'app-termus/const/environment_const.dart';
import 'app-termus/const/firebase_consts.dart';

class GlobalEnvironment {
  GlobalEnvironment._();
  static final GlobalEnvironment _instance = GlobalEnvironment._();
  factory GlobalEnvironment() => _instance;
  static GlobalEnvironment get instance => _instance;

  // Environment variables bridge
  final Environment _env = Environment();

  // Static getters for Environment
  String get admobBanner => Environment.admobBanner;
  String get altAdmobBanner => Environment.altAdmobBanner;
  String get onOpenApp => Environment.onOpenApp;
  String get admobPremiado => Environment.admobPremiado;
  List<String> get keywordsAds => Environment.keywordsAds;

  // Instance getters for Environment
  String get siteApp => _env.siteApp;
  String get linkPoliticaPrivacidade => _env.linkPoliticaPrivacidade;
  String get linkTermoUso => _env.linkTermoUso;
  Map<String, dynamic> get hml => _env.hml;
  Map<String, dynamic> get prod => _env.prod;

  // Database constants
  List<Map<String, dynamic>> get listaDbJson => listaDbJson;

  // RevenueCat constants
  String entitlementID = 'Premium';
  String appleApiKey = 'appl_QXSaVxUhpIkHBdHyBHAGvjxTxTR';
  String googleApiKey = 'goog_JYcfxEUeRnReVEdsLkShLQnzCmf';

  // In-app purchase constants
  List<Map<String, dynamic>> get inappProductIds => inappProductIds;
  String get regexAssinatura => regexAssinatura;
  List<Map<String, dynamic>> get inappVantagens => inappVantagens;
  Map<String, String> get inappTermosUso => inappTermosUso;
  Map<String, dynamic> get infoAssinatura => infoAssinatura;

  // Firebase options
  static FirebaseOptions get firebaseOptions =>
      DefaultFirebaseOptions.currentPlatform;
  static FirebaseOptions get firebaseAndroid => DefaultFirebaseOptions.android;
  static FirebaseOptions get firebaseIOS => DefaultFirebaseOptions.ios;
  static FirebaseOptions get firebaseWeb => DefaultFirebaseOptions.web;
  static FirebaseOptions get firebaseMacOS => DefaultFirebaseOptions.macos;

  // Updates history
  List<Map<String, dynamic>> get atualizacoesText => atualizacoesText;

  String get iAppName => appName;
  String get iAppVersion => appVersion;
  String get iAppEmailContato => appEmailContato;

  //supabase
  String get iSupabaseUrl => _env.supabaseUrl;
  String get iSupabaseAnnoKey => _env.supabaseAnnoKey;

  // Menus
  List<Map<String, dynamic>> get itensMenuBottom => itensMenuBottom;

  // Method to initialize Environment
  void initialize() => _env.initialize();
}
