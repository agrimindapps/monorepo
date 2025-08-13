// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../services/domain/tasks/simple_task_service.dart';

/// Service especializado para criação de tarefas iniciais de plantas
/// Centraliza toda lógica de criação de cronogramas de cuidados
class TaskCreationService {
  // Singleton pattern para otimização
  static TaskCreationService? _instance;
  static TaskCreationService get instance =>
      _instance ??= TaskCreationService._();
  TaskCreationService._();

  // ========== CRIAÇÃO DE TAREFAS INICIAIS ==========

  /// Cria todas as tarefas iniciais para uma planta baseado nas configurações
  Future<TaskCreationResult> createInitialTasksForPlant({
    required String plantaId,
    required PlantCareConfiguration config,
  }) async {
    debugPrint(
        '🌱 TaskCreationService: Iniciando criação de tarefas para planta $plantaId');

    final createdTasks = <String>[];
    final errors = <String>[];

    try {
      await SimpleTaskService.instance.initialize();

      // Criar todas as tarefas de uma vez (mais eficiente)
      await SimpleTaskService.instance.createInitialTasksForPlant(
        plantaId: plantaId,
        aguaAtiva: config.aguaAtiva,
        intervaloRegaDias: config.intervaloRegaDias,
        primeiraRega: config.primeiraRega,
        aduboAtivo: config.aduboAtivo,
        intervaloAdubacaoDias: config.intervaloAdubacaoDias,
        primeiraAdubacao: config.primeiraAdubacao,
        banhoSolAtivo: config.banhoSolAtivo,
        intervaloBanhoSolDias: config.intervaloBanhoSolDias,
        primeiroBanhoSol: config.primeiroBanhoSol,
        inspecaoPragasAtiva: config.inspecaoPragasAtiva,
        intervaloInspecaoPragasDias: config.intervaloInspecaoPragasDias,
        primeiraInspecaoPragas: config.primeiraInspecaoPragas,
        podaAtiva: config.podaAtiva,
        intervaloPodaDias: config.intervaloPodaDias,
        primeiraPoda: config.primeiraPoda,
        replantarAtivo: config.replantarAtivo,
        intervaloReplantarDias: config.intervaloReplantarDias,
        primeiroReplantar: config.primeiroReplantar,
      );

      // Montar lista dos tipos criados baseado na configuração
      if (config.aguaAtiva) {
        createdTasks.add('Rega (intervalo: ${config.intervaloRegaDias} dias)');
      }
      if (config.aduboAtivo) {
        createdTasks
            .add('Adubação (intervalo: ${config.intervaloAdubacaoDias} dias)');
      }
      if (config.banhoSolAtivo) {
        createdTasks.add(
            'Banho de sol (intervalo: ${config.intervaloBanhoSolDias} dias)');
      }
      if (config.inspecaoPragasAtiva) {
        createdTasks.add(
            'Inspeção de pragas (intervalo: ${config.intervaloInspecaoPragasDias} dias)');
      }
      if (config.podaAtiva) {
        createdTasks.add('Poda (intervalo: ${config.intervaloPodaDias} dias)');
      }
      if (config.replantarAtivo) {
        createdTasks.add(
            'Replantio (intervalo: ${config.intervaloReplantarDias} dias)');
      }

      debugPrint(
          '✅ TaskCreationService: Todas as tarefas criadas em uma única operação');

      final success = errors.isEmpty;
      debugPrint(
          '${success ? '✅' : '⚠️'} TaskCreationService: Criação finalizada - ${createdTasks.length} tipos criados, ${errors.length} erros');

      return TaskCreationResult(
        success: success,
        createdTaskTypes: createdTasks,
        errors: errors,
        totalTasksCreated: createdTasks.length,
      );
    } catch (e) {
      debugPrint(
          '❌ TaskCreationService: Erro crítico na criação de tarefas: $e');
      return TaskCreationResult(
        success: false,
        createdTaskTypes: createdTasks,
        errors: [...errors, 'Erro crítico: $e'],
        totalTasksCreated: createdTasks.length,
      );
    }
  }

  // ========== MÉTODOS UTILITÁRIOS ==========

  /// Cria uma configuração padrão para plantas novas
  PlantCareConfiguration createDefaultConfiguration() {
    final agora = DateTime.now();

    return PlantCareConfiguration(
      aguaAtiva: true,
      intervaloRegaDias: 1,
      primeiraRega: agora.add(const Duration(days: 1)),
      aduboAtivo: true,
      intervaloAdubacaoDias: 7,
      primeiraAdubacao: agora.add(const Duration(days: 7)),
      banhoSolAtivo: true,
      intervaloBanhoSolDias: 1,
      primeiroBanhoSol: agora.add(const Duration(days: 1)),
      inspecaoPragasAtiva: true,
      intervaloInspecaoPragasDias: 7,
      primeiraInspecaoPragas: agora.add(const Duration(days: 7)),
      podaAtiva: true,
      intervaloPodaDias: 30,
      primeiraPoda: agora.add(const Duration(days: 30)),
      replantarAtivo: true,
      intervaloReplantarDias: 180,
      primeiroReplantar: agora.add(const Duration(days: 180)),
    );
  }

  /// Valida se uma configuração de cuidados é válida
  bool isValidConfiguration(PlantCareConfiguration config) {
    // Verificar se pelo menos um cuidado está ativo
    final hasActiveCare = config.aguaAtiva ||
        config.aduboAtivo ||
        config.banhoSolAtivo ||
        config.inspecaoPragasAtiva ||
        config.podaAtiva ||
        config.replantarAtivo;

    if (!hasActiveCare) {
      debugPrint(
          '⚠️ TaskCreationService: Nenhum cuidado ativo na configuração');
      return false;
    }

    // Verificar datas no futuro para cuidados ativos
    final agora = DateTime.now();
    final ontemLimit = agora.subtract(const Duration(days: 1));

    if (config.aguaAtiva && config.primeiraRega.isBefore(ontemLimit)) {
      debugPrint(
          '⚠️ TaskCreationService: Data de primeira rega muito no passado');
      return false;
    }

    if (config.aduboAtivo && config.primeiraAdubacao.isBefore(ontemLimit)) {
      debugPrint(
          '⚠️ TaskCreationService: Data de primeira adubação muito no passado');
      return false;
    }

    // Continuar verificações para outros cuidados...

    return true;
  }

  /// Calcula resumo dos cuidados que serão criados
  CareScheduleSummary calculateScheduleSummary(PlantCareConfiguration config) {
    final activeCares = <String>[];
    final nextDates = <DateTime>[];

    if (config.aguaAtiva) {
      activeCares.add('Rega');
      nextDates.add(config.primeiraRega);
    }

    if (config.aduboAtivo) {
      activeCares.add('Adubação');
      nextDates.add(config.primeiraAdubacao);
    }

    if (config.banhoSolAtivo) {
      activeCares.add('Banho de sol');
      nextDates.add(config.primeiroBanhoSol);
    }

    if (config.inspecaoPragasAtiva) {
      activeCares.add('Inspeção de pragas');
      nextDates.add(config.primeiraInspecaoPragas);
    }

    if (config.podaAtiva) {
      activeCares.add('Poda');
      nextDates.add(config.primeiraPoda);
    }

    if (config.replantarAtivo) {
      activeCares.add('Replantio');
      nextDates.add(config.primeiroReplantar);
    }

    nextDates.sort();

    return CareScheduleSummary(
      activeCareTypes: activeCares,
      totalActiveCares: activeCares.length,
      nextCareDate: nextDates.isNotEmpty ? nextDates.first : null,
      allUpcomingDates: nextDates,
    );
  }
}

// ========== CLASSES DE DADOS ==========

/// Configuração completa de cuidados para uma planta
class PlantCareConfiguration {
  final bool aguaAtiva;
  final int intervaloRegaDias;
  final DateTime primeiraRega;

  final bool aduboAtivo;
  final int intervaloAdubacaoDias;
  final DateTime primeiraAdubacao;

  final bool banhoSolAtivo;
  final int intervaloBanhoSolDias;
  final DateTime primeiroBanhoSol;

  final bool inspecaoPragasAtiva;
  final int intervaloInspecaoPragasDias;
  final DateTime primeiraInspecaoPragas;

  final bool podaAtiva;
  final int intervaloPodaDias;
  final DateTime primeiraPoda;

  final bool replantarAtivo;
  final int intervaloReplantarDias;
  final DateTime primeiroReplantar;

  PlantCareConfiguration({
    required this.aguaAtiva,
    required this.intervaloRegaDias,
    required this.primeiraRega,
    required this.aduboAtivo,
    required this.intervaloAdubacaoDias,
    required this.primeiraAdubacao,
    required this.banhoSolAtivo,
    required this.intervaloBanhoSolDias,
    required this.primeiroBanhoSol,
    required this.inspecaoPragasAtiva,
    required this.intervaloInspecaoPragasDias,
    required this.primeiraInspecaoPragas,
    required this.podaAtiva,
    required this.intervaloPodaDias,
    required this.primeiraPoda,
    required this.replantarAtivo,
    required this.intervaloReplantarDias,
    required this.primeiroReplantar,
  });
}

/// Resultado da criação de tarefas
class TaskCreationResult {
  final bool success;
  final List<String> createdTaskTypes;
  final List<String> errors;
  final int totalTasksCreated;

  TaskCreationResult({
    required this.success,
    required this.createdTaskTypes,
    required this.errors,
    required this.totalTasksCreated,
  });

  String get summary {
    if (success) {
      return 'Cronograma criado: ${createdTaskTypes.join(', ')}';
    } else {
      return 'Falha na criação: ${errors.length} erro(s)';
    }
  }
}

/// Resumo do cronograma de cuidados
class CareScheduleSummary {
  final List<String> activeCareTypes;
  final int totalActiveCares;
  final DateTime? nextCareDate;
  final List<DateTime> allUpcomingDates;

  CareScheduleSummary({
    required this.activeCareTypes,
    required this.totalActiveCares,
    required this.nextCareDate,
    required this.allUpcomingDates,
  });

  String get description {
    if (totalActiveCares == 0) {
      return 'Nenhum cuidado ativo';
    }

    final nextDateStr = nextCareDate != null
        ? 'Próximo cuidado: ${_formatDate(nextCareDate!)}'
        : '';

    return '$totalActiveCares tipo(s) de cuidado ativo(s). $nextDateStr';
  }

  String _formatDate(DateTime date) {
    final agora = DateTime.now();
    final diff = date.difference(agora).inDays;

    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Amanhã';
    if (diff < 7) return 'Em $diff dias';

    return '${date.day}/${date.month}/${date.year}';
  }
}
