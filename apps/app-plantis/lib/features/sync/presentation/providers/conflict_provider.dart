import 'package:flutter/foundation.dart';
import 'package:core/core.dart' show injectable;

import '../../../../core/data/models/conflict_history_model.dart';
import '../../../../core/services/conflict_history_service.dart';
import '../../../../core/sync/conflict_resolution_strategy.dart';
import '../../../../core/sync/conflict_resolver.dart';

class ConflictState {
  final List<ConflictHistoryModel> conflicts;
  final bool isLoading;
  final String? errorMessage;

  ConflictState({
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

@injectable
class ConflictProvider extends ChangeNotifier {
  final ConflictHistoryService _conflictHistoryService;
  final ConflictResolver _conflictResolver;

  ConflictState _state = ConflictState();
  ConflictState get state => _state;

  ConflictProvider(this._conflictHistoryService, this._conflictResolver);

  /// Carrega todos os conflitos históricos
  Future<void> loadConflicts() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final conflicts = _conflictHistoryService.getAllConflicts();
      _state = _state.copyWith(conflicts: conflicts, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(
        errorMessage: 'Erro ao carregar histórico de conflitos: $e',
        isLoading: false,
      );
    }
    notifyListeners();
  }

  /// Resolve um conflito com uma estratégia específica
  Future<void> resolveConflict(
    ConflictData conflictData, {
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.newerWins,
  }) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

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

      _state = _state.copyWith(isLoading: false);
      notifyListeners();

      return resolvedData;
    } catch (e) {
      _state = _state.copyWith(
        errorMessage: 'Erro ao resolver conflito: $e',
        isLoading: false,
      );
      notifyListeners();
      rethrow;
    }
  }

  /// Limpa todo o histórico de conflitos
  Future<void> clearConflictHistory() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _conflictHistoryService.clearConflictHistory();
      _state = _state.copyWith(conflicts: [], isLoading: false);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        errorMessage: 'Erro ao limpar histórico de conflitos: $e',
        isLoading: false,
      );
      notifyListeners();
    }
  }
}
