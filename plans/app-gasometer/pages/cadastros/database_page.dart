// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/pages/database_inspector_page.dart';
import '../../../../core/services/database_inspector_service.dart';

/// Wrapper da página Database original usando o novo sistema reutilizável
///
/// Esta página mantém a interface original mas usa o novo DatabaseInspectorPage
/// reutilizável que foi movido para core/services.
class DatabaseContentPage extends StatelessWidget {
  const DatabaseContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DatabaseInspectorPage(
      initialStorageType: StorageType.hive,
      customTitle: 'Databases',
      showBackButton: true,
      primaryColor: Color.fromARGB(255, 46, 55, 107),
    );
  }
}

/// Versão para uso em drawer/menu lateral
class DatabaseMenuItem extends StatelessWidget {
  const DatabaseMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    return const DatabaseInspectorDrawerItem(
      customText: 'Database Inspector',
      customIcon: Icons.storage,
      initialStorageType: StorageType.hive,
    );
  }
}

/// Widget de conveniência para debug - pode ser adicionado temporariamente em qualquer tela
class DebugDatabaseButton extends StatelessWidget {
  final StorageType? initialType;
  final String? label;

  const DebugDatabaseButton({
    super.key,
    this.initialType,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextButton.icon(
          onPressed: () => DatabaseInspectorPage.navigate(
            context,
            initialStorageType: initialType ?? StorageType.hive,
            customTitle: 'Debug Database',
          ),
          icon: const Icon(Icons.bug_report, color: Colors.white, size: 16),
          label: Text(
            label ?? 'DB',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

/// Exemplo de como usar o serviço programaticamente
class DatabaseInspectorHelper {
  static final _service = DatabaseInspectorService.instance;

  /// Verifica se há dados em uma box específica
  static Future<bool> hasDataInBox(String boxName) async {
    try {
      final records = await _service.loadHiveBoxData(boxName);
      return records.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking box $boxName: $e');
      return false;
    }
  }

  /// Obtém contagem de registros de uma box
  static Future<int> getRecordCount(String boxName) async {
    try {
      final records = await _service.loadHiveBoxData(boxName);
      return records.length;
    } catch (e) {
      debugPrint('Error counting records in $boxName: $e');
      return 0;
    }
  }

  /// Obtém estatísticas de todas as boxes
  static Future<Map<String, int>> getAllBoxStatistics() async {
    final stats = <String, int>{};

    for (final boxType in DatabaseInspectorService.instance.availableBoxTypes) {
      try {
        final count = await getRecordCount(boxType.key);
        stats[boxType.displayName] = count;
      } catch (e) {
        debugPrint('Error getting stats for ${boxType.key}: $e');
        stats[boxType.displayName] = 0;
      }
    }

    return stats;
  }

  /// Limpa uma chave específica do SharedPreferences
  static Future<bool> clearSharedPrefsKey(String key) async {
    try {
      await _service.removeSharedPrefsKey(key);
      return true;
    } catch (e) {
      debugPrint('Error removing SharedPrefs key $key: $e');
      return false;
    }
  }

  /// Verifica se há dados no SharedPreferences
  static Future<bool> hasSharedPrefsData() async {
    try {
      final records = await _service.loadSharedPreferencesData();
      return records.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking SharedPrefs: $e');
      return false;
    }
  }
}
