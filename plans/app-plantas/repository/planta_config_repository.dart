// Dart imports:
import 'dart:async';

// Project imports:
import '../../core/services/sync_firebase_service.dart';
import '../core/initialization/initialization_manager.dart';
import '../core/interfaces/i_planta_config_repository.dart';
import '../core/validation/planta_config_validator.dart';
import '../core/validation/result.dart';
import '../database/planta_config_model.dart';
import 'error_handling/repository_error_handling_mixin.dart';
import 'patterns/care_type_handler.dart';
import 'patterns/update_command.dart';
import 'planta_repository.dart';

/// Repository para PlantaConfig usando SyncFirebaseService unificado
class PlantaConfigRepository with RepositoryErrorHandlingMixin implements IPlantaConfigRepository {
  static PlantaConfigRepository? _instance;
  static PlantaConfigRepository get instance =>
      _instance ??= PlantaConfigRepository._();

  late final SyncFirebaseService<PlantaConfigModel> _syncService;
  bool _isInitialized = false;

  PlantaConfigRepository._() {
    // Garantir que o adapter está registrado antes de criar o serviço
    SyncFirebaseService.safeRegisterAdapter(PlantaConfigModelAdapter());

    _syncService = SyncFirebaseService.getInstance<PlantaConfigModel>(
      'planta_config',
      (map) => PlantaConfigModel.fromJson(map),
      (model) => model.toJson(),
    );

    // Registrar no InitializationManager
    _registerWithInitializationManager();
  }

  @override
  String get repositoryName => 'PlantaConfigRepository';

  /// Registrar repository no InitializationManager
  void _registerWithInitializationManager() {
    final config = CommonRepositoryConfigs.plantaConfigRepository(() async {
      await _syncService.initialize();
    });

    InitializationManager.instance.registerRepository(config);
  }

  /// Inicializar o repositório usando InitializationManager (thread-safe)
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final result = await InitializationManager.instance
          .initializeRepository('PlantaConfigRepository');

      if (result.isSuccess) {
        _isInitialized = true;
      } else {
        throw Exception(
            'Falha na inicialização do PlantaConfigRepository: ${result.error}');
      }
    } catch (e) {
      // Fallback para inicialização direta em caso de erro no manager
      if (!_isInitialized) {
        await _syncService.initialize();
        _isInitialized = true;
      }
      rethrow;
    }
  }

  /// Criar nova configuração com validação robusta
  Future<Result<PlantaConfigModel>> create(PlantaConfigModel config) async {
    // Validar dados básicos
    final validation = PlantaConfigValidator.instance.validateForCreate(config);
    if (validation.isError) {
      return Result.error(validation.error!);
    }

    // Validar se planta existe
    final plantaValidation =
        await PlantaConfigValidator.instance.validatePlantaExists(
      config.plantaId,
      (plantaId) async {
        final planta = await PlantaRepository.instance.findById(plantaId);
        return planta != null;
      },
    );
    if (plantaValidation.isError) {
      return Result.error(plantaValidation.error!);
    }

    try {
      final id = await _syncService.create(validation.value);
      final created = validation.value.copyWith(id: id);
      return Result.success(created);
    } catch (e) {
      return Result.error(InvalidStateError(
        'create',
        'Erro ao criar configuração: $e',
      ));
    }
  }

  /// Criar nova configuração (método legacy - mantido para compatibilidade)
  Future<PlantaConfigModel> createLegacy(PlantaConfigModel config) async {
    final id = await _syncService.create(config);
    final created = config.copyWith(id: id);
    return created;
  }

  /// Atualizar configuração com validação robusta
  Future<Result<PlantaConfigModel>> update(
      String id, PlantaConfigModel config) async {
    // Validar dados básicos
    final validation = PlantaConfigValidator.instance.validateForUpdate(config);
    if (validation.isError) {
      return Result.error(validation.error!);
    }

    // Validar se planta existe
    final plantaValidation =
        await PlantaConfigValidator.instance.validatePlantaExists(
      config.plantaId,
      (plantaId) async {
        final planta = await PlantaRepository.instance.findById(plantaId);
        return planta != null;
      },
    );
    if (plantaValidation.isError) {
      return Result.error(plantaValidation.error!);
    }

    try {
      await _syncService.update(id, validation.value);
      return Result.success(validation.value);
    } catch (e) {
      return Result.error(InvalidStateError(
        'update',
        'Erro ao atualizar configuração: $e',
      ));
    }
  }

  /// Atualizar configuração (método legacy - mantido para compatibilidade)
  Future<PlantaConfigModel> updateLegacy(
      String id, PlantaConfigModel config) async {
    await _syncService.update(id, config);
    return config;
  }

  Future<bool> delete(String id) async {
    await _syncService.delete(id);
    return true;
  }

  @override
  Future<PlantaConfigModel?> findById(String id) async {
    return _syncService.findById(id);
  }

  @override
  Future<List<PlantaConfigModel>> findAll() async {
    return _syncService.findAll();
  }

  /// Busca configuração por ID da planta (CORRIGIDO - sem engolir exceptions)
  @override
  Future<PlantaConfigModel?> findByPlantaId(String plantaId) async {
    return await executeCrudOperation<PlantaConfigModel?>(
      operation: () async {
        // Verificar se já está inicializado antes de chamar initialize()
        if (!_isInitialized) {
          await initialize();
        }

        final configs = await findAll();

        // Usar método seguro que não engole exceptions inesperadas
        return findInListSafely(
          configs,
          (config) => config.plantaId == plantaId,
          'findByPlantaId',
          context: {'plantaId': plantaId},
        );
      },
      operationType: 'findByPlantaId',
      entityId: plantaId,
      entityType: 'PlantaConfig',
      additionalContext: {'searchCriteria': 'plantaId=$plantaId'},
    );
  }

  /// Busca configurações de plantas ativas
  @override
  Future<List<PlantaConfigModel>> findActiveConfigs() async {
    if (!_isInitialized) {
      await initialize();
    }

    final configs = await findAll();
    return configs
        .where((config) =>
            config.aguaAtiva ||
            config.aduboAtivo ||
            config.banhoSolAtivo ||
            config.inspecaoPragasAtiva ||
            config.podaAtiva ||
            config.replantarAtivo)
        .toList();
  }

  /// Busca configurações por tipo de cuidado ativo
  @override
  Future<List<PlantaConfigModel>> findByActiveCareType(
      String tipoCuidado) async {
    if (!_isInitialized) {
      await initialize();
    }

    final configs = await findAll();
    return configs
        .where((config) => config.isCareTypeActive(tipoCuidado))
        .toList();
  }

  /// Remove configuração por ID da planta
  Future<void> removeByPlantaId(String plantaId) async {
    final config = await findByPlantaId(plantaId);
    if (config != null) {
      await delete(config.id);
    }
  }

  /// Atualiza configuração de uma planta com validação
  Future<Result<PlantaConfigModel>> updatePlantConfig(
    String plantaId,
    PlantaConfigModel newConfig,
  ) async {
    final existingConfig = await findByPlantaId(plantaId);

    if (existingConfig != null) {
      return await _updateExistingPlantConfig(existingConfig, newConfig);
    } else {
      return await _createNewPlantConfig(plantaId, newConfig);
    }
  }

  /// Submétodo para atualizar configuração existente
  Future<Result<PlantaConfigModel>> _updateExistingPlantConfig(
    PlantaConfigModel existingConfig,
    PlantaConfigModel newConfig,
  ) async {
    final configValidada = _validateConfigUpdate(existingConfig, newConfig);

    if (configValidada.isError) {
      return Result.error(configValidada.error!);
    }

    return await update(existingConfig.id, configValidada.value);
  }

  /// Submétodo para criar nova configuração
  Future<Result<PlantaConfigModel>> _createNewPlantConfig(
    String plantaId,
    PlantaConfigModel newConfig,
  ) async {
    final configValidada = _validateConfigCreation(plantaId, newConfig);

    if (configValidada.isError) {
      return Result.error(configValidada.error!);
    }

    return await create(configValidada.value);
  }

  /// Submétodo para validar atualização de configuração
  Result<PlantaConfigModel> _validateConfigUpdate(
    PlantaConfigModel existingConfig,
    PlantaConfigModel newConfig,
  ) {
    return PlantaConfigModelFactory.instance.update(
      existingConfig,
      aguaAtiva: newConfig.aguaAtiva,
      intervaloRegaDias: newConfig.intervaloRegaDias,
      aduboAtivo: newConfig.aduboAtivo,
      intervaloAdubacaoDias: newConfig.intervaloAdubacaoDias,
      banhoSolAtivo: newConfig.banhoSolAtivo,
      intervaloBanhoSolDias: newConfig.intervaloBanhoSolDias,
      inspecaoPragasAtiva: newConfig.inspecaoPragasAtiva,
      intervaloInspecaoPragasDias: newConfig.intervaloInspecaoPragasDias,
      podaAtiva: newConfig.podaAtiva,
      intervaloPodaDias: newConfig.intervaloPodaDias,
      replantarAtivo: newConfig.replantarAtivo,
      intervaloReplantarDias: newConfig.intervaloReplantarDias,
    );
  }

  /// Submétodo para validar criação de configuração
  Result<PlantaConfigModel> _validateConfigCreation(
    String plantaId,
    PlantaConfigModel newConfig,
  ) {
    return PlantaConfigModelFactory.instance.create(
      plantaId: plantaId,
      aguaAtiva: newConfig.aguaAtiva,
      intervaloRegaDias: newConfig.intervaloRegaDias,
      aduboAtivo: newConfig.aduboAtivo,
      intervaloAdubacaoDias: newConfig.intervaloAdubacaoDias,
      banhoSolAtivo: newConfig.banhoSolAtivo,
      intervaloBanhoSolDias: newConfig.intervaloBanhoSolDias,
      inspecaoPragasAtiva: newConfig.inspecaoPragasAtiva,
      intervaloInspecaoPragasDias: newConfig.intervaloInspecaoPragasDias,
      podaAtiva: newConfig.podaAtiva,
      intervaloPodaDias: newConfig.intervaloPodaDias,
      replantarAtivo: newConfig.replantarAtivo,
      intervaloReplantarDias: newConfig.intervaloReplantarDias,
    );
  }

  /// Atualiza configuração de uma planta (método legacy)
  Future<PlantaConfigModel> updatePlantConfigLegacy(
    String plantaId,
    PlantaConfigModel newConfig,
  ) async {
    final existingConfig = await findByPlantaId(plantaId);

    if (existingConfig != null) {
      final updatedConfig = newConfig.copyWith(
        id: existingConfig.id,
        createdAt: existingConfig.createdAt,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      return updateLegacy(existingConfig.id, updatedConfig);
    } else {
      return createLegacy(newConfig);
    }
  }

  /// Obtém intervalo para um tipo de cuidado específico
  Future<int?> getIntervalForCareType(
      String plantaId, String tipoCuidado) async {
    final config = await findByPlantaId(plantaId);
    return config?.getIntervalForCareType(tipoCuidado);
  }

  /// Verifica se um tipo de cuidado está ativo para uma planta
  Future<bool> isCareTypeActive(String plantaId, String tipoCuidado) async {
    final config = await findByPlantaId(plantaId);
    return config?.isCareTypeActive(tipoCuidado) ?? false;
  }

  /// Obtém todos os tipos de cuidado ativos para uma planta
  Future<List<String>> getActiveCareTypes(String plantaId) async {
    final config = await findByPlantaId(plantaId);
    return config?.activeCareTypes ?? [];
  }

  /// Desativa todos os cuidados de uma planta
  Future<void> deactivateAllCare(String plantaId) async {
    final config = await findByPlantaId(plantaId);
    if (config != null) {
      final updated = config.copyWith(
        aguaAtiva: false,
        aduboAtivo: false,
        banhoSolAtivo: false,
        inspecaoPragasAtiva: false,
        podaAtiva: false,
        replantarAtivo: false,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await update(config.id, updated);
    }
  }

  /// Ativa um tipo específico de cuidado com validação (usando Strategy pattern)
  @override
  Future<Result<void>> activateCareType(String plantaId, String tipoCuidado,
      {int? intervalo}) async {
    final config = await findByPlantaId(plantaId);
    if (config == null) {
      return Result.error(
          const InvalidReferenceError('plantaId', 'PlantaConfig'));
    }

    // Usar Command pattern com Strategy pattern
    final command = ActivateCareTypeCommand(
      config: config,
      careType: tipoCuidado,
      activate: true,
      customInterval: intervalo,
    );

    final commandResult = await CommandExecutor.execute(command);
    if (commandResult.isError) {
      return Result.error(commandResult.error!);
    }

    final updateResult = await update(config.id, commandResult.value);
    if (updateResult.isError) {
      return Result.error(updateResult.error!);
    }

    return Result.success(null);
  }

  /// Ativa um tipo específico de cuidado (método legacy)
  Future<void> activateCareTypeLegacy(
      String plantaId, String tipoCuidado) async {
    final config = await findByPlantaId(plantaId);
    if (config == null) return;

    final updatedConfig = _applyCareTypeActivation(config, tipoCuidado);
    if (updatedConfig != null) {
      final finalConfig = _addTimestampToConfig(updatedConfig);
      await updateLegacy(config.id, finalConfig);
    }
  }

  /// Submétodo para aplicar ativação de tipo de cuidado
  PlantaConfigModel? _applyCareTypeActivation(
    PlantaConfigModel config,
    String tipoCuidado,
  ) {
    switch (tipoCuidado) {
      case 'agua':
        return config.copyWith(aguaAtiva: true);
      case 'adubo':
        return config.copyWith(aduboAtivo: true);
      case 'banho_sol':
        return config.copyWith(banhoSolAtivo: true);
      case 'inspecao_pragas':
        return config.copyWith(inspecaoPragasAtiva: true);
      case 'poda':
        return config.copyWith(podaAtiva: true);
      case 'replantar':
        return config.copyWith(replantarAtivo: true);
      default:
        return null;
    }
  }

  /// Submétodo para adicionar timestamp à configuração
  PlantaConfigModel _addTimestampToConfig(PlantaConfigModel config) {
    return config.copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch);
  }

  /// Desativa um tipo específico de cuidado com validação (usando Strategy pattern)
  @override
  Future<Result<void>> deactivateCareType(
      String plantaId, String tipoCuidado) async {
    final config = await findByPlantaId(plantaId);
    if (config == null) {
      return Result.error(
          const InvalidReferenceError('plantaId', 'PlantaConfig'));
    }

    // Usar Command pattern com Strategy pattern
    final command = ActivateCareTypeCommand(
      config: config,
      careType: tipoCuidado,
      activate: false,
    );

    final commandResult = await CommandExecutor.execute(command);
    if (commandResult.isError) {
      return Result.error(commandResult.error!);
    }

    final updateResult = await update(config.id, commandResult.value);
    if (updateResult.isError) {
      return Result.error(updateResult.error!);
    }

    return Result.success(null);
  }

  /// Desativa um tipo específico de cuidado (método legacy)
  Future<void> deactivateCareTypeLegacy(
      String plantaId, String tipoCuidado) async {
    final config = await findByPlantaId(plantaId);
    if (config != null) {
      final updatedConfig = _applyCareTypeDeactivation(config, tipoCuidado);
      if (updatedConfig != null) {
        final finalConfig = _addTimestampToConfig(updatedConfig);
        await updateLegacy(config.id, finalConfig);
      }
    }
  }

  /// Submétodo para aplicar desativação de tipo de cuidado
  PlantaConfigModel? _applyCareTypeDeactivation(
    PlantaConfigModel config,
    String tipoCuidado,
  ) {
    switch (tipoCuidado) {
      case 'agua':
        return config.copyWith(aguaAtiva: false);
      case 'adubo':
        return config.copyWith(aduboAtivo: false);
      case 'banho_sol':
        return config.copyWith(banhoSolAtivo: false);
      case 'inspecao_pragas':
        return config.copyWith(inspecaoPragasAtiva: false);
      case 'poda':
        return config.copyWith(podaAtiva: false);
      case 'replantar':
        return config.copyWith(replantarAtivo: false);
      default:
        return null;
    }
  }

  /// Atualiza intervalo de um tipo específico de cuidado com validação (usando Strategy pattern)
  @override
  Future<Result<void>> updateCareInterval(
      String plantaId, String tipoCuidado, int intervaloDias) async {
    final config = await findByPlantaId(plantaId);
    if (config == null) {
      return Result.error(
          const InvalidReferenceError('plantaId', 'PlantaConfig'));
    }

    // Usar Command pattern com Strategy pattern
    final command = UpdateCareIntervalCommand(
      config: config,
      careType: tipoCuidado,
      newInterval: intervaloDias,
    );

    final commandResult = await CommandExecutor.execute(command);
    if (commandResult.isError) {
      return Result.error(commandResult.error!);
    }

    final updateResult = await update(config.id, commandResult.value);
    if (updateResult.isError) {
      return Result.error(updateResult.error!);
    }

    return Result.success(null);
  }

  /// Atualiza intervalo de um tipo específico de cuidado (método legacy)
  Future<void> updateCareIntervalLegacy(
      String plantaId, String tipoCuidado, int intervaloDias) async {
    final config = await findByPlantaId(plantaId);
    if (config != null) {
      final updated = _applyIntervalUpdate(config, tipoCuidado, intervaloDias);
      if (updated != null) {
        final finalConfig = _addTimestampToConfig(updated);
        await updateLegacy(config.id, finalConfig);
      }
    }
  }

  /// Submétodo para aplicar atualização de intervalo
  PlantaConfigModel? _applyIntervalUpdate(
    PlantaConfigModel config,
    String tipoCuidado,
    int intervaloDias,
  ) {
    switch (tipoCuidado) {
      case 'agua':
        return config.copyWith(intervaloRegaDias: intervaloDias);
      case 'adubo':
        return config.copyWith(intervaloAdubacaoDias: intervaloDias);
      case 'banho_sol':
        return config.copyWith(intervaloBanhoSolDias: intervaloDias);
      case 'inspecao_pragas':
        return config.copyWith(intervaloInspecaoPragasDias: intervaloDias);
      case 'poda':
        return config.copyWith(intervaloPodaDias: intervaloDias);
      case 'replantar':
        return config.copyWith(intervaloReplantarDias: intervaloDias);
      default:
        return null;
    }
  }

  /// Operação de cuidado usando parameter object (simplifica múltiplos parâmetros)
  Future<Result<void>> executeCareOperationWithParams(
      CareOperationParameters params) async {
    // Validar planta se solicitado
    if (params.validatePlantaExists) {
      final planta = await PlantaRepository.instance.findById(params.plantaId);
      if (planta == null) {
        return Result.error(const InvalidReferenceError('plantaId', 'Planta'));
      }
    }

    // Determinar operação baseada nos parâmetros
    if (params.activate != null) {
      // Ativar ou desativar cuidado
      return params.activate!
          ? await activateCareType(params.plantaId, params.careType,
              intervalo: params.interval)
          : await deactivateCareType(params.plantaId, params.careType);
    } else if (params.interval != null) {
      // Atualizar intervalo
      return await updateCareInterval(
          params.plantaId, params.careType, params.interval!);
    } else {
      return Result.error(const InvalidFormatError(
        'operation',
        'Nenhuma operação especificada - deve fornecer activate ou interval',
      ));
    }
  }

  /// Ativar múltiplos tipos de cuidado em batch
  Future<List<Result<void>>> activateMultipleCareTypesWithResults({
    required String plantaId,
    required List<String> careTypes,
    Map<String, int>? customIntervals,
    bool validatePlantaExists = true,
  }) async {
    final results = <Result<void>>[];

    for (final careType in careTypes) {
      final params = CareOperationParameters.activate(
        plantaId: plantaId,
        careType: careType,
        customInterval: customIntervals?[careType],
        validatePlantaExists:
            validatePlantaExists && results.isEmpty, // Validar apenas uma vez
      );

      final result = await executeCareOperationWithParams(params);
      results.add(result);

      // Parar se houver erro
      if (result.isError) break;
    }

    return results;
  }

  /// Configurar planta com múltiplos cuidados usando parameter objects
  Future<Result<PlantaConfigModel>> setupPlantCareWithResult({
    required String plantaId,
    bool aguaAtiva = true,
    int? intervaloRegaDias,
    bool aduboAtivo = false,
    int? intervaloAdubacaoDias,
    bool banhoSolAtivo = false,
    int? intervaloBanhoSolDias,
    bool inspecaoPragasAtiva = false,
    int? intervaloInspecaoPragasDias,
    bool podaAtiva = false,
    int? intervaloPodaDias,
    bool replantarAtivo = false,
    int? intervaloReplantarDias,
  }) async {
    final configValidada = _buildPlantCareConfig(
      plantaId: plantaId,
      aguaAtiva: aguaAtiva,
      intervaloRegaDias: intervaloRegaDias,
      aduboAtivo: aduboAtivo,
      intervaloAdubacaoDias: intervaloAdubacaoDias,
      banhoSolAtivo: banhoSolAtivo,
      intervaloBanhoSolDias: intervaloBanhoSolDias,
      inspecaoPragasAtiva: inspecaoPragasAtiva,
      intervaloInspecaoPragasDias: intervaloInspecaoPragasDias,
      podaAtiva: podaAtiva,
      intervaloPodaDias: intervaloPodaDias,
      replantarAtivo: replantarAtivo,
      intervaloReplantarDias: intervaloReplantarDias,
    );

    if (configValidada.isError) {
      return Result.error(configValidada.error!);
    }

    return await create(configValidada.value);
  }

  /// Submétodo para construir configuração de cuidados
  Result<PlantaConfigModel> _buildPlantCareConfig({
    required String plantaId,
    required bool aguaAtiva,
    required int? intervaloRegaDias,
    required bool aduboAtivo,
    required int? intervaloAdubacaoDias,
    required bool banhoSolAtivo,
    required int? intervaloBanhoSolDias,
    required bool inspecaoPragasAtiva,
    required int? intervaloInspecaoPragasDias,
    required bool podaAtiva,
    required int? intervaloPodaDias,
    required bool replantarAtivo,
    required int? intervaloReplantarDias,
  }) {
    return PlantaConfigModelFactory.instance.create(
      plantaId: plantaId,
      aguaAtiva: aguaAtiva,
      intervaloRegaDias:
          intervaloRegaDias ?? WaterCareHandler().defaultInterval,
      aduboAtivo: aduboAtivo,
      intervaloAdubacaoDias:
          intervaloAdubacaoDias ?? FertilizerCareHandler().defaultInterval,
      banhoSolAtivo: banhoSolAtivo,
      intervaloBanhoSolDias:
          intervaloBanhoSolDias ?? SunBathCareHandler().defaultInterval,
      inspecaoPragasAtiva: inspecaoPragasAtiva,
      intervaloInspecaoPragasDias: intervaloInspecaoPragasDias ??
          PestInspectionCareHandler().defaultInterval,
      podaAtiva: podaAtiva,
      intervaloPodaDias:
          intervaloPodaDias ?? PruningCareHandler().defaultInterval,
      replantarAtivo: replantarAtivo,
      intervaloReplantarDias:
          intervaloReplantarDias ?? ReplantingCareHandler().defaultInterval,
    );
  }

  /// Obtém estatísticas das configurações
  Future<Map<String, dynamic>> getConfigStatistics() async {
    final configs = await findAll();

    return {
      'total': configs.length,
      'aguaAtiva': configs.where((c) => c.aguaAtiva).length,
      'aduboAtivo': configs.where((c) => c.aduboAtivo).length,
      'banhoSolAtivo': configs.where((c) => c.banhoSolAtivo).length,
      'inspecaoPragasAtiva': configs.where((c) => c.inspecaoPragasAtiva).length,
      'podaAtiva': configs.where((c) => c.podaAtiva).length,
      'replantarAtivo': configs.where((c) => c.replantarAtivo).length,
    };
  }

  /// Stream para observar mudanças nas configurações de uma planta
  /// TODO: Implementar quando streams estiverem disponíveis no SyncFirebaseService
  // Stream<PlantaConfigModel?> watchByPlantaId(String plantaId) {
  //   return watchAll().map((configs) {
  //     try {
  //       return configs.firstWhere((config) => config.plantaId == plantaId);
  //     } catch (e) {
  //       return null;
  //     }
  //   });
  // }

  /// Stream para observar configurações ativas
  /// TODO: Implementar quando streams estiverem disponíveis no SyncFirebaseService
  // Stream<List<PlantaConfigModel>> watchActiveConfigs() {
  //   return watchAll().map((configs) => configs.where((config) =>
  //     config.aguaAtiva ||
  //     config.aduboAtivo ||
  //     config.banhoSolAtivo ||
  //     config.inspecaoPragasAtiva ||
  //     config.podaAtiva ||
  //     config.replantarAtivo
  //   ).toList());
  // }

  /// Criar nova configuração
  @override
  Future<String> criar(PlantaConfigModel config) async {
    return await _syncService.create(config);
  }

  /// Criar configuração padrão para planta
  @override
  Future<String> criarPadrao(String plantaId) async {
    // Criar configuração padrão simples
    final config = PlantaConfigModel(
      id: '', // Será gerado automaticamente
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      plantaId: plantaId,
      aguaAtiva: false,
      aduboAtivo: false,
      banhoSolAtivo: false,
      inspecaoPragasAtiva: false,
      podaAtiva: false,
      replantarAtivo: false,
      intervaloRegaDias: 7,
      intervaloAdubacaoDias: 30,
      intervaloBanhoSolDias: 3,
      intervaloInspecaoPragasDias: 14,
      intervaloPodaDias: 60,
      intervaloReplantarDias: 365,
    );
    return await _syncService.create(config);
  }

  /// Atualizar configuração existente
  @override
  Future<void> atualizar(PlantaConfigModel config) async {
    await _syncService.update(config.id, config);
  }

  /// Buscar múltiplas configurações por IDs de plantas
  @override
  Future<List<PlantaConfigModel>> findByPlantaIds(List<String> plantaIds) async {
    final allConfigs = await findAll();
    return allConfigs.where((config) => plantaIds.contains(config.plantaId)).toList();
  }

  /// Remover configuração
  @override
  Future<void> remover(String id) async {
    await _syncService.delete(id);
  }

  /// Remover configuração por planta
  @override
  Future<void> removerPorPlanta(String plantaId) async {
    final config = await findByPlantaId(plantaId);
    if (config != null) {
      await _syncService.delete(config.id);
    }
  }

  /// Streams (para compatibilidade com interface)
  @override
  Stream<List<PlantaConfigModel>> get dataStream => 
      _syncService.dataStream ?? const Stream.empty();

  @override
  Stream<List<PlantaConfigModel>> watchActiveConfigs() =>
      dataStream.map((configs) => configs.where((config) => 
        config.aguaAtiva || config.aduboAtivo || config.banhoSolAtivo || 
        config.inspecaoPragasAtiva || config.podaAtiva || config.replantarAtivo
      ).toList());

  @override
  Stream<PlantaConfigModel?> watchByPlantaId(String plantaId) =>
      dataStream.map((configs) => configs.where((c) => c.plantaId == plantaId).firstOrNull);

  /// Wrapper para executeCareOperation compatível com interface
  @override
  Future<void> executeCareOperation(String plantaId, String careType, bool activate, [int? intervalDays]) async {
    final params = CareOperationParameters(
      plantaId: plantaId,
      careType: careType,
      activate: activate,
      interval: intervalDays,
      validatePlantaExists: true,
    );
    
    final result = await executeCareOperationWithParams(params);
    if (result.isError) {
      throw Exception(result.error.toString());
    }
  }

  /// Wrapper para activateMultipleCareTypes compatível com interface
  @override
  Future<void> activateMultipleCareTypes(String plantaId, Map<String, int> careTypesAndIntervals) async {
    final careTypes = careTypesAndIntervals.keys.toList();
    
    final results = await activateMultipleCareTypesWithResults(
      plantaId: plantaId,
      careTypes: careTypes,
      customIntervals: careTypesAndIntervals,
      validatePlantaExists: true,
    );
    
    // Verificar se algum resultado teve erro
    for (final result in results) {
      if (result.isError) {
        throw Exception(result.error.toString());
      }
    }
  }

  /// Wrapper para setupPlantCare compatível com interface
  @override
  Future<void> setupPlantCare(String plantaId, Map<String, dynamic> careConfig) async {
    final result = await setupPlantCareWithResult(
      plantaId: plantaId,
      aguaAtiva: careConfig['aguaAtiva'] as bool? ?? false,
      aduboAtivo: careConfig['aduboAtivo'] as bool? ?? false,
      banhoSolAtivo: careConfig['banhoSolAtivo'] as bool? ?? false,
      inspecaoPragasAtiva: careConfig['inspecaoPragasAtiva'] as bool? ?? false,
      podaAtiva: careConfig['podaAtiva'] as bool? ?? false,
      replantarAtivo: careConfig['replantarAtivo'] as bool? ?? false,
      intervaloRegaDias: careConfig['intervaloRegaDias'] as int?,
      intervaloAdubacaoDias: careConfig['intervaloAdubacaoDias'] as int?,
      intervaloBanhoSolDias: careConfig['intervaloBanhoSolDias'] as int?,
      intervaloInspecaoPragasDias: careConfig['intervaloInspecaoPragasDias'] as int?,
      intervaloPodaDias: careConfig['intervaloPodaDias'] as int?,
      intervaloReplantarDias: careConfig['intervaloReplantarDias'] as int?,
    );
    
    if (result.isError) {
      throw Exception(result.error.toString());
    }
  }


  Future<List<Result<void>>> activateMultipleCareTypesInternalOld({
    required String plantaId,
    required List<String> careTypes,
    Map<String, int>? customIntervals,
    bool validatePlantaExists = true,
  }) async {
    // Implementação original
    final results = <Result<void>>[];
    
    for (final careType in careTypes) {
      final intervalDays = customIntervals?[careType];
      final params = CareOperationParameters(
        plantaId: plantaId,
        careType: careType,
        activate: true,
        interval: intervalDays,
        validatePlantaExists: validatePlantaExists,
      );
      
      final result = await executeCareOperationWithParams(params);
      results.add(result);
    }
    
    return results;
  }

  Future<Result<PlantaConfigModel>> setupPlantCareInternalOld({
    required String plantaId,
    bool aguaAtiva = false,
    bool aduboAtivo = false,
    bool banhoSolAtivo = false,
    bool inspecaoPragasAtiva = false,
    bool podaAtiva = false,
    bool replantarAtivo = false,
    int? intervaloRegaDias,
    int? intervaloAdubacaoDias,
    int? intervaloBanhoSolDias,
    int? intervaloInspecaoPragasDias,
    int? intervaloPodaDias,
    int? intervaloReplantarDias,
  }) async {
    // Implementação simplificada - criar ou atualizar configuração
    try {
      var config = await findByPlantaId(plantaId);
      
      if (config == null) {
        // Criar nova configuração
        final newConfig = PlantaConfigModel(
          id: '',
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          plantaId: plantaId,
          aguaAtiva: aguaAtiva,
          aduboAtivo: aduboAtivo,
          banhoSolAtivo: banhoSolAtivo,
          inspecaoPragasAtiva: inspecaoPragasAtiva,
          podaAtiva: podaAtiva,
          replantarAtivo: replantarAtivo,
          intervaloRegaDias: intervaloRegaDias ?? 7,
          intervaloAdubacaoDias: intervaloAdubacaoDias ?? 30,
          intervaloBanhoSolDias: intervaloBanhoSolDias ?? 3,
          intervaloInspecaoPragasDias: intervaloInspecaoPragasDias ?? 14,
          intervaloPodaDias: intervaloPodaDias ?? 60,
          intervaloReplantarDias: intervaloReplantarDias ?? 365,
        );
        
        final id = await criar(newConfig);
        config = await findById(id);
      } else {
        // Atualizar configuração existente
        final updatedConfig = config.copyWith(
          aguaAtiva: aguaAtiva,
          aduboAtivo: aduboAtivo,
          banhoSolAtivo: banhoSolAtivo,
          inspecaoPragasAtiva: inspecaoPragasAtiva,
          podaAtiva: podaAtiva,
          replantarAtivo: replantarAtivo,
          intervaloRegaDias: intervaloRegaDias ?? config.intervaloRegaDias,
          intervaloAdubacaoDias: intervaloAdubacaoDias ?? config.intervaloAdubacaoDias,
          intervaloBanhoSolDias: intervaloBanhoSolDias ?? config.intervaloBanhoSolDias,
          intervaloInspecaoPragasDias: intervaloInspecaoPragasDias ?? config.intervaloInspecaoPragasDias,
          intervaloPodaDias: intervaloPodaDias ?? config.intervaloPodaDias,
          intervaloReplantarDias: intervaloReplantarDias ?? config.intervaloReplantarDias,
        );
        
        await atualizar(updatedConfig);
        config = updatedConfig;
      }
      
      return Result.success(config!);
    } catch (e) {
      return Result.error(InvalidStateError('setupPlantCare', 'Erro: $e'));
    }
  }

  /// Limpar recursos (incluindo cache e operações de cleanup)
  @override
  Future<void> dispose() async {
    // PlantaConfigRepository não usa streams atualmente, mas pode ter cache
    // Limpar cache se houver implementação futura
    // Método implementado para consistência com outros repositories
  }
}
