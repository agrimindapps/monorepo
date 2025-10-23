import 'package:core/core.dart';

import '../../../features/vehicles/domain/entities/vehicle_entity.dart';
import '../../../features/vehicles/domain/repositories/vehicle_repository.dart';

/// EXEMPLO: VehicleRepository usando UnifiedSyncManager
/// Este é um exemplo de como o VehicleRepository ficaria APÓS migração completa
/// Compare com VehicleRepositoryImpl atual para ver a simplificação
///
/// ✅ Vantagens:
/// - ~70% menos código
/// - Sync automático (sem background tasks manuais)
/// - Conflict resolution built-in
/// - Retry automático
/// - Observabilidade (streams de status)
/// - Mais testável (menos dependências)
///
/// ⚠️ Notas:
/// 1. Não precisa de connectivity checks (manager faz isso)
/// 2. Não precisa de userId manual (manager pega do FirebaseAuth)
/// 3. Não precisa de local/remote datasources (manager gerencia)
/// 4. Stream de dados built-in (realtime updates)
class UnifiedVehicleRepositoryExample implements VehicleRepository {
  // Nenhuma dependência necessária!
  // UnifiedSyncManager é singleton e gerencia tudo

  static const _appName = 'gasometer';

  @override
  Future<Either<Failure, List<VehicleEntity>>> getAllVehicles() async {
    // UnifiedSyncManager:
    // 1. Retorna dados locais imediatamente (offline-first)
    // 2. Sincroniza com Firebase em background
    // 3. Atualiza stream automaticamente quando houver mudanças
    return await UnifiedSyncManager.instance.findAll<VehicleEntity>(_appName);
  }

  @override
  Future<Either<Failure, VehicleEntity>> getVehicleById(String id) async {
    // Busca local primeiro, depois remoto se necessário
    final result =
        await UnifiedSyncManager.instance.findById<VehicleEntity>(
      _appName,
      id,
    );

    return result.fold(
      (failure) => Left(failure),
      (vehicle) {
        if (vehicle == null) {
          return const Left(ValidationFailure('Vehicle not found'));
        }
        return Right(vehicle);
      },
    );
  }

  @override
  Future<Either<Failure, VehicleEntity>> addVehicle(
    VehicleEntity vehicle,
  ) async {
    // UnifiedSyncManager:
    // 1. Salva no Hive local (cache)
    // 2. Marca como dirty (precisa sync)
    // 3. Adiciona metadata (userId, moduleName, timestamps)
    // 4. Sincroniza com Firebase em background
    // 5. Emite evento de criação
    final result =
        await UnifiedSyncManager.instance.create<VehicleEntity>(
      _appName,
      vehicle,
    );

    return result.fold(
      (failure) => Left(failure),
      (id) => Right(vehicle.copyWith(id: id)),
    );
  }

  @override
  Future<Either<Failure, VehicleEntity>> updateVehicle(
    VehicleEntity vehicle,
  ) async {
    // UnifiedSyncManager:
    // 1. Atualiza no Hive local
    // 2. Incrementa versão (conflict resolution)
    // 3. Marca como dirty
    // 4. Sincroniza com Firebase em background
    // 5. Resolve conflitos se necessário (version-based)
    final result =
        await UnifiedSyncManager.instance.update<VehicleEntity>(
      _appName,
      vehicle.id,
      vehicle.markAsDirty().incrementVersion(),
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => Right(vehicle),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteVehicle(String id) async {
    // UnifiedSyncManager:
    // 1. Marca como deletado (soft delete) no local
    // 2. Sincroniza delete com Firebase
    // 3. Remove do cache após confirmação
    final result =
        await UnifiedSyncManager.instance.delete<VehicleEntity>(
      _appName,
      id,
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }

  @override
  Future<Either<Failure, Unit>> syncVehicles() async {
    // Força sincronização manual de todas as entidades Vehicle
    final result =
        await UnifiedSyncManager.instance.forceSyncEntity<VehicleEntity>(
      _appName,
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> searchVehicles(
    String query,
  ) async {
    // Para search, pegamos todos os veículos e filtramos localmente
    // (mais eficiente que múltiplas queries ao Firebase)
    final result = await getAllVehicles();

    return result.fold(
      (failure) => Left(failure),
      (vehicles) {
        final searchQuery = query.toLowerCase();
        final filtered = vehicles.where((vehicle) {
          return vehicle.name.toLowerCase().contains(searchQuery) ||
              vehicle.brand.toLowerCase().contains(searchQuery) ||
              vehicle.model.toLowerCase().contains(searchQuery) ||
              vehicle.year.toString().contains(searchQuery);
        }).toList();

        return Right(filtered);
      },
    );
  }

  @override
  Stream<Either<Failure, List<VehicleEntity>>> watchVehicles() async* {
    // UnifiedSyncManager fornece stream reativo built-in
    // Emite automaticamente quando há mudanças locais OU remotas
    final stream =
        UnifiedSyncManager.instance.streamAll<VehicleEntity>(_appName);

    if (stream == null) {
      yield const Left(CacheFailure('Stream not available'));
      return;
    }

    // Converte Stream<List<VehicleEntity>> para Stream<Either<Failure, List<VehicleEntity>>>
    yield* stream.map<Either<Failure, List<VehicleEntity>>>(
      (vehicles) => Right(vehicles),
    ).handleError((Object error) {
      return Left(UnexpectedFailure(error.toString()));
    });
  }
}

/// COMPARAÇÃO: Código removido após migração para UnifiedSyncManager
///
/// ❌ Não precisa mais:
/// - VehicleLocalDataSource (Hive manual)
/// - VehicleRemoteDataSource (Firebase manual)
/// - Connectivity checks (_isConnected)
/// - Auth repository injection (_getCurrentUserId)
/// - LoggingService injection (UnifiedSyncManager loga tudo)
/// - Background sync methods (_syncInBackground, _syncVehicleInBackground)
/// - Error handling manual (try-catch gigante)
/// - Estado de sync tracking (UnifiedSyncManager faz isso)
/// - Conversão manual de models (UnifiedSyncManager usa entidades direto)
///
/// 📊 Estatísticas:
/// - Linhas de código ANTES: ~580 linhas (VehicleRepositoryImpl)
/// - Linhas de código DEPOIS: ~170 linhas (este exemplo)
/// - Redução: ~70%
/// - Dependências ANTES: 5 (localDataSource, remoteDataSource, connectivity, authRepository, loggingService)
/// - Dependências DEPOIS: 0 (UnifiedSyncManager é singleton)
///
/// 🎯 Qualidade:
/// - Testes: Mais fácil (sem datasources para mockar)
/// - Manutenção: Mais simples (lógica centralizada)
/// - Robustez: Maior (retry, conflict resolution, error handling automáticos)
/// - Performance: Melhor (batching, throttling, smart sync)
/// - Observabilidade: Superior (streams de status, events, debug info)

/// GUIA DE MIGRAÇÃO RÁPIDA:
///
/// 1. Backup do repositório atual:
///    git checkout -b feature/migrate-unified-sync
///
/// 2. Remover injeção de dependências no DI:
///    - Remover VehicleLocalDataSource
///    - Remover VehicleRemoteDataSource
///    - Manter apenas VehicleRepository
///
/// 3. Substituir implementação:
///    - Copiar métodos deste exemplo
///    - Ajustar apenas lógica de negócio específica (se houver)
///
/// 4. Remover datasources:
///    - Deletar vehicle_local_data_source.dart (após confirmar funcionamento)
///    - Deletar vehicle_remote_data_source.dart (após confirmar funcionamento)
///
/// 5. Atualizar testes:
///    - Usar ProviderContainer para testar (mais simples)
///    - Mock do UnifiedSyncManager se necessário
///
/// Tempo estimado: 30-45 minutos por repositório
