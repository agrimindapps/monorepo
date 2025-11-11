import 'dart:developer' as developer;

import 'package:core/core.dart';
import '../receituagro_database.dart';
import '../migration/hive_to_drift_migration_tool.dart';

/// Helper para inicializar o banco de dados Drift
class DatabaseInitialization {
  DatabaseInitialization._();

  /// Inicializa o banco de dados Drift e executa migração se necessário
  ///
  /// Deve ser chamado no main() antes de runApp()
  static Future<void> initialize({
    required GetIt getIt,
    bool runMigration = true,
  }) async {
    developer.log('🔧 Inicializando Drift Database...', name: 'DatabaseInit');

    try {
      // 1. Obter instância do banco de dados (já registrado via @lazySingleton)
      final db = getIt<ReceituagroDatabase>();

      // 2. Verificar se o banco foi criado corretamente
      final culturasCount = await _checkDatabase(db);

      // 3. Se necessário, executar migração do Hive
      if (runMigration && culturasCount == 0) {
        developer.log(
          '🔄 Banco de dados vazio. Iniciando migração Hive → Drift...',
          name: 'DatabaseInit',
        );

        await _runMigration(getIt, db);
      } else {
        developer.log(
          '✅ Banco de dados já populado ($culturasCount culturas)',
          name: 'DatabaseInit',
        );
      }

      developer.log(
        '✅ Drift Database inicializado com sucesso!',
        name: 'DatabaseInit',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Erro ao inicializar Drift Database: $e',
        name: 'DatabaseInit',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Verifica se o banco está acessível e retorna count de culturas
  static Future<int> _checkDatabase(ReceituagroDatabase db) async {
    try {
      final query = db.selectOnly(db.culturas)
        ..addColumns([db.culturas.id.count()]);

      final result = await query.getSingle();
      return result.read(db.culturas.id.count()) ?? 0;
    } catch (e) {
      developer.log(
        '⚠️ Erro ao verificar banco de dados: $e',
        name: 'DatabaseInit.check',
      );
      return 0;
    }
  }

  /// Executa a migração Hive → Drift
  static Future<void> _runMigration(GetIt getIt, ReceituagroDatabase db) async {
    try {
      final hiveManager = getIt<IHiveManager>();

      final tool = HiveToDriftMigrationTool(
        hiveManager: hiveManager,
        database: db,
      );

      final result = await tool.migrate();

      developer.log(result.summary, name: 'DatabaseInit.migration');

      if (result.hasError) {
        throw Exception('Migration failed: ${result.error}');
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ Erro na migração: $e',
        name: 'DatabaseInit.migration',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Força uma nova migração (use apenas para desenvolvimento/teste)
  static Future<void> forceMigration({required GetIt getIt}) async {
    developer.log('⚠️ Forçando nova migração...', name: 'DatabaseInit.force');

    final db = getIt<ReceituagroDatabase>();
    final hiveManager = getIt<IHiveManager>();

    final tool = HiveToDriftMigrationTool(
      hiveManager: hiveManager,
      database: db,
    );

    final result = await tool.migrate();
    developer.log(result.summary, name: 'DatabaseInit.force');
  }

  /// Exporta dados do usuário para backup
  static Future<Map<String, dynamic>> exportUserData({
    required GetIt getIt,
    required String userId,
  }) async {
    developer.log(
      '📤 Exportando dados do usuário...',
      name: 'DatabaseInit.export',
    );

    final db = getIt<ReceituagroDatabase>();
    final data = await db.exportUserData(userId);

    developer.log(
      '✅ Exportação completa: ${data['diagnosticos'].length} diagnosticos, '
      '${data['favoritos'].length} favoritos, '
      '${data['comentarios'].length} comentarios',
      name: 'DatabaseInit.export',
    );

    return data;
  }

  /// Limpa todos os dados do usuário (hard delete)
  ///
  /// ⚠️ ATENÇÃO: Esta operação é irreversível!
  static Future<void> clearUserData({
    required GetIt getIt,
    required String userId,
  }) async {
    developer.log(
      '🗑️ Limpando dados do usuário...',
      name: 'DatabaseInit.clear',
    );

    final db = getIt<ReceituagroDatabase>();
    await db.clearUserData(userId);

    developer.log('✅ Dados do usuário limpos', name: 'DatabaseInit.clear');
  }
}

/// Exemplo de uso no main.dart:
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // 1. Configurar GetIt (injectable)
///   configureDependencies();
///
///   // 2. Inicializar Drift (com migração automática)
///   await DatabaseInitialization.initialize(
///     getIt: getIt,
///     runMigration: true,
///   );
///
///   // 3. Executar app
///   runApp(
///     ProviderScope(
///       child: MyApp(),
///     ),
///   );
/// }
/// ```
