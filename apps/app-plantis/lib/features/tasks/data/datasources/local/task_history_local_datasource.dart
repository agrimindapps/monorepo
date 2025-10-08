import 'package:core/core.dart';

import '../../../../../core/constants/plantis_environment_config.dart';
import '../../models/task_history_model.dart';

abstract class TaskHistoryLocalDataSource {
  Future<List<TaskHistoryModel>> getHistoryByPlantId(String plantId);
  Future<List<TaskHistoryModel>> getHistoryByTaskId(String taskId);
  Future<List<TaskHistoryModel>> getHistoryByUserId(String userId);
  Future<List<TaskHistoryModel>> getHistoryInDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<TaskHistoryModel?> getHistoryById(String id);
  Future<void> cacheHistory(TaskHistoryModel history);
  Future<void> cacheHistories(List<TaskHistoryModel> histories);
  Future<void> updateHistory(TaskHistoryModel history);
  Future<void> deleteHistory(String id);
  Future<void> deleteHistoryByTaskId(String taskId);
  Future<void> deleteHistoryByPlantId(String plantId);
  Future<void> clearCache();
}

class TaskHistoryLocalDataSourceImpl implements TaskHistoryLocalDataSource {
  final ILocalStorageRepository storageService;
  static const String _boxName = PlantisBoxes.care_logs;

  TaskHistoryLocalDataSourceImpl(this.storageService);

  @override
  Future<List<TaskHistoryModel>> getHistoryByPlantId(String plantId) async {
    try {
      final allHistory = await _getAllHistory();
      return allHistory.where((history) => history.plantId == plantId).toList();
    } catch (e) {
      throw Exception('Erro ao buscar histórico por planta: $e');
    }
  }

  @override
  Future<List<TaskHistoryModel>> getHistoryByTaskId(String taskId) async {
    try {
      final allHistory = await _getAllHistory();
      return allHistory.where((history) => history.taskId == taskId).toList();
    } catch (e) {
      throw Exception('Erro ao buscar histórico por tarefa: $e');
    }
  }

  @override
  Future<List<TaskHistoryModel>> getHistoryByUserId(String userId) async {
    try {
      final allHistory = await _getAllHistory();
      return allHistory.where((history) => history.userId == userId).toList();
    } catch (e) {
      throw Exception('Erro ao buscar histórico por usuário: $e');
    }
  }

  @override
  Future<List<TaskHistoryModel>> getHistoryInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allHistory = await _getAllHistory();
      return allHistory
          .where(
            (history) =>
                history.completedAt.isAfter(startDate) &&
                history.completedAt.isBefore(endDate),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar histórico por período: $e');
    }
  }

  @override
  Future<TaskHistoryModel?> getHistoryById(String id) async {
    try {
      final allHistory = await _getAllHistory();
      return allHistory.where((history) => history.id == id).firstOrNull;
    } catch (e) {
      throw Exception('Erro ao buscar histórico por ID: $e');
    }
  }

  @override
  Future<void> cacheHistory(TaskHistoryModel history) async {
    try {
      final allHistory = await _getAllHistory();
      allHistory.add(history);
      await storageService.save<List<Map<String, dynamic>>>(
        key: 'all_task_history',
        data: allHistory.map((h) => h.toHiveMap()).toList(),
        box: _boxName,
      );
    } catch (e) {
      throw Exception('Erro ao salvar histórico: $e');
    }
  }

  @override
  Future<void> cacheHistories(List<TaskHistoryModel> histories) async {
    try {
      await storageService.save<List<Map<String, dynamic>>>(
        key: 'all_task_history',
        data: histories.map((h) => h.toHiveMap()).toList(),
        box: _boxName,
      );
    } catch (e) {
      throw Exception('Erro ao salvar históricos: $e');
    }
  }

  @override
  Future<void> updateHistory(TaskHistoryModel history) async {
    try {
      final allHistory = await _getAllHistory();
      final index = allHistory.indexWhere((h) => h.id == history.id);
      if (index != -1) {
        allHistory[index] = history;
        await storageService.save<List<Map<String, dynamic>>>(
          key: 'all_task_history',
          data: allHistory.map((h) => h.toHiveMap()).toList(),
          box: _boxName,
        );
      }
    } catch (e) {
      throw Exception('Erro ao atualizar histórico: $e');
    }
  }

  @override
  Future<void> deleteHistory(String id) async {
    try {
      final allHistory = await _getAllHistory();
      allHistory.removeWhere((history) => history.id == id);
      await storageService.save<List<Map<String, dynamic>>>(
        key: 'all_task_history',
        data: allHistory.map((h) => h.toHiveMap()).toList(),
        box: _boxName,
      );
    } catch (e) {
      throw Exception('Erro ao deletar histórico: $e');
    }
  }

  @override
  Future<void> deleteHistoryByTaskId(String taskId) async {
    try {
      final allHistory = await _getAllHistory();
      allHistory.removeWhere((history) => history.taskId == taskId);
      await storageService.save<List<Map<String, dynamic>>>(
        key: 'all_task_history',
        data: allHistory.map((h) => h.toHiveMap()).toList(),
        box: _boxName,
      );
    } catch (e) {
      throw Exception('Erro ao deletar histórico por tarefa: $e');
    }
  }

  @override
  @override
  Future<void> deleteHistoryByPlantId(String plantId) async {
    try {
      final allHistory = await _getAllHistory();
      allHistory.removeWhere((history) => history.plantId == plantId);
      await storageService.save<List<Map<String, dynamic>>>(
        key: 'all_task_history',
        data: allHistory.map((h) => h.toHiveMap()).toList(),
        box: _boxName,
      );
    } catch (e) {
      throw Exception('Erro ao deletar histórico por planta: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await storageService.remove(key: 'all_task_history', box: _boxName);
    } catch (e) {
      throw Exception('Erro ao limpar cache de histórico: $e');
    }
  }

  Future<List<TaskHistoryModel>> _getAllHistory() async {
    try {
      final result = await storageService.get<List<dynamic>>(
        key: 'all_task_history',
        box: _boxName,
      );

      return result.fold((failure) => <TaskHistoryModel>[], (historyData) {
        if (historyData == null) return <TaskHistoryModel>[];

        return historyData.map<TaskHistoryModel>((data) {
          final Map<String, dynamic> historyMap = Map<String, dynamic>.from(
            data as Map,
          );
          return TaskHistoryModel.fromHiveMap(historyMap);
        }).toList();
      });
    } catch (e) {
      throw Exception('Erro ao buscar histórico local: $e');
    }
  }
}
