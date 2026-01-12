import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/enums/error_severity.dart';
import '../../../domain/entities/error_log_entity.dart';
import '../../../domain/repositories/i_error_log_repository.dart';
import '../../../infrastructure/services/firebase_error_log_service.dart';

/// Provider para o serviço de error log
final errorLogServiceProvider = Provider<IErrorLogRepository>((ref) {
  return FirebaseErrorLogService();
});

/// Provider para registrar erro (qualquer usuário/automático)
final logErrorProvider = FutureProvider.family<String?, ErrorLogEntity>((
  ref,
  error,
) async {
  final service = ref.read(errorLogServiceProvider);
  final result = await service.logError(error);
  return result.fold((failure) => throw Exception(failure.message), (id) => id);
});

/// Provider para listar erros (apenas admin)
final errorLogListProvider =
    FutureProvider.family<List<ErrorLogEntity>, ErrorLogFilters>((
      ref,
      filters,
    ) async {
      final service = ref.read(errorLogServiceProvider);
      final result = await service.getErrors(
        status: filters.status,
        type: filters.type,
        severity: filters.severity,
        calculatorId: filters.calculatorId,
        limit: filters.limit,
        lastDocumentId: filters.lastDocumentId,
      );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (errors) => errors,
      );
    });

/// Provider para stream de erros em tempo real (admin)
final errorLogStreamProvider =
    StreamProvider.family<List<ErrorLogEntity>, ErrorLogFilters>((
      ref,
      filters,
    ) {
      final service = ref.read(errorLogServiceProvider);
      return service
          .watchErrors(
            status: filters.status,
            type: filters.type,
            severity: filters.severity,
            limit: filters.limit,
          )
          .map(
            (result) => result.fold(
              (failure) => throw Exception(failure.message),
              (errors) => errors,
            ),
          );
    });

/// Provider para contagem de erros por status
final errorLogCountsProvider = FutureProvider<Map<ErrorStatus, int>>((
  ref,
) async {
  final service = ref.read(errorLogServiceProvider);
  final result = await service.getErrorCounts();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (counts) => counts,
  );
});

/// Provider para contagem de erros por tipo
final errorLogCountsByTypeProvider = FutureProvider<Map<ErrorType, int>>((
  ref,
) async {
  final service = ref.read(errorLogServiceProvider);
  final result = await service.getErrorCountsByType();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (counts) => counts,
  );
});

/// Provider para erros agrupados por calculadora
final errorsByCalculatorProvider = FutureProvider<Map<String, int>>((
  ref,
) async {
  final service = ref.read(errorLogServiceProvider);
  final result = await service.getErrorsByCalculator();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (counts) => counts,
  );
});

/// Provider para obter um erro específico
final errorLogByIdProvider = FutureProvider.family<ErrorLogEntity, String>((
  ref,
  id,
) async {
  final service = ref.read(errorLogServiceProvider);
  final result = await service.getErrorById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (error) => error,
  );
});

/// Classe para filtros de error log
class ErrorLogFilters {
  const ErrorLogFilters({
    this.status,
    this.type,
    this.severity,
    this.calculatorId,
    this.limit = 50,
    this.lastDocumentId,
  });

  final ErrorStatus? status;
  final ErrorType? type;
  final ErrorSeverity? severity;
  final String? calculatorId;
  final int limit;
  final String? lastDocumentId;

  ErrorLogFilters copyWith({
    ErrorStatus? status,
    ErrorType? type,
    ErrorSeverity? severity,
    String? calculatorId,
    int? limit,
    String? lastDocumentId,
  }) {
    return ErrorLogFilters(
      status: status ?? this.status,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      calculatorId: calculatorId ?? this.calculatorId,
      limit: limit ?? this.limit,
      lastDocumentId: lastDocumentId ?? this.lastDocumentId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ErrorLogFilters &&
        other.status == status &&
        other.type == type &&
        other.severity == severity &&
        other.calculatorId == calculatorId &&
        other.limit == limit &&
        other.lastDocumentId == lastDocumentId;
  }

  @override
  int get hashCode =>
      Object.hash(status, type, severity, calculatorId, limit, lastDocumentId);
}

/// Notifier para gerenciar ações de error log (admin)
class ErrorLogActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  IErrorLogRepository get _service => ref.read(errorLogServiceProvider);

  /// Atualiza o status de um erro
  Future<bool> updateStatus(
    String id,
    ErrorStatus status, {
    String? adminNotes,
  }) async {
    state = const AsyncValue<void>.loading();
    final result = await _service.updateErrorStatus(
      id,
      status,
      adminNotes: adminNotes,
    );
    return result.fold(
      (failure) {
        state = AsyncValue<void>.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue<void>.data(null);
        return true;
      },
    );
  }

  /// Atualiza a severidade de um erro
  Future<bool> updateSeverity(String id, ErrorSeverity severity) async {
    state = const AsyncValue<void>.loading();
    final result = await _service.updateErrorSeverity(id, severity);
    return result.fold(
      (failure) {
        state = AsyncValue<void>.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue<void>.data(null);
        return true;
      },
    );
  }

  /// Deleta um erro
  Future<bool> delete(String id) async {
    state = const AsyncValue<void>.loading();
    final result = await _service.deleteError(id);
    return result.fold(
      (failure) {
        state = AsyncValue<void>.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue<void>.data(null);
        return true;
      },
    );
  }

  /// Deleta múltiplos erros
  Future<bool> deleteMultiple(List<String> ids) async {
    state = const AsyncValue<void>.loading();
    final result = await _service.deleteErrors(ids);
    return result.fold(
      (failure) {
        state = AsyncValue<void>.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue<void>.data(null);
        return true;
      },
    );
  }

  /// Limpa erros antigos
  Future<int> cleanup(int days) async {
    state = const AsyncValue<void>.loading();
    final result = await _service.cleanupOldErrors(days);
    return result.fold(
      (failure) {
        state = AsyncValue<void>.error(failure.message, StackTrace.current);
        return 0;
      },
      (count) {
        state = const AsyncValue<void>.data(null);
        return count;
      },
    );
  }
}

/// Provider para ações de error log (admin)
final errorLogActionsProvider =
    NotifierProvider<ErrorLogActionsNotifier, AsyncValue<void>>(
      ErrorLogActionsNotifier.new,
    );
