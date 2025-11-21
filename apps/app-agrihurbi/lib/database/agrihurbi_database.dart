import 'package:drift/drift.dart';
import 'package:core/core.dart';

import 'tables/livestock_tables.dart';

part 'agrihurbi_database.g.dart'; // Será gerado pelo Drift

/// Banco de dados principal do AgruiHurbi Drift
///
/// Este banco gerencia todas as tabelas relacionadas ao gerenciamento de rebanho,
/// incluindo informações sobre bovinos e equinos com rastreamento completo.
///
/// **Funcionalidades:**
/// - Armazenamento local com SQLite
/// - Sincronização offline-first com FirebaseFirestore (futuro)
/// - Streams reativos para UI
/// - Controle de versão e conflitos
/// - Soft deletes para integridade de dados
/// - Foreign keys com integridade referencial
///
/// **Uso:**
/// ```dart
/// // Inicializar
/// final db = AgrihurbiDatabase.production();
///
/// // Usar em repositórios
/// final bovinesRepo = BovineRepository(db);
///
/// // Observar mudanças
/// db.select(db.bovines).watch().listen((bovines) {
///   print('Bovines atualizados: ${bovines.length}');
/// });
/// ```
@DriftDatabase(
  tables: [Bovines, Equines],
)
class AgrihurbiDatabase extends _$AgrihurbiDatabase with BaseDriftDatabase {
  AgrihurbiDatabase(super.e);

  /// Factory para produção
  /// Nota: Não use @lazySingleton aqui, registre manualmente em main.dart
  factory AgrihurbiDatabase.production() {
    return AgrihurbiDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'agrihurbi_drift.db',
        logStatements: false,
      ),
    );
  }

  @override
  int get schemaVersion => 1;

  /// Factory para ambiente de desenvolvimento
  ///
  /// Habilita logging de SQL queries para debug
  factory AgrihurbiDatabase.development() {
    return AgrihurbiDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'agrihurbi_drift_dev.db',
        logStatements: true,
      ),
    );
  }

  /// Factory para testes
  ///
  /// Usa banco de dados em memória
  factory AgrihurbiDatabase.test() {
    return AgrihurbiDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
  }

  /// Factory com path customizado
  ///
  /// Útil para backup/restore ou testes específicos
  factory AgrihurbiDatabase.withPath(String path) {
    return AgrihurbiDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: path,
        logStatements: false,
      ),
    );
  }

  // ========== MIGRATIONS & SETUP ==========

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          print('✅ Database created with schema version: $schemaVersion');
        },
        onUpgrade: (Migrator m, int from, int to) async {
          print('🔄 Upgrading database from v$from to v$to');
          // Implementar migrações aqui se necessário no futuro
        },
        beforeOpen: (details) async {
          print(
              '📝 Database open. Version: ${details.versionBefore} → ${details.versionNow}');
          // Habilitar foreign keys
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // ========== CUSTOM QUERIES & HELPERS ==========

  /// Busca bovinos ativos com ordenação
  Future<List<Bovine>> getActiveBovines() async {
    final query = select(bovines)
      ..where((tbl) => tbl.isActive.equals(true))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.commonName)]);
    return query.get();
  }

  /// Busca equinos ativos com ordenação
  Future<List<Equine>> getActiveEquines() async {
    final query = select(equines)
      ..where((tbl) => tbl.isActive.equals(true))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.commonName)]);
    return query.get();
  }

  /// Stream reativo de bovinos ativos
  Stream<List<Bovine>> watchActiveBovines() {
    return (select(bovines)..where((tbl) => tbl.isActive.equals(true))).watch();
  }

  /// Stream reativo de equinos ativos
  Stream<List<Equine>> watchActiveEquines() {
    return (select(equines)..where((tbl) => tbl.isActive.equals(true))).watch();
  }

  /// Limpa todos os dados (útil para testes)
  Future<void> deleteAllData() async {
    await delete(bovines).go();
    await delete(equines).go();
  }

  /// Limpa todos os dados inativos (housekeeping)
  Future<void> deleteInactiveData() async {
    await (delete(bovines)..where((tbl) => tbl.isActive.equals(false))).go();
    await (delete(equines)..where((tbl) => tbl.isActive.equals(false))).go();
  }

  /// Exporta todos os dados como JSON
  Future<Map<String, dynamic>> exportAsJson() async {
    final bovinesList = await select(bovines).get();
    final equinesList = await select(equines).get();

    return {
      'version': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'bovines': bovinesList.map((b) => _bovineToJson(b)).toList(),
      'equines': equinesList.map((e) => _equineToJson(e)).toList(),
    };
  }

  /// Importa dados de JSON
  Future<void> importFromJson(Map<String, dynamic> jsonData) async {
    try {
      final bovinesData = jsonData['bovines'] as List?;
      final equinesData = jsonData['equines'] as List?;

      await transaction(() async {
        if (bovinesData != null) {
          for (final bovineJson in bovinesData) {
            final bovine = _bovineFromJson(bovineJson as Map<String, dynamic>);
            await into(bovines).insertOnConflictUpdate(bovine);
          }
        }

        if (equinesData != null) {
          for (final equineJson in equinesData) {
            final equine = _equineFromJson(equineJson as Map<String, dynamic>);
            await into(equines).insertOnConflictUpdate(equine);
          }
        }
      });
    } catch (e) {
      print('❌ Error importing data: $e');
      rethrow;
    }
  }

  // ========== JSON SERIALIZATION HELPERS ==========

  Map<String, dynamic> _bovineToJson(Bovine bovine) {
    return {
      'id': bovine.id,
      'createdAt': bovine.createdAt?.toIso8601String(),
      'updatedAt': bovine.updatedAt?.toIso8601String(),
      'isActive': bovine.isActive,
      'registrationId': bovine.registrationId,
      'commonName': bovine.commonName,
      'originCountry': bovine.originCountry,
      'imageUrls': bovine.imageUrls,
      'thumbnailUrl': bovine.thumbnailUrl,
      'animalType': bovine.animalType,
      'origin': bovine.origin,
      'characteristics': bovine.characteristics,
      'breed': bovine.breed,
      'aptitude': bovine.aptitude,
      'tags': bovine.tags,
      'breedingSystem': bovine.breedingSystem,
      'purpose': bovine.purpose,
      'notes': bovine.notes,
    };
  }

  BovinesCompanion _bovineFromJson(Map<String, dynamic> json) {
    return BovinesCompanion.insert(
      id: json['id'] as String,
      createdAt: json['createdAt'] != null
          ? Value(DateTime.parse(json['createdAt'] as String))
          : const Value(null),
      updatedAt: json['updatedAt'] != null
          ? Value(DateTime.parse(json['updatedAt'] as String))
          : const Value(null),
      isActive: Value(json['isActive'] as bool? ?? true),
      registrationId: json['registrationId'] as String,
      commonName: json['commonName'] as String,
      originCountry: json['originCountry'] as String,
      imageUrls: Value(json['imageUrls'] as String? ?? '[]'),
      thumbnailUrl: json['thumbnailUrl'] != null
          ? Value(json['thumbnailUrl'] as String)
          : const Value(null),
      animalType: json['animalType'] as String,
      origin: json['origin'] as String,
      characteristics: json['characteristics'] as String,
      breed: json['breed'] as String,
      aptitude: json['aptitude'] as int,
      tags: Value(json['tags'] as String? ?? '[]'),
      breedingSystem: json['breedingSystem'] as int,
      purpose: json['purpose'] as String,
      notes: json['notes'] != null
          ? Value(json['notes'] as String)
          : const Value(null),
    );
  }

  Map<String, dynamic> _equineToJson(Equine equine) {
    return {
      'id': equine.id,
      'createdAt': equine.createdAt?.toIso8601String(),
      'updatedAt': equine.updatedAt?.toIso8601String(),
      'isActive': equine.isActive,
      'registrationId': equine.registrationId,
      'commonName': equine.commonName,
      'originCountry': equine.originCountry,
      'imageUrls': equine.imageUrls,
      'thumbnailUrl': equine.thumbnailUrl,
      'history': equine.history,
      'temperament': equine.temperament,
      'coat': equine.coat,
      'primaryUse': equine.primaryUse,
      'geneticInfluences': equine.geneticInfluences,
      'height': equine.height,
      'weight': equine.weight,
    };
  }

  EquinesCompanion _equineFromJson(Map<String, dynamic> json) {
    return EquinesCompanion.insert(
      id: json['id'] as String,
      createdAt: json['createdAt'] != null
          ? Value(DateTime.parse(json['createdAt'] as String))
          : const Value(null),
      updatedAt: json['updatedAt'] != null
          ? Value(DateTime.parse(json['updatedAt'] as String))
          : const Value(null),
      isActive: Value(json['isActive'] as bool? ?? true),
      registrationId: json['registrationId'] as String,
      commonName: json['commonName'] as String,
      originCountry: json['originCountry'] as String,
      imageUrls: Value(json['imageUrls'] as String? ?? '[]'),
      thumbnailUrl: json['thumbnailUrl'] != null
          ? Value(json['thumbnailUrl'] as String)
          : const Value(null),
      history: json['history'] as String,
      temperament: json['temperament'] as int,
      coat: json['coat'] as int,
      primaryUse: json['primaryUse'] as int,
      geneticInfluences: json['geneticInfluences'] as String,
      height: json['height'] as String,
      weight: json['weight'] as String,
    );
  }
}
