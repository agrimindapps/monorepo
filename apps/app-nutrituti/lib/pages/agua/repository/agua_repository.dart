// Flutter imports:
// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../models/beber_agua_model.dart';

@injectable
class AguaRepository {
  static const String _boxName = 'box_nut_beberagua';
  static const String _collection = 'box_nut_beberagua';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Constructor
  AguaRepository();

  AguaRepository._internal();

  // Initialization
  static Future<void> initialize() async {
    try {
      if (!Hive.isAdapterRegistered(41)) {
        Hive.registerAdapter(BeberAguaAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing AguaRepository: $e');
      rethrow;
    }
  }

  Box<BeberAgua> get _box => Hive.box<BeberAgua>(_boxName);

  // Função para verificar se a caixa está aberta e caso não esteja, abri-la
  Future<void> openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<BeberAgua>(_boxName);
    }
  }

  // CRUD Operations
  Future<List<BeberAgua>> getAll() async {
    await openBox();
    final beberAguaBox = Hive.box<BeberAgua>(_boxName);
    return beberAguaBox.values.toList();
  }

  Future<BeberAgua?> get(String id) async {
    await openBox();
    final beberAguaBox = Hive.box<BeberAgua>(_boxName);
    return beberAguaBox.values.firstWhere((a) => a.id == id);
  }

  Future<void> add(BeberAgua registro) async {
    await openBox();
    final beberAguaBox = Hive.box<BeberAgua>(_boxName);
    beberAguaBox.add(registro);

    if (await _hasInternetConnection()) {
      await _firestore
          .collection(_collection)
          .doc(registro.id.toString())
          .set(registro.toMap());
    }
  }

  Future<void> updated(BeberAgua registro) async {
    await openBox();
    final beberAguaBox = Hive.box<BeberAgua>(_boxName);
    final index =
        beberAguaBox.values.toList().indexWhere((a) => a.id == registro.id);
    beberAguaBox.putAt(index, registro);

    if (await _hasInternetConnection()) {
      await _firestore
          .collection(_collection)
          .doc(registro.id.toString())
          .update(registro.toMap());
    }
  }

  Future<void> delete(BeberAgua registro) async {
    await openBox();
    final beberAguaBox = Hive.box<BeberAgua>(_boxName);
    final index =
        beberAguaBox.values.toList().indexWhere((a) => a.id == registro.id);
    beberAguaBox.deleteAt(index);

    if (await _hasInternetConnection()) {
      await _firestore
          .collection(_collection)
          .doc(registro.id.toString())
          .delete();
    }
  }

  Future<bool> _hasInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
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
    final lastUpdateDate =
        DateTime.fromMillisecondsSinceEpoch(lastUpdateMillis);
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
          _keyTodayProgress, currentProgress + additionalProgress);
    }
  }

  Future<double> getTodayProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().millisecondsSinceEpoch;
    final lastUpdateMillis = prefs.getInt(_keyLastUpdate) ?? 0;

    // Converter para DateTime para comparar apenas a data
    final lastUpdateDate =
        DateTime.fromMillisecondsSinceEpoch(lastUpdateMillis);
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
    await openBox();
    final registros = await getAll();

    // Calcular estatísticas básicas
    double totalQuantidade = 0;
    if (registros.isNotEmpty) {
      totalQuantidade =
          registros.fold(0.0, (sum, registro) => sum + registro.quantidade);
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
}
