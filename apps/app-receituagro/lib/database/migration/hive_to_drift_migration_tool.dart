import 'dart:developer' as developer;

import 'package:core/core.dart';
import '../receituagro_database.dart';
import '../../core/data/models/diagnostico_legacy.dart';
import '../../core/data/models/favorito_item_legacy.dart';
import '../../core/data/models/comentario_legacy.dart';
// DEPRECATED: import '../../core/utils/box_manager.dart';
import '../loaders/static_data_loader.dart';

/// Tool para migrar dados do Hive para Drift
///
/// Converte todos os dados user-generated (diagnosticos, favoritos, comentários)
/// do HiveBox para o banco de dados Drift SQL.
class HiveToDriftMigrationTool {
  final IHiveManager _hiveManager;
  final ReceituagroDatabase _db;

  HiveToDriftMigrationTool({
    required IHiveManager hiveManager,
    required ReceituagroDatabase database,
  }) : _hiveManager = hiveManager,
       _db = database;

  /// Executa migração completa
  ///
  /// Retorna um MigrationResult com estatísticas da migração
  Future<MigrationResult> migrate() async {
    developer.log(
      '🔄 Iniciando migração Hive → Drift...',
      name: 'HiveToDriftMigration',
    );

    final result = MigrationResult();
    final stopwatch = Stopwatch()..start();

    try {
      // 1. Popular tabelas estáticas PRIMEIRO (necessário para FKs)
      await _populateStaticData();

      // 2. Migrar diagnosticos
      result.diagnosticos = await _migrateDiagnosticos();

      // 3. Migrar favoritos
      result.favoritos = await _migrateFavoritos();

      // 4. Migrar comentarios
      result.comentarios = await _migrateComentarios();

      stopwatch.stop();
      result.durationSeconds = stopwatch.elapsed.inSeconds;

      developer.log(
        '✅ Migração concluída em ${result.durationSeconds}s',
        name: 'HiveToDriftMigration',
      );
      developer.log(result.summary, name: 'HiveToDriftMigration');

      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      developer.log(
        '❌ Erro na migração: $e',
        name: 'HiveToDriftMigration',
        error: e,
        stackTrace: stackTrace,
      );
      result.error = e.toString();
      result.durationSeconds = stopwatch.elapsed.inSeconds;
      return result;
    }
  }

  /// Popula dados estáticos (culturas, pragas, defensivos) a partir dos JSON assets
  ///
  /// Usa o StaticDataLoader para carregar todos os dados dos arquivos JSON
  Future<void> _populateStaticData() async {
    developer.log(
      '📦 Populando dados estáticos...',
      name: 'HiveToDriftMigration.staticData',
    );

    // Verificar se já existem culturas
    final culturasCount = await (_db.selectOnly(
      _db.culturas,
    )..addColumns([_db.culturas.id.count()])).getSingle();

    final count = culturasCount.read(_db.culturas.id.count()) ?? 0;

    if (count > 0) {
      developer.log(
        'ℹ️ Dados estáticos já populados ($count culturas)',
        name: 'HiveToDriftMigration.staticData',
      );
      return;
    }

    try {
      // Usar StaticDataLoader para popular todos os dados
      final loader = StaticDataLoader(_db);
      await loader.loadAll();

      developer.log(
        '✅ Dados estáticos populados com sucesso',
        name: 'HiveToDriftMigration.staticData',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Erro ao popular dados estáticos: $e',
        name: 'HiveToDriftMigration.staticData',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Migra diagnósticos do Hive para Drift
  Future<int> _migrateDiagnosticos() async {
    developer.log(
      '📦 Migrando diagnosticos...',
      name: 'HiveToDriftMigration.diagnosticos',
    );

    final boxResult =
        await BoxManager.withBox<DiagnosticoHive, List<DiagnosticoHive>>(
          hiveManager: _hiveManager,
          boxName: 'diagnosticos',
          operation: (box) async => box.values.toList(),
        );

    final hiveItems = boxResult.fold((failure) {
      developer.log(
        '⚠️ Falha ao abrir box diagnosticos: $failure',
        name: 'HiveToDriftMigration.diagnosticos',
      );
      return <DiagnosticoHive>[];
    }, (data) => data);

    if (hiveItems.isEmpty) {
      developer.log(
        '  ⚠️  Nenhum diagnostico encontrado no Hive',
        name: 'HiveToDriftMigration.diagnosticos',
      );
      return 0;
    }

    developer.log(
      '  📊 ${hiveItems.length} diagnosticos encontrados no Hive',
      name: 'HiveToDriftMigration.diagnosticos',
    );

    int migratedCount = 0;
    int skippedCount = 0;

    await _db.executeTransaction(() async {
      for (final hiveItem in hiveItems) {
        try {
          // Resolve foreign keys (busca IDs nas tabelas estáticas)
          final defensivoId = await _resolveDefenisivoId(
            hiveItem.fkIdDefensivo,
          );
          final culturaId = await _resolveCulturaId(hiveItem.fkIdCultura);
          final pragaId = await _resolvePragaId(hiveItem.fkIdPraga);

          if (defensivoId == null || culturaId == null || pragaId == null) {
            developer.log(
              '  ⚠️  FK não resolvida para diagnostico ${hiveItem.objectId} (defensivo=$defensivoId, cultura=$culturaId, praga=$pragaId)',
              name: 'HiveToDriftMigration.diagnosticos',
            );
            skippedCount++;
            continue;
          }

          // Inserir no Drift
          await _db
              .into(_db.diagnosticos)
              .insert(
                DiagnosticosCompanion.insert(
                  firebaseId: Value(
                    hiveItem.objectId.isNotEmpty ? hiveItem.objectId : null,
                  ),
                  userId: '', // TODO: Resolver userId real
                  createdAt: Value(
                    DateTime.fromMillisecondsSinceEpoch(hiveItem.createdAt),
                  ),
                  updatedAt: Value(
                    DateTime.fromMillisecondsSinceEpoch(hiveItem.updatedAt),
                  ),
                  idReg: hiveItem.idReg,
                  defenisivoId: defensivoId,
                  culturaId: culturaId,
                  pragaId: pragaId,
                  dsMin: Value(hiveItem.dsMin),
                  dsMax: hiveItem.dsMax,
                  um: hiveItem.um,
                  minAplicacaoT: Value(hiveItem.minAplicacaoT),
                  maxAplicacaoT: Value(hiveItem.maxAplicacaoT),
                  umT: Value(hiveItem.umT),
                  minAplicacaoA: Value(hiveItem.minAplicacaoA),
                  maxAplicacaoA: Value(hiveItem.maxAplicacaoA),
                  umA: Value(hiveItem.umA),
                  intervalo: Value(hiveItem.intervalo),
                  intervalo2: Value(hiveItem.intervalo2),
                  epocaAplicacao: Value(hiveItem.epocaAplicacao),
                  isDirty: const Value(false), // Já sincronizado
                  lastSyncAt: Value(DateTime.now()),
                ),
                mode: InsertMode.insertOrIgnore,
              );

          migratedCount++;
        } catch (e) {
          developer.log(
            '  ❌ Erro migrando diagnostico ${hiveItem.objectId}: $e',
            name: 'HiveToDriftMigration.diagnosticos',
          );
          skippedCount++;
        }
      }
    }, operationName: 'Migrate diagnosticos');

    developer.log(
      '  ✅ $migratedCount diagnosticos migrados, $skippedCount skipped',
      name: 'HiveToDriftMigration.diagnosticos',
    );
    return migratedCount;
  }

  /// Migra favoritos do Hive para Drift
  Future<int> _migrateFavoritos() async {
    developer.log(
      '📦 Migrando favoritos...',
      name: 'HiveToDriftMigration.favoritos',
    );

    final boxResult =
        await BoxManager.withBox<FavoritoItemHive, List<FavoritoItemHive>>(
          hiveManager: _hiveManager,
          boxName: 'favoritos',
          operation: (box) async => box.values.toList(),
        );

    final hiveItems = boxResult.fold((failure) {
      developer.log(
        '⚠️ Falha ao abrir box favoritos: $failure',
        name: 'HiveToDriftMigration.favoritos',
      );
      return <FavoritoItemHive>[];
    }, (data) => data);

    if (hiveItems.isEmpty) {
      developer.log(
        '  ⚠️  Nenhum favorito encontrado no Hive',
        name: 'HiveToDriftMigration.favoritos',
      );
      return 0;
    }

    developer.log(
      '  📊 ${hiveItems.length} favoritos encontrados no Hive',
      name: 'HiveToDriftMigration.favoritos',
    );

    int migratedCount = 0;
    int skippedCount = 0;

    await _db.executeTransaction(() async {
      for (final hiveItem in hiveItems) {
        try {
          await _db
              .into(_db.favoritos)
              .insert(
                FavoritosCompanion.insert(
                  firebaseId: Value(
                    hiveItem.sync_objectId.isNotEmpty
                        ? hiveItem.sync_objectId
                        : null,
                  ),
                  userId: '', // TODO: Resolver userId real
                  createdAt: Value(
                    DateTime.fromMillisecondsSinceEpoch(
                      hiveItem.sync_createdAt,
                    ),
                  ),
                  updatedAt: Value(
                    DateTime.fromMillisecondsSinceEpoch(
                      hiveItem.sync_updatedAt,
                    ),
                  ),
                  tipo: hiveItem.tipo,
                  itemId: hiveItem.itemId,
                  itemData: hiveItem.itemData,
                  isDirty: const Value(false),
                  lastSyncAt: Value(DateTime.now()),
                ),
                mode: InsertMode.insertOrIgnore,
              );

          migratedCount++;
        } catch (e) {
          developer.log(
            '  ❌ Erro migrando favorito ${hiveItem.sync_objectId}: $e',
            name: 'HiveToDriftMigration.favoritos',
          );
          skippedCount++;
        }
      }
    }, operationName: 'Migrate favoritos');

    developer.log(
      '  ✅ $migratedCount favoritos migrados, $skippedCount skipped',
      name: 'HiveToDriftMigration.favoritos',
    );
    return migratedCount;
  }

  /// Migra comentários do Hive para Drift
  Future<int> _migrateComentarios() async {
    developer.log(
      '📦 Migrando comentarios...',
      name: 'HiveToDriftMigration.comentarios',
    );

    final boxResult =
        await BoxManager.withBox<ComentarioHive, List<ComentarioHive>>(
          hiveManager: _hiveManager,
          boxName: 'comentarios',
          operation: (box) async => box.values.toList(),
        );

    final hiveItems = boxResult.fold((failure) {
      developer.log(
        '⚠️ Falha ao abrir box comentarios: $failure',
        name: 'HiveToDriftMigration.comentarios',
      );
      return <ComentarioHive>[];
    }, (data) => data);

    if (hiveItems.isEmpty) {
      developer.log(
        '  ⚠️  Nenhum comentario encontrado no Hive',
        name: 'HiveToDriftMigration.comentarios',
      );
      return 0;
    }

    developer.log(
      '  📊 ${hiveItems.length} comentarios encontrados no Hive',
      name: 'HiveToDriftMigration.comentarios',
    );

    int migratedCount = 0;
    int skippedCount = 0;

    await _db.executeTransaction(() async {
      for (final hiveItem in hiveItems) {
        try {
          // ComentarioHive usa pkIdentificador como itemId e conteudo como texto
          await _db
              .into(_db.comentarios)
              .insert(
                ComentariosCompanion.insert(
                  firebaseId: Value(
                    hiveItem.sync_objectId != null &&
                            hiveItem.sync_objectId!.isNotEmpty
                        ? hiveItem.sync_objectId
                        : null,
                  ),
                  userId: hiveItem.userId,
                  createdAt: Value(
                    hiveItem.sync_createdAt != null
                        ? DateTime.fromMillisecondsSinceEpoch(
                            hiveItem.sync_createdAt!,
                          )
                        : DateTime.now(),
                  ),
                  updatedAt: Value(
                    hiveItem.sync_updatedAt != null
                        ? DateTime.fromMillisecondsSinceEpoch(
                            hiveItem.sync_updatedAt!,
                          )
                        : null,
                  ),
                  itemId: hiveItem
                      .pkIdentificador, // pkIdentificador = ID do item comentado
                  texto: hiveItem.conteudo, // conteudo = texto do comentário
                  isDirty: const Value(false),
                  lastSyncAt: Value(DateTime.now()),
                ),
                mode: InsertMode.insertOrIgnore,
              );

          migratedCount++;
        } catch (e) {
          developer.log(
            '  ❌ Erro migrando comentario ${hiveItem.sync_objectId ?? hiveItem.idReg}: $e',
            name: 'HiveToDriftMigration.comentarios',
          );
          skippedCount++;
        }
      }
    }, operationName: 'Migrate comentarios');

    developer.log(
      '  ✅ $migratedCount comentarios migrados, $skippedCount skipped',
      name: 'HiveToDriftMigration.comentarios',
    );
    return migratedCount;
  }

  // ========== FOREIGN KEY RESOLUTION ==========

  /// Resolve ID do defensivo no Drift a partir do ID do Hive
  ///
  /// Retorna null se não encontrado
  Future<int?> _resolveDefenisivoId(String idDefensivo) async {
    if (idDefensivo.isEmpty) return null;

    final query = _db.select(_db.fitossanitarios)
      ..where((tbl) => tbl.idDefensivo.equals(idDefensivo))
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result?.id;
  }

  /// Resolve ID da cultura no Drift a partir do ID do Hive
  ///
  /// Retorna null se não encontrado
  Future<int?> _resolveCulturaId(String idCultura) async {
    if (idCultura.isEmpty) return null;

    final query = _db.select(_db.culturas)
      ..where((tbl) => tbl.idCultura.equals(idCultura))
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result?.id;
  }

  /// Resolve ID da praga no Drift a partir do ID do Hive
  ///
  /// Retorna null se não encontrado
  Future<int?> _resolvePragaId(String idPraga) async {
    if (idPraga.isEmpty) return null;

    final query = _db.select(_db.pragas)
      ..where((tbl) => tbl.idPraga.equals(idPraga))
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result?.id;
  }
}

/// Resultado da migração
class MigrationResult {
  int diagnosticos = 0;
  int favoritos = 0;
  int comentarios = 0;
  int durationSeconds = 0;
  String? error;

  bool get hasError => error != null;
  bool get success => !hasError;

  int get totalMigrated => diagnosticos + favoritos + comentarios;

  String get summary =>
      '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 RESULTADO DA MIGRAÇÃO HIVE → DRIFT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

${success ? '✅ SUCESSO' : '❌ ERRO'}

Registros Migrados:
  • Diagnósticos: $diagnosticos
  • Favoritos: $favoritos
  • Comentários: $comentarios
  • TOTAL: $totalMigrated

Tempo: ${durationSeconds}s

${hasError ? 'Erro: $error' : ''}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ''';
}
