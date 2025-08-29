import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'log_entry.g.dart';

@HiveType(typeId: 20)
class LogEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String level;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String operation;

  @HiveField(5)
  final String message;

  @HiveField(6)
  final Map<String, dynamic>? metadata;

  @HiveField(7)
  final String? userId;

  @HiveField(8)
  final String? error;

  @HiveField(9)
  final String? stackTrace;

  @HiveField(10)
  final int? duration; // milliseconds

  @HiveField(11)
  final bool synced;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.category,
    required this.operation,
    required this.message,
    this.metadata,
    this.userId,
    this.error,
    this.stackTrace,
    this.duration,
    this.synced = false,
    String? id,
  }) : id = id ?? const Uuid().v4();

  /// Factory para log de início de operação
  factory LogEntry.operationStart({
    required String category,
    required String operation,
    required String message,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    return LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.info.name,
      category: category,
      operation: operation,
      message: message,
      userId: userId,
      metadata: metadata,
    );
  }

  /// Factory para log de sucesso
  factory LogEntry.operationSuccess({
    required String category,
    required String operation,
    required String message,
    String? userId,
    Map<String, dynamic>? metadata,
    int? duration,
  }) {
    return LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.info.name,
      category: category,
      operation: operation,
      message: message,
      userId: userId,
      metadata: metadata,
      duration: duration,
    );
  }

  /// Factory para log de erro
  factory LogEntry.operationError({
    required String category,
    required String operation,
    required String message,
    String? userId,
    required String error,
    String? stackTrace,
    Map<String, dynamic>? metadata,
    int? duration,
  }) {
    return LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.error.name,
      category: category,
      operation: operation,
      message: message,
      userId: userId,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
      duration: duration,
    );
  }

  /// Factory para log de warning
  factory LogEntry.operationWarning({
    required String category,
    required String operation,
    required String message,
    String? userId,
    Map<String, dynamic>? metadata,
    int? duration,
  }) {
    return LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.warning.name,
      category: category,
      operation: operation,
      message: message,
      userId: userId,
      metadata: metadata,
      duration: duration,
    );
  }

  /// Copia com novos valores
  LogEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? level,
    String? category,
    String? operation,
    String? message,
    Map<String, dynamic>? metadata,
    String? userId,
    String? error,
    String? stackTrace,
    int? duration,
    bool? synced,
  }) {
    return LogEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      level: level ?? this.level,
      category: category ?? this.category,
      operation: operation ?? this.operation,
      message: message ?? this.message,
      metadata: metadata ?? this.metadata,
      userId: userId ?? this.userId,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      duration: duration ?? this.duration,
      synced: synced ?? this.synced,
    );
  }

  /// Converte para Map para analytics
  Map<String, dynamic> toAnalyticsMap() {
    return {
      'category': category,
      'operation': operation,
      'level': level,
      'user_id': userId,
      'duration_ms': duration,
      'has_error': error != null,
      ...?metadata,
    };
  }

  /// Converte para Map para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level,
      'category': category,
      'operation': operation,
      'message': message,
      'metadata': metadata,
      'userId': userId,
      'error': error,
      'stackTrace': stackTrace,
      'duration': duration,
      'synced': synced,
    };
  }

  /// Cria a partir de Map JSON
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: json['level'] as String,
      category: json['category'] as String,
      operation: json['operation'] as String,
      message: json['message'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      userId: json['userId'] as String?,
      error: json['error'] as String?,
      stackTrace: json['stackTrace'] as String?,
      duration: json['duration'] as int?,
      synced: json['synced'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'LogEntry{id: $id, timestamp: $timestamp, level: $level, '
        'category: $category, operation: $operation, message: $message}';
  }
}

/// Níveis de log disponíveis
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Categorias de log para o Gasometer
class LogCategory {
  static const String vehicles = 'VEHICLES';
  static const String maintenance = 'MAINTENANCE';
  static const String expenses = 'EXPENSES';
  static const String odometer = 'ODOMETER';
  static const String fuel = 'FUEL';
  static const String auth = 'AUTH';
  static const String sync = 'SYNC';
  static const String cache = 'CACHE';
  static const String analytics = 'ANALYTICS';
  static const String premium = 'PREMIUM';
  static const String reports = 'REPORTS';
}

/// Operações de log disponíveis
class LogOperation {
  static const String create = 'CREATE';
  static const String update = 'UPDATE';
  static const String delete = 'DELETE';
  static const String read = 'READ';
  static const String sync = 'SYNC';
  static const String validate = 'VALIDATE';
  static const String export = 'EXPORT';
  static const String import = 'IMPORT';
  static const String login = 'LOGIN';
  static const String logout = 'LOGOUT';
  static const String signup = 'SIGNUP';
}