import 'package:dartz/dartz.dart';
import '../../shared/utils/failure.dart';

/// Interface do repositório de analytics
/// Define os contratos para operações de analytics via Firebase
abstract class IAnalyticsRepository {
  /// Registra um evento de analytics
  Future<Either<Failure, void>> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  });

  /// Define propriedades do usuário para analytics
  Future<Either<Failure, void>> setUserProperties({
    required Map<String, String> properties,
  });

  /// Define o ID do usuário para analytics
  Future<Either<Failure, void>> setUserId(String? userId);

  /// Registra a tela/página atual
  Future<Either<Failure, void>> setCurrentScreen({
    required String screenName,
    String? screenClassOverride,
  });

  /// Eventos específicos comuns entre os apps
  
  /// Registra login do usuário
  Future<Either<Failure, void>> logLogin({
    required String method, // 'email', 'google', 'apple', etc.
  });

  /// Registra logout do usuário
  Future<Either<Failure, void>> logLogout();

  /// Registra cadastro de novo usuário
  Future<Either<Failure, void>> logSignUp({
    required String method,
  });

  /// Registra compra/assinatura
  Future<Either<Failure, void>> logPurchase({
    required String productId,
    required double value,
    required String currency,
    String? transactionId,
  });

  /// Registra cancelamento de assinatura
  Future<Either<Failure, void>> logCancelSubscription({
    required String productId,
    String? reason,
  });

  /// Registra início de trial
  Future<Either<Failure, void>> logTrialStart({
    required String productId,
  });

  /// Registra conversão de trial para pago
  Future<Either<Failure, void>> logTrialConversion({
    required String productId,
  });

  /// Registra erro da aplicação
  Future<Either<Failure, void>> logError({
    required String error,
    String? stackTrace,
    Map<String, dynamic>? additionalInfo,
  });

  /// Registra busca realizada
  Future<Either<Failure, void>> logSearch({
    required String searchTerm,
    String? category,
    int? resultCount,
  });

  /// Registra compartilhamento de conteúdo
  Future<Either<Failure, void>> logShare({
    required String contentType,
    required String contentId,
    String? method, // 'whatsapp', 'telegram', etc.
  });

  /// Registra feedback do usuário
  Future<Either<Failure, void>> logFeedback({
    required String type, // 'rating', 'suggestion', 'bug', etc.
    required String content,
    double? rating,
  });

  /// Registra onboarding completado
  Future<Either<Failure, void>> logOnboardingComplete({
    int? stepsCompleted,
    int? totalSteps,
  });

  /// Registra tutorial completado
  Future<Either<Failure, void>> logTutorialComplete({
    required String tutorialId,
  });

  /// Registra configuração alterada
  Future<Either<Failure, void>> logSettingChanged({
    required String settingName,
    required dynamic oldValue,
    required dynamic newValue,
  });
}
