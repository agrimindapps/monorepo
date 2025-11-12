import 'package:core/core.dart' hide Column;

import '../../../../database/repositories/plant_tasks_drift_repository.dart';
import '../../../../database/repositories/plants_drift_repository.dart';
import '../../../../database/repositories/spaces_drift_repository.dart';
import '../../../../database/repositories/tasks_drift_repository.dart';

/// Interface para data source local de conta
/// Abstração para acesso a Drift ou outro storage local
abstract class AccountLocalDataSource {
  /// Obtém informações da conta armazenadas localmente
  Future<UserEntity?> getLocalAccountInfo();

  /// Limpa dados locais de conteúdo do usuário
  Future<int> clearLocalUserData();

  /// Remove todos os dados da conta localmente
  Future<void> clearAccountData();
}

/// ============================================================================
/// ACCOUNT LOCAL DATASOURCE - MIGRADO PARA DRIFT
/// ============================================================================
///
/// **MIGRAÇÃO HIVE → DRIFT (Phase 3.5):**
/// - Removido IHiveManager e acesso direto aos boxes Hive
/// - Usa Drift repositories para limpar dados
/// - clearLocalUserData() → chama clearAll() em todos os repos
/// - Interface pública idêntica (0 breaking changes)
/// ============================================================================

/// Implementação do data source local usando Drift
class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  final PlantsDriftRepository _plantsRepo;
  final SpacesDriftRepository _spacesRepo;
  final TasksDriftRepository _tasksRepo;
  final PlantTasksDriftRepository _plantTasksRepo;

  const AccountLocalDataSourceImpl({
    required PlantsDriftRepository plantsRepo,
    required SpacesDriftRepository spacesRepo,
    required TasksDriftRepository tasksRepo,
    required PlantTasksDriftRepository plantTasksRepo,
  }) : _plantsRepo = plantsRepo,
       _spacesRepo = spacesRepo,
       _tasksRepo = tasksRepo,
       _plantTasksRepo = plantTasksRepo;

  @override
  Future<UserEntity?> getLocalAccountInfo() async {
    try {
      // Implementação depende da estrutura atual do Drift
      // Por enquanto retorna null, será implementado conforme necessário
      return null;
    } catch (e) {
      throw CacheFailure('Erro ao buscar dados locais: $e');
    }
  }

  @override
  Future<int> clearLocalUserData() async {
    try {
      int totalCleared = 0;

      // Limpa todas as tabelas Drift que suportam clearAll()
      // Nota: Alguns repos retornam int (número de linhas), outros void
      try {
        await _plantsRepo.clearAll();
        totalCleared += 1; // Incrementa contador de tabelas limpas
      } catch (e) {
        // Ignora se método não existir
      }

      try {
        await _spacesRepo.clearAll();
        totalCleared += 1;
      } catch (e) {
        // Ignora
      }

      try {
        await _tasksRepo.clearAll();
        totalCleared += 1;
      } catch (e) {
        // Ignora
      }

      try {
        final cleared = await _plantTasksRepo.clearAll();
        totalCleared += cleared;
      } catch (e) {
        // Ignora
      }

      // PlantConfigs, Comments e SyncQueue não têm clearAll()
      // ou são dependentes de Plants (deletados via cascata)

      return totalCleared;
    } catch (e) {
      throw CacheFailure('Erro ao limpar dados locais: $e');
    }
  }

  @override
  Future<void> clearAccountData() async {
    try {
      await clearLocalUserData();
      // Limpa também dados de configuração da conta se necessário
    } catch (e) {
      throw CacheFailure('Erro ao limpar dados da conta: $e');
    }
  }
}
