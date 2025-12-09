import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../database/providers/database_providers.dart';
import '../../../../database/repositories/favorito_repository.dart';
import '../../data/repositories/favoritos_repository_simplified.dart';
import 'favoritos_services_providers.dart';

part 'favoritos_providers.g.dart';

/// Bridge provider for FavoritosRepositorySimplified
@riverpod
FavoritosRepositorySimplified favoritosRepositorySimplified(Ref ref) {
  return FavoritosRepositorySimplified(
    service: ref.watch(favoritosServiceProvider),
  );
}

/// Stream provider que escuta mudanças nos favoritos do Drift
/// Isso permite sincronização em tempo real entre dispositivos
@riverpod
Stream<List<FavoritoData>> favoritosStream(Ref ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null || userId.isEmpty) {
    return Stream.value([]);
  }

  final repository = ref.watch(favoritoRepositoryProvider);
  return repository.watchByUserId(userId);
}

/// Stream provider para favoritos por tipo específico
@riverpod
Stream<List<FavoritoData>> favoritosByTipoStream(Ref ref, String tipo) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null || userId.isEmpty) {
    return Stream.value([]);
  }

  final repository = ref.watch(favoritoRepositoryProvider);
  return repository.watchByUserAndType(userId, tipo);
}
