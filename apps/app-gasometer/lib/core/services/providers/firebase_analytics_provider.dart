import 'dart:developer' as developer;
import 'package:core/core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../contracts/i_analytics_provider.dart';

/// Provider de analytics implementando IAnalyticsProvider
///
/// **Implementação de:** IAnalyticsProvider
///
/// **Responsabilidades:**
/// - Registrar eventos customizados no Firebase Analytics
/// - Registrar erros
/// - Definir propriedades do usuário
/// - Rastrear visualizações de tela
/// - Abstração de FirebaseAnalytics para o resto da aplicação
///
/// **Princípio SOLID:**
/// - Single Responsibility: Apenas operações de analytics
/// - Dependency Injection: FirebaseAnalytics injetado
/// - Interface Segregation: Implementa apenas IAnalyticsProvider
/// - Dependency Inversion: Depende de abstração, não de implementação direta
///
/// **Exemplo:**
/// ```dart
/// final analyticsProvider = FirebaseAnalyticsProvider(
///   firebaseAnalytics: FirebaseAnalytics.instance,
/// );
/// 
/// final result = await analyticsProvider.logEvent(
///   'fuel_added',
///   {'amount': 50.0, 'vehicle_id': 'v123'},
/// );
/// result.fold(
///   (failure) => print('Event logging failed: ${failure.message}'),
///   (_) => print('Event logged successfully'),
/// );
/// ```
class FirebaseAnalyticsProvider implements IAnalyticsProvider {
  FirebaseAnalyticsProvider({required FirebaseAnalytics firebaseAnalytics})
      : _firebaseAnalytics = firebaseAnalytics;

  final FirebaseAnalytics _firebaseAnalytics;

  /// Registra evento customizado
  ///
  /// **Retorna:**
  /// - Right(null): Evento registrado com sucesso
  /// - Left(failure): Erro ao registrar evento
  @override
  Future<Either<Failure, void>> logEvent(
    String eventName,
    Map<String, dynamic>? parameters,
  ) async {
    try {
      developer.log(
        '📊 Logging event: $eventName',
        name: 'FirebaseAnalytics',
      );

      await _firebaseAnalytics.logEvent(
        name: eventName,
        parameters: _sanitizeParameters(parameters),
      );

      developer.log(
        '✅ Event logged: $eventName',
        name: 'FirebaseAnalytics',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        '❌ Error logging event: $e',
        name: 'FirebaseAnalytics',
      );
      return Left(AnalyticsFailure('Failed to log event: $e'));
    }
  }

  /// Registra erro
  ///
  /// **Retorna:**
  /// - Right(null): Erro registrado com sucesso
  /// - Left(failure): Erro ao registrar o erro
  @override
  Future<Either<Failure, void>> logError(
    String error,
    StackTrace? stackTrace,
  ) async {
    try {
      developer.log(
        '⚠️ Logging error: $error',
        name: 'FirebaseAnalytics',
      );

      await _firebaseAnalytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_message': error,
          'stack_trace': stackTrace?.toString() ?? 'N/A',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      developer.log(
        '✅ Error logged: $error',
        name: 'FirebaseAnalytics',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        '❌ Error logging error: $e',
        name: 'FirebaseAnalytics',
      );
      return Left(AnalyticsFailure('Failed to log error: $e'));
    }
  }

  /// Define propriedade do usuário
  ///
  /// **Retorna:**
  /// - Right(null): Propriedade definida com sucesso
  /// - Left(failure): Erro ao definir propriedade
  @override
  Future<Either<Failure, void>> setUserProperty(String name, String value) async {
    try {
      developer.log(
        '👤 Setting user property: $name = $value',
        name: 'FirebaseAnalytics',
      );

      await _firebaseAnalytics.setUserProperty(name: name, value: value);

      developer.log(
        '✅ User property set: $name',
        name: 'FirebaseAnalytics',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        '❌ Error setting user property: $e',
        name: 'FirebaseAnalytics',
      );
      return Left(AnalyticsFailure('Failed to set user property: $e'));
    }
  }

  /// Registra visualização de tela
  ///
  /// **Retorna:**
  /// - Right(null): Tela registrada com sucesso
  /// - Left(failure): Erro ao registrar tela
  @override
  Future<Either<Failure, void>> logScreenView(String screenName) async {
    try {
      developer.log(
        '📱 Logging screen view: $screenName',
        name: 'FirebaseAnalytics',
      );

      await _firebaseAnalytics.logScreenView(screenName: screenName);

      developer.log(
        '✅ Screen view logged: $screenName',
        name: 'FirebaseAnalytics',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        '❌ Error logging screen view: $e',
        name: 'FirebaseAnalytics',
      );
      return Left(AnalyticsFailure('Failed to log screen view: $e'));
    }
  }

  /// Remove valores nulos e converte tipos para compatibilidade com Firebase
  ///
  /// Firebase Analytics tem limitações de tipos: apenas int, double, bool, String
  Map<String, Object>? _sanitizeParameters(Map<String, dynamic>? parameters) {
    if (parameters == null || parameters.isEmpty) {
      return null;
    }

    final sanitized = <String, Object>{};

    parameters.forEach((key, value) {
      if (value == null) return;

      // Firebase aceita: String, int, double
      if (value is String || value is int || value is double || value is bool) {
        sanitized[key] = value as Object;
      } else if (value is num) {
        // Converte para double se for número
        sanitized[key] = value.toDouble();
      } else {
        // Converte para string para outros tipos
        sanitized[key] = value.toString();
      }
    });

    return sanitized.isEmpty ? null : sanitized;
  }
}

/// Failure específica para erros de analytics
class AnalyticsFailure extends Failure {
  const AnalyticsFailure(String message) : super(message: message);

  @override
  List<Object?> get props => [message];
}
