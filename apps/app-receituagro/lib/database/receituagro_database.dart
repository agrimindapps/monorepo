import 'package:core/core.dart';
import 'tables/receituagro_tables.dart';

part 'receituagro_database.g.dart';

/// Banco de dados principal do ReceitaAgro Drift
///
/// Este banco gerencia todas as tabelas relacionadas ao compêndio agrícola,
/// incluindo diagnósticos, favoritos, comentários e dados estáticos (culturas, pragas, defensivos).
///
/// **Funcionalidades:**
/// - Armazenamento local com SQLite
/// - Sincronização com Firebase
/// - Streams reativos para UI
/// - Controle de versão e conflitos
/// - Soft deletes
/// - Foreign keys com integridade referencial
///
/// **Uso:**
/// ```dart
/// // Inicializar
/// final db = ReceituagroDatabase.production();
///
/// // Usar em repositórios
/// final diagnosticoRepo = DiagnosticoRepository(db);
///
/// // Observar mudanças
/// db.select(db.diagnosticos).watch().listen((diagnosticos) {
///   print('Diagnósticos atualizados: ${diagnosticos.length}');
/// });
/// ```
@DriftDatabase(
  tables: [
    // User-generated data
    Diagnosticos,
    Favoritos,
    Comentarios,
    AppSettings,
    // Static data (JSON assets)
    Culturas,
    Pragas,
    PragasInf,
    Fitossanitarios,
    FitossanitariosInfo,
  ],
)
@lazySingleton
class ReceituagroDatabase extends _$ReceituagroDatabase with BaseDriftDatabase {
  ReceituagroDatabase(QueryExecutor e) : super(e);

  /// Factory Injectable
  @factoryMethod
  factory ReceituagroDatabase.injectable() {
    print('🏭 Creating ReceituagroDatabase via injectable factory');
    final db = ReceituagroDatabase.production();
    print('✅ ReceituagroDatabase created successfully: ${db.hashCode}');
    return db;
  }

  @override
  int get schemaVersion => 1;

  /// Factory para ambiente de produção
  factory ReceituagroDatabase.production() {
    return ReceituagroDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'receituagro_drift.db',
        logStatements: false,
      ),
    );
  }

  /// Factory para ambiente de desenvolvimento
  ///
  /// Habilita logging de SQL queries para debug
  factory ReceituagroDatabase.development() {
    return ReceituagroDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'receituagro_drift_dev.db',
        logStatements: true, // Log SQL queries
      ),
    );
  }

  /// Factory para testes
  ///
  /// Usa banco de dados em memória
  factory ReceituagroDatabase.test() {
    return ReceituagroDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
  }

  /// Factory com path customizado
  ///
  /// Útil para backup/restore ou testes específicos
  factory ReceituagroDatabase.withPath(String path) {
    return ReceituagroDatabase(
      DriftDatabaseConfig.createCustomExecutor(
        databaseName: 'receituagro_drift.db',
        customPath: path,
        logStatements: false,
      ),
    );
  }

  /// Estratégia de migração do banco de dados
  ///
  /// Define como o banco deve ser criado e atualizado entre versões
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      // Criar todas as tabelas
      await m.createAll();

      print('✅ Receituagro Database: Tabelas criadas');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Migrações futuras virão aqui
      // if (from < 2) {
      //   await m.addColumn(diagnosticos, diagnosticos.newColumn);
      // }
    },
    beforeOpen: (details) async {
      // ⚠️ CRÍTICO: Habilitar foreign keys
      await customStatement('PRAGMA foreign_keys = ON');

      // Log da abertura do banco
      if (details.wasCreated) {
        print(
          '✅ Receituagro Database criado com sucesso! v${details.versionNow}',
        );
        // Popular dados estáticos após criação
        await _populateStaticDataIfNeeded();
      } else if (details.hadUpgrade) {
        print(
          '⬆️ Receituagro Database atualizado de v${details.versionBefore} para v${details.versionNow}',
        );
      }
    },
  );

  /// Popula dados estáticos (culturas, pragas, defensivos) a partir dos JSON assets
  ///
  /// Este método deve ser chamado apenas na primeira execução (onCreate)
  Future<void> _populateStaticDataIfNeeded() async {
    // Verificar se já existem dados
    final culturasCount = await (selectOnly(
      culturas,
    )..addColumns([culturas.id.count()])).getSingle();

    final count = culturasCount.read(culturas.id.count()) ?? 0;

    if (count > 0) {
      print('ℹ️ Dados estáticos já populados (${count} culturas)');
      return;
    }

    print('📦 Populando dados estáticos dos JSON assets...');

    // TODO: Implementar carregamento dos JSON assets
    // 1. Carregar assets/database/json/tbculturas/ → inserir em culturas
    // 2. Carregar assets/database/json/tbpragas/ → inserir em pragas
    // 3. Carregar assets/database/json/tbpragasinf/ → inserir em pragasInf
    // 4. Carregar assets/database/json/tbfitossanitarios/ → inserir em fitossanitarios
    // 5. Carregar assets/database/json/tbfitossanitariosinfo/ → inserir em fitossanitariosInfo

    print('⚠️ Carregamento de dados estáticos ainda não implementado');
  }

  // ========== QUERIES ÚTEIS ==========

  /// Busca diagnósticos do usuário ordenados por data (mais recente primeiro)
  Future<List<Diagnostico>> getDiagnosticosByUser(
    String userId, {
    int limit = 50,
  }) async {
    final query = select(diagnosticos)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(limit);
    return await query.get();
  }

  /// Stream de diagnósticos do usuário
  Stream<List<Diagnostico>> watchDiagnosticosByUser(String userId) {
    final query = select(diagnosticos)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    return query.watch();
  }

  /// Busca favoritos do usuário por tipo
  Future<List<Favorito>> getFavoritosByUserAndType(
    String userId,
    String tipo,
  ) async {
    final query = select(favoritos)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.tipo.equals(tipo) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    return await query.get();
  }

  /// Stream de favoritos do usuário
  Stream<List<Favorito>> watchFavoritosByUser(String userId) {
    final query = select(favoritos)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    return query.watch();
  }

  /// Verifica se um item está favoritado
  Future<bool> isFavorited(String userId, String tipo, String itemId) async {
    final query = selectOnly(favoritos)
      ..addColumns([favoritos.id.count()])
      ..where(
        favoritos.userId.equals(userId) &
            favoritos.tipo.equals(tipo) &
            favoritos.itemId.equals(itemId) &
            favoritos.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return (result.read(favoritos.id.count()) ?? 0) > 0;
  }

  /// Busca comentários de um item
  Future<List<Comentario>> getComentariosByItem(String itemId) async {
    final query = select(comentarios)
      ..where((tbl) => tbl.itemId.equals(itemId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    return await query.get();
  }

  /// Stream de comentários de um item
  Stream<List<Comentario>> watchComentariosByItem(String itemId) {
    final query = select(comentarios)
      ..where((tbl) => tbl.itemId.equals(itemId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    return query.watch();
  }

  /// Conta comentários de um item
  Future<int> countComentariosByItem(String itemId) async {
    final query = selectOnly(comentarios)
      ..addColumns([comentarios.id.count()])
      ..where(
        comentarios.itemId.equals(itemId) & comentarios.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return result.read(comentarios.id.count()) ?? 0;
  }

  /// Busca registros que precisam ser sincronizados (isDirty = true)
  Future<List<Diagnostico>> getDirtyDiagnosticos() async {
    final query = select(diagnosticos)
      ..where((tbl) => tbl.isDirty.equals(true));
    return await query.get();
  }

  // ========== QUERIES ESTÁTICAS (DADOS JSON) ==========

  /// Busca todas as culturas
  Future<List<Cultura>> getAllCulturas() async {
    return (select(
      culturas,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.nome)])).get();
  }

  /// Busca cultura por ID
  Future<Cultura?> getCulturaById(String idCultura) async {
    return (select(
      culturas,
    )..where((tbl) => tbl.idCultura.equals(idCultura))).getSingleOrNull();
  }

  /// Busca todas as pragas
  Future<List<Praga>> getAllPragas() async {
    return (select(
      pragas,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.nome)])).get();
  }

  /// Busca praga por ID
  Future<Praga?> getPragaById(String idPraga) async {
    return (select(
      pragas,
    )..where((tbl) => tbl.idPraga.equals(idPraga))).getSingleOrNull();
  }

  /// Busca todos os defensivos
  Future<List<Fitossanitario>> getAllDefensivos() async {
    return (select(
      fitossanitarios,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.nome)])).get();
  }

  /// Busca defensivo por ID
  Future<Fitossanitario?> getDefensivoById(String idDefensivo) async {
    return (select(
      fitossanitarios,
    )..where((tbl) => tbl.idDefensivo.equals(idDefensivo))).getSingleOrNull();
  }

  // ========== OPERAÇÕES EM LOTE ==========

  /// Marca múltiplos registros como deletados (soft delete)
  Future<void> softDeleteDiagnosticos(List<int> diagnosticoIds) async {
    await executeTransaction(() async {
      for (final id in diagnosticoIds) {
        await (update(diagnosticos)..where((tbl) => tbl.id.equals(id))).write(
          DiagnosticosCompanion(
            isDeleted: const Value(true),
            isDirty: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    }, operationName: 'Soft delete diagnosticos');
  }

  /// Limpa todos os dados de um usuário (hard delete)
  Future<void> clearUserData(String userId) async {
    await executeTransaction(() async {
      // Deletar em ordem (respeitar foreign keys)
      await (delete(
        comentarios,
      )..where((tbl) => tbl.userId.equals(userId))).go();
      await (delete(favoritos)..where((tbl) => tbl.userId.equals(userId))).go();
      await (delete(
        diagnosticos,
      )..where((tbl) => tbl.userId.equals(userId))).go();
    }, operationName: 'Clear user data');
  }

  /// Exporta dados do usuário para JSON
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    final userDiagnosticos = await (select(
      diagnosticos,
    )..where((tbl) => tbl.userId.equals(userId))).get();

    final userFavoritos = await (select(
      favoritos,
    )..where((tbl) => tbl.userId.equals(userId))).get();

    final userComentarios = await (select(
      comentarios,
    )..where((tbl) => tbl.userId.equals(userId))).get();

    return {
      'export_date': DateTime.now().toIso8601String(),
      'user_id': userId,
      'diagnosticos': userDiagnosticos.map((d) => d.toJson()).toList(),
      'favoritos': userFavoritos.map((f) => f.toJson()).toList(),
      'comentarios': userComentarios.map((c) => c.toJson()).toList(),
    };
  }
}
