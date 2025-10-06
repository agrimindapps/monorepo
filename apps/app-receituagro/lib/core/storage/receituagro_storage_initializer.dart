import 'package:core/core.dart';

import 'receituagro_boxes.dart';

/// Inicializador de storage específico para o app ReceitaAgro
/// Responsável por registrar todas as boxes necessárias no BoxRegistryService
class ReceitaAgroStorageInitializer {
  static const String _appId = 'receituagro';

  /// Inicializa o storage registrando as boxes específicas do ReceitaAgro
  /// Deve ser chamado durante a inicialização do app
  static Future<Either<Failure, void>> initialize(
    IBoxRegistryService boxRegistry,
  ) async {
    try {
      final configurations = ReceitaAgroBoxes.getConfigurations();
      for (final config in configurations) {
        final result = await boxRegistry.registerBox(config);
        
        if (result.isLeft()) {
          return result.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao inicializar storage do ReceitaAgro: $e'),
      );
    }
  }

  /// Verifica se todas as boxes do ReceitaAgro estão registradas
  static bool isInitialized(IBoxRegistryService boxRegistry) {
    final expectedBoxes = ReceitaAgroBoxes.getConfigurations()
        .map((config) => config.name)
        .toList();

    for (final boxName in expectedBoxes) {
      if (!boxRegistry.isBoxRegistered(boxName)) {
        return false;
      }
    }

    return true;
  }

  /// Cleanup - fecha todas as boxes do ReceitaAgro
  /// Útil durante testes ou shutdown da aplicação
  static Future<Either<Failure, void>> cleanup(
    IBoxRegistryService boxRegistry,
  ) async {
    try {
      return await boxRegistry.closeBoxesForApp(_appId);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao fazer cleanup do storage ReceitaAgro: $e'),
      );
    }
  }

  /// Obtém informações de debug sobre o estado das boxes
  static Map<String, dynamic> getDebugInfo(IBoxRegistryService boxRegistry) {
    final configurations = ReceitaAgroBoxes.getConfigurations();
    final registeredBoxes = boxRegistry.getRegisteredBoxesForApp(_appId);

    return {
      'app_id': _appId,
      'expected_boxes': configurations.length,
      'registered_boxes': registeredBoxes.length,
      'is_fully_initialized': isInitialized(boxRegistry),
      'box_details': configurations.map((config) => {
        'name': config.name,
        'registered': boxRegistry.isBoxRegistered(config.name),
        'version': config.version,
        'metadata': config.metadata,
      }).toList(),
      'missing_boxes': configurations
          .where((config) => !boxRegistry.isBoxRegistered(config.name))
          .map((config) => config.name)
          .toList(),
    };
  }

  /// Migração de dados - para casos onde estrutura de box mudou
  /// Placeholder para futuras migrações de dados
  static Future<Either<Failure, void>> migrateData(
    IBoxRegistryService boxRegistry, {
    required int fromVersion,
    required int toVersion,
  }) async {
    try {
      
      if (fromVersion == toVersion) {
        return const Right(null);
      }
      print('ReceitaAgro: Migrando dados da versão $fromVersion para $toVersion');

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro durante migração de dados ReceitaAgro: $e'),
      );
    }
  }
}