import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../services/data_cleaner_service.dart';

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

  @singleton
  IBoxRegistryService get boxRegistryService => BoxRegistryService();

  @singleton
  ILocalStorageRepository get localStorageRepository =>
      HiveStorageService(boxRegistryService);

  @singleton
  IAppRatingRepository get appRatingRepository => AppRatingService();

  @singleton
  ImageCompressionService get imageCompressionService =>
      ImageCompressionService();

  /// IAuthRepository - registered manually in CoreModule, but needs to be
  /// accessible via Injectable for module dependencies
  @lazySingleton
  IAuthRepository get authRepository => FirebaseAuthService();

  /// ISubscriptionRepository - registered manually in CoreModule, but needs to be
  /// accessible via Injectable for module dependencies
  @lazySingleton
  ISubscriptionRepository get subscriptionRepository => RevenueCatService();

  /// DataCleanerService for migration services
  @lazySingleton
  DataCleanerService get dataCleanerService => DataCleanerService.instance;

  /// EnhancedAnalyticsService for GasometerAnalyticsService
  /// NOTE: This requires Firebase to be initialized. Will be null in local-only mode.
  @lazySingleton
  EnhancedAnalyticsService get enhancedAnalyticsService {
    try {
      return EnhancedAnalyticsService(
        analytics: FirebaseAnalyticsService(),
        crashlytics: FirebaseCrashlyticsService(),
        config: AnalyticsConfig.forApp(
          appId: 'gasometer',
          version: '1.0.0',
        ),
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
