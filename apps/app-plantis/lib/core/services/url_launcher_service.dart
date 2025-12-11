import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../constants/app_config.dart';

/// Service for handling URL launches with validation and error handling
/// Provides consistent URL opening across the application with analytics tracking
class UrlLauncherService {
  static final UrlLauncherService _instance = UrlLauncherService._internal();
  factory UrlLauncherService() => _instance;
  UrlLauncherService._internal();

  /// Launch URL with comprehensive error handling and validation
  Future<UrlLaunchResult> launchUrl(
    String url, {
    String? source,
    Map<String, dynamic>? analyticsParameters,
    url_launcher.LaunchMode mode = url_launcher.LaunchMode.externalApplication,
  }) async {
    try {
      if (!AppConfig.isValidUrl(url)) {
        return UrlLaunchResult.failure(
          error: UrlLaunchError.invalidUrl,
          message: 'URL inválida: $url',
          url: url,
        );
      }

      final uri = Uri.parse(url);
      final canLaunch = await url_launcher.canLaunchUrl(uri);
      if (!canLaunch) {
        return UrlLaunchResult.failure(
          error: UrlLaunchError.cannotLaunch,
          message: 'Não é possível abrir este link',
          url: url,
        );
      }
      final launched = await _launchUrlSafely(uri, mode);

      if (launched) {
        _trackUrlLaunch(url, source, analyticsParameters, success: true);

        return UrlLaunchResult.success(
          url: url,
          message: 'Link aberto com sucesso',
        );
      } else {
        _trackUrlLaunch(url, source, analyticsParameters, success: false);

        return UrlLaunchResult.failure(
          error: UrlLaunchError.launchFailed,
          message: 'Falha ao abrir o link',
          url: url,
        );
      }
    } catch (e) {
      _trackUrlLaunch(
        url,
        source,
        analyticsParameters,
        success: false,
        exception: e.toString(),
      );

      return UrlLaunchResult.failure(
        error: UrlLaunchError.exception,
        message: 'Erro inesperado ao abrir o link: ${e.toString()}',
        url: url,
      );
    }
  }

  /// Safely launch URL with platform-specific handling
  Future<bool> _launchUrlSafely(Uri uri, url_launcher.LaunchMode mode) async {
    try {
      return await url_launcher.launchUrl(uri, mode: mode);
    } catch (e) {
      if (mode != url_launcher.LaunchMode.externalApplication) {
        try {
          return await url_launcher.launchUrl(
            uri,
            mode: url_launcher.LaunchMode.externalApplication,
          );
        } catch (fallbackError) {
          if (kDebugMode) {
            print('URL Launch fallback failed: $fallbackError');
          }
          return false;
        }
      }

      if (kDebugMode) {
        print('URL Launch failed: $e');
      }
      return false;
    }
  }

  /// Launch email with pre-filled subject and body
  Future<UrlLaunchResult> launchEmail({
    required String email,
    String? subject,
    String? body,
    String? source,
  }) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );

    return await launchUrl(
      emailUri.toString(),
      source: source ?? 'email_launcher',
      analyticsParameters: {
        'email_type': 'support',
        'has_subject': subject != null,
        'has_body': body != null,
      },
    );
  }

  /// Launch phone dialer with number
  Future<UrlLaunchResult> launchPhone(
    String phoneNumber, {
    String? source,
  }) async {
    final phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    return await launchUrl(
      phoneUri.toString(),
      source: source ?? 'phone_launcher',
      analyticsParameters: {'action': 'phone_call'},
    );
  }

  /// Launch SMS with pre-filled message
  Future<UrlLaunchResult> launchSMS({
    required String phoneNumber,
    String? message,
    String? source,
  }) async {
    final smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: message != null ? {'body': message} : null,
    );

    return await launchUrl(
      smsUri.toString(),
      source: source ?? 'sms_launcher',
      analyticsParameters: {
        'action': 'sms_send',
        'has_message': message != null,
      },
    );
  }

  /// Launch store page for app rating/review
  Future<UrlLaunchResult> launchStoreReview({String? source}) async {
    final storeUrl = defaultTargetPlatform == TargetPlatform.iOS
        ? AppConfig.appStoreUrl
        : AppConfig.googlePlayUrl;

    return await launchUrl(
      storeUrl,
      source: source ?? 'store_review',
      analyticsParameters: {
        'action': 'store_review',
        'platform': defaultTargetPlatform.name,
      },
    );
  }

  /// Track URL launch events (placeholder for analytics integration)
  void _trackUrlLaunch(
    String url,
    String? source,
    Map<String, dynamic>? additionalParameters, {
    required bool success,
    String? exception,
  }) {
    if (kDebugMode) {
      print(
        'URL Launch Event: '
        'url=$url, '
        'source=$source, '
        'success=$success'
        '${exception != null ? ', exception=$exception' : ''}',
      );
    }
  }
}

/// Result of URL launch operation
class UrlLaunchResult {
  final bool isSuccess;
  final String url;
  final String message;
  final UrlLaunchError? error;

  const UrlLaunchResult._({
    required this.isSuccess,
    required this.url,
    required this.message,
    this.error,
  });

  factory UrlLaunchResult.success({
    required String url,
    required String message,
  }) => UrlLaunchResult._(isSuccess: true, url: url, message: message);

  factory UrlLaunchResult.failure({
    required UrlLaunchError error,
    required String message,
    required String url,
  }) => UrlLaunchResult._(
    isSuccess: false,
    url: url,
    message: message,
    error: error,
  );

  @override
  String toString() =>
      'UrlLaunchResult(success: $isSuccess, url: $url, message: $message)';
}

/// Types of URL launch errors
enum UrlLaunchError { invalidUrl, cannotLaunch, launchFailed, exception }

/// Extension to provide user-friendly error messages
extension UrlLaunchErrorExtension on UrlLaunchError {
  String get description {
    switch (this) {
      case UrlLaunchError.invalidUrl:
        return 'O link fornecido é inválido';
      case UrlLaunchError.cannotLaunch:
        return 'Este tipo de link não pode ser aberto neste dispositivo';
      case UrlLaunchError.launchFailed:
        return 'Falha ao abrir o link. Verifique se você tem um aplicativo compatível instalado';
      case UrlLaunchError.exception:
        return 'Ocorreu um erro inesperado ao tentar abrir o link';
    }
  }
}
