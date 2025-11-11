import 'dart:developer' as developer;

import 'package:core/core.dart' hide Column;

import '../../database/loaders/static_data_loader.dart';
import '../../database/receituagro_database.dart';

/// Serviço responsável por inicializar e gerenciar dados da aplicação usando Drift
/// Orquestra o carregamento de JSONs e população das tabelas Drift
class DataInitializationServiceDrift {
  final ReceituagroDatabase _database;
  late final StaticDataLoader _staticDataLoader;

  DataInitializationServiceDrift({required ReceituagroDatabase database})
    : _database = database {
    _staticDataLoader = StaticDataLoader(_database);
  }

  /// Inicializa todos os dados da aplicação se necessário
  Future<Either<Exception, void>> initializeData() async {
    try {
      developer.log(
        'Iniciando carregamento de dados (Drift)...',
        name: 'DataInitializationServiceDrift',
      );

      // Verificar se os dados já foram carregados
      final isDataLoaded = await _isDataAlreadyLoaded();
      if (isDataLoaded) {
        developer.log(
          'Dados já carregados, pulando inicialização',
          name: 'DataInitializationServiceDrift',
        );
        return const Right(null);
      }

      // Carregar dados estáticos via StaticDataLoader
      await _staticDataLoader.loadAll();

      developer.log(
        'Dados carregados com sucesso (Drift)',
        name: 'DataInitializationServiceDrift',
      );
      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Erro ao inicializar dados: $e',
        name: 'DataInitializationServiceDrift',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(
        Exception('Falha na inicialização dos dados: ${e.toString()}'),
      );
    }
  }

  /// Força recarregamento de todos os dados
  Future<Either<Exception, void>> forceReloadData() async {
    try {
      developer.log(
        'Forçando recarregamento de dados (Drift)...',
        name: 'DataInitializationServiceDrift',
      );

      // Limpar dados existentes
      await _clearExistingData();

      // Recarregar dados estáticos
      await _staticDataLoader.loadAll();

      developer.log(
        'Recarregamento forçado concluído (Drift)',
        name: 'DataInitializationServiceDrift',
      );
      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Erro no recarregamento forçado: $e',
        name: 'DataInitializationServiceDrift',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(
        Exception('Falha no recarregamento forçado: ${e.toString()}'),
      );
    }
  }

  /// Verifica se os dados já foram carregados
  Future<bool> _isDataAlreadyLoaded() async {
    try {
      // Verificar se há dados nas tabelas estáticas
      final culturasCount = await _database
          .select(_database.culturas)
          .get()
          .then((value) => value.length);
      final pragasCount = await _database
          .select(_database.pragas)
          .get()
          .then((value) => value.length);
      final fitossanitariosCount = await _database
          .select(_database.fitossanitarios)
          .get()
          .then((value) => value.length);

      // Considerar dados carregados se todas as tabelas têm dados
      return culturasCount > 0 && pragasCount > 0 && fitossanitariosCount > 0;
    } catch (e) {
      developer.log(
        'Erro ao verificar dados carregados: $e',
        name: 'DataInitializationServiceDrift',
      );
      return false;
    }
  }

  /// Limpa dados existentes das tabelas estáticas
  Future<void> _clearExistingData() async {
    try {
      developer.log(
        'Limpando dados existentes...',
        name: 'DataInitializationServiceDrift',
      );

      // Limpar tabelas estáticas (não limpar dados do usuário)
      await _database.delete(_database.culturas).go();
      await _database.delete(_database.pragas).go();
      await _database.delete(_database.fitossanitarios).go();
      await _database.delete(_database.fitossanitariosInfo).go();
      await _database.delete(_database.pragasInf).go();

      developer.log(
        'Dados existentes limpos',
        name: 'DataInitializationServiceDrift',
      );
    } catch (e) {
      developer.log(
        'Erro ao limpar dados existentes: $e',
        name: 'DataInitializationServiceDrift',
      );
      rethrow;
    }
  }

  /// Retorna estatísticas dos dados carregados
  Future<Map<String, dynamic>> getDataStats() async {
    try {
      final culturasCount = await _database
          .select(_database.culturas)
          .get()
          .then((value) => value.length);
      final pragasCount = await _database
          .select(_database.pragas)
          .get()
          .then((value) => value.length);
      final fitossanitariosCount = await _database
          .select(_database.fitossanitarios)
          .get()
          .then((value) => value.length);
      final diagnosticosCount = await _database
          .select(_database.diagnosticos)
          .get()
          .then((value) => value.length);

      return {
        'culturas': culturasCount,
        'pragas': pragasCount,
        'fitossanitarios': fitossanitariosCount,
        'diagnosticos': diagnosticosCount,
        'total_static': culturasCount + pragasCount + fitossanitariosCount,
        'total_user': diagnosticosCount,
      };
    } catch (e) {
      developer.log(
        'Erro ao obter estatísticas: $e',
        name: 'DataInitializationServiceDrift',
      );
      return {'error': e.toString()};
    }
  }

  /// Verifica se os dados estão prontos para uso
  Future<bool> isDataReady() async {
    try {
      final stats = await getDataStats();
      final error = stats['error'];
      if (error != null) return false;

      // Verificar se há dados mínimos carregados
      return (stats['culturas'] as int) > 0 &&
          (stats['pragas'] as int) > 0 &&
          (stats['fitossanitarios'] as int) > 0;
    } catch (e) {
      developer.log(
        'Erro ao verificar prontidão dos dados: $e',
        name: 'DataInitializationServiceDrift',
      );
      return false;
    }
  }
}
