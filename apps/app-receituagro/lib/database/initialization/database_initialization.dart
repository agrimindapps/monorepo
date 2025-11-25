import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import '../receituagro_database.dart';

/// Helper para inicializar o banco de dados Drift
class DatabaseInitialization {
  DatabaseInitialization._();

  /// Inicializa o banco de dados Drift
  ///
  /// Deve ser chamado no main() antes de runApp()
  static Future<void> initialize({
    required ReceituagroDatabase db,
  }) async {
    developer.log('🔧 Inicializando Drift Database...', name: 'DatabaseInit');

    try {
      // 2. Verificar se o banco foi criado corretamente
      final culturasCount = await _checkDatabase(db);

      developer.log(
        '✅ Banco de dados populado com $culturasCount culturas',
        name: 'DatabaseInit',
      );

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
      final countColumn = db.culturas.id.count();
      final query = db.selectOnly(db.culturas)
        ..addColumns([countColumn]);

      final result = await query.getSingle();
      return result.read(countColumn) ?? 0;
    } catch (e) {
      developer.log(
        '⚠️ Erro ao verificar banco de dados: $e',
        name: 'DatabaseInit.check',
      );
      return 0;
    }
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
