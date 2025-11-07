import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @singleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @singleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @singleton
  ImagePicker get imagePicker => ImagePicker();

  @singleton
  GoogleSignIn get googleSignIn {
    if (kIsWeb) {
      return GoogleSignIn(signInOption: SignInOption.standard);
    }
    return GoogleSignIn();
  }

  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @singleton
  ConnectivityService get connectivityService => ConnectivityService.instance;

  @singleton
  Connectivity get connectivity => Connectivity();

  // ❌ REMOVIDO: BoxRegistryService já é registrado no core package
  // Não devemos registrar novamente aqui para evitar múltiplas instâncias

  // ✅ IMPORTANTE: Usar @lazySingleton para evitar erro de "não registrado"
  // O BoxRegistryService só é registrado DEPOIS pelo CoreModule
  // LazySingleton adia a criação até o primeiro uso
  @lazySingleton
  ILocalStorageRepository get localStorageRepository =>
      HiveStorageService(GetIt.I<IBoxRegistryService>());

  @singleton
  IAppRatingRepository get appRatingRepository => AppRatingService();

  @singleton
  ImageCompressionService get imageCompressionService =>
      ImageCompressionService();

  // ❌ REMOVIDO: IAuthRepository já é registrado pelo core package
  // Manter aqui causa erro "already registered"
  // @lazySingleton
  // IAuthRepository get authRepository => FirebaseAuthService();

  // ❌ REMOVIDO: ISubscriptionRepository já é registrado pelo core package
  // Manter aqui causa erro "already registered"
  // @lazySingleton
  // ISubscriptionRepository get subscriptionRepository => RevenueCatService();

  /// DataCleanerService is registered via @lazySingleton annotation on the class

  /// EnhancedAnalyticsService for GasometerAnalyticsService
  /// NOTE: This requires Firebase to be initialized. Will be null in local-only mode.
  @lazySingleton
  EnhancedAnalyticsService get enhancedAnalyticsService {
    try {
      return EnhancedAnalyticsService(
        analytics: FirebaseAnalyticsService(),
        crashlytics: FirebaseCrashlyticsService(),
        config: AnalyticsConfig.forApp(appId: 'gasometer', version: '1.0.0'),
      );
    } catch (e) {
      // Return a stub if Firebase is not initialized
      throw UnimplementedError(
        'EnhancedAnalyticsService requires Firebase. Initialize Firebase before accessing this service.',
      );
    }
  }

  /// FirebaseDeviceService for DeviceManagementService
  @lazySingleton
  FirebaseDeviceService get firebaseDeviceService => FirebaseDeviceService();

  /// FirebaseAuthService concrete class (already registered as IAuthRepository)
  @lazySingleton
  FirebaseAuthService get firebaseAuthService => FirebaseAuthService();

  /// FirebaseAnalyticsService concrete class (for DeviceManagementService)
  @lazySingleton
  FirebaseAnalyticsService get firebaseAnalyticsService =>
      FirebaseAnalyticsService();

  /// IDeviceRepository - FirebaseDeviceService implements this
  @lazySingleton
  IDeviceRepository get deviceRepository => FirebaseDeviceService();
}
