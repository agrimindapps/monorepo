import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../data/models/comentario_legacy.dart';
import 'legacy_adapter_registry.dart';

/// Implementação específica do ReceitaAgro para limpeza de dados
/// Implementa IAppDataCleaner do core package
/// Baseado na implementação bem-sucedida do app-gasometer
class ReceitaAgroDataCleaner implements IAppDataCleaner {
  @override
  String get appName => 'ReceitaAgro';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Dados agronômicos (culturas, pragas, defensivos, diagnósticos, favoritos, premium)';

  @override
  Future<Map<String, dynamic>> clearAllAppData() async {
    if (kDebugMode) {
      debugPrint('🧹 ReceitaAgroDataCleaner: Iniciando limpeza de dados do usuário...');
      debugPrint('   ✅ Preservando dados estáticos: culturas, pragas, defensivos, diagnósticos');
    }

    final startTime = DateTime.now();
    final results = <String, dynamic>{
      'clearedBoxes': <String>[],
      'clearedPreferences': <String>[],
      'errors': <String>[],
      'startTime': startTime,
    };

    try {
      // Limpar apenas dados do usuário (NOT dados estáticos)
      final boxResults = await _clearUserDataBoxesOnly();
      results['clearedBoxes'] = boxResults['clearedBoxes'];
      if (boxResults['errors'] != null) {
        results['errors'].addAll(boxResults['errors']);
      }
      final prefsResults = await _clearAppSharedPreferences();
      results['clearedPreferences'] = prefsResults['clearedKeys'];
      if (prefsResults['errors'] != null) {
        results['errors'].addAll(prefsResults['errors']);
      }

      results['success'] = true;
      results['totalClearedBoxes'] = results['clearedBoxes'].length;
      results['totalClearedPreferences'] = results['clearedPreferences'].length;
      results['totalRecordsCleared'] = boxResults['totalRecordsCleared'] ?? 0;

    } catch (e) {
      results['success'] = false;
      results['mainError'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroDataCleaner: Erro na limpeza - $e');
      }
    }

    results['endTime'] = DateTime.now();
    results['duration'] = results['endTime'].difference(startTime).inMilliseconds;

    if (kDebugMode) {
      debugPrint('✅ ReceitaAgroDataCleaner: Limpeza de dados do usuário finalizada:');
      debugPrint('   Boxes limpos: ${results['totalClearedBoxes'] ?? 0}');
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
        'boxStats': <String, Map<String, dynamic>>{},
        'totalBoxes': 0,
        'totalRecords': 0,
        'appSpecificPrefs': 0,
        'availableCategories': getAvailableCategories(),
      };

      int totalRecords = 0;
      final boxStats = <String, Map<String, dynamic>>{};
      for (final entry in LegacyAdapterRegistry.boxNames.entries) {
        final boxName = entry.value;
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box<dynamic>(boxName);
            final recordCount = box.keys.length;
            totalRecords += recordCount;

            boxStats[entry.key] = {
              'boxName': boxName,
              'totalRecords': recordCount,
              'category': _getCategoryForBox(entry.key),
            };
          }
        } catch (e) {
          boxStats[entry.key] = {
            'boxName': boxName,
            'totalRecords': 0,
            'error': e.toString(),
          };
        }
      }

      stats['boxStats'] = boxStats;
      stats['totalBoxes'] = LegacyAdapterRegistry.boxNames.length;
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
      'clearedBoxes': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    try {
      // Tratamento especial para favoritos e comentários: soft delete com sync
      if (category == 'favoritos') {
        final softDeleteResult = await _markFavoritosAsDeleted();
        if (softDeleteResult['success'] == true) {
          results['clearedBoxes'].add('favoritos');
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
          results['clearedBoxes'].add('comentarios');
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
      final boxesToClear = _getBoxesForCategory(category);

      if (boxesToClear.isEmpty) {
        results['errors'].add('Categoria "$category" não encontrada');
        results['success'] = false;
        return results;
      }

      if (kDebugMode) {
        debugPrint('🧹 ReceitaAgroDataCleaner: Limpando categoria "$category" (${boxesToClear.length} boxes)...');
      }

      int totalRecords = 0;

      for (final boxKey in boxesToClear) {
        final boxName = LegacyAdapterRegistry.boxNames[boxKey];
        if (boxName == null) continue;

        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box<dynamic>(boxName);
            final recordCount = box.keys.length;

            await box.clear();

            results['clearedBoxes'].add(boxKey);
            totalRecords += recordCount;

            if (kDebugMode) {
              debugPrint('   ✅ Box "$boxKey" limpo ($recordCount registros)');
            }
          }
        } catch (e) {
          final error = 'Erro ao limpar box "$boxKey": $e';
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
        debugPrint('❌ ReceitaAgroDataCleaner: Erro na limpeza da categoria "$category": $e');
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
      'premium',
      'comentarios',
    ];
  }

  @override
  Future<bool> verifyDataCleanup() async {
    try {
      for (final boxName in LegacyAdapterRegistry.boxNames.values) {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box<dynamic>(boxName);
          if (box.keys.isNotEmpty) {
            if (kDebugMode) {
              debugPrint('⚠️ ReceitaAgroDataCleaner: Box "$boxName" ainda contém ${box.keys.length} registros');
            }
            return false;
          }
        }
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
          debugPrint('⚠️ ReceitaAgroDataCleaner: SharedPreferences ainda contêm chaves do app: $remainingAppKeys');
        }
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroDataCleaner: Erro na verificação: $e');
      }
      return false;
    }
  }

  /// Limpa APENAS boxes com dados do usuário (preserva dados estáticos como culturas, pragas, etc)
  /// Boxes do usuário: favoritos, comentarios, premium_status
  /// Boxes estáticas preservadas: culturas, pragas, fitossanitarios, diagnosticos, plantas_inf
  Future<Map<String, dynamic>> _clearUserDataBoxesOnly() async {
    final results = <String, dynamic>{
      'clearedBoxes': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    if (kDebugMode) {
      debugPrint('🧹 ReceitaAgroDataCleaner: Limpando APENAS boxes de dados do usuário...');
    }

    // APENAS boxes de dados do usuário - NÃO tocar em dados estáticos
    final userDataBoxKeys = ['favoritos', 'comentarios', 'premium_status'];

    int totalRecords = 0;

    for (final boxKey in userDataBoxKeys) {
      final boxName = LegacyAdapterRegistry.boxNames[boxKey];
      if (boxName == null) continue;

      try {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box<dynamic>(boxName);
          final recordCount = box.keys.length;

          await box.clear();

          results['clearedBoxes'].add(boxKey);
          totalRecords += recordCount;

          if (kDebugMode) {
            debugPrint('   ✅ Box "$boxKey" limpo ($recordCount registros)');
          }
        } else {
          if (kDebugMode) {
            debugPrint('   ⚠️ Box "$boxKey" não está aberto - pulando');
          }
        }
      } catch (e) {
        final error = 'Erro ao limpar box "$boxKey": $e';
        results['errors'].add(error);

        if (kDebugMode) {
          debugPrint('   ❌ $error');
        }
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

  /// Limpa todas as HiveBoxes do ReceitaAgro
  Future<Map<String, dynamic>> _clearAllHiveBoxes() async {
    final results = <String, dynamic>{
      'clearedBoxes': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    if (kDebugMode) {
      debugPrint('🧹 ReceitaAgroDataCleaner: Limpando ${LegacyAdapterRegistry.boxNames.length} HiveBoxes...');
    }

    int totalRecords = 0;

    for (final entry in LegacyAdapterRegistry.boxNames.entries) {
      final boxKey = entry.key;
      final boxName = entry.value;

      try {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box<dynamic>(boxName);
          final recordCount = box.keys.length;

          await box.clear();

          results['clearedBoxes'].add(boxKey);
          totalRecords += recordCount;

          if (kDebugMode) {
            debugPrint('   ✅ Box "$boxKey" limpo ($recordCount registros)');
          }
        } else {
          if (kDebugMode) {
            debugPrint('   ⚠️ Box "$boxKey" não está aberto - pulando');
          }
        }
      } catch (e) {
        final error = 'Erro ao limpar box "$boxKey": $e';
        results['errors'].add(error);

        if (kDebugMode) {
          debugPrint('   ❌ $error');
        }
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
        debugPrint('🧹 ReceitaAgroDataCleaner: Limpando ${appKeys.length} preferências do app...');
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
        debugPrint('❌ ReceitaAgroDataCleaner: Erro ao acessar SharedPreferences - $e');
      }
    }

    return results;
  }

  /// Mapear categoria para boxes correspondentes
  List<String> _getBoxesForCategory(String category) {
    switch (category) {
      case 'culturas':
        return ['culturas'];
      case 'pragas':
        return ['pragas', 'pragas_inf'];
      case 'defensivos':
        return ['fitossanitarios', 'fitossanitarios_info'];
      case 'diagnosticos':
        return ['diagnosticos'];
      case 'favoritos':
        return ['favoritos'];
      case 'premium':
        return ['premium_status'];
      case 'comentarios':
        return ['comentarios'];
      case 'plantas':
        return ['plantas_inf'];
      default:
        return [];
    }
  }

  /// Obter categoria de uma box
  String _getCategoryForBox(String boxKey) {
    switch (boxKey) {
      case 'culturas':
        return 'culturas';
      case 'pragas':
      case 'pragas_inf':
        return 'pragas';
      case 'fitossanitarios':
      case 'fitossanitarios_info':
        return 'defensivos';
      case 'diagnosticos':
        return 'diagnosticos';
      case 'favoritos':
        return 'favoritos';
      case 'premium_status':
        return 'premium';
      case 'comentarios':
        return 'comentarios';
      case 'plantas_inf':
        return 'plantas';
      default:
        return 'outros';
    }
  }

  /// Limpa favoritos e dispara sincronização com Firestore
  /// Isso permite que a mudança seja propagada para outros dispositivos
  Future<Map<String, dynamic>> _markFavoritosAsDeleted() async {
    final results = <String, dynamic>{
      'success': false,
      'totalMarkedAsDeleted': 0,
      'error': null,
    };

    try {
      if (kDebugMode) {
        debugPrint('🧹 ReceitaAgroDataCleaner: Limpando favoritos e disparando sincronização...');
      }

      final boxName = LegacyAdapterRegistry.boxNames['favoritos'];
      if (boxName == null) {
        results['error'] = 'Box de favoritos não encontrada no registry';
        return results;
      }

      if (!Hive.isBoxOpen(boxName)) {
        results['error'] = 'Box de favoritos não está aberta';
        return results;
      }

      final box = Hive.box<dynamic>(boxName);
      final favoriteCount = box.keys.length;

      // Limpar todos os favoritos locais
      await box.clear();

      if (kDebugMode) {
        debugPrint('   ✅ $favoriteCount favoritos removidos localmente');
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
        debugPrint('✅ ReceitaAgroDataCleaner: Limpeza de favoritos concluída');
      }

      return results;
    } catch (e) {
      results['error'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroDataCleaner: Erro ao limpar favoritos - $e');
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
        debugPrint('🧹 ReceitaAgroDataCleaner: Marcando comentários como deletados (soft delete)...');
      }

      final boxName = LegacyAdapterRegistry.boxNames['comentarios'];
      if (boxName == null) {
        results['error'] = 'Box de comentários não encontrada no registry';
        return results;
      }

      if (!Hive.isBoxOpen(boxName)) {
        results['error'] = 'Box de comentários não está aberta';
        return results;
      }

      final box = Hive.box<ComentarioHive>(boxName);
      int markedCount = 0;

      // Iterar sobre todos os comentários e marcar como deletados
      for (final key in box.keys) {
        try {
          final comentario = box.get(key);
          if (comentario != null) {
            // Marcar como deletado (sync_deleted = true)
            comentario.sync_deleted = true;
            await box.put(key, comentario);
            markedCount++;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('   ⚠️ Erro ao marcar comentário $key: $e');
          }
        }
      }

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
        debugPrint('✅ ReceitaAgroDataCleaner: Soft delete de comentários concluído');
      }

      return results;
    } catch (e) {
      results['error'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroDataCleaner: Erro ao marcar comentários como deletados - $e');
      }
      return results;
    }
  }
}
