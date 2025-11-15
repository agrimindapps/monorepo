import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'i_sync_push_service.dart';

/// Interface para fase de pull de sincronização
/// 
/// Segregada conforme ISP - apenas responsável por operações de pull
/// Coordena múltiplos adapters de sincronização
abstract class ISyncPullService {
  /// Executa fase de pull para todos os tipos de dados
  Future<Either<Failure, SyncPhaseResult>> pullAll(String userId);

  /// Executa fase de pull para tipo específico
  Future<Either<Failure, SyncPhaseResult>> pullByType(String userId, String entityType);
}
