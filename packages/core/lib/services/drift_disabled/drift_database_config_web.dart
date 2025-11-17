import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Configuração base para bancos de dados Drift (Web)
///
/// Esta classe fornece métodos utilitários para configurar e inicializar
/// bancos de dados Drift de forma consistente em todo o monorepo.
///
/// IMPORTANTE: Para web, usa WASM (WebAssembly) + IndexedDB
class DriftDatabaseConfig {
  /// Cria um QueryExecutor para o banco de dados
  ///
  /// [databaseName] - Nome do banco de dados (usado como chave no IndexedDB)
  /// [logStatements] - Se deve logar as queries SQL (útil para debug)
  static QueryExecutor createExecutor({
    required String databaseName,
    bool logStatements = false,
  }) {
    return LazyDatabase(() async {
      try {
        // ignore: avoid_print
        print('🔧 Initializing Drift WASM database: $databaseName');

        final result = await WasmDatabase.open(
          databaseName: databaseName,
          sqlite3Uri: Uri.parse('sqlite3.wasm'),
          driftWorkerUri: Uri.parse('drift_worker.dart.js'),
        );

        if (result.missingFeatures.isNotEmpty) {
          // ignore: avoid_print
          print('⚠️ Missing features for drift web: ${result.missingFeatures}');
        }

        // ignore: avoid_print
        print('✅ Drift WASM database initialized successfully');

        return result.resolvedExecutor;
      } catch (e, stackTrace) {
        // ignore: avoid_print
        print('❌ Failed to initialize Drift WASM database: $e');
        // ignore: avoid_print
        print('Stack trace: $stackTrace');
        rethrow;
      }
    });
  }

  /// Cria um executor customizado para casos especiais
  ///
  /// Na web, customPath é ignorado pois usa IndexedDB
  static QueryExecutor createCustomExecutor({
    required String databaseName,
    String? customPath,
    bool logStatements = false,
  }) {
    // Na web, ignoramos customPath e usamos IndexedDB
    return createExecutor(
      databaseName: databaseName,
      logStatements: logStatements,
    );
  }

  /// Cria um executor em memória (útil para testes)
  ///
  /// Na web, cria um banco temporário no IndexedDB
  static QueryExecutor createInMemoryExecutor({bool logStatements = false}) {
    return createExecutor(
      databaseName: 'drift_memory_${DateTime.now().millisecondsSinceEpoch}',
      logStatements: logStatements,
    );
  }

  /// Obtém o caminho do banco de dados
  ///
  /// Na web, retorna o nome da chave do IndexedDB
  static Future<String> getDatabasePath(String databaseName) async {
    return 'indexeddb://$databaseName';
  }

  /// Deleta o banco de dados (útil para reset ou testes)
  ///
  /// NOTA: No web, essa operação pode não ser tão precisa quanto no mobile
  static Future<void> deleteDatabase(String databaseName) async {
    // No web, precisaríamos usar IndexedDB API diretamente
    // Por enquanto, deixamos vazio - a implementação completa requer JS interop
    // O Drift irá criar um novo banco se não existir
  }

  /// Verifica se o banco de dados existe
  ///
  /// Na web, sempre retorna true pois IndexedDB cria automaticamente
  static Future<bool> databaseExists(String databaseName) async {
    // IndexedDB cria o banco automaticamente se não existir
    return true;
  }

  /// Obtém o tamanho do banco de dados em bytes
  ///
  /// Na web, retorna 0 pois não há acesso direto ao tamanho do IndexedDB
  static Future<int> getDatabaseSize(String databaseName) async {
    // No web, não temos acesso direto ao tamanho do IndexedDB
    return 0;
  }

  /// Cria um backup do banco de dados
  ///
  /// Na web, essa operação não é suportada
  static Future<String> backupDatabase(String databaseName) async {
    throw UnsupportedError(
      'Database backup is not supported on web platform. '
      'Consider using export/import functionality instead.',
    );
  }

  /// Restaura o banco de dados de um backup
  ///
  /// Na web, essa operação não é suportada
  static Future<void> restoreDatabase({
    required String databaseName,
    required String backupPath,
  }) async {
    throw UnsupportedError(
      'Database restore is not supported on web platform. '
      'Consider using import functionality instead.',
    );
  }
}
