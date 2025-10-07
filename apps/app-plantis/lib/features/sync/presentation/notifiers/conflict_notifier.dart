import 'package:core/core.dart' hide getIt, ConflictResolutionStrategy;

import '../../../../core/data/models/conflict_history_model.dart';
import '../../../../core/services/conflict_history_service.dart';
import '../../../../core/sync/conflict_resolution_strategy.dart';
import '../../../../core/sync/conflict_resolver.dart';

part 'conflict_notifier.g.dart';

/// State para gerenciamento de conflitos de sincronização
class ConflictState {
  final List<ConflictHistoryModel> conflicts;

  const ConflictState({
    this.conflicts = const [],
  });

  ConflictState copyWith({
    List<ConflictHistoryModel>? conflicts,
  }) {
    return ConflictState(
      conflicts: conflicts ?? this.conflicts,
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
    final conflicts = _conflictHistoryService.getAllConflicts();
    return ConflictState(conflicts: conflicts);
  }

  /// Carrega todos os conflitos históricos
  Future<void> loadConflicts() async {
    ref.invalidateSelf();
    await future;
  }

  /// Resolve um conflito com uma estratégia específica
  Future<dynamic> resolveConflict(
    ConflictData conflictData, {
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.newerWins,
  }) async {
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
    ref.invalidateSelf();
    return resolvedData;
  }

  Future<void> clearConflictHistory() async {
    await _conflictHistoryService.clearConflictHistory();
    ref.invalidateSelf();
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
