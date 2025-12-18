import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/nebulalist_database.dart';
import '../database/repositories/list_repository.dart';
import '../database/repositories/item_repository.dart';
import '../database/repositories/item_master_repository.dart';

part 'database_providers.g.dart';

/// Provider do banco de dados principal
///
/// **Funcionamento em todas as plataformas:**
/// - **Mobile/Desktop**: SQLite nativo via Drift
/// - **Web**: WASM + IndexedDB via Drift
///
/// Usa DriftDatabaseConfig que automaticamente escolhe o executor correto.
@riverpod
NebulalistDatabase nebulalistDatabase(Ref ref) {
  final db = NebulalistDatabase.production();

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

/// Provider do ListRepository
@riverpod
ListRepository listRepository(Ref ref) {
  final db = ref.watch(nebulalistDatabaseProvider);
  return ListRepository(db);
}

/// Provider do ItemRepository
@riverpod
ItemRepository itemRepository(Ref ref) {
  final db = ref.watch(nebulalistDatabaseProvider);
  return ItemRepository(db);
}

/// Provider do ItemMasterDriftRepository
/// NOTE: Currently used only by DAOs, not by feature layer
@riverpod
ItemMasterDriftRepository itemMasterDriftRepository(Ref ref) {
  final db = ref.watch(nebulalistDatabaseProvider);
  return ItemMasterDriftRepository(db);
}
