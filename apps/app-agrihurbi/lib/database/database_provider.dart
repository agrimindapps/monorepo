import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'agrihurbi_database.dart';
import 'repositories/bovine_repository.dart';
import 'repositories/equine_repository.dart';

part 'database_provider.g.dart';

/// Provider do banco de dados principal
///
/// **Funcionamento em todas as plataformas:**
/// - **Mobile/Desktop**: SQLite nativo via Drift
/// - **Web**: WASM + IndexedDB via Drift
///
/// Usa DriftDatabaseConfig que automaticamente escolhe o executor correto.
@riverpod
AgrihurbiDatabase agrihurbiDatabase(Ref ref) {
  final db = AgrihurbiDatabase.production();

  // Mantém o provider vivo permanentemente
  ref.keepAlive();

  // Fecha o banco quando o provider for descartado
  ref.onDispose(() {
    db.close();
  });

  return db;
}

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================

/// Provider do BovineRepository
@riverpod
BovineRepository bovineRepository(Ref ref) {
  final db = ref.watch(agrihurbiDatabaseProvider);
  return BovineRepository(db);
}

/// Provider do EquineRepository
@riverpod
EquineRepository equineRepository(Ref ref) {
  final db = ref.watch(agrihurbiDatabaseProvider);
  return EquineRepository(db);
}
