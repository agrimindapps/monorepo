// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../database/tarefa_model.dart';
import '../../../repository/tarefa_repository.dart';
import 'concurrency_service.dart';

/// Service especializado para operações avançadas com tarefas
/// Centraliza lógica de gerenciamento, filtragem e manipulação de tarefas
class TarefasManagementService {
  // Singleton pattern para otimização
  static TarefasManagementService? _instance;
  static TarefasManagementService get instance =>
      _instance ??= TarefasManagementService._();
  TarefasManagementService._();

  // ========== OPERAÇÕES DE CARREGAMENTO ==========

  /// Carrega todas as tarefas de uma planta com categorização inteligente
  Future<TarefasData> carregarTarefasPlanta(String plantaId) async {
    return await ConcurrencyService.withLock('tarefas_$plantaId', () async {
      try {
        debugPrint(
            '📋 TarefasManagementService: Carregando tarefas da planta $plantaId');

        final tarefaRepo = TarefaRepository.instance;
        await tarefaRepo.initialize();

        // Carregar todas as tarefas da planta
        final todasTarefas = await tarefaRepo.findByPlanta(plantaId);

        // Categorizar tarefas automaticamente
        final categorizacao = _categorizarTarefas(todasTarefas);

        debugPrint(
            '✅ TarefasManagementService: ${todasTarefas.length} tarefas carregadas e categorizadas');

        return TarefasData(
          todas: todasTarefas,
          recentes: categorizacao.recentes,
          proximas: categorizacao.proximas,
          atrasadas: categorizacao.atrasadas,
          concluidas: categorizacao.concluidas,
          success: true,
        );
      } catch (e) {
        debugPrint('❌ TarefasManagementService: Erro ao carregar tarefas: $e');
        return TarefasData(
          success: false,
          error: e.toString(),
        );
      }
    });
  }

  /// Carrega apenas tarefas pendentes priorizadas
  Future<List<TarefaModel>> carregarTarefasPendentes(String plantaId) async {
    try {
      debugPrint(
          '⏳ TarefasManagementService: Carregando tarefas pendentes da planta $plantaId');

      final tarefaRepo = TarefaRepository.instance;
      await tarefaRepo.initialize();

      final todasTarefas = await tarefaRepo.findByPlanta(plantaId);

      // Filtrar apenas tarefas pendentes e ordenar por prioridade
      final tarefasPendentes =
          todasTarefas.where((tarefa) => !tarefa.concluida).toList();

      // Ordenar por prioridade (atrasadas primeiro, depois por data)
      tarefasPendentes.sort((a, b) {
        final aAtrasada = a.isAtrasada;
        final bAtrasada = b.isAtrasada;

        if (aAtrasada && !bAtrasada) return -1;
        if (!aAtrasada && bAtrasada) return 1;

        return a.dataExecucao.compareTo(b.dataExecucao);
      });

      debugPrint(
          '✅ TarefasManagementService: ${tarefasPendentes.length} tarefas pendentes carregadas');
      return tarefasPendentes;
    } catch (e) {
      debugPrint(
          '❌ TarefasManagementService: Erro ao carregar tarefas pendentes: $e');
      return [];
    }
  }

  // ========== OPERAÇÕES DE MANIPULAÇÃO ==========

  /// Marca tarefa como concluída com validações
  Future<TarefaOperationResult> marcarTarefaConcluida({
    required TarefaModel tarefa,
    String? observacaoConlusao,
  }) async {
    return await ConcurrencyService.withLock('tarefa_${tarefa.id}', () async {
      try {
        debugPrint(
            '✅ TarefasManagementService: Marcando tarefa ${tarefa.id} como concluída');

        // Validar se tarefa pode ser concluída
        final validationResult = _validarConclusaoTarefa(tarefa);
        if (!validationResult.isValid) {
          return TarefaOperationResult(
            success: false,
            error: validationResult.errors.join(', '),
          );
        }

        // Executar conclusão com timeout
        await ConcurrencyService.executeWithTimeout([
          () async {
            final tarefaRepo = TarefaRepository.instance;
            await tarefaRepo.initialize();
            await tarefaRepo.marcarConcluida(
              tarefa.id,
              observacoes: observacaoConlusao,
            );
          }(),
        ], const Duration(seconds: 15));

        debugPrint('✅ TarefasManagementService: Tarefa concluída com sucesso');
        return TarefaOperationResult(
          success: true,
          message: 'Tarefa "${tarefa.tipoCuidadoNome}" concluída com sucesso',
        );
      } catch (e) {
        debugPrint(
            '❌ TarefasManagementService: Erro ao marcar tarefa como concluída: $e');
        return TarefaOperationResult(
          success: false,
          error: e.toString(),
        );
      }
    });
  }

  /// Reagenda tarefa para nova data
  Future<TarefaOperationResult> reagendarTarefa({
    required TarefaModel tarefa,
    required DateTime novaData,
    String? motivo,
  }) async {
    return await ConcurrencyService.withLock('tarefa_${tarefa.id}', () async {
      try {
        debugPrint(
            '📅 TarefasManagementService: Reagendando tarefa ${tarefa.id}');

        // Validar nova data
        final validationResult = _validarReagendamento(tarefa, novaData);
        if (!validationResult.isValid) {
          return TarefaOperationResult(
            success: false,
            error: validationResult.errors.join(', '),
          );
        }

        final tarefaRepo = TarefaRepository.instance;
        await tarefaRepo.initialize();

        // Criar nova tarefa com a nova data (mantendo histórico)
        final tarefaReagendada = tarefa.copyWith(
          dataExecucao: novaData,
          observacoes: motivo != null
              ? '${tarefa.observacoes ?? ''}\nReagendada: $motivo'.trim()
              : tarefa.observacoes,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );

        await tarefaRepo.update(tarefaReagendada.id, tarefaReagendada);

        debugPrint('✅ TarefasManagementService: Tarefa reagendada com sucesso');
        return TarefaOperationResult(
          success: true,
          message: 'Tarefa reagendada para ${_formatarData(novaData)}',
          tarefa: tarefaReagendada,
        );
      } catch (e) {
        debugPrint('❌ TarefasManagementService: Erro ao reagendar tarefa: $e');
        return TarefaOperationResult(
          success: false,
          error: e.toString(),
        );
      }
    });
  }

  /// Cancela/remove tarefa com justificativa
  Future<TarefaOperationResult> cancelarTarefa({
    required TarefaModel tarefa,
    required String motivo,
  }) async {
    return await ConcurrencyService.withLock('tarefa_${tarefa.id}', () async {
      try {
        debugPrint(
            '🚫 TarefasManagementService: Cancelando tarefa ${tarefa.id}');

        // Validar cancelamento
        if (motivo.trim().length < 3) {
          return TarefaOperationResult(
            success: false,
            error: 'Motivo do cancelamento deve ter pelo menos 3 caracteres',
          );
        }

        final tarefaRepo = TarefaRepository.instance;
        await tarefaRepo.initialize();

        // Marcar como deletada com motivo (soft delete)
        await tarefaRepo.delete(tarefa.id);

        debugPrint('✅ TarefasManagementService: Tarefa cancelada com sucesso');
        return TarefaOperationResult(
          success: true,
          message: 'Tarefa cancelada: $motivo',
        );
      } catch (e) {
        debugPrint('❌ TarefasManagementService: Erro ao cancelar tarefa: $e');
        return TarefaOperationResult(
          success: false,
          error: e.toString(),
        );
      }
    });
  }

  // ========== ANÁLISES E ESTATÍSTICAS ==========

  /// Obtém estatísticas completas das tarefas
  Future<TarefaStatistics> obterEstatisticas(String plantaId) async {
    try {
      debugPrint(
          '📊 TarefasManagementService: Calculando estatísticas da planta $plantaId');

      final tarefasData = await carregarTarefasPlanta(plantaId);
      if (!tarefasData.success) {
        return TarefaStatistics.empty();
      }

      final agora = DateTime.now();
      final ultimos30Dias = agora.subtract(const Duration(days: 30));

      final concluidasUltimos30Dias = tarefasData.concluidas.where((t) {
        return t.dataConclusao != null &&
            t.dataConclusao!.isAfter(ultimos30Dias);
      }).length;

      final taxaConclusao = tarefasData.todas.isNotEmpty
          ? (tarefasData.concluidas.length / tarefasData.todas.length) * 100
          : 0.0;

      final diasMediaEntreTarefas =
          _calcularDiasMediaEntreTarefas(tarefasData.concluidas);

      return TarefaStatistics(
        total: tarefasData.todas.length,
        concluidas: tarefasData.concluidas.length,
        pendentes: tarefasData.proximas.length,
        atrasadas: tarefasData.atrasadas.length,
        concluidasUltimos30Dias: concluidasUltimos30Dias,
        taxaConclusao: taxaConclusao,
        diasMediaEntreTarefas: diasMediaEntreTarefas,
        proximaTarefa:
            tarefasData.proximas.isNotEmpty ? tarefasData.proximas.first : null,
      );
    } catch (e) {
      debugPrint(
          '❌ TarefasManagementService: Erro ao calcular estatísticas: $e');
      return TarefaStatistics.empty();
    }
  }

  /// Obtém resumo do cronograma de cuidados
  Future<CronogramaResumo> obterResumoChronograma(String plantaId) async {
    try {
      final tarefasPendentes = await carregarTarefasPendentes(plantaId);

      if (tarefasPendentes.isEmpty) {
        return CronogramaResumo.empty();
      }

      final proximaTarefa = tarefasPendentes.first;
      final tarefasHoje = tarefasPendentes.where((t) => t.isParaHoje).length;
      final tarefasAtrasadas =
          tarefasPendentes.where((t) => t.isAtrasada).length;
      final tarefasProximaSemana = tarefasPendentes.where((t) {
        final agora = DateTime.now();
        final proximaSemana = agora.add(const Duration(days: 7));
        return t.dataExecucao.isAfter(agora) &&
            t.dataExecucao.isBefore(proximaSemana);
      }).length;

      return CronogramaResumo(
        proximaTarefa: proximaTarefa,
        tarefasHoje: tarefasHoje,
        tarefasAtrasadas: tarefasAtrasadas,
        tarefasProximaSemana: tarefasProximaSemana,
        totalPendentes: tarefasPendentes.length,
      );
    } catch (e) {
      debugPrint('❌ TarefasManagementService: Erro ao obter resumo: $e');
      return CronogramaResumo.empty();
    }
  }

  // ========== MÉTODOS PRIVADOS ==========

  /// Categoriza tarefas por status e data
  TarefasCategorizacao _categorizarTarefas(List<TarefaModel> tarefas) {
    final agora = DateTime.now();
    final trintaDiasAtras = agora.subtract(const Duration(days: 30));

    final recentes = <TarefaModel>[];
    final proximas = <TarefaModel>[];
    final atrasadas = <TarefaModel>[];
    final concluidas = <TarefaModel>[];

    for (final tarefa in tarefas) {
      if (tarefa.concluida) {
        concluidas.add(tarefa);

        // Se foi concluída recentemente, adicionar às recentes também
        if (tarefa.dataConclusao != null &&
            tarefa.dataConclusao!.isAfter(trintaDiasAtras)) {
          recentes.add(tarefa);
        }
      } else {
        if (tarefa.isAtrasada) {
          atrasadas.add(tarefa);
        } else {
          proximas.add(tarefa);
        }
      }
    }

    // Ordenar cada categoria
    recentes.sort((a, b) => b.dataConclusao!.compareTo(a.dataConclusao!));
    proximas.sort((a, b) => a.dataExecucao.compareTo(b.dataExecucao));
    atrasadas.sort((a, b) => a.dataExecucao.compareTo(b.dataExecucao));
    concluidas.sort((a, b) =>
        (b.dataConclusao ?? DateTime.fromMillisecondsSinceEpoch(b.updatedAt))
            .compareTo(a.dataConclusao ??
                DateTime.fromMillisecondsSinceEpoch(a.updatedAt)));

    return TarefasCategorizacao(
      recentes: recentes,
      proximas: proximas,
      atrasadas: atrasadas,
      concluidas: concluidas,
    );
  }

  /// Valida se tarefa pode ser concluída
  ValidationResult _validarConclusaoTarefa(TarefaModel tarefa) {
    final errors = <String>[];

    if (tarefa.concluida) {
      errors.add('Tarefa já está concluída');
    }

    // Validar se não é muito futuro (mais de 7 dias)
    final agora = DateTime.now();
    final seteDiasAFrente = agora.add(const Duration(days: 7));

    if (tarefa.dataExecucao.isAfter(seteDiasAFrente)) {
      errors.add('Não é possível concluir tarefa muito antecipadamente');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Valida reagendamento de tarefa
  ValidationResult _validarReagendamento(
      TarefaModel tarefa, DateTime novaData) {
    final errors = <String>[];

    if (tarefa.concluida) {
      errors.add('Não é possível reagendar tarefa já concluída');
    }

    final agora = DateTime.now();
    final ontem = DateTime(agora.year, agora.month, agora.day - 1);

    if (novaData.isBefore(ontem)) {
      errors.add('Nova data não pode ser no passado');
    }

    final umAnoAFrente = agora.add(const Duration(days: 365));
    if (novaData.isAfter(umAnoAFrente)) {
      errors.add('Nova data não pode ser mais de um ano no futuro');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Calcula dias médios entre tarefas concluídas
  double _calcularDiasMediaEntreTarefas(List<TarefaModel> tarefasConcluidas) {
    if (tarefasConcluidas.length < 2) return 0.0;

    final tarefasOrdenadas = List<TarefaModel>.from(tarefasConcluidas)
      ..sort((a, b) =>
          (a.dataConclusao ?? DateTime.fromMillisecondsSinceEpoch(a.updatedAt))
              .compareTo(b.dataConclusao ??
                  DateTime.fromMillisecondsSinceEpoch(b.updatedAt)));

    var totalDias = 0;
    for (int i = 1; i < tarefasOrdenadas.length; i++) {
      final dataAnterior = tarefasOrdenadas[i - 1].dataConclusao ??
          DateTime.fromMillisecondsSinceEpoch(
              tarefasOrdenadas[i - 1].updatedAt);
      final dataAtual = tarefasOrdenadas[i].dataConclusao ??
          DateTime.fromMillisecondsSinceEpoch(tarefasOrdenadas[i].updatedAt);

      totalDias += dataAtual.difference(dataAnterior).inDays;
    }

    return totalDias / (tarefasOrdenadas.length - 1);
  }

  /// Formata data para exibição
  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final diff = data.difference(agora).inDays;

    if (diff == 0) return 'hoje';
    if (diff == 1) return 'amanhã';
    if (diff == -1) return 'ontem';
    if (diff > 0) return 'em $diff dias';
    return '${diff.abs()} dias atrás';
  }

  /// Cancela operações pendentes
  void cancelarOperacoesPendentes(String plantaId) {
    ConcurrencyService.cancelOperation('tarefas_$plantaId');
    debugPrint(
        '🚫 TarefasManagementService: Operações canceladas para planta $plantaId');
  }
}

// ========== CLASSES DE DADOS ==========

/// Dados completos das tarefas categorizadas
class TarefasData {
  final List<TarefaModel> todas;
  final List<TarefaModel> recentes;
  final List<TarefaModel> proximas;
  final List<TarefaModel> atrasadas;
  final List<TarefaModel> concluidas;
  final bool success;
  final String? error;

  TarefasData({
    this.todas = const [],
    this.recentes = const [],
    this.proximas = const [],
    this.atrasadas = const [],
    this.concluidas = const [],
    required this.success,
    this.error,
  });
}

/// Categorização de tarefas
class TarefasCategorizacao {
  final List<TarefaModel> recentes;
  final List<TarefaModel> proximas;
  final List<TarefaModel> atrasadas;
  final List<TarefaModel> concluidas;

  TarefasCategorizacao({
    required this.recentes,
    required this.proximas,
    required this.atrasadas,
    required this.concluidas,
  });
}

/// Resultado de operações com tarefas
class TarefaOperationResult {
  final bool success;
  final String? error;
  final String? message;
  final TarefaModel? tarefa;

  TarefaOperationResult({
    required this.success,
    this.error,
    this.message,
    this.tarefa,
  });
}

/// Estatísticas das tarefas
class TarefaStatistics {
  final int total;
  final int concluidas;
  final int pendentes;
  final int atrasadas;
  final int concluidasUltimos30Dias;
  final double taxaConclusao;
  final double diasMediaEntreTarefas;
  final TarefaModel? proximaTarefa;

  TarefaStatistics({
    required this.total,
    required this.concluidas,
    required this.pendentes,
    required this.atrasadas,
    required this.concluidasUltimos30Dias,
    required this.taxaConclusao,
    required this.diasMediaEntreTarefas,
    this.proximaTarefa,
  });

  factory TarefaStatistics.empty() {
    return TarefaStatistics(
      total: 0,
      concluidas: 0,
      pendentes: 0,
      atrasadas: 0,
      concluidasUltimos30Dias: 0,
      taxaConclusao: 0.0,
      diasMediaEntreTarefas: 0.0,
    );
  }

  String get resumo {
    if (total == 0) return 'Nenhuma tarefa registrada';
    return '$total tarefas, ${taxaConclusao.toStringAsFixed(1)}% concluídas';
  }
}

/// Resumo do cronograma
class CronogramaResumo {
  final TarefaModel? proximaTarefa;
  final int tarefasHoje;
  final int tarefasAtrasadas;
  final int tarefasProximaSemana;
  final int totalPendentes;

  CronogramaResumo({
    this.proximaTarefa,
    required this.tarefasHoje,
    required this.tarefasAtrasadas,
    required this.tarefasProximaSemana,
    required this.totalPendentes,
  });

  factory CronogramaResumo.empty() {
    return CronogramaResumo(
      tarefasHoje: 0,
      tarefasAtrasadas: 0,
      tarefasProximaSemana: 0,
      totalPendentes: 0,
    );
  }

  String get statusResumo {
    if (totalPendentes == 0) return 'Nenhuma tarefa pendente';
    if (tarefasAtrasadas > 0) return '$tarefasAtrasadas tarefa(s) atrasada(s)';
    if (tarefasHoje > 0) return '$tarefasHoje tarefa(s) para hoje';
    return '$totalPendentes tarefa(s) pendente(s)';
  }
}

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    this.errors = const [],
  });
}
