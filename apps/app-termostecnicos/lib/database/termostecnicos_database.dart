import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/comentario_dao.dart';
import 'tables/comentarios_table.dart';

part 'termostecnicos_database.g.dart';

/// Main database for Termos Tecnicos app
/// Manages comments storage with Drift/SQLite
@DriftDatabase(tables: [Comentarios], daos: [ComentarioDao])
class TermosTecnicosDatabase extends _$TermosTecnicosDatabase {
  TermosTecnicosDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    // Mobile/Desktop implementation only
    // Web support can be added later with drift/wasm.dart
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'termostecnicos.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
