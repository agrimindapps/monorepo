import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../database/receituagro_database.dart';

/// Implementação específica do ReceitaAgro para limpeza de dados usando Drift
/// Implementa IAppDataCleaner do core package
/// Refatorado completamente para usar Drift ao invés de Hive
class ReceitaAgroDataCleaner implements IAppDataCleaner {
  final ReceituagroDatabase _db = GetIt.instance<ReceituagroDatabase>();

  @override
  String get appName => 'ReceitaAgro';

  @override
  String get version => '2.0.0-drift';

  @override
  String get description => 'Dados agronômicos (culturas, pragas, defensivos, diagnósticos, favoritos) - Drift Database';

  @override
  Future<Map<String, dynamic>> clearAllAppData() async {
    if (kDebugMode) {
      debugPrint('🧹 ReceitaAgroDataCleaner (Drift): Iniciando limpeza de dados do usuário...');
      debugPrint('   ✅ Preservando dados estáticos: culturas, pragas, defensivos');
    }

    final startTime = DateTime.now();
    final results = <String, dynamic>{
      'clearedTables': <String>[],
      'clearedPreferences': <String>[],
      'errors': <String>[],
      'startTime': startTime,
    };

    try {
      // Limpar apenas dados do usuário (NOT dados estáticos)
      final tableResults = await _clearUserDataTablesOnly();
      results['clearedTables'] = tableResults['clearedTables'];
      if (tableResults['errors'] != null) {
        results['errors'].addAll(tableResults['errors']);
      }
      
      final prefsResults = await _clearAppSharedPreferences();
      results['clearedPreferences'] = prefsResults['clearedKeys'];
      if (prefsResults['errors'] != null) {
        results['errors'].addAll(prefsResults['errors']);
      }

      results['success'] = true;
      results['totalClearedTables'] = results['clearedTables'].length;
      results['totalClearedPreferences'] = results['clearedPreferences'].length;
      results['totalRecordsCleared'] = tableResults['totalRecordsCleared'] ?? 0;

    } catch (e) {
      results['success'] = false;
      results['mainError'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroDataCleaner (Drift): Erro na limpeza - $e');
      }
    }

    results['endTime'] = DateTime.now();
    results['duration'] = results['endTime'].difference(startTime).inMilliseconds;

    if (kDebugMode) {
      debugPrint('✅ ReceitaAgroDataCleaner (Drift): Limpeza de dados do usuário finalizada:');
      debugPrint('   Tabelas limpas: ${results['totalClearedTables'] ?? 0}');
      debugPrint('   Preferências limpas: ${results['totalClearedPreferences'] ?? 0}');
      debugPrint('   Registros totais: ${results['totalRecordsCleared'] ?? 0}');
      debugPrint('   Erros: ${(results['errors'] as List).length}');
      debugPrint('   Tempo: ${results['duration']}ms');
    }

    return results;
  }

  @override
  Future<Map<String, dynamic>> getDataStatsBeforeCleaning() async {
    try {
      final stats = <String, dynamic>{
        'tableStats': <String, Map<String, dynamic>>{},
        'totalTables': 0,
        'totalRecords': 0,
        'appSpecificPrefs': 0,
        'availableCategories': getAvailableCategories(),
      };

      int totalRecords = 0;
      final tableStats = <String, Map<String, dynamic>>{};
      
      // Get count from each Drift table
      try {
        // NOTE: Diagnosticos is static table - no isDeleted field, count all
        final diagnosticosCount = await _db.select(_db.diagnosticos).get().then((rows) => rows.length);
        tableStats['diagnosticos'] = {
          'tableName': 'diagnosticos',
          'totalRecords': diagnosticosCount,
          'category': 'diagnosticos',
        };
        totalRecords += diagnosticosCount;
      } catch (e) {
        tableStats['diagnosticos'] = {'tableName': 'diagnosticos', 'totalRecords': 0, 'error': e.toString()};
      }

      try {
        final favoritosCount = await (_db.select(_db.favoritos)..where((tbl) => tbl.isDeleted.equals(false))).get().then((rows) => rows.length);
        tableStats['favoritos'] = {
          'tableName': 'favoritos',
          'totalRecords': favoritosCount,
          'category': 'favoritos',
        };
        totalRecords += favoritosCount;
      } catch (e) {
        tableStats['favoritos'] = {'tableName': 'favoritos', 'totalRecords': 0, 'error': e.toString()};
      }

      try {
        final comentariosCount = await (_db.select(_db.comentarios)..where((tbl) => tbl.isDeleted.equals(false))).get().then((rows) => rows.length);
        tableStats['comentarios'] = {
          'tableName': 'comentarios',
          'totalRecords': comentariosCount,
          'category': 'comentarios',
        };
        totalRecords += comentariosCount;
      } catch (e) {
        tableStats['comentarios'] = {'tableName': 'comentarios', 'totalRecords': 0, 'error': e.toString()};
      }

      try {
        final culturasCount = await _db.select(_db.culturas).get().then((rows) => rows.length);
        tableStats['culturas'] = {
          'tableName': 'culturas',
          'totalRecords': culturasCount,
          'category': 'culturas',
        };
        totalRecords += culturasCount;
      } catch (e) {
        tableStats['culturas'] = {'tableName': 'culturas', 'totalRecords': 0, 'error': e.toString()};
      }

      try {
        final pragasCount = await _db.select(_db.pragas).get().then((rows) => rows.length);
        tableStats['pragas'] = {
          'tableName': 'pragas',
          'totalRecords': pragasCount,
          'category': 'pragas',
        };
        totalRecords += pragasCount;
      } catch (e) {
        tableStats['pragas'] = {'tableName': 'pragas', 'totalRecords': 0, 'error': e.toString()};
      }

      try {
        final fitossanitariosCount = await _db.select(_db.fitossanitarios).get().then((rows) => rows.length);
        tableStats['fitossanitarios'] = {
          'tableName': 'fitossanitarios',
          'totalRecords': fitossanitariosCount,
          'category': 'defensivos',
        };
        totalRecords += fitossanitariosCount;
      } catch (e) {
        tableStats['fitossanitarios'] = {'tableName': 'fitossanitarios', 'totalRecords': 0, 'error': e.toString()};
      }

      try {
        final appSettingsCount = await _db.select(_db.appSettings).get().then((rows) => rows.length);
        tableStats['app_settings'] = {
          'tableName': 'app_settings',
          'totalRecords': appSettingsCount,
          'category': 'settings',
        };
        totalRecords += appSettingsCount;
      } catch (e) {
        tableStats['app_settings'] = {'tableName': 'app_settings', 'totalRecords': 0, 'error': e.toString()};
      }

      stats['tableStats'] = tableStats;
      stats['totalTables'] = tableStats.length;
      stats['totalRecords'] = totalRecords;

      try {
        final prefs = await SharedPreferences.getInstance();
        final allKeys = prefs.getKeys();

        final appKeys = allKeys.where((key) =>
          key.startsWith('receituagro_') ||
          key.startsWith('agro_') ||
          key.startsWith('culture_') ||
          key.startsWith('praga_') ||
          key.startsWith('defensivo_') ||
          key.startsWith('diagnostico_') ||
          key.startsWith('favorite_') ||
          key.startsWith('premium_') ||
          key.contains('receituagro') ||
          key == 'theme_mode' // Theme provider key
        ).length;

        stats['appSpecificPrefs'] = appKeys;
      } catch (e) {
        stats['prefsError'] = e.toString();
      }

      return stats;
    } catch (e) {
      return {
        'error': 'Erro ao obter estatísticas: $e',
      };
    }
  }

  @override
  Future<bool> hasDataToClear() async {
    try {
      final stats = await getDataStatsBeforeCleaning();
      return (stats['totalRecords'] as int? ?? 0) > 0 ||
             (stats['appSpecificPrefs'] as int? ?? 0) > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> clearCategoryData(String category) async {
    if (category == 'all') {
      return await clearAllAppData();
    }

    final results = <String, dynamic>{
      'category': category,
      'clearedTables': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    try {
      // Tratamento especial para favoritos e comentários: soft delete com sync
      if (category == 'favoritos') {
        final softDeleteResult = await _markFavoritosAsDeleted();
        if (softDeleteResult['success'] == true) {
          results['clearedTables'].add('favoritos');
          results['totalRecordsCleared'] = softDeleteResult['totalMarkedAsDeleted'] ?? 0;
          if (kDebugMode) {
            debugPrint('✅ Favoritos marcados como deletados e sincronização disparada');
          }
        } else {
          results['errors'].add(softDeleteResult['error'] ?? 'Erro ao marcar favoritos como deletados');
        }
        results['success'] = results['errors'].isEmpty;
        return results;
      }

      if (category == 'comentarios') {
        final softDeleteResult = await _markComentariosAsDeleted();
        if (softDeleteResult['success'] == true) {
          results['clearedTables'].add('comentarios');
          results['totalRecordsCleared'] = softDeleteResult['totalMarkedAsDeleted'] ?? 0;
          if (kDebugMode) {
            debugPrint('✅ Comentários marcados como deletados e sincronização disparada');
          }
        } else {
          results['errors'].add(softDeleteResult['error'] ?? 'Erro ao marcar comentários como deletados');
        }
        results['success'] = results['errors'].isEmpty;
        return results;
      }

      // Para outras categorias, fazer clear normal
      final tablesToClear = _getTablesForCategory(category);

      if (tablesToClear.isEmpty) {
        results['errors'].add('Categoria "$category" não encontrada');
        results['success'] = false;
        return results;
      }

      if (kDebugMode) {
        debugPrint('🧹 ReceitaAgroDataCleaner (Drift): Limpando categoria "$category" (${tablesToClear.length} tabelas)...');
      }

      int totalRecords = 0;

      for (final tableName in tablesToClear) {
        try {
          int recordCount = 0;
          
          if (tableName == 'diagnosticos') {
            // NOTE: Diagnosticos is static table - skip deletion
            recordCount = 0;
            debugPrint('⚠️ Skipping diagnosticos - static table');
          } else if (tableName == 'favoritos') {
            final rows = await (_db.select(_db.favoritos)..where((tbl) => tbl.isDeleted.equals(false))).get();
            recordCount = rows.length;
            await (_db.delete(_db.favoritos)..where((tbl) => tbl.isDeleted.equals(false))).go();
          } else if (tableName == 'comentarios') {
            final rows = await (_db.select(_db.comentarios)..where((tbl) => tbl.isDeleted.equals(false))).get();
            recordCount = rows.length;
            await (_db.delete(_db.comentarios)..where((tbl) => tbl.isDeleted.equals(false))).go();
          } else if (tableName == 'culturas') {
            final rows = await _db.select(_db.culturas).get();
            recordCount = rows.length;
            await _db.delete(_db.culturas).go();
          } else if (tableName == 'pragas') {
            final rows = await _db.select(_db.pragas).get();
            recordCount = rows.length;
            await _db.delete(_db.pragas).go();
          } else if (tableName == 'fitossanitarios') {
            final rows = await _db.select(_db.fitossanitarios).get();
            recordCount = rows.length;
            await _db.delete(_db.fitossanitarios).go();
          }

          results['clearedTables'].add(tableName);
          totalRecords += recordCount;

          if (kDebugMode) {
            debugPrint('   ✅ Tabela "$tableName" limpa ($recordCount registros)');
          }
        } catch (e) {
          final error = 'Erro ao limpar tabela "$tableName": $e';
          results['errors'].add(error);

          if (kDebugMode) {
            debugPrint('   ❌ $error');
          }
        }
      }

      results['success'] = results['errors'].isEmpty;
      results['totalRecordsCleared'] = totalRecords;

    } catch (e) {
      results['success'] = false;
      results['mainError'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroDataCleaner (Drift): Erro na limpeza da categoria "$category": $e');
      }
    }

    return results;
  }

  @override
  List<String> getAvailableCategories() {
    return [
      'all',
      'culturas',
      'pragas',
      'defensivos',
      'diagnosticos',
      'favoritos',
      'comentarios',
    ];
  }

  @override
  Future<bool> verifyDataCleanup() async {
    try {
      // NOTE: Diagnosticos is static table - skip verification
      // Only verify user tables (favoritos, comentarios)
      
      final favoritosCount = await (_db.select(_db.favoritos)..where((tbl) => tbl.isDeleted.equals(false))).get().then((rows) => rows.length);
      if (favoritosCount > 0) {
        if (kDebugMode) {
          debugPrint('⚠️ ReceitaAgroDataCleaner (Drift): Tabela "favoritos" ainda contém $favoritosCount registros');
        }
        return false;
      }

      final comentariosCount = await (_db.select(_db.comentarios)..where((tbl) => tbl.isDeleted.equals(false))).get().then((rows) => rows.length);
      if (comentariosCount > 0) {
        if (kDebugMode) {
          debugPrint('⚠️ ReceitaAgroDataCleaner (Drift): Tabela "comentarios" ainda contém $comentariosCount registros');
        }
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();

      final remainingAppKeys = allKeys.where((key) =>
        key.startsWith('receituagro_') ||
        key.startsWith('agro_') ||
        key.startsWith('culture_') ||
        key.startsWith('praga_') ||
        key.startsWith('defensivo_') ||
        key.startsWith('diagnostico_') ||
        key.startsWith('favorite_') ||
        key.startsWith('premium_') ||
        key.contains('receituagro')
      ).toList();

      if (remainingAppKeys.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ ReceitaAgroDataCleaner (Drift): SharedPreferences ainda contêm chaves do app: $remainingAppKeys');
        }
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroDataCleaner (Drift): Erro na verificação: $e');
      }
      return false;
    }
  }

  /// Limpa APENAS tabelas com dados do usuário (preserva dados estáticos como culturas, pragas, etc)
  /// Tabelas do usuário: favoritos, comentarios, diagnosticos, app_settings
  /// Tabelas estáticas preservadas: culturas, pragas, fitossanitarios, plantas_inf, pragas_inf, fitossanitarios_info
  Future<Map<String, dynamic>> _clearUserDataTablesOnly() async {
    final results = <String, dynamic>{
      'clearedTables': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    if (kDebugMode) {
      debugPrint('🧹 ReceitaAgroDataCleaner (Drift): Limpando APENAS tabelas de dados do usuário...');
    }

    int totalRecords = 0;

    // NOTE: Diagnosticos is static table - skip clearing
    // Only clear user tables (favoritos, comentarios)

    // Limpar tabela de favoritos (dados do usuário)
    try {
      final favoritosRows = await (_db.select(_db.favoritos)..where((tbl) => tbl.isDeleted.equals(false))).get();
      final favoritosCount = favoritosRows.length;
      
      // Soft delete
      await (_db.update(_db.favoritos)
        ..where((tbl) => tbl.isDeleted.equals(false))
      ).write(const FavoritosCompanion(isDeleted: Value(true), isDirty: Value(true)));
      
      results['clearedTables'].add('favoritos');
      totalRecords += favoritosCount;

      if (kDebugMode) {
        debugPrint('   ✅ Tabela "favoritos" limpa ($favoritosCount registros)');
      }
    } catch (e) {
      final error = 'Erro ao limpar tabela "favoritos": $e';
      results['errors'].add(error);
      if (kDebugMode) {
        debugPrint('   ❌ $error');
      }
    }

    // Limpar tabela de comentários (dados do usuário)
    try {
      final comentariosRows = await (_db.select(_db.comentarios)..where((tbl) => tbl.isDeleted.equals(false))).get();
      final comentariosCount = comentariosRows.length;
      
      // Soft delete
      await (_db.update(_db.comentarios)
        ..where((tbl) => tbl.isDeleted.equals(false))
      ).write(const ComentariosCompanion(isDeleted: Value(true), isDirty: Value(true)));
      
      results['clearedTables'].add('comentarios');
      totalRecords += comentariosCount;

      if (kDebugMode) {
        debugPrint('   ✅ Tabela "comentarios" limpa ($comentariosCount registros)');
      }
    } catch (e) {
      final error = 'Erro ao limpar tabela "comentarios": $e';
      results['errors'].add(error);
      if (kDebugMode) {
        debugPrint('   ❌ $error');
      }
    }

    // Limpar app_settings (dados do usuário)
    try {
      final appSettingsRows = await _db.select(_db.appSettings).get();
      final appSettingsCount = appSettingsRows.length;
      
      await _db.delete(_db.appSettings).go();
      
      results['clearedTables'].add('app_settings');
      totalRecords += appSettingsCount;

      if (kDebugMode) {
        debugPrint('   ✅ Tabela "app_settings" limpa ($appSettingsCount registros)');
      }
    } catch (e) {
      final error = 'Erro ao limpar tabela "app_settings": $e';
      results['errors'].add(error);
      if (kDebugMode) {
        debugPrint('   ❌ $error');
      }
    }

    // Sempre disparar sincronização para propagar mudanças
    try {
      if (kDebugMode) {
        debugPrint('   🔄 Disparando sincronização com Firestore...');
      }
      unawaited(
        UnifiedSyncManager.instance.forceSyncApp('receituagro').then((_) {
          if (kDebugMode) {
            debugPrint('   ✅ Sincronização com Firestore disparada');
          }
        }).catchError((Object error) {
          if (kDebugMode) {
            debugPrint('   ⚠️ Erro ao sincronizar: $error');
          }
        }),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('   ⚠️ Erro ao disparar sincronização: $e');
      }
    }

    results['totalRecordsCleared'] = totalRecords;
    return results;
  }

  /// Limpa SharedPreferences específicas do ReceitaAgro
  Future<Map<String, dynamic>> _clearAppSharedPreferences() async {
    final results = <String, dynamic>{
      'clearedKeys': <String>[],
      'errors': <String>[],
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final appKeys = allKeys.where((key) =>
        key.startsWith('receituagro_') ||
        key.startsWith('agro_') ||
        key.startsWith('culture_') ||
        key.startsWith('praga_') ||
        key.startsWith('defensivo_') ||
        key.startsWith('diagnostico_') ||
        key.startsWith('favorite_') ||
        key.startsWith('premium_') ||
        key.contains('receituagro') ||
        key == 'theme_mode' // Theme provider key
      ).toList();

      if (kDebugMode) {
        debugPrint('🧹 ReceitaAgroDataCleaner (Drift): Limpando ${appKeys.length} preferências do app...');
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
          results['errors'].add(error);

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
      results['errors'].add('Erro ao acessar SharedPreferences: $e');
      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroDataCleaner (Drift): Erro ao acessar SharedPreferences - $e');
      }
    }

    return results;
  }

  /// Mapear categoria para tabelas correspondentes
  List<String> _getTablesForCategory(String category) {
    switch (category) {
      case 'culturas':
        return ['culturas'];
      case 'pragas':
        return ['pragas'];
      case 'defensivos':
        return ['fitossanitarios'];
      case 'diagnosticos':
        return ['diagnosticos'];
      case 'favoritos':
        return ['favoritos'];
      case 'comentarios':
        return ['comentarios'];
      default:
        return [];
    }
  }

  /// Limpa favoritos e dispara sincronização com Firestore
  /// Usa soft delete para propagar mudanças para outros dispositivos
  Future<Map<String, dynamic>> _markFavoritosAsDeleted() async {
    final results = <String, dynamic>{
      'success': false,
      'totalMarkedAsDeleted': 0,
      'error': null,
    };

    try {
      if (kDebugMode) {
        debugPrint('🧹 ReceitaAgroDataCleaner (Drift): Marcando favoritos como deletados...');
      }

      final favoritosRows = await (_db.select(_db.favoritos)..where((tbl) => tbl.isDeleted.equals(false))).get();
      final favoriteCount = favoritosRows.length;

      // Soft delete: marcar todos como deletados
      await (_db.update(_db.favoritos)
        ..where((tbl) => tbl.isDeleted.equals(false))
      ).write(const FavoritosCompanion(isDeleted: Value(true), isDirty: Value(true)));

      if (kDebugMode) {
        debugPrint('   ✅ $favoriteCount favoritos marcados como deletados');
      }

      // Disparar sincronização com Firestore para propagar mudança
      try {
        if (kDebugMode) {
          debugPrint('   🔄 Disparando sincronização com Firestore...');
        }
        unawaited(
          UnifiedSyncManager.instance.forceSyncApp('receituagro').then((_) {
            if (kDebugMode) {
              debugPrint('   ✅ Sincronização com Firestore disparada com sucesso');
            }
          }).catchError((Object error) {
            if (kDebugMode) {
              debugPrint('   ⚠️ Erro ao sincronizar: $error');
            }
          }),
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('   ⚠️ Erro ao disparar sincronização: $e');
        }
      }

      results['success'] = true;
      results['totalMarkedAsDeleted'] = favoriteCount;

      if (kDebugMode) {
        debugPrint('✅ ReceitaAgroDataCleaner (Drift): Limpeza de favoritos concluída');
      }

      return results;
    } catch (e) {
      results['error'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroDataCleaner (Drift): Erro ao limpar favoritos - $e');
      }
      return results;
    }
  }

  /// Marca todos os comentários como deletados (soft delete) para sincronização
  /// Isso permite que a mudança seja propagada para outros dispositivos via Firestore
  Future<Map<String, dynamic>> _markComentariosAsDeleted() async {
    final results = <String, dynamic>{
      'success': false,
      'totalMarkedAsDeleted': 0,
      'error': null,
    };

    try {
      if (kDebugMode) {
        debugPrint('🧹 ReceitaAgroDataCleaner (Drift): Marcando comentários como deletados (soft delete)...');
      }

      final comentariosRows = await (_db.select(_db.comentarios)..where((tbl) => tbl.isDeleted.equals(false))).get();
      final markedCount = comentariosRows.length;

      // Soft delete: marcar todos como deletados
      await (_db.update(_db.comentarios)
        ..where((tbl) => tbl.isDeleted.equals(false))
      ).write(const ComentariosCompanion(isDeleted: Value(true), isDirty: Value(true)));

      if (kDebugMode) {
        debugPrint('   ✅ $markedCount comentários marcados como deletados');
      }

      // Disparar sincronização com Firestore
      try {
        if (kDebugMode) {
          debugPrint('   🔄 Disparando sincronização com Firestore...');
        }
        unawaited(
          UnifiedSyncManager.instance.forceSyncApp('receituagro').then((_) {
            if (kDebugMode) {
              debugPrint('   ✅ Sincronização com Firestore disparada com sucesso');
            }
          }).catchError((Object error) {
            if (kDebugMode) {
              debugPrint('   ⚠️ Erro ao sincronizar: $error');
            }
          }),
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('   ⚠️ Erro ao disparar sincronização: $e');
        }
      }

      results['success'] = true;
      results['totalMarkedAsDeleted'] = markedCount;

      if (kDebugMode) {
        debugPrint('✅ ReceitaAgroDataCleaner (Drift): Limpeza de comentários concluída');
      }

      return results;
    } catch (e) {
      results['error'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroDataCleaner (Drift): Erro ao limpar comentários - $e');
      }
      return results;
    }
  }
}
