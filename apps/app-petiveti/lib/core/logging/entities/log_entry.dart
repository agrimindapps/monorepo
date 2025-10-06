
import 'package:core/core.dart';

@HiveType(typeId: 100)
class LogEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final LogLevel level;

  @HiveField(3)
  final LogCategory category;

  @HiveField(4)
  final LogOperation operation;

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
  final Duration? duration;

  LogEntry({
    required this.id,
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
  });

  factory LogEntry.info({
    required String id,
    required LogCategory category,
    required LogOperation operation,
    required String message,
    Map<String, dynamic>? metadata,
    String? userId,
    Duration? duration,
  }) {
    return LogEntry(
      id: id,
      timestamp: DateTime.now(),
      level: LogLevel.info,
      category: category,
      operation: operation,
      message: message,
      metadata: metadata,
      userId: userId,
      duration: duration,
    );
  }

  factory LogEntry.warning({
    required String id,
    required LogCategory category,
    required LogOperation operation,
    required String message,
    Map<String, dynamic>? metadata,
    String? userId,
    Duration? duration,
  }) {
    return LogEntry(
      id: id,
      timestamp: DateTime.now(),
      level: LogLevel.warning,
      category: category,
      operation: operation,
      message: message,
      metadata: metadata,
      userId: userId,
      duration: duration,
    );
  }

  factory LogEntry.error({
    required String id,
    required LogCategory category,
    required LogOperation operation,
    required String message,
    required String error,
    String? stackTrace,
    Map<String, dynamic>? metadata,
    String? userId,
    Duration? duration,
  }) {
    return LogEntry(
      id: id,
      timestamp: DateTime.now(),
      level: LogLevel.error,
      category: category,
      operation: operation,
      message: message,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
      userId: userId,
      duration: duration,
    );
  }

  @override
  String toString() {
    return '${timestamp.toIso8601String()} [${level.name.toUpperCase()}] ${category.name.toUpperCase()}.${operation.name.toUpperCase()}: $message${error != null ? ' - Error: $error' : ''}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'category': category.name,
      'operation': operation.name,
      'message': message,
      'metadata': metadata,
      'userId': userId,
      'error': error,
      'stackTrace': stackTrace,
      'duration': duration?.inMilliseconds,
    };
  }
}

@HiveType(typeId: 101)
enum LogLevel {
  @HiveField(0)
  info,

  @HiveField(1)
  warning,

  @HiveField(2)
  error,
}

@HiveType(typeId: 102)
enum LogCategory {
  @HiveField(0)
  animals,

  @HiveField(1)
  appointments,

  @HiveField(2)
  auth,

  @HiveField(3)
  calculators,

  @HiveField(4)
  expenses,

  @HiveField(5)
  medications,

  @HiveField(6)
  reminders,

  @HiveField(7)
  subscriptions,

  @HiveField(8)
  vaccines,

  @HiveField(9)
  weight,

  @HiveField(10)
  system,

  @HiveField(11)
  performance,

  @HiveField(12)
  network,

  @HiveField(13)
  storage,
}

@HiveType(typeId: 103)
enum LogOperation {
  @HiveField(0)
  create,

  @HiveField(1)
  read,

  @HiveField(2)
  update,

  @HiveField(3)
  delete,

  @HiveField(4)
  sync,

  @HiveField(5)
  login,

  @HiveField(6)
  logout,

  @HiveField(7)
  register,

  @HiveField(8)
  validate,

  @HiveField(9)
  calculate,

  @HiveField(10)
  notification,

  @HiveField(11)
  backup,

  @HiveField(12)
  restore,

  @HiveField(13)
  import,

  @HiveField(14)
  export,
}
