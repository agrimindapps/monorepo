import 'package:core/core.dart';
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
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @singleton
  ConnectivityService get connectivityService => ConnectivityService.instance;

  @singleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  ILocalStorageRepository get localStorageRepository =>
      HiveStorageService(GetIt.I<IBoxRegistryService>());

  @singleton
  IAppRatingRepository get appRatingRepository => AppRatingService();

  @singleton
  ImageCompressionService get imageCompressionService =>
      ImageCompressionService();

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

  @lazySingleton
  FirebaseDeviceService get firebaseDeviceService => FirebaseDeviceService();

  @lazySingleton
  FirebaseAuthService get firebaseAuthService => FirebaseAuthService();

  @lazySingleton
  FirebaseAnalyticsService get firebaseAnalyticsService =>
      FirebaseAnalyticsService();

  @lazySingleton
  IDeviceRepository get deviceRepository => FirebaseDeviceService();
}
