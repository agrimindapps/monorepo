import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../domain/repositories/i_analytics_repository.dart';
import '../../shared/config/environment_config.dart';
import '../../shared/utils/failure.dart';

/// Implementação concreta do repositório de analytics usando Firebase Analytics
class FirebaseAnalyticsService implements IAnalyticsRepository {
  final FirebaseAnalytics? _analytics;

  /// Cria uma instância do FirebaseAnalyticsService
  FirebaseAnalyticsService({
    FirebaseAnalytics? analytics,
  }) : _analytics = analytics ?? (kIsWeb ? null : FirebaseAnalytics.instance);

  @override
  Future<Either<Failure, void>> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      if (kIsWeb || !EnvironmentConfig.enableAnalytics) {
        if (EnvironmentConfig.enableLogging) {
          developer.log('📊 Analytics (${kIsWeb ? 'WEB' : 'DEBUG'}): $eventName - $parameters', name: 'FirebaseAnalytics');
        }
        return const Right(null);
      }

      await _analytics?.logEvent(
        name: eventName,
        parameters: _sanitizeParameters(parameters),
      );

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure('Erro ao registrar evento: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setUserProperties({
    required Map<String, String> properties,
  }) async {
    try {
      if (kIsWeb || !EnvironmentConfig.enableAnalytics) {
        if (EnvironmentConfig.enableLogging) {
          developer.log('📊 Analytics Properties (${kIsWeb ? 'WEB' : 'DEBUG'}): $properties', name: 'FirebaseAnalytics');
        }
        return const Right(null);
      }

      for (final entry in properties.entries) {
        await _analytics?.setUserProperty(
          name: entry.key,
          value: entry.value,
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure('Erro ao definir propriedades: $e'));
    }
  }

  /// Define uma única propriedade do usuário
  Future<Either<Failure, void>> setUserProperty(String name, String value) async {
    return await setUserProperties(properties: {name: value});
  }

  @override
  Future<Either<Failure, void>> setUserId(String? userId) async {
    try {
      if (kIsWeb || !EnvironmentConfig.enableAnalytics) {
        if (EnvironmentConfig.enableLogging) {
          developer.log('📊 Analytics User ID (${kIsWeb ? 'WEB' : 'DEBUG'}): $userId', name: 'FirebaseAnalytics');
        }
        return const Right(null);
      }

      await _analytics?.setUserId(id: userId);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure('Erro ao definir ID do usuário: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setCurrentScreen({
    required String screenName,
    String? screenClassOverride,
  }) async {
    try {
      if (kIsWeb || !EnvironmentConfig.enableAnalytics) {
        if (EnvironmentConfig.enableLogging) {
          developer.log('📊 Analytics Screen (${kIsWeb ? 'WEB' : 'DEBUG'}): $screenName', name: 'FirebaseAnalytics');
        }
        return const Right(null);
      }

      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClassOverride,
      );

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure('Erro ao registrar tela: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logLogin({
    required String method,
  }) async {
    return logEvent(
      'login',
      parameters: {
        'login_method': method,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<Either<Failure, void>> logLogout() async {
    return logEvent(
      'logout',
      parameters: {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<Either<Failure, void>> logSignUp({
    required String method,
  }) async {
    return logEvent(
      'sign_up',
      parameters: {
        'signup_method': method,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<Either<Failure, void>> logPurchase({
    required String productId,
    required double value,
    required String currency,
    String? transactionId,
  }) async {
    return logEvent(
      'purchase',
      parameters: {
        'item_id': productId,
        'value': value,
        'currency': currency.toUpperCase(),
        if (transactionId != null) 'transaction_id': transactionId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<Either<Failure, void>> logCancelSubscription({
    required String productId,
    String? reason,
  }) async {
    return logEvent(
      'cancel_subscription',
      parameters: {
        'product_id': productId,
        if (reason != null) 'cancellation_reason': reason,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<Either<Failure, void>> logTrialStart({
    required String productId,
  }) async {
    return logEvent(
      'trial_start',
      parameters: {
        'product_id': productId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<Either<Failure, void>> logTrialConversion({
    required String productId,
  }) async {
    return logEvent(
      'trial_conversion',
      parameters: {
        'product_id': productId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<Either<Failure, void>> logError({
    required String error,
    String? stackTrace,
    Map<String, dynamic>? additionalInfo,
  }) async {
    final parameters = <String, dynamic>{
      'error_message': error,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    if (stackTrace != null) {
      parameters['stack_trace'] = stackTrace.length > 100
          ? '${stackTrace.substring(0, 100)}...'
          : stackTrace;
    }

    if (additionalInfo != null) {
      parameters.addAll(additionalInfo);
    }

    return logEvent('app_error', parameters: parameters);
  }

  @override
  Future<Either<Failure, void>> logSearch({
    required String searchTerm,
    String? category,
    int? resultCount,
  }) async {
    return logEvent(
      'search',
      parameters: {
        'search_term': searchTerm,
        if (category != null) 'search_category': category,
        if (resultCount != null) 'result_count': resultCount,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<Either<Failure, void>> logShare({
    required String contentType,
    required String contentId,
    String? method,
  }) async {
    return logEvent(
      'share',
      parameters: {
        'content_type': contentType,
        'content_id': contentId,
        if (method != null) 'share_method': method,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<Either<Failure, void>> logFeedback({
    required String type,
    required String content,
    double? rating,
  }) async {
    return logEvent(
      'feedback',
      parameters: {
        'feedback_type': type,
        'feedback_content': content.length > 100
            ? '${content.substring(0, 100)}...'
            : content,
        if (rating != null) 'rating': rating,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<Either<Failure, void>> logOnboardingComplete({
    int? stepsCompleted,
    int? totalSteps,
  }) async {
    return logEvent(
      'onboarding_complete',
      parameters: {
        if (stepsCompleted != null) 'steps_completed': stepsCompleted,
        if (totalSteps != null) 'total_steps': totalSteps,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<Either<Failure, void>> logTutorialComplete({
    required String tutorialId,
  }) async {
    return logEvent(
      'tutorial_complete',
      parameters: {
        'tutorial_id': tutorialId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<Either<Failure, void>> logSettingChanged({
    required String settingName,
    required dynamic oldValue,
    required dynamic newValue,
  }) async {
    return logEvent(
      'setting_changed',
      parameters: {
        'setting_name': settingName,
        'old_value': oldValue.toString(),
        'new_value': newValue.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Sanitiza parâmetros para garantir compatibilidade com Firebase Analytics
  Map<String, Object>? _sanitizeParameters(Map<String, dynamic>? parameters) {
    if (parameters == null) return null;

    final sanitized = <String, Object>{};
    
    for (final entry in parameters.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is String) {
        sanitized[key] = value.length > 100 ? value.substring(0, 100) : value;
      } else if (value is num || value is bool) {
        sanitized[key] = value as Object;
      } else if (value != null) {
        final stringValue = value.toString();
        sanitized[key] = stringValue.length > 100 
            ? stringValue.substring(0, 100) 
            : stringValue;
      }
    }
    sanitized['environment'] = EnvironmentConfig.environmentName;
    sanitized['app_version'] = '1.0.0'; // TODO: Pegar versão real

    return sanitized;
  }
}