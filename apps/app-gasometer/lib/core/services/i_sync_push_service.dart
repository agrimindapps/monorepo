import 'package:core/core.dart';
import '../sync/models/sync_results.dart';

/// Interface para orquestração de operações de push de sincronização
///
/// **Responsabilidades (Single Responsibility):**
/// - Coordenar push de múltiplos adapters em paralelo
/// - Agregar resultados e estatísticas
/// - Apenas push operations, sem pull
/// - Delegação para adapters específicos
///
/// **Princípio ISP:**
/// - ≤ 5 métodos (apenas push necessários)
/// - Segregado de pull operations
///
/// **Princípio DIP:**
/// - Depende de ISyncAdapter abstrato, não de implementações específicas
/// - Usa SyncAdapterRegistry para listar adapters
///
/// **Exemplo:**
/// ```dart
/// final result = await pushService.pushAll(userId);
/// result.fold(
///   (failure) => print('Push failed: ${failure.message}'),
///   (results) => print('Pushed ${results.length} adapters'),
/// );
/// ```
abstract class ISyncPushService {
  /// Executa push de todos os adapters registrados em paralelo
  ///
  /// Comportamento:
  /// - Adapters rodam em paralelo (não sequencial)
  /// - Um adapter falhando não interrompe os outros
  /// - Erros são agregados no resultado final
  Future<Either<Failure, List<SyncPushResult>>> pushAll(String userId);
}
