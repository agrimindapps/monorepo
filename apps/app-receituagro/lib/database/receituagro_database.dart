import 'package:core/core.dart';
import 'package:drift/drift.dart';

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
    PlantasInf,
    Pragas,
    PragasInf,
    Fitossanitarios,
    FitossanitariosInfo,
    // Version control
    StaticDataVersion,
  ],
)
class ReceituagroDatabase extends _$ReceituagroDatabase with BaseDriftDatabase {
  ReceituagroDatabase(super.e);

  @override
  int get schemaVersion => 2;

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
  factory ReceituagroDatabase.development() {
    return ReceituagroDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'receituagro_drift_dev.db',
        logStatements: true,
      ),
    );
  }

  /// Factory para testes
  factory ReceituagroDatabase.test() {
    return ReceituagroDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
  }

  /// Factory com path customizado
  factory ReceituagroDatabase.withPath(String path) {
    return ReceituagroDatabase(
      DriftDatabaseConfig.createCustomExecutor(
        databaseName: 'receituagro_drift.db',
        customPath: path,
        logStatements: false,
      ),
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      // Criar todas as tabelas
      await m.createAll();
      print('✅ Receituagro Database: Tabelas criadas');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Migration from version 1 to 2: Add StaticDataVersion table
      if (from < 2) {
        await m.createTable(staticDataVersion);
        print('⬆️ Migration v1→v2: StaticDataVersion table added');
      }
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
      print('ℹ️ Dados estáticos já populados ($count culturas)');
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
  /// Busca diagnósticos (tabela estática - todos os dados)
  ///
  /// NOTA: Diagnosticos agora é uma tabela estática (lookup).
  /// Não pertence a usuários específicos.
  Future<List<Diagnostico>> getDiagnosticos({int limit = 50}) async {
    final query = select(diagnosticos)..limit(limit);
    return await query.get();
  }

  /// Stream de diagnósticos (tabela estática)
  Stream<List<Diagnostico>> watchDiagnosticos() {
    return select(diagnosticos).watch();
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

  // ========== SYNC METHODS - REMOVED ==========
  // NOTE: Diagnosticos table is STATIC (no sync fields)
  // getDirtyDiagnosticos() removed - table has no isDirty field

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

  // NOTA: clearUserData/exportUserData removidos - Diagnosticos é tabela estática sem userId
  // Para operações de usuário, usar tabelas Favoritos e Comentarios
}
