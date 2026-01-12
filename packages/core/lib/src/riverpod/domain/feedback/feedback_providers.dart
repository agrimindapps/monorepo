import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/feedback_entity.dart';
import '../../../domain/repositories/i_feedback_repository.dart';
import '../../../infrastructure/services/firebase_feedback_service.dart';

/// Provider para o serviço de feedback
final feedbackServiceProvider = Provider<IFeedbackRepository>((ref) {
  return FirebaseFeedbackService();
});

/// Provider para enviar feedback (qualquer usuário)
final submitFeedbackProvider = FutureProvider.family<String?, FeedbackEntity>(
  (ref, feedback) async {
    final service = ref.read(feedbackServiceProvider);
    final result = await service.submitFeedback(feedback);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (id) => id,
    );
  },
);

/// Provider para listar feedbacks (apenas admin)
final feedbackListProvider = FutureProvider.family<List<FeedbackEntity>, FeedbackFilters>(
  (ref, filters) async {
    final service = ref.read(feedbackServiceProvider);
    final result = await service.getFeedbacks(
      status: filters.status,
      type: filters.type,
      limit: filters.limit,
      lastDocumentId: filters.lastDocumentId,
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (feedbacks) => feedbacks,
    );
  },
);

/// Provider para stream de feedbacks em tempo real (admin)
final feedbackStreamProvider = StreamProvider.family<List<FeedbackEntity>, FeedbackFilters>(
  (ref, filters) {
    final service = ref.read(feedbackServiceProvider);
    return service.watchFeedbacks(
      status: filters.status,
      type: filters.type,
      limit: filters.limit,
    ).map((result) => result.fold(
      (failure) => throw Exception(failure.message),
      (feedbacks) => feedbacks,
    ));
  },
);

/// Provider para contagem de feedbacks por status
final feedbackCountsProvider = FutureProvider<Map<FeedbackStatus, int>>((ref) async {
  final service = ref.read(feedbackServiceProvider);
  final result = await service.getFeedbackCounts();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (counts) => counts,
  );
});

/// Provider para obter um feedback específico
final feedbackByIdProvider = FutureProvider.family<FeedbackEntity, String>(
  (ref, id) async {
    final service = ref.read(feedbackServiceProvider);
    final result = await service.getFeedbackById(id);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (feedback) => feedback,
    );
  },
);

/// Classe para filtros de feedback
class FeedbackFilters {
  const FeedbackFilters({
    this.status,
    this.type,
    this.limit = 50,
    this.lastDocumentId,
  });

  final FeedbackStatus? status;
  final FeedbackType? type;
  final int limit;
  final String? lastDocumentId;

  FeedbackFilters copyWith({
    FeedbackStatus? status,
    FeedbackType? type,
    int? limit,
    String? lastDocumentId,
  }) {
    return FeedbackFilters(
      status: status ?? this.status,
      type: type ?? this.type,
      limit: limit ?? this.limit,
      lastDocumentId: lastDocumentId ?? this.lastDocumentId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedbackFilters &&
        other.status == status &&
        other.type == type &&
        other.limit == limit &&
        other.lastDocumentId == lastDocumentId;
  }

  @override
  int get hashCode => Object.hash(status, type, limit, lastDocumentId);
}

/// Notifier para gerenciar ações de feedback (admin)
class FeedbackActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  IFeedbackRepository get _service => ref.read(feedbackServiceProvider);

  /// Atualiza o status de um feedback
  Future<bool> updateStatus(
    String id,
    FeedbackStatus status, {
    String? adminNotes,
  }) async {
    state = const AsyncValue<void>.loading();
    final result = await _service.updateFeedbackStatus(
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

  /// Deleta um feedback
  Future<bool> delete(String id) async {
    state = const AsyncValue<void>.loading();
    final result = await _service.deleteFeedback(id);
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
}

/// Provider para ações de feedback (admin)
final feedbackActionsProvider =
    NotifierProvider<FeedbackActionsNotifier, AsyncValue<void>>(
  FeedbackActionsNotifier.new,
);
