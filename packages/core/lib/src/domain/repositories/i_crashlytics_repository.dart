import 'package:dartz/dartz.dart';
import '../../shared/utils/failure.dart';

/// Interface do repositório de crashlytics
/// Define os contratos para operações de monitoramento via Firebase Crashlytics
abstract class ICrashlyticsRepository {
  /// Registra um erro fatal (que causou crash)
  Future<Either<Failure, void>> recordError({
    required dynamic exception,
    required StackTrace stackTrace,
    String? reason,
    bool fatal = true,
    Map<String, dynamic>? additionalInfo,
  });

  /// Registra um erro não-fatal
  Future<Either<Failure, void>> recordNonFatalError({
    required dynamic exception,
    required StackTrace stackTrace,
    String? reason,
    Map<String, dynamic>? additionalInfo,
  });

  /// Registra uma mensagem de log customizada
  Future<Either<Failure, void>> log(String message);

  /// Define o ID do usuário para rastreamento
  Future<Either<Failure, void>> setUserId(String userId);

  /// Define uma chave-valor customizada
  Future<Either<Failure, void>> setCustomKey({
    required String key,
    required dynamic value,
  });

  /// Define múltiplas chaves customizadas
  Future<Either<Failure, void>> setCustomKeys({
    required Map<String, dynamic> keys,
  });

  /// Verifica se o Crashlytics está habilitado
  Future<Either<Failure, bool>> isCrashlyticsCollectionEnabled();

  /// Habilita/desabilita coleta de dados do Crashlytics
  Future<Either<Failure, void>> setCrashlyticsCollectionEnabled({
    required bool enabled,
  });

  /// Métodos de conveniência para diferentes tipos de erro
  
  /// Registra erro de validação
  Future<Either<Failure, void>> recordValidationError({
    required String field,
    required String message,
    Map<String, dynamic>? context,
  });

  /// Registra erro de rede
  Future<Either<Failure, void>> recordNetworkError({
    required String url,
    required int statusCode,
    String? errorMessage,
    Map<String, dynamic>? context,
  });

  /// Registra erro de parsing/serialização
  Future<Either<Failure, void>> recordParsingError({
    required String dataType,
    required String errorMessage,
    String? rawData,
    Map<String, dynamic>? context,
  });

  /// Registra erro de autenticação
  Future<Either<Failure, void>> recordAuthError({
    required String authMethod,
    required String errorCode,
    required String errorMessage,
    Map<String, dynamic>? context,
  });

  /// Registra erro de permissão
  Future<Either<Failure, void>> recordPermissionError({
    required String permission,
    required String errorMessage,
    Map<String, dynamic>? context,
  });

  /// Registra erro específico do app
  Future<Either<Failure, void>> recordAppError({
    required String appName, // 'plantis' ou 'receituagro'
    required String feature,
    required String errorType,
    required String errorMessage,
    Map<String, dynamic>? context,
  });

  /// Registra informações de sessão
  Future<Either<Failure, void>> recordSessionInfo({
    required String appVersion,
    required String buildNumber,
    required String platform,
    String? deviceModel,
    String? osVersion,
    Map<String, dynamic>? additionalInfo,
  });

  /// Registra breadcrumb personalizado
  Future<Either<Failure, void>> recordBreadcrumb({
    required String message,
    String? category,
    BreadcrumbLevel level = BreadcrumbLevel.info,
    Map<String, dynamic>? data,
  });
}

/// Níveis de severidade para breadcrumbs
enum BreadcrumbLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

extension BreadcrumbLevelExtension on BreadcrumbLevel {
  String get name {
    switch (this) {
      case BreadcrumbLevel.debug:
        return 'debug';
      case BreadcrumbLevel.info:
        return 'info';
      case BreadcrumbLevel.warning:
        return 'warning';
      case BreadcrumbLevel.error:
        return 'error';
      case BreadcrumbLevel.fatal:
        return 'fatal';
    }
  }

  int get severity {
    switch (this) {
      case BreadcrumbLevel.debug:
        return 0;
      case BreadcrumbLevel.info:
        return 1;
      case BreadcrumbLevel.warning:
        return 2;
      case BreadcrumbLevel.error:
        return 3;
      case BreadcrumbLevel.fatal:
        return 4;
    }
  }
}

/// Chaves customizadas padrão para Crashlytics
class CrashlyticsKeys {
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String appName = 'app_name';
  static const String feature = 'feature';
  static const String subscriptionTier = 'subscription_tier';
  static const String environment = 'environment';
  static const String buildType = 'build_type';
  static const String deviceType = 'device_type';
  static const String connectionType = 'connection_type';
  static const String lastAction = 'last_action';
  static const String screenName = 'screen_name';
}

/// Tipos de erro comuns para categorização
class ErrorTypes {
  static const String network = 'network';
  static const String parsing = 'parsing';
  static const String validation = 'validation';
  static const String auth = 'auth';
  static const String permission = 'permission';
  static const String storage = 'storage';
  static const String subscription = 'subscription';
  static const String ui = 'ui';
  static const String logic = 'logic';
  static const String external = 'external';
}
