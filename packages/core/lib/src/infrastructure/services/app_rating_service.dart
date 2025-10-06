import 'package:rate_my_app/rate_my_app.dart';
import '../../domain/repositories/i_app_rating_repository.dart';

/// Service for handling app rating functionality using rate_my_app package
class AppRatingService implements IAppRatingRepository {
  late final RateMyApp _rateMyApp;
  
  /// Creates an AppRatingService
  /// 
  /// [appStoreId] - iOS App Store ID (required for iOS)
  /// [googlePlayId] - Google Play Store ID (required for Android)
  /// [minDays] - Minimum days before showing rating dialog
  /// [minLaunches] - Minimum app launches before showing rating dialog
  /// [remindDays] - Days to wait before asking again if user chose "Later"
  /// [remindLaunches] - Launches to wait before asking again if user chose "Later"
  AppRatingService({
    String? appStoreId,
    String? googlePlayId,
    int minDays = 7,
    int minLaunches = 10,
    int remindDays = 7,
    int remindLaunches = 10,
  }) {
    _rateMyApp = RateMyApp(
      preferencesPrefix: 'rateMyApp_',
      minDays: minDays,
      minLaunches: minLaunches,
      remindDays: remindDays,
      remindLaunches: remindLaunches,
      appStoreIdentifier: appStoreId,
      googlePlayIdentifier: googlePlayId,
    );
  }

  /// Initialize the rate my app instance
  Future<void> init() async {
    await _rateMyApp.init();
  }

  @override
  Future<bool> showRatingDialog({context}) async {
    try {
      await init();
      
      if (context == null) return false;
      
      if (_rateMyApp.shouldOpenDialog) {
        await _rateMyApp.showRateDialog(
          context,
          title: 'Avalie o App',
          message: 'Você está gostando do aplicativo? Que tal nos dar uma avaliação na loja?',
          rateButton: 'AVALIAR',
          noButton: 'NÃO, OBRIGADO',
          laterButton: 'TALVEZ MAIS TARDE',
          listener: (button) {
            switch (button) {
              case RateMyAppDialogButton.rate:
                return true; // Opens the app store
              case RateMyAppDialogButton.later:
                return false; // Will ask again later
              case RateMyAppDialogButton.no:
                return false; // Won't ask again
            }
          },
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> openAppStore() async {
    try {
      await init();
      await _rateMyApp.launchStore();
      return true; // Se não lançar exceção, assume que foi bem-sucedido
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> canShowRatingDialog() async {
    try {
      await init();
      return _rateMyApp.shouldOpenDialog;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> incrementUsageCount() async {
    try {
      await init();
    } catch (e) {
    }
  }

  @override
  Future<void> markAsRated() async {
    try {
      await init();
      _rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
    } catch (e) {
    }
  }

  @override
  Future<bool> hasUserRated() async {
    try {
      await init();
      return !_rateMyApp.shouldOpenDialog;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setMinimumUsageCount(int count) async {
  }

  @override
  Future<void> resetRatingPreferences() async {
    try {
      await _rateMyApp.reset();
    } catch (e) {
    }
  }
}