/// STUB temporário para BoxManager durante migração Hive → Drift
///
/// Este arquivo fornece uma implementação stub do BoxManager que foi removido.
/// **NÃO USE EM PRODUÇÃO** - Apenas para compilar durante migração.
///
/// TODO: Remover após migração completa dos serviços que usam BoxManager

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

/// @deprecated BoxManager foi removido - use Drift repositories
class BoxManager {
  const BoxManager._();

  /// Stub method - returns error
  static Future<Either<Failure, T>> withMultipleBoxes<T>({
    required IHiveManager hiveManager,
    required List<String> boxNames,
    required Future<T> Function(Map<String, dynamic>) operation,
  }) async {
    return Left(UnexpectedFailure('BoxManager not implemented - use Drift'));
  }
}
