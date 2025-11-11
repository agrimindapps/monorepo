import 'dart:developer' as developer;

import 'package:core/core.dart' hide Column;

import '../../database/receituagro_database.dart';
import 'app_data_manager.dart';
import 'data_initialization_service.dart';
import 'data_initialization_service_drift.dart';

/// Interface para o gerenciador de dados da aplicação (versão Drift)
abstract class IAppDataManagerDrift implements IAppDataManager {
  @override
  DataInitializationService get dataService;
}

/// Implementação do gerenciador principal de dados da aplicação usando Drift
/// Responsável por inicializar o banco de dados Drift e coordenar o carregamento de dados
/// Substitui a versão baseada em Hive repositories
class AppDataManagerDrift implements IAppDataManagerDrift {
  late final DataInitializationServiceDrift _dataService;
  late final ReceituagroDatabase _database;
  bool _isInitialized = false;

  /// Construtor que permite injeção de dependência
  AppDataManagerDrift();

  /// Inicializa completamente o sistema de dados usando Drift
  @override
  Future<Either<Exception, void>> initialize() async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      developer.log(
        'Iniciando inicialização do sistema de dados (Drift)...',
        name: 'AppDataManagerDrift',
      );

      // Obter instância do banco de dados Drift
      _database = getIt<ReceituagroDatabase>();

      developer.log(
        'Banco de dados Drift inicializado com sucesso',
        name: 'AppDataManagerDrift',
      );

      // Criar serviço de inicialização de dados usando Drift
      _dataService = DataInitializationServiceDrift(database: _database);

      developer.log(
        'Serviços criados com sucesso (Drift)',
        name: 'AppDataManagerDrift',
      );

      _isInitialized = true;
      return const Right(null);
    } catch (e) {
      developer.log(
        'Erro ao criar serviços Drift: $e',
        name: 'AppDataManagerDrift',
      );
      return Left(
        Exception(
          'Falha na inicialização do sistema de dados: ${e.toString()}',
        ),
      );
    }
  }

  /// Força recarregamento de todos os dados usando Drift
  @override
  Future<Either<Exception, void>> forceReloadData() async {
    if (!_isInitialized) {
      return Left(Exception('Sistema não foi inicializado'));
    }

    try {
      developer.log(
        'Forçando recarregamento de dados (Drift)...',
        name: 'AppDataManagerDrift',
      );

      await _dataService.forceReloadData();

      developer.log(
        'Recarregamento forçado concluído com sucesso',
        name: 'AppDataManagerDrift',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Erro ao forçar recarregamento: $e',
        name: 'AppDataManagerDrift',
      );
      return Left(
        Exception('Falha no recarregamento forçado: ${e.toString()}'),
      );
    }
  }

  /// Retorna estatísticas dos dados carregados
  @override
  Future<Map<String, dynamic>> getDataStats() async {
    if (!_isInitialized) {
      return {'error': 'Sistema não foi inicializado'};
    }

    try {
      return await _dataService.getDataStats();
    } catch (e) {
      developer.log(
        'Erro ao obter estatísticas: $e',
        name: 'AppDataManagerDrift',
      );
      return {'error': e.toString()};
    }
  }

  /// Verifica se os dados estão prontos para uso
  @override
  Future<bool> isDataReady() async {
    if (!_isInitialized) {
      return false;
    }

    try {
      return await _dataService.isDataReady();
    } catch (e) {
      developer.log(
        'Erro ao verificar prontidão dos dados: $e',
        name: 'AppDataManagerDrift',
      );
      return false;
    }
  }

  /// Retorna o serviço de inicialização de dados
  @override
  DataInitializationService get dataService =>
      _dataService as DataInitializationService;

  /// Libera recursos
  @override
  Future<void> dispose() async {
    try {
      await _database.close();
      _isInitialized = false;
      developer.log(
        'Recursos liberados com sucesso',
        name: 'AppDataManagerDrift',
      );
    } catch (e) {
      developer.log(
        'Erro ao liberar recursos: $e',
        name: 'AppDataManagerDrift',
      );
    }
  }

  /// Verifica se o sistema foi inicializado
  @override
  bool get isInitialized => _isInitialized;

  /// Singleton instance
  static AppDataManagerDrift? _instance;
  static AppDataManagerDrift get instance {
    _instance ??= AppDataManagerDrift();
    return _instance!;
  }
}
