// Flutter imports:
// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' as drift;
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../../drift_database/daos/agua_dao.dart';
import '../../../drift_database/nutrituti_database.dart';
import '../models/beber_agua_model.dart';

class AguaRepository {
  static const String _collection = 'box_nut_beberagua';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AguaDao _aguaDao;

  // Constructor
  AguaRepository(this._aguaDao);

  // CRUD Operations
  Future<List<BeberAgua>> getAll() async {
    // TODO: Get perfilId from somewhere (maybe pass as parameter or get from auth)
    const perfilId = 'default'; // Temporary - should be injected or passed
    final registros = await _aguaDao.getAllRegistros(perfilId);
    return registros.map(_fromDrift).toList();
  }

  Future<BeberAgua?> get(String id) async {
    final registro = await _aguaDao.getRegistroById(id);
    return registro != null ? _fromDrift(registro) : null;
  }

  Future<void> add(BeberAgua registro) async {
    final companion = _toCompanion(registro);
    await _aguaDao.createRegistro(companion);

    if (await _hasInternetConnection()) {
      await _firestore
          .collection(_collection)
          .doc(registro.id.toString())
          .set(registro.toMap());
    }
  }

  Future<void> updated(BeberAgua registro) async {
    final companion = _toCompanion(registro);
    await _aguaDao.updateRegistro(registro.id!, companion);

    if (await _hasInternetConnection()) {
      await _firestore
          .collection(_collection)
          .doc(registro.id.toString())
          .update(registro.toMap());
    }
  }

  Future<void> delete(BeberAgua registro) async {
    await _aguaDao.deleteRegistro(registro.id!);

    if (await _hasInternetConnection()) {
      await _firestore
          .collection(_collection)
          .doc(registro.id.toString())
          .delete();
    }
  }

  Future<bool> _hasInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  // Constantes para SharedPreferences
  static const String _keyDailyGoal = 'dailyWaterGoal';
  static const String _keyTodayProgress = 'todayProgress';
  static const String _keyLastUpdate = 'lastUpdate';
  static const String _keyStreak = 'currentStreak';
  static const String _keyAchievements = 'unlockedAchievements';

  // Métodos para gerenciar metas e progresso
  Future<void> setDailyGoal(double goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyDailyGoal, goal);
  }

  Future<double> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyDailyGoal) ?? 2000.0;
  }

  Future<void> updateTodayProgress(double additionalProgress) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().millisecondsSinceEpoch;
    final lastUpdateMillis = prefs.getInt(_keyLastUpdate) ?? 0;

    // Converter para DateTime para comparar apenas a data
    final lastUpdateDate = DateTime.fromMillisecondsSinceEpoch(
      lastUpdateMillis,
    );
    final todayDate = DateTime.fromMillisecondsSinceEpoch(today);

    final isSameDay = lastUpdateDate.year == todayDate.year &&
        lastUpdateDate.month == todayDate.month &&
        lastUpdateDate.day == todayDate.day;

    // Resetar progresso se for um novo dia
    if (!isSameDay) {
      await prefs.setDouble(_keyTodayProgress, additionalProgress);
      await prefs.setInt(_keyLastUpdate, today);
    } else {
      final currentProgress = prefs.getDouble(_keyTodayProgress) ?? 0.0;
      await prefs.setDouble(
        _keyTodayProgress,
        currentProgress + additionalProgress,
      );
    }
  }

  Future<double> getTodayProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().millisecondsSinceEpoch;
    final lastUpdateMillis = prefs.getInt(_keyLastUpdate) ?? 0;

    // Converter para DateTime para comparar apenas a data
    final lastUpdateDate = DateTime.fromMillisecondsSinceEpoch(
      lastUpdateMillis,
    );
    final todayDate = DateTime.fromMillisecondsSinceEpoch(today);

    final isSameDay = lastUpdateDate.year == todayDate.year &&
        lastUpdateDate.month == todayDate.month &&
        lastUpdateDate.day == todayDate.day;

    if (!isSameDay) {
      await prefs.setDouble(_keyTodayProgress, 0.0);
      await prefs.setInt(_keyLastUpdate, today);
      return 0.0;
    }

    return prefs.getDouble(_keyTodayProgress) ?? 0.0;
  }

  // Métodos para streak e achievements
  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStreak) ?? 0;
  }

  Future<int> incrementStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final currentStreak = prefs.getInt(_keyStreak) ?? 0;
    final newStreak = currentStreak + 1;
    await prefs.setInt(_keyStreak, newStreak);
    return newStreak;
  }

  Future<void> resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStreak, 0);
  }

  Future<void> addUnlockedAchievement(String achievementTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final achievements = prefs.getStringList(_keyAchievements) ?? [];

    if (!achievements.contains(achievementTitle)) {
      achievements.add(achievementTitle);
      await prefs.setStringList(_keyAchievements, achievements);
    }
  }

  Future<List<String>> getUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyAchievements) ?? [];
  }

  // Método para obter estatísticas
  Future<Map<String, dynamic>> getStatistics() async {
    final registros = await getAll();

    double totalQuantidade = 0;
    if (registros.isNotEmpty) {
      totalQuantidade = registros.fold(
        0.0,
        (total, registro) => total + registro.quantidade,
      );
    }

    return {
      'totalRegistros': registros.length,
      'totalQuantidade': totalQuantidade,
      'mediaQuantidade':
          registros.isEmpty ? 0.0 : totalQuantidade / registros.length,
      'streak': await getStreak(),
    };
  }

  // Métodos auxiliares
  Future<int?> getLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLastUpdate);
  }

  Future<void> setLastUpdate(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastUpdate, timestamp);
  }

  // Conversion methods
  BeberAgua _fromDrift(AguaRegistro registro) {
    return BeberAgua(
      id: registro.id,
      createdAt: registro.createdAt,
      updatedAt: registro.updatedAt,
      dataRegistro: registro.dataRegistro,
      quantidade: registro.quantidade.toDouble(),
      fkIdPerfil: registro.fkIdPerfil,
    );
  }

  AguaRegistrosCompanion _toCompanion(BeberAgua model) {
    return AguaRegistrosCompanion(
      id: drift.Value(model.id!),
      dataRegistro: drift.Value(model.dataRegistro),
      quantidade: drift.Value(model.quantidade.toInt()),
      fkIdPerfil: drift.Value(model.fkIdPerfil),
      createdAt: drift.Value(model.createdAt ?? DateTime.now()),
      updatedAt: drift.Value(model.updatedAt ?? DateTime.now()),
    );
  }
}
