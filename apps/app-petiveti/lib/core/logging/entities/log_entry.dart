
// Logging disabled - Hive removed from app-petiveti
// TODO: Implement Drift-based logging if needed in the future

class LogEntry {
  final String id;
  final DateTime timestamp;
  final LogLevel level;
  final LogCategory category;
  final LogOperation operation;
  final String message;
  final Map<String, dynamic>? metadata;
  final String? userId;
  final String? error;
  final String? stackTrace;
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

enum LogLevel {
  info,
  warning,
  error,
}

enum LogCategory {
  animals,
  appointments,
  auth,
  calculators,
  expenses,
  medications,
  reminders,
  subscriptions,
  vaccines,
  weight,
  system,
  performance,
  network,
  storage,
}

enum LogOperation {
  create,
  read,
  update,
  delete,
  sync,
  login,
  logout,
  register,
  validate,
  calculate,
  notification,
  backup,
  restore,
  import,
  export,
}
