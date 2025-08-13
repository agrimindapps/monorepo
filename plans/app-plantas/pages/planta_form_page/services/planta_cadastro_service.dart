// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../database/espaco_model.dart';
import '../../../database/planta_config_model.dart';
import '../../../database/planta_model.dart';
import '../../../repository/planta_config_repository.dart';
import '../../../services/domain/plants/plant_care_service.dart';
import 'loading_state_service.dart';
import 'planta_validation_service.dart';
import 'task_creation_service.dart';

/// Service principal para orquestrar todo o processo de cadastro de plantas
/// Coordena validação, salvamento e criação de tarefas seguindo SOLID
class PlantaCadastroService {
  // Singleton pattern para otimização
  static PlantaCadastroService? _instance;
  static PlantaCadastroService get instance =>
      _instance ??= PlantaCadastroService._();
  PlantaCadastroService._();

  // Services especializados
  final _validationService = PlantaValidationService.instance;
  final _taskCreationService = TaskCreationService.instance;
  final _loadingService = LoadingStateService.instance;

  // ========== ORQUESTRAÇÃO PRINCIPAL ==========

  /// Executa todo o processo de cadastro de forma orquestrada
  Future<PlantaCadastroResult> cadastrarPlanta({
    required PlantaData plantaData,
    required PlantCareConfiguration careConfig,
  }) async {
    debugPrint(
        '🌱 PlantaCadastroService: Iniciando processo de cadastro completo');

    return await _loadingService.executeWithLoading(
      LoadingOperation.savingPlant,
      () async => await _executeCadastroProcess(plantaData, careConfig),
      loadingMessage: 'Cadastrando planta...',
      successMessage: 'Planta "${plantaData.nome}" cadastrada com sucesso!',
    );
  }

  /// Execução interna do processo de cadastro
  Future<PlantaCadastroResult> _executeCadastroProcess(
    PlantaData plantaData,
    PlantCareConfiguration careConfig,
  ) async {
    final steps = <String>[];
    final warnings = <String>[];

    try {
      // FASE 1: Validação (10%)
      _loadingService.updateProgress(LoadingOperation.savingPlant, 0.1,
          message: 'Validando dados...');

      final validationResult = await _validateData(plantaData, careConfig);
      if (!validationResult.isValid) {
        throw PlantaCadastroException(
          'Dados inválidos: ${validationResult.errors.join(', ')}',
          type: PlantaCadastroErrorType.validation,
        );
      }
      warnings.addAll(validationResult.warnings);
      steps.add('Dados validados com sucesso');

      // FASE 2: Inicialização de serviços (20%)
      _loadingService.updateProgress(LoadingOperation.savingPlant, 0.2,
          message: 'Inicializando serviços...');

      await _initializeServices();
      steps.add('Serviços inicializados');

      // FASE 3: Criação da planta (40%)
      _loadingService.updateProgress(LoadingOperation.savingPlant, 0.4,
          message: 'Salvando planta "${plantaData.nome}"...');

      final plantaSalva = await _createPlant(plantaData);
      steps.add('Planta salva com ID: ${plantaSalva.id}');

      // FASE 4: Salvamento de configurações (60%)
      _loadingService.updateProgress(LoadingOperation.savingPlant, 0.6,
          message: 'Configurando cuidados...');

      await _saveConfiguration(plantaSalva.id, careConfig);
      steps.add('Configurações de cuidados salvas');

      // FASE 5: Criação de tarefas (80%)
      _loadingService.updateProgress(LoadingOperation.savingPlant, 0.8,
          message: 'Criando cronograma de cuidados...');

      final taskResult = await _taskCreationService.createInitialTasksForPlant(
        plantaId: plantaSalva.id,
        config: careConfig,
      );

      if (!taskResult.success) {
        warnings.addAll(taskResult.errors.map((e) => 'Tarefas: $e'));
      }
      steps.add(
          'Cronograma criado: ${taskResult.createdTaskTypes.length} tipos de cuidado');

      // FASE 6: Finalização (100%)
      _loadingService.updateProgress(LoadingOperation.savingPlant, 1.0,
          message: 'Finalizando...');

      steps.add('Cadastro finalizado com sucesso');

      debugPrint('✅ PlantaCadastroService: Cadastro concluído com sucesso!');

      return PlantaCadastroResult(
        success: true,
        plantaSalva: plantaSalva,
        steps: steps,
        warnings: warnings,
        taskCreated: taskResult.success,
        taskSummary: taskResult.summary,
      );
    } catch (e) {
      debugPrint('❌ PlantaCadastroService: Erro durante cadastro: $e');

      if (e is PlantaCadastroException) {
        rethrow;
      }

      throw PlantaCadastroException(
        'Erro inesperado durante cadastro: $e',
        type: PlantaCadastroErrorType.unknown,
        originalError: e,
      );
    }
  }

  // ========== FASES DO PROCESSO ==========

  /// Valida todos os dados necessários
  Future<FormValidationResult> _validateData(
    PlantaData plantaData,
    PlantCareConfiguration careConfig,
  ) async {
    return _validationService.validateCompleteForm(
      nome: plantaData.nome,
      especie: plantaData.especie,
      observacoes: plantaData.observacoes,
      imageBase64: plantaData.fotoBase64,
      aguaAtiva: careConfig.aguaAtiva,
      intervaloRegaDias: careConfig.intervaloRegaDias,
      primeiraRega: careConfig.primeiraRega,
      aduboAtivo: careConfig.aduboAtivo,
      intervaloAdubacaoDias: careConfig.intervaloAdubacaoDias,
      primeiraAdubacao: careConfig.primeiraAdubacao,
      banhoSolAtivo: careConfig.banhoSolAtivo,
      intervaloBanhoSolDias: careConfig.intervaloBanhoSolDias,
      primeiroBanhoSol: careConfig.primeiroBanhoSol,
      inspecaoPragasAtiva: careConfig.inspecaoPragasAtiva,
      intervaloInspecaoPragasDias: careConfig.intervaloInspecaoPragasDias,
      primeiraInspecaoPragas: careConfig.primeiraInspecaoPragas,
      podaAtiva: careConfig.podaAtiva,
      intervaloPodaDias: careConfig.intervaloPodaDias,
      primeiraPoda: careConfig.primeiraPoda,
      replantarAtivo: careConfig.replantarAtivo,
      intervaloReplantarDias: careConfig.intervaloReplantarDias,
      primeiroReplantar: careConfig.primeiroReplantar,
    );
  }

  /// Inicializa todos os serviços necessários
  Future<void> _initializeServices() async {
    await PlantCareService.instance.initialize();
    debugPrint('✅ PlantaCadastroService: Serviços inicializados');
  }

  /// Cria e salva a planta
  Future<PlantaModel> _createPlant(PlantaData plantaData) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final planta = PlantaModel(
      id: '',
      createdAt: now,
      updatedAt: now,
      nome: plantaData.nome.trim(),
      especie: plantaData.especie?.trim(),
      espacoId: plantaData.espacoId,
      observacoes: plantaData.observacoes?.trim(),
      imagePaths: plantaData.imagePaths,
      fotoBase64: plantaData.fotoBase64,
    );

    final plantaId = await PlantCareService.instance.createPlant(planta);
    final plantaSalva = planta.copyWith(id: plantaId);

    debugPrint('✅ PlantaCadastroService: Planta salva com ID: $plantaId');
    return plantaSalva;
  }

  /// Salva as configurações de cuidados
  Future<void> _saveConfiguration(
      String plantaId, PlantCareConfiguration careConfig) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final plantaConfig = PlantaConfigModel(
      id: '',
      createdAt: now,
      updatedAt: now,
      plantaId: plantaId,
      aguaAtiva: careConfig.aguaAtiva,
      intervaloRegaDias: careConfig.intervaloRegaDias,
      aduboAtivo: careConfig.aduboAtivo,
      intervaloAdubacaoDias: careConfig.intervaloAdubacaoDias,
      banhoSolAtivo: careConfig.banhoSolAtivo,
      intervaloBanhoSolDias: careConfig.intervaloBanhoSolDias,
      inspecaoPragasAtiva: careConfig.inspecaoPragasAtiva,
      intervaloInspecaoPragasDias: careConfig.intervaloInspecaoPragasDias,
      podaAtiva: careConfig.podaAtiva,
      intervaloPodaDias: careConfig.intervaloPodaDias,
      replantarAtivo: careConfig.replantarAtivo,
      intervaloReplantarDias: careConfig.intervaloReplantarDias,
    );

    final configRepository = PlantaConfigRepository.instance;
    await configRepository.initialize();
    await configRepository.create(plantaConfig);

    debugPrint('✅ PlantaCadastroService: Configurações salvas');
  }

  // ========== OPERAÇÕES AUXILIARES ==========

  /// Carrega lista de espaços disponíveis
  Future<List<EspacoModel>> carregarEspacosDisponiveis() async {
    try {
      await PlantCareService.instance.initialize();
      final espacos = await PlantCareService.instance.getAllSpaces();
      debugPrint(
          '✅ PlantaCadastroService: ${espacos.length} espaços carregados');
      return espacos;
    } catch (e) {
      debugPrint('❌ PlantaCadastroService: Erro ao carregar espaços: $e');
      throw PlantaCadastroException(
        'Erro ao carregar espaços disponíveis: $e',
        type: PlantaCadastroErrorType.spaceLoading,
        originalError: e,
      );
    }
  }

  /// Cria um novo espaço personalizado
  Future<EspacoModel> criarEspacoPersonalizado(String nome) async {
    try {
      await PlantCareService.instance.initialize();

      final novoEspaco = EspacoModel(
        id: '',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        nome: nome.trim(),
        descricao: 'Espaço personalizado',
      );

      final espacoId = await PlantCareService.instance.createSpace(novoEspaco);
      final espacoSalvo = novoEspaco.copyWith(id: espacoId);

      debugPrint(
          '✅ PlantaCadastroService: Espaço "$nome" criado com ID: $espacoId');
      return espacoSalvo;
    } catch (e) {
      debugPrint('❌ PlantaCadastroService: Erro ao criar espaço: $e');
      throw PlantaCadastroException(
        'Erro ao criar espaço "$nome": $e',
        type: PlantaCadastroErrorType.spaceCreation,
        originalError: e,
      );
    }
  }

  /// Obtém resumo do cronograma que será criado
  CareScheduleSummary obterResumoChronograma(
      PlantCareConfiguration careConfig) {
    return _taskCreationService.calculateScheduleSummary(careConfig);
  }

  /// Cria configuração padrão para nova planta
  PlantCareConfiguration criarConfiguracaoPadrao() {
    return _taskCreationService.createDefaultConfiguration();
  }
}

// ========== CLASSES DE DADOS ==========

/// Dados básicos da planta para cadastro
class PlantaData {
  final String nome;
  final String? especie;
  final String? espacoId;
  final String? observacoes;
  final List<String> imagePaths;
  final String? fotoBase64;

  PlantaData({
    required this.nome,
    this.especie,
    this.espacoId,
    this.observacoes,
    this.imagePaths = const [],
    this.fotoBase64,
  });
}

/// Resultado completo do processo de cadastro
class PlantaCadastroResult {
  final bool success;
  final PlantaModel? plantaSalva;
  final List<String> steps;
  final List<String> warnings;
  final bool taskCreated;
  final String taskSummary;

  PlantaCadastroResult({
    required this.success,
    this.plantaSalva,
    required this.steps,
    required this.warnings,
    required this.taskCreated,
    required this.taskSummary,
  });

  String get summary {
    if (success && plantaSalva != null) {
      final warningText =
          warnings.isNotEmpty ? ' (${warnings.length} aviso(s))' : '';
      return 'Planta "${plantaSalva!.nome}" cadastrada com sucesso$warningText';
    } else {
      return 'Falha no cadastro';
    }
  }
}

/// Exceção específica para erros de cadastro
class PlantaCadastroException implements Exception {
  final String message;
  final PlantaCadastroErrorType type;
  final dynamic originalError;

  PlantaCadastroException(
    this.message, {
    required this.type,
    this.originalError,
  });

  @override
  String toString() => 'PlantaCadastroException: $message';
}

/// Tipos de erro específicos do cadastro
enum PlantaCadastroErrorType {
  validation,
  spaceLoading,
  spaceCreation,
  plantCreation,
  configSaving,
  taskCreation,
  unknown,
}
