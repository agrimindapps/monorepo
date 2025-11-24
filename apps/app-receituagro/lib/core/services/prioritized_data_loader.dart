import 'dart:developer' as developer;

import 'culturas_data_loader.dart';
import 'diagnosticos_data_loader.dart';
import 'fitossanitarios_data_loader.dart';
import 'pragas_data_loader.dart';

/// Serviço de carregamento priorizado de dados
///
/// Carrega dados em duas fases:
/// - **Fase 1 (Prioritária)**: Culturas, Pragas e Fitossanitários - aguarda antes do app iniciar
/// - **Fase 2 (Background)**: Diagnósticos - carrega em background sem bloquear o app
class PrioritizedDataLoader {
  // Construtor privado para evitar instanciação (utility class)
  PrioritizedDataLoader._();

  static bool _isPriorityDataLoaded = false;
  static bool _isBackgroundDataLoaded = false;

  /// Carrega dados prioritários (Culturas, Pragas, Fitossanitários)
  /// Estes dados são essenciais para navegação básica do app
  static Future<void> loadPriorityData(dynamic ref) async {
    if (_isPriorityDataLoaded) {
      developer.log(
        '✅ Dados prioritários já carregados, pulando...',
        name: 'PrioritizedDataLoader',
      );
      return;
    }

    try {
      developer.log(
        '🚀 [PRIORITY] Iniciando carregamento de dados prioritários...',
        name: 'PrioritizedDataLoader',
      );

      final startTime = DateTime.now();

      // Carrega dados prioritários em paralelo
      await Future.wait([
        CulturasDataLoader.loadCulturasData(ref),
        PragasDataLoader.loadPragasData(ref),
        FitossanitariosDataLoader.loadFitossanitariosData(ref),
      ]);

      final duration = DateTime.now().difference(startTime);

      _isPriorityDataLoaded = true;

      developer.log(
        '✅ [PRIORITY] Dados prioritários carregados em ${duration.inMilliseconds}ms',
        name: 'PrioritizedDataLoader',
      );

      // Log estatísticas
      await _logPriorityDataStats(ref);
    } catch (e, stackTrace) {
      developer.log(
        '❌ [PRIORITY] Erro ao carregar dados prioritários: $e',
        name: 'PrioritizedDataLoader',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Carrega dados em background (Diagnósticos)
  /// Estes dados não bloqueiam a inicialização do app
  ///
  /// IMPORTANTE: Este método retorna imediatamente e continua carregando em background
  static void loadBackgroundData(dynamic ref) {
    if (_isBackgroundDataLoaded) {
      developer.log(
        '✅ Dados em background já carregados, pulando...',
        name: 'PrioritizedDataLoader',
      );
      return;
    }

    developer.log(
      '⏳ [BACKGROUND] Iniciando carregamento de dados em background...',
      name: 'PrioritizedDataLoader',
    );

    // Carrega em background sem bloquear
    _loadBackgroundDataAsync(ref);
  }

  /// Método privado que executa o carregamento em background
  static Future<void> _loadBackgroundDataAsync(dynamic ref) async {
    try {
      final startTime = DateTime.now();

      developer.log(
        '🩺 [BACKGROUND] Carregando diagnósticos...',
        name: 'PrioritizedDataLoader',
      );

      await DiagnosticosDataLoader.loadDiagnosticosData(ref);

      final duration = DateTime.now().difference(startTime);

      _isBackgroundDataLoaded = true;

      developer.log(
        '✅ [BACKGROUND] Diagnósticos carregados em ${duration.inMilliseconds}ms',
        name: 'PrioritizedDataLoader',
      );

      // Log estatísticas
      await _logBackgroundDataStats(ref);
    } catch (e, stackTrace) {
      developer.log(
        '❌ [BACKGROUND] Erro ao carregar dados em background: $e',
        name: 'PrioritizedDataLoader',
        error: e,
        stackTrace: stackTrace,
      );
      // Não propaga o erro - background loading não deve crashar o app
    }
  }

  /// Força recarregamento de todos os dados
  static Future<void> forceReloadAll(dynamic ref) async {
    developer.log(
      '🔄 Forçando recarregamento de todos os dados...',
      name: 'PrioritizedDataLoader',
    );

    _isPriorityDataLoaded = false;
    _isBackgroundDataLoaded = false;

    await loadPriorityData(ref);
    await _loadBackgroundDataAsync(ref);

    developer.log(
      '✅ Recarregamento completo concluído!',
      name: 'PrioritizedDataLoader',
    );
  }

  /// Verifica se dados prioritários estão carregados
  static Future<bool> isPriorityDataReady(dynamic ref) async {
    try {
      final culturasLoaded = await CulturasDataLoader.isDataLoaded(ref);
      final pragasLoaded = await PragasDataLoader.isDataLoaded(ref);
      final fitossanitariosLoaded =
          await FitossanitariosDataLoader.isDataLoaded(ref);

      return culturasLoaded && pragasLoaded && fitossanitariosLoaded;
    } catch (e) {
      developer.log(
        '❌ Erro ao verificar dados prioritários: $e',
        name: 'PrioritizedDataLoader',
      );
      return false;
    }
  }

  /// Verifica se dados em background estão carregados
  static Future<bool> isBackgroundDataReady(dynamic ref) async {
    try {
      return await DiagnosticosDataLoader.isDataLoaded(ref);
    } catch (e) {
      developer.log(
        '❌ Erro ao verificar dados em background: $e',
        name: 'PrioritizedDataLoader',
      );
      return false;
    }
  }

  /// Obtém estatísticas completas de carregamento
  static Future<Map<String, dynamic>> getLoadingStats(dynamic ref) async {
    try {
      final culturasStats = await CulturasDataLoader.getStats(ref);
      final pragasStats = await PragasDataLoader.getStats(ref);
      final fitossanitariosStats = await FitossanitariosDataLoader.getStats(ref);
      final diagnosticosStats = await DiagnosticosDataLoader.getStats(ref);

      return {
        'priority_data': {
          'loaded': _isPriorityDataLoaded,
          'culturas': culturasStats,
          'pragas': pragasStats,
          'fitossanitarios': fitossanitariosStats,
        },
        'background_data': {
          'loaded': _isBackgroundDataLoaded,
          'diagnosticos': diagnosticosStats,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'priority_loaded': _isPriorityDataLoaded,
        'background_loaded': _isBackgroundDataLoaded,
      };
    }
  }

  /// Log estatísticas dos dados prioritários
  static Future<void> _logPriorityDataStats(dynamic ref) async {
    try {
      final culturasStats = await CulturasDataLoader.getStats(ref);
      final pragasStats = await PragasDataLoader.getStats(ref);
      final fitossanitariosStats = await FitossanitariosDataLoader.getStats(ref);

      final totalCulturas = culturasStats['total_culturas'] ?? 0;
      final totalPragas = pragasStats['total_pragas'] ?? 0;
      final totalFitossanitarios =
          fitossanitariosStats['total_fitossanitarios'] ?? 0;

      developer.log(
        '📊 [PRIORITY STATS] Culturas: $totalCulturas | Pragas: $totalPragas | Fitossanitários: $totalFitossanitarios',
        name: 'PrioritizedDataLoader',
      );
    } catch (e) {
      developer.log(
        '⚠️ Erro ao obter estatísticas prioritárias: $e',
        name: 'PrioritizedDataLoader',
      );
    }
  }

  /// Log estatísticas dos dados em background
  static Future<void> _logBackgroundDataStats(dynamic ref) async {
    try {
      final diagnosticosStats = await DiagnosticosDataLoader.getStats(ref);
      final totalDiagnosticos = diagnosticosStats['total_diagnosticos'] ?? 0;

      developer.log(
        '📊 [BACKGROUND STATS] Diagnósticos: $totalDiagnosticos',
        name: 'PrioritizedDataLoader',
      );
    } catch (e) {
      developer.log(
        '⚠️ Erro ao obter estatísticas em background: $e',
        name: 'PrioritizedDataLoader',
      );
    }
  }

  /// Getters para status de carregamento
  static bool get isPriorityDataLoaded => _isPriorityDataLoaded;
  static bool get isBackgroundDataLoaded => _isBackgroundDataLoaded;

  /// Reset flags (útil para testes)
  static void reset() {
    _isPriorityDataLoaded = false;
    _isBackgroundDataLoaded = false;
  }
}
