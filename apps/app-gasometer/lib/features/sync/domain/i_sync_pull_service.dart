import 'package:core/core.dart';
import '../../../core/sync/models/sync_results.dart';

/// Interface para orquestração de operações de pull de sincronização
///
/// **Responsabilidades (Single Responsibility):**
/// - Coordenar pull de múltiplos adapters em paralelo
/// - Agregar resultados e estatísticas
/// - Apenas pull operations, sem push
/// - Delegação para adapters específicos
///
/// **Princípio ISP:**
/// - ≤ 5 métodos (apenas pull necessários)
/// - Segregado de push operations
///
/// **Princípio DIP:**
/// - Depende de ISyncAdapter abstrato, não de implementações específicas
/// - Usa SyncAdapterRegistry para listar adapters
///
/// **Exemplo:**
/// ```dart
/// final result = await pullService.pullAll(userId);
/// result.fold(
///   (failure) => print('Pull failed: ${failure.message}'),
///   (results) => print('Pulled ${results.length} adapters'),
/// );
/// ```
abstract class ISyncPullService {
  /// Executa pull de todos os adapters registrados em paralelo
  ///
  /// Comportamento:
  /// - Adapters rodam em paralelo (não sequencial)
  /// - Um adapter falhando não interrompe os outros
  /// - Erros são agregados no resultado final
  /// - since: Timestamp da última sincronização (null = full sync)
  Future<Either<Failure, List<SyncPullResult>>> pullAll(
    String userId, {
    DateTime? since,
  });
}
