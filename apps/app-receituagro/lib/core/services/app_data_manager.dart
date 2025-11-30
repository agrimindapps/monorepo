import 'dart:developer' as developer;


import 'package:core/core.dart' hide Column;

import 'static_data_loader_service.dart';

/// Interface para o gerenciador de dados da aplicação
abstract class IAppDataManager {
  Future<Either<Exception, void>> initialize();
  Future<Either<Exception, void>> forceReloadData();
  Future<Map<String, dynamic>> getDataStats();
  Future<bool> isDataReady();

  Future<void> dispose();
  bool get isInitialized;
}

/// Implementação do gerenciador principal de dados da aplicação
/// Responsável por inicializar o Drift, coordenar o carregamento de dados
/// e gerenciar o sistema de controle automático de versão
class AppDataManager implements IAppDataManager {
  final Ref ref;
  // ✅ Keep _isInitialized for interface compliance
  bool _isInitialized = false;

  /// Construtor que permite injeção de dependência
  AppDataManager(this.ref);

  /// Inicializa completamente o sistema de dados com controle automático de versão
  /// Nota: Drift é inicializado automaticamente pelo database instance
  @override
  Future<Either<Exception, void>> initialize() async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      developer.log(
        'Iniciando inicialização do sistema de dados...',
        name: 'AppDataManager',
      );

      // Drift é gerenciado automaticamente pelo database instance
      // Dados do app usam Drift para armazenamento local

      await _createServices();
      developer.log(
        'Carregando dados estáticos com controle de versão...',
        name: 'AppDataManager',
      );

      // Carregar dados estáticos usando o novo serviço com controle de versão
      // Isso garante que os dados só são carregados uma vez por versão
      await StaticDataLoaderService.loadAllStaticDataIfNeeded(ref);

      _isInitialized = true;

      developer.log(
        'Sistema de dados inicializado com sucesso',
        name: 'AppDataManager',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Erro na inicialização do sistema de dados: $e',
        name: 'AppDataManager',
      );
      return Left(Exception('Falha na inicialização: ${e.toString()}'));
    }
  }

  /// Cria instâncias de todos os serviços necessários
  Future<void> _createServices() async {
    try {
      developer.log(
        'Criando instâncias dos serviços...',
        name: 'AppDataManager',
      );

      // Drift database será inicializado automaticamente quando necessário
      // Repositories são criados via dependency injection quando requisitados

      developer.log(
        'Serviços criados com sucesso (incluindo controle de versão)',
        name: 'AppDataManager',
      );
    } catch (e) {
      developer.log('Erro ao criar serviços: $e', name: 'AppDataManager');
      rethrow;
    }
  }

  /// Força recarregamento de todos os dados usando controle automático de versão
  @override
  Future<Either<Exception, void>> forceReloadData() async {
    if (!_isInitialized) {
      return Left(Exception('Sistema não foi inicializado'));
    }

    try {
      developer.log(
        'Forçando recarregamento de dados...',
        name: 'AppDataManager',
      );
      
      await StaticDataLoaderService.forceReloadAll(ref);
      
      developer.log(
        'Recarregamento forçado concluído com sucesso',
        name: 'AppDataManager',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Erro ao forçar recarregamento: $e',
        name: 'AppDataManager',
      );
      return Left(
        Exception('Falha no recarregamento forçado: ${e.toString()}'),
      );
    }
  }

  /// Obtém estatísticas do carregamento de dados incluindo informações de versão
  @override
  Future<Map<String, dynamic>> getDataStats() async {
    if (!_isInitialized) {
      return {'error': 'Sistema não foi inicializado'};
    }

    try {
      return await StaticDataLoaderService.getStats(ref);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Verifica se os dados estão carregados
  @override
  Future<bool> isDataReady() async {
    if (!_isInitialized) return false;
    return await StaticDataLoaderService.isAllDataLoaded(ref);
  }

  /// Limpa recursos do sistema
  /// ✅ PADRÃO APP-PLANTIS: BoxRegistryService gerencia fechamento de boxes
  @override
  Future<void> dispose() async {
    try {
      developer.log(
        'Fazendo dispose do AppDataManager...',
        name: 'AppDataManager',
      );

      _isInitialized = false;

      developer.log(
        'Dispose do AppDataManager concluído',
        name: 'AppDataManager',
      );
    } catch (e) {
      developer.log(
        'Erro durante dispose do AppDataManager: $e',
        name: 'AppDataManager',
      );
    }
  }

  /// Getter para verificar se está inicializado
  @override
  bool get isInitialized => _isInitialized;
}
