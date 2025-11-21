import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/favoritos_repository_simplified.dart';
import 'favoritos_services_providers.dart';

part 'favoritos_providers.g.dart';

/// Bridge provider for FavoritosRepositorySimplified
@riverpod
FavoritosRepositorySimplified favoritosRepositorySimplified(FavoritosRepositorySimplifiedRef ref) {
  return FavoritosRepositorySimplified(
    service: ref.watch(favoritosServiceProvider),
  );
}
