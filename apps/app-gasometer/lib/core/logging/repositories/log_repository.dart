import 'package:dartz/dartz.dart';
import '../../error/failures.dart';
import '../entities/log_entry.dart';

abstract class LogRepository {
  /// Salva um log entry localmente
  Future<Either<Failure, Unit>> saveLog(LogEntry logEntry);

  /// Salva múltiplos logs localmente
  Future<Either<Failure, Unit>> saveLogs(List<LogEntry> logEntries);

  /// Obtém todos os logs locais
  Future<Either<Failure, List<LogEntry>>> getAllLogs();

  /// Obtém logs por categoria
  Future<Either<Failure, List<LogEntry>>> getLogsByCategory(String category);

  /// Obtém logs por período
  Future<Either<Failure, List<LogEntry>>> getLogsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Obtém logs não sincronizados
  Future<Either<Failure, List<LogEntry>>> getUnsyncedLogs();

  /// Marca logs como sincronizados
  Future<Either<Failure, Unit>> markLogsAsSynced(List<String> logIds);

  /// Limpa logs antigos (mais de X dias)
  Future<Either<Failure, Unit>> cleanOldLogs({int daysToKeep = 30});

  /// Obtém estatísticas dos logs
  Future<Either<Failure, Map<String, dynamic>>> getLogStatistics();

  /// Sincroniza logs com Firebase (remoto)
  Future<Either<Failure, Unit>> syncLogsToRemote(List<LogEntry> logs);

  /// Deleta um log específico
  Future<Either<Failure, Unit>> deleteLog(String logId);

  /// Deleta todos os logs
  Future<Either<Failure, Unit>> deleteAllLogs();

  /// Busca logs por texto
  Future<Either<Failure, List<LogEntry>>> searchLogs(String query);

  /// Obtém logs com erro
  Future<Either<Failure, List<LogEntry>>> getErrorLogs();

  /// Obtém logs por operação
  Future<Either<Failure, List<LogEntry>>> getLogsByOperation(String operation);

  /// Exporta logs para JSON
  Future<Either<Failure, String>> exportLogsToJson();
}