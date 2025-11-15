import 'package:core/core.dart';
import '../entities/fuel_record_entity.dart';

/// Interface para operações de sincronização de combustível
///
/// **Responsabilidades (Single Responsibility):**
/// - Detectar registros pendentes (isDirty) offline
/// - Sincronizar registros com Firebase
/// - Marcar registros como sincronizados após sucesso
/// - Apenas sincronização, sem lógica de negócio
///
/// **Princípio ISP:**
/// - ≤ 5 métodos (apenas sync necessários)
/// - Segregado de CRUD e query operations
///
/// **Exemplo:**
/// ```dart
/// final pending = await syncService.loadPendingRecords();
/// pending.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (records) => print('${records.length} pending records'),
/// );
/// ```
abstract class IFuelSyncService {
  /// Carrega registros pendentes (isDirty) para sincronização
  Future<Either<Failure, List<FuelRecordEntity>>> loadPendingRecords();

  /// Marca registros como sincronizados
  Future<Either<Failure, void>> markAsSynced(List<String> recordIds);
}
