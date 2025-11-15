import 'package:core/core.dart';

/// Interface abstrata para provedor de analytics
///
/// **Responsabilidades (Single Responsibility):**
/// - Registrar eventos de análise
/// - Configurar propriedades de usuário
/// - Apenas operações de analytics, sem negócio
///
/// **Princípio ISP:**
/// - ≤ 5 métodos (apenas analytics necessários)
///
/// **Princípio DIP:**
/// - Depende de abstração, não de Firebase diretamente
/// - Facilita testes com mocks
///
/// **Exemplo:**
/// ```dart
/// final result = await analyticsProvider.logEvent(
///   name: 'fuel_added',
///   parameters: {'vehicleId': '123', 'amount': 50.0},
/// );
/// result.fold(
///   (failure) => print('Analytics failed'),
///   (_) => print('Event logged'),
/// );
/// ```
abstract class IAnalyticsProvider {
  /// Registra evento de análise
  ///
  /// Parametros:
  /// - name: Nome do evento (ex: 'fuel_added', 'vehicle_created')
  /// - parameters: Dados adicionais do evento (opcional)
  ///
  /// Retorna:
  /// - Right(null): Evento registrado
  /// - Left(failure): Erro ao registrar
  Future<Either<Failure, void>> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  });

  /// Define propriedades do usuário para segmentação
  ///
  /// Parametros:
  /// - properties: Map de propriedades (ex: {'appVersion': '1.2.3'})
  ///
  /// Retorna:
  /// - Right(null): Propriedades definidas
  /// - Left(failure): Erro ao definir
  Future<Either<Failure, void>> setUserProperties(
    Map<String, dynamic> properties,
  );
}
