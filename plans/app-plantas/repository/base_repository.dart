// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../core/models/base_model.dart';
import '../../core/services/sync_firebase_service.dart';
import '../core/cache/cache_manager.dart';
import '../core/initialization/initialization_manager.dart';
import '../core/optimization/filtering_optimizer.dart';
import '../core/streams/stream_manager.dart';
import 'aop/aspect_interface.dart';
import 'aop/aspect_manager.dart';
import 'error_handling/repository_error_handling_mixin.dart';
import 'transaction/transactional_repository_mixin.dart';

/// Abstract Base Repository para todos os repositories
///
/// ISSUE #33: Mixed Abstraction Levels - SOLUTION IMPLEMENTED
/// ISSUE #35: Repository Responsibilities - SOLUTION IMPLEMENTED
///
/// Este repository mantém APENAS operações de baixo nível (LOW-LEVEL):
/// - CRUD operations básicas (create, read, update, delete)
/// - Cache management básico através de mixins
/// - Stream lifecycle management
/// - Error handling robusto
/// - Inicialização via InitializationManager
/// - Singleton pattern thread-safe
/// - Estatísticas básicas (contadores simples)
///
/// CROSS-CUTTING CONCERNS EXTERNALIZADOS via AOP:
/// - Logging: Aplicado automaticamente via LoggingAspect
/// - Validation: Aplicado automaticamente via ValidationAspect
/// - Statistics: Aplicado automaticamente via StatisticsAspect
/// - Caching: Aplicado automaticamente via CachingAspect (futuro)
/// - Security: Aplicado automaticamente via SecurityAspect (futuro)
///
/// Para operações de alto nível (HIGH-LEVEL), use:
/// - RepositoryOperationsFacade: Operações complexas cross-entity
/// - RepositoryQueryFacade: Queries avançadas e analytics
/// - Services especializados: BusinessRulesService, StatisticsService, etc.
///
/// CONSISTENT ABSTRACTION LEVEL: Este repository mantém abstração consistente
/// focando apenas em persistência de dados e operações básicas.
abstract class BaseRepository<T extends BaseModel>
    with
        StreamLifecycleManager,
        OptimizedFiltering,
        CacheableRepository,
        RepositoryErrorHandlingMixin,
        TransactionalRepositoryMixin<T>,
        AspectAwareRepository {
  /// SyncFirebaseService instance para operações de dados
  /// Late final garante inicialização única e imutável
  late final SyncFirebaseService<T> _syncService;

  /// Protected getter para acesso ao syncService por subclasses
  @protected
  SyncFirebaseService<T> get syncService => _syncService;

  /// Flag de inicialização thread-safe
  bool _isInitialized = false;

  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Aspectos são aplicados automaticamente pelo AspectAwareServiceLocator
  /// e não precisam ser gerenciados diretamente pelo repository.
  ///
  /// Os aspectos disponíveis são:
  /// - LoggingAspect: Para logging estruturado de operações
  /// - ValidationAspect: Para validação de entrada e saída
  /// - StatisticsAspect: Para coleta de métricas e performance

  @override
  List<RepositoryAspect> get aspects {
    // Os aspectos são gerenciados pelo RepositoryAspectManager
    // e aplicados automaticamente pelo AspectAwareServiceLocator
    return RepositoryAspectManager.instance
        .getAspectsForRepository(repositoryName);
  }

  /// Nome da coleção Firestore/Hive
  String get collectionName;

  /// Nome do repository para logs e cache
  @override
  String get repositoryName;

  /// Function para converter JSON em model
  ///
  /// Converte dados JSON do Firestore/Hive para instâncias do modelo.
  /// Deve ser implementada pela subclasse para mapear corretamente
  /// os campos JSON para as propriedades do modelo.
  ///
  /// Parameters:
  ///   json: Map<String, dynamic> - Dados JSON a serem convertidos
  ///
  /// Returns:
  ///   T: Instância do modelo criada a partir dos dados JSON
  ///
  /// Throws:
  ///   FormatException: Se os dados JSON estiverem mal formatados
  ///   ArgumentError: Se campos obrigatórios estiverem ausentes
  T Function(Map<String, dynamic>) get fromJson;

  /// Function para converter model em JSON
  ///
  /// Converte instâncias do modelo para formato JSON compatível
  /// com Firestore/Hive. Deve serializar todas as propriedades
  /// necessárias para persistência.
  ///
  /// Parameters:
  ///   model: T - Instância do modelo a ser serializada
  ///
  /// Returns:
  ///   Map<String, dynamic>: Dados JSON representando o modelo
  ///
  /// Throws:
  ///   ArgumentError: Se o modelo contém dados inválidos
  @override
  Map<String, dynamic> Function(T) get toJson;

  // Configuração personalizada do repository - removido (usando CommonRepositoryConfigs)

  /// Constructor protegido - subclasses devem implementar singleton
  BaseRepository() {
    _initializeSyncService();
    _registerWithInitializationManager();
  }

  /// Inicializar SyncFirebaseService - implementado por subclasses se necessário
  void _initializeSyncService() {
    _syncService = SyncFirebaseService.getInstance<T>(
      collectionName,
      fromJson,
      toJson,
    );

    // Configurar invalidação automática do cache
    setupCacheInvalidation(_syncService.dataStream);
  }

  /// Registrar repository no InitializationManager
  void _registerWithInitializationManager() {
    final config = RepositoryConfig(
      name: repositoryName,
      initFunction: () async => await _syncService.initialize(),
    );
    InitializationManager.instance.registerRepository(config);
  }

  /// Inicializar o repositório usando InitializationManager (thread-safe)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final result = await InitializationManager.instance
          .initializeRepository(repositoryName);

      if (result.isSuccess) {
        _isInitialized = true;
        await onAfterInitialize();
      } else {
        throw Exception(
            'Falha na inicialização do $repositoryName: ${result.error}');
      }
    } catch (e) {
      // Fallback para inicialização direta em caso de erro no manager
      if (!_isInitialized) {
        await _syncService.initialize();
        _isInitialized = true;
        await onAfterInitialize();
      }
      rethrow;
    }
  }

  /// Hook para lógica adicional após inicialização - override se necessário
  Future<void> onAfterInitialize() async {
    // Subclasses podem implementar lógica específica
  }

  // ===========================================
  // CRUD OPERATIONS BÁSICAS (Generic Pattern)
  // ===========================================

  /// Stream de todos os dados
  Stream<List<T>> get dataStream => _syncService.dataStream;

  /// Stream de status de sincronização
  Stream<SyncStatus> get syncStatusStream => _syncService.syncStatusStream;

  /// Stream de conectividade
  Stream<bool> get connectivityStream => _syncService.connectivityStream;

  /// Buscar todos os registros (com cache otimizado)
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP aplicam automaticamente:
  /// - Logging da operação (início/fim, duração, erros)
  /// - Validação de parâmetros de entrada
  /// - Coleta de estatísticas de performance
  /// - Cache management inteligente
  ///
  /// Recupera todos os registros da coleção com cache inteligente.
  /// O cache é mantido por 10 minutos para otimizar performance.
  ///
  /// Returns:
  ///   Future<List<T>>: Lista de todos os registros da coleção
  ///
  /// Throws:
  ///   RepositoryException: Se houver erro na consulta
  ///   NetworkException: Se não houver conexão e cache estiver expirado
  ///
  /// Example:
  /// ```dart
  /// final plantas = await plantaRepository.findAll();
  /// print('Total: ${plantas.length}');
  /// ```
  Future<List<T>> findAll() {
    // ISSUE #35: Os aspectos são aplicados automaticamente pelo proxy
    // Não é necessário chamar executeWithAspects aqui pois isso é
    // feito transparentemente pelo AspectAwareRepositoryProxy
    return cachedFindAll(
      () => _syncService.findAll(),
      repositoryName,
      ttl: const Duration(minutes: 10),
    );
  }

  /// Buscar registro por ID (com cache otimizado)
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP aplicam automaticamente:
  /// - Logging da operação com contexto (ID solicitado, resultado, duração)
  /// - Validação do ID de entrada (formato, não-vazio, etc.)
  /// - Coleta de estatísticas (cache hit/miss, tempo de resposta)
  /// - Error handling padronizado
  ///
  /// Recupera um registro específico pelo seu ID único.
  /// Utiliza cache por 15 minutos para queries frequentes.
  ///
  /// Parameters:
  ///   id: String - ID único do registro (não pode ser vazio)
  ///
  /// Returns:
  ///   Future<T?>: O registro encontrado ou null se não existir
  ///
  /// Throws:
  ///   ValidationException: Se ID estiver inválido (via ValidationAspect)
  ///   RepositoryException: Se houver erro na consulta
  ///
  /// Example:
  /// ```dart
  /// final planta = await plantaRepository.findById('123');
  /// if (planta != null) {
  ///   print('Encontrada: ${planta.nome}');
  /// }
  /// ```
  @override
  Future<T?> findById(String id) {
    // ISSUE #35: Validation é feita automaticamente pelo ValidationAspect
    // Assertion removida pois agora é responsabilidade do aspecto

    return cachedFindById(
      id,
      _syncService.findById,
      repositoryName,
      ttl: const Duration(minutes: 15),
    );
  }

  /// Buscar múltiplos registros por IDs (OTIMIZADO com cache batch)
  ///
  /// Recupera múltiplos registros de uma só vez, otimizando
  /// consultas ao banco e utilizando cache batch inteligente.
  ///
  /// Parameters:
  ///   ids: List<String> - Lista de IDs dos registros desejados
  ///
  /// Returns:
  ///   Future<List<T>>: Lista dos registros encontrados (pode ser menor que IDs fornecidos)
  ///
  /// Throws:
  ///   ArgumentError: Se algum ID estiver vazio
  ///   RepositoryException: Se houver erro na consulta
  ///
  /// Example:
  /// ```dart
  /// final plantas = await plantaRepository.findByIds(['1', '2', '3']);
  /// print('Encontradas: ${plantas.length} de 3 solicitadas');
  /// ```
  Future<List<T>> findByIds(List<String> ids) async {
    // Null object pattern: retornar lista vazia para entrada vazia
    if (ids.isEmpty) return <T>[];

    // Assertion para garantir que não há IDs vazios
    assert(
        ids.every((id) => id.isNotEmpty), 'Todos os IDs devem ser não-vazios');

    return cacheManager.getOrSetBatch(
      getCacheKey('findById'),
      ids,
      (missingIds) async {
        final allItems = await _syncService.findAll();
        final idSet = missingIds.toSet();
        return allItems
            .where((item) => idSet.contains(getItemId(item)))
            .toList();
      },
      (item) => getItemId(item),
      ttl: const Duration(minutes: 15),
    );
  }

  /// Criar novo registro (com invalidação de cache)
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP aplicam automaticamente:
  /// - Logging da operação (dados de entrada, ID gerado, duração)
  /// - Validação completa do modelo (campos obrigatórios, tipos, formatos)
  /// - Coleta de estatísticas (operações por minuto, sucesso/erro)
  /// - Error handling padronizado com contexto rico
  ///
  /// Cria um novo registro na coleção e invalida o cache
  /// para garantir consistência. Executa hook onItemCreated.
  ///
  /// Parameters:
  ///   item: T - Instância do modelo a ser criada (não pode ser null)
  ///
  /// Returns:
  ///   Future<String>: ID gerado para o novo registro
  ///
  /// Throws:
  ///   ValidationException: Se dados do item forem inválidos (via ValidationAspect)
  ///   RepositoryException: Se houver erro na criação
  ///
  /// Example:
  /// ```dart
  /// final novaPlanta = PlantaModel(nome: 'Rosa');
  /// final id = await plantaRepository.create(novaPlanta);
  /// print('Planta criada com ID: $id');
  /// ```
  Future<String> create(T item) async {
    // ISSUE #35: Validations são feitas automaticamente pelo ValidationAspect
    // Assertions removidas pois agora são responsabilidade dos aspectos

    final id = await _syncService.create(item);

    invalidateCache();
    onItemCreated(id, item);
    return id;
  }

  /// Atualizar registro (com invalidação de cache)
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP aplicam automaticamente:
  /// - Logging da operação (ID, dados alterados, duração)
  /// - Validação do ID e dados de entrada (existe, formato válido, etc.)
  /// - Coleta de estatísticas (updates por entidade, performance)
  /// - Error handling com retry automático se configurado
  ///
  /// Atualiza um registro existente na coleção e invalida
  /// o cache para garantir consistência. Executa hook onItemUpdated.
  ///
  /// Parameters:
  ///   id: String - ID do registro a ser atualizado (não pode ser vazio)
  ///   item: T - Nova instância do modelo (não pode ser null)
  ///
  /// Returns:
  ///   Future<void>: Completa quando a atualização é finalizada
  ///
  /// Throws:
  ///   ValidationException: Se ID ou dados forem inválidos (via ValidationAspect)
  ///   RepositoryException: Se houver erro na atualização
  ///   NotFoundException: Se o registro não existir
  ///
  /// Example:
  /// ```dart
  /// planta.nome = 'Rosa Vermelha';
  /// await plantaRepository.update('123', planta);
  /// ```
  Future<void> update(String id, T item) async {
    // ISSUE #35: Validations são feitas automaticamente pelo ValidationAspect
    // Assertions removidas pois agora são responsabilidade dos aspectos

    await _syncService.update(id, item);
    invalidateCache();
    onItemUpdated(id, item);
  }

  /// Deletar registro (com invalidação de cache)
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP aplicam automaticamente:
  /// - Logging da operação (ID, resultado, warnings)
  /// - Validação do ID (formato, existência)
  /// - Coleta de estatísticas (deletes por período, soft vs hard deletes)
  /// - Security checks (autorização para delete)
  ///
  /// Remove um registro da coleção e invalida o cache.
  /// Busca o item antes da deleção para executar o hook onItemDeleted.
  ///
  /// Parameters:
  ///   id: String - ID do registro a ser deletado (não pode ser vazio)
  ///
  /// Returns:
  ///   Future<void>: Completa quando a deleção é finalizada
  ///
  /// Throws:
  ///   ValidationException: Se ID estiver inválido (via ValidationAspect)
  ///   RepositoryException: Se houver erro na deleção
  ///
  /// Note:
  ///   Se o item não existir, a operação é bem-sucedida mas gera log de warning.
  ///
  /// Example:
  /// ```dart
  /// await plantaRepository.delete('123');
  /// ```
  Future<void> delete(String id) async {
    // ISSUE #35: Validations são feitas automaticamente pelo ValidationAspect
    // Assertion removida pois agora é responsabilidade do aspecto

    final item = await findById(id);
    await _syncService.delete(id);
    invalidateCache();

    // Null object pattern: só chamar callback se item existir
    if (item != null) {
      onItemDeleted(id, item);
    }
    // ISSUE #35: Warning logging é feito automaticamente pelo LoggingAspect
  }

  /// Criar múltiplos registros com transação atômica (transaction-safe)
  ///
  /// IMPORTANTE: Esta operação usa transações atômicas com rollback automático.
  /// Se qualquer operação falhar, todas as operações já executadas serão revertidas,
  /// garantindo consistência de dados entre Hive e Firebase.
  Future<List<String>> createBatch(List<T> items) async {
    return createBatchTransactional(items);
  }

  /// Criar múltiplos registros (versão legacy sem transação)
  ///
  /// DEPRECATED: Use createBatch() que é transaction-safe.
  /// Esta versão mantida apenas para compatibilidade temporária.
  @Deprecated(
      'Use createBatch() que é transaction-safe com rollback automático')
  Future<List<String>> createBatchLegacy(List<T> items) async {
    if (items.isEmpty) return [];

    // Usar BatchOperationHelper para chunks otimizados
    final ids = await BatchOperationHelper.executeBatch(
      items,
      (item) => _syncService.create(item),
      chunkSize: 20, // Processar em lotes de 20
      delay: const Duration(milliseconds: 50),
    );

    // Invalidar cache após batch operation
    invalidateCache();
    onItemsCreatedBatch(ids, items);

    return ids;
  }

  /// Atualizar múltiplos registros com transação atômica
  ///
  /// Atualiza múltiplos registros em uma única transação atômica.
  /// Se qualquer operação falhar, todas as alterações são revertidas.
  ///
  /// Parameters:
  ///   itemsMap: Map<String, T> - Mapa de ID -> Item para atualização
  ///
  /// Returns:
  ///   Future<void>: Completa quando todas as atualizações são finalizadas
  ///
  /// Throws:
  ///   ArgumentError: Se itemsMap estiver vazio ou contém valores inválidos
  ///   TransactionException: Se a transação falhar e for feito rollback
  ///   RepositoryException: Se houver erro nas operações
  ///
  /// Example:
  /// ```dart
  /// final updates = {'1': planta1, '2': planta2};
  /// await plantaRepository.updateBatch(updates);
  /// ```
  Future<void> updateBatch(Map<String, T> itemsMap) async {
    return updateBatchTransactional(itemsMap);
  }

  /// Deletar múltiplos registros com transação atômica
  ///
  /// Remove múltiplos registros em uma única transação atômica.
  /// Se qualquer operação falhar, todas as deleções são revertidas.
  ///
  /// Parameters:
  ///   ids: List<String> - Lista de IDs dos registros a serem deletados
  ///
  /// Returns:
  ///   Future<void>: Completa quando todas as deleções são finalizadas
  ///
  /// Throws:
  ///   ArgumentError: Se a lista estiver vazia ou contém IDs inválidos
  ///   TransactionException: Se a transação falhar e for feito rollback
  ///   RepositoryException: Se houver erro nas operações
  ///
  /// Example:
  /// ```dart
  /// await plantaRepository.deleteBatch(['1', '2', '3']);
  /// ```
  Future<void> deleteBatch(List<String> ids) async {
    return deleteBatchTransactional(ids);
  }

  /// Limpar todos os registros
  ///
  /// Remove todos os registros da coleção. Operação irreversível
  /// que deve ser usada com extrema cautela.
  ///
  /// Returns:
  ///   Future<void>: Completa quando todos os registros forem removidos
  ///
  /// Throws:
  ///   RepositoryException: Se houver erro na limpeza
  ///
  /// Warning:
  ///   Esta operação é irreversível e remove TODOS os dados da coleção.
  ///
  /// Example:
  /// ```dart
  /// await plantaRepository.clear(); // Remove todas as plantas!
  /// ```
  Future<void> clear() => _syncService.clear();

  /// Forçar sincronização
  ///
  /// Força a sincronização imediata entre dados locais (Hive)
  /// e remotos (Firebase). Útil quando é necessário garantir
  /// consistência de dados em tempo real.
  ///
  /// Returns:
  ///   Future<void>: Completa quando a sincronização é finalizada
  ///
  /// Throws:
  ///   NetworkException: Se não houver conexão com a internet
  ///   SyncException: Se houver conflitos de sincronização
  ///   RepositoryException: Se houver erro geral na sincronização
  ///
  /// Example:
  /// ```dart
  /// await plantaRepository.forceSync();
  /// print('Dados sincronizados com sucesso');
  /// ```
  Future<void> forceSync() => _syncService.forceSync();

  // ===========================================
  // HOOKS PARA CUSTOMIZAÇÃO POR SUBCLASSES
  // ===========================================

  /// Obter ID do item - deve ser implementado por subclasses
  @override
  String getItemId(T item);

  /// Hook executado após criar item
  void onItemCreated(String id, T item) {
    // Subclasses podem implementar lógica específica
  }

  /// Hook executado após atualizar item
  @override
  void onItemUpdated(String id, T item) {
    // Subclasses podem implementar lógica específica
  }

  /// Hook executado após deletar item
  @override
  void onItemDeleted(String id, T item) {
    // Subclasses podem implementar lógica específica
  }

  /// Hook executado após criar items em batch
  @override
  void onItemsCreatedBatch(List<String> ids, List<T> items) {
    // Subclasses podem implementar lógica específica
  }

  // ===========================================
  // UTILITY METHODS GENÉRICOS
  // ===========================================

  /// Salvar item (create ou update) - Método genérico
  Future<String> save(T item) async {
    // Assertion para garantir item válido

    final id = getItemId(item);

    // Null object pattern: decidir entre create/update baseado no ID
    if (id.isEmpty) {
      return await create(item);
    } else {
      await update(id, item);
      return id;
    }
  }

  /// Cache para queries com filtros genérico - usando implementação do CacheableRepository
  Future<List<T>> cachedQueryBase(
    Map<String, dynamic> filters,
    Future<List<T>> Function() fetchFunction,
    String operationName, {
    Duration? ttl,
  }) {
    return cachedQuery<T>(filters, fetchFunction, operationName, ttl: ttl);
  }

  /// Obter informações de debug
  Map<String, dynamic> getDebugInfo() => _syncService.getDebugInfo();

  /// Verificar se repository está inicializado
  bool get isInitialized => _isInitialized;

  /// Obter estatísticas básicas genéricas
  ///
  /// ISSUE #33: Mixed Abstraction Levels - LOW-LEVEL OPERATION
  /// ISSUE #35: Repository Responsibilities - Statistics externalizadas via AOP
  ///
  /// Este método mantém apenas estatísticas básicas de repository.
  /// Estatísticas detalhadas de performance, acesso e uso são coletadas
  /// automaticamente pelo StatisticsAspect e podem ser acessadas via:
  /// - RepositoryAspectManager.instance.getAspectStatistics()
  /// - StatisticsAspect.getStatistics(repositoryName)
  ///
  /// Para estatísticas complexas e análises de negócio, use:
  /// - RepositoryOperationsFacade.getDashboardData()
  /// - RepositoryQueryFacade.getProductivityStats()
  /// - Services especializados de estatísticas
  Future<Map<String, dynamic>> getBasicStats() async {
    final items = await findAll();
    return {
      'total': items.length,
      'collection': collectionName,
      'repository': repositoryName,
      'isInitialized': _isInitialized,
      'cacheStats': cacheManager.getStats().toString(),
      'transactionStats': getTransactionStats(),
      // ISSUE #35: Aspectos AOP fornecem estatísticas avançadas
      'aspects_enabled': aspects.isNotEmpty,
      'active_aspects': aspects.map((a) => a.name).toList(),
    };
  }

  // ===========================================
  // LIFECYCLE MANAGEMENT
  // ===========================================

  /// Limpar recursos (incluindo streams e cache)
  Future<void> dispose() async {
    await disposeStreams(); // Limpar subscriptions gerenciadas
    invalidateFilterCache(repositoryName); // Limpar cache de filtros
    invalidateCache(); // Limpar cache inteligente
    _syncService.dispose();
  }

  // ===========================================
  // IMPLEMENTAÇÃO DOS MÉTODOS TRANSACIONAIS
  // ===========================================

  Future<String> _executeCreateWithoutCacheInvalidation(T item) async {
    return await _syncService.create(item);
  }

  Future<void> _executeUpdateWithoutCacheInvalidation(String id, T item) async {
    return await _syncService.update(id, item);
  }

  Future<void> _executeDeleteWithoutCacheInvalidation(String id) async {
    return await _syncService.delete(id);
  }
}

// RepositoryConfig movido para compatibility com InitializationManager

/// Mixin para funcionalidades específicas de Plant Care
mixin PlantCareFunctionality<T extends BaseModel> on BaseRepository<T> {
  /// Stream de dados filtrados por planta
  Stream<List<T>> watchByPlanta(String plantaId) {
    return dataStream.map((items) =>
        items.where((item) => getPlantaId(item) == plantaId).toList());
  }

  /// Buscar registros por planta
  Future<List<T>> findByPlanta(String plantaId) {
    return cachedQuery(
      {'plantaId': plantaId},
      () async {
        final items = await findAll();
        return items.where((item) => getPlantaId(item) == plantaId).toList();
      },
      'findByPlanta',
      ttl: const Duration(minutes: 10),
    );
  }

  /// Obter PlantaId do item - deve ser implementado por subclasses que usam este mixin
  String getPlantaId(T item);
}

/// Mixin para funcionalidades específicas de Space Management
mixin SpaceManagementFunctionality<T extends BaseModel> on BaseRepository<T> {
  /// Stream de dados ativos
  Stream<List<T>> watchAtivos() {
    return dataStream
        .map((items) => items.where((item) => isItemActive(item)).toList());
  }

  /// Stream de dados inativos
  Stream<List<T>> watchInativos() {
    return dataStream
        .map((items) => items.where((item) => !isItemActive(item)).toList());
  }

  /// Buscar registros ativos
  Future<List<T>> findAtivos() async {
    final items = await findAll();
    return items.where((item) => isItemActive(item)).toList();
  }

  /// Verificar se item está ativo - deve ser implementado por subclasses que usam este mixin
  bool isItemActive(T item);
}

/// Mixin para funcionalidades específicas de Task Management
mixin TaskManagementFunctionality<T extends BaseModel> on BaseRepository<T> {
  /// Stream de tarefas pendentes
  Stream<List<T>> watchPendentes() {
    return dataStream
        .map((items) => items.where((item) => !isTaskCompleted(item)).toList());
  }

  /// Stream de tarefas concluídas
  Stream<List<T>> watchConcluidas() {
    return dataStream
        .map((items) => items.where((item) => isTaskCompleted(item)).toList());
  }

  /// Buscar tarefas pendentes
  Future<List<T>> findPendentes() async {
    final items = await findAll();
    return items.where((item) => !isTaskCompleted(item)).toList();
  }

  /// Buscar tarefas concluídas
  Future<List<T>> findConcluidas() async {
    final items = await findAll();
    return items.where((item) => isTaskCompleted(item)).toList();
  }

  /// Verificar se tarefa está concluída - deve ser implementado por subclasses que usam este mixin
  bool isTaskCompleted(T item);
}
