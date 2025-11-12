import 'package:core/core.dart' hide Column;
import 'package:injectable/injectable.dart';

import '../../../../../core/data/models/espaco_model.dart';
import '../../../../../database/repositories/spaces_drift_repository.dart';
import '../../models/space_model.dart';

/// ============================================================================
/// SPACES LOCAL DATASOURCE - MIGRADO PARA DRIFT
/// ============================================================================
///
/// **MIGRAÇÃO HIVE → DRIFT (Fase 2):**
/// - Removido código Hive (Box, JSON serialization)
/// - Usa SpacesDriftRepository para persistência
/// - Conversão SpaceModel ↔ EspacoModel (compatibilidade)
/// - Mantém interface pública idêntica (0 breaking changes)
///
/// **PADRÃO:**
/// - SpaceModel: Interface externa (usado por repositories/use cases)
/// - EspacoModel: Model interno (usado pelo Drift repository)
/// ============================================================================

abstract class SpacesLocalDatasource {
  Future<List<SpaceModel>> getSpaces();
  Future<SpaceModel?> getSpaceById(String id);
  Future<void> addSpace(SpaceModel space);
  Future<void> updateSpace(SpaceModel space);
  Future<void> deleteSpace(String id);
  Future<void> clearCache();
}

@LazySingleton(as: SpacesLocalDatasource)
class SpacesLocalDatasourceImpl implements SpacesLocalDatasource {
  final SpacesDriftRepository _driftRepo;

  SpacesLocalDatasourceImpl(this._driftRepo);

  @override
  Future<List<SpaceModel>> getSpaces() async {
    try {
      final espacos = await _driftRepo.getAllSpaces();

      // Converter EspacoModel → SpaceModel
      return espacos.map(_espacoToSpaceModel).toList();
    } catch (e) {
      throw CacheFailure(
        'Erro ao buscar espaços do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<SpaceModel?> getSpaceById(String id) async {
    try {
      final espaco = await _driftRepo.getSpaceById(id);

      return espaco != null ? _espacoToSpaceModel(espaco) : null;
    } catch (e) {
      throw CacheFailure(
        'Erro ao buscar espaço do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> addSpace(SpaceModel space) async {
    try {
      final espaco = _spaceModelToEspaco(space);
      await _driftRepo.insertSpace(espaco);
    } catch (e) {
      throw CacheFailure(
        'Erro ao salvar espaço no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateSpace(SpaceModel space) async {
    try {
      final espaco = _spaceModelToEspaco(space);
      final success = await _driftRepo.updateSpace(espaco);

      if (!success) {
        throw CacheFailure('Espaço não encontrado para atualização: ${space.id}');
      }
    } catch (e) {
      throw CacheFailure(
        'Erro ao atualizar espaço no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteSpace(String id) async {
    try {
      final success = await _driftRepo.deleteSpace(id);

      if (!success) {
        throw CacheFailure('Espaço não encontrado para exclusão: $id');
      }
    } catch (e) {
      throw CacheFailure(
        'Erro ao deletar espaço do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _driftRepo.clearAll();
    } catch (e) {
      throw CacheFailure('Erro ao limpar cache local: ${e.toString()}');
    }
  }

  // ==================== CONVERTERS ====================

  /// Converte EspacoModel (Drift) → SpaceModel (interface externa)
  SpaceModel _espacoToSpaceModel(EspacoModel espaco) {
    return SpaceModel(
      id: espaco.id,
      name: espaco.nome,
      description: espaco.descricao,
      lightCondition: null, // EspacoModel não tem esse campo
      humidity: null,
      averageTemperature: null,
      createdAt: espaco.dataCriacao,
      updatedAt: espaco.updatedAt,
      lastSyncAt: espaco.lastSyncAt,
      isDirty: espaco.isDirty,
      isDeleted: espaco.isDeleted,
      version: espaco.version,
      userId: espaco.userId,
      moduleName: espaco.moduleName,
    );
  }

  /// Converte SpaceModel (interface externa) → EspacoModel (Drift)
  EspacoModel _spaceModelToEspaco(SpaceModel space) {
    return EspacoModel(
      id: space.id,
      nome: space.name,
      descricao: space.description,
      ativo: true,
      dataCriacao: space.createdAt,
      createdAtMs: space.createdAt?.millisecondsSinceEpoch,
      updatedAtMs: space.updatedAt?.millisecondsSinceEpoch,
      lastSyncAtMs: space.lastSyncAt?.millisecondsSinceEpoch,
      isDirty: space.isDirty,
      isDeleted: space.isDeleted,
      version: space.version,
      userId: space.userId,
      moduleName: space.moduleName,
    );
  }
}
