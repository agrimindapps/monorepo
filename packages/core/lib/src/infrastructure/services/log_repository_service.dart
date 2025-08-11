import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/log_entry.dart';
import '../../shared/enums/log_level.dart';

/// Sistema completo de captura, armazenamento e visualização de logs
/// Implementa logging com múltiplos níveis, persistência local, filtragem avançada
/// e capacidades de exportação, ideal para debug e monitoramento de aplicações
class LogRepositoryService {
  static LogRepositoryService? _instance;
  static const String _prefsKey = 'app_logs';
  static const int _maxLogs = 10000;
  static const int _rotationThreshold = 8000;

  final List<LogEntry> _logs = [];
  final StreamController<LogEntry> _logStreamController = 
      StreamController<LogEntry>.broadcast();

  LogRepositoryService._internal();

  /// Singleton instance
  static LogRepositoryService get instance {
    _instance ??= LogRepositoryService._internal();
    return _instance!;
  }

  /// Stream de logs em tempo real
  Stream<LogEntry> get logStream => _logStreamController.stream;

  /// Todos os logs em memória
  List<LogEntry> get allLogs => List.unmodifiable(_logs);

  /// Inicializa o serviço carregando logs persistidos
  Future<void> init() async {
    await _loadPersistedLogs();
  }

  /// Log de informação geral
  void info(String message, {String? context}) {
    log(message, level: LogLevel.info, context: context);
  }

  /// Log de aviso
  void warning(String message, {String? context}) {
    log(message, level: LogLevel.warning, context: context);
  }

  /// Log de erro
  void error(String message, {String? context}) {
    log(message, level: LogLevel.error, context: context);
  }

  /// Log de debug
  void debug(String message, {String? context}) {
    log(message, level: LogLevel.debug, context: context);
  }

  /// Método principal de logging
  void log(
    String message, {
    LogLevel level = LogLevel.info,
    String? context,
  }) {
    final entry = LogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      descricao: message,
      hora: DateTime.now(),
      level: level,
      context: context,
      createdAt: DateTime.now(),
    );

    _addLogEntry(entry);
  }

  /// Adiciona entrada de log ao sistema
  void _addLogEntry(LogEntry entry) {
    // Adicionar à lista em memória
    _logs.add(entry);
    
    // Emitir no stream para observadores
    _logStreamController.add(entry);

    // Output para console em debug mode
    if (kDebugMode) {
      _printToConsole(entry);
    }

    // Rotação automática se necessário
    if (_logs.length > _maxLogs) {
      _rotateLogs();
    }

    // Persistir assincronamente
    _persistLogs();
  }

  /// Imprime log no console com formatação
  void _printToConsole(LogEntry entry) {
    final levelStr = entry.level.name.toUpperCase().padRight(7);
    final contextStr = entry.context != null ? '[${entry.context}] ' : '';
    final timeStr = entry.hora.toIso8601String().substring(11, 23); // HH:mm:ss.SSS
    
    print('$levelStr [$timeStr] $contextStr${entry.descricao}');
  }

  /// Remove logs antigos quando limite é excedido
  void _rotateLogs() {
    final logsToRemove = _logs.length - _rotationThreshold;
    if (logsToRemove > 0) {
      _logs.removeRange(0, logsToRemove);
      info('Log rotation: removed $logsToRemove old entries', context: 'LogService');
    }
  }

  /// Recupera logs com filtros opcionais
  Future<List<LogEntry>> getLogs({
    LogLevel? filterLevel,
    String? searchText,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var filteredLogs = List<LogEntry>.from(_logs);

    // Filtro por nível
    if (filterLevel != null) {
      filteredLogs = filteredLogs
          .where((log) => log.level == filterLevel)
          .toList();
    }

    // Filtro por texto
    if (searchText != null && searchText.isNotEmpty) {
      final searchLower = searchText.toLowerCase();
      filteredLogs = filteredLogs.where((log) {
        return log.descricao.toLowerCase().contains(searchLower) ||
            (log.context?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    // Filtro por data inicial
    if (startDate != null) {
      filteredLogs = filteredLogs
          .where((log) => log.hora.isAfter(startDate) || log.hora.isAtSameMomentAs(startDate))
          .toList();
    }

    // Filtro por data final
    if (endDate != null) {
      filteredLogs = filteredLogs
          .where((log) => log.hora.isBefore(endDate) || log.hora.isAtSameMomentAs(endDate))
          .toList();
    }

    // Ordenar por data (mais recentes primeiro)
    filteredLogs.sort((a, b) => b.hora.compareTo(a.hora));

    return filteredLogs;
  }

  /// Limpa todos os logs
  Future<void> clearLogs() async {
    _logs.clear();
    await _clearPersistedLogs();
    info('Logs cleared by user', context: 'LogService');
  }

  /// Exporta logs para arquivo
  Future<File> exportLogs({
    LogLevel? filterLevel,
    String? searchText,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final logs = await getLogs(
      filterLevel: filterLevel,
      searchText: searchText,
      startDate: startDate,
      endDate: endDate,
    );

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'logs_export_$timestamp.txt';
    final file = File('${directory.path}/$fileName');

    final buffer = StringBuffer();
    buffer.writeln('# Log Export - ${DateTime.now().toIso8601String()}');
    buffer.writeln('# Total entries: ${logs.length}');
    buffer.writeln('# Filters applied:');
    if (filterLevel != null) buffer.writeln('#   Level: ${filterLevel.name}');
    if (searchText?.isNotEmpty == true) buffer.writeln('#   Search: $searchText');
    if (startDate != null) buffer.writeln('#   Start: ${startDate.toIso8601String()}');
    if (endDate != null) buffer.writeln('#   End: ${endDate.toIso8601String()}');
    buffer.writeln('# ==========================================');
    buffer.writeln();

    for (final log in logs) {
      buffer.writeln(log.toFormattedString());
    }

    await file.writeAsString(buffer.toString());
    
    info('Logs exported to: ${file.path}', context: 'LogService');
    return file;
  }

  /// Carrega logs persistidos do SharedPreferences
  Future<void> _loadPersistedLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getStringList(_prefsKey);
      
      if (logsJson != null) {
        for (final logJson in logsJson) {
          try {
            final logMap = jsonDecode(logJson) as Map<String, dynamic>;
            final entry = LogEntry.fromJson(logMap);
            _logs.add(entry);
          } catch (e) {
            // Ignora logs corrompidos
            if (kDebugMode) {
              print('Failed to parse persisted log: $e');
            }
          }
        }
        
        // Ordenar por data
        _logs.sort((a, b) => a.hora.compareTo(b.hora));
        
        info('Loaded ${_logs.length} persisted logs', context: 'LogService');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load persisted logs: $e');
      }
    }
  }

  /// Persiste logs no SharedPreferences
  Future<void> _persistLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Converter logs para JSON (apenas os últimos 1000 para não sobrecarregar)
      final logsToSave = _logs.length > 1000 
          ? _logs.sublist(_logs.length - 1000)
          : _logs;
          
      final logsJson = logsToSave
          .map((log) => jsonEncode(log.toJson()))
          .toList();
      
      await prefs.setStringList(_prefsKey, logsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to persist logs: $e');
      }
    }
  }

  /// Limpa logs persistidos
  Future<void> _clearPersistedLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to clear persisted logs: $e');
      }
    }
  }

  /// Obtém estatísticas dos logs
  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    final last24h = now.subtract(const Duration(days: 1));
    final last7days = now.subtract(const Duration(days: 7));

    final stats = {
      'total': _logs.length,
      'last24h': _logs.where((log) => log.hora.isAfter(last24h)).length,
      'last7days': _logs.where((log) => log.hora.isAfter(last7days)).length,
      'byLevel': <String, int>{},
      'byContext': <String, int>{},
    };

    // Contar por nível
    final byLevelMap = stats['byLevel'] as Map<String, int>;
    for (final level in LogLevel.values) {
      byLevelMap[level.name] = _logs
          .where((log) => log.level == level)
          .length;
    }

    // Contar por contexto
    final contextCounts = <String, int>{};
    for (final log in _logs) {
      final context = log.context ?? 'No Context';
      contextCounts[context] = (contextCounts[context] ?? 0) + 1;
    }
    stats['byContext'] = contextCounts;

    return stats;
  }

  /// Finaliza o serviço
  void dispose() {
    _logStreamController.close();
  }
}

/// Instância global do serviço de logs
final csLogs = LogRepositoryService.instance;