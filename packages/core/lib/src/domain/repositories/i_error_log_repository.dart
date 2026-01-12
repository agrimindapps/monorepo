import 'package:dartz/dartz.dart';

import '../../shared/enums/error_severity.dart';
import '../../shared/utils/failure.dart';
import '../entities/error_log_entity.dart';

/// Interface do repositório de logs de erro
///
/// Define as operações disponíveis para gerenciar logs de erro web.
/// A implementação concreta usa Firebase Firestore.
abstract class IErrorLogRepository {
  /// Registra um novo erro
  ///
  /// Qualquer usuário pode registrar (erros automáticos).
  /// Retorna o ID do erro criado em caso de sucesso.
  Future<Either<Failure, String>> logError(ErrorLogEntity error);

  /// Incrementa ocorrências de um erro existente (deduplicação)
  ///
  /// Usado quando um erro com mesmo hash já existe.
  Future<Either<Failure, void>> incrementOccurrences(String errorHash);

  /// Busca erro por hash (para deduplicação)
  Future<Either<Failure, ErrorLogEntity?>> getErrorByHash(String errorHash);

  /// Lista todos os erros (apenas admin autenticado)
  ///
  /// Suporta paginação e filtros opcionais.
  Future<Either<Failure, List<ErrorLogEntity>>> getErrors({
    ErrorStatus? status,
    ErrorType? type,
    ErrorSeverity? severity,
    String? calculatorId,
    int limit = 50,
    String? lastDocumentId,
  });

  /// Obtém um erro específico por ID (apenas admin)
  Future<Either<Failure, ErrorLogEntity>> getErrorById(String id);

  /// Atualiza o status de um erro (apenas admin)
  Future<Either<Failure, void>> updateErrorStatus(
    String id,
    ErrorStatus status, {
    String? adminNotes,
  });

  /// Atualiza a severidade de um erro (apenas admin)
  Future<Either<Failure, void>> updateErrorSeverity(
    String id,
    ErrorSeverity severity,
  );

  /// Deleta um erro (apenas admin)
  Future<Either<Failure, void>> deleteError(String id);

  /// Deleta múltiplos erros (apenas admin)
  Future<Either<Failure, void>> deleteErrors(List<String> ids);

  /// Stream de erros em tempo real (apenas admin)
  Stream<Either<Failure, List<ErrorLogEntity>>> watchErrors({
    ErrorStatus? status,
    ErrorType? type,
    ErrorSeverity? severity,
    int limit = 50,
  });

  /// Obtém contagem de erros por status (apenas admin)
  Future<Either<Failure, Map<ErrorStatus, int>>> getErrorCounts();

  /// Obtém contagem de erros por tipo (apenas admin)
  Future<Either<Failure, Map<ErrorType, int>>> getErrorCountsByType();

  /// Obtém erros agrupados por calculadora (apenas admin)
  Future<Either<Failure, Map<String, int>>> getErrorsByCalculator();

  /// Limpa erros antigos (retenção)
  ///
  /// Remove erros com status 'fixed' ou 'ignored' mais antigos que [days] dias.
  Future<Either<Failure, int>> cleanupOldErrors(int days);
}
