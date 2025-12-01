import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/core_providers.dart';
import '../receituagro_database.dart';
import '../repositories/repositories.dart';
import '../repositories/static_data_version_repository.dart';
import '../sync/adapters/comentarios_drift_sync_adapter.dart';
import '../sync/adapters/favoritos_drift_sync_adapter.dart';

part 'database_providers.g.dart';

// ========== DATABASE PROVIDER ==========

/// Provider do banco de dados Drift
///
/// IMPORTANTE: Este provider é um ALIAS para receituagroDatabaseProvider
/// definido em core_providers.dart, garantindo que apenas UMA instância
/// do banco de dados seja criada durante toda a vida da aplicação.
///
/// Usar SEMPRE este provider ou receituagroDatabaseProvider para acessar o banco.
@riverpod
ReceituagroDatabase database(Ref ref) {
  // Reutiliza a instância do receituagroDatabaseProvider (manual provider)
  // para evitar criar múltiplas instâncias do banco de dados
  return ref.watch(receituagroDatabaseProvider);
}

// ========== REPOSITORY PROVIDERS ==========

/// Provider do repositório de diagnósticos
@riverpod
DiagnosticoRepository diagnosticoRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return DiagnosticoRepository(db);
}

/// Provider do repositório de favoritos
@riverpod
FavoritoRepository favoritoRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return FavoritoRepository(db);
}

/// Provider do repositório de comentários
@riverpod
ComentarioRepository comentarioRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return ComentarioRepository(db);
}

/// Provider do repositório de fitossanitários
@riverpod
FitossanitariosRepository fitossanitariosRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return FitossanitariosRepository(db);
}

/// Provider do repositório de informações de fitossanitários
@riverpod
FitossanitariosInfoRepository fitossanitariosInfoRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return FitossanitariosInfoRepository(db);
}

/// Provider do repositório de culturas
@riverpod
CulturasRepository culturasRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return CulturasRepository(db);
}

/// Provider do repositório de pragas
@riverpod
PragasRepository pragasRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return PragasRepository(db);
}

/// Provider do repositório de informações de pragas
@riverpod
PragasInfRepository pragasInfRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return PragasInfRepository(db);
}

/// Provider do repositório de informações de plantas
@riverpod
PlantasInfRepository plantasInfRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return PlantasInfRepository(db);
}

/// Provider do repositório de controle de versão dos dados estáticos
@riverpod
StaticDataVersionRepository staticDataVersionRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return StaticDataVersionRepository(db);
}

// ========== STREAM PROVIDERS (Reactive UI) ==========

/// Stream de diagnósticos com dados relacionados (JOIN)
@riverpod
Stream<List<DiagnosticoEnriched>> diagnosticosEnrichedStream(Ref ref) {
  final repo = ref.watch(diagnosticoRepositoryProvider);
  return repo.watchAllWithRelations();
}

/// Stream de favoritos do usuário
@riverpod
Stream<List<FavoritoData>> favoritosStream(Ref ref, String userId) {
  final repo = ref.watch(favoritoRepositoryProvider);
  return repo.watchByUserId(userId);
}

/// Stream de favoritos por tipo
@riverpod
Stream<List<FavoritoData>> favoritosByTypeStream(
  Ref ref, {
  required String userId,
  required String tipo,
}) {
  final repo = ref.watch(favoritoRepositoryProvider);
  return repo.watchByUserAndType(userId, tipo);
}

/// Stream de comentários de um item
@riverpod
Stream<List<ComentarioData>> comentariosStream(Ref ref, String itemId) {
  final repo = ref.watch(comentarioRepositoryProvider);
  return repo.watchByItem(itemId);
}

/// Stream de comentários do usuário
@riverpod
Stream<List<ComentarioData>> comentariosUserStream(Ref ref, String userId) {
  final repo = ref.watch(comentarioRepositoryProvider);
  return repo.watchByUserId(userId);
}

// ========== FUTURE PROVIDERS (One-time data fetch) ==========

/// Provider para verificar se item está favoritado
@riverpod
Future<bool> isFavorited(
  Ref ref, {
  required String userId,
  required String tipo,
  required String itemId,
}) async {
  final repo = ref.watch(favoritoRepositoryProvider);
  return repo.isFavorited(userId, tipo, itemId);
}

/// Provider para contar comentários de um item
@riverpod
Future<int> comentariosCount(Ref ref, String itemId) async {
  final repo = ref.watch(comentarioRepositoryProvider);
  return repo.countByItem(itemId);
}

/// Provider para contar favoritos por tipo
@riverpod
Future<Map<String, int>> favoritosCountByType(Ref ref, String userId) async {
  final repo = ref.watch(favoritoRepositoryProvider);
  return repo.countByType(userId);
}

// ========== SYNC ADAPTER PROVIDERS ==========

/// Provider do adapter de sincronização de favoritos
@riverpod
FavoritosDriftSyncAdapter favoritosSyncAdapter(Ref ref) {
  final db = ref.watch(databaseProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return FavoritosDriftSyncAdapter(db, firestore, connectivity);
}

/// Provider do adapter de sincronização de comentários
@riverpod
ComentariosDriftSyncAdapter comentariosSyncAdapter(Ref ref) {
  final db = ref.watch(databaseProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return ComentariosDriftSyncAdapter(db, firestore, connectivity);
}
