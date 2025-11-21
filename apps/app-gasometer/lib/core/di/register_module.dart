import 'package:core/core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  
  ImagePicker get imagePicker => ImagePicker();

  
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  
  ConnectivityService get connectivityService => ConnectivityService.instance;

  
  Connectivity get connectivity => Connectivity();


  
  IAppRatingRepository get appRatingRepository => AppRatingService();

  
  ImageCompressionService get imageCompressionService =>
      ImageCompressionService();

  
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

  
  FirebaseDeviceService get firebaseDeviceService => FirebaseDeviceService();

  
  FirebaseAuthService get firebaseAuthService => FirebaseAuthService();

  
  FirebaseAnalyticsService get firebaseAnalyticsService =>
      FirebaseAnalyticsService();

  
  IDeviceRepository get deviceRepository => FirebaseDeviceService();
}
