import 'package:core/core.dart' hide getIt, ConflictResolutionStrategy;

import '../../../../core/data/models/conflict_history_model.dart';
import '../../../../core/services/conflict_history_service.dart';
import '../../../../core/sync/conflict_resolution_strategy.dart';
import '../../../../core/sync/conflict_resolver.dart';

part 'conflict_notifier.g.dart';

/// State para gerenciamento de conflitos de sincronização
class ConflictState {
  final List<ConflictHistoryModel> conflicts;
  final bool isLoading;
  final String? errorMessage;

  const ConflictState({
    this.conflicts = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ConflictState copyWith({
    List<ConflictHistoryModel>? conflicts,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ConflictState(
      conflicts: conflicts ?? this.conflicts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier para gerenciamento de conflitos de sincronização
@riverpod
class ConflictNotifier extends _$ConflictNotifier {
  late final ConflictHistoryService _conflictHistoryService;
  late final ConflictResolver _conflictResolver;

  @override
  Future<ConflictState> build() async {
    _conflictHistoryService = ref.read(conflictHistoryServiceProvider);
    _conflictResolver = ref.read(conflictResolverProvider);
    try {
      final conflicts = _conflictHistoryService.getAllConflicts();
      return ConflictState(conflicts: conflicts);
    } catch (e) {
      return ConflictState(
        errorMessage: 'Erro ao carregar histórico de conflitos: $e',
      );
    }
  }

  /// Carrega todos os conflitos históricos
  Future<void> loadConflicts() async {
    state = AsyncValue.data(
      (state.valueOrNull ?? const ConflictState()).copyWith(isLoading: true),
    );

    try {
      final conflicts = _conflictHistoryService.getAllConflicts();

      state = AsyncValue.data(
        ConflictState(conflicts: conflicts, isLoading: false),
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.valueOrNull ?? const ConflictState()).copyWith(
          errorMessage: 'Erro ao carregar histórico de conflitos: $e',
          isLoading: false,
        ),
      );
    }
  }

  /// Resolve um conflito com uma estratégia específica
  Future<dynamic> resolveConflict(
    ConflictData conflictData, {
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.newerWins,
  }) async {
    state = AsyncValue.data(
      (state.valueOrNull ?? const ConflictState()).copyWith(isLoading: true),
    );

    try {
      final resolvedData = _conflictResolver.resolveConflict(
        conflictData,
        strategy: strategy,
      );

      final conflictHistory = ConflictHistoryModel.create(
        modelType: conflictData.modelType,
        modelId: conflictData.localData.id as String,
        resolutionStrategy: strategy.toString(),
        localData: conflictData.localData.toMap() as Map<String, dynamic>,
        remoteData: conflictData.remoteData.toMap() as Map<String, dynamic>,
        resolvedData: resolvedData.toMap() as Map<String, dynamic>,
        autoResolved: strategy != ConflictResolutionStrategy.manual,
      );

      await _conflictHistoryService.saveConflict(conflictHistory);

      state = AsyncValue.data(
        (state.valueOrNull ?? const ConflictState()).copyWith(isLoading: false),
      );

      return resolvedData;
    } catch (e) {
      state = AsyncValue.data(
        (state.valueOrNull ?? const ConflictState()).copyWith(
          errorMessage: 'Erro ao resolver conflito: $e',
          isLoading: false,
        ),
      );
      rethrow;
    }
  }

  Future<void> clearConflictHistory() async {
    state = AsyncValue.data(
      (state.valueOrNull ?? const ConflictState()).copyWith(isLoading: true),
    );

    try {
      await _conflictHistoryService.clearConflictHistory();

      state = const AsyncValue.data(
        ConflictState(conflicts: [], isLoading: false),
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.valueOrNull ?? const ConflictState()).copyWith(
          errorMessage: 'Erro ao limpar histórico de conflitos: $e',
          isLoading: false,
        ),
      );
    }
  }
}

@riverpod
ConflictHistoryService conflictHistoryService(Ref ref) {
  return GetIt.instance<ConflictHistoryService>();
}

@riverpod
ConflictResolver conflictResolver(Ref ref) {
  return GetIt.instance<ConflictResolver>();
}
