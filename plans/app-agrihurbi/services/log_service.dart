// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../theme/agrihurbi_theme.dart';

/// Níveis de log disponíveis
enum LogLevel {
  debug,    // Informações de desenvolvimento
  info,     // Informações gerais
  warning,  // Avisos que não impedem o funcionamento
  error,    // Erros que podem afetar a funcionalidade
  critical, // Erros críticos que podem quebrar a aplicação
}

/// Configuração do sistema de logs
class LogConfig {
  static bool enableDebugLogs = kDebugMode;
  static bool enableInfoLogs = true;
  static bool enableWarningLogs = true;
  static bool enableErrorLogs = true;
  static bool enableCriticalLogs = true;
  static bool logToFile = false;
  static bool showLogOverlay = false;
}

/// Serviço centralizado de logs para o módulo AgriHurbi
/// 
/// Substitui debugPrint por um sistema mais robusto com níveis
/// e controle de exibição em produção
class LogService {
  static final List<LogEntry> _logs = [];
  static const int maxLogEntries = 1000;

  /// Log de debug - apenas em modo desenvolvimento
  static void debug(String message, {String? tag, Object? data}) {
    if (!LogConfig.enableDebugLogs) return;
    _log(LogLevel.debug, message, tag: tag, data: data);
  }

  /// Log de informação - eventos normais do sistema
  static void info(String message, {String? tag, Object? data}) {
    if (!LogConfig.enableInfoLogs) return;
    _log(LogLevel.info, message, tag: tag, data: data);
  }

  /// Log de aviso - situações que merecem atenção
  static void warning(String message, {String? tag, Object? data}) {
    if (!LogConfig.enableWarningLogs) return;
    _log(LogLevel.warning, message, tag: tag, data: data);
  }

  /// Log de erro - problemas que afetam funcionalidade
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (!LogConfig.enableErrorLogs) return;
    _log(LogLevel.error, message, tag: tag, data: error, stackTrace: stackTrace);
  }

  /// Log crítico - erros graves que podem quebrar a aplicação
  static void critical(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (!LogConfig.enableCriticalLogs) return;
    _log(LogLevel.critical, message, tag: tag, data: error, stackTrace: stackTrace);
  }

  /// Método interno para processamento dos logs
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? data,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      level: level,
      message: message,
      tag: tag ?? 'AgriHurbi',
      data: data,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );

    // Adiciona ao buffer interno
    _logs.add(entry);
    if (_logs.length > maxLogEntries) {
      _logs.removeAt(0);
    }

    // Output no console (apenas em debug)
    if (kDebugMode) {
      final formattedMessage = _formatLogMessage(entry);
      debugPrint(formattedMessage);
    }

    // Log remoto (apenas erros e críticos em produção)
    if (!kDebugMode && (level == LogLevel.error || level == LogLevel.critical)) {
      _logToRemote(entry);
    }
  }

  /// Formata a mensagem de log para exibição
  static String _formatLogMessage(LogEntry entry) {
    final timestamp = _formatTimestamp(entry.timestamp);
    final levelStr = entry.level.name.toUpperCase().padRight(8);
    final tag = entry.tag.padRight(15);
    
    var message = '[$timestamp] [$levelStr] [$tag] ${entry.message}';
    
    if (entry.data != null) {
      message += '\n  Data: ${entry.data}';
    }
    
    if (entry.stackTrace != null) {
      message += '\n  Stack: ${entry.stackTrace.toString().split('\n').take(5).join('\n  ')}';
    }
    
    return message;
  }

  /// Formata timestamp para logs
  static String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}.'
           '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }

  /// Envia logs para serviço remoto (placeholder)
  static void _logToRemote(LogEntry entry) {
    // TODO: Implementar integração com serviço de logging remoto
    // (Firebase Crashlytics, Sentry, etc.)
  }

  /// Logs específicos para diferentes contextos do AgriHurbi
  
  // Bovinos e Equinos
  static void logAnimal(String action, String animalType, {String? animalId, Object? data}) {
    info('$action $animalType', tag: 'Animal', data: {'id': animalId, 'data': data});
  }

  // Pluviometria
  static void logMedicao(String action, {String? pluviometroId, double? quantidade}) {
    info('$action medição', tag: 'Medicao', data: {'pluviometro': pluviometroId, 'quantidade': quantidade});
  }

  // Calculadoras
  static void logCalculation(String calculatorType, Map<String, dynamic> inputs, dynamic result) {
    info('Cálculo executado', tag: 'Calculator', data: {'type': calculatorType, 'inputs': inputs, 'result': result});
  }

  // Sincronização
  static void logSync(String action, {int? recordCount, String? error}) {
    if (error != null) {
      warning('Erro na sincronização: $error', tag: 'Sync');
    } else {
      info('$action - $recordCount registros', tag: 'Sync');
    }
  }

  // Upload de imagens
  static void logUpload(String fileName, {bool success = true, String? error}) {
    if (success) {
      info('Upload concluído: $fileName', tag: 'Upload');
    } else {
      LogService.error('Erro no upload: $fileName - $error', tag: 'Upload');
    }
  }

  // API calls
  static void logApiCall(String endpoint, {int? statusCode, String? method, Duration? duration}) {
    final durationStr = duration != null ? ' (${duration.inMilliseconds}ms)' : '';
    info('$method $endpoint - $statusCode$durationStr', tag: 'API');
  }

  // Database operations
  static void logDatabase(String operation, String table, {int? recordCount, String? error}) {
    if (error != null) {
      LogService.error('Erro no banco: $operation $table - $error', tag: 'DB');
    } else {
      debug('$operation $table - $recordCount registros', tag: 'DB');
    }
  }

  /// Utilitários para gerenciamento de logs
  
  /// Limpa o buffer de logs
  static void clearLogs() {
    _logs.clear();
  }

  /// Retorna todos os logs
  static List<LogEntry> getAllLogs() {
    return List.unmodifiable(_logs);
  }

  /// Retorna logs de um nível específico
  static List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }

  /// Retorna logs por tag
  static List<LogEntry> getLogsByTag(String tag) {
    return _logs.where((log) => log.tag == tag).toList();
  }

  /// Exporta logs como string
  static String exportLogs({LogLevel? minLevel, DateTime? since}) {
    var filteredLogs = _logs.where((log) => true);
    
    if (minLevel != null) {
      final minIndex = LogLevel.values.indexOf(minLevel);
      filteredLogs = filteredLogs.where((log) => 
        LogLevel.values.indexOf(log.level) >= minIndex);
    }
    
    if (since != null) {
      filteredLogs = filteredLogs.where((log) => 
        log.timestamp.isAfter(since));
    }
    
    return filteredLogs
        .map((entry) => _formatLogMessage(entry))
        .join('\n');
  }

  /// Conta logs por nível
  static Map<LogLevel, int> getLogCounts() {
    final counts = <LogLevel, int>{};
    for (final level in LogLevel.values) {
      counts[level] = _logs.where((log) => log.level == level).length;
    }
    return counts;
  }
}

/// Entrada de log
class LogEntry {
  final LogLevel level;
  final String message;
  final String tag;
  final Object? data;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  const LogEntry({
    required this.level,
    required this.message,
    required this.tag,
    this.data,
    this.stackTrace,
    required this.timestamp,
  });

  /// Cor do log baseada no nível
  Color get color {
    switch (level) {
      case LogLevel.debug:
        return AgrihurbiTheme.mutedTextColor;
      case LogLevel.info:
        return AgrihurbiTheme.infoColor;
      case LogLevel.warning:
        return AgrihurbiTheme.warningColor;
      case LogLevel.error:
        return AgrihurbiTheme.errorColor;
      case LogLevel.critical:
        return Colors.red.shade800;
    }
  }

  /// Ícone do log baseado no nível
  IconData get icon {
    switch (level) {
      case LogLevel.debug:
        return Icons.bug_report;
      case LogLevel.info:
        return Icons.info;
      case LogLevel.warning:
        return Icons.warning;
      case LogLevel.error:
        return Icons.error;
      case LogLevel.critical:
        return Icons.dangerous;
    }
  }
}

/// Widget para exibir logs na interface (modo debug)
class LogViewer extends StatelessWidget {
  final List<LogEntry> logs;
  final LogLevel? filterLevel;

  const LogViewer({
    super.key,
    required this.logs,
    this.filterLevel,
  });

  @override
  Widget build(BuildContext context) {
    final filteredLogs = filterLevel != null
        ? logs.where((log) => log.level == filterLevel).toList()
        : logs;

    return Container(
      decoration: AgrihurbiTheme.cardDecoration,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AgrihurbiTheme.space3),
            decoration: const BoxDecoration(
              color: AgrihurbiTheme.agriculturaPrimary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.list_alt, color: Colors.white),
                const SizedBox(width: AgrihurbiTheme.space2),
                Text(
                  'Logs (${filteredLogs.length})',
                  style: AgrihurbiTheme.titleMedium.copyWith(color: Colors.white),
                ),
                const Spacer(),
                if (kDebugMode)
                  const IconButton(
                    onPressed: LogService.clearLogs,
                    icon: Icon(Icons.clear, color: Colors.white, size: 18),
                    tooltip: 'Limpar logs',
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredLogs.length,
              itemBuilder: (context, index) {
                final log = filteredLogs[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AgrihurbiTheme.space3,
                    vertical: AgrihurbiTheme.space2,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AgrihurbiTheme.borderColor.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        log.icon,
                        size: 16,
                        color: log.color,
                      ),
                      const SizedBox(width: AgrihurbiTheme.space2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${LogService._formatTimestamp(log.timestamp)} [${log.tag}]',
                              style: AgrihurbiTheme.labelSmall,
                            ),
                            Text(
                              log.message,
                              style: AgrihurbiTheme.bodySmall.copyWith(
                                color: log.color,
                              ),
                            ),
                            if (log.data != null)
                              Text(
                                'Data: ${log.data}',
                                style: AgrihurbiTheme.labelSmall.copyWith(
                                  fontFamily: 'monospace',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}