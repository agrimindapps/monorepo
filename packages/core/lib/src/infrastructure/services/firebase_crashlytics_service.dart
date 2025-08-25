import 'package:dartz/dartz.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../domain/repositories/i_crashlytics_repository.dart';
import '../../shared/config/environment_config.dart';
import '../../shared/utils/failure.dart';

/// Implementação concreta do repositório de crashlytics usando Firebase Crashlytics
class FirebaseCrashlyticsService implements ICrashlyticsRepository {
  final FirebaseCrashlytics _crashlytics;

  /// Cria uma instância do FirebaseCrashlyticsService
  FirebaseCrashlyticsService({
    FirebaseCrashlytics? crashlytics,
  }) : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  @override
  Future<Either<Failure, void>> recordError({
    required dynamic exception,
    required StackTrace stackTrace,
    String? reason,
    bool fatal = true,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      // Adicionar informações de contexto
      if (additionalInfo != null) {
        for (final entry in additionalInfo.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value as Object);
        }
      }

      // Definir informações do ambiente
      await _crashlytics.setCustomKey('environment', EnvironmentConfig.environmentName);
      await _crashlytics.setCustomKey('is_debug', EnvironmentConfig.isDebugMode);

      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure('Erro ao registrar crash: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> recordNonFatalError({
    required dynamic exception,
    required StackTrace stackTrace,
    String? reason,
    Map<String, dynamic>? additionalInfo,
  }) async {
    return recordError(
      exception: exception,
      stackTrace: stackTrace,
      reason: reason,
      fatal: false,
      additionalInfo: additionalInfo,
    );
  }

  @override
  Future<Either<Failure, void>> log(String message) async {
    try {
      await _crashlytics.log(message);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure('Erro ao registrar log: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure('Erro ao definir ID do usuário: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setCustomKey({
    required String key,
    required dynamic value,
  }) async {
    try {
      await _crashlytics.setCustomKey(key, value as Object);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure('Erro ao definir chave customizada: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setCustomKeys({
    required Map<String, dynamic> keys,
  }) async {
    try {
      for (final entry in keys.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value as Object);
      }
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure('Erro ao definir chaves customizadas: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isCrashlyticsCollectionEnabled() async {
    try {
      final isEnabled = _crashlytics.isCrashlyticsCollectionEnabled;
      return Right(isEnabled);
    } catch (e) {
      return Left(FirebaseFailure('Erro ao verificar status do Crashlytics: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setCrashlyticsCollectionEnabled({
    required bool enabled,
  }) async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure('Erro ao configurar coleta do Crashlytics: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> recordValidationError({
    required String field,
    required String message,
    Map<String, dynamic>? context,
  }) async {
    final exception = ValidationException(
      field: field,
      message: message,
      context: context,
    );

    return recordNonFatalError(
      exception: exception,
      stackTrace: StackTrace.current,
      reason: 'Validation Error',
      additionalInfo: {
        CrashlyticsKeys.feature: 'validation',
        'validation_field': field,
        'validation_message': message,
        ...?context,
      },
    );
  }

  @override
  Future<Either<Failure, void>> recordNetworkError({
    required String url,
    required int statusCode,
    String? errorMessage,
    Map<String, dynamic>? context,
  }) async {
    final exception = NetworkException(
      url: url,
      statusCode: statusCode,
      message: errorMessage,
    );

    return recordNonFatalError(
      exception: exception,
      stackTrace: StackTrace.current,
      reason: 'Network Error',
      additionalInfo: {
        CrashlyticsKeys.feature: 'network',
        'network_url': url,
        'status_code': statusCode,
        if (errorMessage != null) 'error_message': errorMessage,
        ...?context,
      },
    );
  }

  @override
  Future<Either<Failure, void>> recordParsingError({
    required String dataType,
    required String errorMessage,
    String? rawData,
    Map<String, dynamic>? context,
  }) async {
    final exception = ParsingException(
      dataType: dataType,
      message: errorMessage,
      rawData: rawData,
    );

    return recordNonFatalError(
      exception: exception,
      stackTrace: StackTrace.current,
      reason: 'Parsing Error',
      additionalInfo: {
        CrashlyticsKeys.feature: 'parsing',
        'data_type': dataType,
        'parsing_error': errorMessage,
        if (rawData != null) 'raw_data': _truncateData(rawData),
        ...?context,
      },
    );
  }

  @override
  Future<Either<Failure, void>> recordAuthError({
    required String authMethod,
    required String errorCode,
    required String errorMessage,
    Map<String, dynamic>? context,
  }) async {
    final exception = AuthException(
      method: authMethod,
      code: errorCode,
      message: errorMessage,
    );

    return recordNonFatalError(
      exception: exception,
      stackTrace: StackTrace.current,
      reason: 'Auth Error',
      additionalInfo: {
        CrashlyticsKeys.feature: 'auth',
        'auth_method': authMethod,
        'auth_error_code': errorCode,
        'auth_error_message': errorMessage,
        ...?context,
      },
    );
  }

  @override
  Future<Either<Failure, void>> recordPermissionError({
    required String permission,
    required String errorMessage,
    Map<String, dynamic>? context,
  }) async {
    final exception = PermissionException(
      permission: permission,
      message: errorMessage,
    );

    return recordNonFatalError(
      exception: exception,
      stackTrace: StackTrace.current,
      reason: 'Permission Error',
      additionalInfo: {
        CrashlyticsKeys.feature: 'permission',
        'permission_type': permission,
        'permission_error': errorMessage,
        ...?context,
      },
    );
  }

  @override
  Future<Either<Failure, void>> recordAppError({
    required String appName,
    required String feature,
    required String errorType,
    required String errorMessage,
    Map<String, dynamic>? context,
  }) async {
    final exception = AppSpecificException(
      appName: appName,
      feature: feature,
      type: errorType,
      message: errorMessage,
    );

    return recordNonFatalError(
      exception: exception,
      stackTrace: StackTrace.current,
      reason: 'App Specific Error',
      additionalInfo: {
        CrashlyticsKeys.appName: appName,
        CrashlyticsKeys.feature: feature,
        'error_type': errorType,
        'error_message': errorMessage,
        ...?context,
      },
    );
  }

  @override
  Future<Either<Failure, void>> recordSessionInfo({
    required String appVersion,
    required String buildNumber,
    required String platform,
    String? deviceModel,
    String? osVersion,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      await _crashlytics.setCustomKey('app_version', appVersion);
      await _crashlytics.setCustomKey('build_number', buildNumber);
      await _crashlytics.setCustomKey('platform', platform);
      if (deviceModel != null) {
        await _crashlytics.setCustomKey('device_model', deviceModel);
      }
      if (osVersion != null) {
        await _crashlytics.setCustomKey('os_version', osVersion);
      }
      await _crashlytics.setCustomKey('environment', EnvironmentConfig.environmentName);
      await _crashlytics.setCustomKey('session_start', DateTime.now().toIso8601String());
      
      // Set additional info if provided
      if (additionalInfo != null) {
        for (final entry in additionalInfo.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }

      await _crashlytics.log('Session started: $appVersion ($buildNumber) on $platform');
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure('Erro ao registrar informações da sessão: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> recordBreadcrumb({
    required String message,
    String? category,
    BreadcrumbLevel level = BreadcrumbLevel.info,
    Map<String, dynamic>? data,
  }) async {
    try {
      final breadcrumbMessage = [
        '[${level.name.toUpperCase()}]',
        if (category != null) '[$category]',
        message,
        if (data != null) '- Data: ${data.toString()}',
      ].join(' ');

      await _crashlytics.log(breadcrumbMessage);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure('Erro ao registrar breadcrumb: $e'));
    }
  }

  /// Trunca dados grandes para não sobrecarregar o Crashlytics
  String _truncateData(String data) {
    const maxLength = 1000;
    if (data.length <= maxLength) return data;
    return '${data.substring(0, maxLength)}... [TRUNCATED]';
  }
}

// Exceptions customizadas para melhor categorização
class ValidationException implements Exception {
  final String field;
  final String message;
  final Map<String, dynamic>? context;

  ValidationException({
    required this.field,
    required this.message,
    this.context,
  });

  @override
  String toString() => 'ValidationException: $field - $message';
}

class NetworkException implements Exception {
  final String url;
  final int statusCode;
  final String? message;

  NetworkException({
    required this.url,
    required this.statusCode,
    this.message,
  });

  @override
  String toString() => 'NetworkException: $statusCode on $url${message != null ? ' - $message' : ''}';
}

class ParsingException implements Exception {
  final String dataType;
  final String message;
  final String? rawData;

  ParsingException({
    required this.dataType,
    required this.message,
    this.rawData,
  });

  @override
  String toString() => 'ParsingException: $dataType - $message';
}

class AuthException implements Exception {
  final String method;
  final String code;
  final String message;

  AuthException({
    required this.method,
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'AuthException: $method - $code: $message';
}

class PermissionException implements Exception {
  final String permission;
  final String message;

  PermissionException({
    required this.permission,
    required this.message,
  });

  @override
  String toString() => 'PermissionException: $permission - $message';
}

class AppSpecificException implements Exception {
  final String appName;
  final String feature;
  final String type;
  final String message;

  AppSpecificException({
    required this.appName,
    required this.feature,
    required this.type,
    required this.message,
  });

  @override
  String toString() => 'AppSpecificException: $appName/$feature - $type: $message';
}