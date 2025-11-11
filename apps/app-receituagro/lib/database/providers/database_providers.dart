import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../receituagro_database.dart';
import '../repositories/repositories.dart';

part 'database_providers.g.dart';

// ========== DATABASE PROVIDER ==========

/// Provider do banco de dados Drift
///
/// Cria uma única instância do banco de dados e a mantém viva durante
/// toda a vida do app. Quando o ref for disposed, fecha o banco.
@riverpod
ReceituagroDatabase database(Ref ref) {
  final db = GetIt.instance<ReceituagroDatabase>();
  ref.onDispose(() => db.close());
  return db;
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

// ========== STREAM PROVIDERS (Reactive UI) ==========

/// Stream de diagnósticos do usuário
///
/// A UI pode observar este provider para reagir automaticamente
/// a mudanças nos diagnósticos
@riverpod
Stream<List<DiagnosticoData>> diagnosticosStream(Ref ref, String userId) {
  final repo = ref.watch(diagnosticoRepositoryProvider);
  return repo.watchByUserId(userId);
}

/// Stream de diagnósticos com dados relacionados (JOIN)
@riverpod
Stream<List<DiagnosticoEnriched>> diagnosticosEnrichedStream(
  Ref ref,
  String userId,
) {
  final repo = ref.watch(diagnosticoRepositoryProvider);
  return repo.watchAllWithRelations(userId);
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

/// Provider para buscar diagnósticos recentes
@riverpod
Future<List<DiagnosticoData>> diagnosticosRecent(
  Ref ref, {
  required String userId,
  int limit = 10,
}) async {
  final repo = ref.watch(diagnosticoRepositoryProvider);
  return repo.findRecent(userId, limit: limit);
}

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

/// Provider para contar diagnósticos do usuário
@riverpod
Future<int> diagnosticosCount(Ref ref, String userId) async {
  final repo = ref.watch(diagnosticoRepositoryProvider);
  return repo.countByUserId(userId);
}

/// Provider para contar favoritos por tipo
@riverpod
Future<Map<String, int>> favoritosCountByType(Ref ref, String userId) async {
  final repo = ref.watch(favoritoRepositoryProvider);
  return repo.countByType(userId);
}
