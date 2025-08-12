// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../models/launch_countdown_model.dart';
import '../models/pre_register_model.dart';

class LaunchService {
  static final LaunchService _instance = LaunchService._internal();
  factory LaunchService() => _instance;
  LaunchService._internal();

  // Platform store URLs
  static const Map<String, String> _storeUrls = {
    'android': 'https://play.google.com/store/apps/details?id=com.petiveti',
    'ios': 'https://apps.apple.com/app/petiveti/id123456789',
  };

  // Social media URLs
  static const Map<String, String> _socialUrls = {
    'facebook': 'https://facebook.com/petiveti',
    'instagram': 'https://instagram.com/petiveti',
    'twitter': 'https://twitter.com/petiveti',
    'youtube': 'https://youtube.com/petiveti',
    'linkedin': 'https://linkedin.com/company/petiveti',
  };

  // Website URLs
  static const Map<String, String> _websiteUrls = {
    'home': 'https://petiveti.com',
    'about': 'https://petiveti.com/about',
    'help': 'https://petiveti.com/help',
    'privacy': 'https://petiveti.com/privacy',
    'terms': 'https://petiveti.com/terms',
    'blog': 'https://petiveti.com/blog',
    'contact': 'https://petiveti.com/contact',
  };

  // Store operations
  Future<bool> openAppStore(AppPlatform platform) async {
    try {
      final url = getStoreUrl(platform);
      if (url != null) {
        return await _launchUrl(url);
      }
      return false;
    } catch (e) {
      debugPrint('LaunchService: Error opening app store: $e');
      return false;
    }
  }

  Future<bool> openGooglePlay() async {
    return await openAppStore(AppPlatform.android);
  }

  Future<bool> openAppStoreIOS() async {
    return await openAppStore(AppPlatform.ios);
  }

  String? getStoreUrl(AppPlatform platform) {
    return _storeUrls[platform.id];
  }

  Map<String, String> getAllStoreUrls() {
    return Map.unmodifiable(_storeUrls);
  }

  // Social media operations
  Future<bool> openSocialMedia(String platform) async {
    try {
      final url = _socialUrls[platform.toLowerCase()];
      if (url != null) {
        return await _launchUrl(url);
      }
      return false;
    } catch (e) {
      debugPrint('LaunchService: Error opening social media: $e');
      return false;
    }
  }

  Future<bool> openFacebook() async {
    return await openSocialMedia('facebook');
  }

  Future<bool> openInstagram() async {
    return await openSocialMedia('instagram');
  }

  Future<bool> openTwitter() async {
    return await openSocialMedia('twitter');
  }

  Future<bool> openYouTube() async {
    return await openSocialMedia('youtube');
  }

  Future<bool> openLinkedIn() async {
    return await openSocialMedia('linkedin');
  }

  String? getSocialUrl(String platform) {
    return _socialUrls[platform.toLowerCase()];
  }

  Map<String, String> getAllSocialUrls() {
    return Map.unmodifiable(_socialUrls);
  }

  // Website operations
  Future<bool> openWebsite({String page = 'home'}) async {
    try {
      final url = _websiteUrls[page.toLowerCase()];
      if (url != null) {
        return await _launchUrl(url);
      }
      return false;
    } catch (e) {
      debugPrint('LaunchService: Error opening website: $e');
      return false;
    }
  }

  Future<bool> openHomePage() async {
    return await openWebsite(page: 'home');
  }

  Future<bool> openAboutPage() async {
    return await openWebsite(page: 'about');
  }

  Future<bool> openHelpPage() async {
    return await openWebsite(page: 'help');
  }

  Future<bool> openPrivacyPolicy() async {
    return await openWebsite(page: 'privacy');
  }

  Future<bool> openTermsOfService() async {
    return await openWebsite(page: 'terms');
  }

  Future<bool> openBlog() async {
    return await openWebsite(page: 'blog');
  }

  Future<bool> openContactPage() async {
    return await openWebsite(page: 'contact');
  }

  String? getWebsiteUrl(String page) {
    return _websiteUrls[page.toLowerCase()];
  }

  Map<String, String> getAllWebsiteUrls() {
    return Map.unmodifiable(_websiteUrls);
  }

  // Email operations
  Future<bool> sendEmail({
    required String email,
    String? subject,
    String? body,
    List<String>? cc,
    List<String>? bcc,
  }) async {
    try {
      final Map<String, String> queryParameters = {};
      
      if (subject != null) queryParameters['subject'] = subject;
      if (body != null) queryParameters['body'] = body;
      if (cc != null && cc.isNotEmpty) queryParameters['cc'] = cc.join(',');
      if (bcc != null && bcc.isNotEmpty) queryParameters['bcc'] = bcc.join(',');

      final emailUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      return await _launchUri(emailUri);
    } catch (e) {
      debugPrint('LaunchService: Error sending email: $e');
      return false;
    }
  }

  Future<bool> sendSupportEmail({String? message}) async {
    return await sendEmail(
      email: 'suporte@petiveti.com',
      subject: 'Suporte PetiVeti - Página Promocional',
      body: message,
    );
  }

  Future<bool> sendFeedbackEmail(String feedback) async {
    return await sendEmail(
      email: 'feedback@petiveti.com',
      subject: 'Feedback PetiVeti',
      body: feedback,
    );
  }

  Future<bool> sendContactEmail({String? message}) async {
    return await sendEmail(
      email: 'contato@petiveti.com',
      subject: 'Contato PetiVeti',
      body: message,
    );
  }

  // Phone operations
  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final telUri = Uri(scheme: 'tel', path: phoneNumber);
      return await _launchUri(telUri);
    } catch (e) {
      debugPrint('LaunchService: Error making phone call: $e');
      return false;
    }
  }

  Future<bool> callSupport() async {
    return await makePhoneCall('+5511999999999');
  }

  // SMS operations
  Future<bool> sendSMS(String phoneNumber, {String? message}) async {
    try {
      final Map<String, String> queryParameters = {};
      if (message != null) queryParameters['body'] = message;

      final smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      return await _launchUri(smsUri);
    } catch (e) {
      debugPrint('LaunchService: Error sending SMS: $e');
      return false;
    }
  }

  // Platform detection
  AppPlatform getCurrentPlatform() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppPlatform.ios;
    } else {
      return AppPlatform.android;
    }
  }

  String getCurrentPlatformName() {
    return getCurrentPlatform().displayName;
  }

  String getCurrentStoreName() {
    return getCurrentPlatform().storeName;
  }

  String? getCurrentStoreUrl() {
    return getStoreUrl(getCurrentPlatform());
  }

  // Launch information
  LaunchInformation getLaunchInformation() {
    return const LaunchInformation(
      appName: 'PetiVeti',
      version: '1.0.0',
      platforms: ['Android', 'iOS'],
      storeUrls: _storeUrls,
      releaseNotes: 'Primeira versão do PetiVeti com recursos completos para cuidado de pets.',
      newFeatures: [
        'Perfis de pets personalizados',
        'Controle de vacinas e medicamentos',
        'Lembretes inteligentes',
        'Gráficos de peso e saúde',
        'Histórico de consultas',
        'Sincronização em nuvem',
      ],
    );
  }

  // Countdown integration
  LaunchCountdown getCurrentCountdown() {
    return LaunchCountdownRepository.getCurrentCountdown();
  }

  bool isAppLaunched() {
    return getCurrentCountdown().isLaunched;
  }

  bool isCountdownActive() {
    return getCurrentCountdown().isCountdownActive;
  }

  String getCountdownMessage() {
    return getCurrentCountdown().countdownText;
  }

  String getLaunchStatus() {
    return getCurrentCountdown().statusMessage;
  }

  // Validation
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  static bool isValidPhoneNumber(String phoneNumber) {
    return RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(phoneNumber);
  }

  // Batch operations
  Future<Map<String, bool>> openMultipleUrls(List<String> urls) async {
    final results = <String, bool>{};
    
    for (final url in urls) {
      results[url] = await _launchUrl(url);
      // Add small delay between launches
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    return results;
  }

  Future<bool> shareOnAllSocialMedia(String message) async {
    final socialUrls = getAllSocialUrls();
    final results = <bool>[];
    
    for (final platform in socialUrls.keys) {
      final success = await openSocialMedia(platform);
      results.add(success);
    }
    
    return results.any((success) => success);
  }

  // Analytics and tracking
  void trackLaunchAction(String action, {Map<String, dynamic>? properties}) {
    debugPrint('Launch action tracked: $action, properties: $properties');
    // In a real implementation, send to analytics service
  }

  void trackStoreOpened(AppPlatform platform) {
    trackLaunchAction('store_opened', properties: {'platform': platform.id});
  }

  void trackSocialOpened(String platform) {
    trackLaunchAction('social_opened', properties: {'platform': platform});
  }

  void trackWebsiteOpened(String page) {
    trackLaunchAction('website_opened', properties: {'page': page});
  }

  void trackEmailSent(String type) {
    trackLaunchAction('email_sent', properties: {'type': type});
  }

  // Capability checks
  Future<Map<String, bool>> checkCapabilities() async {
    return {
      'canLaunchUrl': true,
      'canSendEmail': await canLaunchUrl(Uri(scheme: 'mailto', path: 'test@example.com')),
      'canMakePhoneCall': await canLaunchUrl(Uri(scheme: 'tel', path: '+1234567890')),
      'canSendSMS': await canLaunchUrl(Uri(scheme: 'sms', path: '+1234567890')),
    };
  }

  // Error handling
  String getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return 'Erro desconhecido ao abrir link';
  }

  // Private helper methods
  Future<bool> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await _launchUri(uri);
    } catch (e) {
      debugPrint('LaunchService: Error parsing URL $url: $e');
      return false;
    }
  }

  Future<bool> _launchUri(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('LaunchService: Error launching URI $uri: $e');
      return false;
    }
  }

  // Service information
  Map<String, dynamic> getServiceInfo() {
    return {
      'storeUrls': _storeUrls,
      'socialUrls': _socialUrls,
      'websiteUrls': _websiteUrls,
      'currentPlatform': getCurrentPlatform().id,
      'isAppLaunched': isAppLaunched(),
      'isCountdownActive': isCountdownActive(),
    };
  }
}
