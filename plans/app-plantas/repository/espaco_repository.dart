// Dart imports:
import 'dart:async';

// Project imports:
import '../core/interfaces/i_espaco_repository.dart';
import '../core/validation/espaco_validator.dart';
import '../core/validation/result.dart';
import '../database/espaco_model.dart';
import '../services/configuration/default_spaces_service.dart';
import '../services/domain/spaces/espaco_copy_service.dart';
import '../shared/utils/string_comparison_utils.dart';
import 'base_repository.dart';
import 'patterns/update_command.dart';

/// Repository para Espaços usando BaseRepository pattern
///
/// ISSUE #33: Mixed Abstraction Levels - SOLUTION IMPLEMENTED
/// ISSUE #35: Repository Responsibilities - SOLUTION IMPLEMENTED
///
/// ARQUITETURA REFATORADA - Mantém APENAS operações de baixo nível:
/// - CRUD básico para EspacoModel
/// - Operações simples de busca (findByNome, searchEspacos)
/// - Operações de ativação/desativação básicas
/// - Criação de espaços padrão (setup inicial)
/// - Cache básico e stream management
///
/// CROSS-CUTTING CONCERNS EXTERNALIZADOS via AOP:
/// - Logging: Aplicado automaticamente via LoggingAspect
/// - Validation: Aplicado automaticamente via ValidationAspect
/// - Statistics: Aplicado automaticamente via StatisticsAspect
/// - Error Handling: Aplicado automaticamente via aspectos
///
/// Para operações de alto nível, use:
/// - RepositoryOperationsFacade: Operações cross-entity e analytics
/// - RepositoryQueryFacade: Queries complexas e relatórios
/// - BusinessRulesService: Validações de negócio (existeEspacoComNome, etc.)
/// - StatisticsService: Estatísticas e métricas (getEspacoStatistics, etc.)
/// - EspacoQueryService: Consultas avançadas e filtros complexos
/// - EspacoStatisticsService: Estatísticas detalhadas e relatórios
///
/// CONSISTENT ABSTRACTION LEVEL: Foca apenas em persistência de EspacoModel.
class EspacoRepository extends BaseRepository<EspacoModel>
    with SpaceManagementFunctionality<EspacoModel>
    implements IEspacoRepository {
  static EspacoRepository? _instance;
  // Late final singleton com assertion para garantir inicialização única
  static EspacoRepository get instance {
    return _instance ??= EspacoRepository._();
  }

  EspacoRepository._() : super();

  @override
  String get repositoryName => 'EspacoRepository';

  @override
  String get collectionName => 'espacos';

  @override
  EspacoModel Function(Map<String, dynamic>) get fromJson =>
      EspacoModel.fromJson;

  @override
  Map<String, dynamic> Function(EspacoModel) get toJson =>
      (espaco) => espaco.toJson();

  @override
  String getItemId(EspacoModel item) => item.id;

  @override
  bool isItemActive(EspacoModel item) => item.ativo;

  // repositoryConfig removido - usando CommonRepositoryConfigs no BaseRepository

  @override
  Future<void> onAfterInitialize() async {
    // Verificar se existem espaços, se não criar os padrão
    final espacos = await findAll();
    if (espacos.isEmpty) {
      await _criarEspacosPadrao();
    }
  }

  /// Stream de todos os espaços (backward compatibility)
  Stream<List<EspacoModel>> get espacosStream => dataStream;

  // Métodos findAll() e findById() herdados do BaseRepository

  /// Criar novo espaço (interface method)
  @override
  Future<String> criar(EspacoModel espaco) async {
    return await create(espaco);
  }

  /// Criar novo espaço (override do BaseRepository)
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP aplicam automaticamente:
  /// - Logging da criação (dados de entrada, validações, resultado)
  /// - Validação completa (dados básicos, unicidade de nome, regras de negócio)
  /// - Coleta de estatísticas (espaços criados por período, padrões de nomes)
  /// - Error handling padronizado com contexto rico
  @override
  Future<String> create(EspacoModel espaco) async {
    // ISSUE #35: Validações movidas para ValidationAspect
    // O aspecto aplicará automaticamente:
    // - validateForCreate(espaco)
    // - validateNomeUnique(espaco.nome)
    // - Outros checks de integridade

    // Usar validators legacy para compatibilidade, mas aspectos são prioritários
    final validation = EspacoValidator.instance.validateForCreate(espaco);
    if (validation.isError) {
      throw Exception(validation.error!.toString());
    }

    final uniqueValidation = await EspacoValidator.instance.validateNomeUnique(
      espaco.nome,
      () => findAll(),
    );
    if (uniqueValidation.isError) {
      throw Exception(uniqueValidation.error!.toString());
    }

    return await super.create(validation.value);
  }

  /// Criar novo espaço com Result wrapper
  Future<Result<String>> createWithResult(EspacoModel espaco) async {
    try {
      final id = await create(espaco);
      return Result.success(id);
    } catch (e) {
      return Result.error(
          InvalidStateError('create', 'Erro ao criar espaço: $e'));
    }
  }

  /// Criar novo espaço (método legacy - mantido para compatibilidade)
  Future<String> createLegacy(EspacoModel espaco) => create(espaco);

  /// Atualizar espaço (interface method)
  @override
  Future<void> atualizar(EspacoModel espaco) async {
    await update(espaco.id, espaco);
  }

  /// Atualizar espaço (override do BaseRepository)
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP aplicam automaticamente:
  /// - Logging da atualização (ID, campos alterados, validações)
  /// - Validação completa (dados, unicidade, regras de negócio)
  /// - Coleta de estatísticas (updates por espaço, campos mais alterados)
  /// - Change tracking para auditoria
  @override
  Future<void> update(String id, EspacoModel espaco) async {
    // ISSUE #35: Validações movidas para ValidationAspect
    // Manter validators legacy para compatibilidade, mas aspectos são prioritários
    final validation = EspacoValidator.instance.validateForUpdate(espaco);
    if (validation.isError) {
      throw Exception(validation.error!.toString());
    }

    final uniqueValidation = await EspacoValidator.instance.validateNomeUnique(
      espaco.nome,
      () => findAll(),
      excludeId: id,
    );
    if (uniqueValidation.isError) {
      throw Exception(uniqueValidation.error!.toString());
    }

    await super.update(id, validation.value);
  }

  /// Atualizar espaço com Result wrapper
  Future<Result<void>> updateWithResult(String id, EspacoModel espaco) async {
    try {
      await update(id, espaco);
      return Result.success(null);
    } catch (e) {
      return Result.error(
          InvalidStateError('update', 'Erro ao atualizar espaço: $e'));
    }
  }

  /// Atualizar espaço (método legacy - mantido para compatibilidade)
  Future<void> updateLegacy(String id, EspacoModel espaco) =>
      update(id, espaco);

  // Métodos delete(), createBatch(), clear() e forceSync() herdados do BaseRepository

  // Métodos específicos para Espaços

  // Streams watchAtivos() e watchInativos() herdados do mixin SpaceManagementFunctionality

  // Método findAtivos() herdado do mixin SpaceManagementFunctionality

  /// Buscar espaços por nome (OTIMIZADO com Firebase queries)
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP aplicam automaticamente:
  /// - Logging detalhado (nome buscado, estratégia, resultados, filtros)
  /// - Validação do nome de entrada (não-vazio, caracteres válidos)
  /// - Coleta de estatísticas (Firebase vs fallback, cache performance)
  /// - Error handling com retry e fallback automático
  ///
  /// Para queries avançadas, use EspacoQueryService
  Future<List<EspacoModel>> findByNome(String nome) async {
    // ISSUE #35: Validação feita automaticamente pelo ValidationAspect
    // Assertion removida pois agora é responsabilidade do aspecto

    try {
      final optimizedResults = await syncService.findByNomeOptimized(nome);
      if (optimizedResults.isNotEmpty) {
        // Filtrar apenas espaços ativos (regra de negócio)
        final activeSpaces =
            optimizedResults.where((espaco) => espaco.ativo).toList();
        if (activeSpaces.isNotEmpty) {
          // ISSUE #35: Debug logging feito automaticamente pelo LoggingAspect
          return activeSpaces;
        }
      }
    } catch (e) {
      // ISSUE #35: Error logging feito automaticamente pelo LoggingAspect
      // Continuar com fallback
    }

    // Fallback para busca local com comparação normalizada
    final espacos = await findAll();

    return espacos.where((espaco) {
      // Null safety: garantir que nome do espaço seja válido
      final espacoNome = espaco.nome;
      if (espacoNome.trim().isEmpty) return false;
      return StringComparisonUtils.contains(espacoNome, nome) && espaco.ativo;
    }).toList();
  }

  /// Buscar espaços usando full-text search otimizado
  Future<List<EspacoModel>> searchEspacos(
    String searchText, {
    List<String> searchFields = const ['nome', 'descricao'],
  }) async {
    try {
      // Usar full-text search otimizado
      final results = await syncService.fullTextSearch(
        searchText,
        searchFields: searchFields,
      );

      // Filtrar apenas espaços ativos
      final activeResults = results.where((espaco) => espaco.ativo).toList();

      logger.debug('Full-text search encontrou espaços ativos',
          data: {'count': activeResults.length});
      return activeResults;
    } catch (e) {
      logger.warning('Erro no full-text search de espaços, usando busca básica',
          data: {'error': e.toString()});
      return await findByNome(searchText);
    }
  }

  /// Remover espaço (interface method)
  @override
  Future<void> remover(String id) async {
    await delete(id);
  }

  /// Verificar se existe espaço com nome básico
  /// DEPRECATED: Use BusinessRulesService.existeEspacoComNome() para regras de negócio
  /// Para queries avançadas, use EspacoQueryService
  @Deprecated(
      'Use BusinessRulesService.existeEspacoComNome() - será removido na v2.0')
  @override
  Future<bool> existeComNome(String nome, {String? excludeId}) async {
    // Implementação legacy mantida por compatibilidade
    // Recomenda-se usar BusinessRulesService.existeEspacoComNome()
    // FIXED: Usa comparação normalizada para caracteres acentuados
    final espacos = await findAll();

    return espacos.any((espaco) =>
        StringComparisonUtils.equals(espaco.nome, nome) &&
        espaco.ativo &&
        (excludeId == null || espaco.id != excludeId));
  }

  /// Ativar espaço com validação (interface method)
  @override
  Future<void> ativar(String id) async {
    final result = await _setAtivoWithResult(id, true);
    if (result.isError) {
      throw Exception(result.error.toString());
    }
  }

  /// Desativar espaço com validação (interface method)
  @override
  Future<void> desativar(String id) async {
    final result = await _setAtivoWithResult(id, false);
    if (result.isError) {
      throw Exception(result.error.toString());
    }
  }

  /// Definir status ativo/inativo (interface method)
  @override
  Future<void> setAtivo(String id, bool ativo) async {
    final result = await _setAtivoWithResult(id, ativo);
    if (result.isError) {
      throw Exception(result.error.toString());
    }
  }

  /// Definir status ativo do espaço com validação (internal method)
  Future<Result<void>> _setAtivoWithResult(String espacoId, bool ativo) async {
    try {
      final espaco = await findById(espacoId);
      if (espaco == null) {
        return Result.error(const InvalidReferenceError('espacoId', 'Espaco'));
      }

      // Validar mudança de status
      final statusValidation =
          EspacoValidator.instance.validateStatusChange(espaco, ativo);
      if (statusValidation.isError) {
        return Result.error(statusValidation.error!);
      }

      // Usar factory para atualizar com validação
      final espacoValidado = EspacoModelFactory.instance.update(
        espaco,
        ativo: ativo,
      );

      if (espacoValidado.isError) {
        return Result.error(espacoValidado.error!);
      }

      await update(espacoId, espacoValidado.value);
      return Result.success(null);
    } catch (e) {
      return Result.error(
          InvalidStateError('setAtivo', 'Erro ao definir status: $e'));
    }
  }

  /// Métodos legacy para ativar/desativar
  Future<void> ativarLegacy(String espacoId) async {
    await setAtivo(espacoId, true);
  }

  Future<void> desativarLegacy(String espacoId) async {
    await setAtivo(espacoId, false);
  }

  Future<void> setAtivoLegacy(String espacoId, bool ativo) async {
    await setAtivo(espacoId, ativo);
  }

  /// Salvar espaço com validação usando Command pattern
  Future<Result<String>> salvar(EspacoModel espaco) async {
    try {
      if (espaco.id.isEmpty) {
        // Operação de criação usando Command pattern
        final command = CreateEspacoCommand(
          creationParams: EspacoCreationParameters(
            nome: espaco.nome,
            descricao: espaco.descricao,
            ativo: espaco.ativo,
            dataCriacao: espaco.dataCriacao,
          ),
        );

        final commandResult = await CommandExecutor.execute(command);
        if (commandResult.isError) {
          return Result.error(commandResult.error!);
        }

        final id = await create(commandResult.value);
        return Result.success(id);
      } else {
        // Operação de atualização usando Command pattern
        final espacoOriginal = await findById(espaco.id);
        if (espacoOriginal == null) {
          return Result.error(const InvalidReferenceError('id', 'Espaco'));
        }

        final command = UpdateEspacoCommand(
          currentEspaco: espacoOriginal,
          updateParams: EspacoUpdateParameters(
            nome: espaco.nome,
            descricao: espaco.descricao,
            ativo: espaco.ativo,
            dataCriacao: espaco.dataCriacao,
          ),
        );

        final commandResult = await CommandExecutor.execute(command);
        if (commandResult.isError) {
          return Result.error(commandResult.error!);
        }

        await update(espaco.id, commandResult.value);
        return Result.success(espaco.id);
      }
    } catch (e) {
      return Result.error(
          InvalidStateError('salvar', 'Erro ao salvar espaço: $e'));
    }
  }

  /// Salvar espaço (método legacy - mantido para compatibilidade)
  Future<String> salvarLegacy(EspacoModel espaco) async {
    return await save(espaco);
  }

  /// Duplicar espaço (interface method)
  @override
  Future<String> duplicar(String id) async {
    final result = await _duplicarWithResult(id);
    if (result.isError) {
      throw Exception(result.error.toString());
    }
    return result.value;
  }

  /// Duplicar espaço delegando para EspacoCopyService (internal method)
  /// Repository não contém lógica de negócio - apenas delega para service
  Future<Result<String>> _duplicarWithResult(String espacoId) async {
    try {
      // Delegar lógica de negócio para EspacoCopyService
      final id = await EspacoCopyService.instance.duplicateSpace(espacoId);
      return Result.success(id);
    } catch (e) {
      return Result.error(
          InvalidStateError('duplicar', 'Erro ao duplicar espaço: $e'));
    }
  }

  /// Criar espaço usando parameter object (simplifica múltiplos parâmetros)
  Future<Result<String>> criarEspaco({
    required String nome,
    String? descricao,
    bool ativo = true,
    DateTime? dataCriacao,
  }) async {
    // Assertions para validar parâmetros críticos
    assert(nome.trim().isNotEmpty, 'Nome do espaço não pode ser vazio');
    assert(
        dataCriacao == null ||
            dataCriacao.isBefore(DateTime.now().add(const Duration(days: 1))),
        'Data de criação não pode ser no futuro');
    try {
      final params = EspacoCreationParameters(
        nome: nome,
        descricao: descricao,
        ativo: ativo,
        dataCriacao: dataCriacao,
      );

      final command = CreateEspacoCommand(creationParams: params);
      final commandResult = await CommandExecutor.execute(command);

      if (commandResult.isError) {
        return Result.error(commandResult.error!);
      }

      final id = await create(commandResult.value);
      return Result.success(id);
    } catch (e) {
      return Result.error(
          InvalidStateError('criarEspaco', 'Erro ao criar espaço: $e'));
    }
  }

  /// Atualizar espaço usando parameter object (simplifica múltiplos parâmetros)
  Future<Result<void>> atualizarEspaco({
    required String espacoId,
    String? nome,
    String? descricao,
    bool? ativo,
    DateTime? dataCriacao,
  }) async {
    // Assertions para validar parâmetros críticos
    assert(espacoId.trim().isNotEmpty, 'espacoId não pode ser vazio');
    assert(nome == null || nome.trim().isNotEmpty,
        'Se fornecido, nome não pode ser vazio');
    assert(
        dataCriacao == null ||
            dataCriacao.isBefore(DateTime.now().add(const Duration(days: 1))),
        'Data de criação não pode ser no futuro');
    try {
      final espacoAtual = await findById(espacoId);
      if (espacoAtual == null) {
        return Result.error(const InvalidReferenceError('espacoId', 'Espaco'));
      }

      final params = EspacoUpdateParameters(
        nome: nome,
        descricao: descricao,
        ativo: ativo,
        dataCriacao: dataCriacao,
      );

      // Verificar se há algo para atualizar
      if (!params.hasUpdates) {
        return Result.success(null); // Nada para atualizar
      }

      final command = UpdateEspacoCommand(
        currentEspaco: espacoAtual,
        updateParams: params,
      );

      final commandResult = await CommandExecutor.execute(command);
      if (commandResult.isError) {
        return Result.error(commandResult.error!);
      }

      await update(espacoId, commandResult.value);
      return Result.success(null);
    } catch (e) {
      return Result.error(
          InvalidStateError('atualizarEspaco', 'Erro ao atualizar espaço: $e'));
    }
  }

  /// Operação batch para criar múltiplos espaços usando parameter objects
  Future<List<Result<String>>> criarMultiplosEspacos(
    List<EspacoCreationParameters> espacosParams,
  ) async {
    final results = <Result<String>>[];

    for (final params in espacosParams) {
      final result = await criarEspaco(
        nome: params.nome,
        descricao: params.descricao,
        ativo: params.ativo,
        dataCriacao: params.dataCriacao,
      );

      results.add(result);

      // Continuar mesmo se houver erro (não é crítico)
    }

    return results;
  }

  /// Duplicar espaço (método legacy - mantido para compatibilidade)
  /// Repository não contém lógica de negócio - delega para EspacoCopyService
  Future<String> duplicarLegacy(String espacoId) async {
    // Delegar lógica de negócio para EspacoCopyService
    return await EspacoCopyService.instance.duplicateSpace(espacoId);
  }

  /// Obter estatísticas básicas dos espaços
  /// DEPRECATED: Use StatisticsService.getEspacoStatistics() para lógica de negócio
  /// Para estatísticas avançadas, use EspacoStatisticsService
  @Deprecated(
      'Use StatisticsService.getEspacoStatistics() - será removido na v2.0')
  Future<Map<String, int>> getEstatisticas() async {
    // Implementação legacy mantida por compatibilidade
    // Recomenda-se usar StatisticsService.getEspacoStatistics()
    final espacos = await findAll();

    int ativos = 0;
    int inativos = 0;

    for (final espaco in espacos) {
      if (espaco.ativo) {
        ativos++;
      } else {
        inativos++;
      }
    }

    return {
      'total': espacos.length,
      'ativos': ativos,
      'inativos': inativos,
    };
  }

  /// Criar espaços padrão usando configuração internacionalizada
  ///
  /// Os espaços são agora configuráveis via:
  /// - SharedPreferences para customização local
  /// - Sistema de tradução GetX para i18n
  /// - Configuração remota (futuro)
  Future<void> _criarEspacosPadrao() async {
    try {
      // Tentar usar o service de configuração
      final defaultSpacesService = DefaultSpacesService.instance;
      final espacosPadrao =
          await defaultSpacesService.createDefaultSpaceModels();

      if (espacosPadrao.isNotEmpty) {
        await createBatch(espacosPadrao);
        logger.info(
            'Espaços padrão criados usando configuração internacionalizada',
            data: {'count': espacosPadrao.length});
        return;
      }
    } catch (e) {
      logger.warning(
          'Erro ao criar espaços com service de configuração, usando fallback',
          data: {'error': e.toString()});
    }

    // Fallback para versão hardcoded (mantido para compatibilidade)
    await _criarEspacosPadraoFallback();
  }

  /// Fallback para criação de espaços padrão (versão legacy)
  ///
  /// Mantido para garantir que sempre haverá espaços criados,
  /// mesmo se o service de configuração falhar.
  Future<void> _criarEspacosPadraoFallback() async {
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;

    final espacosPadrao = [
      EspacoModel(
        id: '',
        createdAt: nowMs,
        updatedAt: nowMs,
        nome: 'Sala de estar',
        descricao: 'Ambiente principal da casa',
        ativo: true,
        dataCriacao: now,
      ),
      EspacoModel(
        id: '',
        createdAt: nowMs,
        updatedAt: nowMs,
        nome: 'Quarto',
        descricao: 'Dormitório',
        ativo: true,
        dataCriacao: now,
      ),
      EspacoModel(
        id: '',
        createdAt: nowMs,
        updatedAt: nowMs,
        nome: 'Cozinha',
        descricao: 'Área de preparo de alimentos',
        ativo: true,
        dataCriacao: now,
      ),
      EspacoModel(
        id: '',
        createdAt: nowMs,
        updatedAt: nowMs,
        nome: 'Varanda',
        descricao: 'Área externa coberta',
        ativo: true,
        dataCriacao: now,
      ),
      EspacoModel(
        id: '',
        createdAt: nowMs,
        updatedAt: nowMs,
        nome: 'Jardim',
        descricao: 'Área externa com terra',
        ativo: true,
        dataCriacao: now,
      ),
    ];

    await createBatch(espacosPadrao);
    logger.info('Espaços padrão criados usando fallback hardcoded',
        data: {'count': espacosPadrao.length});
  }

  /// Recriar espaços padrão (para desenvolvimento)
  ///
  /// Limpa todos os espaços existentes e recria usando a configuração atual.
  /// Útil para desenvolvimento e testes.
  Future<void> recriarEspacosPadrao() async {
    await clear();
    await _criarEspacosPadrao();
    logger.info('Espaços padrão recriados para desenvolvimento');
  }

  /// Preparar espaços para busca otimizada
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP aplicam automaticamente:
  /// - Logging detalhado do setup (progresso, resultados, erros)
  /// - Error handling com retry automático
  /// - Coleta de estatísticas (tempo de setup, effectiveness do cache warming)
  /// - Performance monitoring do processo
  Future<void> setupOptimizedSearch() async {
    // ISSUE #35: Logging e error handling feitos pelos aspectos
    try {
      // Preparar documentos Firebase para busca
      await syncService.prepareCollectionForOptimizedSearch();

      // Warm up cache com termos comuns
      await syncService.warmupSearchCache(
        commonTerms: ['sala', 'quarto', 'cozinha', 'varanda', 'jardim'],
      );
    } catch (e) {
      // ISSUE #35: Exception handling feito automaticamente pelos aspectos
      rethrow; // Re-lançar para que os aspectos possam processar
    }
  }

  /// Obter relatório de performance das queries
  Future<Map<String, dynamic>> getQueryPerformanceReport() async {
    return await syncService.getQueryPerformanceReport();
  }

  /// Limpar recursos (incluindo streams e cache)
  @override
  Future<void> dispose() async {
    await super.dispose();
  }
}
