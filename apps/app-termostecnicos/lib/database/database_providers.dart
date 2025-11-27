import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'termostecnicos_database.dart';

part 'database_providers.g.dart';

/// Provider do banco de dados principal
///
/// **Funcionamento em todas as plataformas:**
/// - **Mobile/Desktop**: SQLite nativo via Drift
/// - **Web**: WASM + IndexedDB via Drift
///
/// Usa DriftDatabaseConfig que automaticamente escolhe o executor correto.
@riverpod
TermosTecnicosDatabase termosTecnicosDatabase(Ref ref) {
  final db = TermosTecnicosDatabase.production();

  // Mantém o provider vivo permanentemente
  ref.keepAlive();

  // Fecha o banco quando o provider for descartado
  ref.onDispose(() {
    db.close();
  });

  return db;
}