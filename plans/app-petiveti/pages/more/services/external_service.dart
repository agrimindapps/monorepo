// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../utils/more_constants.dart';

class ExternalService {
  static final ExternalService _instance = ExternalService._internal();
  factory ExternalService() => _instance;
  ExternalService._internal();

  // URL Launching
  Future<bool> launchURL(String url, {bool inApp = false}) async {
    try {
      final uri = Uri.parse(url);
      final mode = inApp ? LaunchMode.inAppWebView : LaunchMode.externalApplication;
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: mode);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('ExternalService: Error launching URL $url: $e');
      return false;
    }
  }

  Future<bool> launchAppStore() async {
    String url;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      url = MoreConstants.appStoreUrl;
    } else {
      url = MoreConstants.playStoreUrl;
    }
    return await launchURL(url);
  }

  Future<bool> launchWebsite() async {
    return await launchURL(MoreConstants.websiteUrl);
  }

  Future<bool> launchHelp() async {
    return await launchURL(MoreConstants.helpUrl);
  }

  Future<bool> launchPrivacyPolicy() async {
    return await launchURL(MoreConstants.privacyPolicyUrl);
  }

  Future<bool> launchTermsOfService() async {
    return await launchURL(MoreConstants.termsOfServiceUrl);
  }

  Future<bool> launchBlog() async {
    return await launchURL(MoreConstants.blogUrl);
  }

  Future<bool> launchFAQ() async {
    return await launchURL(MoreConstants.faqUrl);
  }

  // Social Media
  Future<bool> launchFacebook() async {
    return await launchURL(MoreConstants.facebookUrl);
  }

  Future<bool> launchInstagram() async {
    return await launchURL(MoreConstants.instagramUrl);
  }

  Future<bool> launchTwitter() async {
    return await launchURL(MoreConstants.twitterUrl);
  }

  Future<bool> launchYouTube() async {
    return await launchURL(MoreConstants.youtubeUrl);
  }

  Future<bool> launchLinkedIn() async {
    return await launchURL(MoreConstants.linkedinUrl);
  }

  // Email
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

      final emailLaunchUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('ExternalService: Error sending email: $e');
      return false;
    }
  }

  Future<bool> sendSupportEmail({String? message}) async {
    return await sendEmail(
      email: MoreConstants.supportEmail,
      subject: MoreConstants.supportEmailSubject,
      body: message,
    );
  }

  Future<bool> sendFeedbackEmail(String feedback) async {
    return await sendEmail(
      email: MoreConstants.feedbackEmail,
      subject: MoreConstants.feedbackEmailSubject,
      body: feedback,
    );
  }

  Future<bool> sendBugReportEmail(String bugReport) async {
    return await sendEmail(
      email: MoreConstants.bugReportEmail,
      subject: MoreConstants.bugReportEmailSubject,
      body: bugReport,
    );
  }

  Future<bool> sendBusinessEmail({String? message}) async {
    return await sendEmail(
      email: MoreConstants.businessEmail,
      subject: MoreConstants.businessEmailSubject,
      body: message,
    );
  }

  // Phone
  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final telLaunchUri = Uri(scheme: 'tel', path: phoneNumber);
      
      if (await canLaunchUrl(telLaunchUri)) {
        await launchUrl(telLaunchUri);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('ExternalService: Error making phone call: $e');
      return false;
    }
  }

  Future<bool> callSupport() async {
    return await makePhoneCall(MoreConstants.supportPhone);
  }

  // SMS
  Future<bool> sendSMS(String phoneNumber, {String? message}) async {
    try {
      final Map<String, String> queryParameters = {};
      if (message != null) queryParameters['body'] = message;

      final smsLaunchUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      if (await canLaunchUrl(smsLaunchUri)) {
        await launchUrl(smsLaunchUri);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('ExternalService: Error sending SMS: $e');
      return false;
    }
  }

  // Sharing
  Future<bool> shareText(String text, {String? subject}) async {
    try {
      await Share.share(text, subject: subject);
      return true;
    } catch (e) {
      debugPrint('ExternalService: Error sharing text: $e');
      return false;
    }
  }

  Future<bool> shareApp() async {
    final storeUrl = defaultTargetPlatform == TargetPlatform.iOS 
        ? MoreConstants.appStoreUrl 
        : MoreConstants.playStoreUrl;
    
    return await shareText(
      '${MoreConstants.defaultShareMessage} $storeUrl',
      subject: 'Confira o ${MoreConstants.appName}!',
    );
  }

  Future<bool> sharePremium() async {
    return await shareText(
      MoreConstants.premiumShareMessage,
      subject: '${MoreConstants.appName} Premium',
    );
  }

  Future<bool> shareFeedback() async {
    return await shareText(
      MoreConstants.feedbackShareMessage,
      subject: 'Recomendação do ${MoreConstants.appName}',
    );
  }

  Future<bool> shareWithPlatform({
    required String text,
    String? subject,
    String? platform,
  }) async {
    try {
      if (platform != null) {
        // In a real implementation, you could use platform-specific sharing
        // For now, just use the general share
      }
      
      await Share.share(text, subject: subject);
      return true;
    } catch (e) {
      debugPrint('ExternalService: Error sharing with platform: $e');
      return false;
    }
  }

  // File Operations
  Future<bool> shareFile(String filePath, {String? text, String? subject}) async {
    try {
      await Share.shareXFiles([XFile(filePath)], text: text, subject: subject);
      return true;
    } catch (e) {
      debugPrint('ExternalService: Error sharing file: $e');
      return false;
    }
  }

  Future<bool> shareFiles(List<String> filePaths, {String? text, String? subject}) async {
    try {
      final xFiles = filePaths.map((path) => XFile(path)).toList();
      await Share.shareXFiles(xFiles, text: text, subject: subject);
      return true;
    } catch (e) {
      debugPrint('ExternalService: Error sharing files: $e');
      return false;
    }
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

  // Platform Utilities
  static String getPlatformStoreUrl() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return MoreConstants.appStoreUrl;
    } else {
      return MoreConstants.playStoreUrl;
    }
  }

  static String getPlatformPackageName() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return MoreConstants.androidPackageName;
      case TargetPlatform.iOS:
        return MoreConstants.iosAppId;
      case TargetPlatform.windows:
        return MoreConstants.windowsAppId;
      case TargetPlatform.macOS:
        return MoreConstants.macosAppId;
      case TargetPlatform.linux:
        return MoreConstants.linuxAppId;
      default:
        return MoreConstants.androidPackageName;
    }
  }

  // Error Handling
  String getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return 'Erro desconhecido';
  }

  // Utility Methods
  Future<Map<String, bool>> testConnectivity() async {
    final results = <String, bool>{};
    
    try {
      results['website'] = await launchURL(MoreConstants.websiteUrl);
      results['help'] = await launchURL(MoreConstants.helpUrl);
      results['store'] = await launchURL(getPlatformStoreUrl());
    } catch (e) {
      debugPrint('ExternalService: Connectivity test error: $e');
    }
    
    return results;
  }

  Map<String, dynamic> getServiceInfo() {
    return {
      'platform': defaultTargetPlatform.name,
      'storeUrl': getPlatformStoreUrl(),
      'packageName': getPlatformPackageName(),
      'supportEmail': MoreConstants.supportEmail,
      'supportPhone': MoreConstants.supportPhone,
      'websiteUrl': MoreConstants.websiteUrl,
      'helpUrl': MoreConstants.helpUrl,
    };
  }

  Future<Map<String, dynamic>> getCapabilities() async {
    return {
      'canLaunchUrl': true,
      'canSendEmail': await canLaunchUrl(Uri(scheme: 'mailto', path: 'test@example.com')),
      'canMakePhoneCall': await canLaunchUrl(Uri(scheme: 'tel', path: '+1234567890')),
      'canSendSMS': await canLaunchUrl(Uri(scheme: 'sms', path: '+1234567890')),
      'canShare': true,
    };
  }
}
