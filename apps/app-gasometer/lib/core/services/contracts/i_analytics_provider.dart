import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

/// Interface abstrata para análise (analytics)
/// 
/// Segregada conforme ISP - apenas responsável por operações de analytics
/// Abstrai Firebase para facilitar testes e mudanças futuras
abstract class IAnalyticsProvider {
  /// Registra evento customizado
  Future<Either<Failure, void>> logEvent(
    String eventName,
    Map<String, dynamic>? parameters,
  );

  /// Registra erro
  Future<Either<Failure, void>> logError(
    String error,
    StackTrace? stackTrace,
  );

  /// Define propriedade do usuário
  Future<Either<Failure, void>> setUserProperty(String name, String value);

  /// Registra tempo de tela
  Future<Either<Failure, void>> logScreenView(String screenName);
}
