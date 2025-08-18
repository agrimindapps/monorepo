import 'package:injectable/injectable.dart';
import 'package:hive/hive.dart';

import '../data/models/conflict_history_model.dart';

@injectable
class ConflictHistoryService {
  final Box<ConflictHistoryModel> _conflictHistoryBox;

  ConflictHistoryService(@Named('conflictHistoryBox') this._conflictHistoryBox);

  /// Salva um novo registro de histórico de conflito
  Future<void> saveConflict(ConflictHistoryModel conflictHistory) async {
    await _conflictHistoryBox.put(conflictHistory.id, conflictHistory);
  }

  /// Busca histórico de conflitos por ID do modelo
  List<ConflictHistoryModel> getConflictsByModelId(String modelId) {
    return _conflictHistoryBox.values
        .where((conflict) => conflict.modelId == modelId)
        .toList();
  }

  /// Busca todos os históricos de conflitos
  List<ConflictHistoryModel> getAllConflicts() {
    return _conflictHistoryBox.values.toList();
  }

  /// Remove um registro específico de conflito
  Future<void> removeConflict(String conflictId) async {
    await _conflictHistoryBox.delete(conflictId);
  }

  /// Limpa todo o histórico de conflitos
  Future<void> clearConflictHistory() async {
    await _conflictHistoryBox.clear();
  }

  /// Conta o número total de conflitos registrados
  int countConflicts() {
    return _conflictHistoryBox.length;
  }

  /// Obtém os últimos N conflitos registrados
  List<ConflictHistoryModel> getRecentConflicts(int limit) {
    final allConflicts = getAllConflicts();
    allConflicts.sort((a, b) => 
      (b.createdAtMs ?? 0).compareTo(a.createdAtMs ?? 0)
    );
    return allConflicts.take(limit).toList();
  }
}