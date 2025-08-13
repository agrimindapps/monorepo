// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../database/comentario_model.dart';
import '../../../database/espaco_model.dart';
import '../../../database/planta_config_model.dart';
import '../../../database/planta_model.dart';
import 'comentarios_service.dart';
import 'concurrency_service.dart';
import 'planta_detalhes_service.dart';
import 'tarefas_management_service.dart';

/// Service orquestrador para sincronização e integridade de dados
/// Coordena operações entre services especializados mantendo consistência
class PlantaDataService {
  // Singleton pattern para otimização
  static PlantaDataService? _instance;
  static PlantaDataService get instance => _instance ??= PlantaDataService._();
  PlantaDataService._();

  // Services especializados
  final _plantaDetalhesService = PlantaDetalhesService.instance;
  final _comentariosService = ComentariosService.instance;
  final _tarefasService = TarefasManagementService.instance;

  // ========== OPERAÇÕES ORQUESTRADAS ==========

  /// Carrega todos os dados da planta de forma orquestrada
  Future<PlantaCompleteData> carregarDadosCompletos(String plantaId) async {
    return await ConcurrencyService.withLock('dados_completos_$plantaId',
        () async {
      debugPrint(
          '🔄 PlantaDataService: Carregando dados completos da planta $plantaId');

      try {
        // Carregar dados em paralelo para otimizar performance
        final results = await ConcurrencyService.executeWithTimeout([
          _plantaDetalhesService.carregarDadosCompletos(plantaId),
          _comentariosService.obterComentariosOrdenados(plantaId),
          _tarefasService.carregarTarefasPlanta(plantaId),
        ], const Duration(seconds: 45));

        final plantaDetalhes = results[0] as PlantaDetalhesData;
        final comentarios = results[1] as List<ComentarioModel>;
        final tarefasData = results[2] as TarefasData;

        // Verificar integridade dos dados carregados
        final integrityCheck = await _verificarIntegridadeDados(
            plantaId, plantaDetalhes, comentarios, tarefasData);

        debugPrint(
            '✅ PlantaDataService: Dados completos carregados com sucesso');

        return PlantaCompleteData(
          planta: plantaDetalhes.planta,
          configuracoes: plantaDetalhes.configuracoes,
          espaco: plantaDetalhes.espaco,
          comentarios: comentarios,
          tarefasData: tarefasData,
          integrityCheck: integrityCheck,
          success: true,
        );
      } catch (e) {
        debugPrint('❌ PlantaDataService: Erro ao carregar dados completos: $e');
        return PlantaCompleteData(
          success: false,
          error: e.toString(),
        );
      }
    });
  }

  /// Atualiza dados da planta garantindo sincronização
  Future<DataSyncResult> atualizarDadosPlanta({
    required String plantaId,
    PlantaModel? plantaAtualizada,
    List<ComentarioModel>? comentariosAtualizados,
  }) async {
    return await ConcurrencyService.withLock('atualizar_dados_$plantaId',
        () async {
      debugPrint('🔄 PlantaDataService: Atualizando dados da planta $plantaId');

      try {
        final operacoes = <Future>[];
        final resultados = <String>[];

        // Atualizar planta se fornecida
        if (plantaAtualizada != null) {
          operacoes
              .add(_plantaDetalhesService.atualizarPlanta(plantaAtualizada));
          resultados.add('Dados da planta atualizados');
        }

        // Executar atualizações em paralelo se houver múltiplas
        if (operacoes.isNotEmpty) {
          await ConcurrencyService.executeWithTimeout(
              operacoes, const Duration(seconds: 30));
        }

        // Verificar consistência após atualizações
        final consistencyCheck = await verificarConsistencia(plantaId);

        debugPrint('✅ PlantaDataService: Dados atualizados com sucesso');

        return DataSyncResult(
          success: true,
          operacoesRealizadas: resultados,
          consistencyCheck: consistencyCheck,
        );
      } catch (e) {
        debugPrint('❌ PlantaDataService: Erro ao atualizar dados: $e');
        return DataSyncResult(
          success: false,
          error: e.toString(),
        );
      }
    });
  }

  /// Executa sincronização completa com verificação de integridade
  Future<SyncResult> sincronizarTudo(String plantaId) async {
    debugPrint(
        '🔄 PlantaDataService: Iniciando sincronização completa da planta $plantaId');

    return await ConcurrencyService.withLock('sync_completo_$plantaId',
        () async {
      try {
        // Cancelar operações pendentes antes de sincronizar
        _cancelarTodasOperacoesPendentes(plantaId);

        // Sincronizar todos os services
        final syncTasks = [
          _plantaDetalhesService.sincronizarDados(plantaId),
          _comentariosService.obterComentariosOrdenados(plantaId),
          _tarefasService.carregarTarefasPlanta(plantaId),
        ];

        final results = await ConcurrencyService.executeWithTimeout(
            syncTasks, const Duration(seconds: 60));

        // Verificar resultados
        final plantaDetalhes = results[0] as PlantaDetalhesData;
        final comentarios = results[1] as List<ComentarioModel>;
        final tarefasData = results[2] as TarefasData;

        final success = plantaDetalhes.success && tarefasData.success;

        // Executar verificação de integridade final
        final integrityResult =
            await _plantaDetalhesService.verificarIntegridade(plantaId);

        debugPrint(
            '${success ? '✅' : '⚠️'} PlantaDataService: Sincronização completa finalizada');

        return SyncResult(
          success: success,
          plantaDetalhes: plantaDetalhes,
          comentarios: comentarios,
          tarefasData: tarefasData,
          integrityResult: integrityResult,
          syncTimestamp: DateTime.now(),
        );
      } catch (e) {
        debugPrint('❌ PlantaDataService: Erro na sincronização completa: $e');
        return SyncResult(
          success: false,
          error: e.toString(),
          syncTimestamp: DateTime.now(),
        );
      }
    });
  }

  // ========== OPERAÇÕES DE VERIFICAÇÃO ==========

  /// Verifica consistência dos dados entre services
  Future<ConsistencyCheckResult> verificarConsistencia(String plantaId) async {
    try {
      debugPrint(
          '🔍 PlantaDataService: Verificando consistência dos dados da planta $plantaId');

      final issues = <String>[];
      final warnings = <String>[];

      // Verificar integridade nos services individuais
      final plantaIntegrity =
          await _plantaDetalhesService.verificarIntegridade(plantaId);

      if (!plantaIntegrity.isValid) {
        issues.addAll(plantaIntegrity.issues);
        warnings.addAll(plantaIntegrity.warnings);
      }

      // Verificar consistência entre comentários e planta
      final comentarios =
          await _comentariosService.obterComentariosOrdenados(plantaId);
      final plantaDetalhes =
          await _plantaDetalhesService.carregarDadosCompletos(plantaId);

      if (plantaDetalhes.success && plantaDetalhes.planta != null) {
        final comentariosNaPlanta =
            plantaDetalhes.planta!.comentarios?.length ?? 0;
        if (comentarios.length != comentariosNaPlanta) {
          warnings.add('Inconsistência na contagem de comentários');
        }
      }

      // Verificar se tarefas têm referência válida para a planta
      final tarefasData = await _tarefasService.carregarTarefasPlanta(plantaId);
      if (tarefasData.success) {
        final tarefasSemPlanta =
            tarefasData.todas.where((t) => t.plantaId != plantaId);
        if (tarefasSemPlanta.isNotEmpty) {
          issues.add(
              '${tarefasSemPlanta.length} tarefa(s) com referência incorreta');
        }
      }

      final isConsistent = issues.isEmpty;
      debugPrint(
          '${isConsistent ? '✅' : '⚠️'} PlantaDataService: Verificação de consistência completa');

      return ConsistencyCheckResult(
        isConsistent: isConsistent,
        issues: issues,
        warnings: warnings,
        checkTimestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint(
          '❌ PlantaDataService: Erro na verificação de consistência: $e');
      return ConsistencyCheckResult(
        isConsistent: false,
        issues: ['Erro na verificação: $e'],
        checkTimestamp: DateTime.now(),
      );
    }
  }

  // ========== OPERAÇÕES UTILITÁRIAS ==========

  /// Obtém resumo executivo dos dados da planta
  Future<PlantaSummary> obterResumoExecutivo(String plantaId) async {
    try {
      debugPrint(
          '📊 PlantaDataService: Gerando resumo executivo da planta $plantaId');

      // Carregar estatísticas de todos os services
      final comentarioStats =
          await _comentariosService.obterEstatisticas(plantaId);
      final tarefaStats = await _tarefasService.obterEstatisticas(plantaId);
      final cronogramaResumo =
          await _tarefasService.obterResumoChronograma(plantaId);

      return PlantaSummary(
        plantaId: plantaId,
        comentarioStats: comentarioStats,
        tarefaStats: tarefaStats,
        cronogramaResumo: cronogramaResumo,
        geradoEm: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ PlantaDataService: Erro ao gerar resumo executivo: $e');
      return PlantaSummary.empty(plantaId);
    }
  }

  /// Executa limpeza e otimização dos dados
  Future<CleanupResult> executarLimpeza(String plantaId) async {
    debugPrint(
        '🧹 PlantaDataService: Executando limpeza de dados da planta $plantaId');

    try {
      final operacoesLimpeza = <String>[];

      // Cancelar operações pendentes antigas
      _cancelarTodasOperacoesPendentes(plantaId);
      operacoesLimpeza.add('Operações pendentes canceladas');

      // Verificar e reportar dados órfãos ou inconsistentes
      final consistencyCheck = await verificarConsistencia(plantaId);
      if (!consistencyCheck.isConsistent) {
        operacoesLimpeza.add(
            '${consistencyCheck.issues.length} inconsistência(s) detectada(s)');
      }

      debugPrint('✅ PlantaDataService: Limpeza concluída');

      return CleanupResult(
        success: true,
        operacoes: operacoesLimpeza,
        consistencyResult: consistencyCheck,
      );
    } catch (e) {
      debugPrint('❌ PlantaDataService: Erro na limpeza: $e');
      return CleanupResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  // ========== MÉTODOS PRIVADOS ==========

  /// Verifica integridade dos dados carregados
  Future<DataIntegrityResult> _verificarIntegridadeDados(
    String plantaId,
    PlantaDetalhesData plantaDetalhes,
    List<ComentarioModel> comentarios,
    TarefasData tarefasData,
  ) async {
    final problemas = <String>[];
    final avisos = <String>[];

    // Verificar se planta existe
    if (!plantaDetalhes.success || plantaDetalhes.planta == null) {
      problemas.add('Dados da planta não puderam ser carregados');
    }

    // Verificar se tarefas carregaram
    if (!tarefasData.success) {
      avisos.add('Tarefas não puderam ser carregadas completamente');
    }

    // Verificar se há dados básicos mínimos
    if (plantaDetalhes.planta != null) {
      if (plantaDetalhes.planta!.nome == null ||
          plantaDetalhes.planta!.nome!.isEmpty) {
        problemas.add('Planta sem nome definido');
      }
    }

    return DataIntegrityResult(
      isIntegral: problemas.isEmpty,
      problemas: problemas,
      avisos: avisos,
    );
  }

  /// Cancela todas as operações pendentes para uma planta
  void _cancelarTodasOperacoesPendentes(String plantaId) {
    _plantaDetalhesService.cancelarOperacoesPendentes(plantaId);
    _comentariosService.cancelarOperacoesPendentes(plantaId);
    _tarefasService.cancelarOperacoesPendentes(plantaId);
    ConcurrencyService.cancelOperation('dados_completos_$plantaId');
    ConcurrencyService.cancelOperation('sync_completo_$plantaId');
    debugPrint(
        '🚫 PlantaDataService: Todas as operações canceladas para planta $plantaId');
  }

  /// Cancela operações pendentes externamente
  void cancelarOperacoesPendentes(String plantaId) {
    _cancelarTodasOperacoesPendentes(plantaId);
  }
}

// ========== CLASSES DE DADOS ==========

/// Dados completos da planta com todas as dependências
class PlantaCompleteData {
  final PlantaModel? planta;
  final PlantaConfigModel? configuracoes;
  final EspacoModel? espaco;
  final List<ComentarioModel> comentarios;
  final TarefasData tarefasData;
  final DataIntegrityResult? integrityCheck;
  final bool success;
  final String? error;

  PlantaCompleteData({
    this.planta,
    this.configuracoes,
    this.espaco,
    this.comentarios = const [],
    TarefasData? tarefasData,
    this.integrityCheck,
    required this.success,
    this.error,
  }) : tarefasData = tarefasData ?? TarefasData(success: false);
}

/// Resultado de sincronização de dados
class DataSyncResult {
  final bool success;
  final List<String> operacoesRealizadas;
  final ConsistencyCheckResult? consistencyCheck;
  final String? error;

  DataSyncResult({
    required this.success,
    this.operacoesRealizadas = const [],
    this.consistencyCheck,
    this.error,
  });
}

/// Resultado de sincronização completa
class SyncResult {
  final bool success;
  final PlantaDetalhesData? plantaDetalhes;
  final List<ComentarioModel> comentarios;
  final TarefasData? tarefasData;
  final IntegrityCheckResult? integrityResult;
  final DateTime syncTimestamp;
  final String? error;

  SyncResult({
    required this.success,
    this.plantaDetalhes,
    this.comentarios = const [],
    this.tarefasData,
    this.integrityResult,
    required this.syncTimestamp,
    this.error,
  });
}

/// Resultado de verificação de consistência
class ConsistencyCheckResult {
  final bool isConsistent;
  final List<String> issues;
  final List<String> warnings;
  final DateTime checkTimestamp;

  ConsistencyCheckResult({
    required this.isConsistent,
    this.issues = const [],
    this.warnings = const [],
    required this.checkTimestamp,
  });

  String get summary {
    if (isConsistent && warnings.isEmpty) {
      return 'Dados totalmente consistentes';
    } else if (isConsistent) {
      return '${warnings.length} aviso(s) de consistência';
    } else {
      return '${issues.length} problema(s) de consistência detectado(s)';
    }
  }
}

/// Resumo executivo da planta
class PlantaSummary {
  final String plantaId;
  final ComentarioStatistics? comentarioStats;
  final TarefaStatistics? tarefaStats;
  final CronogramaResumo? cronogramaResumo;
  final DateTime geradoEm;

  PlantaSummary({
    required this.plantaId,
    required this.comentarioStats,
    required this.tarefaStats,
    required this.cronogramaResumo,
    required this.geradoEm,
  });

  factory PlantaSummary.empty(String plantaId) {
    return PlantaSummary(
      plantaId: plantaId,
      comentarioStats: null,
      tarefaStats: null,
      cronogramaResumo: null,
      geradoEm: DateTime.now(),
    );
  }
}

/// Resultado de limpeza de dados
class CleanupResult {
  final bool success;
  final List<String> operacoes;
  final ConsistencyCheckResult? consistencyResult;
  final String? error;

  CleanupResult({
    required this.success,
    this.operacoes = const [],
    this.consistencyResult,
    this.error,
  });
}

/// Resultado de verificação de integridade dos dados
class DataIntegrityResult {
  final bool isIntegral;
  final List<String> problemas;
  final List<String> avisos;

  DataIntegrityResult({
    required this.isIntegral,
    this.problemas = const [],
    this.avisos = const [],
  });
}
