import 'package:drift/drift.dart' as drift;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../drift_database/daos/exercicio_dao.dart';
import '../../../../drift_database/nutrituti_database.dart';
import '../models/exercicio_model.dart';

/// Local data source for exercise data using Drift
abstract class ExercicioLocalDataSource {
  /// Add a new exercise
  Future<ExercicioModel> addExercicio(ExercicioModel exercicio);

  /// Update an existing exercise
  Future<ExercicioModel> updateExercicio(ExercicioModel exercicio);

  /// Delete an exercise by ID
  Future<void> deleteExercicio(String id);

  /// Get all exercises
  Future<List<ExercicioModel>> getAllExercicios();

  /// Get exercise by ID
  Future<ExercicioModel?> getExercicioById(String id);

  /// Get exercises by date range
  Future<List<ExercicioModel>> getExerciciosByDateRange(
    DateTime start,
    DateTime end,
  );

  /// Get exercises by category
  Future<List<ExercicioModel>> getExerciciosByCategoria(String categoria);

  /// Get total calories by date range
  Future<double> getTotalCaloriasByDateRange(DateTime start, DateTime end);

  /// Mark exercise as synced
  Future<void> markAsSynced(String id);

  /// Mark exercise as pending sync
  Future<void> markAsPending(String id);

  /// Get pending sync exercises
  Future<List<ExercicioModel>> getPendingSyncExercicios();

  /// Clear all data
  Future<void> clearAllData();
}

@Injectable(as: ExercicioLocalDataSource)
class ExercicioLocalDataSourceImpl implements ExercicioLocalDataSource {
  final ExercicioDao _exercicioDao;
  final SharedPreferences _prefs;

  static const String _lastSyncKey = 'exercicios_last_sync';

  ExercicioLocalDataSourceImpl(this._prefs, this._exercicioDao);

  @override
  Future<ExercicioModel> addExercicio(ExercicioModel exercicio) async {
    try {
      final companion = _exercicioToCompanion(exercicio);
      await _exercicioDao.addExercicio(companion);
      return exercicio;
    } catch (e) {
      throw CacheException('Failed to add exercise: $e');
    }
  }

  @override
  Future<ExercicioModel> updateExercicio(ExercicioModel exercicio) async {
    try {
      if (exercicio.id == null) {
        throw CacheException('Exercise ID cannot be null for update');
      }

      final companion = _exercicioToCompanion(exercicio);
      await _exercicioDao.updateExercicio(exercicio.id!, companion);
      return exercicio;
    } catch (e) {
      throw CacheException('Failed to update exercise: $e');
    }
  }

  @override
  Future<void> deleteExercicio(String id) async {
    try {
      await _exercicioDao.deleteExercicio(id);
    } catch (e) {
      throw CacheException('Failed to delete exercise: $e');
    }
  }

  @override
  Future<List<ExercicioModel>> getAllExercicios() async {
    try {
      final exercicios = await _exercicioDao.getAllExercicios();
      return exercicios.map(_exercicioFromDrift).toList();
    } catch (e) {
      throw CacheException('Failed to get exercises: $e');
    }
  }

  @override
  Future<ExercicioModel?> getExercicioById(String id) async {
    try {
      final exercicio = await _exercicioDao.getExercicioById(id);
      return exercicio != null ? _exercicioFromDrift(exercicio) : null;
    } catch (e) {
      throw CacheException('Failed to get exercise by id: $e');
    }
  }

  @override
  Future<List<ExercicioModel>> getExerciciosByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final exercicios = await _exercicioDao.getExerciciosByDateRange(
        start,
        end,
      );
      return exercicios.map(_exercicioFromDrift).toList();
    } catch (e) {
      throw CacheException('Failed to get exercises by date range: $e');
    }
  }

  @override
  Future<List<ExercicioModel>> getExerciciosByCategoria(
    String categoria,
  ) async {
    try {
      final exercicios = await _exercicioDao.getExerciciosByCategoria(
        categoria,
      );
      return exercicios.map(_exercicioFromDrift).toList();
    } catch (e) {
      throw CacheException('Failed to get exercises by category: $e');
    }
  }

  @override
  Future<double> getTotalCaloriasByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      return await _exercicioDao.getTotalCaloriasByDateRange(start, end);
    } catch (e) {
      throw CacheException('Failed to get total calories: $e');
    }
  }

  @override
  Future<void> markAsSynced(String id) async {
    try {
      await _exercicioDao.markAsSynced(id);
    } catch (e) {
      throw CacheException('Failed to mark exercise as synced: $e');
    }
  }

  @override
  Future<void> markAsPending(String id) async {
    try {
      await _exercicioDao.markAsPending(id);
    } catch (e) {
      throw CacheException('Failed to mark exercise as pending: $e');
    }
  }

  @override
  Future<List<ExercicioModel>> getPendingSyncExercicios() async {
    try {
      final exercicios = await _exercicioDao.getPendingSyncExercicios();
      return exercicios.map(_exercicioFromDrift).toList();
    } catch (e) {
      throw CacheException('Failed to get pending sync exercises: $e');
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await _exercicioDao.deleteAll();
      await _prefs.remove(_lastSyncKey);
    } catch (e) {
      throw CacheException('Failed to clear all exercise data: $e');
    }
  }

  // Conversion methods
  ExercicioModel _exercicioFromDrift(Exercicio exercicio) {
    return ExercicioModel(
      id: exercicio.id,
      nome: exercicio.nome,
      categoria: exercicio.categoria,
      duracao: exercicio.duracao,
      caloriasQueimadas: exercicio.caloriasQueimadas.toInt(),
      dataRegistro: exercicio.dataRegistro.millisecondsSinceEpoch,
      observacoes: exercicio.observacoes,
    );
  }

  ExerciciosCompanion _exercicioToCompanion(ExercicioModel exercicio) {
    return ExerciciosCompanion(
      id: drift.Value(exercicio.id ?? _generateId()),
      nome: drift.Value(exercicio.nome),
      categoria: drift.Value(exercicio.categoria),
      duracao: drift.Value(exercicio.duracao),
      caloriasQueimadas: drift.Value(exercicio.caloriasQueimadas.toDouble()),
      dataRegistro: drift.Value(
        DateTime.fromMillisecondsSinceEpoch(exercicio.dataRegistro),
      ),
      observacoes: drift.Value(exercicio.observacoes),
      isSynced: const drift.Value(false),
      isPending: const drift.Value(true),
      updatedAt: drift.Value(DateTime.now()),
    );
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
