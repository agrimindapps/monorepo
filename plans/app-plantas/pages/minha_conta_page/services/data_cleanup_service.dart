// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../repository/espaco_repository.dart';
import '../../../repository/planta_config_repository.dart';
import '../../../repository/planta_repository.dart';
import '../../../services/domain/tasks/simple_task_service.dart';

/// Service especializado para limpeza e gerenciamento de dados
/// Centraliza toda lógica de remoção e cleanup de registros do sistema
class DataCleanupService {
  // Singleton pattern
  static DataCleanupService? _instance;
  static DataCleanupService get instance =>
      _instance ??= DataCleanupService._();
  DataCleanupService._();

  // ========== OPERAÇÕES DE LIMPEZA ==========

  /// Executa limpeza completa de todos os dados com confirmação do usuário
  Future<CleanupResult> limparTodosRegistrosComConfirmacao() async {
    try {
      debugPrint(
          '🧹 DataCleanupService: Iniciando processo de limpeza completa');

      // Mostrar diálogo de confirmação
      final confirmacao = await _mostrarDialogoConfirmacao();

      if (confirmacao != true) {
        debugPrint('🚫 DataCleanupService: Limpeza cancelada pelo usuário');
        return CleanupResult(
          success: false,
          cancelled: true,
          message: 'Operação cancelada pelo usuário',
        );
      }

      // Executar limpeza
      return await _executarLimpezaCompleta();
    } catch (e) {
      debugPrint('❌ DataCleanupService: Erro no processo de limpeza: $e');
      return CleanupResult(
        success: false,
        error: e.toString(),
        message: 'Erro ao limpar registros: $e',
      );
    }
  }

  /// Executa limpeza apenas de dados de teste (identificados por IDs específicos)
  Future<CleanupResult> limparApenasDataosDeTeste() async {
    try {
      debugPrint('🧪 DataCleanupService: Limpando apenas dados de teste');

      await _initializeRepositories();

      // IDs conhecidos de dados de teste
      final testPlantaIds = [
        'planta_1',
        'planta_2',
        'planta_3',
        'planta_4',
        'planta_5'
      ];
      final testEspacoIds = ['espaco_1', 'espaco_2', 'espaco_3'];
      final testConfigIds = [
        'config_1',
        'config_2',
        'config_3',
        'config_4',
        'config_5'
      ];

      int removedCount = 0;

      // Remover plantas de teste
      final plantaRepo = PlantaRepository.instance;
      for (final id in testPlantaIds) {
        try {
          await plantaRepo.delete(id);
          removedCount++;
        } catch (e) {
          debugPrint('⚠️ DataCleanupService: Erro ao remover planta $id: $e');
        }
      }

      // Remover configurações de teste
      final configRepo = PlantaConfigRepository.instance;
      for (final id in testConfigIds) {
        try {
          await configRepo.delete(id);
          removedCount++;
        } catch (e) {
          debugPrint('⚠️ DataCleanupService: Erro ao remover config $id: $e');
        }
      }

      // Remover espaços de teste
      final espacoRepo = EspacoRepository.instance;
      for (final id in testEspacoIds) {
        try {
          await espacoRepo.delete(id);
          removedCount++;
        } catch (e) {
          debugPrint('⚠️ DataCleanupService: Erro ao remover espaço $id: $e');
        }
      }

      // Limpar tarefas relacionadas
      await SimpleTaskService.instance.clearAllTasks();

      debugPrint(
          '✅ DataCleanupService: $removedCount dados de teste removidos');

      return CleanupResult(
        success: true,
        plantasRemovidas: testPlantaIds.length,
        espacosRemovidos: testEspacoIds.length,
        configsRemovidas: testConfigIds.length,
        tarefasRemovidas: 0, // Não contamos tarefas individualmente
        message: 'Dados de teste removidos com sucesso',
      );
    } catch (e) {
      debugPrint('❌ DataCleanupService: Erro ao limpar dados de teste: $e');
      return CleanupResult(
        success: false,
        error: e.toString(),
        message: 'Erro ao limpar dados de teste: $e',
      );
    }
  }

  /// Obtém estatísticas dos dados atuais para exibição
  Future<DataStatistics> obterEstatisticasAtuais() async {
    try {
      await _initializeRepositories();

      final plantaRepo = PlantaRepository.instance;
      final espacoRepo = EspacoRepository.instance;
      final configRepo = PlantaConfigRepository.instance;

      // Buscar todos os registros para contagem
      final plantas = await plantaRepo.findAll();
      final espacos = await espacoRepo.findAll();
      final configs = await configRepo.findAll();
      final tarefasPendentes =
          await SimpleTaskService.instance.getAllPendingTasks();
      final tarefasConcluidas =
          await SimpleTaskService.instance.getCompletedTasks();

      return DataStatistics(
        totalPlantas: plantas.length,
        totalEspacos: espacos.length,
        totalConfigs: configs.length,
        totalTarefasPendentes: tarefasPendentes.length,
        totalTarefasConcluidas: tarefasConcluidas.length,
      );
    } catch (e) {
      debugPrint('❌ DataCleanupService: Erro ao obter estatísticas: $e');
      return DataStatistics();
    }
  }

  // ========== MÉTODOS PRIVADOS ==========

  /// Executa a limpeza completa de todos os dados
  Future<CleanupResult> _executarLimpezaCompleta() async {
    await _initializeRepositories();

    // Obter estatísticas antes da limpeza
    final stats = await obterEstatisticasAtuais();

    // Limpar todas as tarefas primeiro
    await SimpleTaskService.instance.clearAllTasks();

    // Limpar plantas
    final plantaRepo = PlantaRepository.instance;
    final plantas = await plantaRepo.findAll();
    for (final planta in plantas) {
      await plantaRepo.delete(planta.id);
    }

    // Limpar configurações
    final configRepo = PlantaConfigRepository.instance;
    final configs = await configRepo.findAll();
    for (final config in configs) {
      await configRepo.delete(config.id);
    }

    // Limpar espaços
    final espacoRepo = EspacoRepository.instance;
    final espacos = await espacoRepo.findAll();
    for (final espaco in espacos) {
      await espacoRepo.delete(espaco.id);
    }

    final totalTarefas =
        stats.totalTarefasPendentes + stats.totalTarefasConcluidas;

    debugPrint('✅ DataCleanupService: Limpeza completa finalizada');

    return CleanupResult(
      success: true,
      plantasRemovidas: stats.totalPlantas,
      espacosRemovidos: stats.totalEspacos,
      configsRemovidas: stats.totalConfigs,
      tarefasRemovidas: totalTarefas,
      message: 'Todos os dados foram removidos:\n'
          '• ${stats.totalPlantas} plantas\n'
          '• ${stats.totalEspacos} espaços\n'
          '• ${stats.totalConfigs} configurações\n'
          '• $totalTarefas tarefas',
    );
  }

  /// Mostra diálogo de confirmação para limpeza
  Future<bool?> _mostrarDialogoConfirmacao() async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar Limpeza'),
        content: const Text(
          'Esta ação irá remover TODOS os dados do app:\n\n'
          '• Todas as plantas\n'
          '• Todos os espaços\n'
          '• Todas as configurações\n'
          '• Todas as tarefas\n'
          '• Todos os comentários\n\n'
          'Esta ação NÃO pode ser desfeita!',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Limpar Tudo'),
          ),
        ],
      ),
    );
  }

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
}

// ========== CLASSES DE DADOS ==========

/// Resultado de operações de limpeza
class CleanupResult {
  final bool success;
  final bool cancelled;
  final int plantasRemovidas;
  final int espacosRemovidos;
  final int configsRemovidas;
  final int tarefasRemovidas;
  final String message;
  final String? error;

  CleanupResult({
    required this.success,
    this.cancelled = false,
    this.plantasRemovidas = 0,
    this.espacosRemovidos = 0,
    this.configsRemovidas = 0,
    this.tarefasRemovidas = 0,
    required this.message,
    this.error,
  });

  int get totalItensRemovidos =>
      plantasRemovidas + espacosRemovidos + configsRemovidas + tarefasRemovidas;

  bool get hasRemovedItems => totalItensRemovidos > 0;
}

/// Estatísticas dos dados atuais
class DataStatistics {
  final int totalPlantas;
  final int totalEspacos;
  final int totalConfigs;
  final int totalTarefasPendentes;
  final int totalTarefasConcluidas;

  DataStatistics({
    this.totalPlantas = 0,
    this.totalEspacos = 0,
    this.totalConfigs = 0,
    this.totalTarefasPendentes = 0,
    this.totalTarefasConcluidas = 0,
  });

  int get totalTarefas => totalTarefasPendentes + totalTarefasConcluidas;
  int get totalItens =>
      totalPlantas + totalEspacos + totalConfigs + totalTarefas;
  bool get hasData => totalItens > 0;
}
