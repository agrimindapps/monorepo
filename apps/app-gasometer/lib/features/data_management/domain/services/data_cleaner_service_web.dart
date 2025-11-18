import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import 'i_data_cleaner_service.dart';

/// Web implementation of DataCleanerService
/// 
/// Since Drift is not supported on web, this version only clears
/// SharedPreferences. Data in Firestore should be cleared via backend.
class DataCleanerServiceWeb implements IDataCleanerService {
  /// Limpa SharedPreferences (web não usa Drift)
  @override
  Future<Map<String, dynamic>> clearAllData() async {
    if (kDebugMode) {
      debugPrint('🧹 [Web] Iniciando limpeza de dados (SharedPreferences only)...');
    }

    final startTime = DateTime.now();
    final results = <String, dynamic>{
      'clearedTables': <String>[],
      'clearedPreferences': <String>[],
      'errors': <String>[],
      'startTime': startTime,
    };

    try {
      final prefsResults = await clearAppSharedPreferences();
      results['clearedPreferences'] = prefsResults['clearedKeys'];
      if (prefsResults['errors'] != null) {
        results['errors'].addAll(prefsResults['errors'] as List);
      }

      results['success'] = true;
      results['totalClearedTables'] = 0; // No tables on web
      results['totalClearedPreferences'] = (results['clearedPreferences'] as List).length;
    } catch (e) {
      results['success'] = false;
      results['mainError'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ [Web] Erro na limpeza: $e');
      }
    }

    results['endTime'] = DateTime.now();
    results['duration'] = (results['endTime'] as DateTime)
        .difference(startTime)
        .inMilliseconds;

    if (kDebugMode) {
      debugPrint('✅ [Web] Limpeza finalizada:');
      debugPrint('   Preferências limpas: ${results['totalClearedPreferences'] ?? 0}');
      debugPrint('   Tempo: ${results['duration']}ms');
    }

    return results;
  }

  /// Limpa SharedPreferences específicas do aplicativo
  @override
  Future<Map<String, dynamic>> clearAppSharedPreferences() async {
    final results = <String, dynamic>{
      'clearedKeys': <String>[],
      'errors': <String>[],
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final appKeys = allKeys
          .where(
            (key) =>
                key.startsWith('gasometer_') ||
                key.startsWith('theme_') ||
                key.startsWith('user_') ||
                key.startsWith('vehicle_') ||
                key.startsWith('fuel_') ||
                key.startsWith('maintenance_') ||
                key.startsWith('expense_') ||
                key.contains('gasometer') ||
                key == 'theme_mode',
          )
          .toList();

      if (kDebugMode) {
        debugPrint('🧹 [Web] Limpando ${appKeys.length} preferências do app...');
      }

      for (final key in appKeys) {
        try {
          await prefs.remove(key);
          results['clearedKeys'].add(key);

          if (kDebugMode) {
            debugPrint('   ✅ Chave "$key" removida');
          }
        } catch (e) {
          final error = 'Erro ao remover chave "$key": $e';
          (results['errors'] as List).add(error);

          if (kDebugMode) {
            debugPrint('   ❌ $error');
          }
        }
      }

      if (appKeys.isEmpty) {
        if (kDebugMode) {
          debugPrint('   ℹ️ Nenhuma preferência específica do app encontrada');
        }
      }
    } catch (e) {
      (results['errors'] as List).add('Erro ao acessar SharedPreferences: $e');
      if (kDebugMode) {
        debugPrint('❌ [Web] Erro ao acessar SharedPreferences: $e');
      }
    }

    return results;
  }

  /// Verifica se há dados para limpar
  @override
  Future<bool> hasDataToClear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      return allKeys.any(
        (key) =>
            key.startsWith('gasometer_') ||
            key.startsWith('theme_') ||
            key.startsWith('user_') ||
            key.contains('gasometer') ||
            key == 'theme_mode',
      );
    } catch (e) {
      return false;
    }
  }
}
