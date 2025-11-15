import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

/// Resultado de uma fase de sincronização
class SyncPhaseResult {
  final int successCount;
  final int failureCount;
  final List<String> errors;
  final Duration duration;

  SyncPhaseResult({
    required this.successCount,
    required this.failureCount,
    required this.errors,
    required this.duration,
  });
}

/// Interface para fase de push de sincronização
/// 
/// Segregada conforme ISP - apenas responsável por operações de push
/// Coordena múltiplos adapters de sincronização
abstract class ISyncPushService {
  /// Executa fase de push para todos os tipos de dados
  Future<Either<Failure, SyncPhaseResult>> pushAll(String userId);

  /// Executa fase de push para tipo específico
  Future<Either<Failure, SyncPhaseResult>> pushByType(String userId, String entityType);
}
