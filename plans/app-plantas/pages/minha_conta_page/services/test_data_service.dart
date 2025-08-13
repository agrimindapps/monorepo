// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../database/comentario_model.dart';
import '../../../database/espaco_model.dart';
import '../../../database/planta_config_model.dart';
import '../../../database/planta_model.dart';
import '../../../repository/espaco_repository.dart';
import '../../../repository/planta_config_repository.dart';
import '../../../repository/planta_repository.dart';
import '../../../services/domain/tasks/simple_task_service.dart';

/// Service especializado para geração de dados de teste
/// Centraliza toda lógica complexa de criação de plantas, espaços e configurações de exemplo
class TestDataService {
  // Singleton pattern
  static TestDataService? _instance;
  static TestDataService get instance => _instance ??= TestDataService._();
  TestDataService._();

  // ========== GERAÇÃO DE DADOS DE TESTE ==========

  /// Gera conjunto completo de dados de teste incluindo espaços, plantas, configurações e tarefas
  Future<TestDataResult> gerarDadosCompletos() async {
    try {
      debugPrint('🧪 TestDataService: Iniciando geração de dados de teste');

      // Inicializar repositórios
      await _initializeRepositories();

      final now = DateTime.now();
      final timestamp = now.millisecondsSinceEpoch;

      // Gerar dados em sequência para manter integridade referencial
      final espacos = await _criarEspacosDeTeste(timestamp, now);
      final plantas = await _criarPlantasDeTeste(timestamp, now);
      final configs = await _criarConfiguracoesDeTeste(timestamp);

      // Gerar tarefas baseadas nas configurações
      await _criarTarefasIniciais(configs, now);

      debugPrint('✅ TestDataService: Dados de teste gerados com sucesso');

      return TestDataResult(
        success: true,
        espacosCount: espacos.length,
        plantasCount: plantas.length,
        configsCount: configs.length,
        message:
            'Dados de teste criados com sucesso!\n• ${espacos.length} espaços\n• ${plantas.length} plantas\n• ${configs.length} configurações\n• Tarefas automáticas geradas',
      );
    } catch (e) {
      debugPrint('❌ TestDataService: Erro ao gerar dados: $e');
      return TestDataResult(
        success: false,
        error: e.toString(),
        message: 'Erro ao gerar dados de teste: $e',
      );
    }
  }

  // ========== MÉTODOS PRIVADOS DE GERAÇÃO ==========

  /// Inicializa todos os repositórios necessários
  Future<void> _initializeRepositories() async {
    final plantaRepo = PlantaRepository.instance;
    final espacoRepo = EspacoRepository.instance;
    final configRepo = PlantaConfigRepository.instance;

    await plantaRepo.initialize();
    await espacoRepo.initialize();
    await configRepo.initialize();
    await SimpleTaskService.instance.initialize();
  }

  /// Cria espaços de teste com variedade de ambientes
  Future<List<EspacoModel>> _criarEspacosDeTeste(
      int timestamp, DateTime now) async {
    final espacoRepo = EspacoRepository.instance;

    final espacos = [
      EspacoModel(
        id: 'espaco_1',
        createdAt: timestamp,
        updatedAt: timestamp,
        nome: 'Sala de Estar',
        descricao: 'Plantas decorativas para ambiente interno',
        ativo: true,
        dataCriacao: now,
      ),
      EspacoModel(
        id: 'espaco_2',
        createdAt: timestamp,
        updatedAt: timestamp,
        nome: 'Varanda',
        descricao: 'Plantas que recebem luz solar direta',
        ativo: true,
        dataCriacao: now,
      ),
      EspacoModel(
        id: 'espaco_3',
        createdAt: timestamp,
        updatedAt: timestamp,
        nome: 'Jardim',
        descricao: 'Área externa para plantas de grande porte',
        ativo: true,
        dataCriacao: now,
      ),
    ];

    // Salvar espaços
    for (final espaco in espacos) {
      await espacoRepo.create(espaco);
    }

    debugPrint('🏠 TestDataService: ${espacos.length} espaços criados');
    return espacos;
  }

  /// Cria plantas de teste com diversidade de espécies e comentários
  Future<List<PlantaModel>> _criarPlantasDeTeste(
      int timestamp, DateTime now) async {
    final plantaRepo = PlantaRepository.instance;

    final plantas = [
      PlantaModel(
        id: 'planta_1',
        createdAt: timestamp,
        updatedAt: timestamp,
        nome: 'Monstera Deliciosa',
        especie: 'Monstera deliciosa',
        espacoId: 'espaco_1',
        imagePaths: [],
        observacoes: 'Planta tropical que gosta de umidade e luz indireta',
        dataCadastro: now,
        comentarios: [
          ComentarioModel(
            id: 'comment_1',
            createdAt: timestamp,
            updatedAt: timestamp,
            conteudo: 'Folhas estão crescendo bem!',
            dataCriacao: now.subtract(const Duration(days: 5)),
          ),
        ],
      ),
      PlantaModel(
        id: 'planta_2',
        createdAt: timestamp,
        updatedAt: timestamp,
        nome: 'Espada de São Jorge',
        especie: 'Sansevieria trifasciata',
        espacoId: 'espaco_1',
        imagePaths: [],
        observacoes: 'Planta resistente, ideal para iniciantes',
        dataCadastro: now,
        comentarios: [
          ComentarioModel(
            id: 'comment_2',
            createdAt: timestamp,
            updatedAt: timestamp,
            conteudo: 'Mudas novas brotando na base',
            dataCriacao: now.subtract(const Duration(days: 2)),
          ),
        ],
      ),
      PlantaModel(
        id: 'planta_3',
        createdAt: timestamp,
        updatedAt: timestamp,
        nome: 'Suculenta Echeveria',
        especie: 'Echeveria elegans',
        espacoId: 'espaco_2',
        imagePaths: [],
        observacoes: 'Precisa de sol direto e pouca água',
        dataCadastro: now,
        comentarios: [],
      ),
      PlantaModel(
        id: 'planta_4',
        createdAt: timestamp,
        updatedAt: timestamp,
        nome: 'Lírio da Paz',
        especie: 'Spathiphyllum wallisii',
        espacoId: 'espaco_1',
        imagePaths: [],
        observacoes: 'Indica quando precisa de água com folhas caídas',
        dataCadastro: now,
        comentarios: [],
      ),
      PlantaModel(
        id: 'planta_5',
        createdAt: timestamp,
        updatedAt: timestamp,
        nome: 'Manjericão',
        especie: 'Ocimum basilicum',
        espacoId: 'espaco_3',
        imagePaths: [],
        observacoes: 'Erva aromática para uso culinário',
        dataCadastro: now,
        comentarios: [
          ComentarioModel(
            id: 'comment_3',
            createdAt: timestamp,
            updatedAt: timestamp,
            conteudo: 'Colheu folhas para tempero',
            dataCriacao: now.subtract(const Duration(days: 1)),
          ),
        ],
      ),
    ];

    // Salvar plantas
    for (final planta in plantas) {
      await plantaRepo.create(planta);
    }

    debugPrint('🌱 TestDataService: ${plantas.length} plantas criadas');
    return plantas;
  }

  /// Cria configurações específicas para cada tipo de planta
  Future<List<PlantaConfigModel>> _criarConfiguracoesDeTeste(
      int timestamp) async {
    final configRepo = PlantaConfigRepository.instance;

    final configs = [
      // Monstera - planta tropical
      PlantaConfigModel(
        id: 'config_1',
        createdAt: timestamp,
        updatedAt: timestamp,
        plantaId: 'planta_1',
        aguaAtiva: true,
        intervaloRegaDias: 3,
        aduboAtivo: true,
        intervaloAdubacaoDias: 15,
        banhoSolAtivo: false,
        intervaloBanhoSolDias: 7,
        inspecaoPragasAtiva: true,
        intervaloInspecaoPragasDias: 7,
        podaAtiva: true,
        intervaloPodaDias: 60,
        replantarAtivo: true,
        intervaloReplantarDias: 365,
      ),
      // Espada de São Jorge - resistente
      PlantaConfigModel(
        id: 'config_2',
        createdAt: timestamp,
        updatedAt: timestamp,
        plantaId: 'planta_2',
        aguaAtiva: true,
        intervaloRegaDias: 7,
        aduboAtivo: true,
        intervaloAdubacaoDias: 30,
        banhoSolAtivo: true,
        intervaloBanhoSolDias: 2,
        inspecaoPragasAtiva: true,
        intervaloInspecaoPragasDias: 14,
        podaAtiva: false,
        intervaloPodaDias: 90,
        replantarAtivo: true,
        intervaloReplantarDias: 730,
      ),
      // Suculenta - pouca água
      PlantaConfigModel(
        id: 'config_3',
        createdAt: timestamp,
        updatedAt: timestamp,
        plantaId: 'planta_3',
        aguaAtiva: true,
        intervaloRegaDias: 10,
        aduboAtivo: true,
        intervaloAdubacaoDias: 45,
        banhoSolAtivo: true,
        intervaloBanhoSolDias: 1,
        inspecaoPragasAtiva: true,
        intervaloInspecaoPragasDias: 21,
        podaAtiva: false,
        intervaloPodaDias: 120,
        replantarAtivo: true,
        intervaloReplantarDias: 540,
      ),
      // Lírio da Paz - umidade
      PlantaConfigModel(
        id: 'config_4',
        createdAt: timestamp,
        updatedAt: timestamp,
        plantaId: 'planta_4',
        aguaAtiva: true,
        intervaloRegaDias: 2,
        aduboAtivo: true,
        intervaloAdubacaoDias: 21,
        banhoSolAtivo: false,
        intervaloBanhoSolDias: 14,
        inspecaoPragasAtiva: true,
        intervaloInspecaoPragasDias: 10,
        podaAtiva: true,
        intervaloPodaDias: 45,
        replantarAtivo: true,
        intervaloReplantarDias: 270,
      ),
      // Manjericão - erva culinária
      PlantaConfigModel(
        id: 'config_5',
        createdAt: timestamp,
        updatedAt: timestamp,
        plantaId: 'planta_5',
        aguaAtiva: true,
        intervaloRegaDias: 1,
        aduboAtivo: true,
        intervaloAdubacaoDias: 14,
        banhoSolAtivo: true,
        intervaloBanhoSolDias: 1,
        inspecaoPragasAtiva: true,
        intervaloInspecaoPragasDias: 5,
        podaAtiva: true,
        intervaloPodaDias: 21,
        replantarAtivo: true,
        intervaloReplantarDias: 180,
      ),
    ];

    // Salvar configurações
    for (final config in configs) {
      await configRepo.create(config);
    }

    debugPrint('⚙️ TestDataService: ${configs.length} configurações criadas');
    return configs;
  }

  /// Cria tarefas iniciais baseadas nas configurações de cada planta
  Future<void> _criarTarefasIniciais(
      List<PlantaConfigModel> configs, DateTime now) async {
    for (final config in configs) {
      final proximaRega = now.add(Duration(days: config.intervaloRegaDias));
      final proximaAdubacao =
          now.add(Duration(days: config.intervaloAdubacaoDias));
      final proximoBanhoSol =
          now.add(Duration(days: config.intervaloBanhoSolDias));
      final proximaInspecao =
          now.add(Duration(days: config.intervaloInspecaoPragasDias));
      final proximaPoda = now.add(Duration(days: config.intervaloPodaDias));
      final proximoReplantio =
          now.add(Duration(days: config.intervaloReplantarDias));

      await SimpleTaskService.instance.createInitialTasksForPlant(
        plantaId: config.plantaId,
        aguaAtiva: config.aguaAtiva,
        intervaloRegaDias: config.intervaloRegaDias,
        primeiraRega: proximaRega,
        aduboAtivo: config.aduboAtivo,
        intervaloAdubacaoDias: config.intervaloAdubacaoDias,
        primeiraAdubacao: proximaAdubacao,
        banhoSolAtivo: config.banhoSolAtivo,
        intervaloBanhoSolDias: config.intervaloBanhoSolDias,
        primeiroBanhoSol: proximoBanhoSol,
        inspecaoPragasAtiva: config.inspecaoPragasAtiva,
        intervaloInspecaoPragasDias: config.intervaloInspecaoPragasDias,
        primeiraInspecaoPragas: proximaInspecao,
        podaAtiva: config.podaAtiva,
        intervaloPodaDias: config.intervaloPodaDias,
        primeiraPoda: proximaPoda,
        replantarAtivo: config.replantarAtivo,
        intervaloReplantarDias: config.intervaloReplantarDias,
        primeiroReplantar: proximoReplantio,
      );
    }

    debugPrint(
        '📋 TestDataService: Tarefas iniciais criadas para ${configs.length} plantas');
  }
}

// ========== CLASSES DE RESULTADO ==========

/// Resultado da geração de dados de teste
class TestDataResult {
  final bool success;
  final int espacosCount;
  final int plantasCount;
  final int configsCount;
  final String message;
  final String? error;

  TestDataResult({
    required this.success,
    this.espacosCount = 0,
    this.plantasCount = 0,
    this.configsCount = 0,
    required this.message,
    this.error,
  });

  bool get hasData => espacosCount > 0 || plantasCount > 0 || configsCount > 0;
}
