import 'package:firebase_analytics/firebase_analytics.dart';

class GAnalyticsService {
  static final GAnalyticsService _singleton = GAnalyticsService._internal();

  factory GAnalyticsService() {
    return _singleton;
  }

  GAnalyticsService._internal();

  static void initializeService() {
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
  }

  static Future<void> setCurrentScreen(String screenName) async {
    await FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
      screenClass: 'AnalyticsDemo',
    );
  }
  static Future<void> logCustomEvent(String eventName,
      {Map<String, Object>? parameters}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  static Future<void> logAppOpen() async {
    await FirebaseAnalytics.instance.logAppOpen();
    logInstall();
  }

  static Future<void> logInstall() async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'install',
      parameters: <String, Object>{
        'name': 'install',
      },
    );
  }
}
